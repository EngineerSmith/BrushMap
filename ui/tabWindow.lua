local ui = require("ui.base.ui")
local tabWindow = setmetatable({}, ui)
tabWindow.__index = tabWindow

local anchor = require("ui.base.anchor")

local lg = love.graphics

local aabb = require("utilities.aabb")

tabWindow.new = function(title, windowWidth)
    local anchor = anchor.new("NorthEast", -(windowWidth or 130),0, windowWidth or 130,-1)
    local self = setmetatable(ui.new(anchor), tabWindow)
    
    self.title = title
    self.titleRect = {0,0,0,0}
    self.active = false
    
    self.color ={.8,.8,.8}
    
    return self
end

tabWindow.setTitleRect = function(self, x,y,w,h)
    self.titleRect[1], self.titleRect[2], self.titleRect[3], self.titleRect[4] =x,y,w,h
end

tabWindow.getTitleRect = function(self)
    return self.titleRect[1], self.titleRect[2], self.titleRect[3], self.titleRect[4]
end

tabWindow.drawElement = function(self)
    local x,y,w,h = self:getTitleRect()
    local x2,y2,w2,h2 = self.anchor:getRect()
    
    if self.active then
        lg.setColor(.2,.2,.2)
        lg.rectangle("fill", x2,y2,w2,h2)
    end
    
    if self.parent.active then
        x = x - w
    end
    lg.setColor(self.color)
    lg.rectangle("fill", x,y,w,h)
end


tabWindow.touchreleasedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    local x,y,w,h = self:getTitleRect()
    x = x - (self.parent.active and w or 0)
    if aabb(pressedX, pressedY, x,y,w,h) then
        self.color = {1,0,0}
        if not self.active then 
            if not self.parent.active then
                self.parent:setActive(true, self)
            end
            self.active = true 
        else
            self.active = false
            self.parent:setActive(false, self)
        end
        return true
    end
end

return tabWindow