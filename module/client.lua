---#region FUNCTIONS
function ShowChargeMenu(jobName)
    local input = lib.inputDialog('Billing Register', {
        {type = 'number', label = 'Person ID', icon = 'credit-card', required = true, min = 1},
        {type = 'number', label = 'Amount', icon = 'credit-card', required = true, min = 1},
        {type = 'input', label = 'Reason', icon = 'circle-question', required = true},
        {type = 'select', label = 'Payment Mode', options = { { value = "cash", label = "Cash" }, { value = "bank", label = "Card" } }, default = "cash", required = true},
    })
    if input then
        if not input[1] then Notify("Person ID not provided") return end
        if not input[2] then Notify("Amount not provided") return end
        if not input[3] then Notify("Reason not provided") return end
        if not input[4] then Notify("Payment mode not provided") return end
        TriggerServerEvent('payments:server:charge', lib.math.round(input[1]), lib.math.round(input[2]), input[3], input[4], jobName)
    end
end

function OpenCashRegister(jobName)
    local cash = lib.callback.await('payments:server:checkCash', false, jobName)
    if not cash or cash < 1 then Notify("Register is empty", "error") return end
    local input = lib.inputDialog('Collect Cash ($'..cash..')', {
        {type = 'number', label = 'Amount', icon = "credit-card", required = true, min = 1},
    })
    if input then
        if not input[1] then Notify("Amount not provided") return end
        if input[1] < 1 then return end
        local amount = lib.math.round(input[1])
        Wait(math.random(200, 600))
        TriggerServerEvent('payments:server:collectCashinRegister', jobName, amount)
    end
end

local function ShowRegister(jobName)
    lib.registerContext({
        id = 'payment_register',
        title = 'Register',
        options = {
            {
                title = 'Charge Customer',
                description = 'Charge a nearby customer',
                icon = 'cash-register',
                onSelect = function()
                    ShowChargeMenu(jobName)
                end
            },
            {
                title = 'Collect Cash',
                description = 'Collect cash from register',
                icon = 'cash-register',
                onSelect = function()
                    OpenCashRegister(jobName)
                end
            },
        }
    })
    lib.showContext('payment_register')
end exports('ShowRegister', ShowRegister)
---#endregion FUNCTIONS

---#region EVENTS
RegisterNetEvent("payments:client:payPopup", function(amount, biller, billtype, reason, jobName)
    local status = lib.alertDialog({
        header = 'Incoming Payment ($'..tostring(amount)..')',
        content = 'Do you want to accept the payment?',
        centered = true,
        cancel = true
    })
    if status == "confirm" then
        TriggerServerEvent("payments:server:payPopup", true, amount, billtype, biller, reason, jobName)
    else
        TriggerServerEvent("payments:server:payPopup", false, amount, billtype, biller, reason, jobName)
    end
end)
---#endregion EVENTS

---#region CALLBACKS
lib.callback.register("payments:requestPayment", function(amount, reason)
    local promise = promise:new()
    SetTimeout(15000, function()
        promise:resolve(false)
        lib.closeInputDialog()
    end)
    local input = lib.inputDialog('Payments Portal', {
        {type = 'input', label = 'Amount', default = amount, icon = 'credit-card', disabled = true},
        {type = 'input', label = 'Reason', default = reason, icon = 'circle-question', disabled = true},
        {type = 'select', label = 'Payment Mode', options = { { value = "cash", label = "Cash" }, { value = "bank", label = "Card" } }, default = "cash", required = true},
    })
    if input and input[3] then promise:resolve(input[3])
    else promise:resolve(false) end
    local response = Citizen.Await(promise)
    return response
end)
---#endregion CALLBACKS

---#region THREADS
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
                if IsJobBoss(self.job) then
                    lib.registerContext({
                        id = 'payments_register',
                        title = self.name,
                        options = {
                            {
                                title = 'Charge Customer',
                                icon = 'fa-solid fa-cash-register',
                                onSelect = function()
                                    ShowChargeMenu(self.job)
                                end
                            },
                            {
                                title = 'Collect Cash',
                                icon = 'fa-solid fa-cash-register',
                                onSelect = function()
                                    OpenCashRegister(self.job)
                                end
                            }
                        }
                    })
                    lib.showContext('payments_register')
                else
                    Notify('You dont have access to this register', 'error')
                end
            end
        end
    end
end)
---#endregion THREADS