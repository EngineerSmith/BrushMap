local ui = require("ui.base.ui")
local text = setmetatable({}, {__index=ui})
text.__index = text

local lg = love.graphics

local floor = math.floor

text.new = function(anchor, string, font, color)
    local self = setmetatable(ui.new(anchor), text)
    self.text = string
    self.font = font or lg.getFont()
    self.color = color or {1,1,1}
    self:updateTextSize()
    return self
end

text.updateText = function(self, string, font, color)
    self.text = string or self.text
    self.font = font or self.font
    self.color = color or self.color
    self:updateTextSize()
end

text.updateTextSize = function(self)
    self.anchor.width.max = self.font:getWidth(self.text)
    self.anchor.width.min = self.anchor.width.max
    self.anchor.height.max = self.font:getHeight()
    self.anchor.height.min = self.anchor.height.max
    
    self:getAnchorUpdate()
end

text.drawElement = function(self)
    local x, y, width, height = self.anchor:getRect()
    
    local allignment = self.anchor.pointStr
    local centreV = floor(width/2) - floor(self.font:getWidth(self.text) / 2)
    local centreH = floor(height/2) - floor(self.font:getHeight() /2)
    
    if allignment == "North" or allignment == "Center" or allignment == "South" then
        x = x + centreV
    end
    if allignment == "West" or allignment == "Centre" or allignment == "East" then
        y = y + centreH
    end
    lg.setColor(self.color)
    lg.print(self.text, self.font, x, y)
end

return text