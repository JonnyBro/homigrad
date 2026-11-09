SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.xm8lmg.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.xm8lmg.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/xm8icon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb2/weapons/xm8lmg/m249-1.wav"
SWEP.Primary.SoundFar = "zcitysnd/sound/weapons/m249/m249_dist.wav"
SWEP.Primary.Force = 240 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.085
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.TwoHands = true
SWEP.Supressed = true

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

SWEP.ViewModel = "models/pwb2/weapons/w_xm8lmg.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_xm8lmg.mdl"

SWEP.addAng = Angle(0.2, -0, 0)
SWEP.addPos = Vector(0, 4, -0.7)
SWEP.vbwPos = Vector(1.5, -7.1, 0)
SWEP.vbwAng = Angle(15, 10, -90)

SWEP.SightPos = Vector(-33, 4, -0.4)

-- DO NOT APPLY 3D CROSSHAIRS ON GUNS WITH TRANSPARENT GLASS. BROKEN AF.