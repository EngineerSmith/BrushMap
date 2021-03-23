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

local controller = tabController.new()
window:addChild(controller)
window.controller = controller

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
    local sta = controller.tabStatic
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
    controller.tabStatic:updatePreview(window.preview:getRect())
    local ani = controller.tabAnimation
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
        if tile.type == "static" then
            if window.tile ~= tile and aabb(pressedX, pressedY, tile.x, tile.y, tile.w, tile.h) then
                if window.bitmaskEditing then
                    -- TODO Set current bitmask to `tile`
                else
                    controller.tabStatic:setState("edit")
                    window.tile = tile
                    window.updatePreview(tile.x,tile.y,tile.w,tile.h)
                    return
                end
            end
        elseif tile.type == "animated" then
            if window.tile == tile then
                break
            end
            local t = tile.tiles[1]
            if aabb(pressedX, pressedY, t.x, t.y, t.w, t.h) then
                if window.bitmaskEditing then
                    -- TODO Set current bitmask to `tile`
                else
                    window.tile = tile
                    window.updatePreview(t.x, t.y, t.w, t.h)
                    for _, tile in ipairs(tile.tiles) do
                        local quad = lg.newQuad(tile.x, tile.y, tile.w, tile.h, window.tileset.image:getDimensions())
                        controller.tabAnimation.preview:addFrame(quad, tile.time)
                    end
                    controller.tabAnimation:setState("edit")
                    controller:setLock(true)
                    return
                end
            end
        elseif tile.type == "bitmask" and window.bitmaskEditPick then
            for i=0, (60*tile.direction)-255 do
                local t = tile.tiles[i]
                if t and aabb(pressedX, pressedY, t.x, t.y, t.w, t.h) then
                    -- Set `tile` as tile to edit
                end
            end 
        end
    end
    end
    if window.tile and window.tile.type == "animated" then
        window.updatePreview(x,y,w,h)
    else
        window.tile = nil
        if x~=-1 and y~=-1 and w~=-1 and h~=-1 then
            controller.tabStatic:setState("new")
            controller.tabAnimation:setState("new")
        else
            controller.tabStatic:setActive("deactive")
            controller.tabAnimation:setState("deactive")
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

local togglePicker = function(bool)
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
    togglePicker(false)
    love.graphics.setBackgroundColor(picker:getColor())
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
               for i=0, (60*tile.direction)-255 do
                    if tile.tiles[i] then
                         local t = global.editorSession:getTile(tile.tiles[i], window.tileset)
                         box:setRect(t.x, t.y, t.w, t.h)
                         box:draw()
                    end
                end
            end
        elseif tile ~= window.tile or not controller.activeChild then
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
            elseif tile.type == "bitmask" then
                --error("TODO")
            end
        end
    end
    end
    if controller.activeChild and controller.activeChild ~= controller.tabTileset then
        if window.preview.x == -1 and window.preview.y == -1 and window.preview.width == -1 and window.preview.height == -1 then
            return -- TO NOT DRAW
        end
        if controller.tabAnimation.preview.quads then
            box:setColor(tileColorPreviewAlpha)
            for _, quad in ipairs(controller.tabAnimation.preview.quads) do
                box:setRect(quad:getViewport())
                box:draw(scale)
            end
        end
        window.preview:draw(scale)
    end
end

--[[ TAB TILESET ]]
controller.tabTileset = require("scene.ui.tilesetEditor.tabTileset")(font, controller, window)

local fileDialogCallback = function(success, path)
    togglePicker(false)
    if success then
        window.tileset = global.editorSession:addTileset(path)
        local img = window.tileset.image
        
        controller.tabStatic:newTileset(img)
        controller.tabAnimation:newTileset(img)
        controller.tabBitmask:newTileset(img)
        
        if window.newTilesetCallback then
            window.newTilesetCallback(img)
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
controller.tabStatic = require("scene.ui.tilesetEditor.tabStatic")(font, controller, window)

controller.tabStatic:createUI()
controller:addChild(controller.tabStatic)

--[[ TAB ANIMATION ]]
controller.tabAnimation = require("scene.ui.tilesetEditor.tabAnimation")(font, controller, window)

controller.tabAnimation:createUI()
controller:addChild(controller.tabAnimation)

--[[ TAB BITMASK ]]
controller.tabBitmask = require("scene.ui.tilesetEditor.tabBitmask")(font, controller, window)

controller.tabBitmask:createUI()
controller:addChild(controller.tabBitmask)

return window