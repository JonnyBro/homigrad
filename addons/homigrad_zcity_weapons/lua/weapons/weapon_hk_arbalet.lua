if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "Арбалет"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Арбик с болтами"
SWEP.Category 				= "Оружие 2"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= false  
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 255
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/crossbow/bolt_fly4.wav"
SWEP.ReloadSound = "weapons/crossbow/reload1.wav"
SWEP.Primary.Force = 255
SWEP.ReloadTime = 2
SWEP.ShootWait = .03

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
SWEP.SlotPos				= 1
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/w_jmod_crossbow.mdl"
SWEP.WorldModel				= "models/weapons/w_jmod_crossbow.mdl"

SWEP.vbwPos = Vector(0,0,0)

SWEP.Supressed = true

SWEP.dwmModeScale = 0.9
SWEP.dwmForward = 12
SWEP.dwmRight = 0
SWEP.dwmUp = 3

SWEP.dwmAUp = 90
SWEP.dwmARight = 180
SWEP.dwmAForward = 0
SWEP.addAng = Angle( 16, 1, 0 )
SWEP.addPos = Vector(0,0,2)
SWEP.Efect = "PhyscannonImpact"

local model 
if CLIENT then
    model = GDrawWorldModel or ClientsideModel(SWEP.WorldModel,RENDER_GROUP_OPAQUE_ENTITY)
    GDrawWorldModel = model
    model:SetNoDraw(true)
end
if SERVER then
    function SWEP:GetPosAng()
        local owner = self:GetOwner()
        local Pos,Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
        if not Pos then return end
        
        Pos:Add(Ang:Forward() * self.dwmForward)
        Pos:Add(Ang:Right() * self.dwmRight)
        Pos:Add(Ang:Up() * self.dwmUp)


        Ang:RotateAroundAxis(Ang:Up(),self.dwmAUp)
        Ang:RotateAroundAxis(Ang:Right(),self.dwmARight)
        Ang:RotateAroundAxis(Ang:Forward(),self.dwmAForward)

        return Pos,Ang
    end
else
    function SWEP:SetPosAng(Pos,Ang)
        self.Pos = Pos
        self.Ang = Ang
    end
    function SWEP:GetPosAng()
        return self.Pos,self.Ang
    end
end
function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if not IsValid(owner) then
        self:DrawModel()

        return
    end

    model:SetModel(self.WorldModel)

    local Pos,Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
    if not Pos then return end
    
    Pos:Add(Ang:Forward() * self.dwmForward)
    Pos:Add(Ang:Right() * self.dwmRight)
    Pos:Add(Ang:Up() * self.dwmUp)


    Ang:RotateAroundAxis(Ang:Up(),self.dwmAUp)
    Ang:RotateAroundAxis(Ang:Right(),self.dwmARight)
    Ang:RotateAroundAxis(Ang:Forward(),self.dwmAForward)
    
    self:SetPosAng(Pos,Ang)

    model:SetPos(Pos)
    model:SetAngles(Ang)

    model:SetModelScale(self.dwmModeScale)

    model:DrawModel()
end
end