local tileStatic = setmetatable({}, tile)
tileStatic.__index = tileStatic

local lg = love.graphics

tileStatic.new = function(tileset, x, y, w, h)
    tileset = tileset or error("Tileset requied")
    local self = setmetatable(tile.new("static", tileset), tileStatic)
    self:setQuad(x, y, w, h)
    return self
end

tileStatic.setQuad = function(self, x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    
    self.quad = lg.newQuad(x, y, w, h, self.tileset.image:getDimensions())
end

tileStatic.draw = function(self)
    lg.draw(self.tileset.image, self.quad)
end

return tileStatic