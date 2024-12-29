function ExtractIdentifiers(src)
    
    local identifiers = {
        steam = "",
        ip = "",
        discord = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        end
    end

    return identifiers
end

local logs = "YOUR-WEBHOOK HERE"

local kick_msg = "Hmm, what you wanna do in this inspector?"
local discord_msg = '`Player try to use nui_devtools`\n`and he got a kick`\n`ANTI NUI_DEVTOOLS`'
local color_msg = 16767235

function sendToDiscord (source,message,color,identifier)
    
    local name = GetPlayerName(source)
    if not color then
        color = color_msg
    end
    local sendD = {
        {
            ["color"] = color,
            ["title"] = message,
            ["description"] = "Steam: **"..identifier.steam.."** \nIP: **"..identifier.ip.."**\nDiscord: **"..identifier.discord.."**",
            ["footer"] = {
                ["text"] = "© QamarQ & vjuton - "..os.date("%x %X %p")
            },
        }
    }

    PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "YourRP - Anti nui_devtools", embeds = sendD}), { ['Content-Type'] = 'application/json' })
end

local checkedPlayers = {}

RegisterServerEvent(GetCurrentResourceName())
AddEventHandler(GetCurrentResourceName(), function()
    local _source = source
    
    if checkedPlayers[_source] then return end
    
    local identifier = ExtractIdentifiers(_source)
    local identifierDb
    if extendedVersionV1Final then
        identifierDb = identifier.license
    else
        identifierDb = identifier.steam
    end

    if checkmethod == 'steam' then
        if json.encode(allowlist) == "[]" then
            sendToDiscord (_source, discord_msg, color_msg, identifier)
            DropPlayer(_source, kick_msg)
            return
        end
        
        local isAllowed = false
        for _, v in pairs(allowlist) do
            if v == identifierDb then
                isAllowed = true
                break
            end
        end
        
        if not isAllowed then
            sendToDiscord (_source, discord_msg, color_msg, identifier)
            DropPlayer(_source, kick_msg)
            return
        end
        
    elseif checkmethod == 'SQL' then
        MySQL.Async.fetchAll("SELECT group FROM characters WHERE identifier = @identifier",{['@identifier'] = identifierDb }, function(results) 
            if not results[1] or (results[1].group ~= 'admin' and results[1].group ~= 'moderator') then
                sendToDiscord (_source, discord_msg, color_msg, identifier)
                DropPlayer(_source, kick_msg)
                return
            end
            checkedPlayers[_source] = true
        end)
    end
    
    if checkmethod == 'steam' then
        checkedPlayers[_source] = true
    end
end)

AddEventHandler('playerDropped', function()
    local _source = source
    checkedPlayers[_source] = nil
end)
