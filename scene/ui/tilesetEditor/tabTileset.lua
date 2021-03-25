local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local button = require("ui.button")
local numericInput = require("ui.numericInput")
local text = require("ui.text")
local checkbox = require("ui.checkbox")

local maxNum = 9999

return function(font, controller, window)
local tabTileset = tabWindow.new("Tileset", font)

tabTileset.updateElement = function(self, dt)
    window.grid:setTileSize(tabTileset.x, tabTileset.y)
    window.grid:setTileOffset(tabTileset.gridoffsetX, tabTileset.gridoffsetY)
    window.grid:setPadding(tabTileset.paddingX, tabTileset.paddingY)
end

tabTileset.createUI = function(self)
--[[ BUTTONS ]]
    local anchor = anchor.new("NorthWest", 10,30, -1,40, 20,0)
    local bgColorPicker = button.new(anchor, nil, function()
        window.togglePicker(true)
    end)
    bgColorPicker:setText("Background Colour", nil, font)
    self:addChild(bgColorPicker)
   
    local anchor = anchor.new("NorthWest", 10,80, -1,40, 20,0)
    local tilesetSelect = button.new(anchor, nil, controller.tilesetSelect)
    tilesetSelect:setText("Select Tileset", nil, font)
    self:addChild(tilesetSelect)
    
    
--[[ TILE SIZE ]]
    local anchor = anchor.new("NorthWest", 10, 130, -1,20, 20,0)
    local titleTilesize = text.new(anchor, "Tile Size", font)
    self:addChild(titleTilesize)
    
    local anchor = anchor.new("NorthWest", 10,170, 20,40)
    local textX = text.new(anchor, "X", font)
    local anchor = anchor.new("NorthWest", 30,160, -1,40, 40,0)
    local x = numericInput.new(anchor, 4, maxNum, 16, font)
    x:setValueChangedCallback(function(_, value)
        self.x = value
        return true
    end)
    self:addChild(textX)
    self:addChild(x)
    
    local anchor = anchor.new("NorthWest", 10,220, 20,40)
    local textY = text.new(anchor, "Y", font)
    local anchor = anchor.new("NorthWest", 30,210, -1,40, 40,0)
    local y = numericInput.new(anchor, 4, maxNum, 16, font)
    y:setValueChangedCallback(function(_, value)
        self.y = value
        return true
    end)
    self:addChild(textY)
    self:addChild(y)
    
    local anchor = anchor.new("NorthEast", 10,125, 30,30)
    local checkboxMirror = checkbox.new(anchor, true)
    checkboxMirror:setValueChangedCallback(function(_, selected)
        x:setClone(selected and y or nil)
    end)
    self:addChild(checkboxMirror)
    
--[[ TILE OFFSET ]]
    local anchor = anchor.new("NorthWest", 10, 260, -1,20, 20,0)
    local titleTileoffset = text.new(anchor, "Tile Offset", font)
    self:addChild(titleTileoffset)
    
    local anchor = anchor.new("NorthWest", 10,300, 20,40)
    local textX = text.new(anchor, "X", font)
    local anchor = anchor.new("NorthWest", 30,290, -1,40, 40,0)
    local offsetX = numericInput.new(anchor, 0, maxNum, 0, font)
    offsetX:setValueChangedCallback(function(_, value)
        self.gridoffsetX = value
        return true
    end)
    self:addChild(textX)
    self:addChild(offsetX)
    
    local anchor = anchor.new("NorthWest", 10,350, 20,40)
    local textY = text.new(anchor, "Y", font)
    local anchor = anchor.new("NorthWest", 30,340, -1,40, 40,0)
    local offsetY = numericInput.new(anchor, 0, maxNum, 0, font)
    offsetY:setValueChangedCallback(function(_, value)
        self.gridoffsetY = value
        return true
    end)
    self:addChild(textY)
    self:addChild(offsetY)
    
    local anchor = anchor.new("NorthEast", 10,255, 30,30)
    local checkboxMirror = checkbox.new(anchor, true)
    checkboxMirror:setValueChangedCallback(function(_, selected)
        offsetX:setClone(selected and offsetY or nil)
    end)
    self:addChild(checkboxMirror)
    
--[[ TILE PADDING ]]
    local anchor = anchor.new("NorthWest", 10, 390, -1,20, 20,0)
    local titlePadding = text.new(anchor, "Padding", font)
    self:addChild(titlePadding)
    
    local anchor = anchor.new("NorthWest", 10,430, 20,40)
    local textX = text.new(anchor, "X", font)
    local anchor = anchor.new("NorthWest", 30,420, -1,40, 40,0)
    local paddingX = numericInput.new(anchor, 0, maxNum, 0, font)
    paddingX:setValueChangedCallback(function(_, value)
        self.paddingX = value
        return true
    end)
    self:addChild(textX)
    self:addChild(paddingX)
    
    local anchor = anchor.new("NorthWest", 10,480, 20,40)
    local textY = text.new(anchor, "Y", font)
    local anchor = anchor.new("NorthWest", 30,470, -1,40, 40,0)
    local paddingY = numericInput.new(anchor, 0, maxNum, 0, font)
    paddingY:setValueChangedCallback(function(_, value)
        self.paddingY = value
        return true
    end)
    self:addChild(textY)
    self:addChild(paddingY)
    
    local anchor = anchor.new("NorthEast", 10,385, 30,30)
    local checkboxMirror = checkbox.new(anchor, true)
    checkboxMirror:setValueChangedCallback(function(_, selected)
        paddingX:setClone(selected and paddingY or nil)
    end)
    self:addChild(checkboxMirror)
end

return tabTileset
end
