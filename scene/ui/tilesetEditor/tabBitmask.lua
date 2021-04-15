local global = require("global")

local lg = love.graphics

local tileBitmask = require("tilemap/tileBitmask")

local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local bitmaskPreview = require("ui.bitmaskPreview")
local numberSelect = require("ui.numberSelect")
local button = require("ui.button")
local checkbox = require("ui.checkbox")
local text = require("ui.text")

return function(font, controller, window)
local tabBitmask = tabWindow.new("Bitmask", font, controller)

tabBitmask.newTileset = function(self, tileset)
    self.preview:setImage(tileset)
    tabBitmask:reset()
end

tabBitmask.getBitType = function(self)
    if self.check16.selected then
        return 15
    elseif self.check48.selected then
        return 47
    elseif self.check256.selected then
        return 255
    end
    error("Shouldn't hit here: tabBitmask.\nAll checkboxes are false")
end

tabBitmask.setTile = function(self, tile)
    self.tile = tile
    window.tile = tile
    local active = tile ~= nil
    self.preview.active = active
    self.numberSelect.active = active
    self.check16.active = active
    self.check48.active = active
    self.check256.active = active
    self.preview:setActiveTiles(0)
    self:setPreviewToBit(0)
    if active then
        if tile.bitType == 15 then
            self.check16.selected = true
            self.check48.selected = false
            self.check256.selected = false
        elseif tile.bitType == 47 then
            self.check16.selected = false
            self.check48.selected = true
            self.check256.selected = false
        elseif tile.bitType == 255 then
            self.check16.selected = false
            self.check48.selected = false
            self.check256.selected = true
        end
    end
end

tabBitmask.reset = function(self)
   self.preview:reset()
   self.numberSelect:reset()
end

tabBitmask.setState = function(self, state, ...)
    if state == "edit" then
        self.change:setActive(self.tile and #self.tile.tiles > 0 or true)
        self.change:setText("Finished Tile")
        self.finish:setActive(select(1, ...))
        self.finish:setText("Delete Tile")
    elseif state == "new" then
        self:reset()
        self.change:setActive(global.editorSession.bitmask > 0)
        self.change:setText("Edit Tile")
        self.finish:setActive(true)
        self.finish:setText("Create Tile")
        window.updatePreview(-1,-1,-1,-1)
    end
end

tabBitmask.addTileToBit = function(self, tile)
    self.tile.tiles[self.numberSelect:getValue()] = tile
    self.change:setActive(true)
    self:setTileToPreview(tile)
end

tabBitmask.setTileToPreview = function(self, tile)
    self.preview:resetQuads()
    local p = window.preview
    if tile then
        if tile.type == "static" then
            self.preview:addQuad(tile.quad)
            p.x, p.y, p.width, p.height = tile.x, tile.y, tile.w, tile.h
        elseif tile.type == "animated" then
            for _, tile in ipairs(tile.quads) do
                self.preview:addQuad(tile.quad, tile.time)
            end
            local quad1 = tile.quads[1]
            p.x, p.y, p.width, p.height = quad1.x, quad1.y, quad1.w, quad1.h
        else
            error("You shouldn't reach here: tabBitmask.lua")
        end
    end
end

tabBitmask.setPreviewToBit = function(self, bit)
    if window.tileset and self.tile and self.tile.tiles[bit] then
        self:setTileToPreview(self.tile.tiles[bit])
    else
        self.preview:resetQuads()
        local p = window.preview
        p.x, p.y, p.width, p.height = -1, -1, -1, -1
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
        if not self.numberSelect:setIndex(sum) then
            self.preview.negative = true
        else
            self.preview.negative = false
        end
        self:setPreviewToBit(sum)
    end
    
    self.numberSelect.indexedChangedCallback = function(_, index, value)
        self.preview:setActiveTiles(value or index)
        return true
    end
    
    local x,y,w,h = self.numberSelect.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, -1,20, 20,0)
    local titleToggle = text.new(anchor, "Number of Tiles", font)
    self:addChild(titleToggle)
    local anchor = anchor.new("NorthWest", 10, 45+height)
    local text16 = text.new(anchor, "16", font)
    self:addChild(text16)
    local anchor = anchor.new("NorthWest", 35, 40+height, 30,30)
    self.check16 = checkbox.new(anchor, false)
    self.check16:setValueChangedCallback(function(_, selected)
        if selected then
            self.preview:drawEvenDirectionsOnly(true)
            self.numberSelect:setList(nil)
            self.numberSelect.max = 15
            self.preview:setActiveTiles(15)
            self:setPreviewToBit(15)
            self.tile.bitType = 15
        end
    end)
    self:addChild(self.check16)
    local anchor = anchor.new("NorthWest", 72, 45+height)
    local text48 = text.new(anchor, "48", font)
    self:addChild(text48)
    local anchor = anchor.new("NorthWest", 97, 40+height, 30,30)
    self.check48 = checkbox.new(anchor, false)
    self.check48:setValueChangedCallback(function(_, selected)
        if selected then
            self.preview:drawEvenDirectionsOnly(false)
            self.numberSelect:setList(tileBitmask.directions48)
            self.preview:setActiveTiles(255)
            self:setPreviewToBit(255)
            self.tile.bitType = 47
        end
    end)
    self.check16:addOwnership(self.check48)
    self:addChild(self.check48)
    local anchor = anchor.new("NorthWest", 134, 45+height)
    local text256 = text.new(anchor, "256", font)
    self:addChild(text256)
    local anchor = anchor.new("NorthWest", 169, 40+height, 30,30)
    self.check256 = checkbox.new(anchor, true)
    self.check256:setValueChangedCallback(function(_, selected)
        if selected then
            self.preview:drawEvenDirectionsOnly(false)
            self.numberSelect:setList(nil)
            self.numberSelect.max = 255
            self.preview:setActiveTiles(255)
            self:setPreviewToBit(255)
            if self.tile then
                self.tile.bitType = 255
            end
        end
    end)
    self.check16:addOwnership(self.check256)
    self:addChild(self.check256)
    
    local anchor = anchor.new("NorthWest", 10,80+height, -1,40, 20,0)
    self.change = button.new(anchor, nil, function(_)
        if not window.tileset then
            return
        end
        if not window.bitmaskEditing then
            window.bitmaskEditing = true
            window.bitmaskEditPick = true
            self:setState("edit", false)
        else
            window.bitmaskEditing = false
            window.bitmaskEditPick = false
            self.tile = nil
            self:setState("new")
        end
        self:setTile(self.tile)
        controller:setLock(window.bitmaskEditing)
    end)
    self.change:setText("Edit Bitmask", nil, font)
    self:addChild(self.change, nil)
    self.change:setActive(false)
    
    local anchor = anchor.new("NorthWest", 10,130+height, -1,40, 20,0)
    self.finish = button.new(anchor, nil, function(_)
        if not window.tileset then
            return
        end
        if not window.bitmaskEditing then
            window.bitmaskEditing = true
            
            self.tile = tileBitmask.new({}, self:getBitType())
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