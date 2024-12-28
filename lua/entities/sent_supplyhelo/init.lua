// Send required files to client.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")


// Include needed files.
include("shared.lua")

function ENT:SetCrateContents( contents )
  self.crateContents = contents
end

function ENT:DropCrate( )
	local angles = self.fakeCrate:GetAngles( )
	self.fakeCrate:Remove( )

	local crate = ents.Create( "sent_airdropcrate" )
	//Position and angles are relative to our future parent.
	local angle, position = Angle( 0, 0, 0 ), Vector( 0, 0, 15 )
	crate:SetPos( self:LocalToWorld( position ) )
	crate:SetAngles( self:LocalToWorldAngles( angle ) )
	crate:Spawn( )
	constraint.NoCollide( self, crate, 0, 0 )
	crate:GetPhysicsObject( ):SetVelocityInstantaneous( self:GetPhysicsObject( ):GetVelocity( ) )
  crate:SetContents( self.crateContents )
end


function ENT:SetSpot( spot )
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

	local start, finish = tr1.HitPos, tr2.HitPos
  self:SetStartVec( start )
  self:SetEndVec( finish )
  self:SetAboveCratePos( heloPos )

  print( self:GetStartVec( ) )
	self:SetPos( self:GetStartVec( ) )

	local ang = ( finish - start ):Angle()
	ang.p = 9
	self:SetAngles( ang )

	self.target = heloPos
	self.targetAngle = 30

	if IsValid( self:GetPhysicsObject( ) ) then
		self:GetPhysicsObject( ):SetVelocityInstantaneous( ( finish - start ):GetNormalized( ) * 8000 )
		self:GetPhysicsObject( ):ApplyForceCenter( ( finish - start ):GetNormalized( ) * 8000 * self:GetPhysicsObject( ):GetMass( ) )
	end
  self:StartMotionController( )
end
