if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "TMP"
SWEP.Instructions			= ""
SWEP.Category 				= "Оружие"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb/weapons/tmp/shoot.wav"
--SWEP.Primary.SoundFar = "weapons/m14/m14_dist.wav"
SWEP.Primary.Force = 270/3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.06
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.TwoHands = true
SWEP.Supressed = true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "smg"

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/pwb/weapons/w_tmp.mdl"
SWEP.WorldModel				= "models/pwb/weapons/w_tmp.mdl"

SWEP.addAng = Angle( 1.8, 0.9, 0 )
SWEP.addPos = Vector(0,0,0)
SWEP.vbwPos = Vector(12,-1.7,-12)
SWEP.vbwAng = Angle(10,-30,0)
end