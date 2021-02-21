local pixelArt = function(asset)
    asset:setFilter("nearest","nearest")
end

local assets = {
    {"font.kennyfuture12", "fonts/Kenney Future.ttf", 12},
    {"font.kennyfuture18", "fonts/Kenney Future.ttf", 18},
    {"font.kennyfuture50", "fonts/Kenney Future.ttf", 50},
    {"icon.language", "wireframe-globe.png"},
    {"icon.help", "help.png"},
    --EXAMPLE {"icon.pixel", "pixel.png", onLoad=pixelArt},
}

return assets