util.AddNetworkString("afk")

isAboveThreshold = #player.GetAll() / game.MaxPlayers() >= 0.75

net.Receive("afk", function(len, ply)
	if isAboveThreshold then
		ply:KillSilent()
		ply:Kick("[AUTOMATED] You've been kicked for being AFK too long! Other's want to play, yknow?")
	elseif not isAboveThreshold then
		ply:KillSilent()
		ply:SetTeam(1002)
	end
end)