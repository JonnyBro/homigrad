SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.p220.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.p220.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/p220icon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 17
SWEP.Primary.DefaultClip = 17
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "m9/m9_fp.wav"
SWEP.Primary.SoundFar = "m9/m9_dist.wav"
SWEP.Primary.Force = 90 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.08

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

SWEP.ViewModel = "models/pwb/weapons/w_cz75.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_cz75.mdl"

SWEP.vbwPos = Vector(8.5, -10, -8)
SWEP.addAng = Angle(0, -1, 0.8)
SWEP.addPos = Vector(0, 0, -0.9)

SWEP.SightPos = Vector(-20, 0.8, -0.9)