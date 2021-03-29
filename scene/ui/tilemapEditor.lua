local window = require("ui.base.window").new()

local global = require("global")

local tabController = require("ui.tabController")
local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local button = require("ui.button")

local font = global.assets["font.robotoReg18"]

controllerWest = tabController.new("West", 150)
window:addChild(controllerWest)
window.controllerWest = controllerWest

window.tabTileset = tabWindow.new("Tileset", font, controllerWest)
controllerWest:addChild(window.tabTileset)

local anchor = anchor.new("NorthWest", 10,30, -1,40, 20,0)
local button = button.new(anchor)
button:setText("Tileset Editor", nil, font)
button:setCallbackPressed(function(self)
    require("utilities.sceneManager").changeScene("scene.tilesetEditor")
end)

window.tabTileset:addChild(button)

return window