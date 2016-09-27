-- Modules
local Class = require('lib.middleclass')
local Timer = require('lib.timer')
local Gui = require('lib.suit')

-- Classes
local Field, Rule, Cell, GameOfLife = require('gameOfLife')()

local ceil = math.ceil

-- Main Program
local rule = Rule({2, 3}, {3})
local field = Field(50, 50)
local gameOfLife = GameOfLife(field, rule)
local isRunning = false
