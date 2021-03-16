local window = require("ui.base.window").new()

local global = require("global")

local anchor = require("ui.base.anchor")
local tabController = require("ui.tabController")
local tabWindow = require("ui.tabWindow")
local button = require("ui.button")
local colorPicker = require("ui.colorPicker")
local outlineBox = require("utilities.outlineBox")

local lg = love.graphics
local font = global.assets["font.robotoReg18"]

local controller = tabController.new()
window:addChild(controller)
window.controller = controller

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
    local sta = controller.tabStatic
    sta.x.value = x
    sta.y.value = y
    sta.w.value = w
    sta.h.value = h
    controller.tabStatic.updateStaticQuad()
end

window.selectPreview = function(x, y, w, h)
    for _, tile in ipairs(global.editorSession.tilesets[window.tilesetId].tiles) do
            if tile.x == x and tile.y == y then
                --EDIT
                controller.tabStatic.create:setText("Edit Tile")
                controller.tabStatic.delete.enabled = true
                window.tile = tile
                window.updatePreview(x,y,tile.w,tile.h)
                return
            end
    end
    --CREATE
    window.tile = nil
    controller.tabStatic.create:setText("Create Tile")
    controller.tabStatic.delete.enabled = false
    window.updatePreview(x,y,w,h)
end

local windowFileDialog = require("scene.ui.fileDialog")
window:addChild(windowFileDialog)

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

controller.showPicker = function()
    togglePicker(true)
end

controller.hidePicker = function()
    togglePicker(false)
    love.graphics.setBackgroundColor(picker:getColor())
end

local anchor = anchor.new("NorthEast", 40,40, 80,80)
pickerReturn = button.new(anchor, nil, controller.hidePicker)
pickerReturn:setText("Return", nil, font)
pickerReturn:setOutline(true, 4, 2)
pickerReturn:setRoundCorner(7)
pickerReturn.enabled = false
window:addChild(pickerReturn)

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
    
    if controller.activeChild and controller.activeChild ~= controller.tabTileset then
        window.preview:draw(scale)
    end
end

--[[ TAB TILESET ]]
controller.tabTileset = require("scene.ui.tilesetEditor.tabTileset")(font, controller)

local fileDialogCallback = function(success, path)
    togglePicker(false)
    if success then
        local id, image = global.editorSession:addTileset(path)
        window.tilesetId = id
        window.tileset = image
        window.tileset:setFilter("nearest","nearest")
        
        controller.tabStatic.preview:setImage(window.tileset)
        controller.tabStatic:updateLimits(window.tileset:getDimensions())
        
        if window.newTilesetCallback then
            window.newTilesetCallback(window.tileset)
        end
    end
end

controller.tilesetSelect = function()
    for _, child in ipairs(window.children) do
        child.enabled = false
    end
    windowFileDialog.dialog("load", fileDialogCallback)
end

controller.tabTileset:createUI()
controller:addChild(controller.tabTileset)

--[[ TAB STATIC ]]
controller.tabStatic = require("scene.ui.tilesetEditor.tabStatic")(font, controller)

controller.tabStatic.updateStaticQuad = function()
    if window.tileset then
        local x, y, w, h = window.preview:getRect()
        local quad = lg.newQuad(x,y, w,h, window.tileset:getDimensions())
        controller.tabStatic.preview:setQuad(quad)
    end
end

controller.staticXCallback = function(_, value)
    if window.tileset and value + window.preview.width > window.tileset:getWidth() then
        return false
    end
    window.preview.x = value
    controller.tabStatic.updateStaticQuad()
    return true
end

controller.staticYCallback = function(_, value)
    if window.tileset and value + window.preview.height > window.tileset:getHeight() then
        return false
    end
    window.preview.y = value
    controller.tabStatic.updateStaticQuad()
    return true
end

controller.staticWCallback = function(_, value)
    if window.tileset and window.preview.x + value > window.tileset:getWidth() then
        if window.preview.x - 1 >= tileX.min then
            window.preview.x = window.preview.x - 1
            controller.tabStatic.x:updateValue(window.preview.x)
        end
    end
    window.preview.width = value
    controller.tabStatic.updateStaticQuad()
    return true
end

controller.staticHCallback = function(_, value)
    if window.tileset and window.preview.y + value > window.tileset:getHeight() then
        if window.preview.y - 1 >= tileY.min then
            window.preview.y = window.preview.y - 1
            controller.tabStatic.y:updateValue(window.preview.y)
        end
    end
    window.preview.height = value
    controller.tabStatic.updateStaticQuad()
    return true
end

controller.staticCreateButton = function()
    local p = window.preview
    
    local tileData = window.tile or {type = "static"}
    
    tileData.x = p.x
    tileData.y = p.y
    tileData.w = p.width
    tileData.h = p.height
    
    if not tileData.id then
        global.editorSession:addTile(tileData, window.tilesetId)
        window.selectPreview(p.x, p.y, p.width, p.height)
    end
end

controller.staticDeleteButton = function()
    if window.tile then
        global.editorSession:removeTile(window.tile)
        local p = window.preview
        window.selectPreview(p.x, p.y, p.width, p.height)
    end
end

controller.tabStatic:createUI()
controller:addChild(controller.tabStatic)

--[[ TAB ANIMATION ]]
local tabAnimation = tabWindow.new("Animation", font)
controller:addChild(tabAnimation)

--[[ TAB BITMASKED ]]
local tabBitmask = tabWindow.new("Bitmask", font)
controller:addChild(tabBitmask)

return window