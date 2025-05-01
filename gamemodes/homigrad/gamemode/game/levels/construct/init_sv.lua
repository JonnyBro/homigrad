construct.ragdolls = {}

local function GetTeamSpawns(ply)
	local spawnsT = tdm.SpawnsTwoCommand()

	if ply:Team() == 1 then return spawnsT
	else return false end
end

function construct.StartRoundSV()
	local players = PlayersInGame()
	local spawnsT, _ = tdm.SpawnsTwoCommand()

	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTimeRespawn = CurTime() + 15
	roundTime = 7 * 24 * 60 * 60 -- Seven days in seconds.

	tdm.SpawnCommand(team.GetPlayers(1), spawnsT)

	for _, ply in pairs(players) do
		ply:SetTeam(1)
	end

	return {roundTimeStart, roundTime}
end

function construct.Think()
	construct.LastWave = construct.LastWave or CurTime() + 15

	if CurTime() >= construct.LastWave then
		SetGlobalInt("construct_respawntime", CurTime())

		for _, v in player.Iterator() do
			local players = {}

			if not v:Alive() and v:Team() ~= 1002 then
				v:Spawn()

				local teamspawn = GetTeamSpawns(v)
				local key = math.random(#teamspawn)
				local point = ReadPoint(teamspawn[key])

				if point then
					v:SetPos(point[1])

					table.remove(teamspawn, key)
				end

				players[v:Team()] = players[v:Team()] or {}
				players[v:Team()][v] = true
			end
		end

		for ent in pairs(construct.ragdolls) do
			if IsValid(ent) then ent:Remove() end
			construct.ragdolls[ent] = nil
		end

		construct.LastWave = CurTime() + 10
	end
end

function construct.PlayerSpawn2(ply, teamID)
	ply:SetModel(tdm.models[math.random(#tdm.models)])

	ply:SetPlayerColor(Vector(0, 0, 0.6))

	ply:Give("weapon_physgun")
	ply:Give("weapon_hands")

	-- FIXME: This doesn't seem to work.
	if ply.allowGrab then ply.allowGrab = false end
end

function construct.PlayerInitialSpawn(ply)
	ply:SetTeam(1)
end

function construct.PlayerCanJoinTeam(ply, teamID)
	if teamID == 2 or teamID == 3 then return false end
	return true
end

function construct.GuiltLogic()
	return false
end

function construct.ShouldSpawnLoot()
	return false
end

util.AddNetworkString("construct_die")

function construct.PlayerDeath()
	net.Start("construct_die")
	net.Broadcast()
end