if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'salat_base' -- base 

SWEP.PrintName 				= "M590"
SWEP.Instructions			= ""
SWEP.Category 				= "Оружие"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "12/70 gauge"
SWEP.Primary.Cone = 0.05
SWEP.Primary.Damage = 35
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb2/weapons/ithaca37stakeout/fire.wav"
--SWEP.Primary.SoundFar = "weapons/mini14/mini14_dist.wav"
SWEP.Primary.Force = 25
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.5
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.NumBullet = 8
SWEP.Sight = true
SWEP.TwoHands = true
							
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "ar2"
SWEP.Shotgun = true

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/pwb/weapons/w_m590a1.mdl"
SWEP.WorldModel				= "models/pwb/weapons/w_m590a1.mdl"

function SWEP:ApplyEyeSpray()
    self.eyeSpray = self.eyeSpray - Angle(5,math.Rand(-2,2),0)
end

SWEP.vbwPos = Vector(4,-3.2,-6)
SWEP.vbwAng = Angle(7.5,-30,0)

SWEP.addAng = Angle(2.3,0.15,0)
SWEP.addPos = Vector(0,0,0)

SWEP.CLR_Scope = 0.05
SWEP.CLR = 0.025
end