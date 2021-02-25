local window = require("ui.base.window").new()

local global = require("global")

local lfs = love.filesystem

local insert = table.insert

local anchor = require("ui.base.anchor")

local shape = require("ui.shape")
local button = require("ui.button")
local scrollView = require("ui.scrollView")
local directoryItem = require("ui.directoryItem")
local dropDown = require("ui.dropDown")

local anchor = anchor.new("Center", 0,0, -1,-1, 70,70)
local background = shape.new(anchor, "Rectangle", {0.4,0.4,0.4, 0.5}, "fill", 7)

window:addChild(background)

local anchor = anchor.new("SouthEast", 10,10, 120,120)
local actionButton = button.new(anchor)
actionButton:setText("HELLO")
window.actionButton = actionButton
background:addChild(actionButton)

local iconSize = 30

local anchor = anchor.new("SouthWest", 10,10, -1,-1, 150, 80)
local fileScrollView = scrollView.new(anchor, 0, iconSize + 2)
window.scrollView = fileScrollView
background:addChild(fileScrollView)


local options = lfs.getDirectoryItems("externalAssets")


local anchor = anchor.new("NorthWest", 10,10, -1,30, 20,0)
local driveDrop = dropDown.new(anchor, options, global.assets["font.robotoReg18"], "Select drive")

driveDrop.touchpressedCallback = function(self)
    window.scrollView.enabled = false
    window.actionButton.enabled = false
end

driveDrop.touchreleasedCallback = function(self)
    if self.selected ~= -1 then
        window.scrollView.enabled = true
        window.actionButton.enabled = true
        window.setDrive(self.options[self.selected])
    end
end

background:addChild(driveDrop)

window.scrollView.enabled = false
window.actionButton.enabled = false

local fileItemCallback = function(self, selected)
    if selected and window.previousSelected then
        window.previousSelected:setSelected(false)
        window.previousSelected = self
    elseif selected then
        window.previousSelected = self
    else
        window.previousSelected = nil
    end
    return true
end

local directoryItemCallback

local fileItemfactory = function(fileName)
    fileName = fileName or error("File name required")
    local item = directoryItem.new(global.assets["icon.stack.128"], fileName, global.assets["font.robotoReg12"], iconSize, fileItemCallback)
    window.scrollView:addChild(item)
    return item
end

local directoryItemFactory = function(directoryName)
    directoryName = directoryName or error("Directory name required")
    local item = directoryItem.new(global.assets["icon.folder.128"], directoryName, global.assets["font.robotoReg12"], iconSize, directoryItemCallback)
    window.scrollView:addChild(item)
    return item
end

local displayMap = function(map)
    window.scrollView:empty()
    window.previousSelected = nil
    
    if map.parent then
        local item = directoryItemFactory("..")
        item.map = map.parent
    end
    
    for i=1, #map.directories, 2 do
        local item = directoryItemFactory(map.directories[i])
        item.map = map.directories[i+1]
    end
    for i=1, #map.files, 2 do
        local item = fileItemfactory(map.files[i])
        item.fullDir = map.files[i+1]
    end
end

directoryItemCallback = function(self, selected)
    displayMap(self.map)
    return true
end

--[[ 
CALLBACK EXAMPLE
    function callback(success, filePath) end
FILTER EXAMPLE
    {"png", "tga", "jpeg", "jpg"}
]]

window.modes = {
    --["save"] = "Save Here", --TODO
    ["load"] = "Load File",
}

window.dialog = function(mode, callback, filter)
    --window.callback = callback or error("Callback required when displaying file dialog")
    window.mode = window.modes[mode] and mode or error("Mode not supported in file dialog. "..tostring(mode))
    
    window.actionButton:setText(window.modes[mode], {1,1,1},global.assets["font.robotoReg18"])
    window.enabled = true
end

window.createMap = function(directory, parent)
    local items = lfs.getDirectoryItems(directory)
    local map = {directories ={}, files={},directory=directory, parent=parent}
    
    for _, item in ipairs(items) do
        local fullDir = directory.."/"..item
        if lfs.isFile(fullDir) then
           insert(map.files, item)
           insert(map.files, fullDir)
        elseif lfs.isDirectory(fullDir) then
            insert(map.directories, item)
            insert(map.directories, window.createMap(fullDir, map))
        end
    end
    
    return map
end

window.setDrive = function(drive)
    drive = "externalAssets/"..drive
    window.map = window.createMap(drive)
    
    displayMap(window.map)
end

window.enabled = false

return window