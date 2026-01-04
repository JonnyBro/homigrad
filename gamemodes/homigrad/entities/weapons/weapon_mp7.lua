SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.mp7.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.mp7.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/mp7icon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 40
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "4.6x30 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 30
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "mp5k/mp5k_fp.wav"
SWEP.Primary.SoundFar = "mp5k/mp5k_dist.wav"
SWEP.Primary.Force = 120 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.06
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

SWEP.ViewModel = "models/pwb2/weapons/w_mp7.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_mp7.mdl"

SWEP.vbwPos = Vector(-2, -3.7, 1)
SWEP.vbwAng = Angle(5, -30, 0)

SWEP.dwmModeScale = 1
SWEP.dwmForward = 5
SWEP.dwmRight = 0
SWEP.dwmUp = 1.5

SWEP.dwmAUp = 0
SWEP.dwmARight = 0
SWEP.dwmAForward = 0

SWEP.addPos = Vector(0, 0, 0)
SWEP.addAng = Angle(-0.1, 0, 0.8)

SWEP.SightPos = Vector(-16, 4.95, -0.25)