SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.ar15.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.ar15.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/ar15icon.png"
end

SWEP.WepSelectIcon = "pwb2/vgui/weapons/m4a1"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "m4a1/m4a1_fp.wav"
SWEP.Primary.SoundFar = "m4a1/m4a1_dist.wav"
SWEP.Primary.Force = 160 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.08
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.TwoHands = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "ar2"

SWEP.addAng = Angle(0, -0.8, 0)

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb2/weapons/w_m4a1.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_m4a1.mdl"

SWEP.vbwPos = Vector(-4, -4.2, 1)
SWEP.vbwAng = Angle(7, -30, 0)

SWEP.SightPos = Vector(-30, 2.35, -0.3)