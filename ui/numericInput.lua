local ui = require("ui.base.ui")
local numericInput = setmetatable({}, ui)
numericInput.__index = numericInput

local lg = love.graphics

local floor = math.floor
local aabb = require("utilities.aabb")

local buttonWidth = 50
local halfButtonWidth = floor(buttonWidth/2)

numericInput.new = function(anchor, min, max, font)
    local self = setmetatable(ui.new(anchor), numericInput)
    
    self.value = min
    self.min, self.max = min, max
    self.font = font or lg.getFont()
    return self
end

numericInput.setValueChangedCallback = function(self, callback)
    self.valueChangedCallback = callback
end

numericInput.triangleUp =   {  0,-10, -10, 10, 10,10}
numericInput.triangleDown = {-10,-10,  10,-10,  0,10}

numericInput.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    
    lg.setColor(.4,.4,.4)
    lg.rectangle("fill", x,y,w,h)
    
    lg.setColor(.5,.5,.5)
    lg.rectangle("fill", x,y, buttonWidth, h)
    lg.rectangle("fill", x+w-buttonWidth,y,buttonWidth,h)
    
    local str = tostring(self.value)
    local width, height = self.font:getWidth(str), self.font:getHeight()
    lg.setColor(1,1,1)
    lg.print(str, self.font, x+floor(w/2)-floor(width/2),y+floor(h/2)-floor(height/2))
    
    lg.push()
    lg.translate(x+halfButtonWidth,y+floor(h/2))
    lg.polygon("fill", numericInput.triangleDown)
    lg.translate(w-buttonWidth,0)
    lg.polygon("fill", numericInput.triangleUp)
    lg.pop()
end

numericInput.touchpressedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    local x,y,w,h = self.anchor:getRect()
    if aabb(pressedX, pressedY, x,y,buttonWidth,h) then
        self.value = self.value - 1
        if self.value < self.min then
            self.value = self.min
        elseif self.valueChangedCallback then
            self:valueChangedCallback(self.value) end
        return true
    end
    if aabb(pressedX, pressedY, x+w-buttonWidth,y,buttonWidth,h) then
        self.value = self.value + 1
        if self.value > self.max then
            self.value = self.max
        elseif self.valueChangedCallback then
            self:valueChangedCallback(self.value) end
        return true
    end
    return false
end

return numericInput