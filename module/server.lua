local CashRegister = {}

---#region JSON FETCH
local resource_name = GetCurrentResourceName()
function GetFile()
    local loaded_data = LoadResourceFile(resource_name, "register.json")
    local file_data = json.decode(loaded_data or '{}')
    return file_data
end

function AddJson(itemname, itemcontent)
    local loaded_data = LoadResourceFile(resource_name, "register.json")
    local file_data = json.decode(loaded_data or '{}')
    file_data[itemname] = itemcontent
    SaveResourceFile(resource_name, "register.json", json.encode(file_data, { indent = true }), -1)
end

function UpdateJson(itemname, itemcontent)
    local loaded_data = LoadResourceFile(resource_name, "register.json")
    local file_data = json.decode(loaded_data or '{}')
    if file_data[itemname] ~= nil then
        file_data[itemname] = itemcontent
        SaveResourceFile(resource_name, "register.json", json.encode(file_data, { indent = true }), -1)
    else
        print("[" .. resource_name .. "] Attempted to replace a non-existing item.")
        return
    end
end
---#endregion JSON FETCH

---#region PAYMENTS
CashRegister = GetFile()

RegisterNetEvent("payments:server:collectCashinRegister", function(businessName, amount)
    local source = source
    amount = math.abs(amount)
	if CashRegister[businessName] and CashRegister[businessName] > 0 then
        if CashRegister[businessName] >= amount then
            local player = GetPlayer(source)
            if player.addMoney('cash', amount, string.format('Collected from %s register', businessName)) then
                CashRegister[businessName] = CashRegister[businessName] - amount
                UpdateJson(businessName, CashRegister[businessName])
            else
                Notify(source, "Your hands arent empty to have more cash", "error")
            end
        else
            Notify(source, "Register doesnt have money", "error")
        end
    else
        CashRegister[businessName] = 0
        UpdateJson(businessName, 0)
    end
end)

lib.callback.register("payments:server:checkCash", function(source, businessName)
    return CashRegister[businessName] or 0
end)

RegisterNetEvent("payments:server:charge", function(target, price, reason, billtype, businessName)
    local source = source
	local coords1 = GetEntityCoords(GetPlayerPed(source))
	local coords2 = GetEntityCoords(GetPlayerPed(target))
	if #(coords1 - coords2) < 5.0 then
        price = math.abs(price)
        local tChar = GetPlayer(target)
        if billtype == "cash" then
            if tChar.cash < price then
                Notify(source, "Customer doesn't have enough money to pay", "error")
                Notify(target, "Insufficient balance", "error")
                return
            end
        elseif billtype == "bank" then
            local balance = tChar.bank
            if balance < price then
                Notify(source, "Customer doesn't have enough money to pay", "error")
				Notify(target, "You don't have enough money to pay", "error")
				return
            end
        end
        TriggerClientEvent("payments:client:payPopup", target, price, source, billtype, reason, businessName)
	else
		Notify(source, "Customer is not near!", 'error')
	end
end)

RegisterNetEvent("payments:server:payPopup", function(hasaccept, amount, billtype, biller, reason, businessName)
    local source = source
    local player = GetPlayer(source)
    if not player then return end
    local tplayer = GetPlayer(biller)
    if not tplayer then return end
	if hasaccept then
        amount = math.abs(amount)
        local commission = 0
        if Config.RegisterComissions[businessName] then
            commission = lib.math.round(amount*Config.RegisterComissions[businessName])
        end
        local earnings = lib.math.round(amount-commission)
        if billtype == "cash" then
            player.removeMoney('cash', lib.math.round(amount))
            if commission > 0 then tplayer.addMoney('cash', commission, "Recieved commision on a payment") end
            if CashRegister[businessName] then
                CashRegister[businessName] = CashRegister[businessName] + earnings
                UpdateJson(businessName, CashRegister[businessName])
            else
                CashRegister[businessName] = earnings
                AddJson(businessName, earnings)
            end
            Sendlog(businessName, 'Recieved Payment (Bank) (Register)', string.format("%s charged %s for $%d", player.name, tplayer.name, amount))
        else
            RemoveBalanceWithTax(source, amount, reason, string.format("Recieved Payment through Register (%s)", player.name), businessName, earnings)
            if commission > 0 then tplayer.addMoney('bank', commission, "Recieved commision on a payment") end
            Sendlog(businessName, 'Recieved Payment (Bank) (Register)', string.format("%s charged %s for $%d", player.name,  tplayer.name, amount))
        end
		Notify(biller, "("..tostring(source)..") accepted the payment", "success")
	else
		Notify(source, "You declined the payment")
		Notify(biller, "("..tostring(source)..") declined the payment", "error")
	end
end)

RegisterNetEvent('payments:server:sendPaymentRequest', function(rdata, businessName)
    local source = source
    local playerId = rdata[1]
    local coords1 = GetEntityCoords(GetPlayerPed(source))
	local coords2 = GetEntityCoords(GetPlayerPed(playerId))
	if #(coords1 - coords2) < 5.0 then
        local amount = math.abs(rdata[2])
        local reason = rdata[3]
        local billtype = rdata[4]
        local sChar = GetPlayer(source)
        local tChar = GetPlayer(playerId)
        local displayName = businessName or sChar.name
        lib.callback('phone:client:receiveConfirmationPopup', playerId, function(data)
            if data.status then
                if billtype == "cash" then
                    if not HasItem(playerId, 'money', amount) then
                        Notify(playerId, "You dont have enough money", "error")
                        Notify(source, 'Person doesnt have enough money', 'error')
                        return
                    end
                    tChar.removeMoney('cash', amount, reason)
                    Notify(source, 'Person has accepted the payment', 'success')
                    print(businessName)
                    if businessName then
                        local commision = 0
                        if Config.POSCommissions[businessName] then
                            commision = lib.math.round(amount*Config.POSCommissions[businessName], 2)
                            if commision > 0 then sChar.addMoney('cash', commision, 'Recieved commision from '..businessName) end
                        end
                        local earnings = amount-commision
                        AddMoneyToAccount(businessName, earnings, string.format("Recieved Payment through POS by %s (%s)", sChar.name, tChar.name))
                        Sendlog(businessName, 'Recieved Payment (Cash) (POS)', string.format("%s charged %s for $%d", sChar.name, tChar.name, amount))
                    else
                        sChar.addMoney('cash', amount, string.format("Recieved Payment through POS (%s)", sChar.name))
                    end
                elseif billtype == "bank" then
                    local balance = tChar.bank
                    if balance < amount then
                        Notify(playerId, "You dont have enough balance", "error")
                        Notify(source, 'Person doesnt have enough balance', 'error')
                        return
                    end
                    if businessName then
                        local commision = 0
                        if Config.POSCommissions[businessName] then
                            commision = lib.math.round(amount*Config.POSCommissions[businessName], 2)
                            if commision > 0 then sChar.addMoney('bank', commision, 'Recieved commision from '..businessName) end
                        end
                        local earnings = amount-commision
                        RemoveBalanceWithTax(playerId, amount, string.format("%s (%s)", reason, sChar.name), string.format("Received Payment (POS) from %s for %s", sChar.name, reason), businessName, earnings)
                        Sendlog(businessName, 'Recieved Payment (Bank) (POS)', string.format("%s charged %s for $%d (Reason: %s)", sChar.name, tChar.name, amount, reason))
                    else
                        RemoveBalanceWithTax(playerId, amount, string.format("%s (%s)", reason, sChar.name))
                        sChar.addMoney('bank', amount, string.format("Recieved Payment through POS (%s)", sChar.name))
                    end
                    Notify(source, 'Person has accepted the payment', 'success')
                end
            else
                Notify(source, 'Person rejected the payment', 'error')
            end
        end, {title = 'Payment Request: '..string.upper(displayName), description = string.format('Payment of $%d requested for %s', amount, reason),icon = 'credit-card'})
    else
        Notify(source, 'Person too far', 'error')
    end
end)
---#endregion PAYMENTS

---#region EXPORTS
exports('ChargeMoney', function(playerId, amount, reason)
    if amount and amount < 0 then return end
    if reason == nil then reason = "POS - SWIPEONGO" end
    local player = GetPlayer(playerId)
    local billtype = lib.callback.await('payments:requestPayment', playerId, amount, reason, 'timeout:15000')
    if billtype == "cash" then
        if not HasItem(playerId, 'money', amount) then
            Notify(playerId, "You dont have enough money", "error")
            return false
        end
        player.removeMoney('cash', amount, reason)
        return true
    elseif billtype == "bank" then
        local balance = player.bank
        if balance < amount then
            Notify(playerId, "You dont have enough balance", "error")
            return false
        end
        RemoveBalanceWithTax(playerId, amount, reason, false, false)
        return true
    end
    return false
end)
---#endregion EXPORTS

---#region TAXATION
local Taxation = Config.Taxation
-- Removes the tax & amount from the player for the amount specified
function RemoveBalanceWithTax(src, amount, reason, businessReason, businessName, earnings, dontTakeFee)
    local percent = 0
    local char = GetPlayer(src)
    if not dontTakeFee then
        local money = char.bank
        for _, data in pairs(Taxation) do
            if money >= data.amount then
                percent = data.percent
                break
            end
        end
    end
    if businessName then
        if not earnings then earnings = amount end
        AddMoneyToAccount(businessName, earnings, businessReason or ('Payment recieved from '..char.name))
    end
    businessName = businessName or 'SWIPE'
    if not reason then reason = "POS - "..tostring(businessName) end
    local cardfee = 0
    if Config.CardPaymentFee and not dontTakeFee then
        cardfee = lib.math.round(amount * Config.CardPaymentFee, 2)
        amount = amount + cardfee
        AddMoneyToAccount(Config.CardFeeAccount, cardfee, "Card Fee Recieved From "..char.name)
    end
    local taxamount = lib.math.round(amount * percent)
    local totalamount = lib.math.round(amount + taxamount, 2)
    char.removeMoney('bank', totalamount, reason)
    AddMoneyToAccount(Config.TaxAccount, taxamount, "Payment tax recieved from "..char.name)
    Notify(src, 'You were charged $'..totalamount..' with $'..cardfee..' card fee and '..percent..'% tax.')
end
exports("RemoveBalanceWithTax", RemoveBalanceWithTax)

-- returns TaxBracket, TaxPercent
function GetTaxBracket(src)
    local player = GetPlayer(src)
    local money = player.bank
    for bracket, data in pairs(Taxation) do
        if money >= data.amount then
            return bracket, data.percent
        end
    end
    return "none", 0
end
exports("GetTaxBracket", GetTaxBracket)
---#endregion TAXATION