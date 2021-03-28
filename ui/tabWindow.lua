local ui = require("ui.base.ui")
local tabWindow = setmetatable({}, ui)
tabWindow.__index = tabWindow

local anchor = require("ui.base.anchor")

local lg = love.graphics

local aabb = require("utilities.aabb")
local inbetween = require("utilities.inbetween")
local insert, remove = table.insert, table.remove
local floor = math.floor

tabWindow.new = function(title, font, controller)
    local anchor = controller:getTabWindowAnchor()
    local self = setmetatable(ui.new(anchor), tabWindow)
    
    self.title = title
    self.font = font or lg.getFont()
    self.titleRect = {0,0,0,0}
    self.active = false
    self.offsetY = 0
    self.actualHeight = 0
    
    self.touches = {}
    self.color ={.8,.8,.8}
    
    return self
end

--To be overriden 
tabWindow.createUI = function(self) end

tabWindow.setTitleRect = function(self, x,y,w,h)
    self.titleRect[1], self.titleRect[2], self.titleRect[3], self.titleRect[4] =x,y,w,h
end

tabWindow.getTitleRect = function(self)
    return self.titleRect[1], self.titleRect[2], self.titleRect[3], self.titleRect[4]
end

local bottomPadding = 30

tabWindow.addChild = function(self, child)
    if child.parent then 
        error("Child already a has parent") 
    end
    
    insert(self.children, child)
    self.children.count = self.children.count + 1
    child.parent = self
    
    local num = self.children.count - 1
    
    self:getAnchorUpdate()
    local h = child.anchor.y + child.anchor.height.max
    if h > self.actualHeight - bottomPadding then
        self.actualHeight = h + bottomPadding
    end
end

tabWindow.draw = function(self)
    if self.enabled then
        self:drawElement()
        if self.active then 
            lg.push()
            lg.translate(0, self.offsetY)
            self:drawChildren()
            lg.pop()
        end
    end
end

tabWindow.drawElement = function(self)
    local x,y,w,h = self:getTitleRect()
    
    if self.parent.active then
        if self.parent.side == "West" then
            x = x
        elseif self.parent.side == "East" then 
            x = x - w
        end
    end
    
    if self.active then
        lg.setColor(.3,.3,.3)
    else 
        lg.setColor(.2,.2,.2) 
    end
    lg.rectangle("fill", x,y,w,h)
    
    lg.setColor(1,1,1)
    
    w = floor(w/2) - floor(self.font:getHeight()/2)
    h = floor(h/2) + floor(self.font:getWidth(self.title)/2)
    lg.print(self.title, self.font, x+w,y+h, math.rad(270))
    
    if self.active then 
        lg.setColor(.3,.3,.3)
        lg.rectangle("fill", self.anchor:getRect())
    end
    
end

local getTouch = function(touches, id)
    for k,v in ipairs(touches) do
        if v.id == id then return k,v end
    end
    return -1
end

tabWindow.touchpressedElement = function(self, id, pressedX, pressedY, ...)
    local x,y,w,h = self:getTitleRect()
    if self.parent.active then
        if self.parent.side == "West" then
            x = x - w + 40
        elseif self.parent.side == "East" then 
            x = x - w
        end
    end
    
    if aabb(pressedX, pressedY, x,y,w,h) then
        insert(self.touches, {id=id, trigger=true})
        return true
    end
    if self.active and aabb(pressedX, pressedY, self.anchor:getRect()) then
        insert(self.touches, {id=id, trigger=false})
        return true
    end
end

tabWindow.touchmovedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    local x,y,w,h = self:getTitleRect()
    if self.parent.active then
        if self.parent.side == "West" then
            x = x - w + 40
        elseif self.parent.side == "East" then 
            x = x - w
        end
    end
    if (aabb(pressedX, pressedY, x,y,w,h)) or (self.active and aabb(pressedX, pressedY, self.anchor:getRect())) then
        local key = getTouch(self.touches, id)
        if key ~= -1 then
            local yLimit = self.anchor.rect[4] - self.actualHeight
            if yLimit < 0 then
              self.offsetY = inbetween(self.offsetY + dy, 0, yLimit)
            end
            return true
        end
    end
end

tabWindow.touchreleasedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    local key = getTouch(self.touches, id)
    if key ~= -1 then
        local trigger = self.touches[key].trigger
        remove(self.touches, key)
        
        if trigger then
            local x,y,w,h = self:getTitleRect()
            if self.parent.active then
                if self.parent.side == "West" then
                    x = x - w + 40
                elseif self.parent.side == "East" then 
                    x = x - w
                end
            end
            if aabb(pressedX, pressedY, x,y,w,h) then
                if self.parent:setActive(not self.active, self) then
                    self.active = not self.active
                end
                return true
            end
        end
        
        return self.active and aabb(pressedX, pressedY, self.anchor:getRect())
    end
end

tabWindow.touchpressedChildren = function(self, id, x, y, ...)
    if self.active then
        return ui.touchpressedChildren(self, id, x, y - self.offsetY, ...)
    end
end

tabWindow.touchmovedChildren = function(self, id, x, y, ...)
    if self.active then
        return ui.touchmovedChildren(self, id, x, y - self.offsetY, ...)
    end
end

tabWindow.touchreleasedChildren = function(self, id, x, y, ...)
    if self.active then
        return ui.touchreleasedChildren(self, id, x, y - self.offsetY, ...)
    end
end

return tabWindow