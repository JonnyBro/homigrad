bahmut.ragdolls = {}

function bahmut.SpawnsTwoCommand()
	local spawnsT = ReadDataMap("bahmut_vagner")
	local spawnsCT = ReadDataMap("bahmut_nato")

	return spawnsT, spawnsCT
end

local function GetTeamSpawns(ply)
	local spawnsT, spawnsCT = bahmut.SpawnsTwoCommand()

	if ply:Team() == 1 then
		return spawnsT
	elseif ply:Team() == 2 then
		return spawnsCT
	else
		return false
	end
end

function bahmut.SelectRandomPlayers(list, div, func)
	for _ = 1, math.floor(#list / div) do
		local ply, key = RandomFromTable(list)

		table.remove(list, key)

		func(ply)
	end
end

function bahmut.GiveMimomet(ply)
	ply:Give("weapon_gredmimomet")
	ply:Give("weapon_gredammo")
end

function bahmut.GiveAidPhone(ply)
end

--ply:Give("weapon_phone")
function bahmut.SpawnSimfphys(list, name, func)
	for _, point in pairs(list) do
		local ent = simfphys.SpawnVehicleSimple(name, point[1], point[2])

		if func then
			func(ent)
		end
	end
end

function bahmut.SpawnVehicle()
	bahmut.SpawnSimfphys(ReadDataMap("car_red"), "sim_fphys_pwvolga")
	bahmut.SpawnSimfphys(ReadDataMap("car_blue"), "sim_fphys_pwhatchback")
	--bahmut.SpawnEnt(ReadDataMap("sim_fphys_tank3"),"sim_fphys_tank3")
	--bahmut.SpawnEnt(ReadDataMap("sim_fphys_tank4"),"sim_fphys_tank4")
	bahmut.SpawnEnt(ReadDataMap("car_red_btr"), "lvs_wheeldrive_dodwillyjeep") -- later
	bahmut.SpawnEnt(ReadDataMap("car_blue_btr"), "lvs_wheeldrive_dodwillyjeep")
	bahmut.SpawnEnt(ReadDataMap("wac_hc_ah1z_viper"), "wac_hc_ah1z_viper")
	bahmut.SpawnEnt(ReadDataMap("wac_hc_littlebird_ah6"), "wac_hc_littlebird_ah6")
	bahmut.SpawnEnt(ReadDataMap("wac_hc_mi28_havoc"), "wac_hc_mi28_havoc")
	bahmut.SpawnEnt(ReadDataMap("wac_hc_blackhawk_uh60"), "wac_hc_blackhawk_uh60")
	--bahmut.SpawnEnt(ReadDataMap("car_red_btr"),"lvs_wheeldrive_dodwillyjeep") -- later
	--bahmut.SpawnEnt(ReadDataMap("car_blue_btr"),"lvs_wheeldrive_dodwillyjeep")
	bahmut.SpawnEnt(ReadDataMap("car_red_tank"), "lvs_wheeldrive_t34_57")
	bahmut.SpawnEnt(ReadDataMap("car_blue_tank"), "lvs_wheeldrive_dodsherman")
end

function bahmut.SpawnEnt(list, name, func)
	for _, point in pairs(list) do
		local ent = ents.Create(name)
		ent:SetPos(point[1])
		ent:SetAngles(point[2])
		ent:Spawn()
	end
end

function bahmut.SpawnGred()
	bahmut.SpawnEnt(ReadDataMap("gred_emp_breda35"), "gred_emp_breda35")
	bahmut.SpawnEnt(ReadDataMap("gred_emp_dshk"), "gred_emp_dshk")
	bahmut.SpawnEnt(ReadDataMap("gred_ammobox"), "gred_ammobox")
	bahmut.SpawnEnt(ReadDataMap("gred_emp_2a65"), "gred_emp_2a65")
	bahmut.SpawnEnt(ReadDataMap("gred_emp_pak40"), "gred_emp_pak40")
end

function bahmut.StartRoundSV()
	tdm.RemoveItems()
	roundTimeStart = CurTime()
	-- roundTime = 60 * (2 + math.min(#player.GetAll() / 4,2))
	roundTime = 900
	tdm.DirectOtherTeam(3, 1, 2)
	OpposingAllTeam()
	AutoBalanceTwoTeam()
	-- local spawnsT,spawnsCT = bahmut.SpawnsTwoCommand()
	-- bahmut.SpawnCommand(team.GetPlayers(1),spawnsT)
	-- bahmut.SpawnCommand(team.GetPlayers(2),spawnsCT)
	bahmut.SpawnVehicle()
	bahmut.SpawnGred()
	bahmut.oi = false
	-- tdm.CenterInit()
	bahmut.SelectRandomPlayers(team.GetPlayers(1), 2, bahmut.GiveMimomet)
	bahmut.SelectRandomPlayers(team.GetPlayers(1), 2, bahmut.GiveAidPhone)
	bahmut.SelectRandomPlayers(team.GetPlayers(2), 2, bahmut.GiveMimomet)
	bahmut.SelectRandomPlayers(team.GetPlayers(2), 2, bahmut.GiveAidPhone)
end

function bahmut.Think()
	bahmut.LastWave = bahmut.LastWave or CurTime() + 60

	if CurTime() >= bahmut.LastWave then
		SetGlobalInt("Bahmut_respawntime", CurTime())

		for _, v in player.Iterator() do
			local players = {}

			if not v:Alive() and v:Team() ~= 1002 then
				v:Spawn()
				local teamspawn = GetTeamSpawns(v)
				local point, _ = RandomFromTable(teamspawn)
				point = ReadPoint(point)
				if not point then continue end
				v:SetPos(point[1])
				players[v:Team()] = players[v:Team()] or {}
				players[v:Team()][v] = true
			end
		end

		for ent in pairs(bahmut.ragdolls) do
			if IsValid(ent) then
				ent:Remove()
			end

			bahmut.ragdolls[ent] = nil
		end

		bahmut.LastWave = CurTime() + 60
	end
end

function bahmut.GetCountAlive(list, func)
	local count = 0
	local result

	for _, ply in pairs(list) do
		if not IsValid(ply) then continue end
		result = func and func(ply)

		if result == true then
			count = count + 1
			continue
		elseif result == false then
			continue
		end

		if not IsCuffed(ply) and ply:Alive() then
			count = count + 1
		end
	end

	return count
end

function bahmut.PointsThink()
	local bahmut_points = bahmut.points

	for i, point in pairs(SpawnPointsList.controlpoint[3]) do
		local v = bahmut_points[i]

		if not v then
			v = {}
			bahmut_points[i] = v
		end

		v[1] = point[1]
		v.RedAmount = 0
		v.BlueAmount = 0

		for _, v2 in pairs(ents.FindInSphere(v[1], 256)) do
			if not v2:IsPlayer() or not v2:Alive() or v2.unconscious then continue end

			if v2:Team() == 1 then
				v.RedAmount = v.RedAmount + 1
			elseif v2:Team() == 2 then
				v.BlueAmount = v.BlueAmount + 1
			end
		end

		if v.RedAmount > v.BlueAmount then
			v.CaptureProgress = math.Clamp((v.CaptureProgress or 0) + 10, -100, 100)
		elseif v.BlueAmount > v.RedAmount then
			v.CaptureProgress = math.Clamp((v.CaptureProgress or 0) - 10, -100, 100)
		end

		if v.CaptureProgress == 100 then
			v.CaptureTeam = 1
		elseif v.CaptureProgress == -100 then
			v.CaptureTeam = 2
		elseif v.CaptureProgress == 0 then
			v.CaptureTeam = 0
		end

		if v.CaptureTeam and v.CaptureTeam ~= 0 then
			bahmut.WinPoints[v.CaptureTeam] = bahmut.WinPoints[v.CaptureTeam] + 7.5 / #SpawnPointsList.controlpoint[3]
		end

		SetGlobalInt(i .. "PointProgress", v.CaptureProgress)
		SetGlobalInt(i .. "PointCapture", v.CaptureTeam)
	end

	for i = 1, 2 do
		SetGlobalInt("Bahmut_Winpoints" .. i, bahmut.WinPoints[i])
	end
end

--[[
function bahmut.RoundEndCheck()
	local TAlive = tdm.GetCountAlive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountAlive(team.GetPlayers(2))

	if roundTimeStart + roundTime - CurTime() <= 0 then
		EndRound()
	end

	if TAlive == 0 and CTAlive == 0 then
		EndRound()

		return
	end

	if TAlive == 0 then
		EndRound(2)
	end

	if CTAlive == 0 then
		EndRound(1)
	end

	tdm.Center()
end --]]

function bahmut.RoundEndCheck()
	for i = 1, 2 do
		if bahmut.WinPoints[i] >= 1000 then
			EndRound(i)
		end
	end

	if roundTimeStart + roundTime < CurTime() then
		EndRound()
	end
end

function bahmut.EndRound(winner)
	print("End round, '" .. tostring(winner) .. "' won")

	for _, ply in ipairs(player.GetAll()) do
		if not winner then
			ply:ChatPrint("Победила дружба")
			continue
		end

		if winner == ply:Team() then
			ply:ChatPrint("Победа")
		end

		if winner ~= ply:Team() then
			ply:ChatPrint("Поражение")
		end
	end

	timer.Remove("Bahmut_NewWave")
	timer.Remove("Bahmut_ThinkAboutPoints")
end

function bahmut.PlayerInitialSpawn(ply)
	ply:SetTeam(math.random(1, 2))
end

function bahmut.PlayerSpawn2(ply, teamID)
	local teamTbl = bahmut[bahmut.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])

	if teamID == 1 then
		ply:SetBodygroup(1, 2)
		ply:SetBodygroup(2, 1)
		ply:SetBodygroup(4, 1)
		ply:SetBodygroup(5, 1)
		ply:SetBodygroup(6, 1)
		ply:SetBodygroup(7, 1)
		ply:SetBodygroup(9, 2)
	end

	ply:SetPlayerColor(color:ToVector())

	for _, weapon in pairs(teamTbl.weapons) do
		ply:Give(weapon)
	end

	tdm.GiveSwep(ply, teamTbl.main_weapon)
	tdm.GiveSwep(ply, teamTbl.secondary_weapon)

	if math.random(1, 4) == 4 then
		ply:Give("adrenaline")
	end

	if math.random(1, 4) == 4 then
		ply:Give("morphine")
	end

	if math.random(1, 4) == 4 then
		ply:Give("weapon_hg_sledgehammer")
	end

	JMod.EZ_Equip_Armor(ply, "Medium-Helmet", color)
	local r = math.random(1, 2)
	JMod.EZ_Equip_Armor(ply, (r == 1 and "Medium-Vest") or (r == 2 and "Light-Vest"), color)

	if roundStarter then
		ply:Give("weapon_gredmimomet")
		ply:Give("weapon_gredammo")
		-- ply:Give("weapon_phone")
		ply.allowFlashlights = true
	end
end

function bahmut.PlayerCanJoinTeam(ply, teamID)
	if teamID == 3 then return false end
end

function bahmut.PlayerDeath(ply, inf, att)
	bahmut.ragdolls[ply:GetNWEntity("Ragdoll")] = true

	return false
end

function bahmut.NoSelectRandom()
	return #ReadDataMap("control_point") < 1
end

function bahmut.ShouldSpawnLoot()
	return false
end