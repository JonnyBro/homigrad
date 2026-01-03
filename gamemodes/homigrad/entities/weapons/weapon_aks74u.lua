SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.aks74u.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.aks74u.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/aksuicon.png"
end

SWEP.WepSelectIcon = "pwb/sprites/aks74u"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.45x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "ak74/ak74_fp.wav"
SWEP.Primary.SoundFar = "ak74/ak74_dist.wav"
SWEP.Primary.Force = 140 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.075
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

SWEP.ViewModel = "models/pwb/weapons/w_aks74u.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_aks74u.mdl"

SWEP.vbwPos = Vector(5, -6, -6)
SWEP.SightPos = Vector(-30, 0.85, -0.24)