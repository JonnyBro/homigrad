SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.usp.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.usp.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/uspicon.png"
end

SWEP.WepSelectIcon = "pwb2/vgui/weapons/usptactical"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 26
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/tfa_ins2/usp_tactical/fp1.wav"
SWEP.Primary.SoundFar = "weapons/tfa_ins2/usp_tactical/fpddd.wav"
SWEP.Primary.Force = 90 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.14

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "revolver"

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb2/weapons/w_usptactical.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_usptactical.mdl"

SWEP.vbwPos = Vector(6.5, 3.4, -4)

SWEP.addPos = Vector(0, -2, -0.8)
SWEP.addAng = Angle(0.35, 0.4, 1.5)

SWEP.SightPos = Vector(-22, -0.55, -0.7)