local ui = {}
ui.__index = ui

local insert = table.insert

ui.new = function(anchor) 
    local self = {
        children = {count=0},
        parent = nil,
        anchor = anchor or error("UI requires anchor"),
        enabled = true,
    }
    
    return setmetatable(self, ui)
end

ui.addChild = function(self, child)
    if child.parent then 
        error("Child already a has parent") 
    end
    
    insert(self.children, child)
    self.children.count = self.children.count + 1
    child.parent = self
    self:getAnchorUpdate()
    return self.children.count
end

ui.getAnchorUpdate = function(self)
    if self.parent then
        self.parent:getAnchorUpdate()
    else
        local _,_, width, height = love.window.getSafeArea()
        self:updateAnchor(width, height)
    end
end

ui.updateAnchor = function(self, windowWidth, windowLength, offsetX, offsetY)
    offsetX, offsetY = offsetX or 0, offsetY or 0
    local x, y, width, height = self.anchor:calculate(offsetX, offsetY, windowWidth, windowLength)
    for _, child in ipairs(self.children) do
        child:updateAnchor(width, height, x, y)
    end
end

-- Functions ending in Element are to be overriden

ui.update = function(self, dt) 
    self:updateElement(dt)
    self:updateChildren(dt)
end

ui.updateChildren = function(self, dt) 
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

ui.updateElement = function(self, dt) end 

ui.draw = function(self)
    if self.enabled then
        self:drawElement()
        self:drawChildren()
    end
end

ui.drawChildren = function(self) 
    for _, child in ipairs(self.children) do
        if child.enabled then
            child:draw()
        end
    end
end

ui.drawElement = function(self) end

-- EVENTS

ui.touchpressed = function(self, id, x, y, dx, dy, pressure)
    return self:touchpressedChildren(id, x, y, dx, dy, pressure) or self:touchpressedElement(id, x, y, dx, dy, pressure)
end

ui.touchpressedChildren = function(self, id, x, y, dx, dy, pressure) 
    for _, child in ipairs(self.children) do
        if child.enabled and child:touchpressed(id, x, y, dx, dy, pressure) then
            return true
        end
    end
    return false
end

ui.touchpressedElement = function(self, id, x, y, dx, dy, pressure)
    return false
end

ui.touchmoved = function(self, id, x, y, dx, dy, pressure)
   return self:touchmovedChildren(id, x, y, dx, dy, pressure) or self:touchmovedElement(id, x, y, dx, dy, pressure) 
end

ui.touchmovedChildren = function(self, id, x, y, dx, dy, pressure)
    for _, child in ipairs(self.children) do
        if child.enabled and child:touchmoved(id, x, y, dx, dy, pressure) then
            return true
        end
    end
    return false
end

ui.touchmovedElement = function(self, id, x, y, dx, dy, pressure)
    return false
end

ui.touchreleased = function(self, id, x, y, dx, dy, pressure)
    return self:touchreleasedChildren(id, x, y, dx, dy, pressure) or self:touchreleasedElement(id, x, y, dx, dy, pressure)
end

ui.touchreleasedChildren = function(self, id, x, y, dx, dy, pressure)
    for _, child in ipairs(self.children) do
        if child.enabled and child:touchreleased(id, x, y, dx, dy, pressure) then
            return true
        end
    end
    return false
end

ui.touchreleasedElement = function(self, id, x, y, dx, dy, pressure)
    return false
end

return ui