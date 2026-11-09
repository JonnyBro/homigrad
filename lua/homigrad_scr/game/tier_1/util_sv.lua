local explosions = {
	["models/props_junk/gascan001a.mdl"] = true,
	["models/props_junk/propane_tank001a.mdl"] = true,
	["models/props_junk/PropaneCanister001a.mdl"] = true,
	["models/props_c17/oildrum001_explosive.mdl"] = true,
	["models/props_junk/metalgascan.mdl"] = true,
	["models/props_c17/canister02a.mdl"] = true,
	["models/props_c17/canister01a.mdl"] = true,
	["models/props_c17/oildrum001.mdl"] = true
}

hook.Add("EntityTakeDamage", "EntityDamageExample", function(target, dmginfo)
	if explosions[target:GetModel()] then
		local r = math.random(1, 55)
		if dmginfo:IsDamageType(DMG_GENERIC + DMG_SLASH + DMG_CLUB + DMG_BULLET + DMG_CRUSH + DMG_FALL) then
			dmginfo:SetDamage(0)
		elseif dmginfo:IsDamageType(DMG_BURN) and r == 55 then
			hg.ExplodeProp(target)
			target:Remove()
		elseif dmginfo:IsDamageType(DMG_BLAST) then
			hg.ExplodeProp(target)
			target:Remove()
		end
	end
end)

hook.Add("InitPostEntity", "changeperfsettings", function()
	local phys_settings = physenv.GetPerformanceSettings()
		phys_settings.LookAheadTimeObjectsVsObject = 0 -- 0.5
		phys_settings.LookAheadTimeObjectsVsWorld = 0.1 -- 1
		phys_settings.MaxAngularVelocity = 3600 -- 7272.7275390625
		phys_settings.MaxCollisionChecksPerTimestep = 100 -- 50000
		phys_settings.MaxCollisionsPerObjectPerTimestep = 4 -- 10
		phys_settings.MaxFrictionMass = 2500 -- 2500
		phys_settings.MaxVelocity = 4000 -- 4000
		phys_settings.MinFrictionMass = 100 -- 10
	physenv.SetPerformanceSettings(phys_settings)
end)