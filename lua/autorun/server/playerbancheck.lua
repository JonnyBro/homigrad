if not util.IsBinaryModuleInstalled("mysqloo") then return end

local STEAM_API_KEY = "#####" -- Don't use your main account steam key.

-- clueless
local databaseConfig = {
    host = "IPADDRESS",
    port = 3306,
    username = "USERNAME",
    password = "PASSWORD",
    database = "DATABASE_NAME"
}

-- SQL Setup
require("mysqloo")
local database = mysqloo.connect(databaseConfig.host, databaseConfig.username, databaseConfig.password, databaseConfig.database, databaseConfig.port)

local function onDatabaseConnected()
    print("Connected to the SQL database.")
    database:query("CREATE TABLE IF NOT EXISTS whitelist (steamID VARCHAR(32) PRIMARY KEY)"):start()
end

local function onDatabaseConnectionFailed(err)
    print("Failed to connect to the database: " .. err)
end

database.onConnected = onDatabaseConnected
database.onConnectionFailed = onDatabaseConnectionFailed
database:connect()

-- Function to load the whitelist from SQL
local function LoadWhitelist(ply, callback)
    if not IsValid(ply) then return end

    local queryStr = [[SELECT steamID FROM whitelist WHERE steamID = %s]]
    local query = database:query(queryStr:format(ply:SteamID64()))

    query.onSuccess = function(q, data)
        callback(data[1])
    end

    query.onError = function(q, err)
        print("Failed to load whitelist: " .. err)
        callback("")
    end

    query:start()
end

-- Function to add a SteamID to the SQL whitelist
local function AddToWhitelist(steamID)
    local query = database:query("INSERT IGNORE INTO whitelist (steamID) VALUES (" .. database:escape(steamID) .. ")")

    query.onSuccess = function()
        print("SteamID " .. steamID .. " has been added to the whitelist.")
    end

    query.onError = function(q, err)
        print("Failed to add SteamID to whitelist: " .. err)
    end

    query:start()
end

-- Console command to add a SteamID to the whitelist
concommand.Add("forgive", function(ply, cmd, args)
    if IsValid(ply) then
        -- Check player permissions
        local userGroup = ply:GetUserGroup()
        if not (userGroup == "superadmin" or userGroup == "owner" or userGroup == "servermanager" or userGroup == "admin") then
            ply:ChatPrint("You do not have permission to use this command.")
            return
        end
    end

    local steamID = args[1]
    if not steamID then
        print("Usage: forgive <SteamID>")
        return
    end

    AddToWhitelist(steamID)
end)

-- Function to check ownership and VAC/Game bans
local function CheckPlayerDetails(ply)
    if not ply:IsPlayer() then return end

    local steamID = ply:SteamID()
    local steamID64 = ply:SteamID64()
    local userGroup = ply:GetUserGroup()

    -- Check user group exemptions
    local exemptGroups = { ["tmod"] = true, ["operator"] = true, ["admin"] = true, ["superadmin"] = true, ["servermanager"] = true, ["owner"] = true }
    if exemptGroups[userGroup] then
        --print("Player ", ply:Nick(), " (SteamID: ", steamID, ") is in an exempt user group and bypassed checks.")
        return
    end

    -- Check if the player owns the game
    if steamID64 ~= ply:OwnerSteamID64() then
        ply:Kick("[Harrison's Homigrad] You cannot join this server because you do not own Garry's Mod, and are playing via a Family Share account.\nTo become whitelisted, you can appeal at https://discord.gg/harrisonshomigrad")
        return
    end

    -- Check VAC/Game bans using Steam Web API
    local apiUrl = string.format("https://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=%s&steamids=%s", STEAM_API_KEY, steamID64)

    http.Fetch(apiUrl,
        function(body)
            local data = util.JSONToTable(body)

            if data and data.players and #data.players > 0 then
                local banData = data.players[1]

                if banData.VACBanned or banData.NumberOfGameBans > 0 then
                    ply:Kick("[Harrison's Homigrad] You cannot join this server due to VAC or Game Ban on your account.\nTo become whitelisted, you can appeal at https://discord.gg/harrisonshomigrad")
                else
                    print("Player ", ply:Nick(), " (SteamID: ", steamID, ") is clean.")
                end
            else
                print("Failed to fetch ban data for SteamID: ", steamID)
            end
        end,
        function(error)
            print("HTTP request failed for SteamID: ", steamID, ", Error: ", error)
        end
    )
end

-- Hook into the player join event
hook.Add("PlayerInitialSpawn", "CheckPlayerOwnershipAndatabaseans", function(ply)
    timer.Simple(2, function() -- Delay to ensure player entity is fully initialized
        print("Timer:"..ply:SteamID64())
        LoadWhitelist(ply, function(result)
            print("Load:"..ply:SteamID64())
            if result and whitelist[result] then
                return
            else
                CheckPlayerDetails(ply)
            end
        end)
    end)
end)
