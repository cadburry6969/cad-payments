if Config.Framework == 'qbox' then
    function IsJobBoss(job)
        local data = QBX.PlayerData
        return data.job.name == job and data.job.grade.isboss
    end

    function GetJobLabel(job)
        local jobInfo = exports.qbx_core:GetJobs()[job]
        return jobInfo and jobInfo.label or 'None'
    end
end

if Config.Framework == 'qb' then
    local QBCore = exports['qb-core']:GetCoreObject()

    function IsJobBoss(job)
        local PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.job.name == job and PlayerData.job.grade.isboss
    end

    function GetJobLabel(job)
        local jobInfo = QBCore.Shared.Jobs[job]
        return jobInfo and jobInfo.label or 'None'
    end
end

if Config.Inventory == 'ox_inventory' then
    exports.ox_inventory:displayMetadata({ job = 'Job' })
    exports('useBusinessPos', function(data, slot)
        if not next(slot.metadata) then Notify("Not valid machine") return end
        PlayEmote()
        local jobName = slot.metadata?.jobName or GetJobLabel()
        local input = lib.inputDialog('Point of Sale (POS): '..jobName or slot.metadata.job, {
            {type = 'number', label = 'Person ID', icon = 'credit-card', min = 1},
            {type = 'number', label = 'Amount', icon = 'credit-card', min = 1},
            {type = 'input', label = 'Reason', icon = 'circle-question'},
            {type = 'select', label = 'Payment Mode', options = { { value = "cash", label = "Cash" }, { value = "bank", label = "Card" } }, default = "cash", required = true},
        })
        CancelEmote()
        if input then
            if not input[1] then Notify("Person ID not provided") return end
            if not input[2] then Notify("Amount not provided") return end
            if not input[3] then Notify("Reason not provided") return end
            if not input[4] then Notify("Payment mode not provided") return end
            TriggerServerEvent('payments:server:sendPaymentRequest', input, slot.metadata.job)
        end
    end)

    exports('useGeneralPos', function(data, slot)
        PlayEmote()
        local input = lib.inputDialog('Point of Sale (POS)', {
            {type = 'number', label = 'Person ID', icon = 'credit-card', min = 1},
            {type = 'number', label = 'Amount', icon = 'credit-card', min = 1},
            {type = 'input', label = 'Reason', icon = 'circle-question'},
            {type = 'select', label = 'Payment Mode', options = { { value = "cash", label = "Cash" }, { value = "bank", label = "Card" } }, default = "cash", required = true},
        })
        CancelEmote()
        if input then
            if not input[1] then Notify("Person ID not provided") return end
            if not input[2] then Notify("Amount not provided") return end
            if not input[3] then Notify("Reason not provided") return end
            if not input[4] then Notify("Payment mode not provided") return end
            TriggerServerEvent('payments:server:sendPaymentRequest', input)
        end
    end)
end