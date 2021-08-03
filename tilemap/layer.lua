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


local scoreTile = function(score, tile, tileData, left, right)
    if tile and tile.tileData == tileData then
        tile.score = tile.score + right
       return true, score + left
    end
    return false, score
end

--[[ bit map
    128, 1, 16,
      8, 0,  2,
     64, 4, 32,     ]]
layer.addBitScore = function(self, x, y)
    local tiles = self.tiles
    local tileData = self:getTile(x, y).tileData
    local score = 0
    local N, E, S, W = false, false, false, false
    
    -- NORTH
    N, score = scoreTile(score, self:getTile(x, y-1), tileData, 1, 4)
    -- EAST
    E, score = scoreTile(score, self:getTile(x+1, y), tileData, 2, 8)
    -- SOUTH
    S, score = scoreTile(score, self:getTile(x, y+1), tileData, 4, 1)
    -- WEST
    W, score = scoreTile(score, self:getTile(x-1, y), tileData, 8, 2)
    
    local type = tileData.bitType
    if type == 15 then
        return score
    end
    local type47 = type == 47
    -- NORTH EAST
    if type == 255 or (type47 and N and E) then
        _, score = scoreTile(score, self:getTile(x+1, y-1), tileData, 16, 64)
    end
    -- SOUTH EAST
    if type == 255 or (type47 and S and E) then
        _, score = scoreTile(score, self:getTile(x+1, y+1), tileData, 32, 128)
    end
    -- SOUTH WEST
    if type == 255 or (type47 and S and W) then
        _, score = scoreTile(score, self:getTile(x-1, y+1), tileData, 64, 16)
    end
    -- NORTH WEST
    if type == 255 or (type47 and N and W) then
        _, score = scoreTile(score, self:getTile(x-1, y-1), tileData, 128, 32)
    end
    
    return score
end

layer.removeBitScore = function(self, x, y, oldTileData)
    local tiles, _ = self.tiles, 0
    local N, E, S, W = false, false, false, false
    --NORTH
    N, _ = scoreTile(_, self:getTile(x, y-1), oldTileData, _, -4)
    -- EAST
    E, _ = scoreTile(_, self:getTile(x+1, y), oldTileData, _, -8)
    -- SOUTH
    S, _ = scoreTile(_, self:getTile(x, y+1), oldTileData, _, -1)
    -- WEST
    W, _ = scoreTile(_, self:getTile(x-1, y), oldTileData, _, -2)
    
    local type = oldTileData.bitType
    if type == 15 then
        return
    end
    local type47 = type == 47
    -- NORTH EAST
    if type == 255 or (type47 and N and E) then
        scoreTile(_, self:getTile(x+1, y-1), oldTileData, _, -64)
    end
    -- SOUTH EAST
    if type == 255 or (type47 and S and E) then
        scoreTile(_, self:getTile(x+1, y+1), oldTileData, _, -128)
    end
    -- SOUTH WEST
    if type == 255 or (type47 and S and W) then
        scoreTile(_, self:getTile(x-1, y+1), oldTileData, _, -16)
    end
    -- NORTH EAST
    if type == 255 or (type47 and N and E) then
        scoreTile(_, self:getTile(x-1, y-1), oldTileData, _, -32)
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