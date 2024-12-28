

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "DC-17m Anti-Armor"			
	SWEP.Author				= "Ce1azz"
	SWEP.ViewModelFOV      	= 50
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.WepSelectIcon 		= surface.GetTextureID("HUD/killicons/DC17M_AT")
	
	killicon.Add( "weapon_752_dc17m_at", "HUD/killicons/DC17M_AT", Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType				= "rpg"
SWEP.Base					= "weapon_swsft_base"
SWEP.Category				= "Star Wars"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.ViewModel				= "models/weapons/v_DC17M_AT.mdl"
SWEP.WorldModel				= "models/weapons/w_DC17M_AT.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

local FireSound 			= Sound ("weapons/DC17M_AT_fire.wav");
local ReloadSound			= Sound ("weapons/DC17M_AT_reload.wav");

SWEP.Primary.Recoil			= 10
SWEP.Primary.Damage			= 200
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.15
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Delay			= 1
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "rpg_round"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 			= Vector (-1, -6, 0.3)

/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()
	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end
	self:SetWeaponHoldType( self.HoldType )
	self.Weapon:SetNetworkedBool( "Ironsights", false )
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:EmitSound( FireSound )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:FireRocket( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	self:TakePrimaryAmmo( 1 )
	if ( self.Owner:IsNPC() ) then return end
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
end

function SWEP:FireRocket()
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = self.Owner:GetShootPos() +  aim * 24 + side * 1 + up * -2	--offsets the rocket so it spawns from the muzzle (hopefully)
	local rocket = ents.Create("dc17m_at_rocket")
		if !rocket:IsValid() then return false end
		rocket:SetAngles(aim:Angle())
		rocket:SetPos(pos)
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket:Activate()
	rocket:SetVelocity(rocket:GetForward()*-500)
end

function SWEP:Think()
	if self.Weapon:Clip1() > 0 then
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE_DEPLOYED)
	end
end

function SWEP:Reload()
	if (self.Weapon:Clip1() < self.Primary.ClipSize) then
		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			self.Weapon:EmitSound( ReloadSound )
		end
		self.Weapon:DefaultReload( ACT_VM_RELOAD );
		--self:SetIronsights( false )
	end
end
