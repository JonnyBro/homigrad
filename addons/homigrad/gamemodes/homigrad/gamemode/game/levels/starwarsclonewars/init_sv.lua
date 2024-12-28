starwarsclonewars.ragdolls = {}

function starwarsclonewars.SpawnsTwoCommand()
	local spawnsT = ReadDataMap("spawnpointst")
	local spawnsCT = ReadDataMap("spawnpointsct")

	if #spawnsT == 0 then
		for i, ent in RandomPairs(ents.FindByClass("info_player_terrorist")) do
			table.insert(spawnsT,ent:GetPos())
		end
	end

	if #spawnsCT == 0 then
		for i, ent in RandomPairs(ents.FindByClass("info_player_counterterrorist")) do
			table.insert(spawnsCT,ent:GetPos())
		end
	end

	return spawnsT,spawnsCT
end

local function GetTeamSpawns(ply)
	local spawnsT,spawnsCT = starwarsclonewars.SpawnsTwoCommand()

    if ply:Team() == 1 then
        return spawnsT
    elseif ply:Team() == 2 then
        return spawnsCT
    else
        return false
    end
end

function starwarsclonewars.SelectRandomPlayers(list,div,func)
	for i = 1,math.floor(#list / div) do
		local ply,key = table.Random(list)
		table.remove(list,key)

		func(ply)
	end
end

function starwarsclonewars.GiveMimomet(ply)
 --   ply:Give("weapon_gredmimomet")
 --   ply:Give("weapon_gredammo")
end

function starwarsclonewars.GiveAidPhone(ply)
--    ply:Give("weapon_phone")
end

function starwarsclonewars.SpawnSimfphys(list,name,func)
	for i,point in pairs(list) do
		local ent = simfphys.SpawnVehicleSimple(name,point[1],point[2])
		if func then func(ent) end
	end
end

--[[function starwarsclonewars.SpawnVehicle()
    starwarsclonewars.SpawnSimfphys(ReadDataMap("car_red"),"sim_fphys_pwvolga")
    starwarsclonewars.SpawnSimfphys(ReadDataMap("car_blue"),"sim_fphys_pwhatchback")

	--starwarsclonewars.SpawnEnt(ReadDataMap("sim_fphys_tank3"),"sim_fphys_tank3")
	--starwarsclonewars.SpawnEnt(ReadDataMap("sim_fphys_tank4"),"sim_fphys_tank4")
	
	starwarsclonewars.SpawnEnt(ReadDataMap("car_red_btr"),"lvs_wheeldrive_dodwillyjeep") -- later
    starwarsclonewars.SpawnEnt(ReadDataMap("car_blue_btr"),"lvs_wheeldrive_dodwillyjeep")
	starwarsclonewars.SpawnEnt(ReadDataMap("wac_hc_ah1z_viper"),"wac_hc_ah1z_viper")
	starwarsclonewars.SpawnEnt(ReadDataMap("wac_hc_littlebird_ah6"),"wac_hc_littlebird_ah6")
	starwarsclonewars.SpawnEnt(ReadDataMap("wac_hc_mi28_havoc"),"wac_hc_mi28_havoc")
	starwarsclonewars.SpawnEnt(ReadDataMap("wac_hc_blackhawk_uh60"),"wac_hc_blackhawk_uh60")

	--starwarsclonewars.SpawnEnt(ReadDataMap("car_red_btr"),"lvs_wheeldrive_dodwillyjeep") -- later
    --starwarsclonewars.SpawnEnt(ReadDataMap("car_blue_btr"),"lvs_wheeldrive_dodwillyjeep")
    starwarsclonewars.SpawnEnt(ReadDataMap("car_red_tank"),"lvs_wheeldrive_t34_57")
    starwarsclonewars.SpawnEnt(ReadDataMap("car_blue_tank"),"lvs_wheeldrive_dodsherman")
end]]

function starwarsclonewars.SpawnEnt(list,name,func)
    for i,point in pairs(list) do
		local ent = ents.Create(name)
		ent:SetPos(point[1])
		ent:SetAngles(point[2])
		ent:Spawn()
	end
end

--[[function starwarsclonewars.SpawnGred()
	starwarsclonewars.SpawnEnt(ReadDataMap("gred_emp_breda35"),"gred_emp_breda35")
    starwarsclonewars.SpawnEnt(ReadDataMap("gred_emp_dshk"),"gred_emp_dshk")
    starwarsclonewars.SpawnEnt(ReadDataMap("gred_ammobox"),"gred_ammobox")
    starwarsclonewars.SpawnEnt(ReadDataMap("gred_emp_2a65"),"gred_emp_2a65")
	starwarsclonewars.SpawnEnt(ReadDataMap("gred_emp_pak40"),"gred_emp_pak40")
end]]

function starwarsclonewars.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	--roundTime = 60 * (2 + math.min(#player.GetAll() / 4,2))
	roundTime = 900

	tdm.DirectOtherTeam(3,1,2)

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	--local spawnsT,spawnsCT = starwarsclonewars.SpawnsTwoCommand()
	--starwarsclonewars.SpawnCommand(team.GetPlayers(1),spawnsT)
	--starwarsclonewars.SpawnCommand(team.GetPlayers(2),spawnsCT)

	--starwarsclonewars.SpawnVehicle()
	--starwarsclonewars.SpawnGred()

	starwarsclonewars.oi = false

	--tdm.CenterInit()

    starwarsclonewars.SelectRandomPlayers(team.GetPlayers(1),2,starwarsclonewars.GiveMimomet)
    starwarsclonewars.SelectRandomPlayers(team.GetPlayers(1),2,starwarsclonewars.GiveAidPhone)

    starwarsclonewars.SelectRandomPlayers(team.GetPlayers(2),2,starwarsclonewars.GiveMimomet)
    starwarsclonewars.SelectRandomPlayers(team.GetPlayers(2),2,starwarsclonewars.GiveAidPhone)
end

function starwarsclonewars.Think()
    starwarsclonewars.LastWave = starwarsclonewars.LastWave or CurTime() + 60

    if CurTime() >= starwarsclonewars.LastWave then
        SetGlobalInt("starwarsclonewars_respawntime", CurTime())
        for _, v in pairs(player.GetAll()) do
            local players = {}
            if !v:Alive() and v:Team() != 1002 then
                v:Spawn()
                local teamspawn = GetTeamSpawns(v)
                local point,key = table.Random(teamspawn)
                point = ReadPoint(point)
                if not point then continue end
                v:SetPos(point[1])
                players[v:Team()] = players[v:Team()] or {}
                players[v:Team()][v] = true
            end
    
            /*for i,list in pairs(players) do
                starwarsclonewars.SelectRandomPlayers(list[1],6,starwarsclonewars.GiveAidPhone)
                starwarsclonewars.SelectRandomPlayers(list[2],6,starwarsclonewars.GiveAidPhone)
            end*/
        end
        for ent in pairs(starwarsclonewars.ragdolls) do
            if IsValid(ent) then ent:Remove() end
            starwarsclonewars.ragdolls[ent] = nil
        end
        starwarsclonewars.LastWave = CurTime() + 60
    end
end

function starwarsclonewars.GetCountLive(list,func)
	local count = 0
	local result

	for i,ply in pairs(list) do
		if not IsValid(ply) then continue end

		result = func and func(ply)
		if result == true then count = count + 1 continue elseif result == false then continue end
		if not PlayerIsCuffs(ply) and ply:Alive() then count = count + 1 end
	end

	return count
end

function starwarsclonewars.PointsThink() --обработка точек, сколько людей из каждой команды и процесс захвата
    local starwarsclonewars_points = cp.points
    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        local v = starwarsclonewars_points[i]
        if not v then
            v = {}
            starwarsclonewars_points[i] = v
        end

        v[1] = point[1]

        v.RedAmount = 0
        v.BlueAmount = 0

        for _, v2 in pairs(ents.FindInSphere(v[1], 256)) do
            if !v2:IsPlayer() or !v2:Alive() or v2.Otrub then continue end

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

        if v.CaptureTeam and v.CaptureTeam != 0 then
            cp.WinPoints[v.CaptureTeam] = cp.WinPoints[v.CaptureTeam] + 7.5 / #SpawnPointsList.controlpoint[3]
        end

        SetGlobalInt(i .. "PointProgress", v.CaptureProgress)
        SetGlobalInt(i .. "PointCapture", v.CaptureTeam)
    end

    for i = 1, 2 do
        SetGlobalInt("starwarsclonewars_Winpoints" .. i, cp.WinPoints[i])
    end
end

/*function starwarsclonewars.RoundEndCheck()
	local TAlive = tdm.GetCountLive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountLive(team.GetPlayers(2))

	if roundTimeStart + roundTime - CurTime() <= 0 then EndRound() end

	if TAlive == 0 and CTAlive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if CTAlive == 0 then EndRound(1) end

	tdm.Center()
end*/

function starwarsclonewars.RoundEndCheck()
    for i = 1, 2 do
        if starwarsclonewars.WinPoints[i] >= 1000 then
            EndRound(i)
        end
    end
    if roundTimeStart + roundTime < CurTime() then EndRound() end
end

function starwarsclonewars.EndRound(winner)
	print("End round, win '" .. tostring(winner) .. "'")

	for _, ply in ipairs(player.GetAll()) do
		if !winner then ply:ChatPrint("Победила дружба") continue end
		if winner == ply:Team() then ply:ChatPrint("Победа") end
		if winner ~= ply:Team() then ply:ChatPrint("Поражение") end
	end

    timer.Remove("starwarsclonewars_NewWave")
    timer.Remove("starwarsclonewars_ThinkAboutPoints")
end

function starwarsclonewars.PlayerInitialSpawn(ply) ply:SetTeam(math.random(1,2)) end

function starwarsclonewars.PlayerSpawn(ply, teamID)
	local teamTbl = starwarsclonewars[starwarsclonewars.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
	ply:SetPlayerColor(color:ToVector())

	if teamID == 1 then
		ply:SetBodygroup(1, 6)
		ply:SetBodygroup(2, 3)

		if math.random(1, 10) == 1 then
			ply:SetModel("models/player/Group01/male_02.mdl")
			ply:Give("weapon_lightsaber")
			ply:SetCrystalColor(Vector(255, 0, 0))
			ply:SetPlayerColor(Vector(255, 0, 0))

			return
		end
	end

	-- Настройки для команды 2
	if teamID == 2 then
		ply:SetBodygroup(1, 2)
		if math.random(1, 10) == 1 then
			ply:SetModel("models/player/Group01/male_08.mdl")
			ply:Give("weapon_lightsaber")
			ply:SetCrystalColor(Vector(0, 0, 255))
			ply:SetPlayerColor(Vector(0, 0, 255))

			return
		end
	end

	-- Устанавливаем цвет игрока
	-- Выдача стандартного оружия
	for i, weapon in pairs(teamTbl.weapons) do
		ply:Give(weapon)
	end
	tdm.GiveSwep(ply, teamTbl.main_weapon)
	tdm.GiveSwep(ply, teamTbl.secondary_weapon)

	-- Дополнительные действия при запуске раунда
	if roundStarter then
		ply.allowFlashlights = true
	end
end

function starwarsclonewars.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
end
function starwarsclonewars.PlayerDeath(ply,inf,att)
    starwarsclonewars.ragdolls[ply:GetNWEntity("Ragdoll")] = true
    return false
end
function starwarsclonewars.NoSelectRandom() return #ReadDataMap("control_point") < 1 end
function starwarsclonewars.ShouldSpawnLoot() return false end