CATEGORY_NAME = "Chat"
------------------------------ tgag ------------------------------
function ulx.tgag( calling_ply, target_plys, minutes, should_ungag )
	local players = player.GetAll()
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if should_ungag then
			v.ulx_tgagged = nil
			v:SetNWBool("ulx_gagged", nil)
		else
			if minutes == 0 then
				v.ulx_tgagged = 0
			else
				v.ulx_tgagged = minutes*60 + os.time()
				v:SetNWBool("ulx_gagged", v.ulx_tgagged)
			end
		end
		if SERVER then
			if should_ungag then
				v:RemovePData( "tgag" )
			else
				v:SetPData( "tgag", v.ulx_tgagged )
			end
		end
	end

	if not should_ungag then
		local time = "for #i minute(s)"
		if minutes == 0 then time = "permanently" end
		ulx.fancyLogAdmin( calling_ply, "#A tgagged #T " .. time, target_plys, minutes )
	else
		ulx.fancyLogAdmin( calling_ply, "#A untgagged #T", target_plys )
	end
end
local tgag = ulx.command( CATEGORY_NAME, "ulx tgag", ulx.tgag, "!tgag" )
tgag:addParam{ type=ULib.cmds.PlayersArg }
tgag:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
tgag:addParam{ type=ULib.cmds.BoolArg, invisible=true }
tgag:defaultAccess( ULib.ACCESS_ADMIN )
tgag:help( "Timegag target(s), disables microphone for a given time." )
tgag:setOpposite( "ulx untgag", {_, _, _, true}, "!untgag" )

if SERVER then
	function userAuthed( ply, stid, unid )
		local minutesstr = ply:GetPData( "tgag", "" )
		if minutesstr == "" then return end
		local minutes = util.StringToType( minutesstr, "int")
		if minutes == 0 or minutes > os.time() then
			ply.ulx_tgagged = minutes
			ply:SetNWBool("ulx_tgagged", ply.ulx_tgagged)
			if minutes == 0 then
				ULib.tsayColor( ply, "", Color( 255, 25, 25 ), "Notice: ", Color(151, 211, 255), "You have been permanently gagged, you will not be able to use your mic!" )
			else
				ULib.tsayColor( ply, "", Color( 255, 25, 25 ), "Notice: ", Color(151, 211, 255), "You have a timegag, you will not be able to use your mic before ", Color( 25, 255, 25 ), ""..(minutes-os.time()), Color(151, 211, 255), " minutes!" )
			end
		end
	end
	hook.Add( "PlayerAuthed", "tgagplayerauthed", userAuthed )
	
	local function tgagHook( listener, talker )
		if talker.ulx_tgagged and (talker.ulx_tgagged == 0 or talker.ulx_tgagged*60 > os.time()) then return false
		end
	end
	hook.Add( "PlayerCanHearPlayersVoice", "ULXTGag", tgagHook )
end