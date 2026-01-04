SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.uzi.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.uzi.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/uziicon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 25
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 30
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb/weapons/uzi/shoot.wav"
SWEP.Primary.SoundFar = "weapons/ump45/ump45_dist.wav"
SWEP.Primary.Force = 85 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.05
SWEP.TwoHands = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "revolver"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb/weapons/w_uzi.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_uzi.mdl"

SWEP.vbwPos = Vector(-2, -4, -4)
SWEP.addAng = Angle(-0.18, -6.95, 0)
SWEP.addPos = Vector(0, 0, 0)
SWEP.SightPos = Vector(-18, 1.68, -0.225)