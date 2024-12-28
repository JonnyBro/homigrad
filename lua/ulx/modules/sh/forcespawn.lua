local CATEGORY_NAME = "Apple's Creations"

// Forces a player to respawn
function ulx.respawn( calling_ply, target_plys, forcespawn )

	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		v:Spawn()
		table.insert( affected_plys, v )
	end
	ulx.fancyLogAdmin( calling_ply, "#A have force spawned #T", affected_plys )
end
local respawn = ulx.command( CATEGORY_NAME, "ulx respawn", ulx.respawn, "!respawn" )
respawn:addParam{ type=ULib.cmds.PlayersArg }
respawn:defaultAccess( ULib.ACCESS_ADMIN )
respawn:help( "Forces a player to respawn - !respawn" )