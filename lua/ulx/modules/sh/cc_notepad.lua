function ulx.notepad( calling_ply )
	if (IsValid(calling_ply)) then
		calling_ply:ConCommand("xgui hide");
		calling_ply:ConCommand("notepad_open");
	end
end
local notepad = ulx.command("Fun", "ulx notepad", ulx.notepad, {"!notepad", "!notes", "!note"});
notepad:defaultAccess(ULib.ACCESS_ADMIN);
notepad:help("Open the admin note");
