-- Modules
local Class = require('lib.middleclass')
local Timer = require('lib.timer')
local Suit = require('lib.suit')

-- Classes
local Field, Rule, Cell, GameOfLife = require('gameOfLife')()

local simulTimer

local ceil = math.ceil

-- Main Program
local rule = Rule({2, 3}, {3})
local field = Field(50, 50)
local gol = GameOfLife(field, rule)
local isRunning = false

-- Gui theme
Suit.theme.cornerRadius = 0
Suit.theme.color = {
    normal  = {bg = {218, 40, 40}, fg = {0, 0, 0}},
    hovered = {bg = {218, 22, 22}, fg = {0, 0, 0}},
    active  = {bg = {218, 6, 6}, fg = {0, 0, 0}}
}

-- Input
local input = {}
input.size = {text = '50'}
input.survive = {text = '23'}
input.birth = {text = '3'}
input.delay = {text = '0.5'}

-- Sections
local section = {}
section.menu = {
    x = 0,
    y = 0,
    width = 125
}

function section.menu:update()
    -- Field Settings
    Suit.layout:reset(self.x, self.y)
    Suit.Label('Game Of Life', Suit.layout:row(self.width, 40))

    Suit.layout:push(Suit.layout:row())
        Suit.Label('Field Size', {align = 'left'}, Suit.layout:col(self.width * 0.6, 40))
        Suit.Input(input.size, Suit.layout:col(self.width * 0.4))
    Suit.layout:pop()

    -- Rule settings
    Suit.layout:push(Suit.layout:row())
        Suit.Label('Survive', {align = 'left'}, Suit.layout:col(self.width * 0.6, 40))
        Suit.Input(input.survive, Suit.layout:col(self.width * 0.4))
    Suit.layout:pop()

    Suit.layout:push(Suit.layout:row())
        Suit.Label('Birth', {align = 'left'}, Suit.layout:col(self.width * 0.6, 40))
        Suit.Input(input.birth, Suit.layout:col(self.width * 0.4))
    Suit.layout:pop()

    if Suit.Button('Create', Suit.layout:row()).hit then
        field = Field(tonumber(input.size.text), tonumber(input.size.text))
        local survive = {}
        local birth = {}

        for oneRule in string.gmatch(input.survive.text,"%d") do
            table.insert(survive, tonumber(oneRule))
        end

        for oneRule in string.gmatch(input.birth.text,"%d") do
            table.insert(birth, tonumber(oneRule))
        end

        rule = Rule(survive, birth)
        gol = GameOfLife(field, rule)
        
        if isRunning then
            Timer.cancel(simulTimer);
            isRunning = false
        end
    end

    -- Simulation
    Suit.Label('Simulation', Suit.layout:row(self.width, 40))
    Suit.Label((isRunning and '' or 'not')..' running', Suit.layout:row(self.width, 40))
    if Suit.Button('Start', Suit.layout:row()).hit and not(isRunning) then
        simulTimer = Timer.every(0.5, function() gol:simulate() end)
        isRunning = true
    end

    if Suit.Button('Stop', Suit.layout:row()).hit and isRunning then
        Timer.cancel(simulTimer)
        isRunning = false
    end

    if Suit.Button('Next', Suit.layout:row()).hit then
        gol:simulate()
    end

    -- Export
    Suit.Label('Export', Suit.layout:row())
    if Suit.Button('Bitmap', Suit.layout:row()).hit then
        gol.field:toImageData():encode('png', 'format.png')
    end

    _, self.height = Suit.layout:nextRow()
end

function section.menu:draw()
    love.graphics.setColor({255, 255, 255})
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

section.field = {
    x = 125,
    y = 0,
    width = love.graphics.getWidth() - section.menu.width,
    height = love.graphics.getHeight()
}

function section.field:mousereleased(mouseX, mouseY, button)
    local mouseIn = {
        x = mouseX < self.x + self.width and mouseX > self.x,
        y = mouseY < self.y + self.height and mouseY > self.y
    }

    if mouseIn.x and mouseIn.y and button == 1 then
        local x = ceil((mouseX - self.x) / (self.width / field.width))
        local y = ceil((mouseY - self.y) / (self.height / field.height))
        
        gol.field[x][y]:changeState()
    end
end

function section.field:draw()
    gol.field:draw(self.x, self.y, self.width, self.height)
end

-- Main
function love.update(dt)
    Timer.update(dt)
    section.menu:update()
end

function love.mousereleased(mouseX, mouseY, button)
    section.field:mousereleased(mouseX, mouseY, button)
end

function love.draw()
    love.graphics.setBackgroundColor({231, 231, 231})
    section.menu:draw()
    section.field:draw()
    Suit.draw()
end

function love.textinput(t)
    Suit.textinput(t)
end

function love.keypressed(key)
    Suit.keypressed(key)
end