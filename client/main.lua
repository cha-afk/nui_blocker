RegisterNUICallback(GetCurrentResourceName(), function()
  TriggerServerEvent(GetCurrentResourceName())
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        TriggerServerEvent(GetCurrentResourceName())
    end
end)
