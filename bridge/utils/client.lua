function Notify(msg, type)
    lib.notify({ description = msg, type = type })
    if Config.Notify == 'qb' then
        TriggerEvent("QBCore:Notify", msg, type, 10000)
    elseif Config.Notify == 'ox' then
        lib.notify({ description = msg, type = type, duration = 10000 })
    elseif Config.Notify == 'snappy-phone' then
        local data = {
            title = 'Payment Terminal',
            icon = 'cash-register',
            description = msg,
            duration = 5000,
        }
        exports['snappy-phone']:sendNotification(data)
    end
end

function PlayEmote()
    -- play your emote here
end

function CancelEmote()
    -- cancel your emote here
end