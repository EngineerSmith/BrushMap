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
actionButton:setCallbackReleased(function(self)
    window.enabled = false
    window.callback(true, window.previousSelected.fullDir)
    return true
end)
window.actionButton = actionButton
background:addChild(actionButton)

local anchor = anchor.new("NorthWest", 10,10, 80,30)
local returnButton = button.new(anchor)
returnButton:setText("Return", {1,1,1}, global.assets["font.robotoReg18"])
returnButton:setCallbackReleased(function(self)
    window.enabled = false
    window.callback(false)
    return true
end)
window.returnButton = returnButton
background:addChild(returnButton)

local iconSize = 30

local anchor = anchor.new("SouthWest", 10,10, -1,-1, 150, 80)
local fileScrollView = scrollView.new(anchor, 0, iconSize + 2)
window.scrollView = fileScrollView
background:addChild(fileScrollView)

local options = lfs.getDirectoryItems("externalAssets")

local anchor = anchor.new("NorthWest", 100,10, -1,30, 120,0)
local driveDrop = dropDown.new(anchor, options, global.assets["font.robotoReg18"], "Select drive")

local fileItemCallback

driveDrop.touchpressedCallback = function(self)
    fileItemCallback(nil, false)
    window.scrollView.enabled = false
end

driveDrop.touchreleasedCallback = function(self)
    if self.selected ~= -1 then
        window.scrollView.enabled = true
        window.setDrive(self.options[self.selected])
    end
end

background:addChild(driveDrop)

window.scrollView.enabled = false
window.actionButton.enabled = false

fileItemCallback = function(self, selected)
    if selected and window.previousSelected then
        window.previousSelected:setSelected(false)
        window.previousSelected = self
    elseif selected then
        window.previousSelected = self
        window.actionButton.enabled = true
    else
        window.previousSelected = nil
        window.actionButton.enabled = false
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
    fileItemCallback(nil, false)
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
    ["load"] = "Load File",
    --["save"] = "Save Here", --TODO
}

window.dialog = function(mode, callback, filter)
    window.callback = callback or error("Callback required when displaying file dialog")
    window.mode = window.modes[mode] and mode or error("Mode not supported in file dialog. "..tostring(mode))
    window.filter = filter or {"*"}
    
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