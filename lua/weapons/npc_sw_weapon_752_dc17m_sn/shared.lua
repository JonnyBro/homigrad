

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "NPC_DC-17m Sniper Rifle"			
	SWEP.Author				= "Syntax_Error752"
	SWEP.ViewModelFOV      	= 40
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.WepSelectIcon = surface.GetTextureID("HUD/killicons/DC17M_SN")
	
	killicon.Add( "npc_sw_weapon_752_dc17m_sn", "HUD/killicons/DC17M_SN", Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType				= "ar2"
SWEP.Base					= "weapon_swsft_base"

SWEP.Category				= "Star Wars"

SWEP.Spawnable				= false
SWEP.AdminSpawnable			= false

SWEP.ViewModel				= ""
SWEP.WorldModel				= "models/weapons/w_DC17M_SN.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

local FireSound 			= Sound ("weapons/DC17M_SN_fire.wav");
local ReloadSound			= Sound ("weapons/DC17M_SN_reload.wav");

SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0 --0.00625
SWEP.Primary.ClipSize		= 5
SWEP.Primary.Delay			= 1
SWEP.Primary.DefaultClip	= 15
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Tracer 		= "effect_sw_laser_blue"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 			= Vector (-4.715, -25, -0.65)

function SWEP:PrimaryAttack()

	if self:Clip1() <= 0 then self:NpcReload()
	return end 

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( FireSound )
	
	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			// Aim Cone
	bullet.Tracer	= 1								// Show a tracer on every x bullets 
	bullet.TracerName 	= self.Primary.Tracer
	bullet.Force	= 5									// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	self.Owner:FireBullets( bullet )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (game.SinglePlayer() && SERVER) || ( !game.SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )
	
	end

end

function SWEP:Reload()
		self.Weapon:DefaultReload( ACT_VM_RELOAD );
		self:SetIronsights( false )
end

function SWEP:Think()	
	local ClipPercentage = ((100/self.Primary.ClipSize)*self.Weapon:Clip1());
	
	if (ClipPercentage < 1) then
		self.Owner:GetViewModel():SetSkin( 5 )
		return
	end
	if (ClipPercentage < 21) then
		self.Owner:GetViewModel():SetSkin( 4 )
		return
	end
	if (ClipPercentage < 41) then
		self.Owner:GetViewModel():SetSkin( 3 )
		return
	end
	if (ClipPercentage < 61) then
		self.Owner:GetViewModel():SetSkin( 2 )
		return
	end
	if (ClipPercentage < 81) then
		self.Owner:GetViewModel():SetSkin( 1 )
		return
	end
	if (ClipPercentage < 101) then
		self.Owner:GetViewModel():SetSkin( 0 )
	end
end

Zoom = 0;
function SWEP:SecondaryAttack()

	if ( self.NextSecondaryAttack > CurTime() ) then return end
	
	if (Zoom == 0) then
		if (SERVER) then
			self.Owner:SetFOV( 40, 0.3 )
		end 
		
		bIronsights = !self.Weapon:GetNetworkedBool( "Ironsights", false )
		self:SetIronsights( bIronsights )
		Zoom = 1
		self.NextSecondaryAttack = CurTime() + 0.3
		return
	end
	if (Zoom == 1) then
		if (SERVER) then
			self.Owner:SetFOV( 0, 0.3 )
		end
		Zoom = 0
		self:SetIronsights( false )
		self.NextSecondaryAttack = CurTime() + 0.3
		return
	end
end

function SWEP:Holster() 
	if (SERVER) then
		self.Owner:SetFOV( 0, 0.3 )
	end
	Zoom = 0
	self:SetIronsights( false )
	return true
end