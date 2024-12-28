 --[[
 - Fortification Builder Tablet
 - 
 - /lua/weapons/alydus_fortificationbuildertablet.lua
 -
 - Primary weapon definition file, utilises meta functions defined in /lua/autorun/server/sv_alydusfortificationbuildertablet_meta.lua
 - 
 - Feel free to modify, but please leave appropriate credit.
 - Do not reupload this (modified or original) to this workshop, however you may ruin modified versions on your servers.
 - Assets included for fortifications Alydus does not own the rights to, so do as you wish, but its suggested you also leave appropriate credit.
 -
 - Thanks so much for the support with the addon since it's creation in 2018.
 -
 --]]

AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Fortification Tablet"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false

	surface.CreateFont("Alydus.FortificationsTablet.Title", {font = "Roboto Condensed", size = 50})
	surface.CreateFont("Alydus.FortificationsTablet.Subtitle", {font = "Roboto Condensed", size = 35})
	surface.CreateFont("Alydus.FortificationsTablet.TitleVM", {font = "Roboto Condensed", size = 60})
	surface.CreateFont("Alydus.FortificationsTablet.SubtitleVM", {font = "Roboto Condensed", size = 52})
	surface.CreateFont("Alydus.FortificationsTablet.HealthSubtitle", {font = "Roboto Condensed", size = 30})
	surface.CreateFont("Alydus.FortificationsTablet.HealthEmbeddedTitle", {font = "Roboto Condensed", size = 25})

	if GAMEMODE.IsSandboxDerived then
		language.Add("SBoxLimit_fortifications", "You've hit the Fortification limit!")
	end

	language.Add("Undone_Fortification", "Undone Fortification")

	language.Add("Cleanup_fortifications", "Fortifications")
	language.Add("Cleaned_fortifications", "Cleaned up all fortifications")
elseif SERVER then
	CreateConVar("sbox_maxfortifications", 10)
end

cleanup.Register("fortifications")

SWEP.Author = "Alydus"
SWEP.Instructions = "A utility weapon that allows the user to build fortifications."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "Разное"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 3.5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 3.5

SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_grenade.mdl"
SWEP.WorldModel = "models/nirrti/tablet/tablet_sfm.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.IronSightsPos = Vector(12.72, 0, 0.36)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- Define fortifications
SWEP.Fortifications = {
	{name = "Sandbags Corner 1", model = "models/props_fortifications/sandbags_corner1.mdl"},
	{name = "Sandbags Corner 1 Tall", model = "models/props_fortifications/sandbags_corner1_tall.mdl"},
	{name = "Sandbags Corner 2", model = "models/props_fortifications/sandbags_corner2.mdl"},
	{name = "Sandbags Corner 2 Tall", model = "models/props_fortifications/sandbags_corner2_tall.mdl"},
	{name = "Sandbags Corner 3", model = "models/props_fortifications/sandbags_corner3.mdl"},
	{name = "Sandbags Line 1", model = "models/props_fortifications/sandbags_line1.mdl"},
	{name = "Sandbags Line 1 Tall", model = "models/props_fortifications/sandbags_line1_tall.mdl"},
	{name = "Sandbags Line 2", model = "models/props_fortifications/sandbags_line2.mdl"},
	{name = "Sandbags Line 2 Tall", model = "models/props_fortifications/sandbags_line2_tall.mdl"},
	{name = "Sandbags Line 3", model = "models/props_fortifications/sandbags_line2b.mdl"},
	{name = "Concrete Wall", model = "models/props_fortifications/concrete_wall001_96_reference.mdl"},
	{name = "Concrete Barrier 1", model = "models/props_c17/concrete_barrier001a.mdl"},
	{name = "Concrete Barrier 2 Small", model = "models/props_fortifications/concrete_barrier001_96_reference.mdl"},
	{name = "Concrete Barrier 2 Large", model = "models/props_fortifications/concrete_barrier001_128_reference.mdl"},
	{name = "Concrete Barrier 3", model = "models/jbarnes/props/concrete barricade.mdl"},
	{name = "Small Fence", model = "models/props_c17/fence01b.mdl"},
	{name = "Medium Fence", model = "models/props_c17/fence01a.mdl"},
	{name = "Large Fence", model = "models/props_c17/fence03a.mdl"},
	{name = "Small Anti-Climb Fence", model = "models/props_wasteland/exterior_fence002b.mdl",},
	{name = "Medium Anti-Climb Fence", model = "models/props_wasteland/exterior_fence002c.mdl"},
	{name = "Large Anti-Climb Fence", model = "models/props_wasteland/exterior_fence002d.mdl"},
	{name = "Police Barricade Single", model = "models/props_street/police_barricade.mdl"},
	{name = "Police Barricade Triple", model = "models/props_street/police_barricade2.mdl"},
	{name = "Hesco Small", model = "models/static_afghan/prop_fortification_hesco_small.mdl"},
	{name = "Hesco Tall", model = "models/iraq/ir_hesco_basket_01.mdl"},
	{name = "Hesco Tall Leaning", model = "models/iraq/ir_hesco_basket_01b.mdl"}
}

-- Setup developer add fortification hook
hook.Add("Alydus.FortificationBuilderTablet.AddFortification", "Alydus_FortificationBuilderTablet_AddFortificationHook", function(fortification)
	if fortification["name"] and fortification["model"] then
		table.insert(SWEP.Fortifications, fortification)
	else
		print("Invalid fortification data, failed to add fortification. Please include name, and model.")
	end
end)

-- Cache fortification models
SWEP.FortificationsModelList = {}

print("Caching fortifications models for builder tablet...")

for _, fortification in pairs(SWEP.Fortifications) do
	util.PrecacheModel(fortification["model"])
	table.insert(SWEP.FortificationsModelList, fortification["model"])
end

print("Fortifications models successfully cached.")

-- Define SWEP render elements
SWEP.VElements = {
	["tablet"] = { type = "Model", model = "models/nirrti/tablet/tablet_sfm.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.714, 6.714, -3.636), angle = Angle(29, 100, -127.403), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 1, bodygroup = {} }
}

SWEP.WElements = {
	["tablet"] = { type = "Model", model = "models/nirrti/tablet/tablet_sfm.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.513, 5.714, -2.597), angle = Angle(26.882, 113.376, -127.403), size = Vector(0.82, 0.82, 0.82), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 1, bodygroup = {} },
	["light"] = { type = "Sprite", sprite = "sprites/blueglow1", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 1, -2.398), size = { x = 1.729, y = 1.729 }, color = Color(255, 255, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false}
}

-- Setup networking for SWEP
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsBootingUp")
	self:NetworkVar("Int", 0, "SelectedFortification")
end

if SERVER then
	resource.AddWorkshop("1461735659")
	
	-- Handle placing fortifications
	hook.Add("KeyPress", "Alydus_KeyPress_HandleBuildTabletHologramFinished", function(ply, key)
		if key == IN_USE and IsValid(ply) and ply:CanBuildAlydusFortification() then
			local fortificationClass = "prop_physics"
			
			if alydusDestructibleFortificationExtension then
				fortificationClass = "alydus_destructiblefortification"
			end

			local fortification = ents.Create(fortificationClass)
			fortification:SetAngles(Angle(0, ply:EyeAngles().y - 180, 0))

			if alydusDestructibleFortificationExtension then
				fortification:SetFortificationHealth(GetConVar("alydus_defaultfortificationhealth"):GetInt())
				fortification:SetMaximumFortificationHealth(GetConVar("alydus_defaultfortificationhealth"):GetInt())
			end

			fortification:SetModel(ply:GetActiveWeapon().Fortifications[ply:GetActiveWeapon():GetSelectedFortification()]["model"])
			fortification:Spawn()
			fortification:SetPos(ply:GetEyeTrace().HitPos - ply:GetEyeTrace().HitNormal * fortification:OBBMins().z)

			fortification:SetGravity(150)
			fortification.isPlayerPlacedFortification = ply

			if GAMEMODE.IsSandboxDerived then
				ply:AddCount("fortifications", fortification)
				ply:AddCleanup("fortifications", fortification)
			end

			fortification:EmitSound("physics/concrete/rock_impact_hard" .. math.random(1, 6) .. ".wav")

			local phys = fortification:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetMass(50000)
				phys:EnableMotion(false)
			end

			local effectdata = EffectData()
			effectdata:SetOrigin(Vector(fortification:GetPos().x, fortification:GetPos().y, fortification:GetPos().z) + (fortification:GetUp() * fortification:OBBMaxs().z / 2))
			effectdata:SetMagnitude(3)
			effectdata:SetScale(5)
			effectdata:SetRadius(2)
			util.Effect("cball_explode", effectdata, true, true)

			undo.Create("Fortification")
				undo.AddEntity(fortification)
				undo.SetPlayer(ply)
			undo.Finish()
		end
	end)

	-- Handle tablet bootup and tablet shutdown
	hook.Add("PlayerSwitchWeapon", "Alydus_PlayerSwitchWeapon_FortificationBuilderTabletBootup", function(ply, oldWep, newWep)
		if newWep:GetClass() == "alydus_fortificationbuildertablet" and newWep:GetIsBootingUp() == false then
			newWep:SetIsBootingUp(true)

			ply:EmitSound("ambient/machines/thumper_startup1.wav")

			timer.Simple(2.5, function()
				if IsValid(ply) and newWep:GetIsBootingUp() == true and ply:HasWeapon("alydus_fortificationbuildertablet") then
					ply:EmitSound("npc/scanner/combat_scan4.wav")
					newWep:SetIsBootingUp(false)
					newWep:SetSelectedFortification(1)
				end
			end)
		elseif ply:HasWeapon("alydus_fortificationbuildertablet") and IsValid(oldWep) and oldWep:GetClass() == "alydus_fortificationbuildertablet" then
			ply:EmitSound("npc/roller/mine/combine_mine_deactivate1.wav")

			if ply.fortificationHologram != nil and IsValid(ply.fortificationHologram) then
				ply.fortificationHologram:Remove()
				ply.fortificationHologram = nil
			end
		end
	end)
else
	playerFortificationHolograms = playerFortificationHolograms or {}

	-- Handle clientside fortification holograms for every player
	hook.Add("Tick", "Alydus_Tick_DrawFortificationHolograms", function()
		for steamid64, fortificationHologram in pairs(playerFortificationHolograms) do
			if !IsValid(player.GetBySteamID64(steamid64)) then
				if IsValid(fortificationHologram) then
					fortificationHologram:Remove()
				end

				playerFortificationHolograms[steamid64] = nil
			end
		end

		for _, ply in ipairs(player.GetHumans()) do
			if IsValid(ply) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "alydus_fortificationbuildertablet" and ply:GetActiveWeapon().Fortifications[ply:GetActiveWeapon():GetSelectedFortification()] then
				local tr = ply:GetEyeTrace()
				local wep = ply:GetActiveWeapon()
				local fortificationHologramAngles = Angle(0, ply:EyeAngles().y - 180, 0)
				local fortificationModel = wep.Fortifications[wep:GetSelectedFortification()]["model"]

				if !playerFortificationHolograms[ply:SteamID64()] or !IsValid(playerFortificationHolograms[ply:SteamID64()]) then
					playerFortificationHolograms[ply:SteamID64()] = ClientsideModel(fortificationModel)

					local fortificationHologram = playerFortificationHolograms[ply:SteamID64()]
					fortificationHologram:SetPos(tr.HitPos - tr.HitNormal * fortificationHologram:OBBMins().z)
					fortificationHologram:SetAngles(fortificationHologramAngles)
					fortificationHologram:SetRenderMode(RENDERMODE_TRANSALPHA)
					fortificationHologram:DrawShadow(false)
					fortificationHologram:Spawn()
					fortificationHologram.isAlydusFortificationHologram = true
				elseif IsValid(playerFortificationHolograms[ply:SteamID64()]) then
					local fortificationHologram = playerFortificationHolograms[ply:SteamID64()]

					if fortificationHologram:GetModel() != fortificationModel then
						fortificationHologram:SetModel(fortificationModel)
					end

					local visualPos = Lerp(20 * FrameTime(), fortificationHologram:GetPos(), (tr.HitPos - tr.HitNormal * fortificationHologram:OBBMins().z))
					local visualAngle = LerpAngle(20 * FrameTime(), fortificationHologram:GetAngles(), fortificationHologramAngles, 0)

					fortificationHologram:SetPos(visualPos)
					fortificationHologram:SetAngles(fortificationHologramAngles)

					if ply:CanDrawAlydusFortification() then
						fortificationHologram:SetColor(Color(46, 204, 113, 150))
					else
						fortificationHologram:SetColor(Color(255, 0, 0, 0))
					end
				end
			elseif playerFortificationHolograms[ply:SteamID64()] then
				playerFortificationHolograms[ply:SteamID64()]:Remove()
				playerFortificationHolograms[ply:SteamID64()] = nil
			end
		end
	end)

	-- Draw HUD
	function SWEP:DrawHUD()
		local ply = LocalPlayer()

		if IsValid(ply) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "alydus_fortificationbuildertablet" then

			-- Destructable Fortification Display
			for _, destructibleFortification in ipairs(ents.FindByClass("alydus_destructiblefortification")) do
				if IsValid(destructibleFortification) and destructibleFortification:GetFortificationHealth() > 0 and destructibleFortification:GetPos():DistToSqr(ply:GetPos()) < (250 ^ 2) then
					local pos = Vector(destructibleFortification:GetPos().x, destructibleFortification:GetPos().y, destructibleFortification:GetPos().z)

					pos = pos + destructibleFortification:GetUp() * destructibleFortification:OBBMaxs().z / 2

					local pos2d = pos:ToScreen()

					local healthBarWidth = 300
					local healthBarHeight = 40

					surface.SetDrawColor(60, 60, 60, 150)

					surface.DrawRect(pos2d.x + (-healthBarWidth / 2), pos2d.y + (healthBarWidth / 2) - 210, healthBarWidth, healthBarHeight)

					surface.SetDrawColor(46, 204, 113, 150)

					surface.DrawRect(pos2d.x + (-healthBarWidth / 2), pos2d.y + (healthBarWidth / 2) - 210, (destructibleFortification:GetFortificationHealth() / destructibleFortification:GetMaximumFortificationHealth()) * healthBarWidth, healthBarHeight)

					draw.DrawText("DESTRUCTIBLE FORTIFICATION", "Alydus.FortificationsTablet.HealthSubtitle", pos2d.x, pos2d.y, Color(150, 150, 150), TEXT_ALIGN_CENTER)

					draw.DrawText(math.Round((destructibleFortification:GetFortificationHealth() / destructibleFortification:GetMaximumFortificationHealth()) * 100) .. "%", "Alydus.FortificationsTablet.HealthEmbeddedTitle", pos2d.x, pos2d.y - 55, Color(255, 255, 255), TEXT_ALIGN_CENTER)
				end
			end

			-- Selected Fortification Display
			if IsValid(playerFortificationHolograms[ply:SteamID64()]) and ply:CanDrawAlydusFortification() then
				local fortificationHologram = playerFortificationHolograms[ply:SteamID64()]

				local pos = Vector(fortificationHologram:GetPos().x, fortificationHologram:GetPos().y, fortificationHologram:GetPos().z) + (fortificationHologram:GetUp() * fortificationHologram:OBBMaxs().z / 2)

				local pos2d = pos:ToScreen()

				draw.DrawText(ply:GetActiveWeapon().Fortifications[ply:GetActiveWeapon():GetSelectedFortification()]["name"], "Alydus.FortificationsTablet.Title", pos2d.x, pos2d.y, Color(255, 255, 255), TEXT_ALIGN_CENTER)
				draw.DrawText("Placing...", "Alydus.FortificationsTablet.Subtitle", pos2d.x, pos2d.y + 50, Color(150, 150, 150), TEXT_ALIGN_CENTER)
			end
		end
	end

	local entityTabletMat = Material("entities/alydus_fortificationbuildertablet.png")

	-- Draw Weapon Selection
	function SWEP:DrawWeaponSelection(x, y, w, h, a)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(entityTabletMat)
		surface.DrawTexturedRect(x + 75, y + 20, 185, 185)

		self:PrintWeaponInfo(x + w + 20, y + h * 0.95, a)
	end
end

function SWEP:Initialize()
	if SERVER then
		self:SetIsBootingUp(false)
		self:SetSelectedFortification(1)
	end
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	if SERVER then
		if IsValid(ply) and ply:CanSelectNextAlydusFortification() then
			print(self.Fortifications[self:GetSelectedFortification() + 1])
			if self.Fortifications[self:GetSelectedFortification() + 1] then
				self:SetSelectedFortification(self:GetSelectedFortification() + 1)
			else
				self:SetSelectedFortification(1)
			end
		end
	else
		if IsValid(ply) and ply:CanSelectNextAlydusFortification() and IsFirstTimePredicted() then
			surface.PlaySound("physics/concrete/rock_impact_hard1.wav")
		end
	end
end

function SWEP:SecondaryAttack()
	local ply = self:GetOwner()

	if SERVER then
		if IsValid(ply) and ply:CanSelectPreviousAlydusFortification() then
			if self.Fortifications[self:GetSelectedFortification() - 1] then
				self:SetSelectedFortification(self:GetSelectedFortification() - 1)
			else
				self:SetSelectedFortification(table.Count(self.Fortifications))
			end
		end
	else
		if IsValid(ply) and ply:CanSelectPreviousAlydusFortification() and IsFirstTimePredicted() then
			surface.PlaySound("physics/concrete/rock_impact_hard3.wav")
		end
	end
end

function SWEP:Reload()
	if SERVER then
		local ply = self:GetOwner()

		if not ply:KeyPressed(IN_RELOAD) then
			return
		end

		if IsValid(ply) and ply:CanRemoveAlydusFortification() then
			local fortificationToDelete = ply:GetEyeTrace().Entity

			local effectdata = EffectData()
			effectdata:SetOrigin(Vector(fortificationToDelete:GetPos().x, fortificationToDelete:GetPos().y, fortificationToDelete:GetPos().z) + (fortificationToDelete:GetUp() * fortificationToDelete:OBBMaxs().z / 2))
			effectdata:SetMagnitude(3)
			effectdata:SetScale(5)
			effectdata:SetRadius(2)
			util.Effect("cball_explode", effectdata, true, true)

			fortificationToDelete:EmitSound("physics/concrete/rock_impact_hard" .. math.random(1, 6) .. ".wav")
			fortificationToDelete:Remove()
		end

		return
	end
end

if CLIENT then
	local wrenchMat = Material("alydus/icons/wrench.png")
	local nextMat = Material("alydus/icons/next.png")
	local lastMat = Material("alydus/icons/last.png")
	local shieldMat = Material("alydus/icons/shield.png")
	local refreshMat = Material("alydus/icons/refresh.png")

	local toolsMat = Material("alydus/icons/tools.png")

	local useBind = input.LookupBinding("+use") or "E"
	local reloadBind = input.LookupBinding("+reload") or "R"

	function SWEP:PostDrawViewModel(vm, wep, ply)
		if IsValid(vm) then
			local atch = vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Bip01_R_Hand"))
			local pos, ang = vm:GetBonePosition(vm:LookupBone("ValveBiped.Bip01_R_Hand")), vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles()
			ang:RotateAroundAxis(ang:Right(), 90)

			local baseAng = ang

			baseAng:RotateAroundAxis(baseAng:Right(), 20)
			baseAng:RotateAroundAxis(baseAng:Forward(), -11)
			baseAng:RotateAroundAxis(baseAng:Up(), 57)
			
			cam.Start3D2D(pos - ang:Right() * 3 - ang:Forward() * 8.5 + ang:Right() * -1, baseAng, 0.012)
				surface.SetDrawColor(255, 255, 255, 255)
				if self:GetIsBootingUp() == false then
					draw.SimpleText("Fortification Builder", "Alydus.FortificationsTablet.TitleVM", 15, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					surface.SetMaterial(nextMat)
					surface.DrawTexturedRect(230, 42, 40, 40)
					surface.SetMaterial(lastMat)
					surface.DrawTexturedRect(-235, 38, 40, 40)

					draw.SimpleText("LMB: Last | RMB: Next", "Alydus.FortificationsTablet.SubtitleVM", 15, 60, Color(150, 150, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					surface.SetMaterial(wrenchMat)
					surface.DrawTexturedRect(-215, 98, 40, 40)

					draw.SimpleText("    [" .. string.upper(useBind) .. "]: Build | [" .. string.upper(reloadBind) .. "]: Remove", "Alydus.FortificationsTablet.SubtitleVM", 15, 120, Color(150, 150, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					if alydusDestructibleFortificationExtension then
						surface.SetMaterial(toolsMat)
						surface.DrawTexturedRect(-95, 158, 40, 40)

						draw.SimpleText("      [G]: Repair", "Alydus.FortificationsTablet.SubtitleVM", 15, 180, Color(150, 150, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

						surface.SetMaterial(shieldMat)
						surface.DrawTexturedRect(-237, 222, 40, 40)

						draw.SimpleText("      " .. table.Count(self.Fortifications) .. " Fortifications Available", "Alydus.FortificationsTablet.SubtitleVM", 15, 240, Color(100, 100, 100, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						surface.SetMaterial(shieldMat)
						surface.DrawTexturedRect(-237, 158, 40, 40)

						draw.SimpleText("      " .. table.Count(self.Fortifications) .. " Fortifications Available", "Alydus.FortificationsTablet.SubtitleVM", 15, 180, Color(100, 100, 100, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				else
					draw.SimpleText("Fortification Builder", "Alydus.FortificationsTablet.TitleVM", 15, 30, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					surface.SetMaterial(refreshMat)
					surface.DrawTexturedRect(-130, 70, 40, 40)

					draw.SimpleText("    Booting up...", "Alydus.FortificationsTablet.SubtitleVM", 15, 90, Color(150, 150, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			cam.End3D2D()
		end
	end
end

function SWEP:GetViewModelPosition(pos, ang)
	self.SwayScale = 0
	self.BobScale = 0.1

	return pos, ang
end

function SWEP:Initialize()
	self:SetHoldType("slam")

	if CLIENT then
		self.VElements = table.FullCopy(self.VElements)
		self.WElements = table.FullCopy(self.WElements)
		self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)

		self:CreateModels(self.VElements)
		self:CreateModels(self.WElements)
		
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					vm:SetColor(Color(255,255,255,1))
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
	end
end

function SWEP:Holster()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
		end

		for k, name in ipairs(self.vRenderOrder) do
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial(v.material)
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
			elseif (v.type == "Sprite" and sprite) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	SWEP.wRenderOrder = nil

	function SWEP:DrawWorldModel()
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}

			for k, v in pairs(self.WElements) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs(self.wRenderOrder) do
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
			else
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial(v.material)
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation(basetab, v, ent)
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels(tab)
		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs(tab) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}
				for i, j in pairs(tocheck) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			
			for k, v in pairs(loopthrough) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale(bone, s)
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles(bone, v.angle)
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition(bone, p)
				end
			end
		else
			self:ResetBonePositions(vm)
		end
	end
	 
	function SWEP:ResetBonePositions(vm)
		if (!vm:GetBoneCount()) then return end

		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale(i, Vector(1, 1, 1))
			vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
			vm:ManipulateBonePosition(i, Vector(0, 0, 0))
		end
	end

	function table.FullCopy( tab )
		if (!tab) then return nil end
		
		local res = {}

		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v)
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
	end
end

