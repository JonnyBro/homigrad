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
			local ply = table.Random(team.GetPlayers(1))
			ply:SetTeam(2)
		else
			local ply = table.Random(team.GetPlayers(2))
			ply:SetTeam(1)
		end
	end
end

function OpposingAllTeam()
	local oldT, oldCT = {}, {}

	table.CopyFromTo(team.GetPlayers(1), oldT)
	table.CopyFromTo(team.GetPlayers(2), oldCT)

	for _, ply in pairs(oldT) do
		ply:SetTeam(2)
	end

	for _, ply in pairs(oldCT) do
		ply:SetTeam(1)
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