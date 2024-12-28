ww2.ragdolls = {}

function ww2.SpawnsTwoCommand()
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
	local spawnsT,spawnsCT = ww2.SpawnsTwoCommand()

    if ply:Team() == 1 then
        return spawnsT
    elseif ply:Team() == 2 then
        return spawnsCT
    else
        return false
    end
end

function ww2.SelectRandomPlayers(list,div,func)
	for i = 1,math.floor(#list / div) do
		local ply,key = table.Random(list)
		table.remove(list,key)

		func(ply)
	end
end

function ww2.GiveMimomet(ply)
    ply:Give("weapon_gredmimomet")
    ply:Give("weapon_gredammo")
end

function ww2.GiveAidPhone(ply)
    ply:Give("weapon_phone")
end

function ww2.SpawnSimfphys(list,name,func)
	for i,point in pairs(list) do
		local ent = simfphys.SpawnVehicleSimple(name,point[1],point[2])
		if func then func(ent) end
	end
end

function ww2.SpawnVehicle()
    ww2.SpawnSimfphys(ReadDataMap("car_red"),"sim_fphys_pwvolga")
    ww2.SpawnSimfphys(ReadDataMap("car_blue"),"sim_fphys_pwhatchback")

	--ww2.SpawnEnt(ReadDataMap("sim_fphys_tank3"),"sim_fphys_tank3")
	--ww2.SpawnEnt(ReadDataMap("sim_fphys_tank4"),"sim_fphys_tank4")
	
	ww2.SpawnEnt(ReadDataMap("car_red_btr"),"lvs_wheeldrive_dodwillyjeep") -- later
    ww2.SpawnEnt(ReadDataMap("car_blue_btr"),"lvs_wheeldrive_dodwillyjeep")
	ww2.SpawnEnt(ReadDataMap("wac_hc_ah1z_viper"),"wac_hc_ah1z_viper")
	ww2.SpawnEnt(ReadDataMap("wac_hc_littlebird_ah6"),"wac_hc_littlebird_ah6")
	ww2.SpawnEnt(ReadDataMap("wac_hc_mi28_havoc"),"wac_hc_mi28_havoc")
	ww2.SpawnEnt(ReadDataMap("wac_hc_blackhawk_uh60"),"wac_hc_blackhawk_uh60")

	--ww2.SpawnEnt(ReadDataMap("car_red_btr"),"lvs_wheeldrive_dodwillyjeep") -- later
    --ww2.SpawnEnt(ReadDataMap("car_blue_btr"),"lvs_wheeldrive_dodwillyjeep")
    ww2.SpawnEnt(ReadDataMap("car_red_tank"),"lvs_wheeldrive_t34_57")
    ww2.SpawnEnt(ReadDataMap("car_blue_tank"),"lvs_wheeldrive_dodsherman")
end

function ww2.SpawnEnt(list,name,func)
    for i,point in pairs(list) do
		local ent = ents.Create(name)
		ent:SetPos(point[1])
		ent:SetAngles(point[2])
		ent:Spawn()
	end
end

function ww2.SpawnGred()
	ww2.SpawnEnt(ReadDataMap("gred_emp_breda35"),"gred_emp_breda35")
    ww2.SpawnEnt(ReadDataMap("gred_emp_dshk"),"gred_emp_dshk")
    ww2.SpawnEnt(ReadDataMap("gred_ammobox"),"gred_ammobox")
    ww2.SpawnEnt(ReadDataMap("gred_emp_2a65"),"gred_emp_2a65")
	ww2.SpawnEnt(ReadDataMap("gred_emp_pak40"),"gred_emp_pak40")
end

function ww2.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	--roundTime = 60 * (2 + math.min(#player.GetAll() / 4,2))
	roundTime = 900

	tdm.DirectOtherTeam(3,1,2)

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	--local spawnsT,spawnsCT = ww2.SpawnsTwoCommand()
	--ww2.SpawnCommand(team.GetPlayers(1),spawnsT)
	--ww2.SpawnCommand(team.GetPlayers(2),spawnsCT)

	ww2.SpawnVehicle()
	ww2.SpawnGred()

	ww2.oi = false

	--tdm.CenterInit()

    ww2.SelectRandomPlayers(team.GetPlayers(1),2,ww2.GiveMimomet)
    ww2.SelectRandomPlayers(team.GetPlayers(1),2,ww2.GiveAidPhone)

    ww2.SelectRandomPlayers(team.GetPlayers(2),2,ww2.GiveMimomet)
    ww2.SelectRandomPlayers(team.GetPlayers(2),2,ww2.GiveAidPhone)
end

function ww2.Think()
    ww2.LastWave = ww2.LastWave or CurTime() + 60

    if CurTime() >= ww2.LastWave then
        SetGlobalInt("ww2_respawntime", CurTime())
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
                ww2.SelectRandomPlayers(list[1],6,ww2.GiveAidPhone)
                ww2.SelectRandomPlayers(list[2],6,ww2.GiveAidPhone)
            end*/
        end
        for ent in pairs(ww2.ragdolls) do
            if IsValid(ent) then ent:Remove() end
            ww2.ragdolls[ent] = nil
        end
        ww2.LastWave = CurTime() + 60
    end
end

function ww2.GetCountLive(list,func)
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

function ww2.PointsThink()
    local ww2_points = ww2.points
    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        local v = ww2_points[i]
        if not v then
            v = {}
            ww2_points[i] = v
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
            ww2.WinPoints[v.CaptureTeam] = ww2.WinPoints[v.CaptureTeam] + 7.5 / #SpawnPointsList.controlpoint[3]
        end

        SetGlobalInt(i .. "PointProgress", v.CaptureProgress)
        SetGlobalInt(i .. "PointCapture", v.CaptureTeam)
    end

    for i = 1, 2 do
        SetGlobalInt("ww2_Winpoints" .. i, ww2.WinPoints[i])
    end
end

/*function ww2.RoundEndCheck()
	local TAlive = tdm.GetCountLive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountLive(team.GetPlayers(2))

	if roundTimeStart + roundTime - CurTime() <= 0 then EndRound() end

	if TAlive == 0 and CTAlive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if CTAlive == 0 then EndRound(1) end

	tdm.Center()
end*/

function ww2.RoundEndCheck()
    for i = 1, 2 do
        if ww2.WinPoints[i] >= 1000 then
            EndRound(i)
        end
    end
    if roundTimeStart + roundTime < CurTime() then EndRound() end
end

function ww2.EndRound(winner)
	print("End round, win '" .. tostring(winner) .. "'")

	for _, ply in ipairs(player.GetAll()) do
		if !winner then ply:ChatPrint("Победила дружба") continue end
		if winner == ply:Team() then ply:ChatPrint("Победа") end
		if winner ~= ply:Team() then ply:ChatPrint("Поражение") end
	end

    timer.Remove("ww2_NewWave")
    timer.Remove("ww2_ThinkAboutPoints")
end

function ww2.PlayerInitialSpawn(ply) ply:SetTeam(math.random(1,2)) end

function ww2.PlayerSpawn(ply,teamID)
	local teamTbl = ww2[ww2.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])

	if teamID == 1 then
		ply:SetBodygroup(1,6)
		ply:SetBodygroup(2,3)
	end
		if teamID == 2 then
		ply:SetBodygroup(1,2)
	end

    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	tdm.GiveSwep(ply,teamTbl.main_weapon)
	--tdm.GiveSwep(ply,teamTbl.secondary_weapon)

	--if math.random(1,4) == 4 then ply:Give("adrinaline") end
	--if math.random(1,4) == 4 then ply:Give("morphine") end
	--if math.random(1,4) == 4 then ply:Give("weapon_hg_sleagehammer") end
	
	JMod.EZ_Equip_Armor(ply,"Medium-Helmet",color)
	--local r = math.random(1,2)
	--JMod.EZ_Equip_Armor(ply,(r == 1 and "Medium-Vest") or (r == 2 and "Light-Vest"),color)

	if roundStarter then
		ply:Give("weapon_gredmimomet")
		ply:Give("weapon_gredammo")
		ply:Give("weapon_phone")
		ply.allowFlashlights = true
	end
end

function ww2.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
end
function ww2.PlayerDeath(ply,inf,att)
    ww2.ragdolls[ply:GetNWEntity("Ragdoll")] = true
    return false
end
function ww2.ShouldSpawnLoot() return false end