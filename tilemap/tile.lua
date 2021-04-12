local tile = {}
tile.__index = tile

local validTypes = {
    ["static"] = true,
    ["animated"] = true,
    ["bitmask"] = true
}

tile.new = function(type, tileset)
    if not validTypes[type] then
        error("Invalid tile type: "..tostring(type))
    end
    return setmetatable({
        id = -1,
        type = type,
        tileset = tileset,
        tilesetId = tileset and -1 or tileset.id
    }, tile)
end

tile.update = function(self, dt) end

tile.draw = function(self) end

return tile