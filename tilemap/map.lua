local map = {}
map.__index = map

local layer = require("tilemap.layer")

local lg = love.graphics
local insert = table.insert

map.new = function(tilesize)
    local self = setmetatable({
        tilesize = tilesize or 16,
        layers = {},
        activeLayer = nil
    }, map)
    return self
end

map.newLayer = function(self, name)
    local _,_,w,h = love.window.getSafeArea()
    local layer = layer.new(w, h, name)
    insert(self.layers, layer)
    self.activeLayer = layer
    self.activeLayer.selected = true
    layer.map = self
    return layer
end

map.selectLayer = function(self, layer)
    for _, v in ipairs(self.layers) do
        v.selected = false
    end
    self.activeLayer = layer
    layer.selected = true
end

map.draw = function(self, x, y)
    for _, layer in ipairs(self.layers) do
        layer:draw(self.tilesize, x, y)
        lg.draw(layer.canvas)
    end
end

map.resize = function(self, w, h)
    for _, layer in ipairs(self.layers) do
        layer:resize(w, h)
    end
end

return map