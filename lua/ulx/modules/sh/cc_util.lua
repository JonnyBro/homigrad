---------------------------------------------------
--  This file holds client and server utilities  --
---------------------------------------------------
// This was the most tedious rewrite I've done in my life.
CreateConVar("ulx_hide_notify_superadmins", 0);
function ulx.give(calling_ply, target_plys, ent, bSilent)
	for _, v in ipairs(target_plys) do
		if (!v:Alive()) then
			ULib.tsayError(calling_ply, v:Nick() .. " is dead!", true);
		elseif (v:IsFrozen()) then
			ULib.tsayError(calling_ply, v:Nick() .. " is frozen!", true);
		elseif (v:InVehicle()) then
			ULib.tsayError(calling_ply, v:Nick() .. " is in a vehicle.", true);
		else
			v:Give(ent);
		end
	end
	if (bSilent) then
		ulx.fancyLogAdmin(calling_ply, true, "#A gave #T #s", target_plys, ent);
	else
		ulx.fancyLogAdmin(calling_ply, "#A gave #T #s", target_plys, ent);
	end
end
local give = ulx.command("Utility", "ulx give", ulx.give, "!give");
give:addParam{type = ULib.cmds.PlayersArg};
give:addParam{type = ULib.cmds.StringArg, hint = "Weapon/Entity"};
give:addParam{type = ULib.cmds.BoolArg, invisible = true};
give:defaultAccess(ULib.ACCESS_ADMIN);
give:help("Give a player an entity");
give:setOpposite("ulx sgive", {_, _, _, true}, "!sgive", true);

function ulx.maprestart(calling_ply)
	timer.Simple(1, function ()
		game.ConsoleCommand("changelevel " .. tostring(game.GetMap()) .. "\n")
	end);
	ulx.fancyLogAdmin(calling_ply, "#A forced a mapchange");
end
local maprestart = ulx.command("Utility", "ulx maprestart", ulx.maprestart, "!maprestart");
maprestart:defaultAccess(ULib.ACCESS_SUPERADMIN);
maprestart:help("Forces a mapchange to the current map.");

function ulx.stopsounds(calling_ply)
	for _, v in ipairs(player.GetAll()) do
		v:SendLua([[RunConsoleCommand("stopsound")]]);
	end
	ulx.fancyLogAdmin(calling_ply, "#A stopped all sounds for everyone");
end
local stopsounds = ulx.command("Utility", "ulx stopsounds", ulx.stopsounds, {"!ss", "!stopsounds"});
stopsounds:defaultAccess(ULib.ACCESS_SUPERADMIN);
stopsounds:help("Stops sounds/music of everyone in the server.");

function ulx.multiban(calling_ply, target_ply, minutes, reason)
	local banned = {}
	for i = 1, #target_ply do
		local v = target_ply[i];
		if (v:IsBot()) then
			ULib.tsayError(calling_ply, "Cannot ban a bot", true);
			return;
		end
		table.insert(banned, v);
		ULib.kickban(v, minutes, reason, calling_ply);
	end
	local time = "for #i minute(s)"
	if (minutes == 0) then time = "permanently" end
	local str = "#A banned #T " .. time
	if (reason && reason != "") then str = str .. " (#s)" end
	ulx.fancyLogAdmin(calling_ply, str, banned, (minutes != 0 && minutes) || reason, reason);
end
local multiban = ulx.command("Utility", "ulx multiban", ulx.multiban);
multiban:addParam{type = ULib.cmds.PlayersArg};
multiban:addParam{type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min = 0};
multiban:addParam{type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes = ulx.common_kick_reasons};
multiban:defaultAccess(ULib.ACCESS_ADMIN);
multiban:help("Bans multiple targets.");

if (CLIENT) then
	local enabled = false;
	concommand.Add("thirdperson_toggle", function ()
		enabled = !enabled;
		if (enabled) then
			chat.AddText(Color(162, 255, 162), "Third-person mode enabled.");
		else
			chat.AddText(Color(255, 162, 162), "Third-person mode disabled.");
		end
	end);
	hook.Add("ShouldDrawLocalPlayer", "ThirdPersonDrawPlayer", function ()
		if (enabled && LocalPlayer():Alive()) then
			return true;
		end
	end);
	hook.Add("CalcView", "ThirdPersonView", function (ply, pos, ang, fov, madeByZero)
		if (enabled && IsValid(ply) && ply:Alive()) then
			if (IsValid(ply:GetActiveWeapon())) then
				ply:GetActiveWeapon().AccurateCrosshair = true;
			end
			local view = {};
			view.origin = (pos - (ang:Forward() * 70) + (ang:Right() * 20) + (ang:Up() * 5));
			view.ang = (ply:EyeAngles() + Angle(1, 1, 0));
			local TrD = {}
			TrD.start = (ply:EyePos())
			TrD.endpos = (TrD.start + (ang:Forward() * - 100) + (ang:Right() * 25) + (ang:Up() * 10));
			TrD.filter = ply;
			local trace = util.TraceLine(TrD);
			pos = trace.HitPos;
			if (trace.Fraction < 1) then
				pos = pos + trace.HitNormal * 5;
			end
			view.origin = pos;
			view.fov = fov;
			return GAMEMODE:CalcView(ply, view.origin, view.ang, view.fov);
		end
	end);
	net.Receive("ulxcc_sid_information", function ()
		local sid = net.ReadString();
		net.Start("ulxcc_steamid");
			net.WriteString(sid);
		net.SendToServer();
	end);
	net.Receive("ulxcc_steamid", function ()
		local info = net.ReadTable();
		if (info) then
			PrintTable(info);
		else
			chat.AddText(Color(255, 20, 20), "[ERROR]: Packet Corrupted.");
			return;
		end
	end);
	net.Receive("ulxcc_friends", function ()
		local friendTbl = {};
		for _, v in ipairs(player.GetHumans()) do
			if (v:GetFriendStatus() == "friend") then
				table.insert(friendTbl, v:Nick());
			end
		end
		net.Start("ulxcc_friends");
			net.WriteEntity(net.ReadEntity());
			net.WriteTable(friendTbl);
		net.SendToServer();
	end);
	net.Receive("ulxcc_sendfriends", function ()
		local tbl = net.ReadTable();
		if (istable(tbl)) then
			MsgN("Debug Info:");
			if (table.Count(tbl) == 0) then
				MsgN("This player has no friends on the active server.");
			else
				PrintTable(tbl);
			end
		end
		local tprint = "";
		if (table.Count(tbl) == 0) then
			chat.AddText(Color(20, 255, 20), "[FRIENDS]: " .. net.ReadString() .. " has no friends on this server.");
			return;
		else
			for i = 1, #tbl do
				if (#tbl == i) then
					tprint = tprint .. tbl[i];
				else
					tprint = tprint .. tbl[i] .. ", ";
				end
			end
			chat.AddText(Color(20, 255, 20), "[FRIENDS]: " .. net.ReadString() .. " is friends with: " .. tprint);
		end
	end);
	net.Receive("ulxcc_watchlist", function ()
		if (IsValid(ULXCC_WATCHLIST)) then
			ULXCC_WATCHLIST:Remove();
		end
		local tab = {};
		ULXCC_WATCHLIST = vgui.Create("DFrame");
		ULXCC_WATCHLIST:SetPos(50, 50);
		ULXCC_WATCHLIST:SetSize(700, 400);
		ULXCC_WATCHLIST:SetTitle("Watchlist");
		ULXCC_WATCHLIST:SetVisible(true);
		ULXCC_WATCHLIST:SetDraggable(true);
		ULXCC_WATCHLIST:ShowCloseButton(true);
		ULXCC_WATCHLIST:MakePopup();
		ULXCC_WATCHLIST:Center();
		local list = vgui.Create("DListView", ULXCC_WATCHLIST);
		list:SetPos(4, 27);
		list:SetSize(692, 369);
		list:SetMultiSelect(false);
		list:AddColumn("SteamID");
		list:AddColumn("Name");
		list:AddColumn("Admin");
		list:AddColumn("Reason");
		list:AddColumn("Time");
		net.Start("ulxcc_RequestFiles");
		net.SendToServer();
		net.Receive("ulxcc_RequestFilesCallback", function ()
			local name = net.ReadString();
			local toIns = net.ReadTable();
			table.insert(tab, {name:gsub("x", ":"):sub(1, -5), toIns[1], toIns[2], toIns[3], toIns[4]});
			for _, v in pairs(tab) do
				list:AddLine(v[1], v[2], v[3], v[4], v[5]);
			end
		end);
		list.OnRowRightClick = function(ULXCC_WATCHLIST, line)
			local menu = DermaMenu();
			menu:AddOption("Copy SteamID", function ()
				SetClipboardText(list:GetLine(line):GetValue(1));
				chat.AddText("SteamID Copied");
			end ):SetIcon("icon16/tag_blue_edit.png");
			menu:AddOption("Copy Name", function ()
				SetClipboardText(list:GetLine(line):GetValue(2));
				chat.AddText("Username Copied");
			end):SetIcon("icon16/user_edit.png");
			menu:AddOption("Copy Reason", function ()
				SetClipboardText(list:GetLine(line):GetValue(4));
				chat.AddText("Reason Copied");
			end):SetIcon("icon16/note_edit.png");
			menu:AddOption("Copy Time", function ()
				SetClipboardText(list:GetLine(line):GetValue(5));
				chat.AddText("Time Copied");
			end):SetIcon("icon16/clock_edit.png");
			menu:AddOption("Remove", function ()
				net.Start("RequestDeletion");
					net.WriteString(list:GetLine(line):GetValue(1));
					net.WriteString(list:GetLine(line):GetValue(2));
				net.SendToServer();
				list:Clear();
				net.Start("ulxcc_RequestFiles")
				net.SendToServer()
				net.Receive("ulxcc_RequestFilesCallback", function ()
					local name = net.ReadString();
					local toIns = net.ReadTable();
					table.insert(tab, {name:gsub("x", ":"):sub(1, -5), toIns[1], toIns[2], toIns[3], toIns[4]});
					for _, v in pairs(tab) do
						list:AddLine(v[1], v[2], v[3], v[4], v[5]);
					end
				end);
			end):SetIcon("icon16/table_row_delete.png");
			menu:AddOption("Ban by SteamID", function ()
				local Frame = vgui.Create("DFrame");
				Frame:SetSize(250, 98);
				Frame:Center();
				Frame:MakePopup();
				Frame:SetTitle("Ban by SteamID...");
				local TimeLabel = vgui.Create("DLabel", Frame);
				TimeLabel:SetPos(5, 27);
				TimeLabel:SetColor(Color(0, 0, 0, 255));
				TimeLabel:SetFont("DermaDefault");
				TimeLabel:SetText("Time:");
				local Time = vgui.Create("DTextEntry", Frame);
				Time:SetPos(47, 27);
				Time:SetSize(198, 20);
				Time:SetText("");
				local ReasonLabel = vgui.Create("DLabel", Frame);
				ReasonLabel:SetPos(5, 50);
				ReasonLabel:SetColor(Color(0, 0, 0, 255));
				ReasonLabel:SetFont("DermaDefault");
				ReasonLabel:SetText("Reason:");
				local Reason = vgui.Create("DTextEntry", Frame);
				Reason:SetPos(47, 50);
				Reason:SetSize(198, 20);
				Reason:SetText("");
				local execbutton = vgui.Create("DButton", Frame);
				execbutton:SetSize(75, 20);
				execbutton:SetPos(47, 73);
				execbutton:SetText("Ban!");
				execbutton.DoClick = function ()
					RunConsoleCommand("ulx", "banid", tostring(list:GetLine(line):GetValue(1)), Time:GetText(), Reason:GetText());
					Frame:Close();
				end
				local cancelbutton = vgui.Create("DButton", Frame);
				cancelbutton:SetSize(75, 20);
				cancelbutton:SetPos(127, 73);
				cancelbutton:SetText("Cancel");
				cancelbutton.DoClick = function (cancelbutton)
					Frame:Close();
				end
			end):SetIcon("icon16/tag_blue_delete.png");
			menu:Open();
		end
	end);
elseif (SERVER) then
	util.AddNetworkString("ulxcc_sid_information");
	util.AddNetworkString("ulxcc_steamid");
	util.AddNetworkString("ulxcc_friends");
	util.AddNetworkString("ulxcc_sendfriends");
	util.AddNetworkString("ulxcc_RequestFiles");
	util.AddNetworkString("ulxcc_RequestFilesCallback");
	util.AddNetworkString("ulxcc_RequestDeletion");
	util.AddNetworkString("ulxcc_watchlist");
	if (!file.Exists("watchlist", "DATA")) then
		file.CreateDir("watchlist");
	end
	net.Receive("ulxcc_RequestFiles", function (_, ply)
		if (ply:IsAdmin() || ply:IsUserGroup("operator")) then
			local files = file.Find("watchlist/*", "DATA");
			for _, v in pairs(files) do
				local r = file.Read("watchlist/" .. v, "DATA");
				local exp = string.Explode("\n", r);
				net.Start("ulxcc_RequestFilesCallback");
					net.WriteString(v);
					net.WriteTable(exp);
				net.Send(ply);
			end
		else
			ply.falsecalls = (ply.falsecalls || 0) + 1;
			if (ply.falsecalls >= 5) then
				ply.falsecalls = nil;
				ply:Kick("(Disconnect): ULXCC; Too many false watchlist views called.");
				return;
			end
			for _, v in ipairs(player.GetHumans()) do
				v:ChatPrint(ply:Nick() .. " attempted to view the watchlist file and was blocked! CHECK YOUR CONSOLE!");
				ULib.console(v, ply:Nick() .. " is most likely cheating (sending exploitative net messages to the server);\nRecommended Action: Ban\nContact your administrator if you believe this is a mistake.\naddons/ulxcc/lua/ulx/modules/sh/cc_util.lua at line 308");
			end
		end
	end);
	net.Receive("ulxcc_RequestDeletion", function (_, ply)
		if (ply:IsAdmin() || ply:IsUserGroup("operator")) then
			local sid = net.ReadString();
			local name = net.ReadString();
			local notiGang = {};
			if (file.Exists("watchlist/" .. sid:gsub(":", "X") .. ".txt", "DATA")) then
				file.Delete("watchlist/" .. sid:gsub(":", "X") .. ".txt");
			end
			for _, v in ipairs(player.GetHumans()) do
				if (v:IsSuperAdmin() || v == ply) then
					table.insert(notiGang, v:Nick());
				end
			end
			ulx.fancyLog({notiGang}, "(SILENT) #s removed #s (#s) from the watchlist", ply:Nick(), name, sid);
		else
			for _, v in ipairs(player.GetHumans()) do
				if (v:IsAdmin() || v:IsUserGroup("operator")) then
					v:ChatPrint(ply:Nick() .. " attempted to delete a watchlist file and was blocked! CHECK YOUR CONSOLE!");
					ULib.console(v, ply:Nick() .. " is most likely cheating (sending exploitative net messages to the server);\nRecommended Action: Ban\nContact your administrator if you believe this is a mistake.\naddons/ulxcc/lua/ulx/modules/sh/cc_util.lua at line 330");
				end
			end
			ply.falsecalls = (ply.falsecalls || 0) + 1;
			if (ply.falsecalls >= 5) then
				ply.falsecalls = nil;
				ply:Kick("(Disconnect): ULXCC; Too many false watchlist views called.");
				return;
			end
		end
	end);
	hook.Add("PlayerInitialSpawn", "WatchedPlayerCheck", function (ply)
		local files = file.Find("watchlist/*", "DATA");
		for _, v in pairs(files) do
			if (ply:SteamID() == string.sub(v:gsub("X", ":"), 1, -5)) then
				for _, w in pairs(player.GetHumans()) do
					if (w:IsAdmin() || w:IsUserGroup("operator")) then
						ULib.tsayError(w, ply:Nick() .. " (" .. ply:SteamID() .. ") has CONNECTED and is on the watchlist!");
					end
				end
			end
		end
	end);
	hook.Add("PlayerDisconnected", "WatchedPlayerCheckDC", function (ply)
		local files = file.Find("watchlist/*", "DATA");
		for _, v in pairs(files) do
			if (ply:SteamID() == string.sub(v:gsub("X", ":"), 1, -5)) then
				for _, w in ipairs(player.GetHumans()) do
					if (w:IsAdmin() || w:IsUserGroup("operator")) then
						ULib.tsayError(w, ply:Nick() .. " (" .. ply:SteamID() .. ") has DISCONNECTED and is on the watchlist!");
					end
				end
			end
		end
	end);
	hook.Add("ShutDown", "ResetTimescale", function ()
		if (game.GetTimeScale() != 1) then
			game.SetTimeScale(1);
		end
	end);
	function ulx.thirdperson(calling_ply)
		calling_ply:SendLua([[RunConsoleCommand("thirdperson_toggle")]]);
	end
	local thirdperson = ulx.command("Utility", "ulx thirdperson", ulx.thirdperson, {"!3p", "!thirdperson"}, true);
	thirdperson:defaultAccess(ULib.ACCESS_ALL);
	thirdperson:help("Toggle third person mode.");
	net.Receive("ulxcc_steamid", function (_, ply)
		if (ply:IsAdmin()) then
			local id2 = net.ReadString();
			local tbl = ULib.bans[id2];
			net.Start("ulxcc_steamid");
				net.WriteTable(tbl);
			net.Send(ply);
		end
	end);
	net.Receive("ulxcc_friends", function (_, ply)
		if (net.ReadEntity() == ply.expcall) then
			net.Start("ulxcc_sendfriends");
				net.WriteTable(net.ReadTable());
				net.WriteString(ply:Nick());
			net.Send(ply.expcall);
		end
		ply.expcall = nil;
	end);
end

function ulx.timedcmd(calling_ply, command, seconds, should_cancel)
	ulx.fancyLogAdmin(calling_ply, true, "#A has set command #s to run in #i seconds", command, seconds);
	timer.Create("runcmd_halftime", seconds / 2, 1, function ()
		ULib.tsay(calling_ply, (seconds / 2) .. " seconds left!");
	end);
	timer.Create("timedcmd", seconds, 1, function ()
		calling_ply:ConCommand(command);
		ULib.tsay(calling_ply, "Command ran successfully!");
	end);
end
local timedcmd = ulx.command("Utility", "ulx timedcmd", ulx.timedcmd, "!timedcmd", true);
timedcmd:addParam{type = ULib.cmds.StringArg, hint = "command"};
timedcmd:addParam{type = ULib.cmds.NumArg, min = 1, hint = "seconds", ULib.cmds.round};
timedcmd:addParam{type = ULib.cmds.BoolArg, invisible = true};
timedcmd:defaultAccess( ULib.ACCESS_ADMIN);
timedcmd:help("Runs the specified command after a number of seconds.");

--cancel the active timed command--
function ulx.cancelcmd(calling_ply)
	if (timer.Exists("timedcmd")) then
		timer.Remove("timedcmd");
	end
	if (timer.Exists("runcmd_halftime")) then
		timer.Remove("runcmd_halftime");
	end
	ulx.fancyLogAdmin(calling_ply, true, "#A cancelled the timed command.");
end
local cancelcmd = ulx.command("Utility", "ulx cancelcmd", ulx.cancelcmd, "!cancelcmd", true);
cancelcmd:addParam{type = ULib.cmds.BoolArg, invisible = true};
cancelcmd:defaultAccess(ULib.ACCESS_ADMIN);
cancelcmd:help("Runs the specified command after a number of seconds.");

function ulx.cleardecals(calling_ply)
	for _, v in ipairs(player.GetAll()) do
		if (IsValid(v) && v:IsPlayer()) then
			for i = 1, 3 do // Run a few times to ensure that all decals get removed.
				v:ConCommand("r_cleardecals");
			end
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A cleared decals");
end
local cleardecals = ulx.command("Utility", "ulx cleardecals", ulx.cleardecals, "!cleardecals");
cleardecals:defaultAccess(ULib.ACCESS_ADMIN);
cleardecals:help("Clear decals for all players.");

function ulx.resetmap(calling_ply)
	game.CleanUpMap();
	ulx.fancyLogAdmin(calling_ply, "#A reset the map to its original state");
end
local resetmap = ulx.command("Utility", "ulx resetmap", ulx.resetmap, "!resetmap");
resetmap:defaultAccess(ULib.ACCESS_SUPERADMIN);
resetmap:help("Resets the map to its original state.");

function ulx.bot(calling_ply, number, bKick)
	if (bKick) then
		for _, v in ipairs(player.GetBots()) do
			if (v:IsBot()) then // Just to be sure they are bots
				v:Kick("");
			end
		end
		ulx.fancyLogAdmin(calling_ply, "#A kicked all bots from the server");
	elseif (!bKick) then
		if (tonumber(number) == 0) then
			for i = 1, 6 do // Only add 6 to prevent a overflow.
				RunConsoleCommand("bot");
			end
			ulx.fancyLogAdmin(calling_ply, "#A spawned a few bots");
		elseif (tonumber(number) != 0) then
			for i = 1, number do
				RunConsoleCommand("bot");
			end
			if (number == 1) then
				ulx.fancyLogAdmin(calling_ply, "#A spawned #i bot", number);
			elseif (number > 1) then
				ulx.fancyLogAdmin(calling_ply, "#A spawned #i bots", number);
			end
		end
	end
end
local bot = ulx.command("Utility", "ulx bot", ulx.bot, "!bot");
bot:addParam{type = ULib.cmds.NumArg, default = 0, hint = "number", ULib.cmds.optional};
bot:addParam{type = ULib.cmds.BoolArg, invisible = true};
bot:defaultAccess(ULib.ACCESS_ADMIN);
bot:help("Spawn or remove bots.");
bot:setOpposite("ulx kickbots", {_, _, true}, "!kickbots");

function ulx.banip(calling_ply, minutes, ip)
	if (!ULib.isValidIP(ip)) then
		ULib.tsayError(calling_ply, "Invalid IP Address.");
		return;
	end
	for k, v in ipairs(player.GetAll()) do
		if (string.sub(tostring(v:IPAddress()), 1, string.len(tostring(v:IPAddress())) - 6) == ip) then
			ip = ip .. " (" .. tostring(v:Nick()) .. ")";
			break;
		end
	end
	RunConsoleCommand("addip", minutes, ip);
	RunConsoleCommand("writeip");
	ulx.fancyLogAdmin(calling_ply, true, "#A banned IP Address #s for #i minutes", ip, minutes);
	if (ULib.fileExists("cfg/banned_ip.cfg")) then
		ULib.execFile("cfg/banned_ip.cfg");
	end
end
local banip = ulx.command("Utility", "ulx banip", ulx.banip);
banip:addParam{type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0};
banip:addParam{type = ULib.cmds.StringArg, hint = "address"};
banip:defaultAccess(ULib.ACCESS_SUPERADMIN);
banip:help("Bans ip address.");

hook.Add("Initialize", "banips", function ()
	if (ULib.fileExists("cfg/banned_ip.cfg")) then
		ULib.execFile("cfg/banned_ip.cfg");
	end
end);

function ulx.unbanip(calling_ply, ip)
	if (!ULib.isValidIP(ip)) then
		ULib.tsayError(calling_ply, "Invalid IP Address.");
		return;
	end
	RunConsoleCommand("removeip", ip);
	RunConsoleCommand("writeip");
	ulx.fancyLogAdmin(calling_ply, true, "#A unbanned IP Address #s", ip);
end
local unbanip = ulx.command("Utility", "ulx unbanip", ulx.unbanip);
unbanip:addParam{type = ULib.cmds.StringArg, hint = "address"};
unbanip:defaultAccess(ULib.ACCESS_SUPERADMIN);
unbanip:help("Unbans ip address.");

function ulx.ip(calling_ply, target_ply)
	if (!calling_ply:IsAdmin()) then
		ULib.tsayError(calling_ply, "This command can only be used by admins or higher.");
		return;
	end
	calling_ply:SendLua([[SetClipboardText("]] .. tostring(string.sub(tostring(target_ply:IPAddress())), 1, string.len(tostring(target_ply:IPAddress()) - 6)) .. [[")]]);
	ulx.fancyLogAdmin(calling_ply, true, "#A copied the IP of #T", target_ply);
end
local ip = ulx.command("Utility", "ulx ip", ulx.ip, "!copyip", true);
ip:addParam{type = ULib.cmds.PlayerArg};
ip:defaultAccess(ULib.ACCESS_SUPERADMIN);
ip:help("Copies a player's IP address.");

function ulx.sban(calling_ply, target_ply, minutes, reason)
	if (target_ply:IsBot()) then
		ULib.tsayError(calling_ply, "You can't ban bots", true);
		return;
	end
	ULib.ban(target_ply, minutes, reason, calling_ply);
	target_ply:Kick("Disconnect: Kicked by " .. tostring(calling_ply:Nick()) .. "(" .. tostring(calling_ply:SteamID()) .. ")" .. " " .. "(" .. "Banned for " .. minutes .. " minute(s): " .. reason .. ").");
	local time = "for #i minute(s)"
	if (minutes == 0) then time = "permanently" end
	local str = "#A banned #T " .. time
	if (reason && reason != "") then str = str .. " (#s)" end
	ulx.fancyLogAdmin(calling_ply, true, str, target_ply, minutes != 0 && minutes || reason, reason);
end
local sban = ulx.command("Utility", "ulx sban", ulx.sban, "!sban");
sban:addParam{type = ULib.cmds.PlayerArg};
sban:addParam{type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min = 0};
sban:addParam{type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes = ulx.common_kick_reasons};
sban:addParam{type = ULib.cmds.BoolArg, invisible = true};
sban:defaultAccess(ULib.ACCESS_ADMIN);
sban:help("Bans target silently.");

function ulx.fakeban(calling_ply, target_ply, minutes, reason)
	local time = "for #i minute(s)"
	if (minutes == 0) then time = "permanently" end
	local str = "#A banned #T " .. time
	if (reason && reason != "") then str = str .. " (#s)" end
	ulx.fancyLogAdmin(calling_ply, str, target_ply, minutes != 0 && minutes || reason, reason);
end
local fakeban = ulx.command("Fun", "ulx fakeban", ulx.fakeban, "!fakeban", true);
fakeban:addParam{type = ULib.cmds.PlayerArg};
fakeban:addParam{type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min = 0};
fakeban:addParam{type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes = ulx.common_kick_reasons};
fakeban:defaultAccess(ULib.ACCESS_SUPERADMIN);
fakeban:help("Doesn't actually ban the target.");

function ulx.profile(calling_ply, target_ply)
	calling_ply:SendLua([[gui.OpenUrl("http://steamcommunity.com/profiles/"]] .. tostring(target_ply:SteamID64() .. [[")]]));
	ulx.fancyLogAdmin(calling_ply, true, "#A opened the profile of #T", target_ply);
end
local profile = ulx.command("Utility", "ulx profile", ulx.profile, "!profile", true);
profile:addParam{type = ULib.cmds.PlayerArg};
profile:addParam{type = ULib.cmds.BoolArg, invisible = true};
profile:defaultAccess(ULib.ACCESS_ALL);
profile:help("Opens target's profile");

function ulx.dban(calling_ply)
	calling_ply:ConCommand("xgui hide");
	calling_ply:ConCommand("menu_disconnects");
end
local dban = ulx.command("Utility", "ulx dban", ulx.dban, "!dban");
dban:defaultAccess(ULib.ACCESS_ADMIN);
dban:help("Open the disconnected players menu");

function ulx.hide(calling_ply, command)
	if (GetConVar("ulx_logecho"):GetInt() == 0) then
		ULib.tsayError(calling_ply, "ULX Logecho is already off. Your commands are already hidden!");
		ULib.tsay(calling_ply, "Executed command on you're client.");
		calling_ply:ConCommand(command);
		return;
	end
	local strexc = false;
	local newstr;
	if (string.find(command, "!")) then
		newstr = string.gsub(command, "!", "ulx ");
		strexc = true
	end
	if (!strexc && !string.find(command, "ulx")) then
		ULib.tsayError(calling_ply, "Invalid ULX Command!");
		return;
	end
	local prevecho = GetConVar("ulx_logecho"):GetInt();
	game.ConsoleCommand("ulx logecho 0\n");
	if (!strexc) then
		calling_ply:ConCommand(command);
	else
		string.gsub(newstr, "ulx ", "!");
		calling_ply:ConCommand(newstr);
	end
	timer.Simple(0.25, function ()
		game.ConsoleCommand("ulx logecho " .. tostring(prevecho) .. "\n");
	end);
	ulx.fancyLog({calling_ply}, "(HIDDEN) You ran command #s", command);
	if (GetConVar("ulx_hide_notify_superadmins"):GetInt() == 1 && IsValid(calling_ply)) then
		for _, v in ipairs(player.GetAll()) do
			if (v:IsSuperAdmin() && v != calling_ply) then
				ULib.tsayColor(v, false, Color(151, 211, 255), "(HIDDEN) ", Color(0, 255, 0), tostring(calling_ply:Nick()), Color(151, 211, 255), " ran hidden command ", Color(0, 255, 0), tostring(command));
			end
		end
	end
end
local hide = ulx.command("Utility", "ulx hide", ulx.hide, "!hide", true);
hide:addParam{type = ULib.cmds.StringArg, hint = "command", ULib.cmds.takeRestOfLine};
hide:defaultAccess(ULib.ACCESS_SUPERADMIN);
hide:help("Run a command without it displaying the log echo.");

function ulx.administrate(calling_ply, bRevoke)
	if (bRevoke) then
		calling_ply:GodDisable();
		ULib.invisible(calling_ply, false, 0);
		calling_ply:SetMoveType(MOVETYPE_WALK);
		ulx.fancyLogAdmin(calling_ply, true, "#A has stopped administrating");
	else
		calling_ply:GodEnable();
		ULib.invisible(calling_ply, true, 0);
		calling_ply:SetMoveType(MOVETYPE_NOCLIP);
		ulx.fancyLogAdmin(calling_ply, true, "#A is now administrating");
	end
end
local administrate = ulx.command("Utility", "ulx administrate", ulx.administrate, {"!admin", "!administrate"}, true);
administrate:addParam{type = ULib.cmds.BoolArg, invisible = true};
administrate:defaultAccess(ULib.ACCESS_SUPERADMIN);
administrate:help("Cloak yourself, noclip yourself, and god yourself.");
administrate:setOpposite("ulx unadministrate", {_, true}, "!unadministrate", true);

function ulx.enter(calling_ply, target_ply)
	local vehicle = calling_ply:GetEyeTrace().Entity
	if (!vehicle:IsVehicle()) then
		ULib.tsayError(calling_ply, "That isn't a vehicle!");
		return;
	end
	target_ply:EnterVehicle(vehicle);
	ulx.fancyLogAdmin(calling_ply, "#A forced #T into a vehicle", target_ply);
end
local enter = ulx.command("Utility", "ulx enter", ulx.enter, "!enter");
enter:addParam{type = ULib.cmds.PlayerArg};
enter:defaultAccess(ULib.ACCESS_ADMIN);
enter:help("Force a player into a vehicle.");

function ulx.exit(calling_ply, target_ply)
	if (!IsValid(target_ply:GetVehicle())) then
		ULib.tsayError(calling_ply, target_ply:Nick() .. " is not in a vehicle!");
		return;
	else
		target_ply:ExitVehicle();
	end
	ulx.fancyLogAdmin(calling_ply, "#A forced #T out of a vehicle", target_ply);
end
local exit = ulx.command("Utility", "ulx exit", ulx.exit, "!exit");
exit:addParam{type = ULib.cmds.PlayerArg};
exit:defaultAccess(ULib.ACCESS_ADMIN);
exit:help("Force a player out of a vehicle.");

function ulx.forcerespawn(calling_ply, target_plys)
    for _, v in pairs(target_plys) do
        if v:Team() == 1002 then
            ulx.fancyLogAdmin(calling_ply, "#A tried to respawn #T, but they are not allowed to respawn", {v})
            v:ChatPrint("Соси хуй пират")  -- отправляем сообщение игроку
            return
        end

        if v:Alive() then
            v:Kill()
        end
        
        if GetConVar("gamemode"):GetString() == "terrortown" then
            v:SpawnForRound(true)
        else
            v:Spawn()
        end
    end
    
    ulx.fancyLogAdmin(calling_ply, "#A respawned #T", target_plys)
end

local forcerespawn = ulx.command("Utility", "ulx forcerespawn", ulx.forcerespawn, {"!forcerespawn", "!frespawn"})
forcerespawn:addParam{type = ULib.cmds.PlayersArg}
forcerespawn:defaultAccess(ULib.ACCESS_ADMIN)
forcerespawn:help("Force-respawn a player.")


function ulx.serverinfo(calling_ply)
	local str = string.format("\nServer Information:\nULX version: %s\nULib version: %.2f\n", ulx.getVersion(), ULib.VERSION);
	str = str .. string.format("Gamemode: %s\nMap: %s\n", GAMEMODE.Name, tostring(game.GetMap()));
	str = str .. "Dedicated server: " .. tostring(game.IsDedicated()) .. "\n"
	str = str .. "Hostname: " .. GetConVar("hostname"):GetString() .. "\n"
	str = str .. "Server IP: " .. GetConVar("ip"):GetString() .. "\n"
	str = str .. string.format("----------\nCurrently connected players:\nNick%s steamid%s uid%s id lsh\n", str.rep(" ", 27), str.rep(" ", 11), str.rep(" ", 7));
	for _, v in ipairs(player.GetAll()) do
		local id = string.format("%i", v:EntIndex());
		local sid = tostring(v:SteamID());
		local uid = tostring(v:UniqueID());
		local vLine = tostring(v:Nick()) .. str.rep(" ", 32 - v:Nick():len());
		vLine = vLine .. sid .. str.rep(" ", 19 - sid:len());
		vLine = vLine .. uid .. str.rep(" ", 11 - uid:len());
		vLine = vLine .. id .. str.rep(" ", 3 - id:len());
		if (v:IsListenServerHost()) then
			vLine = vLine .. "y		";
		else
			vLine = vLine .. "n		";
		end
		str = str .. vLine .. "\n";
	end
	local gmoddefault = util.KeyValuesToTable(ULib.fileRead("settings/users.txt"));
	str = str .. "\n----------\nUsergroup Information:\nULib.ucl.users (Users: " .. table.Count(ULib.ucl.users) .. "):\n" .. ulx.dumpTable(ULib.ucl.users, 1) .. "\n"
	str = str .. "ULib.ucl.authed (Players: " .. table.Count(ULib.ucl.authed) .. "):\n" .. ulx.dumpTable(ULib.ucl.authed, 1) .. "\n"
	str = str .. "Garrysmod default file (Groups:" .. table.Count(gmoddefault) .. "):\n" .. ulx.dumpTable(gmoddefault, 1) .. "\n----------\n"
	str = str .. "Addons on this server:\n"
	local _, possibleaddons = file.Find("addons/*", "GAME");
	for _, addon in ipairs(possibleaddons) do
		if (ULib.fileExists("addons/" .. addon .. "/addon.txt")) then
			local t = util.KeyValuesToTable(ULib.fileRead("addons/" .. addon .. "/addon.txt"));
				if (tonumber(t.version)) then
					t.version = string.format("%g", t.version);
				end
			str = str .. string.format("%s%s by %s, version %s (%s)\n", addon, str.rep(" ", 24 - addon:len()), t.author_name, t.version, t.up_date);
		end
	end
	local f = ULib.fileRead("workshop.vdf");
	if (f) then
		local addons = ULib.parseKeyValues(ULib.stripComments(f, "//"));
		addons = addons.addons
		if (table.Count(addons) > 0) then
			str = str .. string.format("\nPlus %i workshop addon(s):\n", table.Count(addons));
			PrintTable(addons)
			for _, addon in pairs(addons) do
				str = str .. string.format("Addon ID: %s\n", addon);
			end
		end
	end
	ULib.tsay(calling_ply, "Server information printed to console.");
	local lines = ULib.explode("\n", str);
	for _, line in ipairs(lines) do
		ULib.console(calling_ply, line);
	end
end
local serverinfo = ulx.command("Utility", "ulx serverinfo", ulx.serverinfo, {"!serverinfo", "!info", "!status"});
serverinfo:defaultAccess(ULib.ACCESS_ADMIN);
serverinfo:help("Print server information.");

function ulx.timescale(calling_ply, number, bReset)
	number = tonumber(number);
	if (bReset) then
		game.SetTimeScale(1);
		ulx.fancyLogAdmin(calling_ply, "#A reset the game's timescale");
	else
		if (number <= 0.1) then
			ULib.tsayError(calling_ply, "You can't set the timescale of the server this low, doing so will cause instability.");
			return;
		end
		if (number >= 5) then
			ULib.tsayError(calling_ply, "You can't set the timescale of the server this high, doing so will cause instability.");
			return;
		end
		game.SetTimeScale(number);
		ulx.fancyLogAdmin(calling_ply, "#A set the game timescale to #i", tostring(number));
	end
end
local timescale = ulx.command("Utility", "ulx timescale", ulx.timescale, "!timescale");
timescale:addParam{type = ULib.cmds.NumArg, default = 1, hint = "multiplier"};
timescale:addParam{type = ULib.cmds.BoolArg, invisible = true};
timescale:defaultAccess(ULib.ACCESS_SUPERADMIN);
timescale:help("Set the server timescale.");
timescale:setOpposite("ulx resettimescale", {_, _, true});

function ulx.removeragdolls(calling_ply)
	for _, v in ipairs(player.GetAll()) do
		if (IsValid(v) && !v:IsBot()) then
			v:SendLua([[game.RemoveRagdolls()]]);
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A removed ragdolls");
end
local removeragdolls = ulx.command("Utility", "ulx removeragdolls", ulx.removeragdolls, "!removeragdolls");
removeragdolls:defaultAccess(ULib.ACCESS_ADMIN);
removeragdolls:help("Remove all ragdolls.");

function ulx.bancheck(calling_ply, sid)
	if (!ULib.isValidSteamID(sid) && !ULib.isValidIP(sid)) then
		ULib.tsayError(calling_ply, "Invalid String.");
		return;
	end
	if (ULib.isValidIP(sid)) then
		local file = file.Read("cfg/baned_ip.cfg", "GAME");
		if (string.find(file, sid)) then
			ulx.fancyLog({calling_ply}, "IP Address #s is banned!", sid);
		else
			ulx.fancyLog({calling_ply}, "IP Address #s is not banned!", sid);
		end
		return;
	elseif (ULib.isValidSteamID(sid)) then
		if (IsValid(calling_ply)) then
			if (ULib.bans[sid]) then
				ulx.fancyLog({calling_ply}, "SteamID #s is banned! Information printed to console.", sid);
				if (SERVER) then
					net.Start("ulxcc_sid_information");
						net.WriteString(tostring(sid));
					net.Send(calling_ply);
				end
			else
				ulx.fancyLog({calling_ply}, "SteamID #s is not banned!", sid);
			end
		else
			if (ULib.bans[sid]) then
				PrintTable(ULib.bans[sid]);
			else
				Msg("SteamID " .. tostring(sid) .. " is not banned!");
			end
		end
	end
end
local bancheck = ulx.command("Utility", "ulx bancheck", ulx.bancheck, "!bancheck");
bancheck:addParam{type = ULib.cmds.StringArg, hint = "string"};
bancheck:defaultAccess(ULib.ACCESS_ADMIN);
bancheck:help("Checks if a steamid or ip address is banned.");

function ulx.friends(calling_ply, target_ply)
	net.Start("ulxcc_friends");
		net.WriteEntity(calling_ply);
		target_ply.expcall = calling_ply;
	net.Send(target_ply);
end
local friends = ulx.command("Utility", "ulx friends", ulx.friends, {"!friends", "!friend", "!listfriends"}, true);
friends:addParam{type = ULib.cmds.PlayerArg};
friends:defaultAccess(ULib.ACCESS_ADMIN);
friends:help("Print a player's connected steam friends.");

function ulx.watch(calling_ply, target_ply, reason, bUnwatch)
	local id = string.gsub(target_ply:SteamID(), ":", "X");
	if (!bUnwatch) then
		if (file.Exists("watchlist/" .. id .. ".txt", "DATA")) then
			file.Delete("watchlist/" .. id .. ".txt");
			file.Write("watchlist/" .. id .. ".txt", "");
		else
			file.Write("watchlist/" .. id .. ".txt", "");
		end
		file.Append("watchlist/" .. id .. ".txt", target_ply:Nick() .. "\n");
		file.Append("watchlist/" .. id .. ".txt", calling_ply:Nick() .. "\n");
		file.Append("watchlist/" .. id .. ".txt", string.Trim(reason) .. "\n");
		file.Append("watchlist/" .. id .. ".txt", os.date("%m/%d/%y %H:%M") .. "\n");
		ulx.fancyLogAdmin(calling_ply, true, "#A added #T to the watchlist (#s)", target_ply, reason);
	else
		if (file.Exists("watchlist/" .. id .. ".txt", "DATA")) then
			file.Delete("watchlist/" .. id .. ".txt");
			ulx.fancyLogAdmin(calling_ply, true, "#A removed #T from the watchlist", target_ply);
		else
			ULib.tsayError(calling_ply, target_ply:Nick() .. " is not on the watchlist.");
		end
	end
end
local watch = ulx.command("Utility", "ulx watch", ulx.watch, "!watch", true);
watch:addParam{type = ULib.cmds.PlayerArg};
watch:addParam{type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine};
watch:addParam{type = ULib.cmds.BoolArg, invisible = true};
watch:defaultAccess(ULib.ACCESS_ADMIN);
watch:help("Watch or unwatch a player");
watch:setOpposite("ulx unwatch", {_, _, false, true}, "!unwatch", true);

function ulx.watchlist(calling_ply)
	if (IsValid(calling_ply) && SERVER) then
		net.Start("ulxcc_watchlist");
		net.Send(calling_ply);
	end
end
local watchlist = ulx.command("Utility", "ulx watchlist", ulx.watchlist, "!watchlist", true);
watchlist:defaultAccess(ULib.ACCESS_ADMIN);
watchlist:help("View the watchlist");
// Zero if you don't stop using semicolin's I'm going to fucking kill you - Kam
