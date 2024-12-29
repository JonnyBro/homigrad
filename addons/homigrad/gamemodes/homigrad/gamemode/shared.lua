DeriveGamemode("sandbox")

GM.Name = "homigrad"
GM.Author = "loh"
GM.Email = "N/A"
GM.Website = "N/A"
GM.TeamBased = true

include("loader.lua")

local start = SysTime()

print("Homigrad is loading...")

GM.includeDir("homigrad/gamemode/game/")

print("Homigrad loaded. Time used: " .. math.Round(SysTime() - start,4) .. "s")

function GM:CreateTeams()
	team.SetUp(1, "Terrorists", Color(255, 0, 0))
	team.SetUp(2, "Counter Terrorists", Color(0, 0, 255))
	team.SetUp(3, "Other", Color(0, 255, 0))
	team.MaxTeams = 3
end

function OpposingTeam(team)
	if team == 1 then
		return 2
	elseif team == 2 then
		return 1
	end
end

function ReadPoint(point)
	if TypeID(point) == TYPE_VECTOR then
		return {point, Angle(0, 0, 0)}
	elseif type(point) == "table" then
		if type(point[2]) == "number" then
			point[3] = point[2]
			point[2] = Angle(0, 0, 0)
		end

		return point
	end
end

function PlayersInGame()
	local newTbl = {}

	for i, ply in pairs(team.GetPlayers(1)) do
		newTbl[i] = ply
	end

	for i, ply in pairs(team.GetPlayers(2)) do
		newTbl[#newTbl + 1] = ply
	end

	for i, ply in pairs(team.GetPlayers(3)) do
		newTbl[#newTbl + 1] = ply
	end

	return newTbl
end