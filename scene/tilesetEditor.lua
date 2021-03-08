local scene = {}

local lg, lt = love.graphics, love.touch

local editorWindow = require("scene.ui.tilesetEditor")
local dashedLine = require("utilities.dashedLine")
local touchController = require("input.touch")

local _,_,w,h = love.window.getSafeArea()
touchController.setDimensions(w,h)

scene.update = function(dt)
    touchController.update()
    editorWindow:update(dt)
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
        local width, height = editorWindow.tileset:getDimensions()
        local x = editorWindow.tilesizeX
        local y = editorWindow.tilesizeY
        lg.setColor(1,1,1,.6)
        for i=-1, width/x + 1 do
            dashedLine(i*x,-y, i*x,height+y, 3,2)
        end
        for i=-1, height/y + 1 do
            lg.setColor(1,1,1,.6)
            dashedLine(-x,i*y, width+x,i*y, 3,2)
        end
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