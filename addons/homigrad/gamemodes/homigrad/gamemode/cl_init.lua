include("shared.lua")

surface.CreateFont("HomigradFont", {
	font = "Roboto",
	size = 18,
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontBig", {
	font = "Roboto",
	size = 25,
	weight = 1100,
	outline = false,
	shadow = true
})

surface.CreateFont("HomigradFontLarge", {
	font = "Roboto",
	size = ScreenScale(30),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontSmall", {
	font = "Roboto",
	size = ScreenScale(10),
	weight = 1100,
	outline = false
})

net.Receive("round_active", function(len)
	roundActive = net.ReadBool()
	roundTimeStart = net.ReadFloat()
	roundTime = net.ReadFloat()
end)

local view = {}

hook.Add("PreCalcView", "spectate", function(lply, pos, ang, fov, znear, zfar)
	lply = LocalPlayer()
	if lply:Alive() or GetViewEntity() ~= lply then return end

	view.fov = CameraSetFOV

	local spec = lply:GetNWEntity("HeSpectateOn")

	if not IsValid(spec) then
		view.origin = lply:EyePos()
		view.angles = ang

		return view
	end

	spec = IsValid(spec:GetNWEntity("Ragdoll")) and spec:GetNWEntity("Ragdoll") or spec

	local dir = Vector(1, 0, 0)
	dir:Rotate(ang)

	local head = spec:LookupBone("ValveBiped.Bip01_Head1")
	local tr = {}
	tr.start = head and spec:GetBonePosition(head) or spec:EyePos()
	tr.endpos = tr.start - dir * 75
	tr.filter = {lply, spec, lply:GetVehicle()}

	view.origin = util.TraceLine(tr).HitPos
	view.angles = ang

	return view
end)

SpectateHideNick = SpectateHideNick or false
local keyOld, keyOld2
flashlight = flashlight or nil
flashlightOn = flashlightOn or false
local gradient_d = Material("vgui/gradient-d")

hook.Add("HUDPaint", "spectate", function()
	local lply = LocalPlayer()
	local spec = lply:GetNWEntity("HeSpectateOn")

	if lply:Alive() then
		if IsValid(flashlight) then
			flashlight:Remove()
			flashlight = nil
		end
	end

	local result = lply:PlayerClassEvent("CanUseSpectateHUD")
	if result == false then return end

	if (((not lply:Alive() or lply:Team() == 1002 or spec and lply:GetObserverMode() ~= OBS_MODE_NONE) or lply:GetMoveType() == MOVETYPE_NOCLIP) and not lply:InVehicle()) or result or hook.Run("CanUseSpectateHUD") then
		local ent = spec

		if IsValid(ent) then
			surface.SetFont("HomigradFont")

			local tw = surface.GetTextSize(ent:GetName())
			draw.SimpleText(ent:GetName(), "HomigradFont", ScrW() / 2 - tw / 2, ScrH() - 100, TEXT_ALING_CENTER, TEXT_ALING_CENTER)
			tw = surface.GetTextSize(language.GetPhrase("hg.spec.health"):format(ent:Health()))
			draw.SimpleText(language.GetPhrase("hg.spec.health"):format(ent:Health()), "HomigradFont", ScrW() / 2 - tw / 2, ScrH() - 75, TEXT_ALING_CENTER, TEXT_ALING_CENTER)

			local func = TableRound().HUDPaint_Spectate

			if func then
				func(ent)
			end
		end

		local key = lply:KeyDown(IN_WALK)

		if keyOld ~= key and key then
			SpectateHideNick = not SpectateHideNick
		end

		keyOld = key
		draw.SimpleText(string.format(language.GetPhrase("hg.spec.names"), string.upper(input.LookupBinding("+walk"))), "HomigradFont", 15, ScrH() - 15, showRoundInfoColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		local key = input.IsButtonDown(KEY_F)

		if not lply:Alive() and keyOld2 ~= key and key then
			flashlightOn = not flashlightOn

			if flashlightOn then
				if not IsValid(flashlight) then
					flashlight = ProjectedTexture()
					flashlight:SetTexture("effects/flashlight001")
					flashlight:SetFarZ(900)
					flashlight:SetFOV(70)
					flashlight:SetEnableShadows(false)
				end
			else
				if IsValid(flashlight) then
					flashlight:Remove()
					flashlight = nil
				end
			end
		end

		keyOld2 = key

		if flashlight then
			flashlight:SetPos(EyePos())
			flashlight:SetAngles(EyeAngles())
			flashlight:Update()
		end

		if not SpectateHideNick then
			local func = TableRound().HUDPaint_ESP

			if func then
				func()
			end

			-- ESP
			for _, v in ipairs(player.GetAll()) do
				if not v:Alive() or v == ent then continue end

				local ent = IsValid(v:GetNWEntity("Ragdoll")) and v:GetNWEntity("Ragdoll") or v
				local screenPosition = ent:GetPos():ToScreen()
				local x, y = screenPosition.x, screenPosition.y
				local teamColor = v:GetPlayerColor():ToColor()
				local distance = lply:GetPos():Distance(v:GetPos())
				local factor = 1 - math.Clamp(distance / 1024, 0, 1)
				local size = math.max(10, 32 * factor)
				local alpha = math.max(255 * factor, 80)
				local text = v:Name()

				surface.SetFont("Trebuchet18")

				local tw, th = surface.GetTextSize(text)

				surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, alpha * 0.5)
				surface.SetMaterial(gradient_d)
				surface.DrawTexturedRect(x - size / 2 - tw / 2, y - th / 2, size + tw, th)
				surface.SetTextColor(255, 255, 255, alpha)
				surface.SetTextPos(x - tw / 2, y - th / 2)
				surface.DrawText(text)

				local barWidth = math.Clamp((v:Health() / 150) * (size + tw), 0, size + tw)
				local healthcolor = v:Health() / 150 * 255

				surface.SetDrawColor(255, healthcolor, healthcolor, alpha)
				surface.DrawRect(x - barWidth / 2, y + th / 1.5, barWidth, ScreenScale(1))
			end
		end
	end
end)

hook.Add("HUDDrawTargetID", "no", function() return false end)

local laserweps = {
	["weapon_xm1014"] = true,
	["weapon_mp40"] = true,
	["weapon_m249"] = true,
	["weapon_fiveseven"] = true,
	["weapon_mk18"] = true,
	["weapon_m4a1"] = true,
	["weapon_ar15"] = true,
	["weapon_m3super"] = true,
	["weapon_mp7"] = true,
	["weapon_p220"] = true,
	["weapon_galil"] = true,
	["weapon_deagle"] = true,
	["weapon_beanbag"] = true,
	["weapon_glock"] = true,
	["weapon_glock18"] = true,
	["weapon_xm8_lmg"] = true
}

laserplayers = laserplayers or {}
local mat = Material("sprites/bluelaser1")
local mat2 = Material("Sprites/light_glow02_add_noz")

hook.Add("PostDrawOpaqueRenderables", "laser", function()
	for i, ply in pairs(laserplayers) do
		if not IsValid(ply) then
			laserplayers[i] = nil
		end

		ply.Laser = ply.Laser or false

		if IsValid(ply) and ply.Laser and not ply:GetNWInt("Otrub") and laserweps[IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or ply.curweapon] then
			local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon() or (IsValid(ply:GetNWEntity("wep")) and ply:GetNWEntity("wep"))
			if not IsValid(wep) then continue end

			local att = wep:GetAttachment(wep:LookupAttachment("muzzle"))
			if att == nil then continue end

			local pos = att.Pos
			local ang = att.Ang

			local t = {}
			t.start = pos + ang:Right() * 2 + ang:Forward() * -5 + ang:Up() * -0.5
			t.endpos = t.start + ang:Forward() * 9000
			t.filter = {ply, wep, LocalPlayer()}
			t.mask = MASK_SOLID

			local tr = util.TraceLine(t)

			cam.Start3D(EyePos(), EyeAngles())
				render.SetMaterial(mat)
				render.DrawBeam(tr.StartPos, tr.HitPos, 1, 0, 15.5, Color(255, 0, 0))

				local Size = math.random(3, 4)
				render.SetMaterial(mat2)

				local tra = util.TraceLine({
					start = tr.HitPos - (tr.HitPos - EyePos()):GetNormalized(),
					endpos = EyePos(),
					filter = {LocalPlayer(), ply, wep, ply:GetNWEntity("Ragdoll")},
					mask = MASK_SHOT
				})

				if not tra.Hit then
					render.DrawSprite(tr.HitPos, Size, Size, Color(255, 0, 0))
				end
			cam.End3D()
		end
	end
end)

local function ToggleMenu(toggle)
	if toggle then
		local w, h = ScrW(), ScrH()

		if IsValid(wepMenu) then
			wepMenu:Remove()
		end

		local lply = LocalPlayer()
		local wep = lply:GetActiveWeapon()
		if not IsValid(wep) then return end

		wepMenu = vgui.Create("DMenu")
		wepMenu:SetPos(w / 3, h / 2)
		wepMenu:MakePopup()
		wepMenu:SetKeyboardInputEnabled(false)

		if wep:GetClass() ~= "weapon_hands" then
			wepMenu:AddOption("#hg.cmenu.drop", function()
				LocalPlayer():ConCommand("say *drop")
			end)
		end

		if wep:Clip1() > 0 then
			wepMenu:AddOption("#hg.cmenu.unload", function()
				net.Start("Unload")
					net.WriteEntity(wep)
				net.SendToServer()
			end)
		end

		if laserweps[wep:GetClass()] then
			wepMenu:AddOption("#hg.cmenu.laser", function()
				local plr = LocalPlayer()

				plr.Laser = not plr.Laser

				net.Start("lasertgg")
					net.WriteBool(plr.Laser)
				net.SendToServer()

				local str = (lply.Laser and "on") or "off"

				LocalPlayer():EmitSound("items/nvg_" .. str .. ".wav", nil, nil, .5)
			end)
		end

		plyMenu = vgui.Create("DMenu")
		plyMenu:SetPos(w / 1.7, h / 2)
		plyMenu:MakePopup()
		plyMenu:SetKeyboardInputEnabled(false)

		plyMenu:AddOption("#hg.cmenu.armor", function()
			LocalPlayer():ConCommand("jmod_ez_inv")
		end)

		plyMenu:AddOption("#hg.cmenu.ammo", function()
			LocalPlayer():ConCommand("hg_ammomenu")
		end)

		local EZarmor = LocalPlayer().EZarmor

		if JMod.GetItemInSlot(EZarmor, "eyes") then
			plyMenu:AddOption("#hg.cmenu.head", function()
				LocalPlayer():ConCommand("jmod_ez_toggleeyes")
			end)
		end
	else
		if IsValid(wepMenu) then wepMenu:Remove() end
		if IsValid(plyMenu) then plyMenu:Remove() end
	end
end

local active, oldValue

hook.Add("Think", "hg_cmenu_think", function()
	active = input.IsKeyDown(KEY_C)

	if oldValue ~= active then
		oldValue = active

		if active then
			ToggleMenu(true)
		else
			ToggleMenu(false)
		end
	end
end)

net.Receive("lasertgg", function(len)
	local ply = net.ReadEntity()
	local boolen = net.ReadBool()

	if boolen then
		laserplayers[ply:EntIndex()] = ply
	else
		laserplayers[ply:EntIndex()] = nil
	end

	ply.Laser = boolen
end)

hook.Add("OnEntityCreated", "homigrad-colorragdolls", function(ent)
	if ent:IsRagdoll() then
		timer.Create("ragdollcolors-timer" .. tostring(ent), 0.1, 0, function()
			if IsValid(ent) then
				ent.playerColor = ent:GetNWVector("plycolor")
				ent.GetPlayerColor = function() return ent.playerColor end

				timer.Remove("ragdollcolors-timer" .. tostring(ent))
			end
		end)
	end
end)

net.Receive("remove_jmod_effects", function(len)
	LocalPlayer().EZvisionBlur = 0
	LocalPlayer().EZflashbanged = 0
end)

local meta = FindMetaTable("Player")

function meta:HasGodMode()
	return self:GetNWBool("HasGodMode")
end

concommand.Add("hg_getentity", function()
	local ent = LocalPlayer():GetEyeTrace().Entity
	print(ent)

	if not IsValid(ent) then return end

	print(ent:GetModel())
	print(ent:GetClass())
end)

gameevent.Listen("player_spawn")

hook.Add("player_spawn", "gg", function(data)
	local ply = Player(data.userid)

	if ply.SetHull then
		ply:SetHull(ply:GetNWVector("HullMin"), ply:GetNWVector("Hull"))
		ply:SetHullDuck(ply:GetNWVector("HullMin"), ply:GetNWVector("HullDuck"))
	end

	hook.Run("Player Spawn", ply)
end)

hook.Add("DrawDeathNotice", "no", function() return false end)