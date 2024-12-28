function construct.CanRoundNext()
    if #ReadDataMap("level_construct") ~= 0 then return true end
end

function construct.CanRandomNext() return false end

function construct.StartRoundSV()
    tdm.RemoveItems()

	for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
	for i,ply in pairs(team.GetPlayers(3)) do ply:SetTeam(1) end

    for i,ply in pairs(team.GetPlayers(1)) do
        ply:Spawn()
    end

    wait = CurTime() + 320

    SetGlobalBool("Can",true)

    return {wait}
end

function construct.RoundEndCheck()
    local alive = 0

    if wait and wait < CurTime() then
        wait = nil

        SetGlobalBool("Can",false)

        for i,ply in pairs(team.GetPlayers(1)) do
            ply:StripWeapons()
        end
    end

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply:Alive() then
            alive = alive + 1
        else
            -- Респавн игрока, если он мёртв
            ply:Spawn()
        end
    end

    if alive <= 1 then EndRound() end
end


function construct.EndRound()
    PrintMessage(3,"Если вы хотите закончить раунд, пропишите !levelend")
end

function construct.PlayerSpawn(ply)
    ply:Give("weapon_physgun")
    ply:Give("weapon_physcannon")
    ply:Give("gmod_tool")
    ply:SetModel("models/player/odessa.mdl")
end

function construct.PlayerInitialSpawn(ply) ply:SetTeam(1) end

function construct.PlayerCanJoinTeam(ply,teamID)
    if teamID == 2 or teamID == 3 then return false end
end

function construct.ShouldFakePhysgun(ply,ent) return false end

local validTypes = {
    prop = true
}

function construct.CanUseSpawnMenu(ply, class)
    if ply:GetUserGroup() == "blat" or ply:GetUserGroup() == "sponsor" or ply:IsAdmin() then
        return true
    elseif not validTypes[class] then
        return false
    end

    return GetGlobalBool("Can", false)
end
