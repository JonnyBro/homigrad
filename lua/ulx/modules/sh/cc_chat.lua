-------------------------------------
--  This file holds chat commands  --
-------------------------------------
if (SERVER) then
	ULib.ucl.registerAccess("ulx seesasay", ULib.ACCESS_SUPERADMIN, "Ability to see \"ulx sasay\"", "Other");
end

ULXCCColors = {
	["white"] = Color(255, 255, 255);
	["red"] = Color(255, 0, 0);
	["maroon"] = Color(128, 0, 0);
	["blue"] = Color(0, 0, 255);
	["green"] = Color(0, 255, 0);
	["orange"] = Color(255, 127, 0);
	["purple"] = Color(51, 0, 102);
	["pink"] = Color(255, 0, 97);
	["yellow"] = Color(255, 255, 0);
	["black"] = Color(0, 0, 0);
	["gray"] = Color(96, 96, 96);
	["grey"] = Color(96, 96, 96);
};

ULXCCColorTblTxt = {};
local mov = 1;
for k, v in pairs(ULXCCColors) do
	table.insert(ULXCCColorTblTxt, mov, k);
	mov = mov + 1;
end

local notiTypesTxt = {
	"generic",
	"error",
	"hint",
	"cleanup",
	"undo",
	"progress"
};

function ulx.tsaycolor(calling_ply, message, color)
	message = tostring(message);
	color = string.lower(tostring(color));
	for k, v in pairs(ULXCCColors) do
		if (k == color) then
			ULib.tsayColor(calling_ply, false, ULXCCColors[k], message);
		end
	end
	if (GetConVar("ulx_logChat"):GetInt() > 0) then
		ulx.logString(string.format("(Tsay from %s) %s", (IsValid(calling_ply)) && ((calling_ply.Nick && calling_ply:Nick()) || "Console"), message));
	end
end
local tsaycolor = ulx.command("Chat", "ulx tsaycolor", ulx.tsaycolor, {"!tcol", "!tcolor", "!color", "!tsaycolor"}, true, true);
tsaycolor:addParam{type = ULib.cmds.StringArg, hint = "Message"};
tsaycolor:addParam{type = ULib.cmds.StringArg, hint = "Color", completes = ULXCCColorTblTxt, ULib.cmds.restrictToCompletes}; // Only allow values contained within our table
tsaycolor:defaultAccess(ULib.ACCESS_ADMIN);
tsaycolor:help("Send a colored message to everyone.");

function ulx.sasay(calling_ply, message)
	local format = "#P to superadmins: #s";
	local me = "/me ";
	if (message:sub(1, me:len()) == me) then
		format = "(SUPERADMINS) *** #P #s";
		message = message:sub(me:len() + 1);
	end
	local cansee = {};
	for k, v in ipairs(player.GetAll()) do
		if (ULib.ucl.query(v, seesasayAccess) || v == calling_ply) then
			table.insert(cansee, v);
		end
	end
	ulx.fancyLog(plys, format, calling_ply, message);
end
local sasay = ulx.command("Chat", "ulx sasay", ulx.sasay, {"$", "!sasay"}, true, true);
sasay:addParam{type = ULib.cmds.StringArg, hint = "Message", ULib.cmds.takeRestOfLine};
sasay:defaultAccess(ULib.ACCESS_SUPERADMIN);
sasay:help("Send a message to currently connected superadmins.");

function ulx.csaycolor(calling_ply, message, color)
	message = tostring(message);
	color = string.lower(tostring(color));
	for k, v in pairs(ULXCCColors) do
		if (k == color) then
			ULib.csay(calling_ply, message, ULXCCColors[k]);
		end
	end
	if (GetConVar("ulx_logChat"):GetInt() > 0) then
		ulx.logString(string.format("(Csay from %s) %s", (IsValid(calling_ply)) && ((calling_ply.Nick && calling_ply:Nick()) || "Console"), message));
	end
end
local csaycolor = ulx.command("Chat", "ulx csaycolor", ulx.csaycolor, {"!csaycolor", "!ccolor"}, true, true);
csaycolor:addParam{type = ULib.cmds.StringArg, hint = "Message"}
csaycolor:addParam{type = ULib.cmds.StringArg, hint = "Color", completes = ULXCCColorTblTxt, ULib.cmds.restrictToCompletes};
csaycolor:defaultAccess(ULib.ACCESS_ADMIN);
csaycolor:help("Send a colored, centered message to everyone.");

function ulx.notifications(calling_ply, target_plys, text, ntype, duration)
	duration = tonumber(duration);
	for _, v in ipairs(target_plys) do
		if (ntype == "progress") then
			local num = math.random();
			v:SendLua("notification.AddProgress(" .. num .. ", \"" .. text .. "\")");
			timer.Simple(duration, function ()
				v:SendLua("notification.Kill(" .. num .. ")");
			end);
		else
			ntype = "NOTIFY_" .. string.upper(ntype);
			v:SendLua("notification.AddLegacy(\"" .. text .. "\", " .. ntype .. ", " .. duration .. ")")
		end
		ULib.console(v, "Notification: " .. text);
		v:SendLua("surface.PlaySound(\"buttons/button15.wav\")");
	end
end
local notifications = ulx.command("Chat", "ulx notifications", ulx.notifications, {"!notifications", "!notify", "!noti"}, false);
notifications:addParam{type = ULib.cmds.PlayersArg};
notifications:addParam{type = ULib.cmds.StringArg, hint = "Text"};
notifications:addParam{type = ULib.cmds.StringArg, hint = "Type", completes = notiTypesTxt, ULib.cmds.restrictToCompletes};
notifications:addParam{type = ULib.cmds.NumArg, default = 5, min = 3, max = 15, hint = "duration", ULib.cmds.optional};
notifications:defaultAccess(ULib.ACCESS_ADMIN);
notifications:help("Send a sandbox-type notification to players.")
