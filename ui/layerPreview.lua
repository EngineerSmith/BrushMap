local ui = require("ui.base.ui")
local layerPreview = setmetatable({}, ui)
layerPreview.__index = layerPreview

local lg = love.graphics

local anchor = require("ui.base.anchor")
local button = require("ui.button")

local aabb = require("utilities.aabb")
local color = {.3,.3,.3}
local insert, remove = table.insert, table.remove

layerPreview.backgroundColor = {.45,.45,.45}
layerPreview.selectedColor = {.35,.35,.35}

layerPreview.new = function(layer, width, font)
    local anchor = anchor.new("NorthWest", 0,0, width-20,width*0.75, 0,0)
    local self = setmetatable(ui.new(anchor), layerPreview)
    self.layer = layer
    self.layer.selected = false
    self.font = font
    self.touches = {}
    
    local anchor = anchor.new("SouthWest", 15,5, 30,30)
    self.trash = button.new(anchor, color, function()
    end)
    self.trash:setText("T", nil, font)
    self:addChild(self.trash)
    
    local anchor = anchor.new("SouthEast", 5, 5, 30,30)
    self.upButton = button.new(anchor, color, function()
        if self.parent:move(self, -1) then
            local target = self.parentIndex
            local index = target+1
            local layers = self.layer.map.layers
            local t = self.layer.map.layers[index]
            layers[index] = layers[target]
            layers[target] = t
            return true
        end
    end)
    self.upButton:setText("^", nil, font)
    self:addChild(self.upButton)
    local anchor = anchor.new("SouthEast", 45, 5, 30,30)
    self.downButton = button.new(anchor, color, function()
        if self.parent:move(self,  1) then
            local target = self.parentIndex
            local index = target-1
            local layers = self.layer.map.layers
            local t = self.layer.map.layers[index]
            layers[index] = layers[target]
            layers[target] = t
            return true
        end
    end)
    
    self.downButton:setText("v", nil, font)
    self:addChild(self.downButton)
    
    return self
end

layerPreview.drawElement = function(self)
    local x,y, w,h = self.anchor:getRect()
    if self.layer.selected then
        lg.setColor(self.selectedColor)
    else
        lg.setColor(self.backgroundColor)
    end
    lg.rectangle("fill", x+10,y, w,h)
    lg.setColor(1,1,1)
    lg.print(self.layer.name, self.font, x+13, y)
    
    local startY = self.font:getHeight() + y
    local height = h - 40 - self.font:getHeight()
    local canvas = self.layer.canvas
    
    local cw, ch = canvas:getDimensions()
    
    local s = height / ch
    
    lg.draw(canvas, x+17, startY, 0, s,s)
end

local getTouch = function(touches, id)
    for k,v in ipairs(touches) do
        if v.id == id then return k,v end
    end
    return -1
end

layerPreview.touchpressedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    local x,y,w,h = self.anchor:getRect()
    if aabb(pressedX, pressedY, x+10,y,w-10,h) then
        insert(self.touches, {id=id, x=pressedX, y=pressedY})
        return true
    end
    return false
end

layerPreview.touchreleasedElement = function(self, id, pressedX, pressedY, dx, dy, pressure)
    local key = getTouch(self.touches, id)
    if key ~= -1 then
        local x,y,w,h = self.anchor:getRect()
        if aabb(pressedX, pressedY, x+10,y,w-10,h) then
            self.layer.map:selectLayer(self.layer)
            remove(self.touches, key)
            return true
        end
        remove(self.touches, key)
    end
    return false
end

return layerPreview