util.AddNetworkString("hg_armor_sync")
util.AddNetworkString("hg_armor_action")

local equipSounds = {"snds_jack_gmod/equip1.wav", "snds_jack_gmod/equip2.wav", "snds_jack_gmod/equip3.wav", "snds_jack_gmod/equip4.wav", "snds_jack_gmod/equip5.wav"}

local armorIDCounter = 0

function hg.NewArmorID()
	armorIDCounter = armorIDCounter + 1

	return tostring(armorIDCounter)
end

local function isBuckshot(dmginfo)
	local ammo = dmginfo:GetAmmoType()

	return ammo and game.GetAmmoName(ammo) == "Buckshot"
end

local function isDamageType(dmginfo, typ)
	if typ == DMG_BULLET and isBuckshot(dmginfo) then return false end
	if typ == DMG_BUCKSHOT and isBuckshot(dmginfo) then return true end

	return dmginfo:IsDamageType(typ)
end

local function isOneOfTypes(dmginfo, types)
	for _, typ in ipairs(types) do
		if isDamageType(dmginfo, typ) then return true end
	end

	return false
end

local function writeArmor(ply)
	net.WriteEntity(ply)
	net.WriteTable(ply.hgArmor)
end

function hg.SyncArmor(ply)
	local armor = ply.hgArmor
	if not armor then return end

	armor.effects = {}
	armor.mskmat = nil
	armor.sndlop = nil

	for _, item in pairs(armor.items) do
		local info = hg.GetArmorInfo(item)

		if info.eff then
			for name, mag in pairs(info.eff) do
				armor.effects[name] = isnumber(mag) and (armor.effects[name] or 0) + mag or mag
			end
		end

		if info.mskmat and info.mskmat ~= "" then armor.mskmat = info.mskmat end
		if info.sndlop and info.sndlop ~= "" then armor.sndlop = info.sndlop end
	end

	net.Start("hg_armor_sync")
	writeArmor(ply)
	net.Broadcast()
end

function hg.CalcArmorSpeed(ply)
	local weight = 0

	for _, item in pairs(ply.hgArmor.items) do
		weight = weight + hg.ArmorTable[item.name].wgt
	end

	ply.hgArmor.totalWeight = weight
	ply.hgArmor.speedfrac = math.Clamp(1 - .8 * weight / 250, .05, 1)
end

local function updateArmor(ply)
	hg.CalcArmorSpeed(ply)
	hg.SyncArmor(ply)
end

function hg.RemoveArmor(ply, id, broken)
	local item = ply.hgArmor and ply.hgArmor.items[id]
	if not item then return end

	local info = hg.ArmorTable[item.name]

	if not broken then
		timer.Simple(math.Rand(0, .5), function()
			if not IsValid(ply) then return end

			ply:EmitSound(info.snds and info.snds.uneq or equipSounds[math.random(#equipSounds)], 60, math.random(80, 120))
		end)
	end

	local ent

	if not broken then
		ent = ents.Create(info.ent)
		ent:SetPos(ply:GetShootPos() + ply:GetAimVector() * 30 + VectorRand() * math.random(1, 20))
		ent:SetAngles(AngleRand())
		ent.ArmorDurability = item.dur
		ent.ArmorID = id
		ent.ArmorColor = item.col
		ent:SetColor(item.col)
		ent:Spawn()
		ent:Activate()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then phys:SetVelocity(ply:GetVelocity()) end
	end

	hook.Run("HG_ArmorRemove", ply, item, info, ent)

	ply.hgArmor.items[id] = nil

	updateArmor(ply)
end

local function findConflict(items, newInfo)
	for id, item in pairs(items) do
		for slot in pairs(hg.ArmorTable[item.name].slots) do
			if newInfo.slots[slot] then return id end
		end
	end
end

function hg.EquipArmor(ply, nameOrEnt, color)
	if hook.Run("HG_ShouldEquipArmor", ply) ~= nil then return end

	local name, id, dur, col

	if isstring(nameOrEnt) then
		name = nameOrEnt
		id = hg.NewArmorID()
		dur = hg.ArmorTable[name].dur
		col = color or Color(128, 128, 128)
	else
		if not IsValid(nameOrEnt) then return end

		name = nameOrEnt.ArmorName
		id = nameOrEnt.ArmorID or hg.NewArmorID()
		dur = nameOrEnt.ArmorDurability or hg.ArmorTable[name].dur
		col = nameOrEnt:GetColor()

		nameOrEnt:Remove()
	end

	local info = hg.ArmorTable[name]
	if not info then return end

	local conflict = findConflict(ply.hgArmor.items, info)

	while conflict do
		hg.RemoveArmor(ply, conflict)
		conflict = findConflict(ply.hgArmor.items, info)
	end

	local item = {
		name = name,
		dur = dur,
		col = col,
		id = id,
		tgl = false
	}

	ply.hgArmor.items[id] = item

	ply:EmitSound(info.snds and info.snds.eq or equipSounds[math.random(#equipSounds)], 60, math.random(80, 120))

	hook.Run("HG_ArmorEquip", ply, item, info)

	updateArmor(ply)
end

local function isHitToFace(ply, dmginfo)
	local dmgDir = dmginfo:GetDamageForce():GetNormalized()

	return -math.deg(math.asin(dmgDir:Dot(ply:GetAimVector()))) > 45
end

local hitgroupSlots = {
	[HITGROUP_CHEST] = {chest = 1},
	[HITGROUP_GENERIC] = {chest = 1},
	[HITGROUP_STOMACH] = {abdomen = .5, pelvis = .5},
	[HITGROUP_RIGHTARM] = {rightshoulder = .5, rightforearm = .5},
	[HITGROUP_LEFTARM] = {leftshoulder = .5, leftforearm = .5},
	[HITGROUP_RIGHTLEG] = {rightthigh = .5, rightcalf = .5},
	[HITGROUP_LEFTLEG] = {leftthigh = .5, leftcalf = .5}
}

local faceSlots = {eyes = .5, mouthnose = .5}
local headSlots = {head = 1}

local nonProtectiveSlots = {ears = true, back = true, waist = true}

-- Returns protection given by armor covering the slot, damaging that armor along the way
local function slotProtection(ply, slot, dmginfo, dmgAmt, protectionMul, cumulative)
	local protection, broke = 0, false
	local hitInfo, hitItem

	for id, item in pairs(ply.hgArmor.items) do
		local info = hg.GetArmorInfo(item)
		local coverage = info.slots[slot]
		if not coverage or nonProtectiveSlots[slot] then continue end

		for dmgType, dmgProtection in pairs(info.def) do
			if not isDamageType(dmginfo, dmgType) then continue end

			hitInfo, hitItem = info, item
			protection = protection + dmgProtection * coverage * protectionMul

			if cumulative then
				local divisor = 0

				for armorSlot in pairs(info.slots) do
					if not nonProtectiveSlots[armorSlot] then divisor = divisor + 1 end
				end

				protection = protection / math.max(divisor, 1)
			end

			if not isOneOfTypes(dmginfo, hg.BiologicalDmgTypes) then
				local armorDmg = protection * dmgAmt

				if dmgType == DMG_BUCKSHOT then armorDmg = armorDmg / 2.5 end

				item.dur = item.dur - armorDmg

				if item.dur <= 0 then
					hg.RemoveArmor(ply, id, true)
					broke = true
				end
			end

			break
		end
	end

	return protection, broke, hitInfo, hitItem
end

-- Returns the armor pieces hit by a locational (bullet) hit as {[info] = item}
function hg.ArmorDamage(ply, hitgroup, dmginfo)
	local hit = {}
	local armor = ply.hgArmor
	if not armor or table.IsEmpty(armor.items) then return hit end

	local slots = hitgroup == HITGROUP_HEAD and (isHitToFace(ply, dmginfo) and faceSlots or headSlots) or hitgroupSlots[hitgroup]
	if not slots then return hit end

	local dmgAmt = dmginfo:GetDamage()

	for slot, relevance in pairs(slots) do
		local _, _, info, item = slotProtection(ply, slot, dmginfo, dmgAmt, relevance, false)
		if info then hit[info] = item end
	end

	return hit
end

local function fullBodyDamage(ply, dmginfo, biological)
	local protection, dmgAmt = 0, dmginfo:GetDamage()

	for slot, healthMul in pairs(hg.ArmorSlotHealthMults) do
		protection = protection + slotProtection(ply, slot, dmginfo, dmgAmt, biological and 1 or healthMul, biological)
	end

	local mul = 1 - protection

	dmginfo:ScaleDamage(mul < .001 and 0 or mul)
end

hook.Add("EntityTakeDamage", "hg_armor_fullbody", function(ply, dmginfo)
	if not ply:IsPlayer() or not ply.hgArmor or table.IsEmpty(ply.hgArmor.items) then return end
	if isOneOfTypes(dmginfo, hg.LocationalDmgTypes) then return end

	if isOneOfTypes(dmginfo, hg.FullBodyDmgTypes) then
		fullBodyDamage(ply, dmginfo, false)
	elseif isOneOfTypes(dmginfo, hg.BiologicalDmgTypes) then
		fullBodyDamage(ply, dmginfo, true)
	end
end)

hook.Add("PlayerSpawn", "hg_armor", function(ply)
	-- Getting up from fake respawns the player, armor has to survive that
	if hg.FakeRespawning then return end

	ply.hgArmor = {
		items = {},
		effects = {},
		totalWeight = 0
	}

	hg.SyncArmor(ply)
end)

hook.Add("PlayerInitialSpawn", "hg_armor", function(newPly)
	timer.Simple(5, function()
		if not IsValid(newPly) then return end

		for _, ply in player.Iterator() do
			if ply == newPly or not ply.hgArmor then continue end

			net.Start("hg_armor_sync")
			writeArmor(ply)
			net.Send(newPly)
		end
	end)
end)

hook.Add("PlayerFootstep", "hg_armor", function(ply)
	if ply.hgArmor and ply.hgArmor.totalWeight >= 50 then ply:EmitSound("snd_jack_gear" .. math.random(1, 6) .. ".wav", 58, math.random(70, 130)) end
end)

local ARMOR_ACTION_DROP, ARMOR_ACTION_TOGGLE = 1, 2

net.Receive("hg_armor_action", function(_, ply)
	if not ply:Alive() or not ply.hgArmor then return end

	local action, id = net.ReadUInt(2), net.ReadString()

	if action == ARMOR_ACTION_TOGGLE and id == "" then id = hg.GetArmorInSlot(ply, "eyes") end

	local item = id and ply.hgArmor.items[id]
	if not item then return end

	if action == ARMOR_ACTION_DROP then
		hg.RemoveArmor(ply, id)
	elseif action == ARMOR_ACTION_TOGGLE and hg.ArmorTable[item.name].tgl then
		item.tgl = not item.tgl

		ply:EmitSound(equipSounds[math.random(#equipSounds)], 60, math.random(80, 120))

		hg.SyncArmor(ply)
	end
end)
