SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.fiveseven.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.fiveseven.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/fivesevenicon.png"
end

SWEP.WepSelectIcon = "entities/weapon_insurgencymakarov.png"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "5.7x28 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 10
SWEP.RubberBullets = false
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb2/weapons/fiveseven/fire.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_smp_far.wav"
SWEP.Primary.Force = 0.1
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

SWEP.ViewModel = "models/pwb2/weapons/w_fiveseven.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_fiveseven.mdl"

SWEP.vbwPos = Vector(8, 0, -6)
SWEP.addPos = Vector(-1, -1, -0.7)
SWEP.addAng = Angle(0.4, 0, 0)

SWEP.SightPos = Vector(-20, 0.4, -0.55)