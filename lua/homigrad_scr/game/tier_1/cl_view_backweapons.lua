PickTable = {}
PickLerp = {}

--[[
hook.Add("HUDWeaponPickedUp", "WeaponPickedUp", function(weapon)
	table.insert(PickTable, weapon:GetPrintName())
	--PrintTable(PickTable)
	timer.Simple(5, function()
		table.remove(PickTable, 1)
		table.remove(PickLerp, 1)
	end)
end)

hook.Add("HUDItemPickedUp", "ItemPickedUp", function(itemName)
	table.insert(PickTable, "#" .. itemName)
	--PrintTable(PickTable)
	timer.Simple(5, function()
		table.remove(PickTable, 1)
		table.remove(PickLerp, 1)
	end)
end)

hook.Add("HUDAmmoPickedUp", "AmmoPickedUp", function(ammo, ammout)
	table.insert(PickTable, ammo .. " - " .. ammout)
	-- PrintTable(PickTable)
	timer.Simple(5, function()
		table.remove(PickTable, 1)
		table.remove(PickLerp, 1)
	end)
end)

function GAMEMODE:HUDDrawPickupHistory()
	for i = 1, table.Count(PickTable) do
		if PickTable[i] then
			PickLerp[i] = Lerp(5 * FrameTime(), PickLerp[i] or 0, (i - 1) * 20)
			draw.DrawText("+ " .. PickTable[i], "HomigradFontBig", ScrW() - 5, ScrH() / 3 + PickLerp[i], color_white, TEXT_ALIGN_RIGHT)
		end
	end
end --]]

local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
local RifleOffset = Vector(-8, -4, -2)
local RifleAng = Angle(0, 0, -20)
local PistolOffset = Vector(8, -9, -8)
local PistolAng = Angle(-80, 0, 0)
local Offset, Ang = Vector(0, 0, 0), Angle(0, 0, 0)

local hg_vbw_draw = CreateClientConVar("hg_vbw_draw", "1", true, false)
local hg_vbw_dis = CreateClientConVar("hg_vbw_dis", "2000", true, false)

local femaleMdl = {}

for i = 1, 6 do
	femaleMdl["models/player/group01/female_0" .. i .. ".mdl"] = true
end

for i = 1, 6 do
	femaleMdl["models/player/group03/female_0" .. i .. ".mdl"] = true
end

--[[
for count = 0, LocalPlayer():GetBoneCount() - 1 do
	print(LocalPlayer():GetBoneName(count))
end --]]

deadBodies = deadBodies or {}

net.Receive("send_deadbodies", function(len) deadBodies = net.ReadTable() end)

-- Original comment stated that this is called 2 times for some reason (and this behavior is not tied to RenderScene)
hook.Add("PostDrawOpaqueRenderables", "draw_weapons", function()
	if not hg_vbw_draw:GetBool() then return end

	render.SetColorMaterial()

	local lply = LocalPlayer()
	local firstPerson = DRAWMODEL
	local gameVBWHide = TableRound().VBWHide
	local worldModel = VBWModel

	if not IsValid(worldModel) then
		worldModel = ClientsideModel("models/hunter/plates/plate.mdl", RENDER_GROUP_OPAQUE_ENTITY)
		VBWModel = worldModel
	end

	worldModel:SetNoDraw(true)

	local cameraPos = EyePos()
	local dis = hg_vbw_dis:GetInt()
	local tbl = homigrad_weapons

	for i = 1, #tbl do
		local wep = tbl[i]
		if not IsValid(wep) then continue end

		local ply = wep:GetParent()
		if not IsValid(ply) then continue end

		ply = IsValid(ply:GetNWEntity("RagdollOwner")) and ply:GetNWEntity("RagdollOwner") or ply
		if not IsValid(ply) then return end

		local rag = ply:GetNWEntity("Ragdoll")
		local ent = IsValid(rag) and rag or ply
		if lply == ply and not firstPerson then continue end

		local activeWep = IsValid(ply:GetNWEntity("ActiveWeapon")) and ply:GetNWEntity("ActiveWeapon") or ply.GetActiveWeapon and ply:GetActiveWeapon()
		if cameraPos:Distance(ent:GetPos()) > dis then continue end
		if activeWep == wep then continue end
		-- print(gameVBWHide(ply, wep))
		-- if gameVBWHide and gameVBWHide(ply, wep) or (GetConVar("hg_ConstructOnly") and GetConVar("hg_ConstructOnly"):GetBool() or true) ~= true then continue end
		if gameVBWHide and gameVBWHide(ply, wep) then continue end

		local matrix = ent:LookupBone("ValveBiped.Bip01_Spine1")
		matrix = matrix and ent:GetBoneMatrix(matrix)
		if not matrix then continue end

		local spinePos, spineAng = matrix:GetTranslation(), matrix:GetAngles()
		matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Pelvis"))

		local pelvisPos, pelvisAng = matrix:GetTranslation(), matrix:GetAngles()
		local mdl = ply:GetModel()

		local sUp, sRight, sForward = spineAng:Up(), spineAng:Right(), spineAng:Forward()
		local pUp, pRight, pForward = pelvisAng:Up(), pelvisAng:Right(), pelvisAng:Forward()
		local active = activeWep ~= wep:GetClass() and wep.vbw
		wep.vbwActive = active
		if not active then continue end

		local localPos, localAng, pistol
		local func = wep.vbwFunc
		local clone

		if func then
			localPos, localAng, pistol = func(wep, ply, mdl)
			Offset:Set(pelvisPos)
			Ang:Set(pelvisAng)
			clone = Vector(localPos[1], localPos[2], localPos[3])
			clone:Rotate(Ang)
			Ang:RotateAroundAxis(pUp, localAng[1])
			Ang:RotateAroundAxis(pRight, localAng[2])
			Ang:RotateAroundAxis(pForward, localAng[3])
		else
			pistol = not wep.vbwRifle and (wep.vbwPistol or not wep.TwoHands)
			if pistol then
				--[[
				if isFamale then
					localPos = wep.vbwPosF or wep.vbwPos or PistolOffsetF
					localAng = wep.vbwAngF or wep.vbwAng or PistolAngF
				else --]]

				localPos = wep.vbwPos or PistolOffset
				localAng = wep.vbwAng or PistolAng
				-- end

				Offset:Set(pelvisPos)
				Ang:Set(pelvisAng)

				clone = Vector(localPos[1], localPos[2], localPos[3])
				clone:Rotate(Ang)

				Ang:RotateAroundAxis(pUp, localAng[1])
				Ang:RotateAroundAxis(pRight, localAng[2])
				Ang:RotateAroundAxis(pForward, localAng[3])
			else
				--[[
				if isFamale then
					localPos = wep.vbwPosF or wep.vbwPos or RifleOffsetF
					localAng = wep.vbwAngF or wep.vbwAng or RifleAngF
				else --]]

				localPos = wep.vbwPos or RifleOffset
				localAng = wep.vbwAng or RifleAng
				-- end

				Offset:Set(spinePos)
				Ang:Set(spineAng)

				clone = Vector(localPos[1], localPos[2], localPos[3])
				clone:Rotate(Ang)

				Ang:RotateAroundAxis(sUp, localAng[1])
				Ang:RotateAroundAxis(sRight, localAng[2])
				Ang:RotateAroundAxis(sForward, localAng[3])
			end
		end

		Offset:Add(clone)

		worldModel:SetModel(wep.WorldModel) -- "models/hunter/plates/plate05.mdl"
		worldModel:SetModelScale(wep.vbwModelScale or 1)
		worldModel:SetPos(Offset)
		worldModel:SetAngles(Ang)
		worldModel:DrawModel()

		if wep.DrawWorldModelAdd then wep:DrawWorldModelAdd(worldModel) end
	end
end)

local vecZero = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local angRotate = Angle(0, 0, 0)

local _cameraPos = Vector(20, 20, 10)
local _cameraAng = Angle(10, 0, 0)

local function PrintWeaponInfo(self, x, y, alpha)
	if self.DrawWeaponInfoBox == false then return end
	if self.InfoMarkup == nil then
		local str
		local title_color = "<color=230,230,230,255>"
		local text_color = "<color=150,150,150,255>"
		str = "<font=HudSelectionText>"
		-- if self.Author ~= "" then str = str .. title_color .. "Author:</color>\t" .. text_color .. self.Author .. "</color>\n" end
		-- if self.Contact ~= "" then str = str .. title_color .. "Contact:</color>\t" .. text_color .. self.Contact .. "</color>\n\n" end
		-- if self.Purpose ~= "" then str = str .. title_color .. "Purpose:</color>\n" .. text_color .. self.Purpose .. "</color>\n\n" end
		if self.Instructions ~= "" then str = str .. title_color .. "Description:</color>\t" .. text_color .. self.Instructions .. "</color>\n" end

		str = str .. "</font>"
		self.InfoMarkup = markup.Parse(str, 250)
	end

	-- surface.DrawTexturedRect(x, y - 64 - 5, 128, 64)
	draw.RoundedBox(0, x, y, 260, self.InfoMarkup:GetHeight() + 2, Color(60, 60, 60, alpha))
	self.InfoMarkup:Draw(x + 5, y, nil, nil, alpha)
end

DrawWeaponSelectionEX = function(self, x, y, wide, tall, alpha)
	local cameraPos = self.dwsPos or _cameraPos
	local mdl = self.WorldModel

	if mdl then
		local DrawModel = G_DrawModel

		if not IsValid(DrawModel) then
			G_DrawModel = ClientsideModel(mdl, RENDER_GROUP_OPAQUE_ENTITY)
			DrawModel = G_DrawModel
			DrawModel:SetNoDraw(true)
		else
			DrawModel:SetModel(mdl)

			cam.Start3D(cameraPos, (-cameraPos):Angle() - (self.cameraAng or _cameraAng), 45, x, y, wide, tall)
				-- cam.IgnoreZ(true)

				render.SuppressEngineLighting(true)
				render.SetLightingOrigin(vecZero)
				render.ResetModelLighting(50 / 255, 50 / 255, 50 / 255)
				render.SetColorModulation(1, 1, 1)
				render.SetBlend(255)
				render.SetModelLighting(4, 1, 1, 1)

				angRotate:Set(angZero)
				angRotate[2] = RealTime() * 30 % 360
				angRotate:Add(self.dwsItemAng or angZero)

				local dir = Vector(0, 0, 0)
				dir:Set(self.dwsItemPos or vecZero)
				dir:Rotate(angRotate)

				DrawModel:SetRenderAngles(angRotate)
				DrawModel:SetRenderOrigin(dir)
				DrawModel:DrawModel()

				render.SetColorModulation(1, 1, 1)
				render.SetBlend(1)
				render.SuppressEngineLighting(false)

				-- cam.IgnoreZ(false)
			cam.End3D()
		end
	end

	if self.PrintWeaponInfo then PrintWeaponInfo(self, x + wide, y + tall, alpha) end
end

DrawWeaponSelection = function(self, x, y, w, h, alpha) DrawWeaponSelectionEX(self, x, y, w, h + 35, alpha) end
OverridePaintIcon = function(self, x, y, w, h, obj) DrawWeaponSelectionEX(obj, x + 5, y + 5, w - 10, h - 30) end