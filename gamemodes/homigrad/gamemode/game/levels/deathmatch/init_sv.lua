function dm.StartRoundSV()
    tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (1 + math.min(#player.GetAll() / 8,2))

    local players = PlayersInGame()
    for i,ply in pairs(players) do ply:SetTeam(1) end

    local aviable = ReadDataMap("dm")
    aviable = #aviable ~= 0 and aviable or homicide.Spawns()
    tdm.SpawnCommand(team.GetPlayers(1),aviable,function(ply)
        ply:Freeze(true)
    end)

    freezing = true

    RTV_CountRound = RTV_CountRound - 1

    roundTimeRespawn = CurTime() + 15

    roundDmType = math.random(1,4)

    return {roundTimeStart,roundTime}
end

function dm.RoundEndCheck()
    local Alive = 0

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply:Alive() then Alive = Alive + 1 end
    end

    if freezing and roundTimeStart + dm.LoadScreenTime < CurTime() then
        freezing = nil

        for i,ply in pairs(team.GetPlayers(1)) do
            ply:Freeze(false)
        end
    end

    if Alive <= 1 then EndRound() return end

end

function dm.EndRound(winner)
    for i, ply in ipairs( player.GetAll() ) do
	    if ply:Alive() then
            PrintMessage(3,ply:GetName() .. " победил в данном раунде.")
        end
    end
end

local red = Color(255,0,0)

function dm.PlayerSpawn(ply,teamID)
	ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:SetPlayerColor(Vector(0,0,0.6))


    ply:Give("weapon_hands")
    if roundDmType == 1 then
        local r = math.random(1,8)
        ply:Give((r==1 and "weapon_mp7") or (r==2 and "weapon_ak74u") or (r==3 and "weapon_akm") or (r==4 and "weapon_rpgg" and "weapon_ump") or (r==5 and "weapon_m4a1") or (r==6 and "weapon_mk18") or (r==7 and "weapon_m4a1") or (r==8 and "weapon_galil"))
        ply:Give("weapon_kabar")
        ply:Give("medkit")
        ply:Give("med_band_big")
        ply:Give("shina")
        ply:SetAmmo( 90, (r==1 and 46) or (r==2 and 44) or (r==3 and 47) or (r>=5 and 45))
    elseif roundDmType == 2 then
        local r = math.random(1,4)
        local p = math.random(1,4)
        ply:Give((r==1 and "weapon_spas12") or (r==2 and "weapon_xm1014") or (r==3 and "weapon_remington870") or (r==4 and "weapon_minu14"))
        ply:Give((p==1 and "weapon_ump") or p==2 and ("weapon_fiveseven") or p==3 and ("weapon_glock") or p==4 and ("weapon_glock18"))
        ply:Give("weapon_kabar")
        ply:Give("medkit")
        ply:Give("med_band_big")
        ply:Give("weapon_hg_rgd5")
        ply:Give("shina")
        ply:SetAmmo( 90, (p<=3 and 49) or (p==4 and "5.7×28 mm"))
        ply:SetAmmo( 90, 41 )
    elseif roundDmType == 3 then
        local r = math.random(1,5)
        ply:Give("weapon_deagle")
        ply:Give("weapon_kabar")
        ply:Give("medkit")
        ply:Give("med_band_big")
        ply:Give("shina")
        ply:SetAmmo( 90,("weapon_deagle" and ".44 Remington Magnum"))
        elseif roundDmType == 4 then
        local r = math.random(1,3)
        ply:Give((r==1 and "weapon_hk_usp") or (r==2 and "weapon_fiveseven") or (r==3 and "weapon_beretta"))
        ply:Give("weapon_kabar")
        ply:Give("med_band_big")
        ply:Give("weapon_hg_rgd5")
        ply:Give("shina")
        ply:Give("weapon_hidebomb")
        ply:SetAmmo( 50, 49 )
        else
        local r = math.random(1,3)
        ply:Give((r==1 and "weapon_hk_usp") or (r==2 and "weapon_fiveseven") or (r==3 and "weapon_beretta"))
        ply:Give("weapon_kabar")
        ply:Give("med_band_big")
        ply:Give("weapon_hg_rgd5")
        ply:Give("shina")
        ply:Give("weapon_hidebomb")
        ply:SetAmmo( 50, 49 )
    end
    ply:Give("weapon_radio")

    ply:SetLadderClimbSpeed(100)

end

function dm.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function dm.PlayerCanJoinTeam(ply,teamID)
	if teamID == 2 or teamID == 3 then ply:ChatPrint("пашол нахуй") return false end

    return true
end

function dm.GuiltLogic() return false end

util.AddNetworkString("dm die")
function dm.PlayerDeath()
    net.Start("dm die")
    net.Broadcast()
end