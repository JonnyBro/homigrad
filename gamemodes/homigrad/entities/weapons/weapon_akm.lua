SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.akm.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.akm.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/akmicon.png"
end

SWEP.WepSelectIcon = "pwb/sprites/akm"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.62x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 45
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "ak74/ak74_fp.wav"
SWEP.Primary.SoundFar = "ak74/ak74_dist.wav"
SWEP.Primary.Force = 240 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.1
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.TwoHands = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "ar2"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb/weapons/w_akm.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_akm.mdl"

SWEP.vbwPos = Vector(5, -6, -6)

SWEP.addAng = Angle(-0.1, 0, 0)
SWEP.addPos = Vector(0, 0, 0)

SWEP.SightPos = Vector(-30, 1.7, -0.27)