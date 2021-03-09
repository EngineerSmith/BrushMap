local scene = {}

local lg, lt = love.graphics, love.touch

local aabbBox = require("utilities.aabbBox")

local editorWindow = require("scene.ui.tilesetEditor")
local dashedLine = require("utilities.dashedLine")
local touchController = require("input.touch")

local _,_,w,h = love.window.getSafeArea()
touchController.setDimensions(w,h)

editorWindow.newTilesetCallback = function(tileset)
    local low, high = 0.8, 5
    touchController.setLimitScale(low, high)
    touchController.reset()
end

local function inbetween(min, max, value)
    return math.min(max, math.max(min, value))
end

scene.update = function(dt)
    touchController.update()
    editorWindow:update(dt)
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
        local offsetX, offsetY = editorWindow.tileoffsetX, editorWindow.tileoffsetY
        local width, height = editorWindow.tileset:getDimensions()
        local x = editorWindow.tilesizeX
        local y = editorWindow.tilesizeY
        
        local dash  = inbetween(2.1, 5, 5 / (touchController.scale / 1.5))
        local space = inbetween(2.1, 5,5 / (touchController.scale / 1.5))
        lg.setLineWidth(math.min(math.max(touchController.scale/1.5,1),0.2))
        lg.setColor(.8,.8,.8)
        for i=0, (width-offsetX)/x do
            dashedLine(i*x+offsetX, offsetY, i*x+offsetX,height, dash, space)
        end
        for i=0, (height-offsetY)/y do
            dashedLine(offsetX,i*y+offsetY, width,i*y+offsetY, dash, space)
        end
        lg.setLineWidth(1)
    end
    lg.pop()
    editorWindow:draw()
    lg.setColor(1,1,1)
    lg.print((""):format(), 50,50)
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