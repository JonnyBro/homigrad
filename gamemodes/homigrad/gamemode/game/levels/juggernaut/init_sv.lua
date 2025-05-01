local function makeT(ply)
	ply.roleT = true

	table.insert(juggernaut.t, ply)

	ply:Give("weapon_hg_rgd5")
	ply:Give("weapon_hg_sledgehammer")

	local wep = ply:Give("weapon_m249")
	wep:SetClip1(wep:GetMaxClip1())
	ply:GiveAmmo(3 * wep:GetMaxClip1(), wep:GetPrimaryAmmoType())

	ply.nopain = true

	ply:SetMaxHealth(#player.GetAll() * 300)
	ply:SetHealth(#player.GetAll() * 300)
end

function juggernaut.SpawnsCT()
	local aviable = {}

	for _, point in pairs(ReadDataMap("spawnpointshiders")) do
		table.insert(aviable, point)
	end

	return aviable
end

function juggernaut.SpawnsT()
	local aviable = {}

	for _, point in pairs(ReadDataMap("spawnpoints_ss_school")) do
		table.insert(aviable, point)
	end

	return aviable
end

function juggernaut.StartRoundSV()
	tdm.RemoveItems()
	tdm.DirectOtherTeam(2, 1, 1)

	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 1.5), 1) * 60
	roundTimeLoot = 5

	for _, ply in pairs(team.GetPlayers(2)) do
		ply:SetTeam(1)
	end

	for _, ply in player.Iterator() do
		ply.roleT = false
	end

	juggernaut.t = {}

	local aviable = juggernaut.SpawnsCT()
	local aviable2 = juggernaut.SpawnsT()
	local players = PlayersInGame()
	local count = 1

	for _ = 1, count do
		local ply = RandomFromTable(players)

		table.RemoveByValue(players, ply)

		makeT(ply)
	end

	juggernaut.SyncRole()

	tdm.SpawnCommand(players, aviable, function(ply)
		ply.roleT = false

		ply:Give("weapon_kukri")

		local wep = ply:Give("weapon_hk_usp")
		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(2 * wep:GetMaxClip1(), wep:GetPrimaryAmmoType())

		if math.random(1, 8) == 8 then ply:Give("adrenaline") end
		if math.random(1, 7) == 7 then ply:Give("painkiller") end
		if math.random(1, 6) == 6 then ply:Give("medkit") end
		if math.random(1, 5) == 5 then ply:Give("med_band_big") end
		if math.random(1, 8) == 8 then ply:Give("morphine") end
	end)

	tdm.SpawnCommand(juggernaut.t, aviable2, function(ply) timer.Simple(1, function() ply.nopain = true end) end)
	tdm.CenterInit()

	return {
		roundTimeLoot = roundTimeLoot
	}
end

function juggernaut.RoundEndCheck()
	tdm.Center()

	if roundTimeStart + roundTime - CurTime() <= 0 then EndRound() end

	local TAlive = tdm.GetCountAlive(juggernaut.t)
	local Alive = tdm.GetCountAlive(team.GetPlayers(1), function(ply) if ply.roleT or ply.isContr then return false end end)

	if roundTimeStart + roundTime < CurTime() then EndRound() end

	if TAlive == 0 and Alive == 0 then return EndRound() end
	if TAlive == 0 then EndRound(2) end
	if Alive == 0 then EndRound(1) end
end

function juggernaut.EndRound(winner)
	PrintMessage(3, winner == 1 and "Juggernaut Wins!" or winner == 2 and "Mercenaries Win!" or "Nobody Wins.")
end

function juggernaut.PlayerSpawn2(ply, teamID)
	local teamTbl = juggernaut[juggernaut.teamEncoder[teamID]]
	local color = teamID == 1 and Color(math.random(55, 165), math.random(55, 165), math.random(55, 165)) or teamTbl[2]

	-- Set the player's model to the custom model if available, otherwise use a random team model
	local customModel = GetPlayerModelBySteamID(ply:SteamID())

	if ply.roleT then
		-- Give Armour to Wick and make it invisible, because current health increase doesnt seem to work?
		JMod.EZ_Equip_Armor(ply, "Heavy-Vest", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "BallisticMask", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "Left-Forearm", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "Right-Forearm", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "Heavy-Right-Shoulder", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "Heavy-Left-Shoulder", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "Pelvis-Panel", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "Heavy-Right-Thigh", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "Heavy-Left-Thigh", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "Left-Calf", Color(255, 0, 0, 255))
		JMod.EZ_Equip_Armor(ply, "Right-Calf", Color(255, 0, 0, 255))

		ply:Give("morphine")
		ply:Give("med_band_big")
		ply:Give("medkit")
		ply:Give("painkiller")
		ply:Give("adrenaline")
		ply:Give("splint")

		if customModel then
			ply:SetSubMaterial()
			ply:SetModel(customModel)
		end
	end

	EasyAppearance.SetAppearance(ply)

	ply:SetPlayerColor(color:ToVector())
	ply:Give("weapon_hands")

	timer.Simple(0, function() ply.allowFlashlights = false end)
end

function juggernaut.PlayerInitialSpawn(ply)
	ply:SetTeam(1)
end

function juggernaut.PlayerCanJoinTeam(ply, teamID)
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

util.AddNetworkString("homicide_roleget2")

function juggernaut.SyncRole()
	local role = {{}, {}}

	for _, ply in pairs(team.GetPlayers(1)) do
		if ply.roleT then table.insert(role[1], ply) end
	end

	net.Start("homicide_roleget2")
		net.WriteTable(role)
	net.Broadcast()
end

function juggernaut.PlayerDeath(ply, inf, att)
	return false
end

function juggernaut.ShouldSpawnLoot()
	return false
end

function juggernaut.GuiltLogic(ply, att, dmgInfo)
	return ply.roleT == att.roleT and 5 or 0
end

juggernaut.NoSelectRandom = true