if CLIENT then
SWEP.WepSelectIcon = surface.GetTextureID( "vgui/hud/weapon_insurgencygurkha" )
SWEP.DrawWeaponInfoBox	= false
SWEP.BounceWeaponIcon = false 
killicon.Add( "weapon_insurgencygurkha", "vgui/hud/weapon_insurgencygurkha", Color( 0, 0, 0, 255 ) )
end

SWEP.PrintName = "Gurkha"

SWEP.Category = "Ближний Бой"

SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/insurgency/v_gurkha.mdl"
SWEP.WorldModel = "models/weapons/insurgency/w_gurkha.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 0
 
SWEP.UseHands = true

SWEP.HoldType = "knife" 

SWEP.FiresUnderwater = false

SWEP.DrawCrosshair = false

SWEP.DrawAmmo = true

SWEP.Base = "weapon_base"

SWEP.CSMuzzleFlashes = true

SWEP.Vehicle = 0
SWEP.Sprint = 0

SWEP.Primary.Sound = Sound( "Weapon_Knife.Single" )
SWEP.Primary.Damage = 60
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.9
SWEP.Primary.Force = 1500

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
self:SetWeaponHoldType( self.HoldType )
end 

function SWEP:DrawModels()
if CLIENT then
if GetConVar( "hands_model" ):GetInt() == 1 then
self.Hands = ClientsideModel( "models/weapons/insurgency/v_hands_ins_h.mdl", RENDERGROUP_VIEWMODEL )
local vm = self.Owner:GetViewModel()
self.Hands:SetPos( vm:GetPos() )
self.Hands:SetAngles( vm:GetAngles() )
self.Hands:AddEffects( EF_BONEMERGE )
self.Hands:SetNoDraw( true )
self.Hands:SetParent( vm )
self.Hands:DrawModel()
end
if GetConVar( "hands_model" ):GetInt() == 2 then
self.Hands = ClientsideModel( "models/weapons/insurgency/v_hands_ins_l.mdl", RENDERGROUP_VIEWMODEL )
local vm = self.Owner:GetViewModel()
self.Hands:SetPos( vm:GetPos() )
self.Hands:SetAngles( vm:GetAngles() )
self.Hands:AddEffects( EF_BONEMERGE )
self.Hands:SetNoDraw( true )
self.Hands:SetParent( vm )
self.Hands:DrawModel()
end
if GetConVar( "hands_model" ):GetInt() == 3 then
self.Hands = ClientsideModel( "models/weapons/insurgency/v_hands_ins_m.mdl", RENDERGROUP_VIEWMODEL )
local vm = self.Owner:GetViewModel()
self.Hands:SetPos( vm:GetPos() )
self.Hands:SetAngles( vm:GetAngles() )
self.Hands:AddEffects( EF_BONEMERGE )
self.Hands:SetNoDraw( true )
self.Hands:SetParent( vm )
self.Hands:DrawModel()
end
if GetConVar( "hands_model" ):GetInt() == 4 then
self.Hands = ClientsideModel( "models/weapons/insurgency/v_hands_sec_h.mdl", RENDERGROUP_VIEWMODEL )
local vm = self.Owner:GetViewModel()
self.Hands:SetPos( vm:GetPos() )
self.Hands:SetAngles( vm:GetAngles() )
self.Hands:AddEffects( EF_BONEMERGE )
self.Hands:SetNoDraw( true )
self.Hands:SetParent( vm )
self.Hands:DrawModel()
end
if GetConVar( "hands_model" ):GetInt() == 5 then
self.Hands = ClientsideModel( "models/weapons/insurgency/v_hands_sec_l.mdl", RENDERGROUP_VIEWMODEL )
local vm = self.Owner:GetViewModel()
self.Hands:SetPos( vm:GetPos() )
self.Hands:SetAngles( vm:GetAngles() )
self.Hands:AddEffects( EF_BONEMERGE )
self.Hands:SetNoDraw( true )
self.Hands:SetParent( vm )
self.Hands:DrawModel()
end
if GetConVar( "hands_model" ):GetInt() == 6 then
self.Hands = ClientsideModel( "models/weapons/insurgency/v_hands_sec_m.mdl", RENDERGROUP_VIEWMODEL )
local vm = self.Owner:GetViewModel()
self.Hands:SetPos( vm:GetPos() )
self.Hands:SetAngles( vm:GetAngles() )
self.Hands:AddEffects( EF_BONEMERGE )
self.Hands:SetNoDraw( true )
self.Hands:SetParent( vm )
self.Hands:DrawModel()
end
if GetConVar( "hands_model" ):GetInt() == 7 then
self.Hands = ClientsideModel( "models/weapons/insurgency/v_hands_vip.mdl", RENDERGROUP_VIEWMODEL )
local vm = self.Owner:GetViewModel()
self.Hands:SetPos( vm:GetPos() )
self.Hands:SetAngles( vm:GetAngles() )
self.Hands:AddEffects( EF_BONEMERGE )
self.Hands:SetNoDraw( true )
self.Hands:SetParent( vm )
self.Hands:DrawModel()
end
end
end

function SWEP:ViewModelDrawn()
if CLIENT then
if not( self.Hands ) then
self:DrawModels()
end
if self.Hands then
self.Hands:DrawModel()
end
end
end

function SWEP:Deploy()
self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
local vm = self.Owner:GetViewModel()
vm:SendViewModelMatchingSequence( vm:LookupSequence( "draw" ) )
self.Vehicle = 1
self.Sprint = 0
end

function SWEP:Holster()
self.Vehicle = 1
self.Sprint = 0
return true
end

function SWEP:PrimaryAttack()
if not( self.Sprint == 0 ) then return end

self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
self.Owner:ViewPunch( Angle( math.random( -1, 1 ) * self.Primary.Recoil, math.Rand( -1, 1 ) *self.Primary.Recoil, 0 ) )
self.Owner:SetAnimation( PLAYER_ATTACK1 )
self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

timer.Simple( 0.2, function()
if SERVER then
self.Owner:EmitSound( "Weapon_Crowbar.Single" )
end
local tr = self.Owner:GetEyeTrace()
local pos1 = tr.HitPos + tr.HitNormal
local pos2 = tr.HitPos - tr.HitNormal
if ( tr.HitPos - self.Owner:GetShootPos() ):Length() < 75 then
util.Decal( "ManhackCut", pos1, pos2 )
if IsValid( tr.Entity ) and SERVER then
local dmginfo = DamageInfo()
dmginfo:SetDamageType( DMG_CLUB )
dmginfo:SetAttacker( self.Owner )
dmginfo:SetInflictor( self )
local angle = self.Owner:GetAngles().y - tr.Entity:GetAngles().y
if angle < -180 then angle = 360 + angle end
if angle <= 90 and angle >= -90 then
dmginfo:SetDamage( 200 )
else
dmginfo:SetDamage( self.Primary.Damage )
end
if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
dmginfo:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
else
if IsValid( tr.Entity:GetPhysicsObject() ) then
tr.Entity:GetPhysicsObject():ApplyForceCenter( self.Owner:GetForward() * self.Primary.Force )
end
end
tr.Entity:TakeDamageInfo( dmginfo )
end
if SERVER then
self.Owner:EmitSound( Sound( "Weapon_Knife.Single" ) )
end
end
end)
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Think()
if self.Owner:InVehicle() and self.Vehicle == 0 then
self.Vehicle = 1
end
if not( self.Owner:InVehicle() ) and self.Vehicle == 1 then
self.Vehicle = 0
self:DrawModels()
end
if self.Sprint == 0 then
if self.Owner:KeyDown( IN_SPEED ) and ( self.Owner:KeyDown( IN_FORWARD ) || self.Owner:KeyDown( IN_BACK ) || self.Owner:KeyDown( IN_MOVELEFT ) || self.Owner:KeyDown( IN_MOVERIGHT ) ) then
self.Sprint = 1
end
end
if self.Sprint == 1 then
local vm = self.Owner:GetViewModel()
vm:SendViewModelMatchingSequence( vm:LookupSequence( "sprint" ) )
self.Sprint = 2
end
if self.Sprint == 2 then
if not( self.Owner:KeyDown( IN_SPEED ) ) then
local vm = self.Owner:GetViewModel()
vm:SendViewModelMatchingSequence( vm:LookupSequence( "idle" ) )
self.Sprint = 0
end
if not( self.Owner:KeyDown( IN_FORWARD ) || self.Owner:KeyDown( IN_BACK ) || self.Owner:KeyDown( IN_MOVELEFT ) || self.Owner:KeyDown( IN_MOVERIGHT ) ) then
local vm = self.Owner:GetViewModel()
vm:SendViewModelMatchingSequence( vm:LookupSequence( "idle" ) )
self.Sprint = 0
end
end
end