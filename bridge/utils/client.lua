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
    elseif Config.Notify == 'lb-phone' then
        local data = {
            title = 'Payment Terminal',
            content = msg
        }
        exports['lb-phone']:SendNotification(data)
    end
end

function PlayEmote()
    if GetResourceState('scully_emotemenu') == 'started' then
        exports.scully_emotemenu:playEmoteByCommand('terminal')
    elseif GetResourceState('rpemotes') == 'started' then
        exports.rpemotes:EmoteCommandStart('terminal')
    end
end

function CancelEmote()
    if GetResourceState('scully_emotemenu') == 'started' then
        exports.scully_emotemenu:cancelEmote()
    elseif GetResourceState('rpemotes') == 'started' then
        exports.rpemotes:EmoteCancel()
    end
end

function RequestConfirmation(data)
    local title = 'Payment Request: ' .. string.upper(data.name)
    local description = string.format('Payment of $%d requested for %s', data.amount, data.reason)
    if Config.Phone == 'snappy-phone' then
        local status = exports['snappy-phone']:sendConfirmation({
            title = title,
            description = description,
            icon = 'credit-card',
            duration = 10000,
        })
        return status
    elseif Config.Phone == 'lb-phone' then
        local result = promise:new()
        local notificationEvent
        CreateThread(function()
            notificationEvent = RegisterNetEvent('lbphone:notificationResponse', function(response)
                result:resolve(response.status)
                RemoveEventHandler(notificationEvent)
            end)
        end)
        exports['lb-phone']:SendNotification({
            title = title,
            content = description,
            customData = {
                buttons = {
                    { title = "Accept",  event = "lbphone:notificationResponse", data = { status = true } },
                    { title = "Decline", event = "lbphone:notificationResponse", data = { status = false } }
                }
            }
        })
        SetTimeout(15000, function()
            result:resolve(false)
        end)
        local response = Citizen.Await(result)
        return response
    end
end

CreateThread(function()
    for _, data in pairs(Config.Registers) do
        local point = lib.points.new({
            coords = vec3(data.coords.x, data.coords.y, data.coords.z),
            distance = data.distance,
            name = data.name,
            job = data.job
        })
        function point:onEnter()
            lib.showTextUI('[E] Access Register')
        end

        function point:onExit()
            lib.hideTextUI()
        end

        function point:nearby()
            if self.currentDistance < 2 and IsControlJustReleased(0, 46) then
                local options = {
                    {
                        title = 'Charge Customer',
                        icon = 'fa-solid fa-cash-register',
                        onSelect = function()
                            exports['cad-payments']:OpenChargeMenu(self.job)
                        end
                    },
                }
                if IsJobBoss(self.job) then
                    options[#options + 1] = {
                        title = 'Collect Cash',
                        icon = 'fa-solid fa-cash-register',
                        onSelect = function()
                            exports['cad-payments']:OpenCashRegister(self.job)
                        end
                    }
                end
                lib.registerContext({
                    id = 'payments_register',
                    title = self.name,
                    options = options
                })
                lib.showContext('payments_register')
            end
        end
    end
end)
