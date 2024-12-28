if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'salat_base' -- base 

SWEP.PrintName 				= "ППШ-41"
SWEP.Author 				= "Ce1azz"
SWEP.Instructions			= "Пистолет-пулемёт под калибр 9х19"
SWEP.Category 				= "Оружие 2"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 35
SWEP.Primary.DefaultClip	= 35
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "9х19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 12
SWEP.Primary.Spread = 5
SWEP.Primary.Sound = "pwb/weapons/uzi/shoot.wav"
SWEP.Primary.SoundFar = "weapons/ump45/ump45_dist.wav"
SWEP.Primary.Force = 320/3
SWEP.Primary.Recoil = 10
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.07
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

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/yotespp/w_smg_ppsh1.mdl"
SWEP.WorldModel				= "models/weapons/w_smg_ppsh.mdl"

SWEP.vbwPos = Vector(4,-3,2)
SWEP.vbwAng = Angle(90,-30,0)

SWEP.addAng = Angle(0,0,0)
end