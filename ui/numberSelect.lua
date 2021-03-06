local ui = require("ui.base.ui")
local numberSelect = setmetatable({}, ui)
numberSelect.__index = numberSelect

local lg = love.graphics

local floor = math.floor
local aabb = require("utilities.aabb")

numberSelect.centralColor ={.5,.5,.5}
numberSelect.activeColor = {.4,.4,.4}
numberSelect.unactiveColor={.2,.2,.2}

numberSelect.new = function(anchor, font, min, max, base)
    local self = setmetatable(ui.new(anchor), numberSelect)
    self.font = font or lg.getFont()
    
    self.index = base or min
    self.base = self.index
    self.min = min
    self.basemin = self.min
    self.max = max
    self.basemax = self.max
    
    self.length = floor(anchor.width.max / 3)
    self.sideOffset = floor(self.length * 0.125)
    
    return self
end

numberSelect.setList = function(self, list)
   self.list = list
   self.min = list and 1 or self.basemin
   self.max = list and #list or self.basemax
end

numberSelect.setIndex = function(self, index)
    if self.list then
        for i, v in ipairs(self.list) do
            if index == v then
                self.index = i
                return true
            end
        end
    else
        self.index = index
        return true
    end
    return false
end

numberSelect.getValue = function(self)
    if self.list then
        return self.list[self.index]
    end
    return self.index
end

numberSelect.reset = function(self)
    self.index = self.base
end

numberSelect.drawElement = function(self)
    local x, y = self.anchor:getRect()
    local strHeight = self.font:getHeight()
    local h = floor((self.length-self.sideOffset*2) / 2) - floor(strHeight / 2)
-- LEFT
    if self.index > self.min then
        lg.setColor(self.activeColor)
        lg.rectangle("fill", x+self.sideOffset,y+self.sideOffset, self.length-self.sideOffset, self.length-(self.sideOffset*2))
        lg.setColor(1,1,1)
        local str = self.list and self.list[self.index-1] or tostring(self.index-1)
        local width = self.font:getWidth(str)
        local w = floor((self.length-self.sideOffset)/2) - floor(width/2)
        lg.print(str, self.font, x+self.sideOffset+w, y+self.sideOffset+h)
    end
-- CENTRE
    lg.setColor(self.centralColor)
    lg.rectangle("fill", self.length+x,y, self.length,self.length)
    lg.setColor(1,1,1)
    local he = floor(self.length / 2) - floor(strHeight / 2)
    local str = self.list and self.list[self.index] or tostring(self.index)
    local width = self.font:getWidth(str)
    local w = floor(self.length / 2) - floor(width / 2)
    lg.print(str, self.font, self.length+x+w,y+he)
-- RIGHT
    if self.index < self.max then
        lg.setColor(self.activeColor)
        lg.rectangle("fill", self.length*2+x,self.sideOffset+y, self.length-self.sideOffset, self.length-(self.sideOffset*2))
        lg.setColor(1,1,1)
        local str = self.list and self.list[self.index+1] or tostring(self.index+1)
        local width = self.font:getWidth(str)
        local w = floor((self.length-self.sideOffset)/2) - floor(width/2)
        lg.print(str, self.font, self.length*2+x+w,y+self.sideOffset+h)
    end
end

numberSelect.touchreleased = function(self, id, pressedX, pressedY, ...)
    if self.active then
        local x,y = self.anchor:getRect()
    -- General shape
        if aabb(pressedX,pressedY, x+self.sideOffset,y, self.length*3-(self.sideOffset*2), self.length) then
    -- LEFT
            if self.index > self.min and aabb(pressedX,pressedY, x+self.sideOffset,y+self.sideOffset, self.length-self.sideOffset, self.length-(self.sideOffset*2)) then
                if self.indexedChangedCallback then
                    self.index = self.index - 1
                    if not self:indexedChangedCallback(self.index, self.list and self.list[self.index]) then
                        self.index = self.index + 1
                    end
                else
                    self.index = self.index - 1
                end
            end
    -- RIGHT
            if self.index < self.max and aabb(pressedX,pressedY, self.length*2+x,self.sideOffset+y, self.length-self.sideOffset,self.length-(self.sideOffset*2)) then
                if self.indexedChangedCallback then
                    self.index = self.index + 1
                    if not self:indexedChangedCallback(self.index, self.list and self.list[self.index]) then
                        self.index = self.index - 1
                    end
                else
                    self.index = self.index + 1
                end
            end
            return true
        end
    end
end

return numberSelect