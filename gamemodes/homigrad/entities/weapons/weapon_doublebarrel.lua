SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.dbss.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.dbss.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/obrezicon.png"
end

SWEP.WepSelectIcon = "pwb2/vgui/weapons/m4super90"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0.02
SWEP.Primary.Damage = 30
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/tfa_ins2/doublebarrel_sawnoff/doublebarrelsawn_fire.wav"
SWEP.Primary.Force = 35
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.1
SWEP.NumBullet = 8
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

SWEP.ViewModel = "models/weapons/tfa_ins2/w_doublebarrel_sawnoff.mdl"
SWEP.WorldModel = "models/weapons/tfa_ins2/w_doublebarrel_sawnoff.mdl"

SWEP.vbwPos = Vector(0, -4.7, 1)
SWEP.vbwAng = Angle(15, 5, -90)

SWEP.addAng = Angle(0, 0, 90)
SWEP.addPos = Vector(18, 0, 1.5) -- some magic numbers

SWEP.dwmModeScale = 1 -- pos
SWEP.dwmForward = 3
SWEP.dwmRight = 0.3
SWEP.dwmUp = 0

SWEP.dwmAUp = 0 -- ang
SWEP.dwmARight = -15
SWEP.dwmAForward = 180

SWEP.SightPos = Vector(0, 0.4, 2.5)

function SWEP:ApplyEyeSpray()
	self.eyeSpray = self.eyeSpray - Angle(5, math.Rand(-4, 4), 0)
end