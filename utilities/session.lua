local session = {}
session.__index = session

local lg = love.graphics

local insert, remove = table.insert, table.remove

session.new = function()
    local self = setmetatable({}, session)
    
    self.tilesets = {}
    self.tiles = {}
    
    return self
end

session.load = function()
    error("TODO")
end

--TODO copy to save dir
--TODO if failed to load
session.addTileset = function(self, path)
    for _, tileset in ipairs(self.tilesets) do
        if tileset.path == path then
            -- Reload image as the image may of changed
            tileset.image = lg.newImage(path)
            return tileset
        end
    end
    
    local image = lg.newImage(path)
    local tileset = {
        path = path,
        image = image,
        tiles = {},
        id = os.time()
    }
    insert(self.tilesets, tileset)
    return tileset
end

session.getTileset = function(self, id)
    for _, tileset in ipairs(self.tilesets) do
        if tileset.id == id then
            return tileset
        end
    end
    return nil
end

session.addTile = function(self, tileData, tileset)
    if not tileData.id then
        insert(tileset.tiles, tileData)
        tileData.id = os.time()
        tileData.tilesetId = tileset.id
    else
        error("Already added tile")
    end
end

session.removeTile = function(self, tileData)
    if not tileData.id and tileData.tilesetId then
        error("Tile not added")
    end
    local tileset = self:getTileset(tileData.tilesetId)
    for key, tile in ipairs(tileset.tiles) do
        if tile == tileData then
            remove(tileset.tiles, key)
            break
        end
    end
end

return session