// Entity information.
ENT.Type = "anim"
ENT.Base = "base_anim"


ENT.PrintName = "Supply Helicopter"
ENT.Author = "Kamshak"
ENT.Information = "Helicopter for airdrops"
ENT.Category = "Fun + Games"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

sound.Add( {
	name = "helicopter_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 120,
	pitch = { 100, 100 },
	sound = "helicopter5.wav"
} )

function ENT:Initialize( )
	self:SetAutomaticFrameAdvance( true )
	self:EmitSound( "helicopter_loop" )
	self:SetModel( "models/supplyhelicopter/supply_helicopter.mdl" )

	// hook.Add( "PreDrawTranslucentRenderables", self, self.PreDrawTranslucentRenderables )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if ( SERVER ) then
		self:PhysicsInit( SOLID_VPHYSICS )
		-- Wake up our physics object so we don't start asleep
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:EnableGravity( false )
			phys:Wake()
		end
  end

	// Add a fake crate
	if SERVER then
		local angle, position = Angle( 0, 0, 0 ), Vector( 0, 0, 15 )

		self.fakeCrate = ents.Create( "prop_physics" )
		//Position and angles are relative to our future parent.
		self.fakeCrate:SetPos( position )
		self.fakeCrate:SetAngles( angle )

		self.fakeCrate:SetMoveParent( self )
		self.fakeCrate:SetModel( "models/care_package/care_package_new.mdl" )

		self.fakeCrate:Spawn()
		self.fakeCrate:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
	end

	self.mode = "flytospot"

	// Enable custom physics
	timer.Simple( 0.01, function( )
		self:StartMotionController( )
	end )
end

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "StartVec" )
	self:NetworkVar( "Vector", 1, "EndVec" )
	self:NetworkVar( "Vector", 2, "AboveCratePos" )
end


local mat = Material( "trails/laser" )
function ENT:PreDrawTranslucentRenderables( )
	local spot = {
		pos = Vector(692.5625, 4210.625, 3.03125),
		ang = Angle(0, 152.65625, 0),
		height = 1047
	}

	local heloPos = spot.pos + Vector( 0, 0, spot.height )
	local tr1 = util.TraceLine( {
		start = heloPos,
		endpos = heloPos + spot.ang:Right() * 1000000,
		mask = MASK_NPCWORLDSTATIC
	} )

	local tr2 = util.TraceLine( {
		start = heloPos,
		endpos = heloPos + spot.ang:Right() * -1000000,
		mask = MASK_NPCWORLDSTATIC
	} )

	render.DrawWireframeSphere( heloPos, 10, 10, 10 )

	render.SetMaterial( mat )
	render.DrawBeam( spot.pos, heloPos, 5, 0, 1 )

	local dir = ( tr1.HitPos - heloPos )
	dir:Normalize( )
	render.DrawBeam( heloPos, tr1.HitPos, 15, 0, 1 )
	local dir2 = ( tr2.HitPos - heloPos )
  dir2:Normalize( )
  render.DrawBeam( heloPos, heloPos + dir2 * 100000 , 15, 0, 1 )
end

function ENT:GetAccelerationToGoal( goal )
	local phys = self:GetPhysicsObject( )

	local deltaPos = goal - self:GetPos( )

	// calc linear acceleration to reach goal position in secs time by solving x(t) = x0 + v0 * d + 1/2 a0 * d^2
	local secs = 1.0
	local linear = 2 * (  deltaPos - phys:GetVelocity( ) * secs ) / secs ^ 2

	// Clamp speed to make helicopter not move too fast/slow
	local speed = math.Clamp( linear:Length( ), 0, 8000 )
	linear = linear:GetNormalized( ) * speed

	return linear
end

function ENT:GetAngularAcceleration( targetAngle )
	local phys = self:GetPhysicsObject( )

	local secs = 0.1
	local angle = 2 * (  math.AngleDifference( targetAngle, self:GetAngles( ).p ) - math.NormalizeAngle( self:GetPhysicsObject( ):GetAngleVelocity( ).y ) * secs ) / secs ^ 2

	--angle = angle - 2 * math.NormalizeAngle( self:GetPhysicsObject( ):GetAngleVelocity( ).y )

	return Vector( 0, angle, 0 )
end

function ENT:PhysicsSimulate( phys, dt )
	linear = self:GetAccelerationToGoal( self.target )
	angular = self:GetAngularAcceleration( self.targetAngle )

	// Simulate drag
	linear = linear + phys:GetVelocity( ) * -0.5

	return angular, linear, SIM_GLOBAL_ACCELERATION
end

function ENT:OnRemove( )
	self:StopSound( "helicopter_loop" )
end

function ENT:Think()
	local ratio = 1
	self.animTime = self.animTime or 0
	if CurTime( ) > self.animTime then
		local sequence = self:LookupSequence( "fly" )
		self:ResetSequence( sequence )
		self:SetPlaybackRate( ratio )
		self:SetCycle( 0 )
		self.animTime = CurTime( ) + self:SequenceDuration( sequence ) / ratio
	end

	self:NextThink( CurTime( ) )

	if self.mode == "flytospot" then
		self.targetAngle = 20 * math.Clamp( ( self:GetVelocity( ):Length( ) - 300 ) / 2000, -1, 1 )
		self.target = self:GetAboveCratePos( )
	end

	if self.mode == "flyaway" and CurTime( ) - self.flyawayStarted > 0.1 then
		self.targetAngle = Lerp( ( ( CurTime( ) - self.flyawayStarted ) * 1.5 ) ^ 2, 0, 25 )
	end

	if self:GetPos( ):Distance( self:GetAboveCratePos( ) ) <= 10 and self.mode == "flytospot" then
		self.mode = "flyaway"
		self.flyawayStarted = CurTime( ) + 0.2
		timer.Simple( 0.2, function( )
			if SERVER then
				self:DropCrate( )
			end
		end )
		timer.Simple( 0.7, function( )
			if not IsValid( self ) then return end
			if not self.GetEndVec then
				self:Remove( ) 
			end
			self.target = self:GetEndVec( ) + ( self:GetEndVec( ) - self:GetStartVec( ) ):GetNormalized( ) * 500 --Set target to far away so helicopter doesnt slow down when flying away
		end )
		timer.Simple( 5, function( )
			if IsValid( self ) then
				self:Remove( )
			end
		end )
	end

	if SERVER and self:GetPos( ):Distance( self:GetEndVec( ) ) <= 100 and self.mode == "flyaway" then
		self:Remove( )
	end

	return true
end
