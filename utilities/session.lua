local session = {}
session.__index = session

local lg = love.graphics

local list = require("utilities.list")

local insert, remove = table.insert, table.remove

session.new = function()
    local self = setmetatable({}, session)
    
    self.tilesets = list.new()
    self.static, self.animated, self.bitmask = 0, 0, 0
    
    return self
end

session.load = function()
    error("TODO")
end

--TODO copy to save dir
--TODO if failed to load
session.addTileset = function(self, path)
    for _, tileset in ipairs(self.tilesets.items) do
        if tileset.path == path then
            -- Reload image as the image may of changed
            tileset.image = lg.newImage(path)
            tileset.image:setFilter("nearest","nearest")
            tileset.image:setWrap("clampzero")
            return tileset
        end
    end
    
    local image = lg.newImage(path)
    image:setFilter("nearest","nearest")
    image:setWrap("clampzero")
    local tileset = {
        path = path,
        image = image,
        tiles = list.new(),
        id = os.time()
    }
    self.tilesets:add(tileset)
    return tileset
end

session.addTile = function(self, tileData, tileset)
    if not tileset.tiles:has(tileData) and not tileData.id then
        tileData.id = os.time()
        tileData.tilesetId = tileset.id
        tileset.tiles:add(tileData)
        
        self[tileData.type] = self[tileData.type] + 1
    else
        error("Already added tile")
    end
end

session.removeTile = function(self, tileData)
    local tileset = self.tilesets:get(tileData.tilesetId)
    tileset.tiles:remove(tileData)
    self[tileData.type] = self[tileData.type] - 1
end

session.getTile = function(self, id, tileset)
    return tileset.tiles:get(id)
end

session.getTileUnknownTileset = function(self, id)
    for _, tileset in ipairs(self.tilesets.items) do
        local tile = self:getTile(id, tileset)
        if tile then
            return tile
        end
    end
end

return session