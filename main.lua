-- Modules
local Class = require('lib.middleclass')
local Timer = require('lib.timer')
local Suit = require('lib.suit')

-- Classes
local Field, Rule, Cell, GameOfLife = require('gameOfLife')()

local ceil = math.ceil

-- Main Program
local rule = Rule({2, 3}, {3})
local field = Field(50, 50)
local gameOfLife = GameOfLife(field, rule)
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
input.width = {text = '50'}
input.height = {text = '50'}
input.survive = {text = '23'}
input.birth = {text = '3'}

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
    Suit.Label('Field', Suit.layout:row(self.width, 40))

    Suit.layout:push(Suit.layout:row())
        Suit.Label('Width', {align = 'left'}, Suit.layout:col(self.width * 0.6, 40))
        Suit.Input(input.width, Suit.layout:col(self.width * 0.4))
    Suit.layout:pop()

    Suit.layout:push(Suit.layout:row())
        Suit.Label('Height', {align = 'left'}, Suit.layout:col(self.width * 0.6, 40))
        Suit.Input(input.height, Suit.layout:col(self.width * 0.4))
    Suit.layout:pop()

    if Suit.Button('Create', Suit.layout:row()).hit then
    end

    -- Rule settings
    Suit.Label('Rule', Suit.layout:row(self.width, 40))
    Suit.layout:push(Suit.layout:row())
        Suit.Label('Survive', {align = 'left'}, Suit.layout:col(self.width * 0.6, 40))
        Suit.Input(input.survive, Suit.layout:col(self.width * 0.4))
    Suit.layout:pop()

    Suit.layout:push(Suit.layout:row())
        Suit.Label('Birth', {align = 'left'}, Suit.layout:col(self.width * 0.6, 40))
        Suit.Input(input.birth, Suit.layout:col(self.width * 0.4))
    Suit.layout:pop()

    if Suit.Button('Apply', Suit.layout:row()).hit then
    end

    -- Actions
    Suit.Label('Actions', Suit.layout:row(self.width, 40))
    if Suit.Button('Start', Suit.layout:row()).hit then
    end

    if Suit.Button('Stop', Suit.layout:row()).hit then
    end

    if Suit.Button('Next', Suit.layout:row()).hit then
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
    width = love.graphics.getWidth() - section.menu.width
}

function section.field:draw()
end

-- Main
function love.update()
    section.menu:update()
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