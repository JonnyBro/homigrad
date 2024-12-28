ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName		= "Airdrop Marker"
ENT.Author			= "Kamshak"
ENT.Purpose			= "Marks a spot for pointshop2 airdrop via smoke."

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel( "models/weapons/w_eq_smokegrenade_thrown.mdl" )

  math.randomseed( self:EntIndex() * 10 )
  self.color = HSVToColor( math.random() * 360, 1, 1 )

  if SERVER then
  	self.Entity:PhysicsInit( SOLID_VPHYSICS )
    self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
    self.Entity:SetSolid( SOLID_VPHYSICS )

  	self.trail = util.SpriteTrail( self, 0, self.color, false, 15, 1, 4, 0.125, 'trails/smoke.vmt' )

  	local phys = self.Entity:GetPhysicsObject( )
  	if phys:IsValid( ) then
  		phys:Wake( )
  	end
  end

  if CLIENT then
	   self.Emitter = ParticleEmitter(self:GetPos(), false)
  end

  self.Created = CurTime( )
end

function ENT:Explode( )
  self.Exploded = true
  if CLIENT then
    self:EmitSound( "BaseSmokeEffect.Sound" )
    return
  end

  timer.Simple( 8, function( )
    if not self:IsValid() then
      -- Nade got removed before Helicopter came
      print("Airdrop nade got removed before the helicopter could come.")
      return
    end

    local tr = util.TraceLine( {
      start = self:GetPos( ),
      endpos = self:GetPos( ) + Vector( 0, 0, 1000000 ),
      mask = MASK_NPCWORLDSTATIC
    })

    local spot = {
      pos = self:GetPos( ),
      ang = Angle(0, 0, 0),
      height = tr.HitPos.z - 50
    }

    if spot.height < 500 then
      self:InvalidAirdrop( )
    else
      local valid = false
      for i = 1, 7 do
        spot.ang = spot.ang + Angle( 0, 45, 0 )

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

        if tr1.HitPos:Distance(tr2.HitPos) >= 500 then
          valid = true
          break
        end
      end
      if valid then
        Pointshop2.Airdrops.ParameterAirdrop( spot )

        --[[ 
          -- Shitty version
          local crate = ents.Create( "sent_airdropcrate" )
          crate:SetPos( spot.pos + Vector( 0, 0, spot.height - 50 ) )
          crate:SetAngles( Angle( 0, 0, 0 ) )
          crate:Spawn( )

          local crateContents = Pointshop2.Airdrops.CreateTempItems( Pointshop2.GetSetting( "Pointshop 2 DLC", "AirdropCrateSettings.AmountOfItems" ) )
          crate:SetContents( crateContents )
        ]]--
      else
        self:InvalidAirdrop( )
      end
    end

    timer.Simple( 3, function( )
      if IsValid(self) then
        self:Remove( )
      end
    end )
  end )
end

function ENT:InvalidAirdrop( )
  if SERVER then
    self.Thrower:PS2_DisplayError( "The helicopter cannot come to this location" )
    self.Thrower:Give( "weapon_dropmarker" )
  end
end

function ENT:Think( )
  if self.Created + 1.5 < CurTime( ) and self:GetVelocity():Length() < 20 and not self.Exploded then
    self:Explode( )
  end
  if CLIENT then
    self:ParticleThink( )
  end
end


function ENT:SetThrower( ply )
  self.Thrower = ply
end
