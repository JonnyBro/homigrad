SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.usps.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.usps.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/uspsicon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb/weapons/tmp/shoot.wav"
SWEP.Primary.Force = 70 / 3
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

SWEP.ViewModel = "models/weapons/v_bean_beansmusp.mdl"
SWEP.WorldModel = "models/weapons/w_bean_beansmusp.mdl"

SWEP.vbwPos = Vector(7.5, 0.1, -6)
SWEP.Supressed = true

SWEP.dwmModeScale = 1
SWEP.dwmForward = -0.6
SWEP.dwmRight = 1
SWEP.dwmUp = 0.5

SWEP.dwmAUp = 4
SWEP.dwmARight = -5.5
SWEP.dwmAForward = -90

SWEP.addAng = Angle(1.55, -0.9, 2)
SWEP.addPos = Vector(10, 3.7, -0.45)

SWEP.SightPos = Vector(-10, 4.96, -0.05)