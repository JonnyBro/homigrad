-- NOTE: chat commands were moved to ULX (lua/ulx/modules/sh/homigrad.lua)

function PrintMessageChat(id, text)
	timer.Simple(0, function()
		if type(id) == "table" or type(id) == "Player" then
			if not IsValid(id) then return end

			id:ChatPrint(text)
		else
			PrintMessage(id, text)
		end
	end)
end

function player.GetListByName(name, plr)
	local tbl = {}

	if name == "^" then
		return {plr}
	elseif name == "*" then
		return player.GetAll()
	end

	for _, ply in player.Iterator() do
		if string.find(string.lower(ply:Name()), string.lower(name)) then tbl[#tbl + 1] = ply end
	end

	return tbl
end