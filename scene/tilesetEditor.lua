local scene = {}

local lg, lt = love.graphics, love.touch

local global = require("global")

local aabb = require("utilities.aabb")
local aabbBox = require("utilities.aabbBox")

local editorWindow = require("scene.ui.tilesetEditor")
local touchController = require("input.touch")
local grid = require("utilities.grid").new()

local _,_,w,h = love.window.getSafeArea()
touchController.setDimensions(w,h)

editorWindow.newTilesetCallback = function(tileset)
    local low, high = 0.8, 5
    touchController.setLimitScale(low, high)
    touchController.reset()
    grid:setDimensions(tileset:getDimensions())
    local x, y, w, h = grid:positionToTile(0,0)
    if x ~= -1 and y ~= -1 then
        editorWindow.updatePreview(x,y, w,h)
    end
end

touchController.setPressedCallback(function(x, y)
    if editorWindow.tileset then
        x, y = touchController.touchToWorld(x, y)
        
        local w, h = editorWindow.tileset.image:getDimensions()
        
        if aabb(x,y, 0,0,w,h) then
            local x, y, w, h = grid:positionToTile(x, y)
            if x ~= -1 and y ~= -1 then
                editorWindow.selectPreview(x,y, w,h)
            end
        end
    end
end)

scene.update = function(dt)
    touchController.update()
    editorWindow:update(dt)
    
    --TODO Make it look better, pass grid to tileset?
    grid:setTileSize(editorWindow.controller.tabTileset.x, editorWindow.controller.tabTileset.y)
    grid:setTileOffset(editorWindow.controller.tabTileset.gridoffsetX,editorWindow.controller.tabTileset.gridoffsetY)
    grid:setPadding(editorWindow.controller.tabTileset.paddingX, editorWindow.controller.tabTileset.paddingY)
    
    if editorWindow.tileset then
        local scale = touchController.scale
        local x,y = touchController.x, touchController.y
        local tw, th = w * scale, h * scale
        local w, h = editorWindow.tileset.image:getDimensions()
        w, h = w * scale, h * scale
        if not aabbBox(0,0,tw,th, x,y,w,h) then
            touchController.reset()
        end
    end
end

local texture = global.assets["texture.checkerboard"]
local _,_, width, height = love.window.getSafeArea()
local quad = lg.newQuad(0,0, width/4, height/4, texture:getDimensions())

scene.draw = function()
    if editorWindow.showTexture then
        lg.setColor(lg.getBackgroundColor())
        lg.draw(texture, quad, 0,0, 0, 4,4)
    end
    lg.push("all")
    lg.scale(touchController.scale)
    lg.translate(touchController.x, touchController.y)
    if editorWindow.tileset then
        lg.setColor(1,1,1)
        lg.draw(editorWindow.tileset.image)
    end
    
    if editorWindow.tileset then
        grid:draw(touchController.scale / 1.5)    
    end
    
    editorWindow.drawOutlines(touchController.scale / 1.5)
    
    lg.pop()
    editorWindow:draw()
    lg.setColor(1,1,1)
    local str = str or ""
    lg.print(str, 50,50)
end

scene.touchpressed = function(...)
    if editorWindow:touchpressed(...) then
        return end
    touchController.touchpressed(...)
end

scene.touchmoved = function(...)
    touchController.touchmoved(...)
    if editorWindow:touchmoved(...) then
        return end
end

scene.touchreleased = function(...)
    touchController.touchreleased(...)
    if editorWindow:touchreleased(...) then
        return end
end

return scene