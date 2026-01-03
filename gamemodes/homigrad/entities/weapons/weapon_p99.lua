SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.p99.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.p99.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/p99icon.png"
end

SWEP.WepSelectIcon = "pwb/sprites/p99"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb/weapons/p99/shoot.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_smp_far.wav"
SWEP.Primary.Force = 80 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.12

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

SWEP.ViewModel = "models/pwb/weapons/w_p99.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_p99.mdl"

SWEP.dwsPos = Vector(15, 15, 5)
SWEP.dwsItemPos = Vector(10, -1, -3)

SWEP.vbwPos = Vector(8, -9, -8)

SWEP.addAng = Angle(-0.18, 0, 0)
SWEP.addPos = Vector(0.1, 0, -0.9)

SWEP.SightPos = Vector(-20, 0.35, -0.98)