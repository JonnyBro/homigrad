
--[[

Editing the Lightsabers.

Once you unpack the lightsaber addon, you are voided of any support as to why it doesn't work.
I can't possibly provide support for all the edits and I can't know what your edits broke or whatever.

-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------
-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------
-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------
-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------
-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------

-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------

]]

TOOL.Category = "Robotboy655"
TOOL.Name = "#tool.rb655_lightsaber"

TOOL.ClientConVar[ "model" ] = "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl"
TOOL.ClientConVar[ "red" ] = "0"
TOOL.ClientConVar[ "green" ] = "127"
TOOL.ClientConVar[ "blue" ] = "255"
TOOL.ClientConVar[ "bladew" ] = "2"
TOOL.ClientConVar[ "bladel" ] = "42"

TOOL.ClientConVar[ "dark" ] = "0"
TOOL.ClientConVar[ "starton" ] = "1"

TOOL.ClientConVar[ "humsound" ] = "lightsaber/saber_loop1.wav"
TOOL.ClientConVar[ "swingsound" ] = "lightsaber/saber_swing1.wav"
TOOL.ClientConVar[ "onsound" ] = "lightsaber/saber_on1.wav"
TOOL.ClientConVar[ "offsound" ] = "lightsaber/saber_off1.wav"

cleanup.Register( "ent_lightsabers" )

if ( SERVER ) then
	CreateConVar( "sbox_maxent_lightsabers", 2 )

	function MakeLightsaber( ply, model, pos, ang, LoopSound, SwingSound, OnSound, OffSound )
		if ( IsValid( ply ) and !ply:CheckLimit( "ent_lightsabers" ) ) then return false end

		local ent_lightsaber = ents.Create( "ent_lightsaber" )
		if ( !IsValid( ent_lightsaber ) ) then return false end

		ent_lightsaber:SetModel( model )
		ent_lightsaber:SetAngles( ang )
		ent_lightsaber:SetPos( pos )
		--ent_lightsaber:SetCrystalColor( clr )
		--ent_lightsaber:SetColor( clr )
		--ent_lightsaber:SetEnabled( tobool( Enabled ) )

		table.Merge( ent_lightsaber:GetTable(), {
			Owner = ply,
			--clr = clr,
			--Enabled = tobool( Enabled ),
			LoopSound = LoopSound,
			SwingSound = SwingSound,
			OnSound = OnSound,
			OffSound = OffSound,
		} )

		ent_lightsaber:Spawn()
		ent_lightsaber:Activate()

		if ( IsValid( ply ) ) then
			ply:AddCount( "ent_lightsabers", ent_lightsaber )
			ply:AddCleanup( "ent_lightsabers", ent_lightsaber )
		end

		DoPropSpawnedEffect( ent_lightsaber )

		return ent_lightsaber
	end

	duplicator.RegisterEntityClass( "ent_lightsaber", MakeLightsaber, "model", "pos", "ang", "LoopSound", "SwingSound", "OnSound", "OffSound" )
end

function rb655_InvalidSettings()

	GAMEMODE:AddNotify( "Cannot spawn Lightsaber with given tool settings.", NOTIFY_ERROR, 6 )
	surface.PlaySound( "buttons/button10.wav" )

end

function TOOL:LeftClick( trace )
	if ( trace.HitSky or !trace.HitPos ) then return false end
	if ( IsValid( trace.Entity ) and ( trace.Entity:GetClass() == "ent_lightsaber" or trace.Entity:IsPlayer() ) ) then return false end
	--if ( trace.Entity:IsNPC() and trace.Entity:GetClass() != "npc_metropolice" ) then return false end
	if ( CLIENT ) then return true end

	local ply = self:GetOwner()

	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch - 90

	if ( trace.HitNormal.z > 0.99 ) then ang.y = ply:GetAngles().y end

	local r = self:GetClientNumber( "red" )
	local g = self:GetClientNumber( "green" )
	local b = self:GetClientNumber( "blue" )

	local hs = self:GetClientInfo( "humsound" )
	local ss = self:GetClientInfo( "swingsound" )
	local ons = self:GetClientInfo( "onsound" )
	local offs = self:GetClientInfo( "offsound" )

	local dark = self:GetClientNumber( "dark" )
	local enabled = self:GetClientNumber( "starton" )
	local mdl = self:GetClientInfo( "model" )

	local bld_len = self:GetClientNumber( "bladel" )
	local bld_w = self:GetClientNumber( "bladew" )

	if ( !game.SinglePlayer() ) then
		bld_len = math.Clamp( bld_len, 32, 64 )
		bld_w = math.Clamp( bld_w, 2, 4 )
	end

	if ( GetConVarNumber( "rb655_lightsaber_disallow_custom_content" ) > 0 and !game.SinglePlayer() ) then
		if ( !list.HasEntry( "LightsaberModels", mdl ) ) then
			ply:SendLua( "rb655_InvalidSettings()" )
			return
		end

		-- This is quite hefty
		local humSnds = list.Get( "rb655_LightsaberHumSounds" )
		local foundHum, foundOnSnd, foundOffSnd, foundSwingSound = false, false, false, false
		for k, v in pairs( humSnds ) do
			if ( v.rb655_lightsaber_humsound == hs ) then
				foundHum = true
			end
		end

		for k, v in pairs( list.Get( "rb655_LightsaberIgniteSounds" ) ) do
			if ( v.rb655_lightsaber_onsound == ons ) then foundOnSnd = true end
			if ( v.rb655_lightsaber_offsound == offs ) then foundOffSnd = true end
		end

		for k, v in pairs( list.Get( "rb655_LightsaberSwingSounds" ) ) do
			if ( v.rb655_lightsaber_swingsound == ss ) then foundSwingSound = true end
		end

		if ( !foundHum or !foundOnSnd or !foundOffSnd or !foundSwingSound) then
			ply:SendLua( "rb655_InvalidSettings()" )
			return
		end
	end

	local ent_lightsaber
	if ( trace.Entity:IsNPC() ) then
		if ( !IsValid( trace.Entity:GetActiveWeapon() ) or trace.Entity:GetActiveWeapon():GetClass() != "weapon_lightsaber" ) then
			ent_lightsaber = trace.Entity:Give( "weapon_lightsaber" )
		else
			ent_lightsaber = trace.Entity:GetActiveWeapon()
		end
		if ( !IsValid( ent_lightsaber ) ) then return end

		ent_lightsaber:SetModel( mdl )
		ent_lightsaber:SetWorldModel( mdl )
		ent_lightsaber.LoopSound = hs
		ent_lightsaber.SwingSound = ss
		ent_lightsaber:SetOnSound( ons )
		ent_lightsaber:SetOffSound( offs )

	else
		ent_lightsaber = MakeLightsaber( ply, mdl, trace.HitPos, ang, hs, ss, ons, offs )
	end

	if ( !IsValid( ent_lightsaber ) ) then return end

	if ( ent_lightsaber:IsWeapon() ) then -- Special case for giving NPC a weapon
		ent_lightsaber:SetCrystalColor( Vector( r, g, b ) )
	else
		ent_lightsaber:SetCrystalColor( Vector( r, g, b ) / 255 )
		ent_lightsaber:SetEnabled( tobool( enabled ) )
	end
	ent_lightsaber:SetDarkInner( tobool( dark ) )
	ent_lightsaber:SetMaxLength( bld_len )
	ent_lightsaber:SetBladeWidth( bld_w )

	local min = ent_lightsaber:OBBMins()
	ent_lightsaber:SetPos( trace.HitPos - trace.HitNormal * min.z )

	local phys = ent_lightsaber:GetPhysicsObject()
	if ( IsValid( phys ) ) then phys:Wake() end

	--[[if ( trace.Entity:IsNPC() and trace.Entity:GetClass() == "npc_metropolice" ) then
		ent_lightsaber:SetParent( trace.Entity )
		ent_lightsaber:Fire( "SetParentAttachment", "RHand" )

		timer.Simple( 0.1, function()
			ent_lightsaber:SetLocalAngles( Angle( -85, 40, 0 ) )
			ent_lightsaber:SetLocalPos( Vector( -1.3, -1.3, -12 ) )
		end )
	end]]

	undo.Create( "ent_lightsaber" )
		undo.AddEntity( ent_lightsaber )
		undo.SetPlayer( ply )
	undo.Finish()

	return true
end

function TOOL:RightClick( trace )
	if ( trace.HitSky or !trace.HitPos ) then return false end
	if ( IsValid( trace.Entity ) and ( trace.Entity:GetClass() == "ent_lightsaber" ) ) then return false end
	if ( CLIENT ) then return true end

	local ply = self:GetOwner()

	ply:StripWeapon( "weapon_lightsaber" )
	local w = ply:Give( "weapon_lightsaber" )

	-- All the settings are loaded by the weapon
	w:LoadToolValues( ply )

	timer.Simple( 0.2, function()
		if ( !IsValid( w ) or !IsValid( ply ) ) then return end

		w:SetEnabled( tobool( ply:GetInfo( "rb655_lightsaber_starton" ) ) )
		ply:SelectWeapon( "weapon_lightsaber" )
	end )

	return true
end

function TOOL:UpdateGhostEntity( ent, ply )
	if ( !IsValid( ent ) ) then return end

	local trace = ply:GetEyeTrace()

	if ( !trace.Hit ) then ent:SetNoDraw( true ) return end
	if ( IsValid( trace.Entity ) and trace.Entity:GetClass() == "ent_lightsaber" or trace.Entity:IsPlayer() or trace.Entity:IsNPC() ) then ent:SetNoDraw( true ) return end

	local ang = trace.HitNormal:Angle()
	ang.p = ang.p - 90

	if ( trace.HitNormal.z > 0.99 ) then ang.y = ply:GetAngles().y end

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )

	ent:SetAngles( ang )
	ent:SetNoDraw( false )
end

function TOOL:Think()
	if ( !IsValid( self.GhostEntity ) or self.GhostEntity:GetModel() != self:GetClientInfo( "model" ) ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostEntity( self.GhostEntity, self:GetOwner() )
end

list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.hum.1", { rb655_lightsaber_humsound = "lightsaber/saber_loop1.wav" } )
list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.hum.2", { rb655_lightsaber_humsound = "lightsaber/saber_loop2.wav" } )
list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.hum.3", { rb655_lightsaber_humsound = "lightsaber/saber_loop3.wav" } )
list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.hum.4", { rb655_lightsaber_humsound = "lightsaber/saber_loop4.wav" } )
list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.hum.5", { rb655_lightsaber_humsound = "lightsaber/saber_loop5.wav" } )
list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.hum.6", { rb655_lightsaber_humsound = "lightsaber/saber_loop6.wav" } )
list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.hum.7", { rb655_lightsaber_humsound = "lightsaber/saber_loop7.wav" } )
list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.hum.8", { rb655_lightsaber_humsound = "lightsaber/saber_loop8.wav" } )
list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.dark", { rb655_lightsaber_humsound = "lightsaber/darksaber_loop.wav" } )
list.Set( "rb655_LightsaberHumSounds", "#tool.rb655_lightsaber.kylo", { rb655_lightsaber_humsound = "lightsaber/saber_loop_kylo.wav" } )

list.Set( "rb655_LightsaberSwingSounds", "#tool.rb655_lightsaber.jedi", { rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav" } )
list.Set( "rb655_LightsaberSwingSounds", "#tool.rb655_lightsaber.sith", { rb655_lightsaber_swingsound = "lightsaber/saber_swing2.wav" } )
list.Set( "rb655_LightsaberSwingSounds", "#tool.rb655_lightsaber.dark", { rb655_lightsaber_swingsound = "lightsaber/darksaber_swing.wav" } )
list.Set( "rb655_LightsaberSwingSounds", "#tool.rb655_lightsaber.kylo", { rb655_lightsaber_swingsound = "lightsaber/saber_swing_kylo.wav" } )

list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.jedi", { rb655_lightsaber_onsound = "lightsaber/saber_on1.wav", rb655_lightsaber_offsound = "lightsaber/saber_off1.wav" } )
list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.jedi_fast", { rb655_lightsaber_onsound = "lightsaber/saber_on1_fast.wav", rb655_lightsaber_offsound = "lightsaber/saber_off1_fast.wav" } )
list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.sith", { rb655_lightsaber_onsound = "lightsaber/saber_on2.wav", rb655_lightsaber_offsound = "lightsaber/saber_off2.wav" } )
list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.sith_fast", { rb655_lightsaber_onsound = "lightsaber/saber_on2_fast.wav", rb655_lightsaber_offsound = "lightsaber/saber_off2_fast.wav" } )
list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.heavy", { rb655_lightsaber_onsound = "lightsaber/saber_on3.wav", rb655_lightsaber_offsound = "lightsaber/saber_off3.wav" } )
list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.heavy_fast", { rb655_lightsaber_onsound = "lightsaber/saber_on3_fast.wav", rb655_lightsaber_offsound = "lightsaber/saber_off3_fast.wav" } )
list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.jedi2", { rb655_lightsaber_onsound = "lightsaber/saber_on4.wav", rb655_lightsaber_offsound = "lightsaber/saber_off4.mp3" } )
list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.jedi2_fast", { rb655_lightsaber_onsound = "lightsaber/saber_on4_fast.wav", rb655_lightsaber_offsound = "lightsaber/saber_off4_fast.wav" } )
list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.dark", { rb655_lightsaber_onsound = "lightsaber/darksaber_on.wav", rb655_lightsaber_offsound = "lightsaber/darksaber_off.wav" } )
list.Set( "rb655_LightsaberIgniteSounds", "#tool.rb655_lightsaber.kylo", { rb655_lightsaber_onsound = "lightsaber/saber_on_kylo.wav", rb655_lightsaber_offsound = "lightsaber/saber_off_kylo.wav" } )

list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_anakin_ep3_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_common_jedi_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_luke_ep6_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_mace_windu_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_maul_saber_half_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_obiwan_ep1_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_obiwan_ep3_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_quigon_gin_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_sidious_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_vader_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_yoda_saber_hilt.mdl", {} )
list.Set( "LightsaberModels", "models/weapons/starwars/w_kr_hilt.mdl", {} )

list.Set( "LightsaberModels", "models/weapons/starwars/w_maul_saber_staff_hilt.mdl", {} )
--list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_maul_saber_hilt.mdl", {} )

list.Set( "LightsaberModels", "models/weapons/starwars/w_dooku_saber_hilt.mdl", {} )
--list.Set( "LightsaberModels", "models/sgg/starwars/weapons/w_dooku_saber_hilt.mdl", {} )

if ( SERVER ) then return end

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
}

language.Add( "tool.rb655_lightsaber", "Lightsabers" )
language.Add( "tool.rb655_lightsaber.name", "Lightsabers" )
language.Add( "tool.rb655_lightsaber.desc", "Spawn customized lightsabers" )
language.Add( "tool.rb655_lightsaber.0", "Left click to spawn a Lightsaber. Right click to give yourself a Lightsaber" ) -- Not sure why I keep this
language.Add( "tool.rb655_lightsaber.left", "Spawn a Lightsaber Entity" )
language.Add( "tool.rb655_lightsaber.right", "Give yourself a Lightsaber Weapon" )

language.Add( "tool.rb655_lightsaber.model", "Hilt" )
language.Add( "tool.rb655_lightsaber.color", "Crystal Color" )
language.Add( "tool.rb655_lightsaber.take", "Take this lightsaber" )

language.Add( "tool.rb655_lightsaber.DarkInner", "Dark inner blade" )
language.Add( "tool.rb655_lightsaber.StartEnabled", "Enabled on spawn" )

language.Add( "tool.rb655_lightsaber.HumSound", "Hum Sound" )
language.Add( "tool.rb655_lightsaber.SwingSound", "Swing Sound" )
language.Add( "tool.rb655_lightsaber.IgniteSound", "Ignition Sound" )

language.Add( "tool.rb655_lightsaber.HudBlur", "Enable HUD Blur ( may reduce performance )" )

language.Add( "tool.rb655_lightsaber.bladew", "Blade Width" )
language.Add( "tool.rb655_lightsaber.bladel", "Blade Length" )

language.Add( "tool.rb655_lightsaber.jedi", "Jedi" )
language.Add( "tool.rb655_lightsaber.jedi_fast", "Jedi - Fast" )
language.Add( "tool.rb655_lightsaber.sith", "Sith" )
language.Add( "tool.rb655_lightsaber.sith_fast", "Sith - Fast" )
language.Add( "tool.rb655_lightsaber.heavy", "Heavy" )
language.Add( "tool.rb655_lightsaber.heavy_fast", "Heavy - Fast" )
language.Add( "tool.rb655_lightsaber.jedi2", "Jedi - Original" )
language.Add( "tool.rb655_lightsaber.jedi2_fast", "Jedi - Original Fast" )
language.Add( "tool.rb655_lightsaber.dark", "Dark Saber" )
language.Add( "tool.rb655_lightsaber.kylo", "Kylo Ren" )

language.Add( "tool.rb655_lightsaber.hum.1", "Default" )
language.Add( "tool.rb655_lightsaber.hum.2", "Sith Heavy" )
language.Add( "tool.rb655_lightsaber.hum.3", "Medium" )
language.Add( "tool.rb655_lightsaber.hum.4", "Heavish" )
language.Add( "tool.rb655_lightsaber.hum.5", "Sith Assassin Light" )
language.Add( "tool.rb655_lightsaber.hum.6", "Darth Vader" )
language.Add( "tool.rb655_lightsaber.hum.7", "Heavy" )
language.Add( "tool.rb655_lightsaber.hum.8", "Dooku" )

language.Add( "Cleanup_ent_lightsabers", "Lightsabers" )
language.Add( "Cleaned_ent_lightsabers", "Cleaned up all Lightsabers" )
language.Add( "SBoxLimit_ent_lightsabers", "You've hit the Lightsaber limit!" )
language.Add( "Undone_ent_lightsaber", "Lightsaber undone" )
language.Add( "max_ent_lightsabers", "Max Lightsabers" )
language.Add( "Hint_LightsaberCustomizationHint", "You can customize your Lightsaber in the Lightsabers tool" )

language.Add( "tool.rb655_lightsaber.preset1", "Darth Maul's Saberstaff" )
language.Add( "tool.rb655_lightsaber.preset2", "Darth Maul's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset3", "Darth Tyrannus's Lightsaber (Count Dooku)" )
language.Add( "tool.rb655_lightsaber.preset4", "Darth Sidious's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset5", "Darth Vader's Lightsaber" )

language.Add( "tool.rb655_lightsaber.preset6", "Master Yoda's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset7", "Qui-Gon Jinn's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset8", "Mace Windu's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset9", "[EP3] Obi-Wan Kenobi's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset10", "[EP1] Obi-Wan Kenobi's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset11", "[EP6] Luke Skywalker's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset12", "[EP2] Anakin Skywalker's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset13", "[EP3] Anakin Skywalker's Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset14", "Common Jedi Lightsaber" )
language.Add( "tool.rb655_lightsaber.preset15", "Dark Saber" )
language.Add( "tool.rb655_lightsaber.preset_kylo", "Kylo Ren's Crossguard Lightsaber" )

local ConVarsDefault = TOOL:BuildConVarList()

local PresetPresets = {
	[ "#preset.default" ] = ConVarsDefault,

	-- Sith
	[ "#tool.rb655_lightsaber.preset1" ] = {
		rb655_lightsaber_model = "models/weapons/starwars/w_maul_saber_staff_hilt.mdl",
		rb655_lightsaber_red = "255",
		rb655_lightsaber_green = "0",
		rb655_lightsaber_blue = "0",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.4",
		rb655_lightsaber_bladel = "45",
		rb655_lightsaber_humsound = "lightsaber/saber_loop7.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing2.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on2.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off2.wav"
	},
	[ "#tool.rb655_lightsaber.preset2" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_maul_saber_half_hilt.mdl",
		rb655_lightsaber_red = "255",
		rb655_lightsaber_green = "0",
		rb655_lightsaber_blue = "0",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.4",
		rb655_lightsaber_bladel = "45",
		rb655_lightsaber_humsound = "lightsaber/saber_loop7.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing2.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on2.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off2.wav"
	},
	[ "#tool.rb655_lightsaber.preset3" ] = {
		rb655_lightsaber_model = "models/weapons/starwars/w_dooku_saber_hilt.mdl",
		rb655_lightsaber_red = "255",
		rb655_lightsaber_green = "0",
		rb655_lightsaber_blue = "0",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2",
		rb655_lightsaber_bladel = "42",
		rb655_lightsaber_humsound = "lightsaber/saber_loop8.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing2.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on2.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off2.wav"
	},
	[ "#tool.rb655_lightsaber.preset4" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_sidious_saber_hilt.mdl",
		rb655_lightsaber_red = "255",
		rb655_lightsaber_green = "0",
		rb655_lightsaber_blue = "0",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.2",
		rb655_lightsaber_bladel = "43",
		rb655_lightsaber_humsound = "lightsaber/saber_loop5.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing2.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on2.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off2.wav"
	},
	[ "#tool.rb655_lightsaber.preset5" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_vader_saber_hilt.mdl",
		rb655_lightsaber_red = "255",
		rb655_lightsaber_green = "0",
		rb655_lightsaber_blue = "0",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.25",
		rb655_lightsaber_bladel = "43",
		rb655_lightsaber_humsound = "lightsaber/saber_loop6.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing2.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on2.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off2.wav"
	},

	-- Jedi
	[ "#tool.rb655_lightsaber.preset6" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_yoda_saber_hilt.mdl",
		rb655_lightsaber_red = "64",
		rb655_lightsaber_green = "255",
		rb655_lightsaber_blue = "64",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.3",
		rb655_lightsaber_bladel = "40",
		rb655_lightsaber_humsound = "lightsaber/saber_loop3.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on1.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off1.wav"
	},
	[ "#tool.rb655_lightsaber.preset7" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_quigon_gin_saber_hilt.mdl",
		rb655_lightsaber_red = "32",
		rb655_lightsaber_green = "255",
		rb655_lightsaber_blue = "32",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.2",
		rb655_lightsaber_bladel = "42",
		rb655_lightsaber_humsound = "lightsaber/saber_loop1.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on1.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off1.wav"
	},
	[ "#tool.rb655_lightsaber.preset8" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_mace_windu_saber_hilt.mdl",
		rb655_lightsaber_red = "127",
		rb655_lightsaber_green = "0",
		rb655_lightsaber_blue = "255",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2",
		rb655_lightsaber_bladel = "42",
		rb655_lightsaber_humsound = "lightsaber/saber_loop1.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on1.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off1.wav"
	},
	[ "#tool.rb655_lightsaber.preset9" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_obiwan_ep3_saber_hilt.mdl",
		rb655_lightsaber_red = "48",
		rb655_lightsaber_green = "48",
		rb655_lightsaber_blue = "255",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.1",
		rb655_lightsaber_bladel = "42",
		rb655_lightsaber_humsound = "lightsaber/saber_loop1.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on1.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off1.wav"
	},
	[ "#tool.rb655_lightsaber.preset10" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_obiwan_ep1_saber_hilt.mdl",
		rb655_lightsaber_red = "48",
		rb655_lightsaber_green = "48",
		rb655_lightsaber_blue = "255",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.1",
		rb655_lightsaber_bladel = "42",
		rb655_lightsaber_humsound = "lightsaber/saber_loop1.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on1.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off1.wav"
	},
	[ "#tool.rb655_lightsaber.preset11" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_luke_ep6_saber_hilt.mdl",
		rb655_lightsaber_red = "32",
		rb655_lightsaber_green = "255",
		rb655_lightsaber_blue = "32",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.1",
		rb655_lightsaber_bladel = "42",
		rb655_lightsaber_humsound = "lightsaber/saber_loop1.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on1.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off1.wav"
	},
	[ "#tool.rb655_lightsaber.preset12" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl",
		rb655_lightsaber_red = "0",
		rb655_lightsaber_green = "100",
		rb655_lightsaber_blue = "255",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.1",
		rb655_lightsaber_bladel = "42",
		rb655_lightsaber_humsound = "lightsaber/saber_loop1.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on1.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off1.wav"
	},
	[ "#tool.rb655_lightsaber.preset13" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_anakin_ep3_saber_hilt.mdl",
		rb655_lightsaber_red = "0",
		rb655_lightsaber_green = "100",
		rb655_lightsaber_blue = "255",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.1",
		rb655_lightsaber_bladel = "42",
		rb655_lightsaber_humsound = "lightsaber/saber_loop1.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on1.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off1.wav"
	},
	[ "#tool.rb655_lightsaber.preset14" ] = {
		rb655_lightsaber_model = "models/sgg/starwars/weapons/w_common_jedi_saber_hilt.mdl",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.2",
		rb655_lightsaber_bladel = "42",
		rb655_lightsaber_humsound = "lightsaber/saber_loop1.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing1.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on1.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off1.wav"
	},

	[ "#tool.rb655_lightsaber.preset_kylo" ] = {
		rb655_lightsaber_model = "models/weapons/starwars/w_kr_hilt.mdl",
		rb655_lightsaber_red = "255",
		rb655_lightsaber_green = "0",
		rb655_lightsaber_blue = "0",
		rb655_lightsaber_dark = "0",
		rb655_lightsaber_bladew = "2.1",
		rb655_lightsaber_bladel = "40",
		rb655_lightsaber_humsound = "lightsaber/saber_loop_kylo.wav",
		rb655_lightsaber_swingsound = "lightsaber/saber_swing_kylo.wav",
		rb655_lightsaber_onsound = "lightsaber/saber_on_kylo.wav",
		rb655_lightsaber_offsound = "lightsaber/saber_off_kylo.wav"
	},

	-- The Pre Vizsla's darksaber from clone wars, I LOVE IT
	[ "#tool.rb655_lightsaber.preset15" ] = {
		rb655_lightsaber_red = "255",
		rb655_lightsaber_green = "255",
		rb655_lightsaber_blue = "255",
		rb655_lightsaber_dark = "1",
		rb655_lightsaber_humsound = "lightsaber/darksaber_loop.wav",
		rb655_lightsaber_swingsound = "lightsaber/darksaber_swing.wav",
		rb655_lightsaber_onsound = "lightsaber/darksaber_on.wav",
		rb655_lightsaber_offsound = "lightsaber/darksaber_off.wav"
	},
}

function TOOL.BuildCPanel( panel )
	panel:AddControl( "ComboBox", { MenuButton = 1, Folder = "rb655_lightsabers", Options = PresetPresets, CVars = table.GetKeys( ConVarsDefault ) } )

	panel:AddControl( "PropSelect", {Label = "#tool.rb655_lightsaber.model", Height = 4, ConVar = "rb655_lightsaber_model", Models = list.Get( "LightsaberModels" )} )
	panel:AddControl( "Color", { Label = "#tool.rb655_lightsaber.color", Red = "rb655_lightsaber_red", Green = "rb655_lightsaber_green", Blue = "rb655_lightsaber_blue", ShowAlpha = "0", ShowHSV = "1", ShowRGB = "1" } )

	panel:AddControl( "Checkbox", { Label = "#tool.rb655_lightsaber.DarkInner", Command = "rb655_lightsaber_dark" } )
	panel:AddControl( "Checkbox", { Label = "#tool.rb655_lightsaber.StartEnabled", Command = "rb655_lightsaber_starton" } )

	panel:AddControl( "Slider", {Label = "#tool.rb655_lightsaber.bladeW", Type = "Float", Min = 2, Max = 4, Command = "rb655_lightsaber_bladew"} )
	panel:AddControl( "Slider", {Label = "#tool.rb655_lightsaber.bladeL", Type = "Float", Min = 32, Max = 64, Command = "rb655_lightsaber_bladel"} )

	panel:AddControl( "ListBox", { Label = "#tool.rb655_lightsaber.HumSound", Options = list.Get( "rb655_LightsaberHumSounds" ) } )
	panel:AddControl( "ListBox", { Label = "#tool.rb655_lightsaber.SwingSound", Options = list.Get( "rb655_LightsaberSwingSounds" ) } )
	panel:AddControl( "ListBox", { Label = "#tool.rb655_lightsaber.IgniteSound", Options = list.Get( "rb655_LightsaberIgniteSounds" ) } )

	panel:AddControl( "Checkbox", { Label = "#tool.rb655_lightsaber.HudBlur", Command = "rb655_lightsaber_hud_blur" } )
end
