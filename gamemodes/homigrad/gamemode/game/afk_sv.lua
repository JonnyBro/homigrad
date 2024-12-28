util.AddNetworkString("afk")

net.Receive("afk",function(len,ply)
	ply:SetTeam(1002)
	--ply:Kick("Засиделся")
end)