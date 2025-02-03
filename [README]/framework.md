# Qbox Framework

> Change client_scripts in fxmanifest.lua
```lua
client_scripts {
    -- "@qbx_core/modules/playerdata.lua",
    "bridge/**/client.lua",
    "module/client.lua"
}
```
> to
```lua
client_scripts {
    "@qbx_core/modules/playerdata.lua",
    "bridge/**/client.lua",
    "module/client.lua"
}
```