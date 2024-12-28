local smileyMaterial = Material("materials/icon72/hand.png")
CreateClientConVar("hg_newfake", "1", true, true, "Pisapopa")
local function RemoveSmileyHooks()
    hook.Remove("HUDPaint", "DrawSmileyOnHandleft")
    hook.Remove("HUDPaint", "DrawSmileyOnHandright")
end


hook.Add("PlayerDeath", "RemoveSmileyOnPlayerDeath", function()
    RemoveSmileyHooks()
end)


net.Receive("ShowSmileyleft", function()
    smileyRagdoll = net.ReadEntity()
    if not IsValid(smileyRagdoll) then return end
end)
net.Receive("RemoveSmileyleft", function()
    smileyRagdoll = nil
    hook.Remove("HUDPaint", "DrawSmileyOnHandleft")
end)

net.Receive("ShowSmileyleft", function()
    local rag = net.ReadEntity()
    if not IsValid(rag) then return end

    hook.Add("HUDPaint", "DrawSmileyOnHandleft", function()
        if not IsValid(rag) then return end

        local ply = LocalPlayer()
        if ply:GetNWEntity("Ragdoll") ~= rag then return end

        local w, h = ScrW(), ScrH()
        local handBone = rag:LookupBone("ValveBiped.Bip01_L_Hand")
        local handPos = rag:GetBonePosition(handBone)
        local screenPos = handPos:ToScreen()

        screenPos.x = math.Clamp(screenPos.x, w / 2 - w / 4, w / 2 + w / 4)
        screenPos.y = math.Clamp(screenPos.y, h / 2 - h / 4, h / 2 + h / 4)

        surface.SetMaterial(smileyMaterial)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRectRotated(screenPos.x, screenPos.y, 64, 64, 0)
    end)
end)


net.Receive("ShowSmileyright", function()
    smileyRagdoll = net.ReadEntity()
    if not IsValid(smileyRagdoll) then return end
end)
net.Receive("RemoveSmileyright", function()
    smileyRagdoll = nil
    hook.Remove("HUDPaint", "DrawSmileyOnHandright")
end)

net.Receive("ShowSmileyright", function()
    local rag = net.ReadEntity()
    if not IsValid(rag) then return end

    hook.Add("HUDPaint", "DrawSmileyOnHandright", function()
        if not IsValid(rag) then return end

        local ply = LocalPlayer()
        if ply:GetNWEntity("Ragdoll") ~= rag then return end

        local w, h = ScrW(), ScrH()
        local handBone = rag:LookupBone("ValveBiped.Bip01_R_Hand")
        local handPos = rag:GetBonePosition(handBone)
        local screenPos = handPos:ToScreen()

        screenPos.x = math.Clamp(screenPos.x, w / 2 - w / 4, w / 2 + w / 4)
        screenPos.y = math.Clamp(screenPos.y, h / 2 - h / 4, h / 2 + h / 4)

        surface.SetMaterial(smileyMaterial)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRectRotated(screenPos.x, screenPos.y, 64, 64, 0)
    end)
end)
