local layer = {}
layer.__index = layer

local lg = love.graphics

local insert, remove = table.insert, table.remove

layer.new = function(w, h, name)
    local self = setmetatable({
        name = name,
        tileCount = 0,
        tiles = {},
        hash = {},
        w, h, x, y,
        canvas
    }, layer)
    self:resize(w, h)
    return self
end

local getHashId = function(x, y)
    return x .. ":" .. y
end

--[[ bit map
    128, 1, 16,
      8, 0,  2,
     64, 4, 32,     ]]
layer.addBitScore = function(self, x, y)
    local tiles = self.tiles
    local tileData = tiles[self.hash[getHashId(x, y)]].tileData
    local type = tileData.bitType
    local score = 0
    local N, E, S, W = false, false, false, false
    
    -- NORTH
    local id = self.hash[getHashId(x, y-1)]
    if id and tiles[id].tileData == tileData then
        score = score + 1
        tiles[id].score = tiles[id].score + 4
        N = true
    end
    -- EAST
    local id = self.hash[getHashId(x+1, y)]
    if id and tiles[id].tileData == tileData then
        score = score + 2
        tiles[id].score = tiles[id].score + 8
        E = true
    end
    -- SOUTH
    local id = self.hash[getHashId(x, y+1)]
    if id and tiles[id].tileData == tileData then
        score = score + 4
        tiles[id].score = tiles[id].score + 1
        S = true
    end
    -- WEST
    local id = self.hash[getHashId(x-1, y)]
    if id and tiles[id].tileData == tileData then
        score = score + 8
        tiles[id].score = tiles[id].score + 2
        W = true
    end
    if type == 15 then
        return score
    end
    -- NORTH EAST
    if type == 255 or (N and E) then
        local id = self.hash[getHashId(x+1, y-1)]
        if id and tiles[id].tileData == tileData then
            score = score + 16
            tiles[id].score = tiles[id].score + 64
        end
    end
    -- SOUTH EAST
    if type == 255 or (S and E) then
        local id = self.hash[getHashId(x+1, y+1)]
        if id and tiles[id].tileData == tileData then
            score = score + 32
            tiles[id].score = tiles[id].score + 128
        end
    end
    -- SOUTH WEST
    if type == 255 or (S and W) then
        local id = self.hash[getHashId(x-1, y+1)]
        if id and tiles[id].tileData == tileData then
            score = score + 64
            tiles[id].score = tiles[id].score + 16
        end
    end
    -- NORTH WEST
    if type == 255 or (N and W) then
        local id = self.hash[getHashId(x-1, y-1)]
        if id and tiles[id].tileData == tileData then
            score = score + 128
            tiles[id].score = tiles[id].score + 32
        end
    end
    return score
end

layer.removeBitScore = function(self, x, y, oldTileData)
    local tiles = self.tiles
    local type = oldTileData.bitType
    local N, E, S, W = false, false, false, false
    --NORTH
    local id = self.hash[getHashId(x, y-1)]
    if id and tiles[id].tileData == oldTileData then
        tiles[id].score = tiles[id].score - 4
        N = true
    end
    -- EAST
    local id = self.hash[getHashId(x+1, y)]
    if id and tiles[id].tileData == oldTileData then
        tiles[id].score = tiles[id].score - 8
        E = true
    end
    -- SOUTH
    local id = self.hash[getHashId(x, y+1)]
    if id and tiles[id].tileData == oldTileData then
        tiles[id].score = tiles[id].score - 1
        S = true
    end
    -- WEST
    local id = self.hash[getHashId(x-1, y)]
    if id and tiles[id].tileData == oldTileData then
        tiles[id].score = tiles[id].score - 2
        W = true
    end
    if type == 15 then
        return
    end
    -- NORTH EAST
    if type == 255 or (N and E) then
        local id = self.hash[getHashId(x+1, y-1)]
        if id and tiles[id].tileData == oldTileData then
            tiles[id].score = tiles[id].score - 64
        end
    end
    -- SOUTH EAST
    if type == 255 or (S and E) then
        local id = self.hash[getHashId(x+1, y+1)]
        if id and tiles[id].tileData == oldTileData then
            tiles[id].score = tiles[id].score - 128
        end
    end
    -- SOUTH WEST
    if type == 255 or (S and W) then
        local id = self.hash[getHashId(x-1, y+1)]
        if id and tiles[id].tileData == oldTileData then
            tiles[id].score = tiles[id].score - 16
        end
    end
    -- NORTH EAST
    if type == 255 or (N and E) then
        local id = self.hash[getHashId(x-1, y-1)]
        if id and tiles[id].tileData == oldTileData then
            tiles[id].score = tiles[id].score - 32
        end
    end
end

layer.setTile = function(self, x, y, tileData, tags)
    local id = getHashId(x, y)
    local index = self.hash[id]
    local tile
    if index ~= nil then
        tile = self.tiles[index]
        if tile.tileData.type == "bitmask" then
            self:removeBitScore(x, y, tile.tileData)
        end
        tile.tileData = tileData
        tile.tags = tags or {}
        if tile.tileData.type == "bitmask" then
            self:addBitScore(x, y)
        end
    else
        local index = self.tileCount + 1
        tile = {
            id = id,
            x = x,
            y = y,
            tileData = tileData,
            tags = tags or {},
            score = 0,
        }
        self.tiles[index] = tile
        self.hash[id] = index
        
        self.tileCount = index
        if tileData.type == "bitmask" then
            tile.score = self:addBitScore(x, y)
        end
    end
    return tile
end

layer.removeTile = function(self, x, y)
    local id = getHashId(x, y)
    local index = self.hash[id]
    if index then
        local tile = self.tiles[index]
        if tile.tileData.type == "bitmask" then
            self:removeBitScore(x, y, tile.tileData)
        end
        self.tiles[index] =nil
        self.hash[id] = nil
    end
end

layer.getTile = function(self, x, y)
    local index = self.hash[getHashId(x, y)]
    return index and self.tiles[index] or nil
end

layer.resize = function(self, w, h)
    if self.w ~= w or self.h ~= h then
        self.w, self.h = w, h
        self.canvas = lg.newCanvas(w, h)
    end
end

layer.draw = function(self, tilesize, x, y, scale)
    self.x, self.y = x, y
    lg.setCanvas(self.canvas)
    lg.clear(0,0,0,0)
    lg.push()
    lg.origin()
    lg.translate(x, y)
    lg.setColor(1,1,1)
    for _, tile in ipairs(self.tiles) do
        lg.push()
        lg.scale(scale, scale)
        lg.translate(tile.x * tilesize, tile.y * tilesize)
        tile.tileData:draw(tile.score)
        lg.pop()
    end
    lg.pop()
    lg.setCanvas()
end

return layer