local window = require("ui.base.window")
local menu = window.new()

local global = require("global")

local anchor = require("ui.base.anchor")

local button = require("ui.button")

local anchor = anchor.new("Center", -120, -20, 200, 100)
local buttonNew2D = button.new(anchor)
buttonNew2D:addText("New 2D Map")
buttonNew2D:setOutline(true, 2, 1)
buttonNew2D:setRoundCorner(7)

menu:addChild(buttonNew2D)

local anchor = anchor.new("Center", 120, -20, 200, 100)
local buttonNew3D = button.new(anchor)
buttonNew3D:addText("New 3D Map")
buttonNew3D:setOutline(true, 2, 1)
buttonNew3D:setRoundCorner(7)

menu:addChild(buttonNew3D)

local anchor = anchor.new("Center", 0, 120, 200, 100)
local buttonLoad = button.new(anchor)

--buttonLoad:addText("Load Map")
buttonLoad:addText(tostring(result))

buttonLoad:setOutline(true, 2, 1)
buttonLoad:setRoundCorner(7)

menu:addChild(buttonLoad)

local anchor = anchor.new("SouthWest", 15, 15, {min=50,max=150}, {min=50,max=150})
local buttonLanguage = button.new(anchor)
buttonLanguage:addImage(global.assets["icon.language"])
buttonLanguage:setOutline(true, 2, 1)
buttonLanguage:setRoundCorner(7)

menu:addChild(buttonLanguage)

local anchor = anchor.new("SouthEast", 15, 15, {min=50,max=150}, {min=50,max=150})
local buttonHelp = button.new(anchor)
buttonHelp:addImage(global.assets["icon.help"])
buttonHelp:setOutline(true, 2, 1)
buttonHelp:setRoundCorner(7)

menu:addChild(buttonHelp)

local anchor = anchor.new("North", 0, 30, 500, 100)
local buttonTitle = button.new(anchor, {0.15,0.15,0.15})
buttonTitle:addText("BrushMap", nil, global.assets["font.kennyfuture72"])

menu:addChild(buttonTitle)

local _,_, width, height = love.window.getSafeArea()
menu:updateAnchor(width, height)
return menu