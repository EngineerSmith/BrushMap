local ui = require("ui.base.ui")
local numericInput = setmetatable({}, ui)
numericInput.__index = numericInput

local lg = love.graphics

local floor = math.floor
local aabb = require("utilities.aabb")

local buttonWidth = 40
local halfButtonWidth = floor(buttonWidth/2)

numericInput.new = function(anchor, min, max, baseValue, font)
    local self = setmetatable(ui.new(anchor), numericInput)
    
    self.value = baseValue or min
    self.min, self.max = min, max
    self.font = font or lg.getFont()
    self.active = true
    return self
end

numericInput.setValueChangedCallback = function(self, callback)
    self.valueChangedCallback = callback
    if self.valueChangedCallback then
        self:valueChangedCallback(self.value)
    end
end

numericInput.setClone = function(self, numericInput)
    if self.clone then
        self.clone.active = true
    end
    self.clone = numericInput
    if self.clone then
        self.clone.active = false
        self.clone.value = self.value
        if self.clone.valueChangedCallback then
            self.clone:valueChangedCallback(self.clone.value)
        end
    end
end

numericInput.triangleUp =   {  0,-10, -10, 10, 10,10}
numericInput.triangleDown = {-10,-10,  10,-10,  0,10}

numericInput.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    
    lg.setColor(.4,.4,.4)
    lg.rectangle("fill", x,y,w,h)
    
    if self.active then
        lg.setColor(.5,.5,.5)
        lg.rectangle("fill", x,y, buttonWidth, h)
        lg.rectangle("fill", x+w-buttonWidth,y,buttonWidth,h)
        
        lg.setColor(1,1,1)
        lg.push()
        lg.translate(x+halfButtonWidth,y+floor(h/2))
        lg.polygon("fill", numericInput.triangleDown)
        lg.translate(w-buttonWidth,0)
        lg.polygon("fill", numericInput.triangleUp)
        lg.pop()
    end
    
    local str = tostring(self.value)
    local width, height = self.font:getWidth(str), self.font:getHeight()
    lg.setColor(1,1,1)
    lg.print(str, self.font, x+floor(w/2)-floor(width/2),y+floor(h/2)-floor(height/2))
end

local checkValue = function(self, bool, value)
    local triggerCloneCallback = false
    if bool then
        self.value = value
    elseif self.valueChangedCallback then
        self:valueChangedCallback(self.value) 
        triggerCloneCallback = true
    end
    if self.clone then
        self.clone.value = self.value
        if triggerCloneCallback and self.clone.valueChangedCallback then
            self.clone:valueChangedCallback(self.value)
        end
        
    end
end

numericInput.touchpressedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    if self.active then
        local x,y,w,h = self.anchor:getRect()
        if aabb(pressedX, pressedY, x,y,buttonWidth,h) then
            self.value = self.value - 1
            checkValue(self, self.value < self.min, self.min)
            return true
        end
        if aabb(pressedX, pressedY, x+w-buttonWidth,y,buttonWidth,h) then
            self.value = self.value + 1
            checkValue(self, self.value > self.max, self.max)
            return true
        end
    end
    return false
end

return numericInput