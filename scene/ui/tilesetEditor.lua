local window = require("ui.base.window").new()

window.tilesizeX, window.tilesizeY = 16,16
window.tileoffsetX, window.tileoffsetY = 0,0

local windowFileDialog = require("scene.ui.fileDialog")
window:addChild(windowFileDialog)

local global = require("global")

local anchor = require("ui.base.anchor")

local tabController = require("ui.tabController")
local tabWindow = require("ui.tabWindow")
local button = require("ui.button")
local colorPicker = require("ui.colorPicker")
local numericInput = require("ui.numericInput")
local text = require("ui.text")
local checkbox = require("ui.checkbox")

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

local anchor = anchor.new("NorthEast", 40,40, 80,80)
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
    if success then --TODO if failed to load
        window.tileset = love.graphics.newImage(path)
        window.tileset:setFilter("nearest","nearest")
        if window.newTilesetCallback then
            window.newTilesetCallback(window.tileset)
        end
    end
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
--[[ TILE SIZE]]
local anchor = anchor.new("NorthWest", 10, 130, -1,20, 20,0)
local titleTilesize = text.new(anchor, "Tile Size", font)

tabTileset:addChild(titleTilesize)

local anchor = anchor.new("NorthWest", 10,170, 20,40)
local textTilesizeX = text.new(anchor, "X", font)
local anchor = anchor.new("NorthWest", 30,160, -1,40, 40,0)
local tilesizeX = numericInput.new(anchor, 4, 9999, 16, font)
tilesizeX:setValueChangedCallback(function(_, value)
    window.tilesizeX = value
end)
tabTileset:addChild(textTilesizeX)
tabTileset:addChild(tilesizeX)

local anchor = anchor.new("NorthWest", 10,220, 20,40)
local textTilesizeY = text.new(anchor, "Y", font)
local anchor = anchor.new("NorthWest", 30,210, -1,40, 40,0)
local tilesizeY = numericInput.new(anchor, 4, 9999, 16, font)
tilesizeY:setValueChangedCallback(function(_, value)
    window.tilesizeY = value
end)
tabTileset:addChild(textTilesizeY)
tabTileset:addChild(tilesizeY)

local anchor = anchor.new("NorthEast", 10,125, 30,30)
local checkboxMirror = checkbox.new(anchor, true)
checkboxMirror:setValueChangedCallback(function(self, selected)
    tilesizeX:setClone(selected and tilesizeY or nil)
end)

tabTileset:addChild(checkboxMirror)
--[[TILE OFFSET]]
local anchor = anchor.new("NorthWest", 10, 260, -1,20, 20,0)
local titleTileoffset = text.new(anchor, "Tile Offset", font)

tabTileset:addChild(titleTileoffset)

local anchor = anchor.new("NorthWest", 10,300, 20,40)
local textTileoffsetX = text.new(anchor, "X", font)
local anchor = anchor.new("NorthWest", 30,290, -1,40, 40,0)
local tileoffsetX = numericInput.new(anchor, 0, 9999, 0, font)
tileoffsetX:setValueChangedCallback(function(_, value)
    window.tileoffsetX = value
end)
tabTileset:addChild(textTileoffsetX)
tabTileset:addChild(tileoffsetX)

local anchor = anchor.new("NorthWest", 10,350, 20,40)
local textTileoffsetY = text.new(anchor, "Y", font)
local anchor = anchor.new("NorthWest", 30,340, -1,40, 40,0)
local tileoffsetY = numericInput.new(anchor, 0, 9999, 0, font)
tileoffsetY:setValueChangedCallback(function(_, value)
    window.tileoffsetY = value
end)
tabTileset:addChild(textTileoffsetY)
tabTileset:addChild(tileoffsetY)

local anchor = anchor.new("NorthEast", 10,255, 30,30)
local checkboxMirror = checkbox.new(anchor, true)
checkboxMirror:setValueChangedCallback(function(self, selected)
    tileoffsetX:setClone(selected and tileoffsetY or nil)
end)

tabTileset:addChild(checkboxMirror)
--[[]]
local tabStatic = tabWindow.new("Static", font)
controller:addChild(tabStatic)

local tabAnimation = tabWindow.new("Animation", font)
controller:addChild(tabAnimation)

local tabBitmask = tabWindow.new("Bitmask", font)
controller:addChild(tabBitmask)

return window