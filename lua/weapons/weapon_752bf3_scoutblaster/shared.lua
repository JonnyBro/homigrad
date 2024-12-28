

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "Scout Blaster"			
	SWEP.Author				= "Syntax_Error752"
	SWEP.ViewModelFOV      	= 70
	SWEP.Slot				= 1
	SWEP.SlotPos			= 5
	SWEP.WepSelectIcon = surface.GetTextureID("HUD/killicons/SCOUTBLASTER")
	
	killicon.Add( "weapon_752bf3_scoutblaster", "HUD/killicons/SCOUTBLASTER", Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType				= "pistol"
SWEP.Base					= "weapon_swsft_base"

SWEP.Category				= "Star Wars"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/synbf3/v_scoutblaster.mdl"
SWEP.WorldModel				= "models/weapons/synbf3/w_scoutblaster.mdl"

local FireSound 			= Sound ("weapons/synbf3/SCOUTBLASTER_fire.wav");
local ReloadSound			= Sound ("weapons/synbf3/SCOUTBLASTER_reload.wav");

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.Recoil			= 0.5
SWEP.Primary.Damage			= 50
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0125
SWEP.Primary.ClipSize		= 25
SWEP.Primary.Delay			= 0.2
SWEP.Primary.DefaultClip	= 75
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Tracer 		= "effect_sw_laser_red"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:PrimaryAttack()

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
	if (self.Weapon:Clip1() < self.Primary.ClipSize) then
		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			self.Weapon:EmitSound( ReloadSound )
		end
		self.Weapon:DefaultReload( ACT_VM_RELOAD_EMPTY );
		self:SetIronsights( false )
		if self:GetNWBool("Scoped") then
			self.Weapon:SetNWBool("Scoped", false)
			self.Owner:GetViewModel():SetNoDraw(false)
			self.Owner:SetFOV( 0, 0.25 )	
		end
	end
end

function SWEP:SecondaryAttack()
	if self:GetNWBool("Scoped") then
		self.Weapon:SetNWBool("Scoped", false)
		self.Owner:GetViewModel():SetNoDraw(false)
		self.Owner:SetFOV( 0, 0.25 )
		self:AdjustMouseSensitivity()
	elseif not self:GetNWBool("Scoped") then
		self.Weapon:SetNWBool("Scoped", true)
		self.Owner:GetViewModel():SetNoDraw(true)
		self.Owner:SetFOV( 40, 0.25 )
		self:AdjustMouseSensitivity()
	end
end

function SWEP:AdjustMouseSensitivity()
	if self:GetNWBool("Scoped") then
		return 0.5
	else if not self:GetNWBool("Scoped") then
		return -1
	end
end
end

function SWEP:DrawHUD()
	if (CLIENT) then
		if not self:GetNWBool("Scoped") then
			
			local x, y
			if ( self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer() ) then

				local tr = util.GetPlayerTrace( self.Owner )
//				tr.mask = ( CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_GRATE|CONTENTS_AUX )
				local trace = util.TraceLine( tr )
				
				local coords = trace.HitPos:ToScreen()
				x, y = coords.x, coords.y
				
			else
				x, y = ScrW() / 2.0, ScrH() / 2.0
			end
	
			local scale = 10 * self.Primary.Cone
	
			local LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
			scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))
			
			surface.SetDrawColor( 255, 0, 0, 255 )
			
			local gap = 40 * scale
			local length = gap + 20 * scale
			surface.DrawLine( x - length, y, x - gap, y )
			surface.DrawLine( x + length, y, x + gap, y )
			surface.DrawLine( x, y - length, x, y - gap )
			surface.DrawLine( x, y + length, x, y + gap )
			return;
		end
		
		local Scale = ScrH()/480
		local w, h = 320*Scale, 240*Scale
		local cx, cy = ScrW()/2, ScrH()/2
		local scope_sniper_lr = surface.GetTextureID("sprites/scopes/752/scope_synbf3_lr")
		local scope_sniper_ll = surface.GetTextureID("sprites/scopes/752/scope_synbf3_ll")
		local scope_sniper_ul = surface.GetTextureID("sprites/scopes/752/scope_synbf3_ul")
		local scope_sniper_ur = surface.GetTextureID("sprites/scopes/752/scope_synbf3_ur")
		local SNIPERSCOPE_MIN = -0.75
		local SNIPERSCOPE_MAX = -2.782
		local SNIPERSCOPE_SCALE = 0.4
		local x = ScrW() / 2.0
		local y = ScrH() / 2.0
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		local gap = 0
		local length = gap + 9999
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawLine( x - length, y, x - gap, y )
		surface.DrawLine( x + length, y, x + gap, y )
		surface.DrawLine( x, y - length, x, y - gap )
		surface.DrawLine( x, y + length, x, y + gap )
		render.UpdateRefractTexture()
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetTexture(scope_sniper_lr)
		surface.DrawTexturedRect(cx, cy, w, h)
		surface.SetTexture(scope_sniper_ll)
		surface.DrawTexturedRect(cx-w, cy, w, h)
		surface.SetTexture(scope_sniper_ul)
		surface.DrawTexturedRect(cx-w, cy-h, w, h)
		surface.SetTexture(scope_sniper_ur)
		surface.DrawTexturedRect(cx, cy-h, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		if cx-w > 0 then
			surface.DrawRect(0, 0, cx-w, ScrH())
			surface.DrawRect(cx+w, 0, cx-w, ScrH())
		end
	end
end
