local window = require("ui.base.window").new()

local lg = love.graphics

local global = require("global")

window.tilesizeX, window.tilesizeY = 16,16
window.tileoffsetX, window.tileoffsetY = 0,0
window.paddingX, window.paddingY = 0,0

local updateStaticQuad = function()
    if window.tileset then
        local x, y, w, h = window.preview:getRect()
        window.previewQuad = lg.newQuad(x,y, w,h, window.tileset:getDimensions())
        window.staticpreview:setQuad(window.previewQuad)
    end
end

local outlineBox = require("utilities.outlineBox")

local tileColorStatic    = {1,0,0}
local tileColorAnimated  = {0,1,0}
local tileColorBitmasked = {0,0,1}

window.outlineBox = outlineBox.new(0,0,0,0)
window.preview = outlineBox.new(0,0,4,4, {0,.8,.8})

window.updatePreview = function(x, y, w, h)
    local pre = window.preview
    pre.x = x
    pre.y = y
    pre.width = w
    pre.height = h
    local sta = window.static
    sta.x.value = x
    sta.y.value = y
    sta.w.value = w
    sta.h.value = h
    updateStaticQuad()
end

window.selectPreview = function(x, y, w, h)
    for _, tile in ipairs(global.editorSession.tilesets[window.tilesetId].tiles) do
            if tile.x == x and tile.y == y then
                --EDIT
                window.static.button:setText("Edit Tile")
                window.tile = tile
                window.updatePreview(x,y,tile.w,tile.h)
                return
            end
    end
    --CREATE
    window.tile = nil
    window.static.button:setText("Create Tile")
    window.updatePreview(x,y,w,h)
end

local maxNum = 9999

local windowFileDialog = require("scene.ui.fileDialog")
window:addChild(windowFileDialog)

local anchor = require("ui.base.anchor")

local tabController = require("ui.tabController")
local tabWindow = require("ui.tabWindow")
local button = require("ui.button")
local colorPicker = require("ui.colorPicker")
local numericInput = require("ui.numericInput")
local text = require("ui.text")
local checkbox = require("ui.checkbox")
local image = require("ui.image")

local font = global.assets["font.robotoReg18"]

local picker = colorPicker.new(global.assets["texture.checkerboard"])
picker.enabled = false
window:addChild(picker)
window.picker = picker

local pickerReturn

local togglePicker = function(bool)
    for _, child in ipairs(window.children) do
        if child ~= windowFileDialog then
            child.enabled = not bool end
    end
    picker.enabled = bool
    pickerReturn.enabled = bool
    window.showTexture = picker.bgImage.enabled
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
window.controller = controller

window.drawOutlines = function(scale)
    for _, tileset in ipairs(global.editorSession.tilesets) do
    for _, tile in ipairs(tileset.tiles) do
        if tile ~= window.tile then
            if tile.type == "static" then
                window.outlineBox:setColor(tileColorStatic)
                window.outlineBox:setRect(tile.x, tile.y, tile.w, tile.h)
                window.outlineBox:draw(scale)
            elseif tile.type == "animated" then
                window.outlineBox:setColor(tileColorAnimated)
                error("TODO")
            elseif tile.type == "bitmasked" then
                window.outlineBox:setColor(tileColorBitmasked)
                error("TODO")
            end
        end
    end
    end
    
    if controller.activeChild and controller.activeChild ~= controller.tileset then
        window.preview:draw(scale)
    end
    
    if window.tilesetPreviews then
        for _, tile in ipairs(window.tilesetPreviews) do
            tile:draw(scale)
        end
    end
end

--[[TAB TILESET]]

local tabTileset = tabWindow.new("Tileset", font)
controller:addChild(tabTileset)
controller.tileset = tabTileset

local anchor = anchor.new("NorthWest", 10,30, -1,40, 20,0)
local backgroundColor = button.new(anchor, nil, showPicker)
backgroundColor:setText("Background Colour", nil, font)

tabTileset:addChild(backgroundColor)

local fileDialogCallback = function(success, path)
    togglePicker(false)
    if success then
        local id, image = global.editorSession:addTileset(path)
        window.tilesetId = id
        window.tileset = image
        window.tileset:setFilter("nearest","nearest")
        window.staticpreview:setImage(window.tileset)
        window.tilesetPreviews = {}
        
        window.static.w:updateValue(nil,nil, window.tileset:getWidth())
        window.static.h:updateValue(nil,nil, window.tileset:getHeight())
        
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
local tilesizeX = numericInput.new(anchor, 4, maxNum, 16, font)
tilesizeX:setValueChangedCallback(function(_, value)
    window.tilesizeX = value
    return true
end)
tabTileset:addChild(textTilesizeX)
tabTileset:addChild(tilesizeX)

local anchor = anchor.new("NorthWest", 10,220, 20,40)
local textTilesizeY = text.new(anchor, "Y", font)
local anchor = anchor.new("NorthWest", 30,210, -1,40, 40,0)
local tilesizeY = numericInput.new(anchor, 4, maxNum, 16, font)
tilesizeY:setValueChangedCallback(function(_, value)
    window.tilesizeY = value
    return true
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
local tileoffsetX = numericInput.new(anchor, 0, maxNum, 0, font)
tileoffsetX:setValueChangedCallback(function(_, value)
    window.tileoffsetX = value
    return true
end)
tabTileset:addChild(textTileoffsetX)
tabTileset:addChild(tileoffsetX)

local anchor = anchor.new("NorthWest", 10,350, 20,40)
local textTileoffsetY = text.new(anchor, "Y", font)
local anchor = anchor.new("NorthWest", 30,340, -1,40, 40,0)
local tileoffsetY = numericInput.new(anchor, 0, maxNum, 0, font)
tileoffsetY:setValueChangedCallback(function(_, value)
    window.tileoffsetY = value
    return true
end)
tabTileset:addChild(textTileoffsetY)
tabTileset:addChild(tileoffsetY)

local anchor = anchor.new("NorthEast", 10,255, 30,30)
local checkboxMirror = checkbox.new(anchor, true)
checkboxMirror:setValueChangedCallback(function(self, selected)
    tileoffsetX:setClone(selected and tileoffsetY or nil)
end)

tabTileset:addChild(checkboxMirror)
--[[TILE PADDING]]
local anchor = anchor.new("NorthWest", 10, 390, -1,20, 20,0)
local titlePadding = text.new(anchor, "Padding", font)

tabTileset:addChild(titlePadding)

local anchor = anchor.new("NorthWest", 10,430, 20,40)
local textPaddingX = text.new(anchor, "X", font)
local anchor = anchor.new("NorthWest", 30,420, -1,40, 40,0)
local paddingX = numericInput.new(anchor, 0, maxNum, 0, font)
paddingX:setValueChangedCallback(function(_, value)
    window.paddingX = value
    return true
end)
tabTileset:addChild(textPaddingX)
tabTileset:addChild(paddingX)

local anchor = anchor.new("NorthWest", 10,480, 20,40)
local textPaddingY = text.new(anchor, "Y", font)
local anchor = anchor.new("NorthWest", 30,470, -1,40, 40,0)
local paddingY = numericInput.new(anchor, 0, maxNum, 0, font)
paddingY:setValueChangedCallback(function(_, value)
    window.paddingY = value
    return true
end)
tabTileset:addChild(textPaddingY)
tabTileset:addChild(paddingY)

local anchor = anchor.new("NorthEast", 10,385, 30,30)
local checkboxMirror = checkbox.new(anchor, true)
checkboxMirror:setValueChangedCallback(function(self, selected)
    paddingX:setClone(selected and paddingY or nil)
end)

tabTileset:addChild(checkboxMirror)
--[[TAB STATIC]]

local tabStatic = tabWindow.new("Static", font)
controller:addChild(tabStatic)

local anchor = anchor.new("NorthWest", 10,30, -1,-2, 20,0)
window.staticpreview = image.new(anchor, nil)
window.staticpreview:setBackgroundColor({0,0,0})
tabStatic:addChild(window.staticpreview)

local rect = window.staticpreview.anchor.rect
local height = rect[2] + rect[4]

local anchor = anchor.new("NorthWest", 10,20+height, 20,40)
local textTileX = text.new(anchor, "X", font)
local anchor = anchor.new("NorthWest", 30,10+height, -1,40, 40,0)
local tileX = numericInput.new(anchor, 0, maxNum, 0, font)
tileX:setValueChangedCallback(function(_, value)
    if window.tileset and value + window.preview.width > window.tileset:getWidth() then
        return false
    end
    window.preview.x = value
    updateStaticQuad()
    return true
end)
tabStatic:addChild(textTileX)
tabStatic:addChild(tileX)

local anchor = anchor.new("NorthWest", 10,70+height, 20,40)
local textTileY = text.new(anchor, "Y", font)
local anchor = anchor.new("NorthWest", 30,60+height, -1,40, 40,0)
local tileY = numericInput.new(anchor, 0, maxNum, 0, font)
tileY:setValueChangedCallback(function(_, value)
    if window.tileset and value + window.preview.height > window.tileset:getHeight() then
        return false
    end
    window.preview.y = value
    updateStaticQuad()
    return true
end)
tabStatic:addChild(textTileY)
tabStatic:addChild(tileY)

local anchor = anchor.new("NorthWest", 8,122+height, 20,40)
local textTileW = text.new(anchor, "W", font)
local anchor = anchor.new("NorthWest", 30,110+height, -1,40, 40,0)
local tileW = numericInput.new(anchor, 4, maxNum, 4, font)
tileW:setValueChangedCallback(function(_, value)
    if window.tileset and window.preview.x + value > window.tileset:getWidth() then
        if window.preview.x - 1 >= tileX.min then
            window.preview.x = window.preview.x - 1
            window.static.x:updateValue(window.preview.x)
        end
    end
    window.preview.width = value
    updateStaticQuad()
    return true
end)
tabStatic:addChild(textTileW)
tabStatic:addChild(tileW)

local anchor = anchor.new("NorthWest", 10,168+height, 20,40)
local textTileH = text.new(anchor, "H", font)
local anchor = anchor.new("NorthWest", 30,160+height, -1,40, 40,0)
local tileH = numericInput.new(anchor, 4, maxNum, 4, font)
tileH:setValueChangedCallback(function(_, value)
    if window.tileset and window.preview.y + value > window.tileset:getHeight() then
        if window.preview.y - 1 >= tileY.min then
            window.preview.y = window.preview.y - 1
            window.static.y:updateValue(window.preview.y)
        end
    end
    window.preview.height = value
    updateStaticQuad()
    return true
end)
tabStatic:addChild(textTileH)
tabStatic:addChild(tileH)

window.static = {}
window.static.tab = tabStatic
window.static.x = tileX
window.static.y = tileY
window.static.w = tileW
window.static.h = tileH

local anchor = anchor.new("NorthWest", 10,220+height, -1,40, 20,0)
local addStaticTile = button.new(anchor, nil, function()
    local p = window.preview
    
    local tileData = window.tile or {type = "static"}
    
    tileData.x = p.x
    tileData.y = p.y
    tileData.w = p.width
    tileData.h = p.height
    
    if not tileData.id then
        global.editorSession:addTile(tileData, window.tilesetId)
    end
end)
addStaticTile:setText("Add Tile", nil, font)

tabStatic:addChild(addStaticTile)
window.static.button = addStaticTile

--[[TAB ANIMATION]]
local tabAnimation = tabWindow.new("Animation", font)
controller:addChild(tabAnimation)

local tabBitmask = tabWindow.new("Bitmask", font)
controller:addChild(tabBitmask)

return window