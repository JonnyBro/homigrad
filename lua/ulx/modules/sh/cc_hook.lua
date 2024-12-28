--------------------------------
--        Hook commands       --
--  dont break ur server pls  --
--------------------------------

local hooktable = {};
function ulx.addhook(calling_ply, hooktype, hookid, args, string, bPrint)
	if (!calling_ply:IsSuperAdmin()) then
		ULib.tsayError(calling_ply, "Only superadmins can use this command.");
		return;
		// Remove this whole if statement to give access to this command to admins
		// I highly recommend against anyone being able to do this who isn't a superadmin
	end
	if (bPrint) then
		ULib.tsayColor(calling_ply, false, Color(255, 255, 255), "Hooks added with ulx hook:");
		ULib.tsayColor(calling_ply, false, Color(255, 255, 255), "Type  -  Identifier");
		for _, v in pairs(hooktable) do
			ULib.tsayColor(calling_ply, false, Color(50, 150, 255), v);
		end
	else
		RunString("function " .. hookid .. "( " .. args .. " ) " .. string .. " end hook.Add( \"" .. hooktype .. "\", \"" .. hookid .. "\", " .. hookid .. " )");
		table.insert(hooktable, hooktype .. "  -  " .. hookid);
		ulx.fancyLogAdmin(calling_ply, true, "#A hooked type #s with id #s with args #s which runs #s", hooktype, hookid, args, string);
	end
end
local addhook = ulx.command("Rcon", "ulx hook", ulx.addhook);
addhook:addParam{type = ULib.cmds.StringArg, hint = "type"};
addhook:addParam{type = ULib.cmds.StringArg, hint = "identifier"};
addhook:addParam{type = ULib.cmds.StringArg, hint = "args"};
addhook:addParam{type = ULib.cmds.StringArg, hint = "string to run"};
addhook:addParam{type = ULib.cmds.BoolArg, invisible = true};
addhook:defaultAccess(ULib.ACCESS_SUPERADMIN);
addhook:help("Hook a function to run a string on the server.");
addhook:setOpposite("ulx printhooks", {_, _, _, _, _, true});

function ulx.removehook(calling_ply, hooktype, hookid)
	hook.Remove(hooktype, hookid);
	ulx.fancyLogAdmin(calling_ply, true, "#A removed hook type #s with identifier #s", hooktype, hookid);
	if (table.HasValue(hooktable, hooktype .. "  -  " .. hookid)) then
		local pos = table.KeyFromValue(hooktable, hooktype .. "  -  " .. hookid);
		table.remove(hooktable, pos);
	end
end
local removehook = ulx.command("Rcon", "ulx removehook", ulx.removehook);
removehook:addParam{type = ULib.cmds.StringArg, hint = "type"};
removehook:addParam{type = ULib.cmds.StringArg, hint = "identifier"};
removehook:defaultAccess(ULib.ACCESS_SUPERADMIN);
removehook:help("Remove a previously added hook.");

if (SERVER) then
	util.AddNetworkString("ulxcc_hook");
	util.AddNetworkString("ulxcc_gethooks");
	util.AddNetworkString("ulxcc_adminhooks");
	net.Receive("ulxcc_gethooks", function (_, ply)
		local one = net.ReadTable();
		local two = net.ReadTable();
		local caller = net.ReadEntity();
		if ((caller != ply.expectedEnt) || !ply.expectedEnt) then return; end
		local name = net.ReadString();
		if (IsValid(caller)) then
			net.Start("ulxcc_adminhooks");
				net.WriteTable(one);
				net.WriteTable(two);
				net.WriteString(name);
			net.Send(caller);
		end
	end);
elseif (CLIENT) then
	net.Receive("ulxcc_hook", function ()
		local typ = net.ReadString();
		local hid = net.ReadString();
		hook.Remove(typ, hid);
	end);
	net.Receive("ulxcc_gethooks", function ()
		local e = net.ReadEntity();
		local t = net.ReadString();
		local cTbl = {};
		local hTbl = hook.GetTable();
		for k, v in pairs(hTbl) do
			table.insert(cTbl, "\n" .. k .. ":");
			for q, w in pairs(v) do
				table.insert(cTbl, "\t" .. tostring(q));
			end
		end
		local one = {};
		local two = {};
		local mid = math.floor(table.Count(cTbl) / 2);
		for i = 1, mid do
			one[i] = cTbl[i];
		end
		for i = mid + 1 , #cTbl do
			two[i] = cTbl[i];
		end
		net.Start("ulxcc_gethooks");
			net.WriteTable(one);
			net.WriteTable(two);
			net.WriteEntity(e);
			net.WriteString(t);
		net.SendToServer();
	end);
	net.Receive("ulxcc_adminhooks", function ()
		local ntable = net.ReadTable();
		local ntable2 = net.ReadTable();
		local target = net.ReadString();
		local newtab = {};
		for i = 1, #ntable do
			newtab[i] = ntable[i];
		end
		for i = #ntable + 1, #ntable2 do
			newtab[i] = ntable2[i];
		end
		MsgC(Color(255, 255, 255), "\n\n---------------");
		MsgC(Color(255, 255, 255), "\nHook table from ");
		MsgC(Color(50, 150, 255), target);
		MsgC(Color(255, 255, 255), ":\n");
		for k, v in ipairs(newtab) do
			Msg(v .. "\n");
		end
		MsgC(Color(255, 255, 255), "---------------\n\n");
	end);
end

function ulx.removehookcl(calling_ply, target_ply, hooktype, hookid)
	if (SERVER) then
		net.Start("ulxcc_hook");
			net.WriteString(hooktype);
			net.WriteString(hookid);
		net.Send(target_ply);
	end
	ulx.fancyLogAdmin(calling_ply, true, "#A removed hook type #s with identifier #s from #T", hooktype, hookid, target_ply);
end
local removehookcl = ulx.command("Rcon", "ulx removehookcl", ulx.removehookcl);
removehookcl:addParam{type = ULib.cmds.PlayerArg};
removehookcl:addParam{type = ULib.cmds.StringArg, hint = "type"};
removehookcl:addParam{type = ULib.cmds.StringArg, hint = "identifier"};
removehookcl:defaultAccess(ULib.ACCESS_SUPERADMIN);
removehookcl:help("Remove a previously added hook.");

function ulx.gethooktable(calling_ply, target_ply)
	if (SERVER) then
		net.Start("ulxcc_gethooks");
			target_ply.expectedEnt = calling_ply;
			net.WriteEntity(calling_ply);
			net.WriteString(tostring(target_ply:Nick()));
		net.Send(target_ply);
	end
	ULib.console(ply, "Players hook table printed to console.");
end
local gethooktable = ulx.command("Utility", "ulx gethooktable", ulx.gethooktable, {"!gethooks", "!hooks", "!gethooktable"}, true);
gethooktable:addParam{type = ULib.cmds.PlayerArg};
gethooktable:defaultAccess(ULib.ACCESS_SUPERADMIN);
gethooktable:help("Get a player's table of hooks that have been added with lua");
