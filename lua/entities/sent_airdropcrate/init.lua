// Send required files to client.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

// Include needed files.
include("shared.lua")

function ENT:SetContents( contents )
  self.contents = contents
end

function ENT:GetContents( )
  return self.contents
end

function ENT:Use( activator, caller, useType, value )
  if caller:GetPos( ):Distance( self:GetPos( ) ) <= Pointshop2.Airdrops.MAX_USE_DISTANCE and caller:Team( ) != TEAM_SPECTATOR then
    AirdropsController:getInstance( ):supplyCrateUsed( caller, self )
  end
end
