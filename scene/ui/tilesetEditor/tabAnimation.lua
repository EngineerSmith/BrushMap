local global = require("global")

local lg = love.graphics

local tabWindow = require("ui.tabWindow")
local anchor = require("ui.base.anchor")
local imageAnimation = require("ui.imageAnimation")
local frameSelect = require("ui.frameSelect")
local text = require("ui.text")
local numericInput = require("ui.numericInput")
local button = require("ui.button")

local insert = table.insert

return function(font, controller, window)
local tabAnimation = tabWindow.new("Animation", font, controller)

tabAnimation.newTileset = function(self, tileset)
   self.preview:setImage(tileset)
   self:reset()
end

tabAnimation.setState = function(self, state)
    if state == "edit" then
        self.create:setText("Edit Tile")
        self.delete:setActive(true)
        self.frameSelect:setMaxindex(#self.preview.quads)
    elseif state == "new" then
        self.create:setText("Create Tile")
        self.delete:setActive(#self.preview.quads > 0)
    elseif state == "deactive" then
        self.deleteFrame:setActive(false)
        self.create:setActive(false)
        self.delete:setActive(false)
    end
end

tabAnimation.reset = function(self)
    self.preview:reset()
    self.frameSelect:reset()
    self.time:reset()
    self:setState("deactive")
end

tabAnimation.createUI = function(self)
    local anchor = anchor.new("NorthWest", 10,30, -1,-2, 20,0)
    self.preview = imageAnimation.new(anchor)
    self.preview:setBackgroundColor({0,0,0})
    self:addChild(self.preview)
    
    local x,y,w,h = self.preview.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, w,w/3, 20,0)
    self.frameSelect = frameSelect.new(anchor, global.assets["font.robotoReg25"], global.assets["icon.plus"])
    self.frameSelect.indexedChangedCallback = function(_, index)
        local p = window.preview
        if not window.tileset or (p.x==-1 and p.y==-1 and p.width==-1 and p.height==-1) then
            return false
        end
        
        local preview = self.preview
        if not preview:hasFrame(index) then
            --Add frame
            local quad = lg.newQuad(p.x,p.y, p.width,p.height, window.tileset.image:getDimensions())
            local time = self.time.value
            
            preview:addFrame(quad, time)
        else -- Already has a quad
            local quad, time = preview:getFrame(index)
            p.x, p.y, p.width, p.height = quad:getViewport()
            self.time.value = time
        end
        
        self.delete:setActive(#preview.quads > 0)
        self.deleteFrame:setActive(#preview.quads > 1)
        self.create:setActive(#preview.quads >= 2)
        controller:setLock(true)
        return true
    end
    self:addChild(self.frameSelect)
    
    local x,y,w,h = self.frameSelect.anchor:getRect()
    local height = y + h
    
    local anchor = anchor.new("NorthWest", 10, 10+height, -1,20, 20,0)
    local titleTime = text.new(anchor, "Time (Seconds)", font)
    local anchor = anchor.new("NorthWest", 10, 40+height, -1,40, 20,0)
    self.time = numericInput.new(anchor, 0.05, 3000, 0.2, font, 0.05)
    self.time:setValueChangedCallback(function(_, value)
        local preview = self.preview
        local index = self.frameSelect.index
        if index > 0 and preview:hasFrame(index) then
            preview:setTime(index, value)
        end
        return true
    end)
    self:addChild(titleTime)
    self:addChild(self.time)
    
    local anchor = anchor.new("NorthWest", 10,100+height, -1,40, 20,0)
    self.deleteFrame = button.new(anchor, nil, function(_)
        local preview = self.preview
        local frameSelect = self.frameSelect
        local index = frameSelect.index
        if index > 0 and preview:hasFrame(index) then
            preview:removeFrame(index)
            frameSelect.maxindex = frameSelect.maxindex - 1
            if frameSelect.index > frameSelect.maxindex then
                frameSelect.index = frameSelect.maxindex
            end
            self.frameSelect:indexedChangedCallback(frameSelect.index)
        end
    end)
    self.deleteFrame:setText("Delete Frame", nil, font)
    self:addChild(self.deleteFrame)
    self.deleteFrame:setActive(false)
    
    local anchor = anchor.new("NorthWest", 10,150+height, -1,40, 20,0)
    self.create = button.new(anchor, nil, function(_)
        local preview = self.preview
        local quads = preview.quads
        
        local tileData = window.tile 
        if tileData == nil or tileData.type ~= "animated" then
            tileData = {type = "animated"}
        end 
        tileData.tiles = {}
        
        for index, quad in ipairs(quads) do
            local x,y,w,h = quad:getViewport()
            local tile = {
                x=x, y=y, w=w, h=h,
                time = preview:getTime(index)
            }
            insert(tileData.tiles, tile)
        end
        
        if not tileData.id then
            global.editorSession:addTile(tileData, window.tileset)
        end
        
        self:reset()
        window.tile = nil
        window.selectPreview(-1,-1,-1,-1)
        controller:setLock(false)
    end)
    self.create:setText("Create Tile", nil, font)
    self:addChild(self.create)
    self.create:setActive(false)
    
    local anchor = anchor.new("NorthWest", 10,200+height, -1,40, 20,0)
    self.delete = button.new(anchor, nil, function(self)
        if window.tile then
            controller.tabAnimation:reset()
            global.editorSession:removeTile(window.tile)
            window.tile = nil
            window.selectPreview(-1,-1,-1,-1)
            controller:setLock(false)
        else
            controller.tabAnimation:reset()
            controller:setLock(false)
        end
    end)
    self.delete:setText("Delete Title", nil, font)
    self:addChild(self.delete)
    self.delete:setActive(false)
end

return tabAnimation
end