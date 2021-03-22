local window = require("ui.base.window").new()

local global = require("global")

local anchor = require("ui.base.anchor")
local tabController = require("ui.tabController")
local colorPicker = require("ui.colorPicker")
local button = require("ui.button")
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
    controller.tabStatic.updateStaticQuad()
    local ani = controller.tabAnimation
    local index = ani.frameSelect.index
    if index > 0 then
        local quad = ani.preview:getFrame(index)
        if quad then
            quad:setViewport(x,y,w,h)
        end
    end
end

window.selectPreview = function(x, y, w, h)
    --EDIT
    if x ~= -1 and y ~= -1 and w ~= -1 and h ~= -1 then
    for _, tile in ipairs(window.tileset.tiles) do
        if tile.type == "static" and tile.x == x and tile.y == y then
            controller.tabStatic.create:setText("Edit Tile")
            controller.tabStatic.create:setActive(true)
            controller.tabStatic.delete:setActive(true)
            window.tile = tile
            window.updatePreview(x,y,tile.w,tile.h)
            return
        elseif tile.type == "animated" then
            if window.tile == tile then
                break
            end
            if tile.tiles[1].x == x and tile.tiles[1].y == y then
                controller.tabStatic.create:setActive(false)
                controller.tabStatic.delete:setActive(false)
                controller.tabAnimation.create:setText("Edit Tile")
                controller.tabAnimation.delete:setActive(true)
                window.tile = tile
                window.updatePreview(x,y,tile.tiles[1].w,tile.tiles[1].h)
                for _, tile in ipairs(tile.tiles) do
                    local quad = lg.newQuad(tile.x, tile.y, tile.w, tile.h, window.tileset.image:getDimensions())
                    controller.tabAnimation.preview:addFrame(quad, tile.time)
                end
                controller.tabAnimation.frameSelect:setMaxindex(#tile.tiles)
                controller:setLock(true)
                return
            end
        elseif tile.type == "bitmask" then
            error("TODO")
        end
    end
    end
    if window.tile and window.tile.type == "animated" then
        -- EDIT ANIMATION
        window.updatePreview(x,y,w,h)
    else
        --CREATE
        window.tile = nil
        if x~=-1 and y~=-1 and w~=-1 and h~=-1 then
            controller.tabStatic.create:setText("Create Tile")
            controller.tabStatic.create:setActive(true)
            controller.tabStatic.delete:setActive(false)
            controller.tabAnimation.create:setText("Create Tile")
            controller.tabAnimation.delete:setActive(false)
        else
            controller.tabStatic.create:setActive(false)
            controller.tabStatic.delete:setActive(false)
            controller.tabAnimation.create:setActive(false)
            controller.tabAnimation.delete:setActive(false)
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
    local box = window.outlineBox
    if window.tileset then
    for _, tile in ipairs(window.tileset.tiles) do
        if tile ~= window.tile then
            if tile.type == "static" then
                box:setColor(tileColorStatic)
                box:setRect(tile.x, tile.y, tile.w, tile.h)
                box:draw(scale)
            elseif tile.type == "animated" then
                box:setColor(tileColorAnimated)
                local tiles = tile.tiles
                if #tiles > 0 then
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
            elseif tile.type == "bitmask" then
                window.outlineBox:setColor(tileColorBitmask)
                error("TODO")
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
controller.tabTileset = require("scene.ui.tilesetEditor.tabTileset")(font, controller)

local fileDialogCallback = function(success, path)
    togglePicker(false)
    if success then
        local tileset = global.editorSession:addTileset(path)
        window.tileset = tileset
        window.tileset.image:setFilter("nearest","nearest")
        window.tileset.image:setWrap("clampzero")
        
        controller.tabStatic.preview:setImage(window.tileset.image)
        controller.tabStatic:updateLimits(window.tileset.image:getDimensions())
        
        controller.tabAnimation.preview:setImage(window.tileset.image)
        controller.tabAnimation.preview:reset()
        
        controller.tabBitmask.preview:setImage(window.tileset.image)
        controller.tabBitmask:reset()
        
        if window.newTilesetCallback then
            window.newTilesetCallback(window.tileset.image)
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
        local quad = lg.newQuad(x,y, w,h, window.tileset.image:getDimensions())
        controller.tabStatic.preview:setQuad(quad)
    end
end

controller.staticXCallback = function(_, value)
    if window.tileset and value + window.preview.width > window.tileset.image:getWidth() then
        return false
    end
    window.preview.x = value
    controller.tabStatic.updateStaticQuad()
    return true
end

controller.staticYCallback = function(_, value)
    if window.tileset and value + window.preview.height > window.tileset.image:getHeight() then
        return false
    end
    window.preview.y = value
    controller.tabStatic.updateStaticQuad()
    return true
end

controller.staticWCallback = function(_, value)
    if window.tileset and window.preview.x + value > window.tileset.image:getWidth() then
        if window.preview.x - 1 >= controller.tabStatic.x.min then
            window.preview.x = window.preview.x - 1
            controller.tabStatic.x:updateValue(window.preview.x)
        end
    end
    window.preview.width = value
    controller.tabStatic.updateStaticQuad()
    return true
end

controller.staticHCallback = function(_, value)
    if window.tileset and window.preview.y + value > window.tileset.image:getHeight() then
        if window.preview.y - 1 >= controller.tabStatic.y.min then
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
    
    local tileData = window.tile
    if tileData == nil or tileData.type ~= "static" then
        tileData = {type = "static"}
    end
    
    tileData.x = p.x
    tileData.y = p.y
    tileData.w = p.width
    tileData.h = p.height
    
    if not tileData.id then
        global.editorSession:addTile(tileData, window.tileset)
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
controller.tabAnimation = require("scene.ui.tilesetEditor.tabAnimation")(font, controller)

controller.animationIndexedChanged = function(self, index)
    local preview = controller.tabAnimation.preview
    local p = window.preview
    if not window.tileset or (p.x==-1 and p.y==-1 and p.width==-1 and p.height==-1) then
        return false
    end
    if not preview:hasFrame(index) then
        --Add frame
        local quad = lg.newQuad(p.x,p.y, p.width,p.height, window.tileset.image:getDimensions())
        local time = controller.tabAnimation.time.value
        
        preview:addFrame(quad, time)
    else -- Already has a quad
        local quad, time = preview:getFrame(index)
        p.x, p.y, p.width, p.height = quad:getViewport()
        controller.tabAnimation.time.value = time
    end
    
    controller.tabAnimation.deleteFrame:setActive(#preview.quads > 1)
    controller.tabAnimation.create:setActive(#preview.quads >= 2)
    controller:setLock(true)
    return true
end

controller.animationTimeChanged = function(self, value)
    local preview = controller.tabAnimation.preview
    local index = controller.tabAnimation.frameSelect.index
    if index > 0 and preview:hasFrame(index) then
        preview:setTime(index, value)
    end
    return true
end

controller.animationDeleteFrameButton = function(self)
    local preview = controller.tabAnimation.preview
    local frameSelect = controller.tabAnimation.frameSelect
    local index = frameSelect.index
    if index > 0 and preview:hasFrame(index) then
        preview:removeFrame(index)
        frameSelect.maxindex = frameSelect.maxindex - 1
        if frameSelect.index > frameSelect.maxindex then
            frameSelect.index = frameSelect.maxindex
        end
        controller.animationIndexedChanged(frameSelect, frameSelect.index)
    end
end

controller.animationCreateButton = function(self)
    local preview = controller.tabAnimation.preview
    local quads = preview.quads
    
    
    local tileData = window.tile 
    if tileData == nil or tileData.type ~= "animated" then
        tileData = {type = "animated"}
    end 
    tileData.tiles = {}
    
    for index, quad in ipairs(quads) do
        local x,y,w,h = quad:getViewport()
        local tile = {
            x=x,
            y=y,
            w=w,
            h=h,
            time = preview:getTime(index)
        }
        insert(tileData.tiles, tile)
    end
    
    if not tileData.id then
        global.editorSession:addTile(tileData, window.tileset)
    end
    
    controller.tabAnimation:reset()
    window.tile = nil
    window.selectPreview(-1,-1,-1,-1)
    controller:setLock(false)
end

controller.animationDeleteButton = function(self)
    if window.tile then
        controller.tabAnimation:reset()
        global.editorSession:removeTile(window.tile)
        window.tile = nil
        window.selectPreview(-1,-1,-1,-1)
        controller:setLock(false)
    end
end

controller.tabAnimation:createUI()
controller:addChild(controller.tabAnimation)

--[[ TAB BITMASK ]]
controller.tabBitmask = require("scene.ui.tilesetEditor.tabBitmask")(font, controller)

controller.bitmaskChangeButton = function(self)
    -- If not editing tile then
    if not window.bitmaskEditing then
        window.bitmaskEditing = true
    -- Edit button pressed,
    -- Display bitmask tiles, wait for one to be selected
    -- Once selected, process bitmask tile and load into preview as changed
    -- Change lock tab, change buttons
        controller.tabBitmask.change:setText("Finished Tile")
        controller.tabBitmask.finish:setText("Delete Tile")
    else
    -- If editing tile then
        window.bitmaskEditing = false
    -- Finished button pressed
    -- Push bitmask tile if needed to session
    -- Change lock tab, change buttons
        controller.tabBitmask.change:setText("Edit Tile")
        controller.tabBitmask.finish:setText("Create Tile")
    end
    controller:setLock(window.bitmaskEditing)
end

controller.bitmaskFinishButton = function(self)
    -- If not editing tile then
    if not window.bitmaskEditing then
        window.bitmaskEditing = true
    -- Create button pressed, set up new bitmask tile
        window.tile = {type="bitmask", tiles={}}
        controller.tabBitmask:setTile(window.tile)
    -- Change lock tab
        controller.tabBitmask.change:setText("Finished Tile")
        controller.tabBitmask.finish:setText("Delete Tile")
    else
    -- If editing tile then
        window.bitmaskEditing = false
    -- Delete current editting tile
        window.tile = nil
    -- Unlock tab
        controller.tabBitmask.change:setText("Edit Tile")
        controller.tabBitmask.finish:setText("Create Tile")
        
    end
    controller:setLock(window.bitmaskEditing)
end

controller.tabBitmask:createUI()
controller:addChild(controller.tabBitmask)
return window
