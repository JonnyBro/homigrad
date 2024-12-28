hook.Add("PlayerAuthed", "AutoRunCommands", function(ply, steamID, uniqueID)
    -- Пример команд, которые будут выполнены при входе игрока
    ply:SendLua([[
        RunConsoleCommand("alternate_sprint_anim", "0")    
    ]])
end)