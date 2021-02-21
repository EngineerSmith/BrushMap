local lily = require("lib.lily.lily")

local global = require("global")
local insert = table.insert

local lilyLoaders = {
    png  = "newImage",
    jpg  = "newImage",
    jpeg = "newImage",
    bmp  = "newImage",
    dds  = "newImage",
    mp3  = "newSource",
    ogg  = "newSource",
    wav  = "newSource",
    txt  = "read",
    ttf  = "newFont",
    otf  = "newFont",
    fnt  = "newFont",
}

local function splitFileExtension(strFilename)
    return string.match(strFilename, "^.+%.(.+)$")
end

local loadAssets = function()
    local assetTable = require(global.assetsDir..".assets")
    
    local lilyTable = {}
    for _, asset in ipairs(assetTable) do
        local extension = splitFileExtension(asset[2])
        local assetTable = {lilyLoaders[extension], global.assetsDir .. "/" .. asset[2]}
        local i = 3
        while asset[i] ~= nil do
            insert(assetTable, asset[i])
            i = i + 1
        end
        insert(lilyTable, assetTable)
    end
    
    local lilyMulti = lily.loadMulti(lilyTable)
    lilyMulti:onComplete(function(_, lilies)
        for index, assets in ipairs(lilies) do
            local assetImport = assetTable[index]
            global.assets[assetImport[1]] = assets[1]
            if assetImport.onLoad then
                assetImport.onLoad(assets[1])
            end
        end
    end)
    
    return lilyMulti
end

return loadAssets()