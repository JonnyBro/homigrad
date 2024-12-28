CATEGORY_NAME = "Chat"
------------------------------ tmute ------------------------------
function ulx.tmute( calling_ply, target_plys, minutes, should_unmute )
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if should_unmute then
			v.tmute = nil
		else
			if minutes == 0 then
				v.tmute = 0
			else
				v.tmute = minutes*60 + os.time()
			end
		end
		--v:SetNWBool("ulx_tmuted", minutes)
		if SERVER then
			if should_unmute then
				v:RemovePData( "tmute" )
			else
				v:SetPData( "tmute", v.tmute )
			end
		end
	end

	if not should_unmute then
		local time = "for #i minute(s)"
		if minutes == 0 then time = "permanently" end
		ulx.fancyLogAdmin( calling_ply, "#A tmuted #T " .. time, target_plys, minutes )
	else
		ulx.fancyLogAdmin( calling_ply, "#A untmuted #T", target_plys )
	end
end
local tmute = ulx.command( CATEGORY_NAME, "ulx tmute", ulx.tmute, "!tmute" )
tmute:addParam{ type=ULib.cmds.PlayersArg }
tmute:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
tmute:addParam{ type=ULib.cmds.BoolArg, invisible=true }
tmute:defaultAccess( ULib.ACCESS_ADMIN )
tmute:help( "Mutes target(s) so they are unable to chat for a given amount of time." )
tmute:setOpposite( "ulx untmute", {_, _, _, true}, "!untmute" )

if SERVER then
	function userAuthed( ply, stid, unid )
		local minutesstr = ply:GetPData( "tmute", "" )
		if minutesstr == "" then return end
		local minutes = util.StringToType( minutesstr, "int")
		if minutes == 0 or minutes > os.time() then
			ply.tmute = minutes
			ply:SetNWBool("ulx_muted", ply.ulx_tmuted)
			if minutes == 0 then
				ULib.tsayColor( ply, "", Color( 255, 25, 25 ), "Notice: ", Color(151, 211, 255), "You have been permanently muted, you will not be able to use your chat!" )
			else
				ULib.tsayColor( ply, "", Color( 255, 25, 25 ), "Notice: ", Color(151, 211, 255), "You have a timemute, you will not be able to chat before ", Color( 25, 255, 25 ), ""..(minutes-os.time()), Color(151, 211, 255), " minutes!" )
			end
		end
	end
	hook.Add( "PlayerAuthed", "tmuteplayerauthed", userAuthed )
	
	local function tmuteCheck( ply, strText )
		if ply.tmute and (ply.tmute == 0 or ply.tmute > os.time()) then print("MUTED") return "" end
	end
	hook.Add( "PlayerSay", "ULXTMuteCheck", tmuteCheck ) -- Very low priority
end