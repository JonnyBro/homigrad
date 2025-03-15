--[[
TODO:
 - Networking of saved data on client
 - Applying appearance
--]]
util.AddNetworkString("EasyAppearance_SendData")
util.AddNetworkString("EasyAppearance_SendReqData")

EasyAppearance = EasyAppearance or {}

net.Receive("EasyAppearance_SendData", function(len, ply)
	ply.bRandomAppearance = net.ReadBool()
	ply.tAppearance = net.ReadTable()
	-- PrintTable(ply.tAppearance)
	-- print(ply.bRandomAppearance)
end)

--[[
local tDefaultAppearance = {
	strModel = "Male 01",
	strColthesStyle = "Casual 1"
} --]]

function EasyAppearance.GetRandomAppearance()
	local tRandomAppearance = {}

	tRandomAppearance.strModel = RandomFromTable(table.GetKeys(EasyAppearance.Models))
	tRandomAppearance.strPath = EasyAppearance.Models[tRandomAppearance.strModel].strPatch
	tRandomAppearance.strColthesStyle = "Random"

	return tRandomAppearance
end

function EasyAppearance.SendRequest(ply)
	net.Start("EasyAppearance_SendReqData")
	net.Send(ply)
end

local function DoInvalid(ply)
	ply:ChatPrint("Your appearance is not valid. Check Appearance menu or delete data/homigrad/appearancedata.json.\nYour appearance set as random.")

	ply.tAppearance = EasyAppearance.GetRandomAppearance()

	return ply.tAppearance
end

function EasyAppearance.SetAppearance(ply)
	if not ply:IsBot() and ply:GetInfo("hg_usecustommodel") == "false" then
		EasyAppearance.SendRequest(ply)

		if ply.bRandomAppearance then ply.tAppearance = EasyAppearance.GetRandomAppearance() end

		local tAppearance = ply.tAppearance
		if not tAppearance then
			ply.tAppearance = EasyAppearance.GetRandomAppearance()
			tAppearance = ply.tAppearance
		end

		if not EasyAppearance.Models[tAppearance.strModel] then tAppearance = DoInvalid(ply) end

		local tModelParms = EasyAppearance.Models[tAppearance.strModel]
		ply:SetModel(tModelParms.strPatch)

		local sex = EasyAppearance.Sex[ply:GetModelSex()]
		if not EasyAppearance.Appearances[sex][tAppearance.strColthesStyle] or tAppearance.strColthesStyle == "Random" then tAppearance.strColthesStyle = RandomFromTable(table.GetKeys(EasyAppearance.Appearances[sex])) end

		ply:SetSubMaterial()
		ply:SetSubMaterial(tModelParms.intSubMat, EasyAppearance.Appearances[sex][tAppearance.strColthesStyle])

		EasyAppearance.SendRequest(ply)
	else
		local selectedModel = ply:GetInfo("cl_playermodel") -- Retrieve the model selected by the player
		local modelToUse = ply:IsBot() and EasyAppearance.GetRandomAppearance().strPath or player_manager.TranslatePlayerModel(selectedModel)

		if modelToUse == "models/player/kleiner.mdl" then return print("Model being utilised is invalid. Most likely set to another model we don't have on the server!") end

		ply:SetSubMaterial()
		ply:SetModel(modelToUse)
	end
end