SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.tmp.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.tmp.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/tmpicon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb/weapons/tmp/shoot.wav"
-- SWEP.Primary.SoundFar = "weapons/m14/m14_dist.wav"
SWEP.Primary.Force = 270 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.06
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

SWEP.HoldType = "smg"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb/weapons/w_tmp.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_tmp.mdl"

SWEP.addAng = Angle(0.7, -2, 0)
SWEP.addPos = Vector(0, 0, 0)
SWEP.vbwPos = Vector(12, -1.5, -12)
SWEP.vbwAng = Angle(10, -30, 0)

SWEP.dwmModeScale = 1
SWEP.dwmForward = 3
SWEP.dwmRight = 0
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = 0
SWEP.dwmAForward = 0

SWEP.SightPos = Vector(-25, 1.85, -0.2)