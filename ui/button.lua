local ui = require("ui.base.ui")
local button = setmetatable({}, {__index=ui})
button.__index = button

local anchor = require("ui.base.anchor")
local shape = require("ui.shape")
local imageUi = require("ui.image")
local textUi = require("ui.text")

local lg = love.graphics
local insert, remove = table.insert, table.remove
local floor = math.floor
local aabb = require("utilities.aabb")
local nilFunc = function() end

button.new = function(anchor, color, callbackPressed, callbackReleased)
    local self = setmetatable(ui.new(anchor), button)
    
    self.shape = shape.new(anchor, "Rectangle", color or {.4,.4,.4}, "fill")
    self.activeColor = self.shape.color
    
    self:setCallbackPressed(callbackPressed)
    self:setCallbackReleased(callbackReleased)
    
    self.touches = {}
    
    return self
end

button.setText = function(self, text, color, font)
    if not self.text then
        local anchor = anchor.new("Center", 0,0, -1,-1)
        self.text = textUi.new(anchor, text, font, color)
        self:addChild(self.text)
    else
        self.text:updateText(text, font, color)
    end
    self:setActive(self.active)
end

button.setImage = function(self, image, color, stencil)
    if not self.image then
        local anchor = anchor.new("Center", 0,0, -1,-1)
        self.image = imageUi.new(anchor, image, color)
        self:addChild(self.image)
    else
        self.image:setImage(image, color)
    end
    self.shape:enableStencil(stencil or false)
    self:setActive(self.active)
end

button.setOutline = function(self, enabled, distance, lineSize, color)
    self.shape:setOutline(enabled, distance, lineSize, color)
end

button.setRoundCorner = function(self, round)
    self.shape:setRoundCorner(round)
end

button.setActive = function(self, value)
    if self.active ~= value then
        self.active = value
        local prevColor = self.shape.color
        if self.active then
            self.shape.color = self.activeColor
            if self.text and self.activeTextColor then
                self.text:updateText(nil,nil, self.activeTextColor)
            end
            if self.image and self.activeImageColor then
                self.image:updateImage(nil, self.activeImageColor)
            end
        else
            local r,g,b = self.activeColor[1],self.activeColor[2],self.activeColor[3]
            self.shape.color = {r-0.2,g-0.2,b-0.2}
            if self.text then
                local r,g,b = self.text.color[1],self.text.color[2],self.text.color[3]
                self.activeTextColor = self.text.color
                self.text:updateText(nil, nil, {r-0.4,g-0.4,b-0.4})
            end
            if self.image then
                local r,g,b = self.image.color[1],self.image.color[2],self.image.color[3]
                self.activeImageColor = self.image.color
                self.image:setImage(nil, {r-0.4,g-0.4,b-0.4})
            end
        end
        -- Set line color to current active color if it's own color hasn't been set
        if self.shape.lineColor == prevColor then
            self.shape.lineColor = self.shape.color
        end
    end
end

button.setCallbackPressed = function(self, callback)
    self.callbackPressed = callback or nilFunc
    self:setActive(self.callbackPressed ~= nilFunc or self.callbackReleased ~= nilFunc)
end

button.setCallbackReleased = function(self, callback) 
    self.callbackReleased = callback or nilFunc
    self:setActive(self.callbackPressed ~= nilFunc or self.callbackReleased ~= nilFunc)
end

local getTouch = function(touches, id)
    for k,v in ipairs(touches) do
        if v.id == id then return k,v end
    end
    return -1
end

button.touchpressedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    if self.active and aabb(pressedX, pressedY, self.anchor:getRect()) then
        insert(self.touches, {id=id, x=x, y=y})
        local result = self:callbackPressed()
        return result ~= nil and result or true
    end
    return false
end

button.touchreleasedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    local key, touch = getTouch(self.touches, id)
    if key ~= -1 then
        if self.active and aabb(pressedX, pressedY, self.anchor:getRect()) then
            local result = self:callbackReleased()
            return result ~= nil and result or true
        end
        remove(self.touches, key)
    end
    return false
end

button.drawElement = function(self)
    self.shape:draw()
end

return button