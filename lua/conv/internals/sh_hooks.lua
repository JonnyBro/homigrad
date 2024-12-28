// INTERNAL, DO NOT USE


hook.Add("InitPostEntity", "CONV", function()

    conv._SpawnMenuNPCs = list.Get("NPC")

    if ZBaseInstalled then
        table.Merge(conv._SpawnMenuNPCs, table.Copy(ZBaseNPCs))
    end

    -- Backwards compatability
    ents._SpawnMenuNPCs = conv._SpawnMenuNPCs

end)



if CLIENT then

    hook.Add("PopulateToolMenu", "CONV", function()
        if istable(conv.toolMenuFuncs) then
            for k, v in pairs(conv.toolMenuFuncs) do
                spawnmenu.AddToolMenuOption(v.tab, v.cat, v.name, v.name, "", "", v.func)
            end
        end
    end)

end