util.AddNetworkString("sendsoundlist");
util.AddNetworkString("sendsoundgroups");
CreateConVar( "soundlist_usedefaultsounds", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_GAMEDLL } )
local soundTable = {};
local blockedGroups = {
	"blocked_groupname1",
	"blocked_groupname2"
	// Example: user, operator
	// Use only lowercase even if the group name has uppercase.
}
hook.Add("PlayerInitialSpawn", "ULXCC_SendBlockedGroups", function (ply)
	net.Start("sendsoundgroups");
		net.WriteTable(blockedGroups);
	net.Send(ply);
end);
local blacklist = {
	"sound/ambient/construct_tone.wav",
	"sound/ambient/forest_day.wav",
	"sound/ambient/forest_night.wav",
	"sound/garrysmod/balloon_pop_cute.wav",
	"sound/garrysmod/content_downloaded.wav",
	"sound/garrysmod/save_load1.wav",
	"sound/garrysmod/save_load2.wav",
	"sound/garrysmod/save_load3.wav",
	"sound/garrysmod/save_load4.wav",
	"sound/garrysmod/ui_click.wav",
	"sound/garrysmod/ui_hover.wav",
	"sound/garrysmod/ui_return.wav",
	"sound/phx/eggcrack.wav",
	"sound/phx/epicmetal_hard.wav",
	"sound/phx/epicmetal_hard1.wav",
	"sound/phx/epicmetal_hard2.wav",
	"sound/phx/epicmetal_hard3.wav",
	"sound/phx/epicmetal_hard4.wav",
	"sound/phx/epicmetal_hard5.wav",
	"sound/phx/epicmetal_hard6.wav",
	"sound/phx/epicmetal_hard7.wav",
	"sound/phx/epicmetal_soft1.wav",
	"sound/phx/epicmetal_soft2.wav",
	"sound/phx/epicmetal_soft3.wav",
	"sound/phx/epicmetal_soft4.wav",
	"sound/phx/epicmetal_soft5.wav",
	"sound/phx/epicmetal_soft6.wav",
	"sound/phx/epicmetal_soft7.wav",
	"sound/phx/explode00.wav",
	"sound/phx/explode01.wav",
	"sound/phx/explode02.wav",
	"sound/phx/explode03.wav",
	"sound/phx/explode04.wav",
	"sound/phx/explode05.wav",
	"sound/phx/explode06.wav",
	"sound/phx/hmetal1.wav",
	"sound/phx/hmetal2.wav",
	"sound/phx/hmetal3.wav",
	"sound/phx/kaboom.wav",
	"sound/sfx/skidding.wav",
	"sound/thrusters/hover00.wav",
	"sound/thrusters/hover01.wav",
	"sound/thrusters/hover02.wav",
	"sound/thrusters/jet00.wav",
	"sound/thrusters/jet01.wav",
	"sound/thrusters/jet02.wav",
	"sound/thrusters/jet03.wav",
	"sound/thrusters/jet04.wav",
	"sound/thrusters/mh1.wav",
	"sound/thrusters/mh2.wav",
	"sound/thrusters/rocket00.wav",
	"sound/thrusters/rocket01.wav",
	"sound/thrusters/rocket02.wav",
	"sound/thrusters/rocket03.wav",
	"sound/thrusters/rocket04.wav"
}

local good = {
	mp3 = 1,
	wav = 1,
	ogg = 1
}

local function FindAllIn( dir, path )
	local tab = {}
	local function ScanRecursive( dir, tab )
		local files, folder = file.Find( dir .. "/*", path )
		if folder then
			for k, v in pairs( folder ) do
				table.insert( files, v )
			end
		end
		if not files then
			files = {}
		end
		for k, x in pairs( files ) do
			local ext = string.sub( x, -3 )
			local y = dir .. "/" .. x
			if not good[ ext ] or file.IsDir( x, path ) then
				ScanRecursive( y, tab )
			elseif good[ ext ] then
				if not table.HasValue( tab, y ) then
					table.insert( tab, y )
				end
			end
		end
	end
	ScanRecursive( dir, tab )
	return tab
end

local function populateSounds()
	soundTable = {};
	local allSounds = FindAllIn("sound", "MOD");
	if (GetConVar("soundlist_usedefaultsounds"):GetInt() > 0) then
		for k, v in pairs(allSounds) do
			table.insert(soundTable, v);
		end
	else
		for k, v in pairs(allSounds) do
			if (!table.HasValue(blacklist, v)) then
				table.insert(soundTable, v);
			end
		end
	end
end

cvars.AddChangeCallback( "soundlist_usedefaultsounds", function( cvarName, oldValue, newValue )
	populateSounds();
	local send = {};
	for k, v in ipairs(player.GetAll()) do
		if (v:IsPlayer() && !table.HasValue(blockedGroups, string.lower(tostring(v:GetUserGroup())))) then
			table.insert(send, v);
		end
	end
	net.Start("sendsoundlist");
		net.WriteTable(soundTable);
	net.Send(send)
	Msg( "[CC] ConVar \"soundlist_usedefaultsounds\" changed to " .. newValue .. "\n" )
end )

net.Receive("sendsoundlist", function (_, ply)
	if (!table.HasValue(blockedGroups, string.lower(tostring(ply:GetUserGroup())))) then
		populateSounds();
		net.Start("sendsoundlist");
			net.WriteTable(soundTable);
		net.Send(ply);
	else
		ply:ChatPrint("[ERROR]: You don't have access to this command, " .. ((ply.Nick && ply:Nick()) || "Console")  .. "!");
	end
end);
