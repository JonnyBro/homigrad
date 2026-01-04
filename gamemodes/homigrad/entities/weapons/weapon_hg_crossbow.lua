SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.crossbow.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.crossbow.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/crossbowicon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "XBowBolt"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 255
-- SWEP.Primary.Recoil = 25-- This doesn't work. It removes the recoil entirely.
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/crossbow/bolt_fly4.wav"
SWEP.ReloadSound = "weapons/crossbow/reload1.wav"
SWEP.Primary.Force = 255
SWEP.ReloadTime = 2
SWEP.ShootWait = .03

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "ar2"

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/w_jmod_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_crossbow.mdl"

SWEP.vbwPos = Vector(0, 0, 0)

SWEP.Supressed = true
SWEP.dwmModeScale = 0.9
SWEP.dwmForward = 0
SWEP.dwmRight = 0
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = 0
SWEP.dwmAForward = 0

SWEP.addAng = Angle(-6, 0, -90)
SWEP.addPos = Vector(0, -1, 0)

SWEP.Effect = "PhyscannonImpact"

SWEP.vbw = false

SWEP.SightPos = Vector(-30, -1, -4.5)