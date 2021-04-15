local ui = require("ui.base.ui")
local layerPreview = setmetatable({}, ui)
layerPreview.__index = layerPreview

local lg = love.graphics

local anchor = require("ui.base.anchor")

layerPreview.new = function(layer, width)
    local anchor = anchor.new("NorthWest", 0,0, width-20,width*0.75, 0,0)
    local self = setmetatable(ui.new(anchor), layerPreview)
    self.layer = layer
    return self
end

layerPreview.drawElement = function(self)
    local x,y, w,h = self.anchor:getRect()
    lg.setColor(.4,.4,.4)
    lg.rectangle("fill", x+10,y, w,h)
end

return layerPreview