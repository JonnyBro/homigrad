if engine.ActiveGamemode() ~= "homigrad" then return end

-- ADMIN

-- forceteam
local AllTeams = team.GetAllTeams()

function ulx.hg_forceteam(ply, targets, arg)
	for i, v in pairs(AllTeams) do
		if v.Name == arg then
			arg = tonumber(i)
		end
	end

	for _, v in pairs(targets) do
		v:SetTeam(arg)
	end

	ulx.fancyLogAdmin(ply, "#A set team for #T to #s", targets, team.GetName(arg))
end

local forceteam = ulx.command("Homigrad", "ulx forceteam", ulx.hg_forceteam, "!forceteam")
forceteam:addParam({
	type = ULib.cmds.PlayersArg
})
forceteam:addParam({
	type = ULib.cmds.StringArg,
	completes = {"Join Game", "Spectator"},
	hint = "Team Name",
	error = "Invalid Team Name specified",
	ULib.cmds.restrictToCompletes
})
forceteam:defaultAccess(ULib.ACCESS_ADMIN)
forceteam:help("Sets player(s) team.")

-- fake
function ulx.hg_fake(ply, targets)
	for _, v in pairs(targets) do
		Faking(v)
	end

	ulx.fancyLogAdmin(ply, "#A faked #T", targets)
end

local fake = ulx.command("Homigrad", "ulx fake", ulx.hg_fake, "!fake")
fake:addParam({
	type = ULib.cmds.PlayersArg
})
fake:defaultAccess(ULib.ACCESS_ADMIN)
fake:help("Toggles 'fake' for a given player(s).")

-- SUPERADMIN

-- spawnpoints
function ulx.hg_spawnpoints(ply)
	for _, v in pairs(SpawnPointsList) do
		print(v[1])
	end

	ply:ChatPrint("[JHG] Printed all spawnpoints to console.")
end

local spawnpoints = ulx.command("Homigrad", "ulx spawnpoints", ulx.hg_spawnpoints, "!spawnpoints")
spawnpoints:defaultAccess(ULib.ACCESS_SUPERADMIN)
spawnpoints:help("Prints all spawnpoints saved")

-- guilt
function ulx.hg_guilt(ply, targets, arg)
	arg = tobool(arg)

	for _, v in pairs(targets) do
		v.noguilt = not arg
	end

	if arg then ulx.fancyLogAdmin(ply, "#A enabled guilt system for #T", targets)
	else ulx.fancyLogAdmin(ply, "#A disabled guilt system for #T", targets) end
end

local guilt = ulx.command("Homigrad", "ulx guilt", ulx.hg_guilt, "!guilt")
guilt:addParam({
	type = ULib.cmds.PlayersArg
})
guilt:addParam({
	type = ULib.cmds.BoolArg,
	hint = "Enable or disable the guilt system"
})
guilt:defaultAccess(ULib.ACCESS_SUPERADMIN)
guilt:help("Toggles guilt system for a given player(s). (currently does nothing)")