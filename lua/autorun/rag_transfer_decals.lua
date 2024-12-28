local SinglePlayer = game.SinglePlayer()


if SinglePlayer && SERVER then
    
    util.AddNetworkString("ServerRagdollTransferDecals")


    hook.Add("CreateEntityRagdoll", "ServerRagdollTransferDecals", function( ent, rag )

        net.Start("ServerRagdollTransferDecals")
        net.WriteEntity(rag)
        net.WriteEntity(ent)
        net.Send(Entity(1))

    end)

end


if CLIENT then

    local function GetShouldServerRagdoll(ent)
        return IsValid(ent) && ent:GetShouldServerRagdoll() or ent:GetNWBool("IsZBaseNPC") or ent.IsVJBaseSNPC or ent.IsDrGNextbot
    end


    local mins, maxs = Vector(-50, -50, -50), Vector(50, 50, 50)
    hook.Add("EntityRemoved", "ServerRagdollTransferDecals", function( RemovedEnt )
        
        if GetShouldServerRagdoll(RemovedEnt) then
            local pos = RemovedEnt:GetPos()

            for _, ent in ipairs( ents.FindInBox(pos+mins, pos+maxs) ) do
                if ent:GetClass()=="prop_ragdoll" && !ent.DecalTransferDone && ent:GetModel() == RemovedEnt:GetModel() then
                    ent:SnatchModelInstance( RemovedEnt )
                end
            end
        end

    end)


    if SinglePlayer then

        net.Receive("ServerRagdollTransferDecals", function()

            local rag = net.ReadEntity()
            local ent = net.ReadEntity()

            if IsValid(ent) && IsValid(rag) && !rag.DecalTransferDone then
                rag:SnatchModelInstance( ent )
                rag.DecalTransferDone = true
            end
    
        end)
    
    end

end
