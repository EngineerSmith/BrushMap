local window = require("ui.base.window").new()

local global = require("global")

local anchor = require("ui.base.anchor")

local tabController = require("ui.tabController")
local tabWindow = require("ui.tabWindow")
local button = require("ui.button")
local colorPicker = require("ui.colorPicker")

local picker = colorPicker.new()
picker.enabled = false
window:addChild(picker)

local togglePicker = function(bool)
    for _, child in ipairs(window.children) do
        child.enabled = not bool
    end
    picker.enabled = bool
end

local showPicker = function()
    togglePicker(true)
end

local hidePicker = function()
    togglePicker(false)
end

local controller = tabController.new()
window:addChild(controller)

local tabTileset = tabWindow.new("Tileset", global.assets["font.robotoReg18"])
controller:addChild(tabTileset)

local anchor = anchor.new("NorthWest", 0,30, 100,40)
local butt = button.new(anchor, nil, showPicker)
butt:setText("Background Color")

tabTileset:addChild(butt)

local tabStatic = tabWindow.new("Static", global.assets["font.robotoReg18"])
controller:addChild(tabStatic)

local tabAnimation = tabWindow.new("Animation", global.assets["font.robotoReg18"])
controller:addChild(tabAnimation)

return window