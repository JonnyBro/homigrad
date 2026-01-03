SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.dbs.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.dbs.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/dbicon.png"
end

SWEP.WepSelectIcon = "pwb2/vgui/weapons/m4super90"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0.02
SWEP.Primary.Damage = 45
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/tfa_ins2/doublebarrel_sawnoff/doublebarrelsawn_fire.wav"
SWEP.Primary.Force = 35
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.1
SWEP.NumBullet = 16
SWEP.Sight = true
SWEP.TwoHands = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.att = 0

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "ar2"

SWEP.Slot = 2
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/tfa_ins2/w_doublebarrel.mdl"
SWEP.WorldModel = "models/weapons/tfa_ins2/w_doublebarrel.mdl"

SWEP.vbwPos = Vector(-2, -4.7, 4)
SWEP.vbwAng = Angle(2.5, -30, 0)

SWEP.addAng = Angle(0, 0, 90)
SWEP.addPos = Vector(18, 0, 1.5) -- some magic numbers

SWEP.dwmModeScale = 1
SWEP.dwmForward = 3
SWEP.dwmRight = 0.3
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = -15
SWEP.dwmAForward = 180

SWEP.SightPos = Vector(0, 0.4, 2.5)

function SWEP:ApplyEyeSpray()
	self.eyeSpray = self.eyeSpray - Angle(4, math.Rand(-1.5, 1.5), 0)
end