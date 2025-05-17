local validUserGroup = {
	superadmin = true,
}

if SERVER then
	COMMANDS.accessspawn = {
		function(ply, args)
			local arg = tobool(args[1])
			if not arg then arg = false end

			SetGlobalBool("AccessSpawn", arg)

			PrintMessage(3, "Spawn Menu Boolean: " .. tostring(GetGlobalBool("AccessSpawn")))
		end
	}

	local function CanUseSpawnMenu(ply, class)
		local func = TableRound().CanUseSpawnMenu
		func = func and func(ply, class)
		if func ~= nil then return func end

		if IsValid(ply) and validUserGroup[ply:GetUserGroup()] and ply:Team() ~= TEAM_SPECTATOR or GetGlobalBool("AccessSpawn") or GetConVar("hg_ConstructOnly"):GetBool() then return true
		else return false end
	end

	hook.Add("PlayerSpawnVehicle", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "vehicle") end)
	hook.Add("PlayerSpawnRagdoll", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "ragdoll") end)
	hook.Add("PlayerSpawnEffect", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "effect") end)
	hook.Add("PlayerSpawnProp", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "prop") end)
	hook.Add("PlayerSpawnSENT", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "sent") end)
	hook.Add("PlayerSpawnNPC", "Cantspawnbullshit", function(ply) return CanUseSpawnMenu(ply, "npc") end)
	hook.Add("PlayerSpawnSWEP", "SpawnBlockSWEP", function(ply) return CanUseSpawnMenu(ply, "swep") end)
	hook.Add("PlayerGiveSWEP", "SpawnBlockSWEP", function(ply) return CanUseSpawnMenu(ply, "swep") end)

	local function spawn(ply, class, ent)
		local func = TableRound().CanUseSpawnMenu
		func = func and func(ply, class, ent)
	end

	hook.Add("PlayerSpawnedVehicle", "sv_round", function(ply, model, ent) spawn(ply, "vehicle", ent) end)
	hook.Add("PlayerSpawnedRagdoll", "sv_round", function(ply, model, ent) spawn(ply, "ragdoll", ent) end)
	hook.Add("PlayerSpawnedEffect", "sv_round", function(ply, model, ent) spawn(ply, "effect", ent) end)
	hook.Add("PlayerSpawnedProp", "sv_round", function(ply, model, ent) spawn(ply, "prop", ent) end)
	hook.Add("PlayerSpawnedSENT", "sv_round", function(ply, model, ent) spawn(ply, "sent", ent) end)
	hook.Add("PlayerSpawnedNPC", "sv_round", function(ply, model, ent) spawn(ply, "npc", ent) end)
else
	local function CanUseSpawnMenu()
		local ply = LocalPlayer()

		local func = TableRound().CanUseSpawnMenu
		func = func and func(LocalPlayer())
		if func ~= nil then return func end

		if IsValid(ply) and validUserGroup[ply:GetUserGroup()] and ply:Team() ~= TEAM_SPECTATOR or GetConVar("hg_ConstructOnly"):GetBool() then return true
		else return false end
	end

	hook.Add("ContextMenuOpen", "hide_spawnmenu", CanUseSpawnMenu)
	hook.Add("SpawnMenuOpen", "hide_spawnmenu", CanUseSpawnMenu)
end