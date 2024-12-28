if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "AT-4"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Имеет траекторию полёта. Обращаться максимально неосторожно."
SWEP.Category 				= "Оружие 2"
--SWEP.WepSelectIcon			= "pwb/sprites/m134"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Ammo = "RPG_Round"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.TwoHands = true
SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "rpg"

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/w_jmod_at4.mdl"
SWEP.WorldModel				= "models/weapons/w_jmod_at4.mdl"

SWEP.vbwPos = Vector(14,5,-7)
SWEP.vbwAng = Angle(60,0,90)

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then return end
    local shotpos = self:GetOwner():GetPos()+Vector(0,0,50)+self:GetOwner():EyeAngles():Forward()*90+self:GetOwner():EyeAngles():Right()*5
    if SERVER then 
        local rocket = ents.Create( "gb_rocket_rp3" )
        rocket:SetPos(shotpos)
        rocket:SetAngles(self:GetOwner():EyeAngles()+Angle(-7,0,0))
        rocket:Spawn()
        rocket:Launch()
    end
    self:TakePrimaryAmmo(1)
end
--models/weapons/insurgency/w_rpg7.mdl
--models/weapons/insurgency/w_rpg7_projectile.mdl
end