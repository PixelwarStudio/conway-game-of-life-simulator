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