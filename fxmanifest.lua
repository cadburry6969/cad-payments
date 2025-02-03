fx_version "cerulean"
game "gta5"
lua54 "yes"

author "Cadburry"
description "Payments system"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}

client_scripts {
    -- "@qbx_core/modules/playerdata.lua",
    "bridge/**/client.lua",
    "module/client.lua"
}

server_scripts {
    "bridge/**/server.lua",
    "module/server.lua"
}

dependencies {
    "/onesync",
    "ox_lib"
}

escrow_ignore {
    "bridge/**/*",
    "config.lua"
}