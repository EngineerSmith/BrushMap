local global = require("global")

local lg = love.graphics

local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local image = require("ui.image")
local text = require("ui.text")
local numericInput = require("ui.numericInput")
local button = require("ui.button")

local maxNum = 9999

return function(font, controller, window)
local tabStatic = tabWindow.new("Static", font)

tabStatic.newTileset = function(self, tileset)
    self.preview:setImage(tileset)
    self:updateLimits(tileset:getDimensions())
end

tabStatic.setState = function(self, state)
    if state == "edit" then
        self.create:setText("Edit Tile")
        self.create:setActive(true)
        self.delete:setActive(true) 
    elseif state == "new" then
        self.create:setText("Create Tile")
        self.create:setActive(true)
        self.delete:setActive(false)
    elseif state == "deactive" then
        self.create:setActive(false)
        self.delete:setActive(false)
    end
end

tabStatic.updateLimits = function(self, maxW, maxH)
    self.w:updateValue(nil,nil, maxW)
    self.h:updateValue(nil,nil, maxH)
end

tabStatic.updatePreview = function(self, x, y, w, h)
    if self.preview.image then
        self.preview:setQuad(lg.newQuad(x,y, w,h, self.preview.image:getDimensions()))
    end
end

tabStatic.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,-2, 20,0)
    self.preview = image.new(anchor)
    self.preview:setBackgroundColor({0,0,0})
    self:addChild(self.preview)
    
    local rect = self.preview.anchor.rect
    local height = rect[2] + rect[4]
    
    local anchor = anchor.new("NorthWest", 10,20+height, 20,40)
    local textX = text.new(anchor, "X", font)
    local anchor = anchor.new("NorthWest", 30,10+height, -1,40, 40,0)
    self.x = numericInput.new(anchor, 0, maxNum, 0, font)
    self.x:setValueChangedCallback(function(_, value)
        if window.tileset and value + window.preview.width > window.tileset.image:getWidth() then
            return false
        end
        window.preview.x = value
        self:updatePreview(window.preview:getRect())
        return true
    end)
    self:addChild(textX)
    self:addChild(self.x)
    
    local anchor = anchor.new("NorthWest", 10,70+height, 20,40)
    local textY = text.new(anchor, "Y", font)
    local anchor = anchor.new("NorthWest", 30,60+height, -1,40, 40,0)
    self.y = numericInput.new(anchor, 0, maxNum, 0, font)
    self.y:setValueChangedCallback(function(_, value)
        if window.tileset and value + window.preview.height > window.tileset.image:getHeight() then
            return false
        end
        window.preview.y = value
        self:updatePreview(window.preview:getRect())
        return true
    end)
    self:addChild(textY)
    self:addChild(self.y)
    
    local anchor = anchor.new("NorthWest", 8,122+height, 20,40)
    local textW = text.new(anchor, "W", font)
    local anchor = anchor.new("NorthWest", 30,110+height, -1,40, 40,0)
    self.w = numericInput.new(anchor, 4, maxNum, 4, font)
    self.w:setValueChangedCallback(function(_, value)
        if window.tileset and window.preview.x + value > window.tileset.image:getWidth() then
            if window.preview.x - 1 >= self.x.min then
                window.preview.x = window.preview.x - 1
                self.x:updateValue(window.preview.x)
            end
        end
        window.preview.width = value
        self:updatePreview(window.preview:getRect())
        return true
    end)
    self:addChild(textW)
    self:addChild(self.w)
    
    
    local anchor = anchor.new("NorthWest", 10,168+height, 20,40)
    local textH = text.new(anchor, "H", font)
    local anchor = anchor.new("NorthWest", 30,160+height, -1,40, 40,0)
    self.h = numericInput.new(anchor, 4, maxNum, 4, font)
    self.h:setValueChangedCallback(function(_, value)
        if window.tileset and window.preview.y + value > window.tileset.image:getHeight() then
            if window.preview.y - 1 >= self.y.min then
                window.preview.y = window.preview.y - 1
                self.y:updateValue(window.preview.y)
            end
        end
        window.preview.height = value
        self:updatePreview(window.preview:getRect())
        return true
    end)
    self:addChild(textH)
    self:addChild(self.h)
    
    local anchor = anchor.new("NorthWest", 10,220+height, -1,40, 20,0)
    self.create = button.new(anchor, nil, function()
        local p = window.preview
        
        local tileData = window.tile
        if tileData == nil or tileData.type ~= "static" then
            tileData = {type = "static"}
        end
        
        tileData.x = p.x
        tileData.y = p.y
        tileData.w = p.width
        tileData.h = p.height
        
        if not tileData.id then
            global.editorSession:addTile(tileData, window.tileset)
            window.tile = tileData
            self:setState("edit")
        end
    end)
    self.create:setText("Add Tile", nil, font)
    self:addChild(self.create)
    self.create:setActive(false)
    
    local anchor = anchor.new("NorthWest", 10,270+height, -1,40, 20,0)
    self.delete = button.new(anchor, nil, function()
        if window.tile then
            global.editorSession:removeTile(window.tile)
            local p = window.preview
            window.selectPreview(p.x, p.y, p.width, p.height)
            self:setState("new")
        end
    end)
    self.delete:setText("Delete Tile", nil, font)
    self:addChild(self.delete)
    self.delete:setActive(false)
end

return tabStatic 
end