AddCSLuaFile()

SWEP.Base = "weapon_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.medkit.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.medkit.inst")
	SWEP.Category = language.GetPhrase("hg.category.medicine")
	SWEP.IconOverride = "materials/items_icons/medkiticon.png"
end

SWEP.Spawnable = true

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.ViewModel = "models/w_models/weapons/w_eq_medkit.mdl"
SWEP.WorldModel = "models/w_models/weapons/w_eq_medkit.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawCrosshair = false

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(15, 15, 15)

SWEP.vbw = false
SWEP.vbwPos = Vector(0, -1, -7)
SWEP.vbwAng = Angle(-90, 90, 180)
SWEP.vbwModelScale = 0.8

SWEP.Delay = 0.25

function SWEP:PostInit()
end

function SWEP:Initialize()
	self:SetHoldType("slam")
	self:PostInit()
end

if SERVER then return end

function SWEP:GetViewModelPosition(pos, ang)
	pos = pos - ang:Up() * 10 + ang:Forward() * 30 + ang:Right() * 7

	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Right(), -10)
	ang:RotateAroundAxis(ang:Forward(), -10)

	return pos, ang
end

SWEP.dwmModeScale = 1
SWEP.dwmForward = 3
SWEP.dwmRight = 0.3
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = 180
SWEP.dwmAForward = 90

function SWEP:DrawWorldModel()
	local owner = self:GetOwner()

	if not IsValid(owner) then
		self:DrawModel()
		self:SetRenderOrigin()
		self:SetRenderAngles()

		return
	end

	local Pos, Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
	if not Pos then return end

	self:SetModel(self.WorldModel)

	Pos:Add(Ang:Forward() * self.dwmForward)
	Pos:Add(Ang:Right() * self.dwmRight)
	Pos:Add(Ang:Up() * self.dwmUp)

	Ang:RotateAroundAxis(Ang:Up(), self.dwmAUp)
	Ang:RotateAroundAxis(Ang:Right(), self.dwmARight)
	Ang:RotateAroundAxis(Ang:Forward(), self.dwmAForward)

	-- self:SetPos(Pos)
	-- self:SetAngles(Ang)

	self:SetRenderOrigin(Pos)
	self:SetRenderAngles(Ang)

	self:SetModelScale(self.dwmModeScale)
	self:DrawModel()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end