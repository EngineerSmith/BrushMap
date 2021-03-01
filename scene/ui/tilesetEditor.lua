local window = require("ui.base.window").new()

local windowFileDialog = require("scene.ui.fileDialog")
window:addChild(windowFileDialog)

local global = require("global")

local anchor = require("ui.base.anchor")

local tabController = require("ui.tabController")
local tabWindow = require("ui.tabWindow")
local button = require("ui.button")
local colorPicker = require("ui.colorPicker")

local font = global.assets["font.robotoReg18"]

local picker = colorPicker.new()
picker.enabled = false
window:addChild(picker)

local pickerReturn

local togglePicker = function(bool)
    for _, child in ipairs(window.children) do
        if child ~= windowFileDialog then
            child.enabled = not bool end
    end
    picker.enabled = bool
    pickerReturn.enabled = bool
end

local showPicker = function()
    togglePicker(true)
end

local hidePicker = function()
    togglePicker(false)
    love.graphics.setBackgroundColor(picker:getColor())
end

local anchor = anchor.new("NorthWest", 40,40, 80,80)
pickerReturn = button.new(anchor, nil, hidePicker)
pickerReturn:setText("Return", nil, font)
pickerReturn:setOutline(true, 4, 2)
pickerReturn:setRoundCorner(7)
pickerReturn.enabled = false
window:addChild(pickerReturn)

local controller = tabController.new()
window:addChild(controller)

local tabTileset = tabWindow.new("Tileset", font)
controller:addChild(tabTileset)

local anchor = anchor.new("NorthWest", 10,30, -1,40, 20,0)
local backgroundColor = button.new(anchor, nil, showPicker)
backgroundColor:setText("Background Colour", nil, font)

tabTileset:addChild(backgroundColor)

local fileDialogCallback = function(success, path)
    togglePicker(false)
end

local titleSelectCallback = function()
    for _, child in ipairs(window.children) do
        child.enabled = false
    end
    windowFileDialog.dialog("load", fileDialogCallback)
end

local anchor = anchor.new("NorthWest", 10,80, -1,40, 20,0)
local tilesetSelect = button.new(anchor, nil, titleSelectCallback)
tilesetSelect:setText("Select Tileset", nil, font)

tabTileset:addChild(tilesetSelect)

local tabStatic = tabWindow.new("Static", font)
controller:addChild(tabStatic)

local tabAnimation = tabWindow.new("Animation", font)
controller:addChild(tabAnimation)

return window