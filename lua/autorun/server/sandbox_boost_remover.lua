hook.Add("PlayerSpawn", "RemoveSandboxJumpBoost", function(ply)
	if (engine.ActiveGamemode() != "sandbox") then return end
	
	local PLAYER = baseclass.Get("player_sandbox")

	PLAYER.FinishMove           = nil       -- Disable boost
	PLAYER.StartMove           	= nil       -- Disable boost
	PLAYER.SlowWalkSpeed		= 100		-- How fast to move when slow-walking (+WALK)
	PLAYER.WalkSpeed			= 190		-- How fast to move when not running
	PLAYER.RunSpeed				= 320		-- How fast to move when running
	PLAYER.CrouchedWalkSpeed	= 0.4		-- Multiply move speed by this when crouching
	PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
	PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
	PLAYER.JumpPower			= 200		-- How powerful our jump should be
end)