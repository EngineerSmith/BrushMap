local pixelArt = function(asset)
    asset:setFilter("nearest","nearest")
end

local assets = {
    {"icon.language", "wireframe-globe.png"},
    {"icon.help", "help.png"},
    --EXAMPLE {"icon.pixel", "pixel.png", onLoad=pixelArt},
}

return assets