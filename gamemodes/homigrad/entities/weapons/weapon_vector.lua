SWEP.Base = "salat_base"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.vector.name")
	SWEP.Author = "Homigrad"
	SWEP.Instructions = language.GetPhrase("hg.vector.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
	SWEP.IconOverride = "materials/items_icons/vectoricon.png"
end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 33
SWEP.Primary.DefaultClip = 33
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb2/weapons/vectorsmg/fire1.wav"
SWEP.Primary.Force = 240 / 3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.03
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.TwoHands = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "smg"

SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/pwb2/weapons/w_vectorsmg.mdl"
SWEP.WorldModel = "models/pwb2/weapons/w_vectorsmg.mdl"

SWEP.addAng = Angle(-0.1, 0, 0.8)
SWEP.addPos = Vector(0, 4, -0.7)
SWEP.vbwPos = Vector(2.5, -5.3, -2)
SWEP.vbwAng = Angle(15, 10, 0)

SWEP.SightPos = Vector(-22, 4, -0.25)