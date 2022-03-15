local ESX
local interacting = false
local serverData = {}

function Init()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    print("^3[INFO]: ^7ESX initialized")
    getData()
    mainThread()
end

AddEventHandler('onClientResourceStart', function(eventName)
    if GetCurrentResourceName() == eventName then
        CreateThread(function()
            Wait(120000)
            Init()
        end)
    end
end)

function mainThread()
    print("^3[INFO]: ^7Main thread started")
    CreateThread(function()
        repeat Wait(150) until serverData ~= {}
        local ped = PlayerPedId()
        while true do
            local coords = GetEntityCoords(ped)
            local closest = { 
                dist = math.huge,
                data = nil
            }
            for k,v in pairs(serverData) do
                closest = closest.dist > #(coords - v.pos) and { dist = #(coords - v.pos), data = v } or closest
            end
            if closest ~= nil then
                if closest.dist > 3 then
                    local speed = GetEntitySpeed(ped)
                    -- Author: fait
                    Wait((closest.dist < 100 and 250 or closest.dist / (speed / 5 < 5 and 1 or speed / 5)) % 7500)
                else
                    Wait(1)
                    Draw3DText(closest.data.pos, '[E] - Collect drugs', 0.4)
                    if IsControlJustReleased(1, 51) and not interacting then
                        interacting = true
                        ClearPedTasks(ped)
                        TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
                        TriggerServerEvent('o-drug:collecting', coords, closest.data)
                        ESX.ShowHelpNotification('~INPUT_VEH_DUCK~ Stop collecting')
                    end
                    if interacting then
                        if IsControlJustPressed(0, 73) then
                            ClearPedTasks(ped)
                            TriggerServerEvent('o-drug:stop')
                            interacting = false
                        end
                    end
                end
            end
        end
    end)
end
    
function getData()
    ESX.TriggerServerCallback('o-drug:getData', function(data)
        serverData = data
    end)
end

function Draw3DText(coords, text, scale)
	local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
	SetTextScale(scale, scale)
	SetTextOutline()
	SetTextDropShadow()
	SetTextDropshadow(2, 0, 0, 0, 255)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry('STRING')
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 215)
	AddTextComponentString(text)
	DrawText(x, y)
    local factor = (string.len(text)) / 400
    DrawRect(x, y+0.012, 0.015+ factor, 0.03, 0, 0, 0, 68)
end
