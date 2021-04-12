local tile = require("tilemap.tile")
local tileBitmask = setmetatable({}, tile)
tileBitmask.__index = tileBitmask

local lg = love.graphics

local validTypes = {
    [15] = true, [47] = true, [255] = true
}

--[[ bit map
    128, 1, 16,
      8, 0,  2,
     64, 4, 32,
]]

tileBitmask.directions48 = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 19, 23, 27, 31, 38, 39, 46, 47, 55, 63, 76, 77, 78, 79, 95, 110, 111, 127, 137, 139, 141, 143, 155, 159, 175, 191, 205, 207, 223, 239, 255
}

tileBitmask.validDirections48 = {}
for _, bit in ipairs(tileBitmask.directions48) do
    tileBitmask.directions48Valid[bit] = true
end

tileBitmask.new = function(tiles, bitType)
    local self = setmetatable(tile.new("bitmask"), tileBitmask)
    self:setTiles(tiles)
    if not validTypes[bitType] then
        error("Invalid bitType")
    end
    self.bitType = bitType
    return self
end

tileBitmask.getIteratorCount = function(self)
    return self.bitType == 15 and 15 or 255
end

tileBitmask.setTiles = function(self, tiles)
    self.tiles = tiles or error("Bitmask tile requires tiles")
end

tileBitmask.draw = function(self, bit)
    if bit < 0 then
        error("Bit given less than 0: "..tostring(bit))
    end
    if self.bitType == 15 then
        if bit > 15 then error("Bit given greater than 15: "..tostring(bit)) end
    elseif self.bitType == 47 then
        if not tileBitmask.validDirections48[bit] then 
            error("Bit given not valid for 48 directions bitmask")
        end
    elseif self.bitType == 255 then
        if bit > 255 then error("Bit given greater than 255: "..tostring(bit)) end
    end
    
    self.tiles[bit]:draw()
end

return tileBitmask