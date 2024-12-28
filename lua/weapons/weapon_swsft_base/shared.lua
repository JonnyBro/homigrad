
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.BounceWeaponIcon = false

end

SWEP.Author			= "Ce1azz"
SWEP.Contact		= ""
SWEP.Purpose		= "Бластер из далёкой-далёкой Галактики"
SWEP.Instructions	= ""

//SWEP.Category			= "Star Wars"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Recoil			= 0.5
SWEP.Primary.Damage			= 50
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0125
SWEP.Primary.Delay			= 0.175

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Tracer 		= "effect_sw_laser_red"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"






/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end
    self:SetHoldType(self.HoldType)
	self.Weapon:SetNetworkedBool( "Ironsights", false ) 
end


function SWEP:Think()	
end

/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
//function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
	//draw.SimpleText( self.IconLetter, "DODSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	
	// try to fool them into thinking they're playing a Tony Hawks game
	//draw.SimpleText( self.IconLetter, "DODSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-14, 14), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	//draw.SimpleText( self.IconLetter, "DODSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-9, 9), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	
//end

--[[local IRONSIGHT_TIME = 0.25

/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------*/
--[[function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0

	if ( !bIron && fIronTime < CurTime() - IRONSIGHT_TIME ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then
	
		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )
		
		if (!bIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.IronSightsPos
	
	if ( self.IronSightsAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
	
end

/*---------------------------------------------------------
	SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights( b )

	self.Weapon:SetNetworkedBool( "Ironsights", b )

end


SWEP.NextSecondaryAttack = 0
/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
--[[function SWEP:SecondaryAttack()

	if ( !self.IronSightsPos ) then return end
	if ( self.NextSecondaryAttack > CurTime() ) then return end
	
	bIronsights = !self.Weapon:GetNetworkedBool( "Ironsights", false )
	
	self:SetIronsights( bIronsights )
	
	self.NextSecondaryAttack = CurTime() + 0.3
	
end

/*---------------------------------------------------------
	DrawHUD
	
	Just a rough mock up showing how to draw your own crosshair.
	
---------------------------------------------------------*/

--[[function SWEP:DrawHUD()

	// No crosshair when ironsights is on
	if ( self.Weapon:GetNetworkedBool( "Ironsights" ) ) then return end

	local x, y

	// If we're drawing the local player, draw the crosshair where they're aiming,
	// instead of in the center of the screen.
	if ( self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer() ) then

		local tr = util.GetPlayerTrace( self.Owner )
//		tr.mask = ( CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_GRATE|CONTENTS_AUX )
		local trace = util.TraceLine( tr )
		
		local coords = trace.HitPos:ToScreen()
		x, y = coords.x, coords.y

	else
		x, y = ScrW() / 2.0, ScrH() / 2.0
	end
	
	local scale = 10 * self.Primary.Cone
	
	// Scale the size of the crosshair according to how long ago we fired our weapon
	local LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))
	
	surface.SetDrawColor( 255, 0, 0, 255 )
	
	// Draw an awesome crosshair
	local gap = 40 * scale
	local length = gap + 20 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )

end]]


--[[/*---------------------------------------------------------
	onRestore
	Loaded a saved game (or changelevel)
---------------------------------------------------------*/
function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	self:SetIronsights( false )
	
end]]

function SWEP:DoImpactEffect( tr, dmgtype )
	if( tr.HitSky ) then return true; end
	
	util.Decal( "fadingscorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal );
	
	if( game.SinglePlayer() or SERVER or not self:IsCarriedByLocalPlayer() or IsFirstTimePredicted() ) then
		local soundToPlay = "effects/sw_impact/sw752_hit_24.wav"
		local randomSound = math.random(1,24)
		if randomSound == 1 then
			soundToPlay = "effects/sw_impact/sw752_hit_01.wav"
		elseif randomSound == 2 then
			soundToPlay = "effects/sw_impact/sw752_hit_02.wav"
		elseif randomSound == 3 then
			soundToPlay = "effects/sw_impact/sw752_hit_03.wav"
		elseif randomSound == 4 then
			soundToPlay = "effects/sw_impact/sw752_hit_04.wav"
		elseif randomSound == 5 then
			soundToPlay = "effects/sw_impact/sw752_hit_05.wav"
		elseif randomSound == 6 then
			soundToPlay = "effects/sw_impact/sw752_hit_06.wav"
		elseif randomSound == 7 then
			soundToPlay = "effects/sw_impact/sw752_hit_07.wav"
		elseif randomSound == 8 then
			soundToPlay = "effects/sw_impact/sw752_hit_08.wav"
		elseif randomSound == 9 then
			soundToPlay = "effects/sw_impact/sw752_hit_09.wav"
		elseif randomSound == 10 then
			soundToPlay = "effects/sw_impact/sw752_hit_10.wav"
		elseif randomSound == 11 then
			soundToPlay = "effects/sw_impact/sw752_hit_11.wav"
		elseif randomSound == 12 then
			soundToPlay = "effects/sw_impact/sw752_hit_12.wav"
		elseif randomSound == 13 then
			soundToPlay = "effects/sw_impact/sw752_hit_13.wav"
		elseif randomSound == 14 then
			soundToPlay = "effects/sw_impact/sw752_hit_14.wav"
		elseif randomSound == 15 then
			soundToPlay = "effects/sw_impact/sw752_hit_15.wav"
		elseif randomSound == 16 then
			soundToPlay = "effects/sw_impact/sw752_hit_16.wav"
		elseif randomSound == 17 then
			soundToPlay = "effects/sw_impact/sw752_hit_17.wav"
		elseif randomSound == 18 then
			soundToPlay = "effects/sw_impact/sw752_hit_18.wav"
		elseif randomSound == 19 then
			soundToPlay = "effects/sw_impact/sw752_hit_19.wav"
		elseif randomSound == 20 then
			soundToPlay = "effects/sw_impact/sw752_hit_20.wav"
		elseif randomSound == 21 then
			soundToPlay = "effects/sw_impact/sw752_hit_21.wav"
		elseif randomSound == 22 then
			soundToPlay = "effects/sw_impact/sw752_hit_22.wav"
		elseif randomSound == 23 then
			soundToPlay = "effects/sw_impact/sw752_hit_23.wav"
		elseif randomSound == 24 then
			soundToPlay = "effects/sw_impact/sw752_hit_24.wav"
		end
		
		local effect = EffectData();
		effect:SetOrigin( tr.HitPos );
		effect:SetNormal( tr.HitNormal );

		util.Effect( "effect_sw_impact_2", effect );
		sound.Play( soundToPlay, tr.HitPos, 75, 100, 1 );

		local effect = EffectData();
		effect:SetOrigin( tr.HitPos );
		effect:SetStart( tr.StartPos );
		effect:SetDamageType( dmgtype );

		util.Effect( "RagdollImpact", effect );
	end

    return true;
end
