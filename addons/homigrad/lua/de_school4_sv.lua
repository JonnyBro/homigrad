--[[
if game.GetMap() ~= "de_school4" then return end

hook.Add("Player Think", "mapsprekol", function(ply)
	if not ply:IsAdmin() and ply:Alive() and ply:Team() ~= 1002 and ply:GetPos()[3] <= -10 then
		ply:Kick("bug obuse")
	end
end)
--]]