local ui = {}
ui.__index = ui

local insert = table.insert

ui.new = function(anchor) 
    local self = {
        children = {},
        parent = nil,
        anchor = anchor or error("UI requires anchor"),
    }
    
    return setmetatable(self, ui)
end

ui.addChild = function(self, child)
    if child.parent then 
        error("Child already a has parent") 
    end
    
    insert(self.children, child)
    child.parent = self
end

ui.updateAnchor = function(self, windowWidth, windowLength, offsetX, offsetY)
    offsetX, offsetY = offsetX or 0, offsetY or 0
    local x, y, width, height = self.anchor:calculate(offsetX, offsetY, windowWidth, windowLength)
    offsetX, offsetY = offsetX + x, offsetY + y
    for _, child in ipairs(self.children) do
        child:updateAnchor(width, height, offsetX, offsetY)
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
    self:drawElement()
    self:drawChildren()
end

ui.drawChildren = function(self) 
    for _, child in ipairs(self.children) do
        child:draw()
    end
end

ui.drawElement = function(self) end

-- EVENTS

ui.touchPressed = function(self, x, y)
    return self:touchPressedChildren(x, y) or self:touchPressedElement(x, y)
end

ui.touchPressedChildren = function(self, x, y) 
    for _, child in ipairs(self.children) do
        if child:touchPressed(x, y) then
            return true
        end
    end
    return false
end

ui.touchPressedElement = function(self, x, y)
    return false
end

ui.touchReleased = function(self, x, y)
    return self:touchReleasedChildren(x, y) or self:touchReleasedElement(x, y)
end

ui.touchReleasedChildren = function(self, x, y)
    for _, child in ipairs(self.children) do
        if child:touchReleased(x, y) then
            return true
        end
    end
    return false
end

ui.touchReleasedElement = function(self, x, y)
    return false
end

return ui