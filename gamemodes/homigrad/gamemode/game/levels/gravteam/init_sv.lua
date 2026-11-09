function gravteam.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 8,2))

	tdm.DirectOtherTeam(3,1,2)

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)

	tdm.CenterInit()
end

function gravteam.RoundEndCheck()

	if roundTimeStart + roundTime - CurTime() <= 0 then EndRound() end

	local TAlive = tdm.GetCountAlive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountAlive(team.GetPlayers(2))

	if TAlive == 0 and CTAlive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if CTAlive == 0 then EndRound(1) end

	tdm.Center()
end

function gravteam.EndRound(winner) tdm.EndRoundMessage(winner) end

function gravteam.PlayerInitialSpawn(ply) ply:SetTeam(math.random(1,2)) end

function gravteam.PlayerSpawn2(ply,teamID)
	local teamTbl = gravteam[gravteam.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])

    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	tdm.GiveSwep(ply,teamTbl.main_weapon)
	tdm.GiveSwep(ply,teamTbl.secondary_weapon)

	if teamID == 2 then
		ply:SetPlayerClass("combine")
	end

	if teamID == 1 then

		local r = math.random(1,2)
	end

end

function gravteam.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then ply:ChatPrint("Go fuck") return false end
end

function gravteam.ShouldSpawnLoot() return false end
function gravteam.PlayerDeath(ply,inf,att) return false end