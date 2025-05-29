fx_version "cerulean"
game "gta5"
lua54 "yes"

author "Cadburry (Bytecode Studios)"
description "Payments system"
version "0.8"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}

client_scripts {
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
