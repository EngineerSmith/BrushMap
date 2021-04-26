local map = {}
map.__index = map

local layer = require("tilemap.layer")

local lg = love.graphics
local insert = table.insert

map.new = function(tilesize)
    local self = setmetatable({
        tilesize = tilesize or 16,
        layers = {}
    }, map)
    return self
end

map.newLayer = function(self, name)
    local _,_,w,h = love.window.getSafeArea()
    local layer = layer.new(w, h, name)
    insert(self.layers, layer)
    return layer
end

map.draw = function(self, x, y)
    for _, layer in ipairs(self.layers) do
        layer:draw(self.tileset, x, y)
        lg.draw(layer.canvas)
    end
end

map.resize = function(self, w, h)
    for _, layer in ipairs(self.layers) do
        layer:resize(w, h)
    end
end

return map