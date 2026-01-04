SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.beretta.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.beretta.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
		SWEP.IconOverride = "materials/items_icons/berettaicon.png"

end

SWEP.WepSelectIcon = "pwb/sprites/m9"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb2/weapons/fiveseven/fire.wav"
-- SWEP.Primary.SoundFar = "m45/m45_dist.wav"
SWEP.Primary.Force = 65 / 3

SWEP.ReloadTime = 2
SWEP.ShootWait = 0.12

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

SWEP.ViewModel = "models/pwb/weapons/w_m9.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_m9.mdl"

SWEP.vbwPos = Vector(8, -9, -8)

SWEP.addPos = Vector(0, 0, -0.9)
SWEP.addAng = Angle(0, 0, 0)

SWEP.SightPos = Vector(-20, 0.3, -0.96)