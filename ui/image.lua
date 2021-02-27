local ui = require("ui.base.ui")
local image = setmetatable({}, {__index=ui})
image.__index = image

local lg = love.graphics

image.new = function(anchor, picture, color)
    local self = setmetatable(ui.new(anchor), image)
    self:setImage(picture, color)
    return self
end

local rad = math.rad

image.setImage = function(self, image, color)
    if image then
        self.image = image
        local width, height = image:getWidth(), image:getHeight()
        self.imageLength = width > height and height or width
    end
    self.color = color or {1,1,1}
end

image.drawElement = function(self)
    local x, y, width, height = self.anchor:getRect()
    local s = (width > height and height or width) / self.imageLength
    
    lg.setColor(self.color)
    lg.draw(self.image, x, y, 0, s, s)
end

return image