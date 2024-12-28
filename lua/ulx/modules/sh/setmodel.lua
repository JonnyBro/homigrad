local CATEGORY_NAME = "Apple's Creations"


function ulx.setmodel( calling_ply, target_plys, model, red, green, blue )
	
	
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		
		if not v:Alive() then
		ULib.tsayError( calling_ply, v:Nick() .. " is dead", true )
		
		else
		v:SetModel(model)
		v:SetColor(Color(red, green, blue))
		table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A set #T's model to #s with colors R:#s, G:#s, B:#s", affected_plys, model, red, green, blue )
end
	
	
local setmodel = ulx.command( CATEGORY_NAME, "ulx setmodel", ulx.setmodel, "!setmodel" )
setmodel:addParam{ type=ULib.cmds.PlayersArg }
setmodel:addParam{ type=ULib.cmds.StringArg, hint="models/modelname.mdl" }
setmodel:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red", ULib.cmds.round, ULib.cmds.optional }
setmodel:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green", ULib.cmds.round, ULib.cmds.optional }
setmodel:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue", ULib.cmds.round, ULib.cmds.optional }
setmodel:defaultAccess( ULib.ACCESS_ADMIN )
setmodel:help( "Set any model to a player - !setmodel" )