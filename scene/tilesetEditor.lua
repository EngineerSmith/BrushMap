local scene = {}

local lg, lt = love.graphics, love.touch

local sqrt = math.sqrt

local editorWindow = require("scene.ui.tilesetEditor")
local dashedLine = require("utilities.dashedLine")

local cameraX, cameraY, cameraScale = 0, 0, 1
local cameraScaleSpeed = 0.01

scene.update = function(dt)
    editorWindow:update(dt)
    
    if editorWindow.tileset then
        --focalX, focalY = editorWindow.tileset:getDimensions()
        --focalX, focalY = focalX / 2, focalY / 2
        --focalX, focalY = (focalX + cameraX) * cameraScale, (focalY + cameraY) * cameraScale
    end
end

scene.draw = function()
    lg.push("all")
    lg.print(("%.2f:%.2f:%.2f"):format(cameraX, cameraY, cameraScale), 50,50)
    lg.scale(cameraScale)
    lg.translate(cameraX, cameraY)
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
    lg.setColor(1,0,1)
    lg.circle("fill", focalX or -100, focalY or -100, 5)
    editorWindow:draw()
end

local lastX, lastY = 0,0

scene.touchpressed = function(id, x, y, dx, dy, pressure)
    if editorWindow:touchpressed(id, x, y, dx, dy, pressure) then
        return end
    lastX, lastY = x,y
end


scene.touchmoved = function(id, x, y, dx, dy, pressure)
    if editorWindow:touchmoved(id, x, y, dx, dy, pressure) then
        return end
    local touches = lt.getTouches()
    if #touches == 1 then
        cameraX = cameraX + (x - lastX) / cameraScale
        cameraY = cameraY + (y - lastY) / cameraScale
        lastX, lastY = x,y
    elseif #touches >= 2 then
        local t1x, t1y, t1dx, t1dy = x,y, 0,0
        local t2x, t2y, t2dx, t2dy = x,y, 0,0
        -- Get touch information
        if touches[1] == id then
            t1dx, t1dy = dx, dy
            t2x, t2y = lt.getPosition(touches[2])
        elseif touches[2] == id then
            t1x, t1y = lt.getPosition(touches[1])
            t2dx, t2dy = dx,dy
        else
            return -- A touch we don't care for
        end
        
        -- Reference: http://answers.unity.com/answers/1271161/view.html for pinch scale code
        local t1preX, t1preY = t1x - t1dx, t1y - t1dy
        local t2preX, t2preY = t2x - t2dx, t2y - t2dy
        
        local tdx, tdy = t1preX - t2preX, t1preY - t2preY
        local preTDeltaLen = sqrt(tdx*tdx+tdy*tdy)
        
        local tdx, tdy = t1x - t2x, t1y - t2y
        local tDeltaLen = sqrt(tdx*tdx+tdy*tdy)
        
        local deltaLenDiff = preTDeltaLen - tDeltaLen
        
        local previousScale = cameraScale
        
        cameraScale = cameraScale - deltaLenDiff * cameraScaleSpeed
        
        if cameraScale < 0.1 then
            cameraScale = 0.1 end
        -- Reference End
        --TODO Solve translate at pinch focal
        --focalX, focalY = t1x + t2x / 2, t1y + t2y / 2
        focalX, focalY = editorWindow.tileset:getDimensions()
        focalX, focalY = focalX / 2, focalY / 2
        focalX, focalY = focalX + cameraX, focalY + cameraY
        focalX, focalY = focalX * cameraScale, focalY * cameraScale
        local _,_,w,h = love.window.getSafeArea()
        
        local prevWidth, prevHeight = w * previousScale, h * previousScale
        local nextWidth, nextHeight = w * cameraScale, h * cameraScale
        
        cameraX = cameraX + (focalX * -1) * ((nextWidth - prevWidth) / nextWidth)
        cameraY = cameraY + (focalY * -1) * ((nextHeight - prevHeight) / nextHeight)
    end
end

scene.touchreleased = function(id, x, y, dx, dy, pressure)
    if editorWindow:touchreleased(id, x, y, dx, dy, pressure) then
        return end
    local touches = lt.getTouches()
    if #touches == 1 then
        lastX, lastY = lt.getPosition(touches[1])
    end
end


return scene