local lily = require("lib.lily.lily")

local global = require("global")

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
    local assetTable = require(global.assetDir..".assets")
    
    local lilyTable = {}
    for _, asset in ipairs(assetTable) do
        local extension = splitFileExtension(asset[2])
        insert(lilyTable, {lilyLoaders[extension], asset[2]})
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