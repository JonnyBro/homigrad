SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.beanbag.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.beanbag.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/beanbagicon.png"
end

SWEP.WepSelectIcon = "entities/weapon_insurgencymakarov.png" -- ??
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 beanbag"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 10
SWEP.RubberBullets = true
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "toz_shotgun/toz_fp.wav"
SWEP.Primary.SoundFar = "toz_shotgun/toz_dist.wav"
SWEP.Primary.Force = 0.5
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.7
SWEP.TwoHands = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "ar2"
SWEP.shotgun = true

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb2/weapons/w_remington870police.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_remington870police.mdl"

SWEP.vbwPos = Vector(-8, -6, -6)

SWEP.addAng = Angle(0.1, 0, 2)
SWEP.addPos = Vector(0, 0, 0)

SWEP.SightPos = Vector(-40, 1.95, -0.6)