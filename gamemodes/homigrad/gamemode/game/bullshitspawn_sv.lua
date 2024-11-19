
KOROBKA_HUYNYI = {
    "models/props_junk/cardboard_box001a.mdl",
    "models/props_junk/cardboard_box001b.mdl",
    "models/props_junk/cardboard_box002a.mdl",
    "models/props_junk/cardboard_box002b.mdl",
    "models/props_junk/cardboard_box003a.mdl",
    "models/props_junk/cardboard_box003b.mdl",
    "models/props_junk/wood_crate001a.mdl",
    "models/props_junk/wood_crate001a_damaged.mdl",
    "models/props_junk/wood_crate001a_damagedmax.mdl",
    "models/props_junk/wood_crate002a.mdl",
    "models/props_c17/furnituredrawer001a.mdl",
    "models/props_c17/furnituredrawer003a.mdl",
    "models/props_c17/furnituredresser001a.mdl",
    "models/props_c17/woodbarrel001.mdl",
    "models/props_lab/dogobject_wood_crate001a_damagedmax.mdl",
    "models/items/item_item_crate.mdl",
    "models/props/de_inferno/claypot02.mdl",
    "models/props/de_inferno/claypot01.mdl",
    "models/props_junk/terracotta01.mdl",
    "models/props_combine/breenbust.mdl",
    "models/props_interiors/Furniture_chair01a.mdl",
    "models/props_c17/FurnitureShelf001a.mdl",
    "models/props_junk/cardboard_box004a.mdl",
    "models/props_junk/wood_pallet001a.mdl",
    "models/props_junk/gascan001a.mdl",
    "models/props_wasteland/cafeteria_bench001a.mdl",
    "models/props_c17/furnituredrawer002a.mdl",
    "models/props_interiors/furniture_cabinetdrawer02a.mdl",
    "models/props_c17/furniturecupboard001a.mdl",
    "models/props_interiors/furniture_desk01a.mdl",
    "models/props_interiors/furniture_vanity01a.mdl"
}


local KOROBKA_HUYNYI_LOOKUP = {}
for _, mdl in ipairs(KOROBKA_HUYNYI) do 
    KOROBKA_HUYNYI_LOOKUP[mdl] = true 
end


local weaponscommon = { "weapon_binokle", "weapon_molotok", "ent_drop_flashlight", "weapon_knife", "weapon_pipe", "splint", "med_band_small", "med_band_big" }
local weaponsuncommon = { "weapon_hg_shovel", "weapon_hg_fubar", "weapon_bat", "weapon_hg_metalbat", "weapon_hg_hatchet", "*ammo*", "ent_jack_gmod_ezarmor_respirator", "ent_jack_gmod_ezarmor_lhead", "medkit" }
local weaponsrare = {  "weapon_t", "weapon_hg_molotov", "*ammo*", "weapon_hg_sleagehammer", "weapon_hg_fireaxe", "ent_jack_gmod_ezarmor_gasmask", "ent_jack_gmod_ezarmor_mltorso" }
local weaponsveryrare = { "weapon_m3super", "weapon_beretta", "ent_jack_gmod_ezarmor_mtorso", "ent_jack_gmod_ezarmor_mhead" }
local weaponslegendary = { "weapon_xm1014", "weapon_ar15", "weapon_civil_famas", "weapon_glock", "weapon_remington870",}


local ammos = { "ent_ammo_.44magnum", "ent_ammo_12/70gauge", "ent_ammo_762x39mm", "ent_ammo_556x45mm", "ent_ammo_9х19mm" }


local function randomLoot()
    local func = TableRound().ShouldSpawnLoot

    if func then
        local should, loot = func()

        if not should then return end
        
        if loot then return loot end
    end

    local gunchance = math.random(1, 200)
    if gunchance < 3 then
        return table.Random(weaponslegendary)
    elseif gunchance < 12 then
        return table.Random(weaponsveryrare)
    elseif gunchance < 30 then
        return table.Random(weaponsrare)
    elseif gunchance < 90 then
        return table.Random(weaponsuncommon)
    else
        return table.Random(weaponscommon)
    end
end


hook.Add("PropBreak", "homigrad", function(att, ent)
    if GetConVar("sv_construct"):GetBool() == false then
        if not KOROBKA_HUYNYI_LOOKUP[ent:GetModel()] then return end

        local posSpawn = ent:GetPos() + ent:OBBCenter()
        local randomWep, type1 = randomLoot()

        if randomWep == "*ammo*" then
            if IsValid(att) then
                local ammoType
                for _, wep in RandomPairs(att:GetWeapons()) do
                    ammoType = wep:GetPrimaryAmmoType()
                    if ammoType and ammoType > 0 then
                        randomWep = "item_ammo_" .. string.lower(game.GetAmmoName(ammoType) or "")
                        break
                    end
                end
                if not ammoType then
                    randomWep = table.Random(ammos)
                end
            else
                randomWep = table.Random(ammos)
            end
        end
        

        local loot = ents.Create(randomWep or "prop_physics")
        if not IsValid(loot) then return end
        loot:SetPos(posSpawn)
        loot:Spawn()
        loot.Spawned = true
    else
        return
    end
end)


local angZero = Angle(0, 0, 0)
local vecHull = Vector(0, 0, 0)
local trCheck = {
    mask = MASK_SOLID,
    mins = -vecHull,
    maxs = vecHull,
}

local function MakeRandomSpawns(basepoints, iterations, maxiterations, tbl)
    if iterations >= maxiterations then return tbl end
    iterations = iterations + 1

    local vecRand = VectorRand(-2048, 2048)
    vecRand[3] = math.random(8) == 1 and math.abs(vecRand[3]) / math.random(2) or 0
    local tr = util.QuickTrace(basepoints[math.random(#basepoints)] + vecRand, -vector_up * 256)

    if tr.Hit and not tr.HitSky and not tr.StartedSolid and not (tr.HitTexture == "**studio**" or tr.HitTexture == "**empty**" or tr.HitTexture == "TOOLS/TOOLSNODRAW") then
        local pos = tr.HitPos + vector_up * 16

        trCheck.start = tr.HitPos
        trCheck.endpos = tr.HitPos + vector_up * 36

        local tr2 = util.TraceLine(trCheck)

        if not tr2.Hit and not tr2.StartedSolid and not (tr2.HitTexture == "**studio**") then
            table.insert(basepoints, pos)
            table.insert(tbl, pos)
        end
    end
    
    return MakeRandomSpawns(basepoints, iterations, maxiterations, tbl)
end


local spawns = {}

local function cacheSpawns()
    spawns = {}
    for _, ent in ipairs(ents.FindByClass("info_*")) do
        table.insert(spawns, ent:GetPos())
    end

    local navmeshareas = navmesh.GetAllNavAreas()
    for _, k in pairs(navmeshareas) do
        table.insert(spawns, k:GetCenter())
    end

    local tbladd = MakeRandomSpawns(spawns, 0, 500, {})
    table.Add(spawns, tbladd)
end

function hg.CacheRandomSpawns()
    cacheSpawns()
end

function hg.RandomSpawns()
    return spawns
end

hook.Add("InitPostEntity", "CacheSpawnPoints", function()
    cacheSpawns()
end)

hook.Add("Boxes Think", "SpawnBoxes", function()
    if #player.GetAll() == 0 or not roundActive or #spawns == 0 then return end
    
    local randomWep = randomLoot()
    if not randomWep then return end
    local box = ents.Create(randomWep)

    if not IsValid(box) then return end

    local spawnPos = spawns[math.random(#spawns)]
    if spawnPos then
        box:SetPos(spawnPos + Vector(0, 0, 32))
        box:Spawn()
        box.Spawned = true
    else
        print("Error: spawn position not found.")
    end
end)


hook.Add("PostCleanupMap", "addboxs", function()
    cacheSpawns()

    timer.Create("SpawnTheBoxes", 5, 0, function()
        hook.Run("Boxes Think")
    end)
end)

timer.Create("SpawnTheBoxes", 5, 0, function()
    hook.Run("Boxes Think")
end)
