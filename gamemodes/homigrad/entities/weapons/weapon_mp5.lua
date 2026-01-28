SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.mp5.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.mp5.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/mp5icon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Spread = 5
SWEP.Primary.Sound = "zcitysnd/sound/weapons/mp5k/mp5k_fp.wav"
SWEP.Primary.SoundFar = "zcitysnd/sound/weapons/mp5k/mp5k_dist.wav"
SWEP.Primary.Force = 85 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.06
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

SWEP.ViewModel = "models/pwb2/weapons/w_mp5a3.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_mp5a3.mdl"

SWEP.vbwPos = Vector(-4, -3.7, 2)
SWEP.vbwAng = Angle(2, -30, 0)

SWEP.addAng = Angle(0, 0, 0)

SWEP.SightPos = Vector(-22, 2.1, -0.23)