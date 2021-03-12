local ui = require("ui.base.ui")
local image = setmetatable({}, {__index=ui})
image.__index = image

local lg = love.graphics

local floor = math.floor

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
        self.imageLength = width > height and width or height
    end
    self.color = color or {1,1,1}
end

image.setQuad = function(self, quad)
    self.quad = quad
    if quad then
        local _,_, width, height = quad:getViewport()
        self.imageLength = width > height and width or height
    end
end

image.setBackgroundColor = function(self, color)
    self.backgroundColor = color
end

image.drawElement = function(self)
    local x, y, width, height = self.anchor:getRect()
    if self.backgroundColor then
        lg.setColor(self.backgroundColor)
        lg.rectangle("fill", x,y, width,height)
    end
    if self.image then
        local s = (width > height and width or height) / self.imageLength
        
        
        lg.setColor(self.color)
        if self.quad then
            local _,_,w,h = self.quad:getViewport()
            local offsetX = floor(width/2) - floor((w*s)/2)
            local offsetY = floor(height/2) - floor((h*s)/2)
            lg.draw(self.image, self.quad, x + offsetX, y + offsetY, 0, s, s)
        else
            local offsetX = floor(width/2) - floor((self.image:getWidth()*s)/2)
            local offsetY = floor(height/2) - floor((self.image:getHeight()*s)/2)
            lg.draw(self.image, x + offsetX, y + offsetY, 0, s, s)
        end
    end
end

return image