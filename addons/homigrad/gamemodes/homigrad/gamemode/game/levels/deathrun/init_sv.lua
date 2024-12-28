function deathrun.StartRoundSV(data)
    tdm.RemoveItems()

	tdm.DirectOtherTeam(1,2)

	roundTimeStart = CurTime()
	roundTime = 240 * (2 + math.min(#player.GetAll() / 16,2))
	roundTimeLoot = 30

    local players = team.GetPlayers(2)

    for i,ply in pairs(players) do
		ply.exit = false

		if ply.deathrunForceT then
			ply.deathrunForceT = nil

			ply:SetTeam(1)
		end
    end

	players = team.GetPlayers(2)

	local count = math.min(math.floor(#players / 4,1))
    for i = 1,count do
        local ply,key = table.Random(players)
		players[key] = nil

        ply:SetTeam(1)
    end

	local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)

	deathrun.police = false
	deathrun.escape = true

	tdm.CenterInit()

	return {roundTimeLoot = roundTimeLoot}
end


function deathrun.RoundEndCheck()
    if roundTimeStart + roundTime < CurTime() then
		if not deathrun.police then
			deathrun.police = true
			PrintMessage(3,"Раунд Закончен.")

			EndRound(1)
		end
	end

	local TAlive = tdm.GetCountLive(team.GetPlayers(1))
	local CTAlive,CTExit = 0,0
	local OAlive = 0

	CTAlive = tdm.GetCountLive(team.GetPlayers(2),function(ply)
		if ply.exit then CTExit = CTExit + 1 return false end
	end)

	local list = ReadDataMap("spawnpoints_ss_exit")

	if deathrun.escape then
		for i,ply in pairs(team.GetPlayers(2)) do
			if not ply:Alive() or ply.exit then continue end

			for i,point in pairs(list) do
				if ply:GetPos():Distance(point[1]) < (point[3] or 250) then
					ply.exit = true
					ply:KillSilent()

					CTExit = CTExit + 1

					PrintMessage(3,"Убегающий сбежал, осталось " .. (CTAlive - 1) .. " убегающих")
				end
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

function deathrun.EndRound(winner) tdm.EndRoundMessage(winner) end

function deathrun.PlayerSpawn(ply,teamID)
	local teamTbl = deathrun[deathrun.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	local r = math.random(1,5)
	ply:Give(r == 1 and "food_fishcan" or r == 2 and "food_spongebob_home" or r == 3 and "food_lays" or r == 4 and "food_monster" or r == 5 and "morphine")

	if teamID == 2 then
		ply:SetPlayerColor(Color(math.random(160),math.random(160),math.random(160)):ToVector())
    end
	ply.allowFlashlights = true
end

function deathrun.PlayerInitialSpawn(ply) ply:SetTeam(2) end

function deathrun.PlayerCanJoinTeam(ply,teamID)
	ply.deathrunForceT = nil

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
			ply.deathrunForceT = true

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

local common = {"weapon_hands"}
local uncommon = {"weapon_hands"}
local rare = {"weapon_hands"}

function deathrun.ShouldSpawnLoot()
   	if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end

	local chance = math.random(100)
	if chance < 5 then
		return false,rare[math.random(#rare)]
	elseif chance < 30 then
		return false,uncommon[math.random(#uncommon)]
	elseif chance < 70 then
		return false,common[math.random(#common)]
	else
		return false
	end
end

function deathrun.PlayerDeath(ply,inf,att) return false end

function deathrun.GuiltLogic(ply,att,dmgInfo)
	if att.isContr and ply:Team() == 2 then return dmgInfo:GetDamage() * 3 end
end

function deathrun.NoSelectRandom()
	local a,b,c = string.find(string.lower(game.GetMap()),"deathrun")
    return a ~= nil
end