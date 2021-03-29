local scene = {}

local global = require("global")

local lg, lt = love.graphics, love.touch

local aabb = require("utilities.aabb")

local floor, max = math.floor, math.max

local editorWindow = require("scene.ui.tilesetEditor")
local touchController = require("input.touch").new()
local grid = require("utilities.tilesetGrid").new()

editorWindow.grid = grid

local _,_,w,h = love.window.getSafeArea()
touchController:setDimensions(w,h)

editorWindow.newTilesetCallback = function(tileset)
    local width, height = tileset:getDimensions()
    local low, high = max(width / 180, 2), max(width / 50, 5)
    touchController:setLimitScale(low, high)
    touchController:reset()
    touchController.scale = low
    touchController.prevWidth = touchController.width * low
    touchController.prevHeight = touchController.height * low
    local _,_,w,h = love.window.getSafeArea()
    w, h = w / low, h / low
    touchController.x = floor(w/2) - floor(width/2)
    touchController.y = floor(h/2) - floor(height/2)
    grid:setDimensions(width, height)
    editorWindow.updatePreview(-1, -1, -1, -1)
end

touchController:setPressedCallback(function(x, y)
    if editorWindow.tileset then
        x, y = touchController:touchToWorld(x, y)
        
        local w, h = editorWindow.tileset.image:getDimensions()
        
        if aabb(x,y, 0,0,w,h) then
            local pressedX, pressedY = x, y
            local x, y, w, h = grid:positionToTile(x, y)
            if x ~= -1 and y ~= -1 then
                editorWindow.selectPreview(x, y, w, h, pressedX, pressedY)
            end
        end
    end
end)

local boundary = 50
scene.update = function(dt)
    local px, py, ps = touchController.x, touchController.y, touchController.scale
    
    touchController:update()
    editorWindow:update(dt)
    
    if editorWindow.tileset then
        local scale = touchController.scale
        local x, y, tw, th = touchController:getRect()
        local w, h = editorWindow.tileset.image:getDimensions()
        if not (boundary < x + w and tw - boundary > x and
                boundary < y + h and th - boundary > y) then
            touchController.x, touchController.y = px, py
            touchController.scale = ps
        end
    end
end

local texture = global.assets["texture.checkerboard"]
local _,_, width, height = love.window.getSafeArea()
local scale = 4
local quad = lg.newQuad(0,0, width/scale, height/scale, texture:getDimensions())

scene.draw = function()
    if editorWindow.showTexture then
        lg.setColor(lg.getBackgroundColor())
        lg.draw(texture, quad, 0,0, 0, scale,scale)
    end
    lg.push("all")
    lg.scale(touchController.scale)
    lg.translate(touchController.x, touchController.y)
    if editorWindow.tileset then
        lg.setColor(1,1,1)
        lg.draw(editorWindow.tileset.image)
    end
    
    editorWindow.drawScene(touchController.scale / 1.5)
    
    lg.pop()
    editorWindow:draw()
    lg.setColor(1,1,1)
    local str = str or "" -- debug, global str
    lg.print(str, 100,50)
end

scene.touchpressed = function(...)
    if editorWindow:touchpressed(...) then
        return end
    touchController:touchpressed(...)
end

scene.touchmoved = function(...)
    touchController:touchmoved(...)
    if editorWindow:touchmoved(...) then
        return end
end

scene.touchreleased = function(...)
    touchController:touchreleased(...)
    if editorWindow:touchreleased(...) then
        return end
end

return scene