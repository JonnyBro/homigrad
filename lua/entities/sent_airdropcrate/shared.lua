// Entity information.
ENT.Type = "anim"
ENT.Base = "base_anim"


ENT.PrintName = "Airdrop Crate"
ENT.Author = "Kamshak"
ENT.Information = "Crate for Airdrop"
ENT.Category = "Fun + Games"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT


function ENT:Initialize( )
	self:SetModel( "models/care_package/care_package_new.mdl" )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if ( SERVER ) then
		self:PhysicsInit( SOLID_VPHYSICS )
		-- Wake up our physics object so we don't start asleep
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()
		end

		self:SetUseType( SIMPLE_USE )

		local lifetime = Pointshop2.GetSetting( "Pointshop 2 DLC", "AirdropCrateSettings.CrateLifetime" ) * 60
		local timername = "AirDropCrate" .. self:GetCreationID()
		timer.Create( timername, lifetime, 1, function( )
			if IsValid( self ) then
				self:Remove( )
			end
			timer.Remove( timername )
		end )
  end
end
