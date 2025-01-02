hook.Add("PlayerSpawn", "Damage", function(ply)
	if PLYSPAWN_OVERRIDE then return end

	ply.Organs = {
		["brain"] = 5,
		["lungs"] = 40,
		["liver"] = 10,
		["stomach"] = 30,
		["intestines"] = 30,
		["heart"] = 20,
		["artery"] = 1,
		["spine"] = 5
	}

	ply.InternalBleeding = nil
	ply.InternalBleeding2 = nil
	ply.InternalBleeding3 = nil
	ply.InternalBleeding4 = nil
	ply.InternalBleeding5 = nil
	ply.arterybleeding = false
	ply.brokenspine = false

	ply.Attacker = nil
	ply.KillReason = nil

	ply.msgLeftArm = 0
	ply.msgRightArm = 0
	ply.msgLeftLeg = 0
	ply.msgRightLeg = 0

	ply.LastDMGInfo = nil
	ply.LastHitPhysicsBone = nil
	ply.LastHitBoneName = nil
	ply.LastHitGroup = nil
	ply.LastAttacker = nil
end)

local filterEnt

local function filter(ent)
	return ent == filterEnt
end

local util_TraceLine = util.TraceLine

function GetPhysicsBoneDamageInfo(ent, dmgInfo)
	local pos = dmgInfo:GetDamagePosition()
	local dir = dmgInfo:GetDamageForce():GetNormalized()
	dir:Mul(1024 * 8)

	local tr = {}
		tr.start = pos
		tr.endpos = pos + dir
		tr.filter = filter
		filterEnt = ent
		tr.ignoreworld = true
	local result = util_TraceLine(tr)

	if result.Entity ~= ent then
		tr.endpos = pos - dir

		return util_TraceLine(tr).PhysicsBone
	else
		return result.PhysicsBone
	end
end


-- Урон по разным костям регдолла
hook.Add("EntityTakeDamage", "ragdamage", function(ent, dmginfo)
	if IsValid(ent:GetPhysicsObject()) and dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_CLUB + DMG_GENERIC + DMG_BLAST) then
		ent:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamageForce():GetNormalized() * math.min(dmginfo:GetDamage() * 10, 3000), dmginfo:GetDamagePosition())
	end

	local ply = RagdollOwner(ent) or ent

	if ent.IsArmor then
		ply = ent.Owner
		ent = ply:GetNWEntity("Ragdoll") or ply
	end

	if not ply or not ply:IsPlayer() or not ply:Alive() or ply:HasGodMode() then return end

	local rag = ply ~= ent and ent

	if rag and dmginfo:IsDamageType(DMG_CRUSH) and att and att:IsRagdoll() then
		dmginfo:SetDamage(0)

		return true
	end

	local physics_bone = GetPhysicsBoneDamageInfo(ent, dmginfo)

	--[[
		if not bone then
		local att = dmginfo:GetAttacker()
		if IsValid(att) and att:IsPlayer() then att:ChatPrint("Незарегало.") end
		ply:ChatPrint("Незарегало.")
		print("незарегало.")
		return
	end
	--]]

	local hitgroup
	local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(physics_bone))
	ply.LastHitBoneName = bonename

	if bonetohitgroup[bonename] then
		hitgroup = bonetohitgroup[bonename]
	end

	local mul = RagdollDamageBoneMul[hitgroup]

	if rag and mul then
		dmginfo:ScaleDamage(mul)
	end

	local entAtt = dmginfo:GetAttacker()
	local att = (entAtt:IsPlayer() and entAtt:Alive() and entAtt) or (entAtt:GetClass() == "wep" and entAtt:GetOwner()) --RagdollOwner(entAtt) or -- or
	att = dmginfo:GetDamageType() ~= DMG_CRUSH and att or ply.LastAttacker

	ply.LastAttacker = att
	ply.LastHitGroup = hitgroup

	local armors = JMod.LocationalDmgHandling(ply, hitgroup, dmginfo)
	local armorMul, armorDur = 1, 0
	local haveHelmet

	for armorInfo, armorData in pairs(armors) do
		local dur = armorData.dur / armorInfo.dur
		local slots = armorInfo.slots

		if dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then
			if slots.mouthnose or slots.head then
				sound.Emit(ent, "player/bhit_helmet-1.wav", 90)

				haveHelmet = true
			elseif slots.leftshoulder or slots.rightshoulder or slots.leftforearm or slots.rightforearm or slots.leftthigh or slots.rightthigh or slots.leftcalf or slots.rightcalf then
				sound.Emit(ent, "snd_jack_hmcd_ricochet_" .. math.random(1, 2) .. ".wav", 90)
			else
				sound.Emit(ent, "player/kevlar" .. math.random(1, 6) .. ".wav", 90)
			end
		end

		if dur >= 0.25 then
			armorDur = (armorData.dur / 100) * dur
			armorMul = math.max(1 - armorDur, 0.25)

			break
		end
	end

	dmginfo:SetDamage(dmginfo:GetDamage() * armorMul)

	local dmginf = DamageInfo()
		dmginf:SetAttacker(dmginfo:GetAttacker())
		dmginf:SetDamage(dmginfo:GetDamage())
		dmginf:SetDamageType(dmginfo:GetDamageType())
		dmginf:SetDamagePosition(dmginfo:GetDamagePosition())
		dmginf:SetDamageForce(dmginfo:GetDamageForce())
	ply.LastDMGInfo = dmginf

	dmginfo:ScaleDamage(0.5)

	hook.Run("HomigradDamage", ply, hitgroup, dmginfo, rag, armorMul, armorDur, haveHelmet)

	dmginfo:ScaleDamage(0.2)

	if rag then
		if dmginfo:GetDamageType() == DMG_CRUSH then
			dmginfo:ScaleDamage(1 / 40 / 15)
		end

		ply:SetHealth(ply:Health() - dmginfo:GetDamage())

		if ply:Health() <= 0 then
			ply:Kill()
		end
	end
end)

local bonenames = {
	["ValveBiped.Bip01_Head1"] = "hg.bones.head",
	["ValveBiped.Bip01_Spine"] = "hg.bones.spine",
	["ValveBiped.Bip01_Spine2"] = "hg.bones.spine",
	["ValveBiped.Bip01_Pelvis"] = "hg.bones.pelvis",

	["ValveBiped.Bip01_R_Hand"] = "hg.bones.rhand",
	["ValveBiped.Bip01_R_Forearm"] = "hg.bones.rforearm",
	["ValveBiped.Bip01_R_Shoulder"] = "hg.bones.rshoulder",
	["ValveBiped.Bip01_R_UpperArm"] = "hg.bones.rshoulder",
	["ValveBiped.Bip01_R_Elbow"] = "hg.bones.relbow",

	["ValveBiped.Bip01_R_Foot"] = "hg.bones.rfoot",
	["ValveBiped.Bip01_R_Thigh"] = "hg.bones.rthigh",
	["ValveBiped.Bip01_R_Calf"] = "hg.bones.rcalf",

	["ValveBiped.Bip01_L_Hand"] = "hg.bones.lhand",
	["ValveBiped.Bip01_L_Forearm"] = "hg.bones.lforearm",
	["ValveBiped.Bip01_L_Shoulder"] = "hg.bones.lshoulder",
	["ValveBiped.Bip01_L_UpperArm"] = "hg.bones.lshoulder",
	["ValveBiped.Bip01_L_Elbow"] = "hg.bones.lelbow",

	["ValveBiped.Bip01_L_Foot"] = "hg.bones.lfoot",
	["ValveBiped.Bip01_L_Thigh"] = "hg.bones.lthigh",
	["ValveBiped.Bip01_L_Calf"] = "hg.bones.lcalf"
}

local deathreasons = {
	["blood"] = "Вы умерли от кровопотери.",
	["pain"] = "Вы умерли от болевого шока.",
	["painlosing"] = "Вы умерли от передоза обезболивающим.",
	["adrenaline"] = "Вы умерли от передоза адреналином.",
	["killyourself"] = "Вы совершили суицид.",
	["hungry"] = "Вы умерли от голода.",
	["virus"] = "Вы умерли от заражения.",
	["poison"] = "Вы были отравлены."
}

hook.Add("PlayerDeath", "plymessage", function(ply, inflictor, attacker)
	local att = ply.LastAttacker
	local boneName = bonenames[ply.LastHitBoneName]
	local add = boneName and " в " .. boneName or ""
	local reason = ply.KillReason
	local dmginfo = ply.LastDMGInfo

	if ply == att then
		ply:ChatPrint("Вы совершили самоубийство" .. add)
	elseif reason then -- TODO: нетворк
		ply:ChatPrint(deathreasons[reason] or "Вы умерли при загадочных обстоятельствах.")
	elseif att then
		local dmgtype = "от ранения"
		dmgtype = dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) and (dmginfo:IsDamageType(DMG_BUCKSHOT) and "от ранения осколками/дробью" or "от огнестрельного ранения") or dmginfo:IsExplosionDamage() and "от взрыва" or dmginfo:IsDamageType(DMG_SLASH) and "от ножевого ранения" or dmginfo:IsDamageType(DMG_CLUB + DMG_GENERIC) and "от ранения тупым оружием" or dmgtype

		ply:ChatPrint("Вы умерли " .. dmgtype .. add)
		ply:ChatPrint("Вас убил игрок " .. att:Name())

		player.EventPoint(att:GetPos(), "hitgroup killed", 512, att, ply)
	else
		ply:ChatPrint("Вы умерли при загадочных обстоятельствах")
	end
end)