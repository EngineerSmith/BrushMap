local ui = require("ui.base.ui")
local layerPreview = setmetatable({}, ui)
layerPreview.__index = layerPreview

local lg = love.graphics

local anchor = require("ui.base.anchor")
local button = require("ui.button")

local color = {.3,.3,.3}

layerPreview.new = function(layer, width, font)
    local anchor = anchor.new("NorthWest", 0,0, width-20,width*0.75, 0,0)
    local self = setmetatable(ui.new(anchor), layerPreview)
    self.layer = layer
    self.font = font
    
    local anchor = anchor.new("SouthWest", 15,5, 30,30)
    self.trash = button.new(anchor, color, function()
        
    end)
    self.trash:setText("T", nil, font)
    self:addChild(self.trash)
    
    local anchor = anchor.new("SouthEast", 5, 5, 30,30)
    self.upButton = button.new(anchor, color, function()
        
    end)
    self.upButton:setText("^", nil, font)
    self:addChild(self.upButton)
    
    local anchor = anchor.new("SouthEast", 45, 5, 30,30)
    self.downButton = button.new(anchor, color, function()
        
    end)
    self.downButton:setText("v", nil, font)
    self:addChild(self.downButton)
    
    return self
end

layerPreview.drawElement = function(self)
    local x,y, w,h = self.anchor:getRect()
    lg.setColor(.4,.4,.4)
    lg.rectangle("fill", x+10,y, w,h)
    lg.setColor(1,1,1)
    lg.print(self.layer.name, self.font, x+13, y)
end

return layerPreview