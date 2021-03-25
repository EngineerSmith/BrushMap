local global = require("global")

local lg = love.graphics

local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local bitmaskPreview = require("ui.bitmaskPreview")
local numberSelect = require("ui.numberSelect")
local button = require("ui.button")
local togglebox = require("ui.togglebox")
local text = require("ui.text")

return function(font, controller, window)
local tabBitmask = tabWindow.new("Bitmask", font)

tabBitmask.newTileset = function(self, tileset)
    self.preview:setImage(tileset)
    tabBitmask:reset()
end

tabBitmask.setTile = function(self, tile)
    self.tile = tile
    window.tile = tile
    local active = tile ~= nil
    self.preview.active = active
    self.numberSelect.active = active
    self.toggle.active = active
    if active then
        self.toggle.selected = self.tile.directions == 8
    end
end

tabBitmask.reset = function(self)
   self.preview:reset()
   self.numberSelect:reset()
end

tabBitmask.setState = function(self, state, ...)
    if state == "edit" then
        self.change:setActive(#self.tile.tiles > 0)
        self.change:setText("Finished Tile")
        self.finish:setActive(select(1, ...))
        self.finish:setText("Delete Tile")
        window.updatePreview(-1,-1,-1,-1)
    elseif state == "new" then
        self:reset()
        self.change:setActive(global.editorSession.bitmask > 0)
        self.change:setText("Edit Tile")
        self.finish:setActive(true)
        self.finish:setText("Create Tile")
    end
end

tabBitmask.addTileToBit = function(self, tile)
    self.tile.tiles[self.numberSelect.index] = tile.id
    self.change:setActive(true)
    self:setTileToPreview(tile)
end

tabBitmask.setTileToPreview = function(self, tile)
    self.preview:resetQuads()
    if tile.type == "static" then
        local quad = lg.newQuad(tile.x, tile.y, tile.w, tile.h, self.preview.image:getDimensions())
        self.preview:addQuad(quad)
    elseif tile.type == "animated" then
        local iw, ih = self.preview.image:getDimensions()
        for _, tile in ipairs(tile.tiles) do
            local quad = lg.newQuad(tile.x, tile.y, tile.w, tile.h, iw, ih)
            self.preview:addQuad(quad, tile.time)
        end
    else
        error("You shouldn't reach here: tabBitmask.lua")
    end
end

tabBitmask.setPreviewToBit = function(self, bit)
    if window.tileset then
        local id = self.tile.tiles[bit]
        if id then
            local tile = global.editorSession:getTile(id, window.tileset)
            self:setTileToPreview(tile)
        else
            self.preview:resetQuads()
        end
    end
    return false
end

tabBitmask.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,-2, 20,0)
    self.preview = bitmaskPreview.new(anchor)
    self.preview:setBackgroundColor({0,0,0})
    self:addChild(self.preview)
    self.active = false
    
    local x,y,w,h = self.preview.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, w,w/3, 20,0)
    self.numberSelect = numberSelect.new(anchor, global.assets["font.robotoReg25"], 0, 255)
    self:addChild(self.numberSelect)
    
    self.preview.valueChangedCallback = function(_, sum)
        self.numberSelect.index = sum
    end
    
    self.numberSelect.indexedChangedCallback = function(_, index)
        self.preview:setActiveTiles(index)
        self:setPreviewToBit(index)
        return true
    end
    
    local x,y,w,h = self.numberSelect.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, -1,20, 20,0)
    local titleToggle = text.new(anchor, "Number of directions", font)
    local anchor = anchor.new("NorthWest", 10, 50+height)
    local text4 = text.new(anchor, "4", font)
    local anchor = anchor.new("NorthEast", 10, 50+height)
    local text8 = text.new(anchor, "8", font)
    local anchor = anchor.new("NorthWest", 30, 40+height, -1,40, 60,0)
    self.toggle = togglebox.new(anchor, true)
    self.toggle:setValueChangedCallback(function(_, selected)
        if self.tile then
            if not selected then
                self.preview:drawEvenDirectionsOnly(true)
                self.numberSelect.max = 15
                self.preview:setActiveTiles(15)
                self:setPreviewToBit(15)
                self.tile.directions = 4
            else
                self.preview:drawEvenDirectionsOnly(false)
                self.numberSelect.max = 255
                self.preview:setActiveTiles(255)
                self:setPreviewToBit(255)
                self.tile.directions = 8
            end
        end
    end)
    self:addChild(titleToggle)
    self:addChild(text4)
    self:addChild(text8)
    self:addChild(self.toggle)
    
    local anchor = anchor.new("NorthWest", 10,100+height, -1,40, 20,0)
    self.change = button.new(anchor, nil, function(_)
        if not window.tileset then
            return
        end
        if not window.bitmaskEditing then
            window.bitmaskEditing = true
            window.bitmaskEditPick = true
        -- Edit button pressed,
        -- Display bitmask tiles, wait for one to be selected
        -- Once selected, process bitmask tile and load into preview as changed
        -- Change lock tab, change buttons
            self:setState("edit", false)
        else
            window.bitmaskEditing = false
            window.bitmaskEditPick = false
            self:setState("new")
        end
        self:setTile(self.tile)
        controller:setLock(window.bitmaskEditing)
    end)
    self.change:setText("Edit Bitmask", nil, font)
    self:addChild(self.change, nil)
    self.change:setActive(false)
    
    local anchor = anchor.new("NorthWest", 10,150+height, -1,40, 20,0)
    self.finish = button.new(anchor, nil, function(_)
        if not window.tileset then
            return
        end
        if not window.bitmaskEditing then
            window.bitmaskEditing = true
            
            self.tile = {type="bitmask", tiles={}, directions=self.toggle.selected and 8 or 4}
            global.editorSession:addTile(self.tile, window.tileset)
            
            self:setState("edit", true)
        else
            window.bitmaskEditing = false
            
            global.editorSession:removeTile(self.tile)
            
            self.tile = nil
            self:setState("new")
        end
        self:setTile(self.tile)
        controller:setLock(window.bitmaskEditing)
    end)
    self.finish:setText("Create Bitmask", nil, font)
    self:addChild(self.finish, nil)
    
    self:setTile(nil)
end

return tabBitmask
end