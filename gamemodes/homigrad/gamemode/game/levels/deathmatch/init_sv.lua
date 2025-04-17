function dm.Spawns()
	local points = {}

	for _, point in pairs(ReadDataMap("dm")) do
		table.insert(points, point)
	end

	return points
end

function dm.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 240 -- 60 * (1 + math.min(#player.GetAll() / 8, 2))

	local players = PlayersInGame()

	for _, ply in pairs(players) do
		ply:SetTeam(1)
	end

	local aviable = dm.Spawns()
	aviable = #aviable ~= 0 and aviable or homicide.Spawns()

	tdm.SpawnCommand(team.GetPlayers(1), aviable, function(ply)
		ply:Freeze(true)
	end)

	freezing = true

	RTV_CountRound = RTV_CountRound - 1
	roundTimeRespawn = CurTime() + 15
	roundDmType = math.random(1, 4)

	return {roundTimeStart, roundTime}
end

function dm.RoundEndCheck()
	local alive = 0

	for _, ply in pairs(team.GetPlayers(1)) do
		if ply:Alive() then
			alive = alive + 1
		end
	end

	if freezing and roundTimeStart + dm.LoadScreenTime < CurTime() then
		freezing = nil

		for _, ply in pairs(team.GetPlayers(1)) do
			ply:Freeze(false)
		end
	end

	if alive <= 1 then
		for _, ply in pairs(player.GetAll()) do
			if ply:Alive() then
				winner = ply
			end
		end

		return EndRound(winner)
	end

	if roundTimeStart + roundTime - CurTime() <= 0 then return EndRound() end
end

function dm.EndRound(winner)
	net.Start("hg_sendchat_format")
		net.WriteTable({
			"#hg.modes.plrwin",
			winner and winner:GetName() or "#hg.modes.draw"
		})
	net.Broadcast()
end

--[[
local function GetTeamSpawns(ply)
	local spawnsT, spawnsCT = bahmut.SpawnsTwoCommand()

	if ply:Team() == 1 then return spawnsT
	elseif ply:Team() == 2 then return spawnsCT
	else return false end
end

function dm.Think()
	construct.LastWave = construct.LastWave or CurTime() + 15

	if CurTime() >= construct.LastWave then
		SetGlobalInt("construct_respawntime", CurTime())

		for _, v in player.Iterator() do
			local players = {}

			if not v:Alive() and v:Team() ~= 1002 then
				v:Spawn()

				local teamspawn = GetTeamSpawns(v)
				local point, key = RandomFromTable(teamspawn)
				point = ReadPoint(point)
				if not point then continue end

				v:SetPos(point[1])

				players[v:Team()] = players[v:Team()] or {}
				players[v:Team()][v] = true
			end
		end

		for ent in pairs(construct.ragdolls) do
			if IsValid(ent) then ent:Remove() end

			construct.ragdolls[ent] = nil
		end

		construct.LastWave = CurTime() + 10
	end
end --]]

function dm.PlayerSpawn2(ply, teamID)
	ply:SetModel(tdm.models[math.random(#tdm.models)])
	ply:SetPlayerColor(Vector(0, 0, 0.6))

	ply:Give("weapon_hands")

	-- This is... something
	if roundDmType == 1 then
		local r = math.random(1, 8)
		local wep1 = ply:Give((r == 1 and "weapon_mp7") or (r == 2 and "weapon_aks74u") or (r == 3 and "weapon_akm") or (r == 4 and "weapon_scout" and "weapon_uzi") or (r == 5 and "weapon_m4a1") or (r == 6 and "weapon_hk416") or (r == 7 and "weapon_m4a1") or (r == 8 and "weapon_galil"))

		ply:Give("med_band_big")
		ply:Give("medkit")
		ply:Give("weapon_kabar")

		ply:GiveAmmo(wep1:GetMaxClip1() * 3, wep1:GetPrimaryAmmoType())
	elseif roundDmType == 2 then
		local r = math.random(1, 4)
		local p = math.random(1, 4)
		local wep1 = ply:Give((r == 1 and "weapon_spas12") or (r == 2 and "weapon_xm1014") or (r == 3 and "weapon_remington870") or (r == 4 and "weapon_m590"))
		local wep2 = ply:Give((p == 1 and "weapon_uzi") or p == 2 and "weapon_p99" or p == 3 and "weapon_glock" or p == 4 and "weapon_fiveseven")

		ply:Give("med_band_big")
		ply:Give("medkit")
		ply:Give("weapon_hg_rgd5")
		ply:Give("weapon_kabar")

		ply:GiveAmmo(wep1:GetMaxClip1() * 3, wep1:GetPrimaryAmmoType())
		ply:GiveAmmo(wep2:GetMaxClip1() * 3, wep2:GetPrimaryAmmoType())
	elseif roundDmType == 3 then
		local wep1 = ply:Give("weapon_mateba")

		ply:Give("med_band_big")
		ply:Give("medkit")
		ply:Give("weapon_kabar")

		ply:GiveAmmo(wep1:GetMaxClip1() * 3, wep1:GetPrimaryAmmoType())
	elseif roundDmType == 4 then
		local r = math.random(1, 3)
		local wep1 = ply:Give((r == 1 and "weapon_hk_usp") or (r == 2 and "weapon_p99") or (r == 3 and "weapon_beretta"))

		if math.random(1, 2) == 2 then ply:Give("weapon_hidebomb") else ply:Give("weapon_suicidevest") end
		ply:Give("med_band_big")
		ply:Give("weapon_hg_rgd5")
		ply:Give("weapon_kabar")

		ply:GiveAmmo(wep1:GetMaxClip1() * 3, wep1:GetPrimaryAmmoType())
	else
		local r = math.random(1, 3)
		local wep1 = ply:Give((r == 1 and "weapon_hk_usp") or (r == 2 and "weapon_p99") or (r == 3 and "weapon_beretta"))

		if math.random(1, 2) == 2 then ply:Give("weapon_hidebomb") else ply:Give("weapon_suicidevest") end
		ply:Give("med_band_big")
		ply:Give("weapon_hg_rgd5")
		ply:Give("weapon_kabar")

		ply:GiveAmmo(wep1:GetMaxClip1() * 3, wep1:GetPrimaryAmmoType())
	end

	ply:Give("weapon_radio")
	ply:SetLadderClimbSpeed(100)
end

function dm.PlayerInitialSpawn(ply)
	ply:SetTeam(1)
end

function dm.PlayerCanJoinTeam(ply, teamID)
	if teamID == 2 or teamID == 3 then return false end

	return true
end

function dm.GuiltLogic()
	return false
end

util.AddNetworkString("dm die")

function dm.PlayerDeath()
	net.Start("dm die")
	net.Broadcast()
end