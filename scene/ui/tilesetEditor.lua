local window = require("ui.base.window").new()

local global = require("global")

local anchor = require("ui.base.anchor")
local tabController = require("ui.tabController")
local colorPicker = require("ui.colorPicker")
local button = require("ui.button")
local aabb = require("utilities.aabb")
local outlineBox = require("utilities.outlineBox")

local lg = love.graphics
local insert = table.insert

local font = global.assets["font.robotoReg18"]

local controllerEast = tabController.new("East", 240)
window:addChild(controllerEast)
window.controllerEast = controllerEast

local tileColorPreview   = {0,.8,.8}
local tileColorStatic    = {1,0,0}
local tileColorAnimated  = {0,1,0}
local tileColorBitmask = {0,0,1}
local tileColorPreviewAlpha =  {.1,.5,.5,0.5}
local tileColorAnimatedAlpha = {tileColorAnimated[1],tileColorAnimated[2],tileColorAnimated[3],0.25}

window.outlineBox = outlineBox.new(-1,-1,-1,-1)
window.preview = outlineBox.new(0,0,4,4, tileColorPreview)

window.bitmaskEditing = false

window.updatePreview = function(x, y, w, h)
    local pre = window.preview
    pre.x = x
    pre.y = y
    pre.width = w
    pre.height = h
    local sta = controllerEast.tabStatic
    if x~=-1 and y~=-1 and w ~=-1 and h ~=-1 then
        sta.x.value = x
        sta.y.value = y
        sta.w.value = w
        sta.h.value = h
    else
        sta.x:reset()
        sta.y:reset()
        sta.w:reset()
        sta.h:reset()
    end
    controllerEast.tabStatic:updatePreview(window.preview:getRect())
    local ani = controllerEast.tabAnimation
    local index = ani.frameSelect.index
    if index > 0 then
        local quad = ani.preview:getFrame(index)
        if quad then
            quad:setViewport(x,y,w,h)
        end
    end
end

window.selectPreview = function(x, y, w, h, pressedX, pressedY)
    --EDIT
    if x ~= -1 and y ~= -1 and w ~= -1 and h ~= -1 and pressedX and pressedY then
    for _, tile in ipairs(window.tileset.tiles.items) do
        if not window.bitmaskEditPick and tile.type == "static" then
            if window.tile ~= tile and aabb(pressedX, pressedY, tile.x, tile.y, tile.w, tile.h) then
                if window.bitmaskEditing then
                    controllerEast.tabBitmask:addTileToBit(tile)
                else
                    controllerEast.tabStatic:setState("edit")
                    window.tile = tile
                end
                window.updatePreview(tile.x,tile.y,tile.w,tile.h)
                return
            end
        elseif not window.bitmaskEditPick and tile.type == "animated" then
            if window.tile == tile then
                break
            end
            local t = tile.tiles[1]
            if aabb(pressedX, pressedY, t.x, t.y, t.w, t.h) then
                if window.bitmaskEditing then
                    controllerEast.tabBitmask:addTileToBit(tile)
                    window.updatePreview(t.x, t.y, t.w, t.h)
                    return
                else
                    window.tile = tile
                    window.updatePreview(t.x, t.y, t.w, t.h)
                    for _, tile in ipairs(tile.tiles) do
                        local quad = lg.newQuad(tile.x, tile.y, tile.w, tile.h, window.tileset.image:getDimensions())
                        controllerEast.tabAnimation.preview:addFrame(quad, tile.time)
                    end
                    controllerEast.tabAnimation:setState("edit")
                    controllerEast:setLock(true)
                    return
                end
            end
        elseif window.bitmaskEditPick and tile.type == "bitmask" then
            local count = tile.tileCount == 15 and 15 or 255
            for i=0, count do
                local t = global.editorSession:getTile(tile.tiles[i], window.tileset)
                if t then
                    local tiles = t.tiles
                    if (t.type == "static" and  aabb(pressedX, pressedY, t.x, t.y, t.w, t.h)) or
                       (t.type == "animated"and aabb(pressedX, pressedY, tiles[1].x, tiles[1].y, tiles[1].w, tiles[1].h)) then
                        window.bitmaskEditPick = false
                        controllerEast.tabBitmask:setTile(tile)
                        controllerEast.tabBitmask:setState("edit", true)
                        return
                    end
                end
            end 
        end
    end
    end
    if window.tile and window.tile.type == "bitmask" then
        return
    elseif window.tile and window.tile.type == "animated" then
        window.updatePreview(x,y,w,h)
    else
        window.tile = nil
        if x~=-1 and y~=-1 and w~=-1 and h~=-1 then
            controllerEast.tabStatic:setState("new")
            controllerEast.tabAnimation:setState("new")
        else
            controllerEast.tabStatic:setState("deactive")
            controllerEast.tabAnimation:setState("deactive")
        end
        window.updatePreview(x,y,w,h)
    end
end

local windowFileDialog = require("scene.ui.fileDialog")
window:addChild(windowFileDialog)

local picker = colorPicker.new(global.assets["texture.checkerboard"])
picker.enabled = false
window:addChild(picker)
window.picker = picker

local pickerReturn

window.togglePicker = function(bool)
    for _, child in ipairs(window.children) do
        if child ~= windowFileDialog then
            child.enabled = not bool end
    end
    picker.enabled = bool
    pickerReturn.enabled = bool
    window.showTexture = picker.bgImage.enabled
end

local anchor = anchor.new("NorthEast", 40,40, 80,80)
pickerReturn = button.new(anchor, nil, function()
    window.togglePicker(false)
    lg.setBackgroundColor(picker:getColor())
end)
pickerReturn:setText("Return", nil, font)
pickerReturn:setOutline(true, 4, 2)
pickerReturn:setRoundCorner(7)
pickerReturn.enabled = false
window:addChild(pickerReturn)

window.drawScene = function(scale)
    if window.tileset then
        window.grid:draw(scale)
    end
    
    local box = window.outlineBox
    if window.tileset then
    for _, tile in ipairs(window.tileset.tiles.items) do
        if window.bitmaskEditPick then
            box:setColor(tileColorBitmask)
            if tile.type == "bitmask" then
                local count = tile.tileCount == 15 and 15 or 255
                for i=0, count do
                    if tile.tiles[i] then
                        local t = global.editorSession:getTile(tile.tiles[i], window.tileset)
                        if t.type == "animated" then
                            t = t.tiles[1] 
                        end
                        box:setRect(t.x, t.y, t.w, t.h)
                        box:draw(scale)
                    end
                end
            end
        elseif tile ~= window.tile or not controllerEast.activeChild or window.bitmaskEditing then
            if tile.type == "static" then
                box:setColor(tileColorStatic)
                box:setRect(tile.x, tile.y, tile.w, tile.h)
                box:draw(scale)
            elseif tile.type == "animated" then
                box:setColor(tileColorAnimated)
                local tiles = tile.tiles
                box:setRect(tiles[1].x, tiles[1].y, tiles[1].w, tiles[1].h)
                box:draw(scale)
                box:setColor(tileColorAnimatedAlpha)
                for i, tile in ipairs(tiles) do
                    if i > 1 then
                        box:setRect(tile.x, tile.y, tile.w, tile.h)
                        box:draw(scale)
                    end
                end
            end
        end
    end
    end
    if controllerEast.activeChild and controllerEast.activeChild ~= controllerEast.tabTileset then
        if window.preview.x == -1 and window.preview.y == -1 and window.preview.width == -1 and window.preview.height == -1 then
            return -- TO NOT DRAW
        end
        if controllerEast.tabAnimation.preview.quads then
            box:setColor(tileColorPreviewAlpha)
            for _, quad in ipairs(controllerEast.tabAnimation.preview.quads) do
                box:setRect(quad:getViewport())
                box:draw(scale)
            end
        end
        window.preview:draw(scale)
    end
end

--[[ TAB TILESET ]]
controllerEast.tabTileset = require("scene.ui.tilesetEditor.tabTileset")(font, controllerEast, window)

local fileDialogCallback = function(success, path)
    window.togglePicker(false)
    if success then
        window.tileset = global.editorSession:addTileset(path)
        local img = window.tileset.image
        
        controllerEast.tabStatic:newTileset(img)
        controllerEast.tabAnimation:newTileset(img)
        controllerEast.tabBitmask:newTileset(img)
        
        if window.newTilesetCallback then
            window.newTilesetCallback(img)
        end
    end
end

controllerEast.tilesetSelect = function()
    for _, child in ipairs(window.children) do
        child.enabled = false
    end
    windowFileDialog.dialog("load", fileDialogCallback)
end

controllerEast.tabTileset:createUI()
controllerEast:addChild(controllerEast.tabTileset)

--[[ TAB STATIC ]]
controllerEast.tabStatic = require("scene.ui.tilesetEditor.tabStatic")(font, controllerEast, window)

controllerEast.tabStatic:createUI()
controllerEast:addChild(controllerEast.tabStatic)

--[[ TAB ANIMATION ]]
controllerEast.tabAnimation = require("scene.ui.tilesetEditor.tabAnimation")(font, controllerEast, window)

controllerEast.tabAnimation:createUI()
controllerEast:addChild(controllerEast.tabAnimation)

--[[ TAB BITMASK ]]
controllerEast.tabBitmask = require("scene.ui.tilesetEditor.tabBitmask")(font, controllerEast, window)

controllerEast.tabBitmask:createUI()
controllerEast:addChild(controllerEast.tabBitmask)

--[[ Controller West]]

local controllerWest = tabController.new("West", 150)
window:addChild(controllerWest)
window.controllerWest = controllerWest


controllerWest.tabTilemap = require("scene.ui.tilesetEditor.tabTilemap")(font, controllerWest, window)

controllerWest.tabTilemap:createUI()
controllerWest:addChild(controllerWest.tabTilemap)

return window