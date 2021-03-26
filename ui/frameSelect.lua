local numberSelect = require("ui.numberSelect")
local frameSelect = setmetatable({}, numberSelect)
frameSelect.__index = frameSelect

local lg = love.graphics

local floor = math.floor
local aabb = require("utilities.aabb")

frameSelect.zeroColor = {.15,.57,.19}

frameSelect.new = function(anchor, font, icon)
    local self = setmetatable(numberSelect.new(anchor, font, 0, math.huge), frameSelect)
    self.icon = icon
    self.maxindex = 0
    
    return self
end

frameSelect.reset = function(self)
    self.index = 0
    self.maxindex = 0
end

frameSelect.setMaxindex = function(self, max)
    self.index = 1
    self.maxindex = max
    if self.indexedChangedCallback then
        self:indexedChangedCallback(self.index)
    end
end

frameSelect.drawElement = function(self)
    local x, y = self.anchor:getRect()
    local strHeight = self.font:getHeight()
    local h = floor((self.length-self.sideOffset*2) / 2) - floor(strHeight / 2)
-- LEFT
    if self.index > 1 then
        lg.setColor(self.activeColor)
        lg.rectangle("fill", x+self.sideOffset,y+self.sideOffset, self.length-self.sideOffset, self.length-(self.sideOffset*2))
        lg.setColor(1,1,1)
        local width = self.font:getWidth(tostring(self.index-1))
        local w = floor((self.length-self.sideOffset)/2) - floor(width/2)
        lg.print(tostring(self.index-1), self.font, x+self.sideOffset+w, y+self.sideOffset+h)
    end
-- CENTRE
    if self.index == 0 then
        lg.setColor(self.zeroColor)
    else
        lg.setColor(self.centralColor)
    end
    lg.rectangle("fill", self.length+x,y, self.length,self.length)
    lg.setColor(1,1,1)
    if self.index ~= 0 then
        local h = floor(self.length / 2) - floor(strHeight / 2)
        local width = self.font:getWidth(tostring(self.index))
        local w = floor(self.length / 2) - floor(width / 2)
        lg.print(tostring(self.index), self.font, self.length+x+w,y+h)
    else
        local width, height = self.icon:getDimensions()
        local imageLength = width > height and width or height
        local s = self.length / imageLength
        lg.draw(self.icon, self.length+x,y, 0, s,s)
    end
-- RIGHT
    if self.index > 0 then
        if self.index < self.maxindex then 
            lg.setColor(self.activeColor)
        else
            lg.setColor(self.unactiveColor)
        end
        lg.rectangle("fill", self.length*2+x,self.sideOffset+y, self.length-self.sideOffset, self.length-(self.sideOffset*2))
        lg.setColor(1,1,1)
        local width = self.font:getWidth(tostring(self.index+1))
        local w = floor((self.length-self.sideOffset)/2) - floor(width/2)
        lg.print(tostring(self.index+1), self.font, self.length*2+x+w,self.sideOffset+y+h)
    end
end

frameSelect.touchreleased = function(self, id, pressedX, pressedY, ...)
    local x,y = self.anchor:getRect()
-- General shape
    if aabb(pressedX,pressedY, x+self.sideOffset,y, self.length*3-(self.sideOffset*2), self.length) then
-- LEFT
        if self.index > 1 and aabb(pressedX,pressedY, x+self.sideOffset,y+self.sideOffset, self.length-self.sideOffset, self.length-(self.sideOffset*2)) then
            if self.indexedChangedCallback then
                self.index = self.index - 1
                if not self:indexedChangedCallback(self.index) then
                    self.index = self.index + 1
                end
            else
                self.index = self.index - 1
            end
        end
-- CENTRE
    if self.index == 0 and aabb(pressedX,pressedY, self.length+x,y, self.length,self.length) then
            if self.indexedChangedCallback then
                self.index = 1
                if not self:indexedChangedCallback(self.index) then
                   self.index = 0 
                end
            else
                self.index = 1
            end
    end
-- RIGHT
        if self.index > 0 and aabb(pressedX,pressedY, self.length*2+x,self.sideOffset+y, self.length-self.sideOffset,self.length-(self.sideOffset*2)) then
            if self.indexedChangedCallback then
                self.index = self.index + 1
                if not self:indexedChangedCallback(self.index) then
                    self.index = self.index - 1
                end
            else
                self.index = self.index + 1
            end
            if self.index > self.maxindex then
                self.maxindex = self.index
            end
        end
        return true
    end
end

return frameSelect