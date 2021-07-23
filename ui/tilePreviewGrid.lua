local ui = require("ui.base.ui")
local tilePreviewGrid = setmetatable({}, ui)
tilePreviewGrid.__index = tilePreviewGrid

local lg = love.graphics
local insert, remove = table.insert, table.remove
local floor = math.floor
local aabb, inbetween = require("utilities.aabb"), require("utilities.inbetween")

tilePreviewGrid.new = function(anchor, tilesets, font)
    local self = setmetatable(ui.new(anchor), tilePreviewGrid)
    self.tilesets = tilesets
    self.font = font
    self.touches = {}
    self.scrollY = 0
    self.scrollLimit = 0
    self.maskFunction = maskFunction or function()
        local x,y, width,height = self.anchor:getRect()
        lg.rectangle("fill", x,y, width,height)
    end
    return self
end

tilePreviewGrid.updateElement = function(self, dt)
    for _, touch in ipairs(self.touches) do
        local _, dy = self:updateTouch(touch)
        
        local yLimit = self.anchor.rect[4] - self.scrollLimit
        if yLimit < 0 then
            self.scrollY = inbetween(self.scrollY + dy, 0, yLimit)
        end
    end
end

local tileSize = 42
local tileSizeWithSpacing = tileSize + 5

tilePreviewGrid.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    local row = floor(w / tileSize)
    lg.setColor(1,1,1)
    lg.stencil(self.maskFunction, "replace", "1")
    lg.setStencilTest("greater", 0)
    lg.push()
    lg.translate(x, y + self.scrollY)
    self.scrollLimit = 0
    lg.setColor(1,1,1)
    for i, tileset in ipairs(self.tilesets.items) do
        lg.setColor(.7,.7,.7)
        lg.print(tileset.name, self.font)
        lg.translate(0, self.font:getHeight() + 2)
        self.scrollLimit = self.scrollLimit + self.font:getHeight() + 2
        for j, tile in ipairs(tileset.tiles.items) do
            j = j -1
            if j ~= 0 and j % row == 0 then
                lg.translate(0, tileSizeWithSpacing)
                self.scrollLimit = self.scrollLimit + tileSizeWithSpacing
            end
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
            lg.rectangle("line", (j % row)*tileSizeWithSpacing, 0, tileSize, tileSize)
        end
        lg.translate(0, tileSizeWithSpacing)
        self.scrollLimit = self.scrollLimit + tileSizeWithSpacing
    end
    lg.pop()
    lg.setStencilTest()
    self.scrollLimit = self.scrollLimit + tileSizeWithSpacing * 2.5
end

local getTouch = function(touches, id)
    for k,v in ipairs(touches) do
        if v.id == id then return k,v end
    end
    return -1
end

tilePreviewGrid.updateTouch = function(self, touch)
    local lastX, lastY = touch.x, touch.y
    local dx,dy = 0,0
    for k, move in ipairs(touch.moved) do
        dx = dx + (move.x - lastX)
        dy = dy + (move.y - lastY)
        lastX, lastY = move.x, move.y
        touch.moved[k] = nil
    end
    touch.x = lastX
    touch.y = lastY
    return dx, dy
end

tilePreviewGrid.touchpressedElement = function(self, id, pressedX, pressedY, ...)
    if aabb(pressedX, pressedY, self.anchor:getRect()) then
        insert(self.touches, {id=id, x=pressedX, y=pressedY, time=love.timer.getTime(), moved={}})
        return false
    end
    return false
end

tilePreviewGrid.touchmovedElement = function(self, id, x, y, ...)
    local key, touch = getTouch(self.touches, id)
    if key ~= -1 then
        local time = love.timer.getTime() - touch.time
        if time > 0.1 then
            insert(touch.moved, {x=x, y=y})
        end
    end
end

tilePreviewGrid.touchreleasedElement = function(self, id, pressedX, pressedY, ...)
    local key, touch = getTouch(self.touches, id)
    if key ~= -1 then
        if aabb(pressedX, pressedY, self.anchor:getRect()) then
            local x,y,w,h = self.anchor:getRect()
            remove(self.touches, key)
            
            local time = love.timer.getTime() - touch.time
            if time < 0.2 then -- Find tile 
                local row = floor(w / tileSize)
                
                pressedX = pressedX - x 
                pressedY = pressedY - y - self.scrollY
                
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
                    pressedY = pressedY - tileSizeWithSpacing
                end
            end
            return true
        end
        remove(self.touches, key)
        return false
    end
    return false
end

return tilePreviewGrid