SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.asval.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.asval.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/asvalicon.png"
end

SWEP.WepSelectIcon = "pwb2/vgui/weapons/asval"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 45
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb2/weapons/asval/ak47-1.wav"
-- SWEP.Primary.SoundFar = "mp5k/mp5k_suppressed_tp.wav"
SWEP.Primary.Force = 200 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.065
SWEP.ReloadSound = "pwb2/weapons/deserteagle/reload.wav"
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

SWEP.ViewModel = "models/pwb2/weapons/w_asval.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_asval.mdl"

SWEP.addAng = Angle(0, 0, 0)
SWEP.addPos = Vector(0, 0, 0)

SWEP.Supressed = true

SWEP.SightPos = Vector(-32, 1.8, -0.45)