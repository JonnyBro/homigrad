afkStart = CurTime()

hook.Add("CreateMove", "afk", function(moveData)
	local ply = LocalPlayer()
	if ply:IsAdmin() then return end

	local time = CurTime()

	if moveData:GetButtons() > 0 or not ply:Alive() or pain > 200 then
		afkStart = time
	end

	if afkStart + 300 < time and ply:Alive() then
		net.Start("afk")
		net.SendToServer()
	end

	-- If the player is in spectator
	if afkStart + 420 < time and ply:Team() == 1002 then
		net.Start("afk")
		net.SendToServer()
	end
end)