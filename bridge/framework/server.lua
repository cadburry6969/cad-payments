function GetJobLabel(job)
    if GetResourceState('qbx_core') == 'started' then
        local jobInfo = exports.qbx_core:GetJobs()[job]
        return jobInfo and jobInfo.label or 'None'
    elseif GetResourceState('qb-core') == 'started' then
        local jobInfo = exports['qb-core']:GetCoreObject().Shared.Jobs[job]
        return jobInfo and jobInfo.label or 'None'
    end
end

function GetPlayer(src)
    if GetResourceState('qbx_core') == 'started' then
        local player = exports.qbx_core:GetPlayer(src)
        return player and {
            source = player.PlayerData.source,
            name = string.format('%s %s', player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname),
            cash = player.PlayerData.money.cash,
            bank = player.PlayerData.money.bank,
            addMoney = function(mtype, amount, reason)
                return player.Functions.AddMoney(mtype, amount, reason)
            end,
            removeMoney = function(mtype, amount, reason)
                return player.Functions.RemoveMoney(mtype, amount, reason)
            end
        }
    elseif GetResourceState('qb-core') == 'started' then
        local player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(src)
        return player and {
            source = player.PlayerData.source,
            name = string.format('%s %s', player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname),
            cash = player.PlayerData.money.cash,
            bank = player.PlayerData.money.bank,
            addMoney = function(mtype, amount, reason)
                return player.Functions.AddMoney(mtype, amount, reason)
            end,
            removeMoney = function(mtype, amount, reason)
                return player.Functions.RemoveMoney(mtype, amount, reason)
            end
        }
    end
end

function HasItem(src, item, amount)
    if GetResourceState('ox_inventory') == 'started' then
        local count = exports.ox_inventory:GetItem(src, item, nil, true)
        return (count and count >= amount) or 0
    elseif GetResourceState('qb-inventory') == 'started' then
        return exports['qb-inventory']:HasItem(src, item, amount)
    elseif GetResourceState('qs-inventory') == 'started' then
        local totalAmount = exports['qs-inventory']:GetItemTotalAmount(src, item)
        return (totalAmount and totalAmount >= amount)
    end
end

function AddItem(src, item, amount, metadata)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(src, item, amount, metadata)
    elseif GetResourceState('qb-inventory') == 'started' then
        return exports['qb-inventory']:AddItem(src, item, amount, nil, metadata)
    elseif GetResourceState('qs-inventory') == 'started' then
        return exports['qs-inventory']:AddItem(src, item, amount, nil, metadata)
    end
end

function RemoveItem(src, item, amount)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:RemoveItem(src, item, amount)
    elseif GetResourceState('qb-inventory') == 'started' then
        return exports['qb-inventory']:RemoveItem(src, item, amount)
    elseif GetResourceState('qs-inventory') == 'started' then
        return exports['qs-inventory']:RemoveItem(src, item, amount)
    end
end

function AddMoneyToAccount(accountName, amount, reason)
    if GetResourceState('qb-banking') == 'started' then
        return exports['qb-banking']:AddMoney(accountName, amount, reason)
    elseif GetResourceState('snipe-banking') == 'started' then
        return exports['snipe-banking']:AddMoneyToAccount(accountName, amount, reason)
    elseif GetResourceState('Renewed-Banking') == 'started' then
        return exports['Renewed-Banking']:addAccountMoney(accountName, amount)
    elseif GetResourceState('qb-management') == 'started' then
        return exports["qb-management"]:AddMoney(accountName, amount, reason)
    elseif GetResourceState('fd_banking') == 'started' then
        return exports['fd_banking']:AddMoney(accountName, amount, reason)
    elseif GetResourceState('okokBanking') == 'started' then
        return exports['okokBanking']:AddMoney(accountName, amount, reason)
    elseif GetResourceState('kartik-banking') == 'started' then
        return exports['kartik-banking']:AddAccountMoney(accountName, amount, reason)
    else
        return false
    end
end

CreateThread(function ()
    local timeout = 60000
    if GetResourceState('qb-inventory') ~= 'missing' then
        while GetResourceState('qb-inventory') ~= 'started' and timeout > 0 do
            Wait(1000)
            timeout = timeout - 1000
        end
        exports['qb-core']:CreateUseableItem('businesspos', function(source, item)
            local Player = exports['qb-core']:GetPlayer(source)
	        if not Player.Functions.GetItemByName(item.name) then return end
            item.metadata = item.info
            TriggerClientEvent('payments:client:useBusinessPos', source, item)
        end)
        exports['qb-core']:CreateUseableItem('generalpos', function(source, item)
            local Player = exports['qb-core']:GetPlayer(source)
	        if not Player.Functions.GetItemByName(item.name) then return end
            TriggerClientEvent('payments:client:useGeneralPos', source)
        end)
    elseif GetResourceState('qs-inventory') ~= 'missing' then
        while GetResourceState('qs-inventory') ~= 'started' and timeout > 0 do
            Wait(1000)
            timeout = timeout - 1000
        end
        exports['qs-inventory']:CreateUsableItem('generalpos', function(source, item)
            if item.metadata and item.metadata.quality then
                TriggerClientEvent('payments:client:useGeneralPos', source, item)
            end
        end)
        exports['qs-inventory']:CreateUsableItem('businesspos', function(source, item)
            if item.metadata and item.metadata.quality then
                TriggerClientEvent('payments:client:useBusinessPos', source)
            end
        end)
    end
end)