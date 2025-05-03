hg.GuiltTable = hg.GuiltTable or {}

function GuiltLogic(ply, att, dmgInfo, dontApply)
	-- if ply.RoundGuilt > 10 then return end
	if att == ply then return end
	if not roundActive then return end

	local resultGame = TableRound().GuiltLogic
	resultGame = resultGame and resultGame(ply, att, dmgInfo)
	if resultGame == false then return end

	local resultClass = ply:PlayerClassEvent("GuiltLogic", att, dmgInfo)
	if resultClass == false then return end

	local plyTeam = ply:Team()
	local attTeam = att:Team()

	if resultGame or resultClass or plyTeam == attTeam then
		if ply.DontGuiltProtect then
			--[[
			if not dontApply then
				att.Guilt = math.max(att.Guilt - dmgInfo:GetDamage(), 0)
			end --]]

			return false, true
		end

		if not dontApply then
			local customGuiltAdd = (type(resultGame) == "number" and resultGame or (resultGame == false and 0 or 1)) * (type(resultClass) == "number" and resultClass or (resultClass == false and 0 or 1))
			hg.GuiltTable[att] = hg.GuiltTable[att] or {}
			hg.GuiltTable[att][ply] = hg.GuiltTable[att][ply] or 0

			local oldguilt = hg.GuiltTable[att][ply]
			local add = customGuiltAdd * dmgInfo:GetDamage() / 3
			hg.GuiltTable[att][ply] = math.Clamp(hg.GuiltTable[att][ply] + add, 0, 50)

			local add_final = hg.GuiltTable[att][ply] - oldguilt

			att.Guilt = (att.Guilt or 0) + add_final
			GuiltCheck(att, ply)
		end

		return true
	end

	return false
end

hook.Add("HomigradStartRound", "Guilt", function()
	hg.GuiltTable = {}
end)

local validUserGroup = {
	superadmin = true,
	admin = true,
	megapenis = true,
	servermanager = true,
	owner = true,
}

function GuiltCheck(att, ply)
	guiltVal = 100

	if att.Guilt >= guiltVal then
		att.Guilt = 0

		if not att:HasGodMode() and att:Alive() then
			-- RunConsoleCommand("ulx", "asay", "[AUTOMATED] " .. att:Name() .. " has exceeded their guilt of 100%. They are on team " .. tostring(att:Team()))
			-- print("[GUILT CHECK] " .. att:Name() .. " has exceeded their guilt of 100%. They are on team " .. tostring(att:Team()))
			if not validUserGroup[att:GetUserGroup()] then
				att:Kill()

				RunConsoleCommand("ulx", "tsay", ":<clr:red>[GUILT] " .. att:Name() .. " has been slayed for exceeding their guilt of 100%.")

				return
			else
				return
			end
		end
	end
end

hook.Add("HomigradDamage", "guilt-logic", function(ply, hitGroup, dmgInfo, rag)
	local att = ply.LastAttacker

	if ply and att then
		GuiltLogic(ply, att, dmgInfo)
	end
end)

hook.Add("Should Fake Collide", "guilt", function(ply, hitEnt, data)
	if hitEnt == game.GetWorld() then return end
	hitEnt = RagdollOwner(hitEnt) or hitEnt
	if not hitEnt:IsPlayer() then return end

	local dmgInfo = DamageInfo()
	dmgInfo:SetAttacker(hitEnt)
	dmgInfo:SetDamage(10)
	dmgInfo:SetDamageType(DMG_CRUSH)

	GuiltLogic(ply, hitEnt, dmgInfo)
end)

hook.Add("Player Spawn", "hg_sendguilt", function(ply)
	ply.Guilt = ply.Guilt or 0

	if validUserGroup[ply:GetUserGroup()] then
		net.Start("hg_sendchat_format")
			net.WriteTable({"#hg.guilt.yourguilt", tostring(math.Round(ply.Guilt, 0))})
		net.Send(ply)
	end

	ply.RoundGuilt = 0
end)

hook.Add("PlayerInitialSpawn", "lololo", function(ply)
	ply.Guilt = ply:GetPData("Guilt") or 0
end)

--[[
local function Seizure(ply)
	ply.Seizure = true

	ply:ChatPrint("You are experiencing a seizure.")

	if not IsValid(ply.FakeRagdoll) then
		Faking(ply)
	end

	timer.Create("seizure" .. ply:EntIndex(), math.random(7, 15), 1, function()
		if ply:IsValid() and ply:Alive() then
			ply:Kill()
		end
	end)
end --]]

hook.Add("PlayerSpawn", "guilt", function(ply)
	if PLYSPAWN_OVERRIDE then return end

	ply.DontGuiltProtect = nil
	ply.Seizure = false
	ply.Guilt = ply.Guilt or 0

	-- ply:ChatPrint("Your guilt is currently at " .. tostring(math.floor(ply.Guilt + 0.5)) .. "% out of 100%")
	--[[
	if ply.Guilt > 30 then
		timer.Create("seizure" .. ply:EntIndex(), math.random(30, 50), 1, function()
			Seizure(ply)
		end)
	end --]]
end)

hook.Add("PlayerDisconnected", "guiltasd", function(ply)
	ply:SetPData("Guilt", ply.Guilt)
end)

hook.Add("Player Think", "guilt reduction", function(ply, time)
	ply.GuiltReductionCooldown = ply.GuiltReductionCooldown or time

	if ply.GuiltReductionCooldown < time then
		ply.GuiltReductionCooldown = time + 5
		ply.Guilt = math.max((ply.Guilt or 0) - 1, 0)
	end
end)

concommand.Add("hg_getguilt", function(ply)
	local text = "Guilt information\n"

	for _, ply in player.Iterator() do
		text = text .. ply:Name() .. ": " .. ply.Guilt .. "\n"
	end

	ply:ChatPrint(text)
end)