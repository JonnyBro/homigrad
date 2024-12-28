bodycam.ragdolls = {}
local function GetTeamSpawns(ply)
	local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()

    if ply:Team() == 1 then
        return spawnsT
    elseif ply:Team() == 2 then
        return spawnsCT
    else
        return false
    end
end

function bodycam.SpawnCommand(tbl,aviable,func,funcShould)
	for i,ply in RandomPairs(tbl) do
		if funcShould and funcShould(ply) ~= nil then continue end

		if ply:Alive() then ply:KillSilent() end

		if func then func(ply) end

		ply:Spawn()
		ply.allowFlashlights = true

		local point,key = table.Random(aviable)
		point = ReadPoint(point)
		if not point then continue end

		ply:SetPos(point[1])
		if #aviable > 1 then table.remove(aviable,key) end
	end
end

function bodycam.DirectOtherTeam(start,min,max)
	if not max then max = min end

	for i = start,team.MaxTeams do
		for i,ply in pairs(team.GetPlayers(i)) do
			ply:SetTeam(math.random(min,max))
		end
	end
end

function bodycam.GetListMul(list,mul,func,max)
	local newList = {}
	mul = math.Round(#list * mul)
	if max then mul = math.max(mul,max) end

	for i = 1,mul do
		local ply,key = table.Random(list)
		list[key] = nil

		if func and func(ply) ~= true then continue end

		newList[#newList + 1] = ply
	end

	return newList
end

changeClass = {
	["prop_vehicle_jeep"]="vehicle_van",
	["prop_vehcle_jeep_old"]="vehicle_van",
	["prop_vehicle_airboat"]="vehicle_van",
	["weapon_crowbar"]="weapon_bat",
	["weapon_stunstick"]="weapon_knife",
	["weapon_pistol"]="weapon_glock",
	["weapon_357"]="weapon_deagle",
	["weapon_shotgun"]="weapon_remington870",
	["weapon_crossbow"]="weapon_hk_arbalet",
	["weapon_ar2"]="weapon_ar15",
	["weapon_smg1"]="weapon_ar15",
	["weapon_frag"]="weapon_hg_f1",
	["weapon_slam"]="weapon_hg_molotov",

	["weapon_rpg"]="ent_ammo_46×30mm",
	["item_ammo_ar2_altfire"]="ent_ammo_762x39mm",
	["item_ammo_357"]="ent_ammo_.44magnum",
	["item_ammo_357_large"]="ent_ammo_.44magnum",
	["item_ammo_pistol"]="ent_ammo_9х19mm",
	["item_ammo_pistol_large"]="ent_ammo_9х19mm",
	["item_ammo_ar2"]="ent_ammo_556x45mm",
	["item_ammo_ar2_large"]="ent_ammo_556x45mm",
	["item_ammo_ar2_smg1"]="ent_ammo_545×39mm",
	["item_ammo_ar2_large"]="ent_ammo_556x45mm",
	["item_ammo_smg1"]="ent_ammo_545×39mm",
	["item_ammo_smg1_large"]="ent_ammo_762x39mm",
	["item_box_buckshot"]="ent_ammo_12/70gauge",
	["item_box_buckshot_large"]="ent_ammo_12/70gauge",
	["item_rpg_round"]="ent_ammo_57×28mm",
	["item_ammo_crate"]="ent_ammo_9x39mm",

	["item_healthvial"]="med_band_small",
	["item_healthkit"]="med_band_big",
	["item_healthcharger"]="medkit",
	["item_suitcharger"]="painkiller",
	["item_battery"]="blood_bag",
	["weapon_alyxgun"]={"food_fishcan","food_lays","food_monster","food_spongebob_home"}
}

function bodycam.RemoveItems()
	for i,ent in pairs(ents.GetAll()) do
		if ent:GetName() == "biboran" then
			ent:Remove()
		end
	end
end

/*function bodycam.StartRoundSV()
    bodycam.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 8,2))

	for i,ply in pairs(team.GetPlayers(3)) do ply:SetTeam(math.random(1,2)) end

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	local spawnsT,spawnsCT = bodycam.SpawnsTwoCommand()
	bodycam.SpawnCommand(team.GetPlayers(1),spawnsT)
	bodycam.SpawnCommand(team.GetPlayers(2),spawnsCT)
end*/

function bodycam.StartRoundSV()
    bodycam.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60*15 --15 минут

	for i,ply in pairs(team.GetPlayers(3)) do ply:SetTeam(math.random(1,2)) end

	OpposingAllTeam()
	AutoBalanceTwoTeam()

   local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)
    bodycam.ragdolls = {}
end

function bodycam.Think()
    bodycam.LastWave = bodycam.LastWave or 60

    if CurTime() >= bodycam.LastWave then
        SetGlobalInt("bodycam_respawntime", CurTime())
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
    
            for i,list in pairs(players) do
                bahmut.SelectRandomPlayers(list[1],6,bahmut.GiveAidPhone)
                bahmut.SelectRandomPlayers(list[2],6,bahmut.GiveAidPhone)
            end
        end
        for ent in pairs(bodycam.ragdolls) do
            if IsValid(ent) then ent:Remove() end
            bodycam.ragdolls[ent] = nil
        end
        bodycam.LastWave = 60
    end
end

function bodycam.GetCountLive(list,func)
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

function bodycam.PointsThink()
    local bodycam_points = bodycam.points
    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        local v = bodycam_points[i]
        if not v then
            v = {}
            bodycam_points[i] = v
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
            bodycam.WinPoints[v.CaptureTeam] = bodycam.WinPoints[v.CaptureTeam] + 7.5 / #SpawnPointsList.controlpoint[3]
        end

        SetGlobalInt(i .. "PointProgress", v.CaptureProgress)
        SetGlobalInt(i .. "PointCapture", v.CaptureTeam)
    end

    for i = 1, 2 do
        SetGlobalInt("bodycam_Winpoints" .. i, bodycam.WinPoints[i])
    end
end

function bodycam.RoundEndCheck()
    tdm.Center()

    for i = 1, 2 do
        if bodycam.WinPoints[i] >= 1000 then
            EndRound(i)
        end
    end
    if roundTimeStart + roundTime < CurTime() then EndRound() end
end

function bodycam.EndRound(winner)
	print("End round, win '" .. tostring(winner) .. "'")

	for _, ply in ipairs(player.GetAll()) do
		if !winner then ply:ChatPrint("Победила дружба") continue end
		if winner == ply:Team() then ply:ChatPrint("Победа") end
		if winner ~= ply:Team() then ply:ChatPrint("Поражение") end
	end

    timer.Remove("bodycam_NewWave")
    timer.Remove("bodycam_ThinkAboutPoints")
end

/*function bodycam.RoundEndCheck()
	if roundTimeStart + roundTime - CurTime() <= 0 then EndRound() end

	local TAlive = bodycam.GetCountLive(team.GetPlayers(1))
	local CTAlive = bodycam.GetCountLive(team.GetPlayers(2))

	if TAlive == 0 and CTAlive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if CTAlive == 0 then EndRound(1) end
end

function bodycam.EndRoundMessage(winner,textNobody)
	local tbl = TableRound()
	PrintMessage(3,"Выиграли - " .. ((winner == 1 and tbl.red[1]) or (winner == 2 and tbl.blue[1]) or (textNobody or "Дружба")) .. ".")
end

function bodycam.EndRound(winner) bodycam.EndRoundMessage(winner) end*/

--

function bodycam.GiveSwep(ply,list,mulClip1)
	if not list then return end

	local wep = ply:Give(type(list) == "table" and list[math.random(#list)] or list)

	mulClip1 = mulClip1 or 3

    if IsValid(wep) then
        wep:SetClip1(wep:GetMaxClip1())
	    ply:GiveAmmo(wep:GetMaxClip1() * mulClip1,wep:GetPrimaryAmmoType())
    end
end

function bodycam.PlayerSpawn(ply,teamID)
	local teamTbl = bodycam[bodycam.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	bodycam.GiveSwep(ply,teamTbl.main_weapon)
	bodycam.GiveSwep(ply,teamTbl.secondary_weapon)

	if math.random(1,4) == 4 then ply:Give("adrenaline") end
	if math.random(1,4) == 4 then ply:Give("morphine") end
	if math.random(1,3) == 3 then if ply:Team() == 1 then ply:Give("weapon_hg_f1") else ply:Give("weapon_hg_rgd5") end end
	
	local r = math.random(1,2)
	JMod.EZ_Equip_Armor(ply,(r == 1 and "Medium-Vest") or (r == 2 and "Light-Vest"),color)
end


function bodycam.PlayerInitialSpawn(ply) ply:SetTeam(math.random(2)) end

function bodycam.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
end

function bodycam.PlayerDeath(ply,inf,att)
    bodycam.ragdolls[ply:GetNWEntity("Ragdoll")] = true
    return false
end
function bodycam.CanRandomNext() return false end

--function bodycam.PlayerDeath(ply,inf,att) return false end