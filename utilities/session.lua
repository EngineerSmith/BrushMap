local session = {}
session.__index = session

local lg = love.graphics

local insert = table.insert

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
session.addTileset = function(self, path)
    for _, tileset in ipairs(self.tilesets) do
        if tileset.path == path then
            -- Reload image as the image may of changed
            tileset.image = lg.newImage(path)
            return tileset.image
        end
    end
    --TODO if failed to load
    
    local image = lg.newImage(path)
    insert(self.tilesets, {
        path = path,
        image = image
    })
    return image
end

--TODO check if already existing
session.addTile = function(self, tileData, tilesetImage)
    if not tileData.tileset then
        for key, tileset in ipairs(self.tilesets) do
            if tileset.image == tilesetImage then
                tileData.tileset = key
                insert(self.tiles, tileData)
            end
        end
    else
        insert(self.tiles, tileData)
    end
end

return session