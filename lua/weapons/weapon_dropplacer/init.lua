include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_gui.lua" )

concommand.Add( "strip_crate_placer" , function( ply, cmd, args )
  if not PermissionInterface.query( ply, 'pointshop2 manageairdrops' ) then
    ply:PS2_DisplayError( "You are not permitted to place Air Drops." )
    return
  end

  if not ply:Alive( ) then
    ply:PS2_DisplayError( "You need to be alive to place Air Drops." )
    return
  end

  if not ply:GetWeapon( "weapon_dropplacer" ) then
    ply:PS2_DisplayError( "You have the wrong weapon" )
    return
  end

  ply:StripWeapons( )
  ply:GodDisable( )
  for k,v in pairs(ply.weaponsBeforePlacer) do
    local wep = ply:Give(v[1])
    ply:RemoveAllAmmo()
    ply:SetAmmo(v[2], v[3], false)
    ply:SetAmmo(v[4], v[5], false)

    if ply.SetClip1 then ply:SetClip1(v[6]) end
    if ply.SetClip2 then ply:SetClip2(v[7]) end
  end
  local cl_defaultweapon = ply:GetInfo("cl_defaultweapon")
  if ( ply:HasWeapon( cl_defaultweapon )  ) then
      ply:SelectWeapon( cl_defaultweapon )
  end

  ply:StripWeapon( "weapon_dropplacer" )
end )
