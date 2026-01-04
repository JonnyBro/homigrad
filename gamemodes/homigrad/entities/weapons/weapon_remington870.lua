SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.r870.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.r870.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/remington870icon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0.05
SWEP.Primary.Damage = 35
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "snd_jack_hmcd_sht_close.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_sht_far.wav"
SWEP.Primary.Force = 15
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.5
SWEP.NumBullet = 8
SWEP.Sight = true
SWEP.TwoHands = true
SWEP.shotgun = true

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

SWEP.ViewModel = "models/bydistac/weapons/w_shot_m3juper90.mdl"
SWEP.WorldModel = "models/bydistac/weapons/w_shot_m3juper90.mdl"

function SWEP:ApplyEyeSpray()
	self.eyeSpray = self.eyeSpray - Angle(5, math.Rand(-2, 2), 0)
end

SWEP.vbwPos = Vector(-9, -5, -5)

SWEP.CLR_Scope = 0.05
SWEP.CLR = 0.025

SWEP.addAng = Angle(-0.25, -1.9, 0)
SWEP.addPos = Vector(0, 0, 0)

SWEP.SightPos = Vector(-30, 2.3, -0.05)