local vecZero = Vector(0, 0, 0)
-- local vecInf = Vector(1, 1, 1) / 0

local function removeBone(rag, bone, phys_bone)
	rag:ManipulateBoneScale(bone, vecZero)

	-- rag:ManipulateBonePosition(bone, vecInf) -- Thanks Rama (only works on certain graphics cards!)

	if rag.gibRemove[phys_bone] then return end

	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	if not IsValid(phys_obj) then return end

	phys_obj:EnableCollisions(false)
	phys_obj:SetMass(0.1)

	-- rag:RemoveInternalConstraint(phys_bone)

	if rag.constraints and IsValid(rag.constraints[rag:GetBoneName(bone)]) then
		rag.constraints[rag:GetBoneName(bone)]:Remove()
		rag.constraints[rag:GetBoneName(bone)] = nil
	end

	constraint.RemoveAll(phys_obj)

	rag.gibRemove[phys_bone] = phys_obj
end

local function recursive_bone(rag, bone, list)
	for _, bone in pairs(rag:GetChildBones(bone)) do
		if bone == 0 then continue end

		list[#list + 1] = bone

		recursive_bone(rag, bone, list)
	end
end

function Gib_RemoveBone(rag, bone, phys_bone)
	rag.gibRemove = rag.gibRemove or {}

	removeBone(rag, bone, phys_bone)

	local list = {}

	recursive_bone(rag, bone, list)

	for _, bone in pairs(list) do
		removeBone(rag, bone, rag:TranslateBoneToPhysBone(bone))
	end
end

concommand.Add("removebone", function(ply)
	if not ply:IsAdmin() then return end

	local trace = ply:GetEyeTrace()

	local ent = trace.Entity
	if not IsValid(ent) then return end

	local phys_bone = trace.PhysicsBone
	if not phys_bone or phys_bone == 0 then return end

	Gib_RemoveBone(ent, ent:TranslatePhysBoneToBone(phys_bone), phys_bone)
end)

gib_ragdols = gib_ragdols or {}

local gib_ragdols = gib_ragdols
local Rand = math.Rand

local validBone = {
	["ValveBiped.Bip01_R_UpperArm"] = true,
	["ValveBiped.Bip01_R_Forearm"] = true,
	["ValveBiped.Bip01_R_Hand"] = true,

	["ValveBiped.Bip01_L_UpperArm"] = true,
	["ValveBiped.Bip01_L_Forearm"] = true,
	["ValveBiped.Bip01_L_Hand"] = true,

	["ValveBiped.Bip01_L_Thigh"] = true,
	["ValveBiped.Bip01_L_Calf"] = true,
	["ValveBiped.Bip01_L_Foot"] = true,

	["ValveBiped.Bip01_R_Thigh"] = true,
	["ValveBiped.Bip01_R_Calf"] = true,
	["ValveBiped.Bip01_R_Foot"] = true
}

local bone_integrity = {
	["ValveBiped.Bip01_R_UpperArm"] = 0.65,
	["ValveBiped.Bip01_R_Forearm"] = 0.5,
	["ValveBiped.Bip01_R_Hand"] = 0.4,

	["ValveBiped.Bip01_L_UpperArm"] = 0.65,
	["ValveBiped.Bip01_L_Forearm"] = 0.5,
	["ValveBiped.Bip01_L_Hand"] = 0.4,

	["ValveBiped.Bip01_L_Thigh"] = 0.85,
	["ValveBiped.Bip01_L_Calf"] = 0.75,
	["ValveBiped.Bip01_L_Foot"] = 0.45,

	["ValveBiped.Bip01_R_Thigh"] = 0.85,
	["ValveBiped.Bip01_R_Calf"] = 0.75,
	["ValveBiped.Bip01_R_Foot"] = 0.45,

	["ValveBiped.Bip01_Pelvis"] = 1.2,

	["ValveBiped.Bip01_Spine"] = 1.1,
	["ValveBiped.Bip01_Spine1"] = 1.1,
	["ValveBiped.Bip01_Spine2"] = 1.1,

	["ValveBiped.Bip01_Head1"] = 1,
}

function SpawnGore(ent, pos, headpos, force)
	force = force * 5

	if ent.gibRemove and not ent.gibRemove[ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_Head1"))] then
		local ent = ents.Create("prop_physics")
		ent:SetModel("models/Gibs/HGIBS.mdl")
		ent:SetPos(headpos or pos)
		ent:SetVelocity(VectorRand(-50, 50))
		ent:Spawn()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then phys:ApplyForceCenter(force) end
	end

	for _ = 1, 2 do
		local entg = ents.Create("prop_physics")
		entg:SetModel("models/Gibs/HGIBS_spine.mdl")
		entg:SetPos(pos)
		entg:SetVelocity(VectorRand(-50, 50))
		entg:Spawn()

		local phys = entg:GetPhysicsObject()
		if IsValid(phys) then phys:ApplyForceCenter(force) end

		local entg = ents.Create("prop_physics")
		entg:SetModel("models/Gibs/HGIBS_scapula.mdl")
		entg:SetPos(pos)
		entg:SetVelocity(VectorRand(-50, 50))
		entg:Spawn()

		local phys = entg:GetPhysicsObject()
		if IsValid(phys) then phys:ApplyForceCenter(force) end

		local entg = ents.Create("prop_physics")
		entg:SetModel("models/Gibs/HGIBS_rib.mdl")
		entg:SetPos(pos)
		entg:SetVelocity(VectorRand(-50, 50))
		entg:Spawn()

		local phys = entg:GetPhysicsObject()
		if IsValid(phys) then phys:ApplyForceCenter(force) end
	end
end

function Gib_Input(rag, bone, dmgInfo)
	if not IsValid(rag) then return end

	local gibRemove = rag.gibRemove

	if not gibRemove then
		rag.gibRemove = {}

		gibRemove = rag.gibRemove
		gib_ragdols[rag] = true

		-- if not dmgInfo:IsDamageType(DMG_CRUSH) then
		rag.Blood = rag.Blood or 5000
		rag.BloodNext = 0
		rag.BloodGibs = {}
		-- end
	end

	local phys_bone = rag:TranslateBoneToPhysBone(bone)
	local dmgPos = dmgInfo:GetDamagePosition()

	if not gibRemove[phys_bone] then
		sound.Emit(rag, "homigrad/player/headshot" .. math.random(1, 2) .. ".wav")
		sound.Emit(rag, "physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
		sound.Emit(rag, "physics/body/body_medium_break3.wav")
		sound.Emit(rag, "physics/glass/glass_sheet_step" .. math.random(1, 4) .. ".wav", 90, 50, 2)

		timer.Simple(0.05, function()
			if not IsValid(rag) then return end

			rag:EmitSound("physics/flesh/flesh_bloody_break.wav", 90, 75, 2)
		end)

		if bone ~= 0 then
			Gib_RemoveBone(rag, bone, phys_bone)
		else
			gibRemove[phys_bone] = true

			BloodParticleExplode(rag:GetPhysicsObjectNum(phys_bone):GetPos(), dmgInfo:GetDamageForce():GetNormalized() * 350)

			SpawnGore(rag, rag:GetPhysicsObjectNum(phys_bone):GetPos(), rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_Head1"))):GetPos(), dmgInfo:GetDamageForce())

			rag:Remove()
		end

		BloodParticleHeadshoot(rag:GetPhysicsObjectNum(phys_bone):GetPos(), dmgInfo:GetDamageForce() * 1)
	end

	-- FIXME: if dmgInfo:GetDamage() >= 50 and dmgInfo:IsDamageType(DMG_BLAST) and not gibRemove[phys_bone] then
	if dmgInfo:IsDamageType(DMG_BLAST) then
		for bonename in pairs(validBone) do
			local access = false
			local bone = rag:LookupBone(bonename)

			if not bone then continue end

			local phys_bone = rag:TranslateBoneToPhysBone(bone)
			if gibRemove[phys_bone] then continue end
			if rag:GetBonePosition(bone):Distance(dmgPos) <= 125 then access = true end

			if access then
				sound.Emit(rag, "physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
				sound.Emit(rag, "physics/body/body_medium_break3.wav")
				sound.Emit(rag, "physics/flesh/flesh_bloody_break.wav", nil, 75)

				if bone ~= 0 then
					Gib_RemoveBone(rag, bone, phys_bone)
				else
					gibRemove[phys_bone] = true

					BloodParticleExplode(rag:GetPhysicsObjectNum(phys_bone):GetPos(), dmgInfo:GetDamageForce():GetNormalized() * 350)

					SpawnGore(rag, rag:GetPhysicsObjectNum(phys_bone):GetPos(), rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_Head1"))):GetPos(), dmgInfo:GetDamageForce())

					rag:Remove()
				end

				BloodParticleMore(rag:GetPhysicsObjectNum(phys_bone):GetPos(), dmgInfo:GetDamageForce() * 10)
			end
		end
	end

	rag:GetPhysicsObject():SetMass(10)
end

local validBone2 = {
	["ValveBiped.Bip01_L_Thigh"] = true,
	["ValveBiped.Bip01_L_Calf"] = true,
	["ValveBiped.Bip01_L_Foot"] = true,

	["ValveBiped.Bip01_R_Thigh"] = true,
	["ValveBiped.Bip01_R_Calf"] = true,
	["ValveBiped.Bip01_R_Foot"] = true,

	--["ValveBiped.Bip01_Head1"] = true, -- bad idea

	["ValveBiped.Bip01_R_UpperArm"] = true,
	["ValveBiped.Bip01_R_Forearm"] = true,
	["ValveBiped.Bip01_R_Hand"] = true,

	["ValveBiped.Bip01_L_UpperArm"] = true,
	["ValveBiped.Bip01_L_Forearm"] = true,
	["ValveBiped.Bip01_L_Hand"] = true,
}

hook.Add("Player Death", "Gib", function(ply, inflictor, attacker)
	dmgInfo = ply.LastDMGInfo

	if not dmgInfo then return end
	if ply.LastTimeAttacked and ply.LastTimeAttacked + 1 < CurTime() then return end
	if dmgInfo:GetDamage() < 450 * (bone_integrity[ply.LastHitBoneName] or 1) then return end

	timer.Simple(0, function()
		local rag = ply:GetNWEntity("Ragdoll")
		if not IsValid(rag) then return end

		local bone = rag:LookupBone(ply.LastHitBoneName)
		-- bone = bone ~= 0 and bone or 1
		if not IsValid(rag) or not bone then return end

		Gib_Input(rag, bone, dmgInfo)
	end)
end)

hook.Add("EntityTakeDamage", "Gib", function(ent, dmgInfo)
	hook.Run("HomigradGib", ent, dmgInfo)
end)

hook.Add("HomigradGib", "Gib", function(ent, dmgInfo, phys_bone)
	if not ent:IsRagdoll() then
		if not ent.onecallonly then
			ent.onecallonly = true

			local phys_bone = GetPhysicsBoneDamageInfo(ent, dmgInfo)
			local hitgroup

			local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(phys_bone))
			if bonetohitgroup[bonename] then hitgroup = bonetohitgroup[bonename] end

			local mul = RagdollDamageBoneMul[hitgroup] or 1

			local newdmginfo = {}
			newdmginfo.att = dmgInfo:GetAttacker() or game.GetWorld()
			newdmginfo.dmg = dmgInfo:GetDamage() / mul
			newdmginfo.pos = dmgInfo:GetDamagePosition()
			newdmginfo.force = dmgInfo:GetDamageForce()

			timer.Simple(0.1, function()
				if not IsValid(newdmginfo.att) then return end

				local rag = ent.FakeRagdoll

				local dmg = DamageInfo()
				dmg:SetAttacker(newdmginfo.att)
				dmg:SetDamage(newdmginfo.dmg)
				dmg:SetDamagePosition(newdmginfo.pos)
				dmg:SetDamageForce(newdmginfo.force)

				if IsValid(rag) then hook.Run("HomigradGib", rag, dmg, phys_bone) end

				ent.onecallonly = nil
			end)
		end
		return
	end

	local phys_bone = phys_bone or GetPhysicsBoneDamageInfo(ent, dmgInfo)
	local dmg = dmgInfo:GetDamage()
	if dmgInfo:GetAttacker():IsRagdoll() then return end

	local ply = RagdollOwner(ent)
	ply = ply and ply:Alive() and ply

	ent.dmgstack = ent.dmgstack or {}
	ent.dmgstack[phys_bone] = (ent.dmgstack[phys_bone] or 0) + dmg * (dmgInfo:IsDamageType(DMG_CRUSH) and 0.15 or 0.75)

	-- Commenting out for now
	-- print(ent.dmgstack[phys_bone], dmgInfo:IsDamageType(DMG_CRUSH))

	timer.Create("removedmgstack" .. ent:EntIndex() .. phys_bone, 0.3, 1, function() if IsValid(ent) then ent.dmgstack[phys_bone] = 0 end end)

	local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(phys_bone))
	if ply and not validBone2[bonename] then return end
	if ent.dmgstack[phys_bone] < 450 * (bone_integrity[bonename] or 1) then return end

	ent.dmgstack[phys_bone] = 0

	Gib_Input(ent, ent:TranslatePhysBoneToBone(phys_bone), dmgInfo)
end)

hook.Add("Fake Up", "gib", function(ply, rag)
	if gib_ragdols[rag] then return false end
end)

local max = math.max
-- local util_TraceLine = util.TraceLine
-- local util_Decal = util.Decal
-- local tr = {}

hook.Add("Think", "Gib", function()
	local time = CurTime()

	for ent in pairs(gib_ragdols) do
		if not IsValid(ent) then
			gib_ragdols[ent] = nil

			continue
		end

		local ply = RagdollOwner(ent) or ent
		ply.Blood = ply.Blood or 5000
		ent.Blood = ply.Blood
		ply.pain = ply.pain or 0

		if ent.BloodGibs and ply.Blood > 0 then
			local k = ply.Blood / 5000
			--[[
			if (ent.BloodNext or 0) < time then
				ent.BloodNext = time + Rand(0.25, 0.5) / max(k, 0.25)
				ent.Blood = max(ent.Blood - 25, 0)
				tr.start = ent:GetPos()
				tr.endpos = tr.start + Vector(Rand(-1, 1), Rand(-1, 1), -Rand(0.25, 0.4)) * 125 * Rand(0.8, 1.2)
				tr.filter = ent
				local traceResult = util_TraceLine(tr)
				if traceResult.Hit then
					ent:EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 60, math.random(230, 240), 0.1, CHAN_AUTO)
					util_Decal("Blood", traceResult.HitPos + traceResult.HitNormal, traceResult.HitPos - traceResult.HitNormal, ply)
				else
					BloodParticle(ent:GetPos() + ent:OBBCenter(), ent:GetVelocity() + Vector(math.Rand(-5, 5), math.Rand(-5, 5), 0))
				end
			end --]]

			local BloodGibs = ent.BloodGibs

			for phys_bone, phys_obj in pairs(ent.gibRemove) do
				if type(phys_obj) ~= "PhysObj" or not IsValid(phys_obj) then continue end

				local parent_bone = ent:GetBoneParent(ent:TranslatePhysBoneToBone(phys_bone))
				if parent_bone and parent_bone ~= -1 and ent.gibRemove[ent:TranslateBoneToPhysBone(ent:GetBoneParent(ent:TranslatePhysBoneToBone(phys_bone)))] then continue end

				local parent_obj = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(parent_bone))
				parent_obj = IsValid(parent_obj) and parent_obj or phys_obj

				if (BloodGibs[phys_bone] or 0) < time then
					ply.Blood = max(ply.Blood - 5, 0)
					ply.pain = ply.pain + 2.5

					BloodGibs[phys_bone] = time + Rand(0.07, 0.1) / max(k, 0.5)

					BloodParticle(phys_obj:GetPos() - parent_obj:GetAngles():Forward() * 1, phys_obj:GetVelocity() + parent_obj:GetAngles():Forward() * Rand(200, 250) * k + VectorRand(-20, 20))
				end
			end
		end
	end
end)