local ui = require("ui.base.ui")
local text = setmetatable({}, {__index=ui})
text.__index = text

local lg = love.graphics

text.new = function(anchor, string, font, color)
    local self = setmetatable(ui.new(anchor), text)
    self.text = string
    self.font = font or lg.getFont()
    self.color = color or {1,1,1}
    self:updateTextSize()
    return self
end


text.updateText = function(self, string, font, color)
    self.text = string
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
    if self.font then
        lg.print(self.text, self.font, x, y)
    else
        lg.print(self.text, x, y)
    end
end

return text