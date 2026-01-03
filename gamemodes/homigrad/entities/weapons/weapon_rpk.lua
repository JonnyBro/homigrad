SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.rpk.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.rpk.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/rpkicon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 45
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.62x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 45
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb2/weapons/rpk/rpk-1.wav"
-- SWEP.Primary.SoundFar = "ak74/ak74_dist.wav"
SWEP.Primary.Force = 240 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.08
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.TwoHands = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "smg"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb2/weapons/w_rpk.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_rpk.mdl"

SWEP.addAng = Angle(0, -0.8, 0.5)

SWEP.SightPos = Vector(-36, 4, -0.2)