SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.ar2.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.ar2.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/ar2icon.png"
end

SWEP.WepSelectIcon = "pwb/sprites/akm"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/arccw/fire1.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_snp_far.wav"
SWEP.Primary.Force = 270 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.1
SWEP.ReloadSound = "weapons/arccw/npc_ar2_reload.wav"
SWEP.TwoHands = true
SWEP.Effect = "AR2Impact"
SWEP.Tracer = "AR2Tracer"

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

SWEP.ViewModel = "models/weapons/arccw/w_irifle.mdl"
SWEP.WorldModel = "models/weapons/arccw/w_irifle.mdl"

SWEP.vbwPos = Vector(2, -4.2, 1)
SWEP.vbwAng = Angle(5, -30, 0)

SWEP.addAng = Angle(0, 0.8, 90)

SWEP.dwmModeScale = 1
SWEP.dwmForward = 0
SWEP.dwmRight = 0
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = 0
SWEP.dwmAForward = 0

SWEP.SightPos = Vector(-30, 2, 3.18)