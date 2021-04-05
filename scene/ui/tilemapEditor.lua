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

--[[ TAB TILESET ]]
controllerWest.tabTileset = require("scene.ui.tilemapEditor.tabTileset")(font, controllerWest, window)

controllerWest.tabTileset:createUI()
controllerWest:addChild(controllerWest.tabTileset)

return window