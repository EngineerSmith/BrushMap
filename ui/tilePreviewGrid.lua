local ui = require("ui.base.ui")
local tilePreviewGrid = setmetatable({}, ui)
tilePreviewGrid.__index = tilePreviewGrid

local lg = love.graphics
local floor = math.floor
local aabb = require("utilities.aabb")

tilePreviewGrid.new = function(anchor, tilesets, font)
    local self = setmetatable(ui.new(anchor), tilePreviewGrid)
    self.tilesets = tilesets
    self.font = font
    return self
end

local tileSize = 42
local tileSizeWithSpacing = tileSize + 5

tilePreviewGrid.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    local row = floor(w / tileSize)
    lg.push()
    lg.translate(x, y)
    for i, tileset in ipairs(self.tilesets.items) do
        lg.setColor(.7,.7,.7)
        lg.print(tileset.name, self.font)
        lg.translate(0, self.font:getHeight() + 2)
        for j, tile in ipairs(tileset.tiles.items) do
            j = j -1
            if j ~= 0 and j % row == 0 then
                lg.translate(0, tileSizeWithSpacing)
            end
            lg.setColor(.8,.8,.8)
            lg.rectangle("fill", (j % row)*tileSizeWithSpacing, 0, tileSize, tileSize)
            lg.setColor(1,1,1)
            if tile.type == "static" then
                local sw = tileSize / tile.w
                local sh = tileSize / tile.h
                lg.draw(tileset.image, tile.quad, (j % row)*tileSizeWithSpacing,0, 0, sw, sh)
            elseif tile.type == "animated" then
                local w, h = tile:getSize()
                local sw = tileSize / w
                local sh = tileSize / h
                tile:draw((j % row)*tileSizeWithSpacing,0, 0, sw, sh)
            end
        end
        lg.translate(0, tileSizeWithSpacing)
    end
    lg.pop()
end

local getTouch = function(touches, id)
    for k,v in ipairs(touches) do
        if v.id == id then return k,v end
    end
    return -1
end

tilePreviewGrid.touchpressedElement = function(self, id, pressedX, pressedY, ...)
    if aabb(pressedX, pressedY, self.anchor:getRect()) then
    
        local x,y,w,h = self.anchor:getRect()
        local row = floor(w / tileSize)
        
        pressedX = pressedX - x 
        pressedY = pressedY - y
        if pressedX < 0 or pressedY < 0 or pressedX > w then
            return false
        end
        for i, tileset in ipairs(self.tilesets.items) do
            pressedY = pressedY - (self.font:getHeight() + 2)
            if pressedY < 0 then
                return false
            end
            
            local itemCount = #tileset.tiles.items
            local rowCount = math.ceil(itemCount / row)
            if pressedY - (tileSizeWithSpacing*rowCount) < 0 then
                for j, tile in ipairs(tileset.tiles.items) do
                    j = j - 1
                    if j ~= 0 and j % row == 0 then
                        pressedY = pressedY - tileSizeWithSpacing
                    end
                    if pressedY > 0 and pressedY <= tileSizeWithSpacing then
                        local x = pressedX - ((j % row)*tileSizeWithSpacing)
                        
                        if x > 0 and x <= tileSizeWithSpacing then
                            str2 = "ID: " .. tile.id
                            str2 = string.format(str2 .. "\n %.2f:%.2f", x, pressedY)
                            return true
                        end
                    end
                end
            end
            pressedY = pressedY - tileSizeWithSpacing*2
        end
    
        --insert(self.touches, {id=id, x=pressedX, y=pressedY})
        str2 = string.format("Hit 4\n %.2f : %.2f", pressedX ,pressedY)
        return false
    end
    str2 = string.format("Hit 3 \n %.1f:%.1f, %.0f:%.0f %.0f:%.0f", pressedX, pressedY, self.anchor:getRect())
    return false
end

tilePreviewGrid.touchreleasedElement = function(self, id, pressedX, pressedY, ...)
    --[[local key = getTouch(self.touches, id)
    if key ~= -1 then
        if self.active and aabb(pressedX, pressedY, self.anchor:getRect()) then
            local result = self:callbackReleased()
            remove(self.touches, key)
            return result ~= nil and result or true
        end
        remove(self.touches, key)
    end
    return false]]
end

return tilePreviewGrid