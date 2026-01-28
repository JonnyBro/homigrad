SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.m249.name")
	SWEP.Instructions = language.GetPhrase("hg.m249.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/m249icon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "zcitysnd/sound/weapons/m249/m249_fp.wav"
SWEP.Primary.SoundFar = "zcitysnd/sound/weapons/m249/m249_dist.wav"
SWEP.Primary.Force = 160 / 3
SWEP.ReloadTime = 2.5
SWEP.ShootWait = 0.1
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

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb2/weapons/w_m249paratrooper.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_m249paratrooper.mdl"

SWEP.vbwPos = Vector(6, -8.7, 2)
SWEP.vbwAng = Angle(0, 5, -90)
SWEP.addPos = Vector(0, 0, 0)
SWEP.addAng = Angle(0, 0, 0)

SWEP.SightPos = Vector(-34, 1.65, -0.15)