local tile = require("tilemap.tile")
local tileAnimated = setmetatable({}, tile)
tileAnimated.__index = tileAnimated

local lg = love.graphics

tileAnimated.new = function(tileset, quads)
    tileset = tileset or error("Tileset requied")
    local self = setmetatable(tile.new("animated", tileset), tileAnimated)
    self:setQuads(quads)
    return self
end

tileAnimated.setQuads = function(self, quads)
    self.quads = quads or error("Animated tile requires tiles")
    self.currentTime = 0
    self.index = 1
    
    for _, quad in ipairs(self.quads) do
        quad.quad = lg.newQuad(quad.x, quad.y, quad.w, quad.h, self.tileset.image:getDimensions())
    end
end

tileAnimated.update = function(self, dt)
    self.currentTime = self.currentTime + dt
    while self.currentTime >= self.quads[self.index].time do
        self.currentTime = self.currentTime - self.quads[self.index].time
        self.index = self.index + 1
        if self.index > #self.quads then
            self.indx = 1
        end
    end
end

tileAnimated.draw = function(self)
    lg.draw(self.tileset.image, self.quads[self.index].quad) 
end

return tileAnimated