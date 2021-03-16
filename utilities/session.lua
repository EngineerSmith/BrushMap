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
    for id, tileset in ipairs(self.tilesets) do
        if tileset.path == path then
            -- Reload image as the image may of changed
            tileset.image = lg.newImage(path)
            return id, tileset.image
        end
    end
    
    local image = lg.newImage(path)
    insert(self.tilesets, {
        path = path,
        image = image,
        tiles = {}
    })
    return #self.tilesets, image
end

session.addTile = function(self, tileData, tilesetId)
    if not self.tilesets[tilesetId] then
        error("Invalid tilesetId :"..tostring(tilesetId))
    end
    
    if not tileData.id then
        insert(self.tilesets[tilesetId].tiles, tileData)
        tileData.id = #self.tilesets[tilesetId].tiles
        tileData.tilesetId = tilesetId
    else
        error("Already added tile")
    end
end

session.removeTile = function(self, tileData)
    if not tileData.id and tileData.tilesetId then
        error("Tile not added")
    end
    
    remove(self.tilesets[tileData.tilesetId].tiles, tileData.id)
end

return session