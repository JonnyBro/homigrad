include( "shared.lua" )
include( "cl_gui.lua" )

function SWEP:Initialize( )
  self.mode = "Position"
  hook.Add( "PreDrawTranslucentRenderables", self, self.PreDrawTranslucentRenderables )
  self.heloHeight = 100
end

function SWEP:Deploy( )
end

function SWEP:Holster( )
  if IsValid( self.gui ) then
    self.gui:Remove( )
  end
  if IsValid( self.crate ) then
    self.crate:Remove( )
  end
  if IsValid( self.helo ) then
    self.helo:Remove( )
  end
end

function SWEP:PrimaryAttack( )
  if LocalPlayer( ):GetActiveWeapon( ) != self then
    return
  end

  if CurTime( ) < ( self.lastPrimaryAttack or 0 ) + 0.3 then
    return
  end
  self.lastPrimaryAttack = CurTime( )

  local modes = { "Position", "Rotate", "Helo Height" }
  local key = table.KeyFromValue( modes, self.mode )
  key = key + 1
  if key == 4 then
    self:Finish( )
    key = 3
    return
  end
  self.mode = modes[key]
  LocalPlayer( ).dropsPlacerGui:SetMode( self.mode )
end

-- For override
function SWEP:OnFinished( pos, ang, height, name )
  hook.Run( "PS2_Airdrops_NewPosition", {
    pos = self.crate:GetPos( ),
    ang = self.crate:GetAngles( ),
    height = self.heloHeight,
    name = name
  } )
end

function SWEP:Finish( )
  Derma_StringRequest( "Please give the new spot a name to describe it's location", "Enter a name", "Position at " .. tostring( self.crate:GetPos() ), function( text )
    self:OnFinished( self.crate:GetPos( ), self.crate:GetAngles( ), self.heloHeight, text )
    RunConsoleCommand( "strip_crate_placer" )
  end, function( )
  end )
end

function SWEP:SecondaryAttack( )
  if LocalPlayer( ):GetActiveWeapon( ) != self then
    return
  end

  if CurTime( ) < ( self.lastSecondaryAttack or 0 ) + 0.3 then
    return
  end
  self.lastSecondaryAttack = CurTime( )

  local modes = { "Position", "Rotate", "Helo Height" }
  local key = table.KeyFromValue( modes, self.mode )
  key = math.Clamp( key - 1, 1, 3 )
  self.mode = modes[key]
  LocalPlayer( ).dropsPlacerGui:SetMode( self.mode )
end

function SWEP:OnRemove( )
  self:Holster( )
end

local mat = Material( "trails/laser" )
function SWEP:PreDrawTranslucentRenderables( )
  if LocalPlayer( ):GetActiveWeapon( ) != self then
    return
  end

  if not IsValid( self.crate ) then
    return
  end

  if self.mode == "Position" then
    local min, max = self.crate:GetModelBounds()
    self.crate:SetPos( LocalPlayer():GetEyeTrace().HitPos + Vector( 0, 0, 35 ) )
  elseif self.mode == "Rotate" then
    local ang = ( self.crate:GetPos( ) - LocalPlayer():GetEyeTrace().HitPos ):Angle( )
    self.crate:SetAngles( Angle( 0, ang.y - 90, 0 ) )
  elseif self.mode == "Helo Height" then
    self.heloHeight = ( LocalPlayer():GetEyeTrace().HitPos - self.crate:GetPos( )  ).z
  end

  local heloPos = self.crate:GetPos( ) + Vector( 0, 0, self.heloHeight )

  render.DrawWireframeSphere( heloPos, 10, 10, 10 )

  render.SetMaterial( mat )
  render.DrawBeam( self.crate:GetPos( ), heloPos, 5, 0, 1 )

  local tr1 = util.TraceLine( {
  	start = heloPos,
    endpos = heloPos + self.crate:GetAngles( ):Right() * 1000000
  } )
  local dir = ( tr1.HitPos - heloPos )
  dir:Normalize( )
  render.SetColorModulation( 1, 0, 0 )
  render.DrawBeam( heloPos, tr1.HitPos, 15, 0, 1 )

  local tr2 = util.TraceLine( {
    start = heloPos,
    endpos = heloPos + self.crate:GetAngles( ):Right() * -1000000
  } )
  local dir2 = ( tr2.HitPos - heloPos )
  dir2:Normalize( )
  render.DrawBeam( heloPos, heloPos + dir2 * 100000 , 15, 0, 1 )

  local start, finish = tr1.HitPos, tr2.HitPos
  if not IsValid( self.helo ) then
    self.helo = ClientsideModel( "models/supplyhelicopter/supply_helicopter.mdl" )
  end
  self.helo:SetPos( start + ( finish - start ) * ( CurTime() % 1 ) + Vector( 0, 0, 50 ) )
  self.helo:SetAngles( ( finish - start ):Angle() )
  self.helo:SetMaterial( "models/wireframe")
end

function SWEP:Think( )
  if LocalPlayer( ):GetActiveWeapon( ) != self then
    return
  end

  if self.mode == "Position" and not IsValid( self.crate ) then
    self.crate = ClientsideModel( "models/care_package/care_package_new.mdl" )
    self.crate:SetMaterial( "models/wireframe" )
  end
end

function SWEP:HUDPaint( )
end

hook.Add( "Think", "HudHookGuiAirdrop", function( )
  if IsValid( LocalPlayer( ):GetActiveWeapon( ) ) and LocalPlayer( ):GetActiveWeapon( ):GetClass( ) == "weapon_dropplacer" then
    if not IsValid( LocalPlayer( ).dropsPlacerGui ) then
      LocalPlayer( ).dropsPlacerGui = vgui.Create( "DPointshopSupplyDropPlacer", self )
    end
  else
    if IsValid( LocalPlayer( ).dropsPlacerGui ) then
      LocalPlayer( ).dropsPlacerGui:Remove( )
    end
  end
end )
