local scene = {}

local lg, lt = love.graphics, love.touch

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
end

touchController.setPressedCallback(function(x, y)
    if editorWindow.tileset then
        x, y = touchController.touchToWorld(x, y)
        
        local w, h = editorWindow.tileset:getDimensions()
        
        if aabb(x,y, 0,0,w,h) then
            xx, yy = grid:positionToTile(x, y)
            str = ("TOUCH!\n%.0f, %.0f\n%.2f, %.2f"):format(x, y, xx, yy)
        end
    end
end)

scene.update = function(dt)
    touchController.update()
    editorWindow:update(dt)
    
    grid:setTileSize(editorWindow.tilesizeX, editorWindow.tilesizeY)
    grid:setTileOffset(editorWindow.tileoffsetX, editorWindow.tileoffsetY)
    
    if editorWindow.tileset then
        local scale = touchController.scale
        local x,y = touchController.x, touchController.y
        local tw, th = w * scale, h * scale
        local w, h = editorWindow.tileset:getDimensions()
        w, h = w * scale, h * scale
        if not aabbBox(0,0,tw,th, x,y,w,h) then
            touchController.reset()
        end
    end
end

scene.draw = function()
    lg.push("all")
    lg.scale(touchController.scale)
    lg.translate(touchController.x, touchController.y)
    if editorWindow.tileset then
        lg.setColor(1,1,1)
        lg.draw(editorWindow.tileset)
    end
    
    if editorWindow.tileset then
        grid:draw(touchController.scale / 1.5)    
    end
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