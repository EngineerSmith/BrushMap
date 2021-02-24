local window = require("ui.base.window").new()

local global = require("global")

local anchor = require("ui.base.anchor")

local button = require("ui.button")
local text = require("ui.text")

local anchor = anchor.new("Center", -120, -20, 200, 100)
local buttonNew2D = button.new(anchor)
buttonNew2D:setText("New 2D Map")
buttonNew2D:setOutline(true, 2, 1)
buttonNew2D:setRoundCorner(7)

window:addChild(buttonNew2D)

local anchor = anchor.new("Center", 120, -20, 200, 100)
local buttonNew3D = button.new(anchor)
buttonNew3D:setText("New 3D Map")
buttonNew3D:setOutline(true, 2, 1)
buttonNew3D:setRoundCorner(7)

window:addChild(buttonNew3D)

local anchor = anchor.new("Center", 0, 120, 200, 100)
local buttonLoad = button.new(anchor)
buttonLoad:setText("Load Map")
buttonLoad:setOutline(true, 2, 1)
buttonLoad:setRoundCorner(7)

window:addChild(buttonLoad)

local anchor = anchor.new("SouthWest", 15, 15, {min=50,max=150}, {min=50,max=150})
local buttonLanguage = button.new(anchor)
buttonLanguage:setImage(global.assets["icon.language"])
buttonLanguage:setOutline(true, 2, 1)
buttonLanguage:setRoundCorner(7)

window:addChild(buttonLanguage)

local anchor = anchor.new("SouthEast", 15, 15, {min=50,max=150}, {min=50,max=150})
local buttonHelp = button.new(anchor)
buttonHelp:setImage(global.assets["icon.help"])
buttonHelp:setOutline(true, 2, 1)
buttonHelp:setRoundCorner(7)

window:addChild(buttonHelp)

local anchor = anchor.new("North", 10, 30)
local textTitle = text.new(anchor, "BrushMap", global.assets["font.kennyfuture72"])

window:addChild(textTitle)

return window