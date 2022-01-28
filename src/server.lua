local ESX
local collecting = {}

function Init()
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

Init()

ESX.RegisterServerCallback('o-drug:getData', function(source, cb)
    cb(Config.Data)
end)

function collectingThread(source, data)
	CreateThread(function()
		while true do
			if collecting[source] then
				local xPlayer = ESX.GetPlayerFromId(source)
				if data.phase == 1 then
					Wait(Config.CollectingSpeed)
					local item = xPlayer.getInventoryItem(data.item)
					if item.count >= 250 then
						xPlayer.showNotification('You have maximum amount of ' ..item.label)
					else
						xPlayer.addInventoryItem(data.item, 1)
					end
				else
					Wait(Config.CollectingSpeed)
					local item = xPlayer.getInventoryItem(data.item)
					local newitem = xPlayer.getInventoryItem(data.newitem)
					if newitem.count <= 50 then
						if item.count >= 5 then
							xPlayer.removeInventoryItem(data.item, 5)
							xPlayer.addInventoryItem(data.newitem, 1)
						else
							xPlayer.showNotification('You don´t have enough ' ..item.label.. ' to continue')
						end
					else
						xPlayer.showNotification('You have maximum amount of ' ..newitem.label)
					end
				end
			else
				break
			end
		end
	end)
end

RegisterServerEvent('o-drug:collecting', function(coords, data)
    local xPlayer = ESX.GetPlayerFromId(source)
	local hex = xPlayer.getIdentifer
    local dist = #(coords - data.pos)
    if xPlayer then
        if dist < 5 then
			collecting[source] = true
			collectingThread(source, data)
		else
			webhook('Player triggered event in wrong position (Cheating). **Coords**: '..coords..' .\n**Hex** : '..hex)
            DropPlayer('Cheating')
		end
	end
end)

RegisterServerEvent('o-drug:stop', function()
	collecting[source] = false
end)

function webhook(message)
	local content = {
        {
        	["color"] = '3863105',  
            ["title"] = Config.WebhookTitle,
            ["description"] = message,
            ["footer"] = {
                ["text"] = os.date("%x %X %p")
            }, 
        }
    }
  	PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = content}), { ['Content-Type'] = 'application/json' })
end