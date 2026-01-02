local function GetTraitorsNames()
	local tbl = {}

	for _, plr in pairs(homicide.t) do
		table.insert(tbl, plr:Name())
	end

	return tbl
end

COMMANDS.homicide_get = {
	function(ply, args)
		if not ply:IsAdmin() then return end
		-- if ply:Alive() then return end
		-- if ply:Team() ~= 1002 then return end

		local role = {{}, {}}

		for _, ply in pairs(team.GetPlayers(1)) do
			if ply.roleT then
				table.insert(role[1], ply)
			end

			if ply.roleCT then
				table.insert(role[2], ply)
			end
		end

		net.Start("homicide_roleget")
			net.WriteTable(role)
		net.Send(ply)
	end
}

local function makeT(ply)
	if not IsValid(ply) then return end

	ply.roleT = true

	table.insert(homicide.t, ply)

	if homicide.roundType == 1 or homicide.roundType == 2 then
		local wep = ply:Give("weapon_hk_usps")

		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(wep:GetMaxClip1() * 1, wep:GetPrimaryAmmoType(), true)

		if math.random(1, 2) == 2 then ply:Give("weapon_hg_t_vxpoison") else ply:Give("weapon_hg_t_syringepoison") end
		if math.random(1, 2) == 2 then ply:Give("weapon_hidebomb") else ply:Give("weapon_suicidevest") end
		ply:Give("weapon_hg_rgd5")
		ply:Give("weapon_kabar")
		ply:Give("weapon_radar")
	elseif homicide.roundType == 3 then
		local wep = ply:Give("weapon_hg_crossbow")

		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(wep:GetMaxClip1() * 8, "XBowBolt", true)

		if math.random(1, 2) == 2 then ply:Give("weapon_hg_t_vxpoison") else ply:Give("weapon_hg_t_syringepoison") end
		if math.random(1, 2) == 2 then ply:Give("weapon_hidebomb") else ply:Give("weapon_suicidevest") end
		ply:Give("weapon_hg_rgd5")
		ply:Give("weapon_kabar")
		ply:Give("weapon_radar")
	elseif homicide.roundType == 5 then
		local wep = math.random(1, 2) == 1 and ply:Give("weapon_scout") or ply:Give("weapon_barret")

		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(wep:GetMaxClip1() * 2, wep:GetPrimaryAmmoType(), true)

		if math.random(1, 2) == 2 then ply:Give("weapon_hg_t_vxpoison") else ply:Give("weapon_hg_t_syringepoison") end
		if math.random(1, 2) == 2 then ply:Give("weapon_hidebomb") else ply:Give("weapon_suicidevest") end
		ply:Give("weapon_hg_rgd5")
		ply:Give("weapon_kabar")
		ply:Give("weapon_radar")
	else
		local wep = ply:Give("weapon_mateba")

		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(wep:GetMaxClip1() * 2, wep:GetPrimaryAmmoType(), true)

		if math.random(1, 2) == 2 then ply:Give("weapon_hg_t_vxpoison") else ply:Give("weapon_hg_t_syringepoison") end
		if math.random(1, 2) == 2 then ply:Give("weapon_hidebomb") else ply:Give("weapon_suicidevest") end
		ply:Give("weapon_hg_rgd5")
		ply:Give("weapon_kabar")
		ply:Give("weapon_radar")
	end

	--[[
	timer.Simple(1, function()
		ply.allowFlashlight = true
	end) --]]
end

local function makeCT(ply)
	if not IsValid(ply) then return end

	ply.roleCT = true

	table.insert(homicide.ct, ply)

	if homicide.roundType == 1 or homicide.roundType == 5 then
		local wep = ply:Give("weapon_remington870")

		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(wep:GetMaxClip1() * 1, wep:GetPrimaryAmmoType(), true)
	elseif homicide.roundType == 2 then
		local wep = ply:Give("weapon_beretta")

		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(wep:GetMaxClip1(), wep:GetPrimaryAmmoType(), true)
	elseif homicide.roundType == 3 then
		local wep = ply:Give("weapon_taser")

		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(wep:GetMaxClip1() * 3, wep:GetPrimaryAmmoType(), true)

		ply:Give("weapon_police_bat")
	elseif homicide.roundType == 4 then
		local wep = ply:Give("weapon_mateba")

		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(wep:GetMaxClip1() * 2, wep:GetPrimaryAmmoType(), true)
	end
end

COMMANDS.russian_roulette = {
	function(ply, args)
		if not ply:IsAdmin() then return end

		for _, plr in pairs(player.GetListByName(args[1], ply)) do
			local wep = plr:GetWeapon("weapon_mateba") or plr:Give("weapon_mateba", true)
			wep:SetClip1(1)
			wep:RollDrum()
		end
	end
}

function homicide.Spawns()
	local points = {}

	for _, point in pairs(ReadDataMap("regular")) do
		table.insert(points, point)
	end

	return points
end

sound.Add({
	name = "police_arrive",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = 100,
	sound = "snd_jack_hmcd_policesiren.wav"
})

local prePolicePlayers = {}

util.AddNetworkString("homicide_support_arrival")

function NotifySupportArrival(ply, arrivalTime)
	net.Start("homicide_support_arrival")
		net.WriteFloat(arrivalTime)
	net.Send(ply)
end

function TryAssignPolice(ply)
	local maxPolice = homicide.roundType == 1 and 5 or 12

	if #prePolicePlayers >= maxPolice then return end
	if homicide.police then return end
	if ply.roleT then return end
	if math.random() > 0.60 then return end

	if not ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
		table.insert(prePolicePlayers, ply)
		NotifySupportArrival(ply, roundTimeStart + roundTime)
	end
end

function SpawnPolicePlayers()
	local points = ReadDataMap("spawnpointsct")
	local playsound = true
	local prePolicePlayers = PlayersDead(true)
	if not prePolicePlayers or table.IsEmpty(prePolicePlayers) then return end

	local ply = prePolicePlayers[1]
	homicide.police = true

	timer.Simple(0, function()
		if homicide.roundType == 1 then
			net.Start("hg_sendchat_simple")
				net.WriteString("#hg.modes.team.swathere")
			net.Broadcast()
		else
			net.Start("hg_sendchat_simple")
				net.WriteString("#hg.modes.team.policehere")
			net.Broadcast()
		end

		if playsound then
			ply:EmitSound("police_arrive")

			playsound = false
		end
	end)

	tdm.SpawnCommand(prePolicePlayers, points, function(ply)
		timer.Simple(0, function()
			if homicide.roundType == 1 then ply:SetPlayerClass("contr")
			else ply:SetPlayerClass("police") end

			net.Start("hg_sendchat_format")
				net.WriteTable({
					"#hg.homicide.traitors",
					#homicide.t > 1 and table.concat(GetTraitorsNames(), ", ") or homicide.t[1]:Name()
				})
			net.Send(ply)
		end)
	end)
end

hook.Add("Player Spawn", "bruhwtf", function(ply)
	net.Start("homicide_roleget")
		net.WriteTable({{}, {}})
	net.Send(ply)
end)

function homicide.StartRoundSV()
	tdm.RemoveItems()

	tdm.DirectOtherTeam(2, 1, 1)

	homicide.police = false

	roundTimeStart = CurTime()
	roundTime = math.min(math.max(math.ceil(#player.GetAll() / 2), 1) * 45, 330)

	-- Space map gravity
	if game.GetMap() == "gm_freeway_spacetunnel" then RunConsoleCommand("sv_gravity", "300")
	else RunConsoleCommand("sv_gravity", "600") end

	if homicide.roundType == 3 then
		roundTime = roundTime * 1.25
	end

	roundTimeLoot = 5

	for _, ply in pairs(team.GetPlayers(2)) do
		ply:SetTeam(1)
	end

	homicide.ct = {}
	homicide.t = {}

	local countT = 0
	local countCT = 0
	local points = homicide.Spawns()

	tdm.SpawnCommand(PlayersInGame(), points, function(ply)
		ply.roleT = false
		ply.roleCT = false

		if ply.forceT then
			ply.forceT = nil
			countT = countT + 1

			makeT(ply)
		end

		if ply.forceCT then
			ply.forceCT = nil
			countCT = countCT + 1

			makeCT(ply)
		end

		if ply:IsUserGroup("sponsor") or ply:IsUserGroup("supporterplus") or ply:IsAdmin() then
			if math.random(1, 5) == 5 then ply:Give("weapon_gear_bloxycola") end
			if math.random(1, 5) == 5 then ply:Give("weapon_gear_cheezburger") end

			ply:Give("weapon_vape")
		end
	end)

	local players = PlayersInGame()
	local count = math.max(math.ceil(#players / 10), 1) - countT

	for _ = 1, count do
		local ply = players[math.random(#players)]

		table.RemoveByValue(players, ply)

		makeT(ply)
	end

	local count = math.max(math.ceil(#players / 10), 1) - countCT

	for _ = 1, count do
		local ply = players[math.random(#players)]

		table.RemoveByValue(players, ply)

		if homicide.roundType <= 5 then
			makeCT(ply)
		end
	end

	timer.Simple(0, function()
		for i, ply in pairs(homicide.t) do
			if not IsValid(ply) then
				table.remove(homicide.t, i)

				continue
			end

			homicide.SyncRole(ply, 1)
		end

		for i, ply in pairs(homicide.ct) do
			if not IsValid(ply) then
				table.remove(homicide.ct, i)

				continue
			end

			homicide.SyncRole(ply, 2)
		end
	end)

	tdm.CenterInit()
	prePolicePlayers = {}

	return {
		roundTimeLoot = roundTimeLoot
	}
end

function homicide.RoundEndCheck()
	tdm.Center()

	local TAlive = tdm.GetCountAlive(homicide.t)
	local Alive = tdm.GetCountAlive(team.GetPlayers(1), function(ply) if ply.roleT or ply.isContr then return false end end)

	if roundTimeStart + roundTime < CurTime() then
		if not homicide.police then SpawnPolicePlayers() end
	elseif roundTimeStart + 180 + roundTime < CurTime() then
		return EndRound()
	end

	if TAlive == 0 and Alive == 0 then return EndRound(0) end
	if TAlive == 0 then return EndRound(1) end
	if Alive == 0 then return EndRound(2) end
end

function homicide.PlayerInitialSpawn(ply)
	ply:SetTeam(1)
	-- TryAssignPolice(ply)
end

COMMANDS.forcepolice = {
	function(ply)
		if not ply:IsAdmin() then return end

		homicide.police = false
		roundTime = 0
	end
}

function homicide.EndRound(winner)
	local tbl = TableRound()

	net.Start("hg_sendchat_format")
		net.WriteTable({
			"#hg.modes.teamwon",
			winner == 0 and "#hg.modes.draw" or tbl[tbl.teamEncoder[winner]] and tbl[tbl.teamEncoder[winner]][1] or "Something bad happened...",
		})
	net.Broadcast()

	if homicide.t and #homicide.t > 0 then
		net.Start("hg_sendchat_format")
			net.WriteTable({
				"#hg.homicide.traitors",
				#homicide.t > 1 and table.concat(GetTraitorsNames(), ", ") or homicide.t[1]:Name()
			})
		net.Broadcast()
	end
end

function homicide.PlayerSpawn2(ply, teamID)
	local teamTbl = homicide[homicide.teamEncoder[teamID]]
	local color = teamID == 1 and Color(math.random(55, 165), math.random(55, 165), math.random(55, 165)) or teamTbl[2]

	-- Set the player's model to the custom model if available, otherwise use a random team model
	local customModel = not ply:IsBot() and GetPlayerModelBySteamID(ply:SteamID()) or false

	if customModel then
		ply:SetModel(customModel)
	else
		EasyAppearance.SetAppearance(ply)
		-- ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
	end

	ply:SetPlayerColor(color:ToVector())

	ply:Give("weapon_hands")

	timer.Simple(0, function() ply.allowFlashlight = false end)
end

function homicide.PlayerCanJoinTeam(ply, teamID)
	if ply:IsAdmin() then
		if teamID == 2 then
			ply.forceCT = nil
			ply.forceT = true

			return false
		end

		if teamID == 3 then
			ply.forceT = nil
			ply.forceCT = true

			return false
		end
	else
		if teamID == 2 or teamID == 3 then return false end
	end

	return true
end

util.AddNetworkString("homicide_roleget")

function homicide.SyncRole(ply, teamID)
	local role = {{}, {}}

	for _, ply in pairs(team.GetPlayers(1)) do
		if teamID ~= 2 and ply.roleT then
			table.insert(role[1], ply)
		end

		if teamID ~= 1 and ply.roleCT then
			table.insert(role[2], ply)
		end
	end

	net.Start("homicide_roleget")
		net.WriteTable(role)
	net.Send(ply)
end

function homicide.PlayerDeath(ply, inf, att)
	-- TryAssignPolice(ply)

	if (ply:IsAdmin() or (ply:GetUserGroup() == "operator") or (ply:GetUserGroup() == "tmod")) and ply:GetInfoNum("homicide_get", 0) then
		local role = {{}, {}}

		for _, ply in pairs(team.GetPlayers(1)) do
			if ply.roleT then
				table.insert(role[1], ply)
			end

			if ply.roleCT then
				table.insert(role[2], ply)
			end
		end

		net.Start("homicide_roleget")
			net.WriteTable(role)
		net.Send(ply)
	end

	return false
end

local common = {"food_lays", "weapon_pipe", "weapon_bat", "med_band_big", "med_band_small", "medkit", "food_monster", "food_fishcan", "food_spongebob_home"}
local uncommon = {"medkit", "weapon_hammer", "weapon_pepperspray", "painkiller"}
local rare = {"weapon_fiveseven", "weapon_kukri", "weapon_tomahawk", "weapon_mateba", "weapon_m590"}

function homicide.ShouldSpawnLoot()
	if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end

	local chance = math.random(100)

	if chance < 2 and homicide.roundType ~= 3 then
		return true, rare[math.random(#rare)], "legend"
	elseif chance < 20 then
		return true, uncommon[math.random(#uncommon)], "veryrare"
	elseif chance < 60 then
		return true, common[math.random(#common)], "common"
	else
		return false
	end
end

function homicide.ShouldDiscordOutput(ply, text)
	if ply:Team() ~= 1002 and ply:Alive() then return false end
end

function homicide.ShouldDiscordInput(ply, text)
	if not ply:IsAdmin() then return false end
end

function homicide.GuiltLogic(ply, att, dmgInfo)
	return ply.roleT == att.roleT and 1 or 0
end