local outlineBox = {}
outlineBox.__index = outlineBox

local lg = love.graphics
local min, max = math.min, math.max

local dashedLine = require("utilities.dashedLine")

local function inbetween(low, high, value)
    return min(high, max(low, value))
end

outlineBox.new = function(x, y, width, height, color)
    local self = setmetatable({}, outlineBox)
    
    self.x, self.y = x, y
    self.width, self.height = width, height
    self.color = color or {1,0,0}
    
    return self
end

outlineBox.getRect = function(self)
    return self.x, self.y, self.width, self.height
end

outlineBox.draw = function(self, scale)
    local dash  = inbetween(2.1, 5, 5 / scale)
    local space = inbetween(2.1, 5, 5 / scale)
    
    local x, y = self.x, self.y
    local w, h = self.width, self.height
    
    lg.setColor(self.color)
    lg.setLineWidth(min(scale, 0.4)*2)
    dashedLine(x,y, x+w,y, dash,space)
    dashedLine(x+w,y, x+w,y+h, dash,space)
    dashedLine(x+w,y+h, x,y+h, dash,space)
    dashedLine(x,y+h, x,y, dash,space)
    lg.setLineWidth(1)
end

return outlineBox