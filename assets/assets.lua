local pixelArt = function(asset)
    asset:setFilter("nearest","nearest")
end

local assets = {
    {"font.kennyfuture12", "fonts/Kenney Future.ttf", 12},
    {"font.kennyfuture18", "fonts/Kenney Future.ttf", 18},
    {"font.kennyfuture50", "fonts/Kenney Future.ttf", 50},
    {"font.kennyfuture72", "fonts/Kenney Future.ttf", 72},
    {"font.robotoReg12", "fonts/Roboto-Regular.ttf", 12},
    {"font.robotoReg18", "fonts/Roboto-Regular.ttf", 18},
    {"font.robotoReg50", "fonts/Roboto-Regular.ttf", 50},
    {"font.robotoReg72", "fonts/Roboto-Regular.ttf", 72},
    {"icon.language", "icons/wireframe-globe.png"},
    {"icon.help", "icons/help.png"},
    {"icon.arrow.right", "icons/arrow-right.png"},
    {"icon.arrow.left", "icons/arrow-left.png"},
    {"icon.folder.128", "icons/open-folder-128.png"},
    {"icon.stack.128", "icons/stack-128.png"},
    {"icon.disc.128", "icons/compact-disc-128.png"}
    --EXAMPLE {"icon.pixel", "pixel.png", onLoad=pixelArt},
}

return assets