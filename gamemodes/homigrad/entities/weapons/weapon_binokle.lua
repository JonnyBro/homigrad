SWEP.Base = "weapon_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.binoculars.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.binoculars.inst")
	SWEP.Category = language.GetPhrase("hg.category.tools")
	SWEP.IconOverride = "materials/items_icons/binocularsicon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 5
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/customstuff/binoculars.mdl"
SWEP.WorldModel = "models/customstuff/binoculars.mdl"

SWEP.ViewBack = true
SWEP.ForceSlot1 = true

SWEP.dwsPos = Vector(10, 10, 10)

SWEP.vbw = true
SWEP.vbwPistol = true
SWEP.vbwPos = Vector(-6, 0, 6)
SWEP.vbwAng = Angle(0, 150, 0)
-- SWEP.vbwPos = Vector(47, -6, 10)
-- SWEP.vbwAng = Angle(-180, 90, 0)
SWEP.vbwModelScale = 0.8

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

function SWEP:Initialize()
	AddHomigradWeapon(self)
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end

function SWEP:Step()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if SERVER then self:SetNWBool("Focus", owner:KeyDown(IN_ATTACK2)) end

	local isFocus = self:GetNWBool("Focus")

	self:SetHoldType(isFocus and "camera" or "slam")

	-- if CLIENT or SERVER then self:SetWeaponHoldType(isFocus and "camera" or "slam") end
end

if SERVER then return end

local value = 0

hook.Add("CalcAddFOV", "Binokle", function(ply)
	if not LerpFT then return end

	local wep = ply:GetActiveWeapon()
	wep = IsValid(wep) and wep:GetClass() == "weapon_binokle" and ply:KeyDown(IN_ATTACK2)

	value = LerpFT(0.1, value, wep and -75 or 0)

	ADDFOV = ADDFOV + value
end)

local white = Color(255, 255, 255)

hook.Add("HUDPaint", "binokle", function()
	local have
	local plr = LocalPlayer()
	local weps = plr:GetWeapons()

	if weps["weapon_binokle"] then have = true end
	if not have then return end

	local count = 36
	local step = 360 / count

	for i = 0, count - 1 do
		local dir = Vector(8000, 0, 0)
		dir:Rotate(Angle(0, i * step, 0))

		local pos = plr:GetPos() + dir
		pos = pos:ToScreen()

		local max = ScrW() / 4
		local a = math.max(max - math.abs(ScrW() / 2 - pos.x), 0) / max
		a = math.max(a - 0.4, 0) / 0.6

		white.a = a * 255

		draw.SimpleText(i * step, "DefaultFixedDropShadow", pos.x, 25, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)

SWEP.dwmModeScale = 1
SWEP.dwmForward = 3
SWEP.dwmRight = 6
SWEP.dwmUp = -2

SWEP.dwmAUp = 0
SWEP.dwmARight = 190
SWEP.dwmAForward = -10

-- local model = GDrawWorldModel or ClientsideModel(SWEP.WorldModel, RENDER_GROUP_OPAQUE_ENTITY)
-- GDrawWorldModel = model
-- model:SetNoDraw(true)

function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	if not IsValid(owner) then return self:DrawModel() end

	local Pos, Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
	if not Pos then return end

	self:SetModel(self.WorldModel)

	Pos:Add(Ang:Forward() * self.dwmForward)
	Pos:Add(Ang:Right() * self.dwmRight)
	Pos:Add(Ang:Up() * self.dwmUp)

	self:SetPos(Pos)

	Ang:RotateAroundAxis(Ang:Up(), self.dwmAUp)
	Ang:RotateAroundAxis(Ang:Right(), self.dwmARight)
	Ang:RotateAroundAxis(Ang:Forward(), self.dwmAForward)

	self:SetAngles(Ang)
	self:SetModelScale(self.dwmModeScale)

	local isFocus = self:GetNWBool("Focus")
	if not isFocus or not firstPerson then self:DrawModel()
	else self:SetNoDraw(true) end
end