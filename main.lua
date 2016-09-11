-- Modules
local Class = require('lib.middleclass')
local Timer = require('lib.timer')
local Gui = require('lib.suit')
local Gif = require('lib.gifcat')

local ceil = math.ceil
print(love.filesystem.getSaveDirectory())

-- Functions
local Rule = Class('Rule')
function Rule:initialize(survive, birth)
  self.survive = survive
  self.birth = birth
end

function Rule:check(cell)
  local n = cell:getNeighbors()
  
  for _, v in ipairs(cell.state == 0 and self.birth or self.survive) do
    if v == n then return true end
  end
  
  return false
end

local Cell = Class('Cell')
Cell.static.COLOR = {
  {0, 0, 0},
  {255, 255, 255}
}
function Cell:initialize(field, x, y, state)
  self.field = field
  self.x = x
  self.y = y
  self.state = state
end

function Cell:getNeighbors()
  local n, width, height = 0, self.field.width, self.field.height
  local x, y = self.x, self.y
  
  for i = x - 1, x + 1 do
    for j = y - 1, y + 1 do
      i = (i < 1 and width or (i > width and 1 or i))
      j = (j < 1 and height or (j > height and 1 or j))
      
      if self.field[i][j].state == 1 then
        n = n + 1
      end
    end
  end
  
  return n - self.state
end

function Cell:draw(x, y, width, height)
  love.graphics.setColor(Cell.COLOR[self.state + 1])
  love.graphics.rectangle('fill', x, y, width, height)
end

local GameOfLife = Class('GameOfLife')
function GameOfLife:initialize(field, rule)
  self.field = field
  self.rule = rule
end

function GameOfLife:simulate()
  local width, height = self.field.width, self.field.height
  local cell, n
  local copy = self.field:createTempCopy()
  
  for x = 1, width do
    for y = 1, height do
      cell = self.field[x][y]
      copy[x][y] = self.rule:check(cell) and 1 or 0
    end
  end
  
  for x = 1, width do
    for y = 1, height do
      self.field[x][y].state = copy[x][y]
    end
  end
end

function GameOfLife:renderToImageData()
  local imageData = love.image.newImageData(self.field.width, self.field.height)
  local color
  for x = 1, self.field.width do
    for y = 1, self.field.height do
      color = Cell.COLOR[self.field[x][y].state + 1]
      imageData:setPixel(x - 1, y - 1, color[1], color[2], color[3], 255)
    end
  end
  
  return imageData
end

local Field = Class('Field')
function Field:initialize(width, height)
  self.width = width
  self.height = height
  
  for x = 1, width do
    self[x] = {}
    for y = 1, height do
      self[x][y] = Cell(self, x, y, 0)
    end
  end
end

function Field:createTempCopy()
  local copy = {}
  for x = 1, self.width do
    copy[x] = {}
    for y = 1, self.height do
      copy[x][y] = 0
    end
  end
  
  return copy
end

function Field:draw(x, y, width, height)
  local cellWidth, cellHeight = width / self.width, height / self.height
  local cell
  
  for i = 1, self.width do
    for j = 1, self.height do
      cell = self[i][j]
      cell:draw(x + cellWidth * (i - 1), y + cellWidth * (j - 1), cellWidth, cellHeight)
    end
  end
end

local Section = Class('Section')
function Section:initialize(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
end

-- Main Program
local rule = Rule({2, 3}, {3})
local field = Field(50, 50)
local gameOfLife = GameOfLife(field, rule)
local isRunning = false

local menu = Section(0, 0, love.graphics.getWidth(), 50)
menu.buttons = 5
menu.button = {}
function menu:update()
  local button = self.button
  Gui.layout:reset(self.x, self.y)
  
  button.start = Gui.Button('Start', Gui.layout:col(self.width / menu.buttons, self.height))
  if button.start.hit and not isRunning then
    gif = Gif.newGif(os.time()..".gif", 300, 300)
    Timer.every(1, function() 
      gameOfLife:simulate()
      local image = gameOfLife:renderToImageData()
      gif:frame(image)
    end)
    isRunning = true
  end
  
  button.stop = Gui.Button('Stop', Gui.layout:col())
  if button.stop.hit and isRunning then
    Timer.clear()
    gif:close()
    gif = nil
    isRunning = false
  end
  
  button.clear = Gui.Button('Clear', Gui.layout:col())
  if button.clear.hit then
    for x = 1, field.width do
      for y = 1, field.height do
        field[x][y].state = 0
      end
    end
  end
  
  button.export = Gui.Button('Export', Gui.layout:col())
  
  button.exit = Gui.Button('Exit', Gui.layout:col())
  if button.exit.hit then
    love.event.quit()
    Gif.close()
  end
end

function menu:draw()
  Gui.draw()
end

local playfield = Section(0, 50, love.graphics.getWidth(), love.graphics.getHeight() - 50)
function playfield:mousereleased(mouseX, mouseY, button)
  local mouseIn = {
    x = mouseX < self.x + self.width and mouseX > self.x,
    y = mouseY < self.y + self.height and mouseY > self.y
  }
  print(mouseIn.x, mouseIn.y, mouseX, mouseY)

  if mouseIn.x and mouseIn.y and button == 1 then
    local x = ceil((mouseX - self.x) / (self.width / field.width))
    local y = ceil((mouseY - self.y) / (self.height / field.height))
    
    field[x][y].state = 1 - field[x][y].state
  end
end

function playfield:draw()
  gameOfLife.field:draw(self.x, self.y, playfield.width, playfield.height)
end

-- Love2d
function love.load()
  Gif.init()
end

function love.mousereleased(mouseX, mouseY, button)
  playfield:mousereleased(mouseX, mouseY, button)
end

function love.keypressed(key)
  Gui.keypressed(key)
end

function love.update(dt)
  Timer.update(dt)
  
  menu:update()
end

function love.draw()
  playfield:draw()
  menu:draw()
end

