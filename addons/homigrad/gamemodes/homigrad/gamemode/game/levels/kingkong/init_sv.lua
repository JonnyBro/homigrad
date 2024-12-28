
local function makeT(ply)
    ply.roleT = true
    table.insert(kingkong.t,ply)

    ply:Give("weapon_kingkong")
    ply:Give("medkit")
    ply:Give("med_band_small")
    ply:Give("med_band_big")
    ply.nopain = true
    ply.blood = 50000
    ply:SetMaxHealth(#player.GetAll() * 2147480000)
    ply:SetHealth(#player.GetAll() * 2147480000)

    ply:ChatPrint("Вы КИНГ КОНГ.")
end

function kingkong.SpawnsCT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("spawnpointsnaem")) do
        table.insert(aviable,point)
    end

    return aviable
end

function kingkong.SpawnsT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("spawnpointswick")) do
        table.insert(aviable,point)
    end

    return aviable
end

function kingkong.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 1.5),1) * 60

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    for i,ply in pairs(player.GetAll()) do ply.roleT = false end

    kingkong.t = {}

    local countT = 0

    local aviable = kingkong.SpawnsCT()
    local aviable2 = kingkong.SpawnsT()

    local players = PlayersInGame()

    local count = 1
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end

    kingkong.SyncRole()

    tdm.SpawnCommand(players,aviable,function(ply)
        ply.roleT = false
        ply:Give("weapon_hands")
        ply:Give("weapon_gurkha")
    end)

    tdm.SpawnCommand(kingkong.t,aviable2,function(ply)
        timer.Simple(1,function()
            ply.nopain = true
        end)
    end)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

function kingkong.RoundEndCheck()
    tdm.Center()

    if roundTimeStart + roundTime - CurTime() <= 0 then EndRound() end
	local TAlive = tdm.GetCountLive(kingkong.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
        EndRound(1)
	end

	if TAlive == 0 and Alive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if Alive == 0 then EndRound(1) end
end

function kingkong.EndRound(winner)
    PrintMessage(3,(winner == 1 and "Победа КИНГ КОНГА." or winner == 2 and "Победа людей." or "Ничья"))
end

local empty = {}

function kingkong.PlayerSpawn(ply, teamID)
    local teamTbl = kingkong[kingkong.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]

    if ply.roleT then
        ply:SetModel("models/vedatys/orangutan.mdl")
        ply.Blood = 500000
        net.Start("info_blood")
        net.WriteFloat(ply.Blood)
        net.Send(ply)
    else
        ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    end

    ply:SetPlayerColor(color:ToVector())
    timer.Simple(0,function() ply.allowFlashlights = false end)
end

function kingkong.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function kingkong.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("homicide_roleget2")

function kingkong.SyncRole()
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
    end

    net.Start("homicide_roleget2")
    net.WriteTable(role)
    net.Broadcast()
end

function kingkong.PlayerDeath(ply,inf,att) return false end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","painkiller"}
local rare = {"weapon_glock18","weapon_gurkha","weapon_t","weapon_per4ik","*ammo*"}

function kingkong.ShouldSpawnLoot()
    return false
end

function kingkong.GuiltLogic(ply,att,dmgInfo)
    return (not ply.roleT) == (not att.roleT) and 20 or 0
end