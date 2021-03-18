local ui = require("ui.base.ui")
local buttonFrameSelect = setmetatable({}, ui)
buttonFrameSelect.__index = buttonFrameSelect

local lg = love.graphics

local floor = math.floor
local aabb = require("utilities.aabb")

buttonFrameSelect.zeroColor =   {.15,.57,.19}
buttonFrameSelect.activeZero =  {.5,.5,.5}
buttonFrameSelect.activeColor = {.4,.4,.4}
buttonFrameSelect.unactiveColor={.2,.2,.2}

buttonFrameSelect.new = function(anchor, font, zeroicon)
    local self = setmetatable(ui.new(anchor), buttonFrameSelect)
    self.font = font or lg.getFont()
    self.zeroicon = zeroicon
    
    self.index = 0
    self.maxindex = 0
    self.length = floor(anchor.width.max / 3)
    self.sideOffset = floor(self.length * 0.125)
    
    return self
end

buttonFrameSelect.reset = function(self)
    self.index = 0
    self.maxindex = 0
end

buttonFrameSelect.setMaxindex = function(self, max)
    self.index = 1
    self.maxindex = max
    if self.indexedChangedCallback then
        self:indexedChangedCallback(self.index)
    end
end

buttonFrameSelect.drawElement = function(self)
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
        lg.setColor(self.activeZero)
    end
    lg.rectangle("fill", self.length+x,y, self.length,self.length)
    lg.setColor(1,1,1)
    if self.index ~= 0 then
        local h = floor(self.length / 2) - floor(strHeight / 2)
        local width = self.font:getWidth(tostring(self.index))
        local w = floor(self.length / 2) - floor(width / 2)
        lg.print(tostring(self.index), self.font, self.length+x+w,y+h)
    elseif self.zeroicon then
        local width, height = self.zeroicon:getDimensions()
        local imageLength = width > height and width or height
        local s = self.length / imageLength
        lg.draw(self.zeroicon, self.length+x,y, 0, s,s)
    end
-- RIGHT
    if self.index > 0 then
        if self.index + 1 > self.maxindex then
            lg.setColor(self.unactiveColor)
        else
            lg.setColor(self.activeColor)
        end
        lg.rectangle("fill", self.length*2+x,self.sideOffset+y, self.length-self.sideOffset, self.length-(self.sideOffset*2))
        lg.setColor(1,1,1)
        local width = self.font:getWidth(tostring(self.index+1))
        local w = floor((self.length-self.sideOffset)/2) - floor(width/2)
        lg.print(tostring(self.index+1), self.font, self.length*2+x+w,self.sideOffset+y+h)
    end
end

buttonFrameSelect.touchreleased = function(self, id, pressedX, pressedY, ...)
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

return buttonFrameSelect