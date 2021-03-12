local ui = require("ui.base.ui")
local image = setmetatable({}, {__index=ui})
image.__index = image

local lg = love.graphics

image.new = function(anchor, picture, color, quad)
    local self = setmetatable(ui.new(anchor), image)
    self:setImage(picture, color)
    self:setQuad(quad)
    return self
end

image.setImage = function(self, image, color)
    if image then
        self.image = image
        local width, height = image:getDimensions()
        self.imageLength = width > height and height or width
    end
    self.color = color or {1,1,1}
end

image.setQuad = function(self, quad)
    self.quad = quad
    if quad then
        local _,_, width, height = quad:getViewport()
        self.imageLength = width > height and height or width
    end
end

image.drawElement = function(self)
    if self.image then
        local x, y, width, height = self.anchor:getRect()
        local s = (width > height and height or width) / self.imageLength
        
        lg.setColor(self.color)
        if self.quad then
            lg.draw(self.image, self.quad, x, y, 0, s, s)
        else
            lg.draw(self.image, x, y, 0, s, s)
        end
    end
end

return image