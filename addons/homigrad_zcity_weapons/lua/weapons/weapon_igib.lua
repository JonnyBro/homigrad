if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "InstaGib Grenade Launcher"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Выпускает 40мм заряды. Может и вас убить на раз-два."
SWEP.Category 				= "Оружие 2"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= 6666
SWEP.Primary.DefaultClip	= 6666
SWEP.Primary.Ammo = "RPG_Round"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.TwoHands = true
SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "smg"

SWEP.Slot					= 0
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/w_jmod_milkormgl.mdl"
SWEP.WorldModel				= "models/weapons/w_jmod_milkormgl.mdl"

SWEP.ShootWait = 0.333

SWEP.Automatic = false
SWEP.vbwPos = Vector(14,5,-7)
SWEP.vbwAng = Angle(60,0,90)
SWEP.ThrowVel = 1500
function SWEP:PrimaryAttack()
    self.ShootNext=self.NextShot or NextShot
    if ( self.NextShot > CurTime() ) then return end
    if self:Clip1() <= 0 then return end
    self.NextShot = CurTime() + self.ShootWait
    local shotpos = self:GetOwner():GetPos()+Vector(0,0,35)+self:GetOwner():EyeAngles():Forward()*90+self:GetOwner():EyeAngles():Right()*5
    if SERVER then 
        local cmm = ents.Create( "ent_hgjack_40mm_contact" )
        cmm:SetPos(shotpos)
        cmm:SetAngles(self:GetOwner():EyeAngles()+Angle(0,0,0))
        cmm:Spawn()
        cmm:Arm()
        local cmm2 = cmm:GetPhysicsObject()
		if IsValid(cmm2) then
			cmm2:SetVelocity(self:GetOwner():GetAimVector() * self.ThrowVel/2 + (self:GetOwner():GetVelocity() * 0.75))
		end
    end
    --self:TakePrimaryAmmo(1)
end
--models/weapons/insurgency/w_rpg7.mdl
--models/weapons/insurgency/w_rpg7_projectile.mdl
end