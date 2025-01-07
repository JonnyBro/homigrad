-- File path to store player models data
local playerModelsFilePath = "hg_player_models.txt"
local playerModels = {}

-- Function to load player models from file
local function LoadPlayerModels()
	if file.Exists(playerModelsFilePath, "DATA") then
		local data = file.Read(playerModelsFilePath, "DATA")

		playerModels = util.JSONToTable(data) or {}

		print("[HG] Player models loaded successfully.")
	else
		print("[HG] No existing player model data found. Starting fresh.")
	end
end

-- Function to save player models to file
local function SavePlayerModels()
	local data = util.TableToJSON(playerModels, true)

	file.Write(playerModelsFilePath, data)

	print("[HG] Player models saved successfully.")
end

-- Function to check if a player is authorized (servermanager or owner)
local function IsAuthorized(ply)
	return ply:IsUserGroup("servermanager") or ply:IsUserGroup("owner") or ply:IsUserGroup("superadmin")
end

-- Command to assign or overwrite a player model for a given SteamID
concommand.Add("hg_playermodel", function(ply, cmd, args)
	if not IsAuthorized(ply) then return ply:ChatPrint("You do not have permission to use this command.") end

	local steamID = args[1]
	local modelDir = args[2]

	if not steamID or not modelDir then return ply:ChatPrint("Usage: hg_playermodel <SteamID> <Model Directory>") end

	-- Store or overwrite the player model for the SteamID
	playerModels[steamID] = modelDir

	SavePlayerModels()

	ply:ChatPrint("Player model for " .. steamID .. " set to " .. modelDir)
end)

-- Command to remove a player model associated with a given SteamID
concommand.Add("hg_removemodel", function(ply, cmd, args)
	if not IsAuthorized(ply) then return ply:ChatPrint("You do not have permission to use this command.") end

	local steamID = args[1]

	if not steamID then return ply:ChatPrint("Usage: hg_removemodel <SteamID>") end

	if playerModels[steamID] then
		playerModels[steamID] = nil

		SavePlayerModels()

		ply:ChatPrint("Player model for " .. steamID .. " has been removed.")
	else
		ply:ChatPrint("No player model found for " .. steamID)
	end
end)

-- Command to list all SteamIDs and their assigned player models
concommand.Add("hg_listmodels", function(ply, cmd, args)
	if not IsAuthorized(ply) then return ply:ChatPrint("You do not have permission to use this command.") end

	if table.Count(playerModels) == 0 then return ply:ChatPrint("No player models have been assigned.") end

	ply:ChatPrint("Assigned Player Models:")

	for steamID, modelDir in pairs(playerModels) do
		ply:ChatPrint(steamID .. ": " .. modelDir)
	end
end)

-- Function to get the model directory for a given SteamID (useful for other parts of the code)
function GetPlayerModelBySteamID(steamID)
	-- print(playerModels[steamID])
	return playerModels[steamID]
end

-- Load player models when the script initializes
LoadPlayerModels()