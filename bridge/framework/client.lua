function IsJobBoss(job)
    if GetResourceState('qbx_core') == 'started' then
        local data = exports.qbx_core:GetPlayerData()
        return data.job.name == job and data.job.grade.isboss
    elseif GetResourceState('qb-core') == 'started' then
        local PlayerData = exports['qb-core']:GetCoreObject().Functions.GetPlayerData()
        return PlayerData.job.name == job and PlayerData.job.grade.isboss
    else
        return false
    end
end

function GetJobLabel(job)
    if GetResourceState('qbx_core') == 'started' then
        local jobInfo = exports.qbx_core:GetJobs()[job]
        return jobInfo and jobInfo.label or 'None'
    elseif GetResourceState('qb-core') == 'started' then
        local jobInfo = exports['qb-core']:GetCoreObject().Shared.Jobs[job]
        return jobInfo and jobInfo.label or 'None'
    else
        return 'None'
    end
end

CreateThread(function()
    local timeout = 30000
    while GetResourceState('ox_inventory') ~= 'missing' and timeout > 0 do
        Wait(1000)
        timeout = timeout - 1000
        if GetResourceState('ox_inventory') == 'started' then
            exports.ox_inventory:displayMetadata({ job = 'Job' })
        end
    end
end)

-- For Inventory Use
local function useBusinessPos(data, slot)
    if not slot.metadata or not next(slot.metadata) then Notify("Not valid machine") return end
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
end
RegisterNetEvent('payments:client:useBusinessPos', function(data)
    useBusinessPos(nil, data)
end)
exports('useBusinessPos', useBusinessPos)

-- For Inventory Use
local function useGeneralPos()
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
end
RegisterNetEvent('payments:client:useGeneralPos', useGeneralPos)
exports('useGeneralPos', useGeneralPos)