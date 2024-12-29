-- Include the player model manager script (adjust the path as necessary)
include("../../playermodelmanager_sv.lua")



local function GetFriends(play)
    
    local huy = ""

    for i, ply in pairs(homicide.t) do
        if play == ply then continue end
        huy = huy .. ply:Name() .. ", "
    end

    return huy
end

COMMANDS.homicide_get = {function(ply,args)
    if not (ply:IsAdmin() or (ply:GetUserGroup() == "operator") or (ply:GetUserGroup() == "tmod")) then return end
    if ply:Alive() then return end
    if not ply:Team() == TEAM_SPECTATOR then return end

    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
        if ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("homicide_roleget")
    net.WriteTable(role)
    net.Send(ply)
end}

local function makeT(ply)
    if not IsValid(ply) then return end
    ply.roleT = true --Игрока не существует. Выдаёт из-за этого ошибку в первый раз.
    table.insert(homicide.t,ply)

    if homicide.roundType == 1 or homicide.roundType == 2 then
        local wep = ply:Give("weapon_hk_usps")
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        ply:Give("weapon_radar")
        ply:GiveAmmo(wep:GetMaxClip1(),wep:GetPrimaryAmmoType())
    elseif homicide.roundType == 3 then
        local wep = ply:Give("weapon_hg_crossbow")
        ply:GiveAmmo(8, "XBowBolt", true) -- slots = bolts.
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_rgd5")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_radar")
    elseif homicide.roundType == 5 then
        local wep
        if math.random(1,2) == 1 then wep = ply:Give("weapon_scout") else wep = ply:Give("weapon_barret") end
        ply:GiveAmmo(20, "XBowBolt", true) -- slots = bolts.
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_rgd5")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_radar")
        print(player.GetCount())
    else
        local wep = ply:Give("weapon_mateba")
        ply:GiveAmmo(3*8, ".44 Remington Magnum", true) -- slots = bullets.
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        ply:Give("weapon_radar")
        ply:GiveAmmo(12,5)
    end

    timer.Simple(5,function() ply.allowFlashlights = true end)

    AddNotificate( ply,"You are a traitor.")

    if #GetFriends(ply) >= 1 then
        timer.Simple(1,function() AddNotificate( ply,"Your Traitor Buddies are" .. GetFriends(ply)) end)
    end
end

local function makeCT(ply)
    if not IsValid(ply) then return end
    ply.roleCT = true
    table.insert(homicide.ct,ply)
    if homicide.roundType == 1 or homicide.roundType == 5 then
        local wep = ply:Give("weapon_remington870")
        wep:SetClip1(wep:GetMaxClip1())
        ply:GiveAmmo(wep:GetMaxClip1(),wep:GetPrimaryAmmoType())
        --AddNotificate( ply,"#rounds.innocentShotgun")
    elseif homicide.roundType == 2 then
        local wep = ply:Give("weapon_beretta")
        wep:SetClip1(wep:GetMaxClip1())
        ply:GiveAmmo(wep:GetMaxClip1(),wep:GetPrimaryAmmoType())
        --AddNotificate( ply,"#rounds.innocentBerreta")
    elseif homicide.roundType == 3 then
        local wep = ply:Give("weapon_taser")
        ply:Give("weapon_police_bat")
        wep:SetClip1(wep:GetMaxClip1())
        ply:GiveAmmo(3,wep:GetPrimaryAmmoType())
        --AddNotificate( ply,"#rounds.innocentTaser")
    elseif homicide.roundType == 4 then
        local wep = ply:Give("weapon_mateba")
        wep:SetClip1(wep:GetMaxClip1())
        ply:GiveAmmo(3,wep:GetPrimaryAmmoType())
        --AddNotificate( ply,"#rounds.innocentWildWest")
    else
    end
end

COMMANDS.russian_roulette = {function(ply,args)
    if not ply:IsAdmin() then return end

	for i,plya in pairs(player.GetListByName(args[1]) or {ply}) do
		local wep = plya:Give("weapon_mateba",true)
        wep:SetClip1(1)
        wep:RollDrum()
	end
end}

function homicide.Spawns()
    local aviable = {}

    for i,point in pairs(ReadDataMap("spawnpointshiders")) do
        table.insert(aviable,point)
    end

    --[[
    for i,point in pairs(ReadDataMap("spawnpointst")) do
        table.insert(aviable,point)
    end

    for i,point in pairs(ReadDataMap("spawnpointsct")) do
        table.insert(aviable,point)
    end
    ]]
    return aviable
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
        --PrintMessage(3, ply:Name() .. " has been chosen to become a police officer.")
        NotifySupportArrival(ply, roundTimeStart + roundTime)
    end
end

function SpawnPolicePlayers()
    local aviable = ReadDataMap("spawnpointsct")
    local playsound = true

    local prePolicePlayers = PlayersDead(true)
    
    if not prePolicePlayers or table.IsEmpty(prePolicePlayers) then return end

    local ply = prePolicePlayers[1]

    homicide.police = true

    timer.Simple(0, function()
        if homicide.roundType == 1 then
            PrintMessage(3, "A SWAT Team has arrived.")
        else
            PrintMessage(3, "The Police have Arrived")
        end
        if playsound then
            ply:EmitSound("police_arrive")
            playsound = false
        end
    end)

    tdm.SpawnCommand(prePolicePlayers, aviable, function(ply)
        timer.Simple(0, function()
            if homicide.roundType == 1 then
                ply:SetPlayerClass("contr")
            else
                ply:SetPlayerClass("police")
            end
            
            if GetConVar("sv_announcetraitorsonpolicespawn"):GetBool() then
                if #homicide.t > 1 then
                    ply:ChatPrint("#chat.rounds.traitorAre")
                    ply:ChatPrint((homicide.t[1]:Name() .. ", " .. GetFriends(homicide.t[1])))
                else
                    ply:ChatPrint("#chat.rounds.traitorIs")
                    ply:ChatPrint(homicide.t[1]:Name())
                end
            end
        end)
    end)
end

hook.Add("Player Spawn","bruhwtf",function(ply)
    net.Start("homicide_roleget")
    net.WriteTable({{}, {}})
    net.Send(ply)
end)

function homicide.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

    homicide.police = false
	roundTimeStart = CurTime()
	roundTime = math.min(math.max(math.ceil(#player.GetAll() / 2), 1) * 45, 330)

    -- Bullshit check.
    if game.GetMap() == "gm_freeway_spacetunnel" then
        RunConsoleCommand("sv_gravity", "300")
    else
        RunConsoleCommand("sv_gravity", "600")
    end

    if homicide.roundType == 3 then
        roundTime = roundTime * 1.25
    end

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    --for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end

    homicide.ct = {}
    homicide.t = {}

    local countT = 0
    local countCT = 0

    local aviable = homicide.Spawns()
    
    tdm.SpawnCommand(PlayersInGame(),aviable,function(ply)
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

        if ply:IsUserGroup("sponsor") or ply:IsUserGroup("supporterplus") then
            ply:Give("weapon_vape")
        end
    end)

    local players = PlayersInGame()
    local count = math.max(math.ceil(#players / 10), 1) - countT
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end

    local count = math.max(math.ceil(#players / 10), 1) - countCT

    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        if homicide.roundType <= 5 then
            makeCT(ply)
        end
    end

    timer.Simple(0,function()
        for i,ply in pairs(homicide.t) do
            if not IsValid(ply) then table.remove(homicide.t,i) continue end

            homicide.SyncRole(ply,1)
        end

        for i,ply in pairs(homicide.ct) do
            if not IsValid(ply) then table.remove(homicide.ct,i) continue end

            homicide.SyncRole(ply,2)
        end
    end)

    tdm.CenterInit()

    prePolicePlayers = {}

    return {roundTimeLoot = roundTimeLoot}
end

function homicide.RoundEndCheck()
    tdm.Center()

	local TAlive = tdm.GetCountLive(homicide.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
		if not homicide.police then
            SpawnPolicePlayers()
		end
    elseif (roundTimeStart + 180) + roundTime < CurTime() then
        EndRound()
	end

	if TAlive == 0 and Alive == 0 then EndRound(1) return end

	if TAlive == 0 then EndRound(2) end
	if Alive == 0 then EndRound(1) end
end

function homicide.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
    --TryAssignPolice(ply)
end

local aviable = ReadDataMap("spawnpointsct")

COMMANDS.forcepolice = {function(ply)
    if not ply:IsAdmin() then PrintMessage(3,"nope") return end

    homicide.police = false
    roundTime = 0
end}

function homicide.EndRound(winner)
    PrintMessage(3,(winner == 1 and "Traitors Win!" or winner == 2 and "Innocents Win!" or "Nobody Wins..."))
    if homicide.t and #homicide.t > 0 then
        if #homicide.t > 1 then
            PrintMessage(3,"The Traitor's were:")
            PrintMessage(3,(homicide.t[1]:Name() .. ", " .. GetFriends(homicide.t[1])))
        else
            PrintMessage(3, "The Traitor was:")
            PrintMessage(3, homicide.t[1]:Name())
        end
    end
end

local empty = {}

function homicide.PlayerSpawn2(ply,teamID)
    local teamTbl = homicide[homicide.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]
    
    local validUserGroup = {
        servermanager = true,
        owner = true,
        superadmin = true,
        admin = true,
        operator = true,
        tmod = true,
        sponsor = true
    }
        
    if validUserGroup[ply:GetUserGroup()] and ply:GetInfo("hg_usecustommodel") == "true" then
        EasyAppearance.SetCustomModel(ply)
        print(ply:GetName().." Modle: "..tostring(ply:GetInfo("cl_playermodel")))
        print(ply:GetUserGroup())
    else
       EasyAppearance.SetAppearance(ply) -- Force this first``
    end
    
    ply:SetPlayerColor(color:ToVector())

	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = false end)
end

function homicide.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("homicide_roleget")

function homicide.SyncRole(ply,teamID)
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if teamID ~= 2 and ply.roleT then table.insert(role[1],ply) end
        if teamID ~= 1 and ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("homicide_roleget")
    net.WriteTable(role)
    net.Send(ply)
end

function homicide.PlayerDeath(ply,inf,att)
    --TryAssignPolice(ply)
    if (ply:IsAdmin() or (ply:GetUserGroup() == "operator") or (ply:GetUserGroup() == "tmod")) and ply:GetInfoNum("homicide_get",0) then
        local role = {{},{}}

        for i,ply in pairs(team.GetPlayers(1)) do
            if ply.roleT then table.insert(role[1],ply) end
            if ply.roleCT then table.insert(role[2],ply) end
        end
    
        net.Start("homicide_roleget")
        net.WriteTable(role)
        net.Send(ply)
    end
    return false
end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_hammer","weapon_pepperspray","painkiller"}
local rare = {"weapon_fiveseven","weapon_gurkha","weapon_t","weapon_mateba","weapon_m590"}

function homicide.ShouldSpawnLoot()
    if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end
    local chance = math.random(100)
    if chance < 2 and not homicide.roundType == 3 then
        return true,rare[math.random(#rare)],"legend"
    elseif chance < 20 then
        return true,uncommon[math.random(#uncommon)],"veryrare"
    elseif chance < 60 then
        return true,common[math.random(#common)],"common"
    else
        return false
    end
    --else
        --return true
end

function homicide.ShouldDiscordOutput(ply,text)
    if ply:Team() ~= 1002 and ply:Alive() then return false end
end

function homicide.ShouldDiscordInput(ply,text)
    if not ply:IsAdmin() then return false end
end

function homicide.GuiltLogic(ply,att,dmgInfo)
    return ply.roleT == att.roleT and 1 or 0
end

