function jailbreak.StartRoundSV(data)
    tdm.RemoveItems()

	tdm.DirectOtherTeam(1,2)

	roundTimeStart = CurTime()
	roundTime = 240 * (2 + math.min(#player.GetAll() / 16,2))
	roundTimeLoot = 30

    local players = team.GetPlayers(2)

    for i,ply in pairs(players) do
		ply.exit = false

		if ply.jailbreakForceT then
			ply.jailbreakForceT = nil

			ply:SetTeam(2)
		end
    end

	players = team.GetPlayers(2)

	local count = math.min(math.floor(#players / 1.2,1))
    for i = 1,count do
        local ply,key = table.Random(players)
		players[key] = nil

        ply:SetTeam(1)
    end

	local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)

	jailbreak.police = false

	tdm.CenterInit()

	return {roundTimeLoot = roundTimeLoot}
end

function jailbreak.RoundEndCheck()
    if roundTimeStart + roundTime < CurTime() then
		if not jailbreak.police then
			jailbreak.police = true
			PrintMessage(3,"Раунд Закончен.")

			EndRound(1)
		end
	end

	local TAlive = tdm.GetCountLive(team.GetPlayers(2))
	local CTAlive,CTExit = 0,0
	local OAlive = 0

	CTAlive = tdm.GetCountLive(team.GetPlayers(1),function(ply)
		if ply.exit then CTExit = CTExit + 1 return false end
	end)

	local list = ReadDataMap("spawnpoints_ss_exit")

	for i, ply in pairs(team.GetPlayers(1)) do
	    if not ply:Alive() then continue end

	    for i, point in pairs(list) do
	        if ply:GetPos():Distance(point[1]) < (point[3] or 250) then
	            ply.exit = true
	            ply:KillSilent()

	            CTExit = CTExit + 1

	            PrintMessage(3, "Заключенный сбежал, осталось " .. (CTAlive - 1) .. " заключенных")
	        end
	    end
	end

	OAlive = tdm.GetCountLive(team.GetPlayers(3))

	if CTExit > 0 and CTAlive == 0 then EndRound(2) return end
	if OAlive == 0 and TAlive == 0 and CTAlive == 0 then EndRound() return end

	if OAlive == 0 and TAlive == 0 then EndRound(2) return end
	if CTAlive == 0 then EndRound(1) return end
	if TAlive == 0 then EndRound(2) return end
end

function jailbreak.EndRound(winner) tdm.EndRoundMessage(winner) end

function jailbreak.PlayerSpawn(ply,teamID)
	local teamTbl = jailbreak[jailbreak.teamEncoder[teamID]]
	local color = teamTbl[1]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end
	
	tdm.GiveSwep(ply,teamTbl.main_weapon,teamID == 1 and 16 or 4)
	
	tdm.GiveSwep(ply,teamTbl.main_weapon,teamID == 2 and 16 or 4)
	tdm.GiveSwep(ply,teamTbl.secondary_weapon,teamID == 2 and 8 or 2)

    if teamID == 2 then
        JMod.EZ_Equip_Armor(ply,"Medium-Helmet",color)
        JMod.EZ_Equip_Armor(ply,"Light-Vest",color)
	elseif teamID == 1 then
		ply:SetPlayerColor(255,170,0)
    end
	ply.allowFlashlights = false

	    timer.Simple(5, function()
        if IsValid(ply) and ply:Alive() then
            ply:Give("weapon_hands")
        end
    end)
end

function jailbreak.PlayerInitialSpawn(ply) ply:SetTeam(2) end

function jailbreak.PlayerCanJoinTeam(ply,teamID)
	ply.jailbreakForceT = nil

	if teamID == 3 then
		if ply:IsAdmin() then
			ply:ChatPrint("Милости прошу")
			ply:Spawn()

			return true
		else
			ply:ChatPrint("Иди нахуй")

			return false
		end
	end

    if teamID == 1 then
		if ply:IsAdmin() then
			ply.jailbreakForceT = true

			ply:ChatPrint("Милости прошу")

			return true
		else
			ply:ChatPrint("Пашол нахуй")

			return false
		end
	end

	if teamID == 2 then
		if ply:Team() == 1 then
			if ply:IsAdmin() then
				ply:ChatPrint("ладно.")

				return true
			else
				ply:ChatPrint("Просижовай жопу до конца раунда, лох.")

				return false
			end
		end

		return true
	end
end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","painkiller"}
local rare = {"weapon_glock18","weapon_gurkha","weapon_t","weapon_per4ik"}

function jailbreak.ShouldSpawnLoot()
   	if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end

	local chance = math.random(100)
	if chance < 5 then
		return true,rare[math.random(#rare)]
	elseif chance < 30 then
		return true,uncommon[math.random(#uncommon)]
	elseif chance < 70 then
		return true,common[math.random(#common)]
	else
		return false
	end
end

function jailbreak.PlayerDeath(ply,inf,att) return false end

function jailbreak.GuiltLogic(ply,att,dmgInfo)
	if att.isContr and ply:Team() == 2 then return dmgInfo:GetDamage() * 3 end
end

function jailbreak.NoSelectRandom()
	local a,b,c = string.find(string.lower(game.GetMap()),"jb")
    return a ~= nil
end