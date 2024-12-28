if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "ИЖ-43"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Неебически длинное ружье с калибром 12/70. С таким и на FurryCon пойти не стыдно."
SWEP.Category 				= "Оружие 2"
SWEP.WepSelectIcon			= "pwb2/vgui/weapons/m4super90"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "12/70 gauge"
SWEP.Primary.Cone = 0.02
SWEP.Primary.Damage = 45
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/tfa_ins2/doublebarrel_sawnoff/doublebarrelsawn_fire.wav"
SWEP.Primary.Force = 35
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.1
SWEP.NumBullet = 16
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

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 2
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/tfa_ins2/w_doublebarrel.mdl"
SWEP.WorldModel				= "models/weapons/tfa_ins2/w_doublebarrel.mdl"

SWEP.vbwPos = Vector(-2,-4.7,4)
SWEP.vbwAng = Angle(2.5,-30,0)

SWEP.addAng = Angle(0,0,0)
SWEP.addPos = Vector(0,47,7) -- shamanskie to4ki

SWEP.dwmModeScale = 1
SWEP.dwmForward = 3
SWEP.dwmRight = 0.3
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = -15
SWEP.dwmAForward = 180

function SWEP:ApplyEyeSpray()
    self.eyeSpray = self.eyeSpray - Angle(4,math.Rand(-1.5,1.5),0)
end 

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
