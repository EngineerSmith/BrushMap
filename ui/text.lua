local ui = require("ui.base.ui")
local text = setmetatable({}, {__index=ui})
text.__index = text

local lg = love.graphics

text.new = function(anchor, string, font, color)
    local self = setmetatable(ui.new(anchor), text)
    self.text = string
    self.font = font
    self.color = color or {1,1,1}
    return self
end

text.updateText = function(self, string, font, color)
    self.text = string
    self.font = font or self.font
    self.color = color or self.color
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