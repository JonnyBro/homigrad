function tdm.SpawnsTwoCommand()
	local spawnsT = ReadDataMap("spawnpointst")
	local spawnsCT = ReadDataMap("spawnpointsct")

	return spawnsT, spawnsCT
end

function tdm.SpawnCommand(tbl, aviable, func, funcShould)
	for _, ply in RandomPairs(tbl) do
		if funcShould and funcShould(ply) ~= nil then continue end

		if ply:Alive() then ply:KillSilent() end
		if func then func(ply) end

		ply:Spawn()

		ply.allowFlashlights = true

		if #aviable > 0 then
			local key = math.random(#aviable)
			local point = ReadPoint(aviable[key])

			if point then
				ply:SetPos(point[1])

				table.remove(aviable, key)
			end
		end
	end
end

function tdm.DirectOtherTeam(start, min, max)
	max = max or min

	for i = start, team.MaxTeams do
		for _, ply in pairs(team.GetPlayers(i)) do
			ply:SetTeam(math.random(min, max))
		end
	end
end

function tdm.GetListMul(list, mul, func, max)
	local newList = {}

	mul = math.Round(#list * mul)
	mul = (max and math.max(mul, max)) or mul

	for _ = 1, mul do
		local ply = list[math.random(#list)]
		list[ply] = nil

		if func and func(ply) ~= true then continue end

		newList[#newList + 1] = ply
	end

	return newList
end

changeClass = {
	["prop_vehicle_jeep"] = "vehicle_van",
	["prop_vehcle_jeep_old"] = "vehicle_van",
	["prop_vehicle_airboat"] = "vehicle_van",
	["weapon_crowbar"] = "weapon_bat",
	["weapon_stunstick"] = "weapon_knife",
	["weapon_pistol"] = "weapon_glock",
	["weapon_357"] = "weapon_mateba",
	["weapon_shotgun"] = "weapon_remington870",
	["weapon_crossbow"] = "weapon_hg_crossbow",
	["weapon_ar2"] = "weapon_ar15",
	["weapon_smg1"] = "weapon_mp5",
	["weapon_frag"] = "weapon_hg_f1",
	["weapon_slam"] = "weapon_hg_molotov",
	["weapon_rpg"] = "ent_ammo_46x30mm",
	["item_ammo_ar2_altfire"] = "ent_ammo_762x39mm",
	["item_ammo_357"] = "ent_ammo_.44magnum",
	["item_ammo_357_large"] = "ent_ammo_.44magnum",
	["item_ammo_pistol"] = "ent_ammo_9x19mm",
	["item_ammo_pistol_large"] = "ent_ammo_9x19mm",
	["item_ammo_ar2"] = "ent_ammo_556x45mm",
	["item_ammo_ar2_large"] = "ent_ammo_556x45mm",
	["item_ammo_ar2_smg1"] = "ent_ammo_545x39mm",
	["item_ammo_ar2_large"] = "ent_ammo_556x45mm",
	["item_ammo_smg1"] = "ent_ammo_545x39mm",
	["item_ammo_smg1_large"] = "ent_ammo_762x39mm",
	["item_box_buckshot"] = "ent_ammo_12/70gauge",
	["item_box_buckshot_large"] = "ent_ammo_12/70gauge",
	["item_rpg_round"] = "ent_ammo_57x28mm",
	["item_ammo_crate"] = "ent_ammo_9x39mm",
	["item_healthvial"] = "med_band_small",
	["item_healthkit"] = "med_band_big",
	["item_healthcharger"] = "medkit",
	["item_suitcharger"] = "painkiller",
	["item_battery"] = "blood_bag",
	["weapon_alyxgun"] = {"food_fishcan", "food_lays", "food_monster", "food_spongebob_home"}
}

function tdm.RemoveItems()
	for _, ent in pairs(ents.GetAll()) do
		if IsValid(ent) and ent:GetName() == "biboran" then
			ent:Remove()
		end
	end
end

function tdm.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 4, 2))

	for _, ply in pairs(team.GetPlayers(3)) do
		ply:SetTeam(math.random(1, 2))
	end

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	local spawnsT, spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1), spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2), spawnsCT)

	tdm.CenterInit()

	bahmut.SelectRandomPlayers(team.GetPlayers(1), 2, bahmut.GiveAidPhone)
	bahmut.SelectRandomPlayers(team.GetPlayers(2), 2, bahmut.GiveAidPhone)
end

function tdm.GetCountAlive(list, func)
	local count = 0
	local result

	for _, ply in pairs(list) do
		if not IsValid(ply) then continue end

		result = func and func(ply)

		if (ply.Blood < 2500 or ply.heartstop) and ply.unconscious then continue end

		if result == true then
			count = count + 1
			continue
		elseif result == false then
			continue
		end

		if not IsCuffed(ply) and ply:Alive() then
			count = count + 1
		end
	end

	return count
end

function tdm.RoundEndCheck()
	tdm.Center()

	if roundTimeStart + roundTime - CurTime() <= 0 then return EndRound() end

	local TAlive = tdm.GetCountAlive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountAlive(team.GetPlayers(2))

	if TAlive == 0 and CTAlive == 0 then return EndRound(0) end
	if TAlive == 0 then return EndRound(2) end
	if CTAlive == 0 then return EndRound(1) end
end

function tdm.EndRoundMessage(winner)
	local tbl = TableRound()

	net.Start("hg_sendchat_format")
		net.WriteTable({
			"#hg.modes.teamwon",
			winner == 0 and "#hg.modes.draw" or tbl[tbl.teamEncoder[winner]] and tbl[tbl.teamEncoder[winner]][1] or "Something bad happened...",
		})
	net.Broadcast()
end

function tdm.EndRound(winner)
	tdm.EndRoundMessage(winner)
end

function tdm.GiveSwep(ply, togive, mulClip1)
	if not togive or not ply then return end

	mulClip1 = mulClip1 or 3

	local selector = (type(togive) == "table" and togive[math.random(#togive)]) or togive
	local wep = ply:Give(selector)

	if IsValid(wep) then
		wep:SetClip1(wep:GetMaxClip1())
		ply:GiveAmmo(wep:GetMaxClip1() * mulClip1, wep:GetPrimaryAmmoType())
	end
end

function tdm.PlayerSpawn2(ply, teamID)
	local teamTbl = tdm[tdm.teamEncoder[teamID]]
	local color = teamTbl[2]

	-- Set the player's model to the custom model if available, otherwise use a random team model
	local customModel = GetPlayerModelBySteamID(ply:SteamID())
	if customModel then
		ply:SetModel(customModel)
		ply:SetPlayerColor(color:ToVector())
	else
		ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
		ply:SetPlayerColor(color:ToVector())
	end

	for _, weapon in pairs(teamTbl.weapons) do
		ply:Give(weapon)
	end

	tdm.GiveSwep(ply, teamTbl.main_weapon)
	tdm.GiveSwep(ply, teamTbl.secondary_weapon)

	if math.random(1, 4) == 4 then ply:Give("adrenaline") end
	if math.random(1, 4) == 4 then ply:Give("morphine") end
	if math.random(1, 3) == 3 then
		if ply:Team() == 1 then ply:Give("weapon_hg_f1")
		else ply:Give("weapon_hg_rgd5") end
	end
	-- local r = math.random(1, 3)
	-- ply:Give(r == 1 and "food_fishcan" or r == 2 and "food_spongebob_home" or r == 3 and "food_lays")

	if ply:IsUserGroup("sponsor") or ply:IsUserGroup("supporterplus") or ply:IsAdmin() then
		if math.random(1, 5) == 5 then ply:Give("weapon_gear_bloxycola") end
		if math.random(1, 5) == 5 then ply:Give("weapon_gear_cheezburger") end

		ply:Give("weapon_vape")
	end

	local r = math.random(1, 2)
	JMod.EZ_Equip_Armor(ply, "Medium-Helmet", color)
	JMod.EZ_Equip_Armor(ply, (r == 1 and "Medium-Vest") or "Light-Vest", color)
end

function tdm.PlayerInitialSpawn(ply)
	ply:SetTeam(math.random(2))
end

function tdm.PlayerCanJoinTeam(ply, teamID)
	if teamID == 3 then return false end
end

function tdm.PlayerDeath(ply, inf, att)
	return false
end