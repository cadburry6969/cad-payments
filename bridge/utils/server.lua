local webhooks = {
	['police'] = '',
	['ambulance'] = '',
    ['mechanic'] = '',
}

function Notify(src, msg, type)
	if Config.Notify == 'qb' then
        TriggerClientEvent("QBCore:Notify", src, msg, type, 5000)
    elseif Config.Notify == 'ox' then
        TriggerClientEvent("ox_lib:notify", src, { description = msg, type = type, duration = 5000 })
    elseif Config.Notify == 'snappy-phone' then
        TriggerClientEvent('phone:client:notification', src, {
            title = 'Payment Terminal',
            icon = 'cash-register',
            description = msg,
            duration = 5000,
        })
    end
end

function Sendlog(logName, logType, message)
    if not webhooks[logName] then return end
	local _data = json.encode({
        username = "Payments Portal",
        embeds = {
			{
				title = logType,
				color = 10650848,
				author = {
					name = "Cadburry",
				},
				description = message,
				footer = {
					text = os.date('%c'),
				},
			}
		}
    })
	PerformHttpRequest(webhooks[logName], function() end, 'POST', _data, { ['Content-Type'] = 'application/json' })
end

lib.addCommand('give_pos', {
    help = 'Provide POS Machine',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'job',
            type = 'string',
            help = 'Name of the job',
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    if not args.target then return end
    local jobName = args.job and GetJobLabel(args.job) or nil
    local itemName = (args.job and 'businesspos') or 'generalpos'
    AddItem(args.target, itemName, 1, { job = args.job, jobName = jobName })
end)