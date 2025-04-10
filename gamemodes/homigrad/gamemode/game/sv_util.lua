LimitAutoBalance = 1

function NeedAutoBalance(addT, addCT)
	addT = addT or 0
	addCT = addCT or 0

	local count = (#team.GetPlayers(1) + addT) - (#team.GetPlayers(2) + addCT)
	if count == 0 then return end

	local favorT

	if count > 0 then
		favorT = true
	end

	local limit = math.min(#player.GetAll() - LimitAutoBalance - 1, LimitAutoBalance)
	count = math.max(math.abs(count) - limit, 0)
	if count == 0 then return end

	return favorT, count
end

function AutoBalanceTwoTeam()
	for _ in pairs(player.GetAll()) do
		local favorT, count = NeedAutoBalance()
		if not count then break end

		if favorT then
			local tm = team.GetPlayers(1)
			local ply = RandomFromTable(tm)
			ply:SetTeam(2)
		else
			local tm = team.GetPlayers(2)
			local ply = RandomFromTable(tm)
			ply:SetTeam(1)
		end
	end
end

function OpposingAllTeam()
	local allPlayers = {}

	for _, ply in pairs(team.GetPlayers(1)) do
		table.insert(allPlayers, ply)
	end

	for _, ply in pairs(team.GetPlayers(2)) do
		table.insert(allPlayers, ply)
	end

	for i = #allPlayers, 2, -1 do
		local j = math.random(i)
		allPlayers[i], allPlayers[j] = allPlayers[j], allPlayers[i]
	end

	for i, ply in ipairs(allPlayers) do
		if i % 2 == 0 then
			ply:SetTeam(1)
		else
			ply:SetTeam(2)
		end
	end
end

function PlayersInGame()
	local newTbl = {}

	for _, ply in pairs(team.GetPlayers(1)) do
		newTbl[i] = ply
	end

	for _, ply in pairs(team.GetPlayers(2)) do
		table.insert(newTbl, ply)
	end

	for _, ply in pairs(team.GetPlayers(3)) do
		table.insert(newTbl, ply)
	end

	return newTbl
end

local EntityMeta = FindMetaTable("Entity")

oldSetModel = oldSetModel or EntityMeta.SetModel

function EntityMeta:SetModel(str)
	self:SetSubMaterial()
	self:SetNWString("EA_Attachments", nil)

	oldSetModel(self, str)
end