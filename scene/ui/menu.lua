local window = require("ui.base.window").new()

local global = require("global")

local ui = require("ui.base.ui")
local anchor = require("ui.base.anchor")

local button = require("ui.button")
local text = require("ui.text")

local font = global.assets["font.robotoReg18"]

local anchor = anchor.new("Center", 0,0, {min=280,max=320},{min=120,max=150})
local anchorBox = ui.new(anchor)

window:addChild(anchorBox)

local anchor = anchor.new("NorthWest", 0,0, 130,50)
local buttonNew2D = button.new(anchor)
buttonNew2D:setText("New 2D Map", nil, font)
buttonNew2D:setOutline(true, 4, 2)
buttonNew2D:setRoundCorner(7)

anchorBox:addChild(buttonNew2D)

local anchor = anchor.new("NorthEast", 0,0, 130,50)
local buttonNew3D = button.new(anchor)
buttonNew3D:setText("New 3D Map", nil, font)
buttonNew3D:setOutline(true, 4, 2)
buttonNew3D:setRoundCorner(7)

anchorBox:addChild(buttonNew3D)

local anchor = anchor.new("South", 0,0, 130,50)
local buttonLoad = button.new(anchor)
buttonLoad:setText("Load Map", nil, font)
buttonLoad:setOutline(true, 4, 2)
buttonLoad:setRoundCorner(7)

anchorBox:addChild(buttonLoad)

local anchor = anchor.new("SouthWest", 20,20, 80,80)
local buttonLanguage = button.new(anchor)
buttonLanguage:setImage(global.assets["icon.language"])
buttonLanguage:setOutline(true, 4, 2)
buttonLanguage:setRoundCorner(7)

window:addChild(buttonLanguage)

local anchor = anchor.new("SouthEast", 20,20, 80,80)
local buttonHelp = button.new(anchor)
buttonHelp:setImage(global.assets["icon.help"])
buttonHelp:setOutline(true, 4, 2)
buttonHelp:setRoundCorner(7)

window:addChild(buttonHelp)

local anchor = anchor.new("North", 0, 30)
local textTitle = text.new(anchor, "BrushMap", global.assets["font.kennyfuture72"])

window:addChild(textTitle)

return window