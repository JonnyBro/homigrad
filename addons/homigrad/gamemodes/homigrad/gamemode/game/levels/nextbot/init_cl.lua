CreateConVar("hg_showNextbotSpawns", "0", FCVAR_ARCHIVE, "pisap")

function nextbot.HUDPaint_RoundLeft(white2, time)
	local player = LocalPlayer()

	if player:IsAdmin() and GetConVar("hg_showNextbotSpawns"):GetInt() == 1 then
		local lst = SpawnPointsList.points_nextbox

		if lst then
			for i, point in pairs(lst[3]) do
				point = ReadPoint(point)
				local pos = point[1]:ToScreen()

				draw.SimpleText("nextbot spawn", "ChatFont", pos.x, pos.y, Color(0, 255, 115), TEXT_ALIGN_CENTER)
			end
		end

		local howlers_maze = ents.FindByClass("npc_sjg_howlers_maze")
		local howlers_battle = ents.FindByClass("npc_sjg_howlers_battle")
		local all_howlers = table.Add(howlers_maze, howlers_battle)

		if all_howlers then
			halo.Add(all_howlers, Color(255, 255, 255), 1, 1, 2, true, true)
		end
	end
end