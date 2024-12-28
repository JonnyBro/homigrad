hook.Add( "InitPostEntity", "AutoTTTMapVote", function()
	if LocalPlayer():IsAdmin()~=true then return end
	CreateConVar( "mapvote_debugmode", "0", {FCVAR_ARCHIVE,FCVAR_USERINFO}, "Activate Debug Mode to receive Table Contents", 0, 1 )
	
	
	net.Start("PSY_mapvote_getGamemodeTimeLimit")
	net.SendToServer()
	
end)

