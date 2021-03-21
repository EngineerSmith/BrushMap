local global = require("global")

local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local bitmaskPreview = require("ui.bitmaskPreview")
local numberSelect = require("ui.numberSelect")
local button = require("ui.button")
local togglebox = require("ui.togglebox")
local text = require("ui.text")

return function(font, controller)
local tabAnimation = tabWindow.new("Bitmask", font)

tabAnimation.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,-2, 20,0)
    self.preview = bitmaskPreview.new(anchor)
    self.preview:setBackgroundColor({0,0,0})
    self:addChild(self.preview)
    
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
        return true
    end
    
    local x,y,w,h = self.numberSelect.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, -1,20, 20,0)
    local titleToggle = text.new(anchor, "Number of directions", font)
    local anchor = anchor.new("NorthWest", 10, 40+height, -1,40, 20,0)
    self.toggle = togglebox.new(anchor, true)
    self.toggle.valueChangedCallback = function(_, selected)
        if not selected then
            self.preview:drawEvenDirectionsOnly(true)
            self.numberSelect.max = 15
            self.preview:setActiveTiles(15)
        else
            self.preview:drawEvenDirectionsOnly(false)
            self.numberSelect.max = 255
            self.preview:setActiveTiles(255)
        end
    end
    self:addChild(titleToggle)
    self:addChild(self.toggle)
    
    local anchor = anchor.new("NorthWest", 10,100+height, -1,40, 20,0)
    self.change = button.new(anchor)
    self.change:setText("Edit Bitmask", nil, font)
    self:addChild(self.change, nil)
    self.change:setActive(false)
    
    local anchor = anchor.new("NorthWest", 10,150+height, -1,40, 20,0)
    self.finish = button.new(anchor)
    self.finish:setText("Create Bitmask", nil, font)
    self:addChild(self.finish, nil)
    self.finish:setActive(false)
    
    
end

return tabAnimation
end