if SERVER then
	ULib.ucl.registerAccess("pointshop2 manageairdrops", ULib.ACCESS_SUPERADMIN, "Permission to modify item categories", "Pointshop 2" )
end

local function startAirdrop( calling_ply )
	Pointshop2.Airdrops.StartAirDrop( )
	ulx.fancyLogAdmin( calling_ply, true, "#A forced a Pointshop 2 Airdrop" )
end
local cmd = ulx.command( "Pointshop 2", "ps2_forceairdrop", startAirdrop, "!airdrop" )
cmd:defaultAccess( ULib.ACCESS_SUPERADMIN )
cmd:help( "Force a Pointshop 2 Airdrop" )
