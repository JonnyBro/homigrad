hook.Add("PlayerSpawn", "Damage", function(ply)
	if PLYSPAWN_OVERRIDE then return end

	ply.organs = {
		heart = 20,
		artery = 1,
		spine = 5,
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

function GetPhysicsBoneDamageInfo(ent, dmgInfo)
	local pos = dmgInfo:GetDamagePosition()
	local dir = dmgInfo:GetDamageForce():GetNormalized()
	dir:Mul(1024 * 8)

	local tr = {}
	tr.start = pos
	tr.endpos = pos + dir
	tr.ignoreworld = true
	local result = util.TraceLine(tr)

	if result.Entity ~= ent then
		tr.endpos = pos - dir

		return util.TraceLine(tr).PhysicsBone
	else
		return result.PhysicsBone
	end
end

bonetohitgroup = {
	["ValveBiped.Bip01_Head1"] = 1,
	["ValveBiped.Bip01_R_UpperArm"] = 5,
	["ValveBiped.Bip01_R_Forearm"] = 5,
	["ValveBiped.Bip01_R_Hand"] = 5,
	["ValveBiped.Bip01_L_UpperArm"] = 4,
	["ValveBiped.Bip01_L_Forearm"] = 4,
	["ValveBiped.Bip01_L_Hand"] = 4,
	["ValveBiped.Bip01_Pelvis"] = 3,
	["ValveBiped.Bip01_Spine2"] = 2,
	["ValveBiped.Bip01_L_Thigh"] = 6,
	["ValveBiped.Bip01_L_Calf"] = 6,
	["ValveBiped.Bip01_L_Foot"] = 6,
	["ValveBiped.Bip01_R_Thigh"] = 7,
	["ValveBiped.Bip01_R_Calf"] = 7,
	["ValveBiped.Bip01_R_Foot"] = 7
}

RagdollDamageBoneMul = {
	[HITGROUP_GENERIC] = 1,
	[HITGROUP_HEAD] = 2,

	[HITGROUP_CHEST] = 1,
	[HITGROUP_STOMACH] = 1,

	[HITGROUP_LEFTARM] = 0.25,
	[HITGROUP_RIGHTARM] = 0.25,

	[HITGROUP_LEFTLEG] = 0.25,
	[HITGROUP_RIGHTLEG] = 0.25,
}

DamageBoneMul = {
	[HITGROUP_GENERIC] = 1,
	[HITGROUP_HEAD] = 2.5,

	[HITGROUP_CHEST] = 1,
	[HITGROUP_STOMACH] = 1,

	[HITGROUP_LEFTARM] = 1,
	[HITGROUP_RIGHTARM] = 1,

	[HITGROUP_LEFTLEG] = 1,
	[HITGROUP_RIGHTLEG] = 1,
}

-- Different damage to ragdoll's bones
hook.Add("EntityTakeDamage", "ragdamage", function(ent, dmginfo)
	if ent.nohook then return end

	if dmginfo:IsDamageType(DMG_CRUSH) and not ent.dodamage then
		ent.dodamage = nil
		return
	end

	if ent:GetClass() == "npc_bullseye" then
		local rag = ent.rag
		rag:TakeDamageInfo(dmginfo)

		return false
	end

	if ent:IsPlayer() and IsValid(ent.FakeRagdoll) then return end
	if ent.overridedmg then return end
	if IsValid(ent:GetPhysicsObject()) and dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_CLUB + DMG_GENERIC + DMG_BLAST) then
		ent:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamageForce():GetNormalized() * math.min(dmginfo:GetDamage() * 10, 3000), dmginfo:GetDamagePosition())
	end

	local ply = RagdollOwner(ent) or ent
	local hitarmor = false

	if ent.IsArmor then
		hitarmor = true
		ply = ent.Owner
		ent = ply:GetNWEntity("Ragdoll") or ply.FakeRagdoll or ply
	end

	if not IsValid(ent) then return end

	if not hitarmor and ent:IsRagdoll() and dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_BLAST + DMG_SLASH) then
		local effdata = EffectData()
			effdata:SetOrigin(dmginfo:GetDamagePosition())
			effdata:SetRadius(1)
			effdata:SetMagnitude(1)
			effdata:SetScale(1)
		util.Effect("BloodImpact", effdata, nil, true)
	end

	if not ply or not ply:IsPlayer() or not ply:Alive() or ply:HasGodMode() then return end

	local rag = ply:IsPlayer() and IsValid(ply.FakeRagdoll) and ply.FakeRagdoll
	if rag and dmginfo:IsDamageType(DMG_CRUSH) and att and att:IsRagdoll() then
		dmginfo:SetDamage(0)

		return true
	end

	local physics_bone = GetPhysicsBoneDamageInfo(ent, dmginfo)
	--[[
	if not physics_bone then
		local att = dmginfo:GetAttacker()
		if IsValid(att) and att:IsPlayer() then att:ChatPrint("didn't registered.") end
		ply:ChatPrint("didn't registered.")
		print("didn't registered.")
		return -- impossible
	end --]]

	local hitgroup

	local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(physics_bone))
	ply.LastHitBoneName = bonename
	if bonetohitgroup[bonename] then hitgroup = bonetohitgroup[bonename] end

	local mul = RagdollDamageBoneMul[hitgroup]

	local lastdmg = DamageInfo()
	lastdmg:SetAttacker(dmginfo:GetAttacker())
	-- lastdmg:SetInflictor(dmginfo:GetInflictor())
	lastdmg:SetDamage(dmginfo:GetDamage() * (not rag and 1 / (mul or 1) or 1))
	lastdmg:SetDamageType(dmginfo:GetDamageType())
	lastdmg:SetDamagePosition(dmginfo:GetDamagePosition())
	lastdmg:SetDamageForce(dmginfo:GetDamageForce())
	ply.LastDMGInfo = lastdmg

	if rag and mul then dmginfo:ScaleDamage(mul) end
	if DamageBoneMul[hitgroup] then dmginfo:ScaleDamage(DamageBoneMul[hitgroup]) end

	local entAtt = dmginfo:GetAttacker()
	local att = entAtt:IsPlayer() and entAtt:Alive() and entAtt or entAtt:GetClass() == "wep" and entAtt:GetOwner() -- or RagdollOwner(entAtt) or IsValid(att) and att
	att = att ~= ply and att
	-- att = ply.LastAttacker -- Made it so last attacker can only be a player

	if IsValid(att) then dmginfo:SetAttacker(att) end

	ply.LastAttacker = att
	ply.LastHitGroup = hitgroup
	ply.LastTimeAttacked = CurTime()

	dmginfo:ScaleDamage(0.01)

	local armors, _ = JMod.LocationalDmgHandling(ply, hitgroup, dmginfo)

	dmginfo:ScaleDamage(100)

	local armorMul, armorDur = 1, 0
	local haveHelmet

	for armorInfo, armorData in pairs(armors) do
		local dur = armorData.dur / armorInfo.dur
		local slots = armorInfo.slots

		if dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then
			if slots.mouthnose or slots.head then
				sound.Emit(ent, "player/bhit_helmet-1.wav", 90, 1)

				haveHelmet = true
			elseif slots.leftshoulder or slots.rightshoulder or slots.leftforearm or slots.rightforearm or slots.leftthigh or slots.rightthigh or slots.leftcalf or slots.rightcalf then
				sound.Emit(ent, "snd_jack_hmcd_ricochet_" .. math.random(1, 2) .. ".wav", 90)
			else
				sound.Emit(ent, "player/kevlar" .. math.random(1, 6) .. ".wav", 90)
			end
		end

		if dur >= 0.25 then
			armorDur = armorData.dur / 100 * dur
			-- dur = math.max(dur - 0.5, 0)
			armorMul = math.max(1 - armorDur, 0.25)

			break
		end
	end

	dmginfo:SetDamage(dmginfo:GetDamage() * armorMul)

	local att = IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker()
	if att and not att:IsNPC() then dmginfo:ScaleDamage(0.5) end

	hook.Run("HomigradDamage", ply, hitgroup, dmginfo, rag, armorMul, armorDur, haveHelmet)

	if att and not att:IsNPC() then dmginfo:ScaleDamage(0.5) end
	if dmginfo:IsDamageType(DMG_BLAST) then dmginfo:ScaleDamage(2) end

	if rag then
		if dmginfo:GetDamageType() == DMG_CRUSH then dmginfo:ScaleDamage(1 / 40 / 15) end

		ply:SetHealth(ply:Health() - dmginfo:GetDamage())
		if ply:Health() <= 0 then ply:Kill() end

		ply.overridedmg = true

		ply:TakeDamageInfo(dmginfo)

		ply.overridedmg = nil
	end
end)

local function velocityDamage(ent, data)
	local speed = (data.OurOldVelocity - data.TheirOldVelocity):Length()
	if speed < 350 then return end

	local dmg = speed / 5350 * data.DeltaTime
	dmg = dmg * math.abs(data.OurOldVelocity:GetNormalized():Dot(data.HitNormal))
	-- if dmg * 20 * 2 < 0.2 then return end

	--[[
	local bone
	for i = 0, ent:GetPhysicsObjectCount() do
		local phys = ent:GetPhysicsObjectNum(i)
		if phys == data.PhysObject then bone = i end
	end --]]

	local dmgInfo = DamageInfo()
	dmgInfo:SetDamage(dmg * 50)
	dmgInfo:SetDamageType(DMG_CRUSH)
	dmgInfo:SetAttacker(data.HitEntity)
	dmgInfo:SetDamagePosition(data.HitPos)
	dmgInfo:SetDamageForce(data.TheirOldVelocity:GetNormalized() * dmg)

	ent.dodamage = true

	ent:TakeDamageInfo(dmgInfo)
	-- ent.dodamage = nil
end

hook.Add("Ragdoll Collide", "hgOrgansDamage", function(ragdoll, data)
	if ragdoll == data.HitEntity then return end
	if data.DeltaTime < 0.25 then return end
	if not ragdoll:IsRagdoll() then return end
	if data.HitEntity:IsPlayerHolding() then return end

	velocityDamage(ragdoll, data)
end)

local bonenames = {
	["ValveBiped.Bip01_Head1"] = "#hg.bones.head",
	["ValveBiped.Bip01_Spine"] = "#hg.bones.spine",
	["ValveBiped.Bip01_Spine2"] = "#hg.bones.spine",
	["ValveBiped.Bip01_Pelvis"] = "#hg.bones.pelvis",

	["ValveBiped.Bip01_R_Hand"] = "#hg.bones.rhand",
	["ValveBiped.Bip01_R_Forearm"] = "#hg.bones.rforearm",
	["ValveBiped.Bip01_R_Shoulder"] = "#hg.bones.rshoulder",
	["ValveBiped.Bip01_R_UpperArm"] = "#hg.bones.rshoulder",
	["ValveBiped.Bip01_R_Elbow"] = "#hg.bones.relbow",

	["ValveBiped.Bip01_R_Foot"] = "#hg.bones.rfoot",
	["ValveBiped.Bip01_R_Thigh"] = "#hg.bones.rthigh",
	["ValveBiped.Bip01_R_Calf"] = "#hg.bones.rcalf",

	["ValveBiped.Bip01_L_Hand"] = "#hg.bones.lhand",
	["ValveBiped.Bip01_L_Forearm"] = "#hg.bones.lforearm",
	["ValveBiped.Bip01_L_Shoulder"] = "#hg.bones.lshoulder",
	["ValveBiped.Bip01_L_UpperArm"] = "#hg.bones.lshoulder",
	["ValveBiped.Bip01_L_Elbow"] = "#hg.bones.lelbow",

	["ValveBiped.Bip01_L_Foot"] = "#hg.bones.lfoot",
	["ValveBiped.Bip01_L_Thigh"] = "#hg.bones.lthigh",
	["ValveBiped.Bip01_L_Calf"] = "#hg.bones.lcalf"
}

local deathreasons = {
	["unknown"] = true,
	["blood"] = true,
	["pain"] = true,
	["painlosing"] = true,
	["adrenaline"] = true,
	["killyourself"] = true,
	["hungry"] = true,
	["virus"] = true,
	["poison"] = true,
	["guilt"] = true
}

hook.Add("Player Death", "plymessage", function(ply, hitgroup, dmginfo)
	local att = ply.LastAttacker
	-- if not IsValid(att) then return end

	local boneName = bonenames[ply.LastHitBoneName]
	local reason = ply.KillReason
	local dmgInfo = dmgInfo or ply.LastDMGInfo

	-- TODO: Check if works
	-- I hope so...
	if ply == att then
		local tbl = boneName and {"#hg.deathreasons.inbone", "#hg.deathreasons.killyourself", boneName} or {"#hg.deathreasons.killyourself"}

		net.Start("hg_sendchat_format")
			net.WriteTable(tbl)
		net.Send(ply)
	elseif reason then
		local tbl = boneName and {"#hg.deathreasons.inbone", deathreasons[reason] and "#hg.deathreasons." .. string.lower(reason) or "#hg.deathreasons.unknown", boneName} or {deathreasons[reason] and "#hg.deathreasons." .. string.lower(reason) or "#hg.deathreasons.unknown"}

		net.Start("hg_sendchat_format")
			net.WriteTable(tbl)
		net.Send(ply)
	elseif att then
		local dmgtype = "#hg.deathreasons.damage"
		dmgtype = dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) and
			(dmgInfo:IsDamageType(DMG_BUCKSHOT) and "#hg.deathreasons.buckshot" or "#hg.deathreasons.gunshot") or
			dmgInfo:IsExplosionDamage() and "#hg.deathreasons.explosion" or
			dmgInfo:IsDamageType(DMG_SLASH) and "#hg.deathreasons.slash" or
			dmgInfo:IsDamageType(DMG_CLUB + DMG_GENERIC) and "#" or dmgtype
		local tbl = {
			"#hg.deathreasons.diedfrom",
			dmgtype,
			att:Name()
		}

		net.Start("hg_sendchat_format")
			net.WriteTable(tbl)
		net.Send(ply)

		player.EventPoint(att:GetPos(), "hitgroup killed", 512, att, ply)
	else
		net.Start("hg_sendchat_simple")
			net.WriteString("#hg.deathreasons.unknown")
		net.Send(ply)
	end
end)