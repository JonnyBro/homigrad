boxes = {"models/props_junk/cardboard_box001a.mdl", "models/props_junk/cardboard_box001b.mdl", "models/props_junk/cardboard_box002a.mdl", "models/props_junk/cardboard_box002b.mdl", "models/props_junk/cardboard_box003a.mdl", "models/props_junk/cardboard_box003b.mdl", "models/props_junk/wood_crate001a.mdl", "models/props_junk/wood_crate001a_damaged.mdl", "models/props_junk/wood_crate001a_damagedmax.mdl", "models/props_junk/wood_crate002a.mdl", "models/props_lab/dogobject_wood_crate001a_damagedmax.mdl", "models/items/item_item_crate.mdl", "models/props_junk/wood_crate002a.mdl", "models/props_junk/wood_crate001a_damagedmax.mdl", "models/props_junk/cardboard_box004a.mdl",}

local newTbl = {}

for _, mdl in pairs(boxes) do
	newTbl[mdl] = true
end

local weaponscommon = {"weapon_binokle", "weapon_molotok", "ent_drop_flashlight", "weapon_knife", "weapon_pipe", "med_band_small", "med_band_big", "blood_bag", "*ammo*"}
local weaponsuncommon = {"weapon_glock18", "weapon_per4ik", "weapon_hg_crowbar", "weapon_hg_fubar", "weapon_bat", "weapon_hg_metalbat", "weapon_hg_hatchet", "weapon_doublebarrel", "*ammo*", "ent_jack_gmod_ezarmor_respirator", "ent_jack_gmod_ezarmor_lhead", "medkit"}
local weaponsrare = {"weapon_beretta", "weapon_remington870", "weapon_glock", "weapon_t", "weapon_hg_molotov", "*ammo*", "weapon_hg_sleagehammer", "weapon_hg_fireaxe", "ent_jack_gmod_ezarmor_gasmask", "ent_jack_gmod_ezarmor_mltorso"}
local weaponsveryrare = {"weapon_m3super", "ent_jack_gmod_ezarmor_mtorso", "ent_jack_gmod_ezarmor_mhead"}
local weaponslegendary = {"weapon_xm1014", "weapon_ar15", "weapon_civil_famas"}
local ammos = {"ent_ammo_.44magnum", "ent_ammo_12/70gauge", "ent_ammo_762x39mm", "ent_ammo_556x45mm", "ent_ammo_9х19mm"}

hook.Add("PropBreak", "homigrad", function(att, ent)
	if not newTbl[ent:GetModel()] then return end

	local func = TableRound().ShouldSpawnLoot
	if not func then return end

	local result, spawnEnt, type1 = TableRound().ShouldSpawnLoot()
	if result == false then return end

	local posSpawn = ent:GetPos() + ent:OBBCenter()
	local ent, type1

	if type(spawnEnt) ~= "string" then
		local gunchance = math.random(0, 100)
		local entName

		if gunchance < 2 then
			entName = table.Random(weaponslegendary)
			type1 = "legend"
		elseif gunchance < 5 then
			entName = table.Random(weaponsveryrare)
			type1 = "veryrare"
		elseif gunchance < 15 then
			entName = table.Random(weaponsrare)
			type1 = "rare"
		elseif gunchance < 35 then
			entName = table.Random(weaponsuncommon)
			type1 = "uncommon"
		elseif gunchance < 55 then
			entName = table.Random(weaponscommon)
			type1 = "common"
		end

		if entName then
			if math.random(1, 1000) == 1000 then
				for i = 1, math.random(3, 4) do
					local ent = ents.Create("ent_jack_gmod_ezcheese")
					ent:SetPos(posSpawn)
					ent:Spawn()
					ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				end

				local ent = ents.Create("weapon_physgun")
				ent:SetPos(posSpawn)
				ent:Spawn()

				return
			end

			if entName == "*ammo*" then
				if IsValid(att) then
					for i, wep in RandomPairs(att:GetWeapons()) do
						if wep:GetMaxClip1() > 0 then
							entName = "item_ammo_" .. string.lower(game.GetAmmoName(wep:GetPrimaryAmmoType()))
							break
						end
					end

					ent = ents.Create(entName)

					if not IsValid(ent) then
						entName = table.Random(ammos)
					end
				else
					entName = table.Random(ammos)
					ent = ents.Create(entName)
				end
			else
				ent = ents.Create(entName)
			end

			if not IsValid(ent) then return end

			ent:SetPos(posSpawn)
			ent:Spawn()

			ent.Spawned = true
		end
	else
		ent = ents.Create(spawnEnt)
		if not IsValid(ent) then return end

		ent:SetPos(posSpawn)
		ent:Spawn()

		ent.Spawned = true
	end

	if type1 then
		--sound.Emit(ent,sndsDrop[type1],50,0.5) -- круто на наверное такое не нужно
	end
end)

local spawns = {}

for _, ent in pairs(ents.FindByClass("info_*")) do
	table.insert(spawns, ent:GetPos())
end

hook.Add("PostCleanupMap", "addboxs", function()
	spawns = {}

	for i, ent in pairs(ents.FindByClass("info_*")) do
		table.insert(spawns, ent:GetPos())
	end

	if timer.Exists("SpawnTheBoxes") then
		timer.Remove("SpawnTheBoxes")
	end

	timer.Create("SpawnTheBoxes", 30, 0, function()
		hook.Run("Boxes Think")
	end)
end)

if timer.Exists("SpawnTheBoxes") then
	timer.Remove("SpawnTheBoxes")
end

timer.Create("SpawnTheBoxes", 30, 0, function()
	hook.Run("Boxes Think")
end)

local function randomLoot()
	local gunchance = math.random(1, 100)
	local entName = false

	if gunchance < 2 then
		entName = table.Random(weaponslegendary)
	elseif gunchance < 5 then
		entName = table.Random(weaponsveryrare)
	elseif gunchance < 15 then
		entName = table.Random(weaponsrare)
	elseif gunchance < 25 then
		entName = table.Random(weaponsuncommon)
	elseif gunchance < 35 then
		entName = table.Random(weaponscommon)
	end

	local func = TableRound().ShouldSpawnLoot
	local should, entNamer

	if func then
		should, entNamer = func()
	end

	entName = (should and entNamer) or entName

	return entName
end

local vec = Vector(0, 0, 32)

hook.Add("Boxes Think", "SpawnBoxes", function()
	if #player.GetAll() == 0 or not roundActive then return end

	local func = TableRound().ShouldSpawnLoot
	if func and func() == false then return end

	local randomWep = randomLoot()
	local ent = ents.Create((not randomWep and "prop_physics") or randomWep)

	print(randomLoot)
	print(ent)

	if randomWep then
		ent:SetModel(boxes[math.random(#boxes)])
	end

	if IsValid(ent) then
		ent:SetPos(spawns[math.random(#spawns)] + vec)
		ent:Spawn()
	end
end)