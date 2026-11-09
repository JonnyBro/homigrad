local femaleModels = {}

for i = 1, 6 do
	femaleModels["models/player/group01/female_0" .. i .. ".mdl"] = true
	femaleModels["models/player/group03/female_0" .. i .. ".mdl"] = true
	femaleModels["models/monolithservers/mpd/female_0" .. i .. ".mdl"] = true
	femaleModels["models/monolithservers/mpd/female_0" .. i .. "_2.mdl"] = true
end

femaleModels["models/player/group03/police_fem.mdl"] = true

local function clearModels(ply)
	if not ply.hgArmorModels then return end

	for _, mdl in pairs(ply.hgArmorModels) do
		if IsValid(mdl) then mdl:Remove() end
	end

	ply.hgArmorModels = nil
end

net.Receive("hg_armor_sync", function()
	local ply = net.ReadEntity()
	local armor = net.ReadTable()
	if not IsValid(ply) then return end

	clearModels(ply)

	ply.hgArmor = armor
end)

local hiddenFirstPersonSlots = {"mouthnose", "eyes", "head"}

local function drawArmor(ply)
	local armor = ply.hgArmor
	if not armor or table.IsEmpty(armor.items) then return end

	local models = ply.hgArmorModels or {}
	ply.hgArmorModels = models

	local firstPerson = ply == LocalPlayer() and GetViewEntity() == ply
	local female = femaleModels[ply:GetModel()]

	for id, item in pairs(armor.items) do
		local info = hg.GetArmorInfo(item)
		if not info then continue end

		if firstPerson then
			local hidden = false

			for _, slot in ipairs(hiddenFirstPersonSlots) do
				if info.slots[slot] then
					hidden = true
					break
				end
			end

			if hidden then continue end
		end

		local mdl = models[id]

		if not IsValid(mdl) then
			mdl = ClientsideModel(info.mdl)
			mdl:SetMaterial(info.mat or "")
			mdl:SetNoDraw(true)
			models[id] = mdl
		end

		local bone = ply:LookupBone(info.bon)
		local matrix = bone and ply:GetBoneMatrix(bone)
		if not matrix then continue end

		local pos, ang = matrix:GetTranslation(), matrix:GetAngles()
		local right, forward, up = ang:Right(), ang:Forward(), ang:Up()
		local femaleOffset = (female and info.bon == "ValveBiped.Bip01_Spine2") and -3 or 0

		pos = pos + right * info.pos.x + forward * (info.pos.y + femaleOffset) + up * info.pos.z

		ang:RotateAroundAxis(right, info.ang.p)
		ang:RotateAroundAxis(up, info.ang.y)
		ang:RotateAroundAxis(forward, info.ang.r)

		mdl:SetRenderOrigin(pos)
		mdl:SetRenderAngles(ang)

		local scale = Matrix()
		scale:Scale(info.siz)
		mdl:EnableMatrix("RenderMultiply", scale)

		if info.bdg then
			for k, v in pairs(info.bdg) do
				mdl:SetBodygroup(k, v)
			end
		end

		if info.skin then mdl:SetSkin(info.skin) end

		local r, g, b = render.GetColorModulation()
		local col = item.col

		render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
		mdl:DrawModel()
		render.SetColorModulation(r, g, b)
	end
end

hook.Add("PostPlayerDraw", "hg_armor", drawArmor)

hook.Add("EntityRemoved", "hg_armor", function(ent)
	if ent:IsPlayer() then clearModels(ent) end
end)

local maskMats, breathSounds = {}, {}

hook.Add("HUDPaintBackground", "hg_armor_mask", function()
	local ply = LocalPlayer()
	local armor = ply.hgArmor
	local alive = ply:Alive()

	if armor and armor.mskmat and alive then
		local mat = maskMats[armor.mskmat]

		if not mat then
			mat = Material(armor.mskmat)
			maskMats[armor.mskmat] = mat
		end

		local col = render.GetLightColor(EyePos())

		surface.SetMaterial(mat)
		surface.SetDrawColor(col.r * 255, col.g * 255, col.b * 255, 255)

		for _ = 1, 3 do
			surface.DrawTexturedRect(-1, -1, ScrW() + 2, ScrH() + 2)
		end
	end

	local sndlop = alive and armor and armor.sndlop

	for path, snd in pairs(breathSounds) do
		if path ~= sndlop then
			snd:Stop()
			breathSounds[path] = nil
		end
	end

	if sndlop then
		local snd = breathSounds[sndlop]

		if not snd then
			snd = CreateSound(ply, sndlop)
			breathSounds[sndlop] = snd
		end

		if not snd:IsPlaying() then snd:Play() end
	end
end)

concommand.Add("hg_armor_toggleeyes", function()
	local ply = LocalPlayer()
	if not ply:Alive() then return end

	if not hg.GetArmorInSlot(ply, "eyes") then
		ply:PrintMessage(HUD_PRINTCENTER, "You are not wearing anything that covers your eyes!")

		return
	end

	net.Start("hg_armor_action")
	net.WriteUInt(2, 2)
	net.WriteString("")
	net.SendToServer()
end)

local function armorAction(action, id)
	net.Start("hg_armor_action")
	net.WriteUInt(action, 2)
	net.WriteString(id)
	net.SendToServer()

	surface.PlaySound("UI/buttonclickrelease.wav")
end

function hg.FillArmorMenu(menu)
	local armor = LocalPlayer().hgArmor

	if not armor or table.IsEmpty(armor.items) then
		menu:AddOption("#hg.cmenu.armor.none"):SetEnabled(false)

		return
	end

	for id, item in SortedPairsByMemberValue(armor.items, "name") do
		local info = hg.ArmorTable[item.name]
		local sub, opt = menu:AddSubMenu(info.PrintName or item.name)
		opt:SetIcon("icon16/shield.png")

		sub:AddOption("#hg.cmenu.armor.drop", function() armorAction(1, id) end):SetIcon("icon16/arrow_down.png")

		if info.tgl then sub:AddOption("#hg.cmenu.armor.toggle", function() armorAction(2, id) end):SetIcon("icon16/arrow_refresh.png") end
	end
end
