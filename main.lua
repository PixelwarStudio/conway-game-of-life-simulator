-- Modules
local Class = require('lib.middleclass')
local Timer = require('lib.timer')
local Gui = require('lib.suit')
local Gif = require('lib.gifcat')

-- Classes
local Field, Rule, Cell, GameOfLife = require('gameOfLife')()

local ceil = math.ceil

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

