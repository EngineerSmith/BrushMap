local ui = require("ui.base.ui")
local tilePreviewGrid = setmetatable({}, ui)
tilePreviewGrid.__index = tilePreviewGrid

local lg = love.graphics
local floor = math.floor

tilePreviewGrid.new = function(anchor, tilesets, font)
    local self = setmetatable(ui.new(anchor), tilePreviewGrid)
    self.tilesets = tilesets
    self.font = font
    return self
end

local tileSize = 40

tilePreviewGrid.drawElement = function(self)
    local x,y,w,h = self.anchor:getRect()
    local row = floor(w / tileSize)
    lg.push()
    for i, tileset in ipairs(self.tilesets.items) do
        lg.setColor(.7,.7,.7)
        lg.print(tileset.name, self.font, x, y)
        lg.translate(0, self.font:getHeight())
        lg.setColor(1,1,1)
        for j, tile in ipairs(tileset.tiles.items) do
            j = j -1
            if j ~= 0 and j % row == 0 then
                lg.translate(0, tileSize + 5)
            end
            if tile.type == "static" then
                local sw = tileSize / tile.w
                local sh = tileSize / tile.h
                lg.draw(tileset.image, tile.quad, (j % row)*(tileSize+5)+ x, y, 0, sw, sh)
            end
        end
        lg.translate(0, tileSize+5)
    end
    lg.pop()
end

return tilePreviewGrid