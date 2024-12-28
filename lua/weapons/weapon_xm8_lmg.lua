if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "XM8 LMG"
SWEP.Author 				= "Niik"
SWEP.Instructions			= "Автоматика под калибр 5,56x45"
SWEP.Category 				= "Оружие 2"
SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "pwb2/weapons/xm8lmg/m249-1.wav"
SWEP.Primary.Force = 240/3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.085
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.TwoHands = true
SWEP.Supressed = true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "ar2"

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/pwb2/weapons/w_xm8lmg.mdl"
SWEP.WorldModel				= "models/pwb2/weapons/w_xm8lmg.mdl"

SWEP.addAng = Angle(0.3,-0.25,0)
SWEP.addPos = Vector(0,4,-0.7)
SWEP.vbwPos = Vector(1.5,-7.1,0)
SWEP.vbwAng = Angle(15,10,-90)

--DO NOT APPLY 3D CROSSHAIRS ON GUNS WITH TRANSPARENT GLASS. BROKEN AF.
/*----------------------------------------- this is so fucking broken.
SWEP.sightPos = Vector(0, 0, 0)
SWEP.sightAng = Angle(0, 0, 0)
SWEP.fakeHandRight = Vector(12, -1, 2)
SWEP.fakeHandLeft = Vector(13, -3, -4)
-----------------------------------------
SWEP.Sight = true
SWEP.DrawScope = true
SWEP.ScopeAdjustAng = Angle(0, 0, -180)
SWEP.ScopeAdjustPos = Vector(-5, 0, 160)
SWEP.ScopeFov = 10
SWEP.ScopeMat = Material("decals/awp.png")
SWEP.ScopeRot = 0
SWEP.UVAdjust = {0, 0} -- позиция прицельной сетки
SWEP.UVScale = {1.2, 1.2} -- размер прицельной сетки
-----------------------------------------
function SWEP:Initialize()
    if CLIENT and LocalPlayer() then
        --self:SetHoldType(self.HoldType)
	    self.ZazhimYaycami = math.min(15,self.Primary.ClipSize)
        self.rtmat = GetRenderTarget("fuck-glass", 512, 512, false)
        self.mat = Material("pwb2/models/weapons/w_xm8lmg/lens")
        self.mat:SetTexture("$basetexture", self.rtmat)
        local texture_matrix = self.mat:GetMatrix("$basetexturetransform")
        texture_matrix:SetAngles(Angle(0, 0, 0))
        self.mat:SetMatrix("$basetexturetransform", texture_matrix)
    end
end

/*function SWEP:AdjustMouseSensitivity()
    if self:GetOwner():KeyDown(IN_ATTACK2) then return 0.3 end
    return 1
end
SWEP.Recoil = 4*/
end