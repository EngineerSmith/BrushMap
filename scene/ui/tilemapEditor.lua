local window = require("ui.base.window").new()

local global = require("global")

local tabController = require("ui.tabController")
local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local button = require("ui.button")

local font = global.assets["font.robotoReg18"]

local controllerEast = tabController.new("East")
window:addChild(controllerEast)
window.controllerEast = controllerEast

local controllerWest = tabController.new("West", 150)
window:addChild(controllerWest)
window.controllerWest = controllerWest

--[[ TAB TILESET ]]
controllerWest.tabTileset = require("scene.ui.tilemapEditor.tabTileset")(font, controllerWest, window)

controllerWest.tabTileset:createUI()
controllerWest:addChild(controllerWest.tabTileset)

--[[ TAB LAYERS ]]
controllerEast.tabLayer = require("scene.ui.tilemapEditor.tabLayer")(font, controllerEast, window)

controllerEast.tabLayer:createUI()
controllerEast:addChild(controllerEast.tabLayer)

--[[ TAB TOOL ]]
controllerEast.tabTool = require("scene.ui.tilemapEditor.tabTool")(font, controllerEast, window)

controllerEast.tabTool:createUI()
controllerEast:addChild(controllerEast.tabTool)

return window