
function ffa.StartRoundSV()
    tdm.RemoveItems()

    roundTimeStart = CurTime()
    roundTime = 300 + math.random(0, 300)

    local players = PlayersInGame()
    for i, ply in ipairs(players) do
        ply:SetTeam(1)
        ply:SetNWInt("KillCount", 0)
        ffa.PlayerSpawn2(ply)
    end

    local aviable = ReadDataMap("dm")
    aviable = #aviable ~= 0 and aviable or homicide.Spawns()

    tdm.SpawnCommand(team.GetPlayers(1), aviable, function(ply)
        ply:Freeze(true)
    end)

    freezing = true
    roundTimeRespawn = CurTime() + 10


    return {roundTimeStart, roundTime}
end

local function giveAmmoForWeapons(ply)
    for _, weapon in ipairs(ply:GetWeapons()) do
        local ammoType = weapon:GetPrimaryAmmoType()
        if ammoType >= 0 then
            ply:SetAmmo(weapon:GetMaxClip1() * 3, ammoType)
        end
    end
end

local primaryWeapons = {
    [1] = {"weapon_mp7", "weapon_aks74u", "weapon_akm", "weapon_uzi", "weapon_m4a1", "weapon_hk416", "weapon_galil"},
    [2] = {"weapon_spas12", "weapon_xm1014", "weapon_remington870", "weapon_m590"},
    [3] = {"weapon_mateba"},
    [4] = {"weapon_hk_usp", "weapon_p99", "weapon_beretta"}
}

local secondaryWeapons = {
    [2] = {"weapon_uzi", "weapon_p99", "weapon_glock", "weapon_fiveseven"}
}

local extraItems = {
    ["knife"] = "weapon_kabar",
    ["medkit"] = "medkit",
    ["bandage"] = "med_band_big",
    ["grenade"] = "weapon_hg_rgd5",
    ["bomb"] = "weapon_hidebomb",
    ["radio"] = "weapon_radio"
}

function ffa.PlayerSpawn2(ply)
    ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:SetPlayerColor(Vector(0, 1, 0.051))

    local roundDmType = math.random(1, 4)
    local primaryWeapon = primaryWeapons[roundDmType][math.random(#primaryWeapons[roundDmType])]
    ply:Give(primaryWeapon)


    if roundDmType == 2 then
        local secondaryWeapon = secondaryWeapons[2][math.random(#secondaryWeapons[2])]
        ply:Give(secondaryWeapon)
    end


    ply:Give(extraItems["knife"])
    ply:Give(extraItems["medkit"])
    ply:Give(extraItems["bandage"])
    ply:Give(extraItems["radio"])


    if roundDmType == 2 or roundDmType == 4 then
        ply:Give(extraItems["grenade"])
    end

    if roundDmType == 4 then
        ply:Give(extraItems["bomb"])
    end


    giveAmmoForWeapons(ply)

    ply:SetLadderClimbSpeed(100)

    ply:Give("weapon_hands")
end



function ffa.RoundEndCheck()
    local winner = nil
    local highestKills = 0
    local topPlayer = nil

    for i, ply in ipairs(team.GetPlayers(1)) do
        local kills = ply:GetNWInt("KillCount", 0)

        if kills >= 50 then
            winner = ply
            break
        end

        if kills > highestKills then
            highestKills = kills
            topPlayer = ply
        end
    end

    if winner then
        EndRound(winner)
    elseif roundTimeStart + roundTime < CurTime() then
        EndRound(topPlayer)
    end
end


function ffa.EndRound(winner)
    if winner then
        PrintMessage(3, winner:GetName() .. " won with " .. winner:GetNWInt("KillCount") .. " kills!")
    else
        PrintMessage(3, "Time is up! No one reached 50 kills.")
    end

    for i, ply in ipairs(player.GetAll()) do
        ply:SetNWInt("KillCount", 0)
    end
end

function ffa.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function ffa.PlayerCanJoinTeam(ply, teamID)
    if teamID ~= 1 then
        ply:ChatPrint("Only one team is available.")
        return false
    end
    return true
end
