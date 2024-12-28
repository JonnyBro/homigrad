local function GetFriends(play)
    
    local huy = ""

    for i, ply in pairs(homicide.t) do
        if play == ply then continue end
        huy = huy .. ply:Name() .. ", "
    end

    return huy
end

COMMANDS.homicide_get = {function(ply,args)
    if not ply:IsAdmin() then return end

    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
        if ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("homicide_roleget")
    net.WriteTable(role)
    net.Send(ply)
end}

function homicide.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

local function makeT(ply)
    ply.roleT = true -- Игрока не существует. Выдаёт из-за этого ошибку в первый раз.
    table.insert(homicide.t, ply)

    local shouldGiveJahidka = math.random() < 0.25 -- 25% шанс на выдачу оружия

    if homicide.roundType == 1 or homicide.roundType == 2 then
        local wep = ply:Give("weapon_hk_usps")
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        if shouldGiveJahidka then
            ply:Give("weapon_jahidka")
        end
    elseif homicide.roundType == 3 then
        local wep = ply:Give("weapon_hk_arbalet")
        ply:GiveAmmo(6, "XBowBolt", true) -- slots = bolts.
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_t_syringepoison")
        ply:Give("weapon_hg_t_vxpoison")
        if shouldGiveJahidka then
            ply:Give("weapon_jahidka")
        end
        print(player.GetCount())
    elseif homicide.roundType == 4 then
        local wep = ply:Give("weapon_deagle")
        ply:GiveAmmo(3*8, ".44 Remington Magnum", true) -- slots = bullets.
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        if shouldGiveJahidka then
            ply:Give("weapon_jahidka")
        end
        ply:GiveAmmo(12, 5)
    elseif homicide.roundType == 5 then
        local wep = ply:Give("weapon_hk_usps")
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        if shouldGiveJahidka then
            ply:Give("weapon_jahidka")
        end
        ply:GiveAmmo(12,5)
end
    timer.Simple(5,function() ply.allowFlashlights = true end)

    AddNotificate( ply,"Вы предатель.")

    if #GetFriends(ply) >= 1 then
        timer.Simple(1,function() AddNotificate( ply,"Ваши товарищи " .. GetFriends(ply)) end)
    end
end

local function makeCT(ply)
    ply.roleCT = true
    table.insert(homicide.ct,ply)
    if homicide.roundType == 1 then
        local wep = ply:Give("weapon_doublebarrel_dulo")
        ply:GiveAmmo(4, "12/70 gauge", true) -- slots = bullets.
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"Вы невиновный с дробовиком вашего деда.")
    elseif homicide.roundType == 2 then
        local wep = ply:Give("weapon_beretta")
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"Вы невиновный со скрытым огнестрельным оружием.")
    elseif homicide.roundType == 3 then
        local wep = ply:Give("weapon_taser")
        ply:Give("weapon_police_bat")
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"Вы полицейский под прикрытием. Вам выдан шокер и дубинка\nВаша задача: связать преступника.")
    elseif homicide.roundType == 4 then
        local wep = ply:Give("weapon_deagle")
        AddNotificate( ply,"Вы невиновный ковбой с револьвером в кобуре.")
    end

end

COMMANDS.russian_roulette = {function(ply,args)
    if not ply:IsAdmin() then return end

    for i,plya in pairs(player.GetListByName(args[1]) or {ply}) do
        local wep = plya:Give("weapon_deagle",true)
        wep:SetClip1(1)
        wep:RollDrum()
    end
end}

function homicide.Spawns()
    local aviable = {}

    for i,ent in pairs(ents.FindByClass("info_player*")) do
        table.insert(aviable,ent:GetPos())
    end

    for i,ent in pairs(ents.FindByClass("info_node*")) do
        table.insert(aviable,ent:GetPos())
    end

    for i,point in pairs(ReadDataMap("spawnpointst")) do
        table.insert(aviable,point)
    end

    for i,point in pairs(ReadDataMap("spawnpointsct")) do
        table.insert(aviable,point)
    end

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

function homicide.StartRoundSV()
    RunConsoleCommand("sv_gravity", "600")
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

    homicide.police = false
    roundTimeStart = CurTime()
    roundTime = math.max(math.ceil(#player.GetAll() / 2),1) * 60

    if homicide.roundType == 3 then
        roundTime = roundTime * 1.25
    end

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end

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
    end)
    
    if homicide.roundType == 4 then
        local players = PlayersInGame()
        for _, ply in ipairs(players) do
            ply:Give("weapon_deagle")
        end
    end
    
    if homicide.roundType == 5 then
        local players = PlayersInGame()
        for _, ply in ipairs(players) do
            local r = math.random(1, 15)
		  --  local p = math.random(1, 6)
            ply:Give(r == 1 and "weapon_xm1014" or r == 2 and "weapon_ar15" or r == 3 and "weapon_rpk" or r == 4 and "weapon_xm8_lmg" or r == 5 and "weapon_l1a1" or r == 6 and "weapon_galil" or r == 7 and "weapon_civil_famas" or r == 8 and "weapon_ump" or r == 9 and "weapon_mp5" or r == 10 and "weapon_minu14" or r == 11 and "weapon_m1a1" or r == 12 and "weapon_m14" or r == 13 and "weapon_vector" or r == 14 and "weapon_ck98" or r == 15 and "weapon_cppsh41", true)
			ply:GiveAmmo(20, r == 1 and "12/70 gauge" or r == 2 and "5.56x45 mm" or r == 3 and "7.62x39 mm" or r == 4 and "ar2" or r == 5 and "ar2" or r == 6 and "5.56x45 mm" or r == 7 and "5.56x45 mm" or r == 8 and "9х19 mm Parabellum" or r == 9 and "9х19 mm Parabellum" or r == 10 and "12/70 gauge" or r == 11 and "9х19 mm Parabellum" or r == 12 and "9х19 mm Parabellum" or r == 13 and "9х19 mm Parabellum" or r == 14 and "7.62x39 mm" or r == 15 and "9х19 mm Parabellum", true)
        end
    end

    local players = PlayersInGame()
    local count = math.max(math.random(1,math.ceil(#players / 16)),1) - countT
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end

    local count = math.max(math.random(1,math.ceil(#players / 16)),1) - countCT

    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        if homicide.roundType <= 4 then
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

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

COMMANDS.forcepolice = {function(ply)
    if not ply:IsAdmin() then PrintMessage(3,"Пошел нахуй, ОПку не взломал еще.") return end
    homicide.police = false

    roundTime = 0
end}

function homicide.RoundEndCheck()
    tdm.Center()

    local TAlive = tdm.GetCountLive(homicide.t)
    local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
        if not homicide.police then
            homicide.police = true
            if homicide.roundType == 1 then
                PrintMessage(3,"Спецназ приехал.")
            else
                PrintMessage(3,"Полиция приехала.")
            end

            local aviable = ReadDataMap("spawnpointsct")
            local ctPlayers = tdm.GetListMul(player.GetAll(),1,function(ply) return not ply:Alive() and not ply.roleT and ply:Team() ~= 1002 end)
            
            local playsound = true
            tdm.SpawnCommand(ctPlayers,aviable,function(ply)
                timer.Simple(0,function()
                    if homicide.roundType == 1 then
                        ply:SetPlayerClass("contr")
                    else
                        ply:SetPlayerClass("police")
                    end
                    if playsound then
                        ply:EmitSound("police_arrive")
                        playsound = false
                    end
                end)
            end)
            
        end
    end

    if TAlive == 0 and Alive == 0 then EndRound(1) return end

    if TAlive == 0 then EndRound(2) end
    if Alive == 0 then EndRound(1) end
end

function homicide.EndRound(winner)
    RunConsoleCommand("homicide_setmode", "99")    
    PrintMessage(3,(winner == 1 and "Победа предателей." or winner == 2 and "Победа невиновых." or "Ничья"))
    if homicide.t and #homicide.t > 0 then
        PrintMessage(3,#homicide.t > 1 and ("Трейторами были: " .. homicide.t[1]:Name() .. ", " .. GetFriends(homicide.t[1])) or ("Трейтором был: " .. homicide.t[1]:Name()))
    end
end

local empty = {}

function homicide.PlayerSpawn(ply,teamID)
    local teamTbl = homicide[homicide.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]

    ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    ply:SetPlayerColor(color:ToVector())

    ply:Give("weapon_hands")
    
    timer.Simple(0,function() ply.allowFlashlights = true end)
end

function homicide.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
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

function homicide.PlayerDeath(ply,inf,att) return false end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","weapon_per4ik","painkiller"}
local rare = {"weapon_glock18","weapon_gurkha","weapon_t","weapon_deagle","weapon_minu14"}

function homicide.ShouldSpawnLoot()
if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end
local chance = math.random(100)

if chance < 3 and not homicide.roundType == 3 then
    return true,rare[math.random(#rare)],"legend"
elseif chance < 20 then
    return true,uncommon[math.random(#uncommon)],"veryrare"
elseif chance < 80 then
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
    return ply.roleT == att.roleT
end