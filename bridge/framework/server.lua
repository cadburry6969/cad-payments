if Config.Framework == 'qbox' then
    function GetJobLabel(job)
        local jobInfo = exports.qbx_core:GetJobs()[job]
        return jobInfo and jobInfo.label or 'None'
    end
    function GetPlayer(src)
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
    end
end

if Config.Framework == 'qb' then
    local QBCore = exports['qb-core']:GetCoreObject()

    function GetJobLabel(job)
        local jobInfo = QBCore.Shared.Jobs[job]
        return jobInfo and jobInfo.label or 'None'
    end
    function GetPlayer(src)
        local player = QBCore.Functions.GetPlayer(src)
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

if Config.Inventory == 'ox_inventory' then
    function HasItem(src, item, amount)
        local count = exports.ox_inventory:GetItem(src, item, nil, true)
        return (count and count >= amount) or 0
    end
    function AddItem(src, item, amount, metadata)
        return exports.ox_inventory:AddItem(src, item, amount, metadata)
    end
    function RemoveItem(src, item, amount)
        return exports.ox_inventory:RemoveItem(src, item, amount)
    end
else
    function HasItem(src, item, amount)
        return exports[Config.Inventory]:HasItem(src, item, amount)
    end
    function AddItem(src, item, amount, metadata)
        return exports[Config.Inventory]:AddItem(src, item, amount, nil, metadata)
    end
    function RemoveItem(src, item, amount)
        return exports.ox_inventory:RemoveItem(src, item, amount)
    end
end

if Config.Banking == 'qb-banking' then
    function AddMoneyToAccount(accountName, amount, reason)
        return exports['qb-banking']:AddMoney(accountName, amount, reason)
    end
elseif Config.Banking == 'snipe-banking' then
    function AddMoneyToAccount(accountName, amount, reason)
        return exports['snipe-banking']:AddMoneyToAccount(accountName, amount, reason)
    end
elseif Config.Banking == 'Renewed-Banking' then
    function AddMoneyToAccount(accountName, amount, reason)
        return exports['Renewed-Banking']:addAccountMoney(accountName, amount)
    end
elseif Config.Banking == "qb-management" then
    function AddMoneyToAccount(accountName, amount, reason)
        return exports["qb-management"]:AddMoney(accountName, amount, reason)
    end
elseif Config.Banking == "fd_banking" then
    function AddMoneyToAccount(accountName, amount, reason)
        return exports.fd_banking:AddMoney(accountName, amount, reason)
    end
elseif Config.Banking == "okokBanking" then
    function AddMoneyToAccount(accountName, amount, reason)
        return exports['okokBanking']:AddMoney(accountName, amount, reason)
    end
end