local controller = {
    x, y, scale,
    width, height = 1,1
}

local insert, remove = table.insert, table.remove
local sqrt = math.sqrt

local touches = {}
local prevWidth, prevHeight

controller.setDimensions = function(width, height)
    controller.width, controller.height = width, height
    prevWidth, prevHeight = width, height
end

controller.reset = function()
    controller.x = 0
    controller.y = 0
    controller.scale = 1
end

local updateTouch = function(touch)
    local lastX, lastY = touch.x, touch.y
    local dx,dy = 0,0
    for k, move in ipairs(touch.moved) do
        dx = dx + (move.x - lastX) / controller.scale
        dy = dy + (move.y - lastY) / controller.scale
        lastX, lastY = move.x, move.y
        touch.moved[k] = nil
    end
    touch.x = lastX
    touch.y = lastY
    return dx, dy
end

local A, B = {}, {}

controller.update = function()
    if #touches == 1 then
        local dx, dy = updateTouch(touches[1])
        
        controller.x = controller.x + dx
        controller.y = controller.y + dy
    elseif #touches == 2 then
        if #touches[1].moved > 0 or #touches[2].moved > 0 then
            updateTouch(touches[1])
            updateTouch(touches[2])
            A.x, B.x = touches[1].x, touches[2].x
            A.y, B.y = touches[1].y, touches[2].y
            --Scale
            local dx,dy = B.x - A.x, B.y - A.y
            local dist = sqrt(dx*dx+dy*dy)
            
            controller.scale = controller.scale * (dist/lastDist)
            lastDist = dist
            --Translate
            A.x, B.x = (A.x / controller.scale) - controller.x, (B.x / controller.scale) - controller.x
            A.y, B.y = (A.y / controller.scale) - controller.y, (B.y / controller.scale) - controller.y
            
            local focalX = (A.x + B.x) / 2
            local focalY = (A.y + B.y) / 2
            
            local nextWidth = controller.width * controller.scale
            local nextHeight= controller.height * controller.scale
            
            controller.x = controller.x + (-(focalX / controller.scale) * (nextWidth - prevWidth) / nextWidth)
            controller.y = controller.y + (-(focalY / controller.scale) * (nextHeight - prevHeight) / nextHeight)
            
            prevWidth, prevHeight = nextWidth, nextHeight
        end
    end
end

local getTouch = function(id)
    for k,v in ipairs(touches) do
        if v.id == id then return k,v end
    end
    return -1
end

controller.touchpressed = function(id, x, y, dx, dy, pressure)
    insert(touches, {id=id, x=x, y=y, moved={}})
    if #touches == 2 then
        local dx, dy = touches[2].x - touches[1].x, touches[2].y - touches[1].y
        lastDist = sqrt(dx*dx+dy*dy)
    end
end

controller.touchmoved = function(id, x, y, dx, dy, pressure)
    local key, touch = getTouch(id)
    if key ~= -1 then
        insert(touch.moved, {x=x, y=y})
    end
end

controller.touchreleased = function(id, x, y, dx, dy, pressure)
    local key = getTouch(id)
    if key ~= -1 then
        remove(touches, key)
    end
end

controller.reset()
return controller