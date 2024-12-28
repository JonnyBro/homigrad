CreateConVar("hg_pisapopa", "1", FCVAR_ARCHIVE, "pisap")

function nextbot.HUDPaint_RoundLeft(white2, time)
    local player = LocalPlayer() 
    if player:IsAdmin() and GetConVar("hg_pisapopa"):GetInt() == 1 then
        local list = SpawnPointsList.points_nextbox
        -- local list = ReadDataMap("spawnpoints_ss_exit")
        if list then
            for i, point in pairs(list[3]) do
                point = ReadPoint(point)
                local pos = point[1]:ToScreen()
                draw.SimpleText("pisapopa", "ChatFont", pos.x, pos.y, Color(0, 255, 115), TEXT_ALIGN_CENTER) 
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
