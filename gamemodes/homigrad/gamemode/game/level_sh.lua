LevelList = {}

function TableRound(name)
	return _G[(name or roundActiveName) or "homicide"]
end

timer.Simple(0, function()
	-- and not (string.find(string.lower(game.GetMap()), "rp_desert_conflict")) then
	if roundActiveName == nil then
		if GetConVar("sv_construct"):GetBool() == true then
			roundActiveName = "construct"
			roundActiveNameNext = "construct"
		else
			roundActiveName = "homicide"
			roundActiveNameNext = "homicide"
		end
	end
end)