----------------------------------
--  This file holds Rcon tools  --
--   Be careful with these...   --
----------------------------------
function ulx.sendlua(calling_ply, target_plys, lua, bSilent)
	if (!lua || string.lower(tostring(lua)) == "lua") then
		ULib.tsayError(calling_ply, "[ERROR]: Please send a valid lua string to someone!");
		return;
	elseif (#target_plys < 1) then
		ULib.tsayError(calling_ply, "[ERROR]: Please select one or more players!");
		return;
	end
	for _, v in ipairs(target_plys) do
		v:SendLua(lua);
	end
	if (bSilent) then
		ulx.fancyLogAdmin(calling_ply, true, "#A ran lua string #s on: #T", lua, target_plys);
	else
		ulx.fancyLogAdmin(calling_ply, false, "#A ran lua string #s on: #T", lua, target_plys);
	end
end
local slua = ulx.command("Rcon", "ulx sendlua", ulx.sendlua, {"!slua", "!sendlua"}, false);
slua:addParam{type = ULib.cmds.PlayersArg};
slua:addParam{type = ULib.cmds.StringArg, hint = "chat.AddText(Color(50, 255, 50), 'Hello!')", ULib.cmds.takeRestOfLine};
slua:addParam{type = ULib.cmds.BoolArg, invisible = true};
slua:defaultAccess(ULib.ACCESS_SUPERADMIN);
slua:setOpposite("ulx ssendlua", {_, _, _, true});
slua:help("Runs a string on a client or multiple clients.");

function ulx.url(calling_ply, target_plys, openedurl, bSilent)
	openedurl = tostring(openedurl);
	if (string.find(openedurl, "porn")) then
		ULib.tsayError(calling_ply, "Nice try...", true); -- get rekt
		return;
	end
	for _, v in ipairs(target_plys) do
		v:SendLua([[gui.OpenURL( "]] .. openedurl .. [[" )]]);
	end
	if (bSilent) then
		ulx.fancyLogAdmin(calling_ply, true, "#A opened url #s on #T", openedurl, target_plys);
	else
		ulx.fancyLogAdmin(calling_ply, "#A opened url #s on #T", openedurl, target_plys);
	end
end
local url = ulx.command("Rcon", "ulx url", ulx.url, {"!url", "!sendurl", "!openurl"});
url:addParam{type = ULib.cmds.PlayersArg}
url:addParam{type = ULib.cmds.StringArg, hint = "https://wiki.facepunch.com/gmod/", ULib.cmds.takeRestOfLine};
url:addParam{type = ULib.cmds.BoolArg, invisible = true};
url:defaultAccess(ULib.ACCESS_SUPERADMIN);
url:help("Open a URL on target(s).");
url:setOpposite("ulx surl", {_, _, _, true}, "!surl");

function ulx.ccvar(calling_ply, var, val, bSilent)
	if (!var || !val || var == "" || val == "") then
		ULib.tsayError(calling_ply, "Enter a valid ConVar/Value!");
		return;
	end
	if (!ConVarExists(var)) then
		ULib.tsayError(calling_ply, "Convar \"" .. variable .. "\" does not exist!");
		return;
	end
	local sv_cheats = (GetConVar("sv_cheats") == 1)
	if (!sv_cheats) then
		if (var == "host_framerate" || "sv_cheats") then
			ULib.tsayError(calling_ply, "Cannot change ConVar \"" .. var .. "\"");
			return;
		end
		if (var == "host_timescale" && (tonumber(val) == 0 || !isnumber(tonumber(val)))) then
			ULib.tsayError(calling_ply, "You probably shouldn't do that...");
			return;
		end
	end
	if (bSilent) then
		ulx.fancyLogAdmin(calling_ply, true, "#A changed ConVar #s to value #i", var, val);
	else
		ulx.fancyLogAdmin(calling_ply, "#A changed ConVar #s to value #i", var, val);
	end
	RunConsoleCommand(var, val);
end
local ccvar = ulx.command("Rcon", "ulx convar", ulx.ccvar, {"!convar", "!var", "!ccvar", "!changeconvar"});
ccvar:addParam{type = ULib.cmds.StringArg, hint = "variable"};
ccvar:addParam{type = ULib.cmds.StringArg, hint = "value"};
ccvar:addParam{type = ULib.cmds.BoolArg, invisible = true};
ccvar:defaultAccess(ULib.ACCESS_SUPERADMIN);
ccvar:help("Change a server ConVar.");
ccvar:setOpposite("ulx sconvar", {_, _, _, true}, "!sconvar");

function ulx.runscript(calling_ply, pathname, bPrint, bSilent)
	if (!ULib.fileExists("lua/" .. pathname)) then
		ULib.tsayError(calling_ply, "File does not exist!");
		return;
	end
	local file = file.Read(pathname, "LUA");
	RunString(file);
	if (bPrint && calling_ply:IsSuperAdmin()) then
		local toprint = ULib.explode("\n", file);
		for _, line in ipairs(toprint) do
			calling_ply:PrintMessage(HUD_PRINTCONSOLE, line);
		end
		ULib.tsayColor(calling_ply, false, Color(255, 0, 0), "Script printed to console.");
	end
	if (bSilent) then
		ulx.fancyLogAdmin(calling_ply, true, "#A ran script #s", pathname);
	else
		ulx.fancyLogAdmin(calling_ply, "#A ran script #s", pathname);
	end
end
local runscript = ulx.command("Rcon", "ulx runscript", ulx.runscript);
runscript:addParam{type = ULib.cmds.StringArg, hint = "pathname"};
runscript:addParam{type = ULib.cmds.BoolArg, default = false, ULib.cmds.optional, hint = "Print script to console?"};
runscript:addParam{type = ULib.cmds.BoolArg, invisible = true};
runscript:defaultAccess(ULib.ACCESS_SUPERADMIN);
runscript:help("Run a lua script on the server.");
runscript:setOpposite("ulx srunscript", {_, _, _, true});

if (SERVER) then
	util.AddNetworkString("ULXCC_FileShare");
end
function ulx.runscriptcl(calling_ply, target_plys, pathname, bPrint, bSilent)
	if (!ULib.fileExists("lua/" .. pathname)) then
		ULib.tsayError(calling_ply, "File does not exist!");
		return;
	end
	local fileToSend = file.Read(pathname, "LUA");
	for i = 1, #target_plys do
		net.Start("ULXCC_FileShare");
			net.WriteString(fileToSend);
		net.Send(target_plys[i]);
	end
	if (bPrint && calling_ply:IsSuperAdmin()) then
		local toprint = ULib.explode("\n", fileToSend);
		for _, line in ipairs(toprint) do
			calling_ply:PrintMessage(HUD_PRINTCONSOLE, line);
		end
		ULib.tsayColor(calling_ply, false, Color(255, 0, 0), "Script printed to console.");
	end
	if (bSilent) then
		ulx.fancyLogAdmin(calling_ply, true, "#A ran script #s on #T", pathname, target_plys);
	else
		ulx.fancyLogAdmin(calling_ply, "#A ran script #s on #T", pathname, target_plys);
	end
end
local runscriptcl = ulx.command("Rcon", "ulx runscriptcl", ulx.runscriptcl);
runscriptcl:addParam{type = ULib.cmds.PlayersArg};
runscriptcl:addParam{type = ULib.cmds.StringArg, hint = "pathname"};
runscriptcl:addParam{type = ULib.cmds.BoolArg, default = false, ULib.cmds.optional, hint = "Print script to console?"};
runscriptcl:addParam{type = ULib.cmds.BoolArg, invisible = true};
runscriptcl:defaultAccess(ULib.ACCESS_SUPERADMIN);
runscriptcl:help("Run a lua script on selected target(s).");
runscriptcl:setOpposite("ulx srunscriptcl", {_, _, _, _, true});
if (CLIENT) then
	net.Receive("ULXCC_FileShare", function ()
		local runFile = net.ReadString();
		RunString(runFile);
	end);
end
