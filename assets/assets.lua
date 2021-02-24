local pixelArt = function(asset)
    asset:setFilter("nearest","nearest")
end

local assets = {
    {"font.kennyfuture12", "fonts/Kenney Future.ttf", 12},
    {"font.kennyfuture18", "fonts/Kenney Future.ttf", 18},
    {"font.kennyfuture50", "fonts/Kenney Future.ttf", 50},
    {"font.kennyfuture72", "fonts/Kenney Future.ttf", 72},
    {"icon.language", "icons/wireframe-globe.png"},
    {"icon.help", "icons/help.png"},
    {"icon.arrow.right", "icons/arrow-right.png"},
    {"icon.arrow.left", "icons/arrow-left.png"},
    {"icon.folder.open", "icons/open-folder.png"},
    {"icon.stack", "icons/stack.png"},
    --EXAMPLE {"icon.pixel", "pixel.png", onLoad=pixelArt},
}

return assets