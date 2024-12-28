local ENT = FindMetaTable("Entity")


--[[
==================================================================================================
                    NPC SPAWNING
==================================================================================================
--]]


-- Spawn a NPC from the spawn menu
function conv.createSpawnMenuNPC( SpawnMenuClass, pos, wep )


    -- Find NPC in spawn menu
    local SpawnMenuTable = ents._SpawnMenuNPCs[SpawnMenuClass]


    -- Check if zbase npc
    local zbasetable
    if ZBaseInstalled then
        zbasetable = ZBaseNPCs[SpawnMenuClass]
    end
    local isZBaseNPC = false
    if istable(zbasetable) then
        SpawnMenuTable = zbasetable
        isZBaseNPC = true
    end


    -- No such NPC
    if !SpawnMenuTable then
        ErrorNoHaltWithStack("No such NPC found: '", SpawnMenuClass, "'\n")
        return
    end


    -- Is ZBase NPC, do ZBase NPC spawn
    if isZBaseNPC then

        -- Stop here
        wep = wep or "default"
        return ZBaseSpawnZBaseNPC( SpawnMenuClass, pos, nil, wep)

    end


    -- Create NPC
    local NPC = ents.Create( SpawnMenuTable.Class )


    -- No such NPC
    if !IsValid(NPC) then
        ErrorNoHaltWithStack("No such NPC found: '", SpawnMenuTable.Class, "'\n")
        return
    end


    -- Position
    if isvector(pos) then
        NPC:SetPos(pos)
    end


    -- Default weapons if none if provided
    wep = wep or (SpawnMenuTable.Weapons && table.Random(SpawnMenuTable.Weapons))
    if isstring(wep) then
        NPC:Give( wep )
    end


    -- Key values
    if SpawnMenuTable.KeyValues then

        for key, value in pairs(SpawnMenuTable.KeyValues) do
            NPC:SetKeyValue(key, value)
        end

    end


    -- Set stuff
    if SpawnMenuTable.Model then NPC:SetModel(SpawnMenuTable.Model) end
    if SpawnMenuTable.Skin then NPC:SetSkin(SpawnMenuTable.Skin) end
    if SpawnMenuTable.Health then NPC:SetMaxHealth(SpawnMenuTable.Health) NPC:SetHealth(SpawnMenuTable.Health) end
    if SpawnMenuTable.Material then NPC:SetMaterial(SpawnMenuTable.Material) end
    if SpawnMenuTable.SpawnFlags then NPC:SetKeyValue("spawnflags", SpawnMenuTable.SpawnFlags) end


    -- Spawn and Activate
    NPC:Spawn()
    NPC:Activate()


    return NPC


end


-- Spawns an entity for a short duration allowing you to obtain info about it
function conv.getEntInfo( cls, func )

    local ent = ents.Create(cls)
    if !IsValid(ent) then
        ErrorNoHaltWithStack("No such ENT found: '", cls, "'\n")
        return
    end


    ent:Spawn()
    ent:Activate()


    conv.callNextTick(function( Ent )
        func(Ent)
        Ent:Remove()
    end, ent)

end