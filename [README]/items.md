> ox_inventory (ox_inventory/data/items.lua)
```lua
['businesspos'] = {
    label = 'Business POS',
    weight = 1000,
    stack = false,
    description = "SWIPE ON THE GO FOR BUSINESS",
    client = {
        export = "cad-payments.useBusinessPos"
    }
},
['generalpos'] = {
    label = 'General POS',
    weight = 1000,
    stack = false,
    description = "SWIPE ON THE GO FOR INDIVIDUAL",
    client = {
        export = "cad-payments.useGeneralPos"
    }
},
```