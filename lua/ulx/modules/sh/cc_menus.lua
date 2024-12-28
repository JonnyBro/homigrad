------------------------------------------
--  This file holds menu related items  --
------------------------------------------

function ulx.donate(calling_ply)
	calling_ply:SendLua([[gui.OpenURL( "]] .. GetConVar("donate_url"):GetString() .. [[" )]]);
end
local donate = ulx.command("Menus", "ulx donate", ulx.donate, "!donate");
donate:defaultAccess(ULib.ACCESS_ALL);
donate:help("View donation information.");

function ulx.soundlist(calling_ply)
	calling_ply:ConCommand("menu_sounds");
end
local soundlist = ulx.command("Menus", "ulx soundlist", ulx.soundlist, {"!sounds", "!soundlist", "!listsounds"});
soundlist:defaultAccess(ULib.ACCESS_ALL);
soundlist:help("Open the sound list.");
