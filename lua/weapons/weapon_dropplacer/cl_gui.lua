local PANEL = {}

function PANEL:Init( )
  self:SetSkin( Pointshop2.Config.DermaSkin )
  self:SetWide( 400 )
  self:SetTall( 205 )

  self:ParentToHUD( )
  self:SetPos( ( ScrW( ) - 400 ) / 2, 25 )

  local label2 = vgui.Create( "DLabel", self )
  label2:Dock( TOP )
  label2:SetText( "Air Drop Placer" )
  label2:SetContentAlignment( 5 )
  label2:SetFont( self:GetSkin( ).BigTitleFont )
  label2:SetColor( color_white )
  label2:SizeToContents( )

  self.label = vgui.Create( "DLabel", self )
  self.label:Dock( TOP )
  self.label:SetText( "Click to go to the next step" )
  self.label:SetContentAlignment( 5 )
  self.label:SetFont( self:GetSkin( ).SmallTitleFont )
  self.label:SetColor( Color( 200, 200, 200 ) )
  self.label:SizeToContents( )
  self.label:DockMargin( 10, -5, 10, 10 )

  self.buttons = vgui.Create( "DPanel", self )
  function self.buttons.Paint() end
  self.buttons:Dock( TOP )
  self.buttons:SetTall( ( 400 - 40 ) / 3 )
  self.modes = { "Position", "Rotate", "Helo Height" }
  for k, v in pairs( self.modes ) do
    self.buttons[v] = vgui.Create( "DButton", self.buttons )
    self.buttons[v]:SetSize( ( 400 - 40 ) / 3, ( 400 - 40 ) / 3 )
    self.buttons[v]:SetText( v )
    self.buttons[v]:SetFont( self:GetSkin( ).TabFont )
    self.buttons[v]:SetPos( k * 10 + ( k - 1 ) * ( 400 - 40 ) / 3, 0 )

    if k == 1 then
      self.buttons[v].Selected = true
    end
  end

  self.startTime = CurTime( )
end

function PANEL:SetMode( mode )
  local key = table.KeyFromValue( self.modes, mode )
  for k, v in pairs( self.modes ) do
    self.buttons[v].Selected = k == key
  end
end

function PANEL:Paint( w, h )
  local _DisableClipping = DisableClipping
  DisableClipping = function( ) end
  Derma_DrawBackgroundBlur( self, self.startTime )
  DisableClipping = _DisableClipping
end

vgui.Register( "DPointshopSupplyDropPlacer", PANEL, "DPanel" )
