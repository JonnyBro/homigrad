-- File path to store player models data
local playerModelsFilePath = "homigrad/hg_player_models.txt"
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

function SetPlayerModelBySteamID(steamID, modelDir)
	playerModels[steamID] = modelDir

	SavePlayerModels()
end

function GetPlayerModels()
	return playerModels
end

-- Function to get the model directory for a given SteamID (useful for other parts of the code)
function GetPlayerModelBySteamID(steamID)
	-- print(playerModels[steamID])
	return playerModels[steamID]
end

-- Load player models when the script initializes
LoadPlayerModels()