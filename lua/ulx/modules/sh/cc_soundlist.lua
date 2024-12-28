function ulx.soundlist(calling_ply)
	if (IsValid(calling_ply)) then
		calling_ply:ConCommand("xgui hide");
		calling_ply:ConCommand("menu_sounds");
	end
end
local soundlist = ulx.command("Fun", "ulx soundlist", ulx.soundlist, {"!soundlist", "!sounds", "!sound"});
soundlist:defaultAccess(ULib.ACCESS_ALL);
soundlist:help("Open the server soundlist");
