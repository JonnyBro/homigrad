igib.ragdolls = {}

local function GetTeamSpawns(ply)
	local spawnsT = tdm.SpawnsTwoCommand()

	if ply:Team() == 1 then
		return spawnsT
	else
		return false
	end
end

function igib.StartRoundSV()
	local players = PlayersInGame()
	local spawnsT, _ = tdm.SpawnsTwoCommand()

	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTimeRespawn = CurTime() + 15
	roundTime = 300

	tdm.SpawnCommand(team.GetPlayers(1), spawnsT)

	for _, ply in pairs(players) do
		ply:SetTeam(1)
	end

	return {roundTimeStart, roundTime}
end

function igib.Think()
	igib.LastWave = igib.LastWave or CurTime() + 15

	if CurTime() >= igib.LastWave then
		SetGlobalInt("igib_respawntime", CurTime())

		for _, v in player.Iterator() do
			local players = {}

			if not v:Alive() and v:Team() ~= 1002 then
				v:Spawn()

				local teamspawn = GetTeamSpawns(v)
				local point, _ = RandomFromTable(teamspawn)
				point = ReadPoint(point)

				if not point then continue end

				v:SetPos(point[1])

				players[v:Team()] = players[v:Team()] or {}
				players[v:Team()][v] = true
			end
		end

		for ent in pairs(igib.ragdolls) do
			if IsValid(ent) then ent:Remove() end

			igib.ragdolls[ent] = nil
		end

		igib.LastWave = CurTime() + 15
	end
end

function igib.RoundEndCheck()
	if roundTimeStart + roundTime < CurTime() then EndRound() end
end

function igib.EndRound(winner)
	for _, ply in ipairs(player.GetAll()) do
		if ply:Alive() then PrintMessage(3, "Раунд окончен.") end
	end
end

function igib.PlayerSpawn2(ply, teamID)
	ply:SetModel(tdm.models[math.random(#tdm.models)])
	ply:SetPlayerColor(Vector(0, 0, 0.6))

	ply:Give("weapon_igib")

	ply:SetLadderClimbSpeed(100)
	ply:SetWalkSpeed(350)
	ply:SetRunSpeed(700)
end

function igib.PlayerInitialSpawn(ply)
	ply:SetTeam(1)
end

function igib.PlayerCanJoinTeam(ply, teamID)
	if teamID == 2 or teamID == 3 then return false end
	return true
end

function igib.GuiltLogic()
	return false
end

util.AddNetworkString("dm die")

function igib.PlayerDeath()
	net.Start("dm die")
	net.Broadcast()
end