util.AddNetworkString("info_blood")

BleedingEntities = BleedingEntities or {}

hook.Add("HomigradDamage", "hgBloodLosing", function(ply, hitGroup, dmginfo, rag, armorMul)
	if armorMul <= 0.75 or not dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER + DMG_BUCKSHOT) then return end

	local dmg
	if dmginfo:IsDamageType(DMG_BUCKSHOT + DMG_SLASH) then
		dmg = dmginfo:GetDamage() * 2
	else
		dmg = dmginfo:GetDamage() * 0.8
	end

	ply.Bloodlosing = ply.Bloodlosing + dmg
end)

--[[
hook.Add("EntityTakeDamage", "asdsdads", function(ent, dmginfo)
	if ent and not ent.IsBleeding and dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER) then
		table.insert(BleedingEntities, ent)
		ent.bloodNext = CurTime()
		ent.Blood = ent.Blood or 5000 --wtf
	end
end) --]]

function homigradPulse(ply)
	local heartstop = ply.Blood + (ply.CPR or 0) + (math.min(ply.adrenaline * 500, 1000) or 0) < 2000
	heartstop = ply.organs["heart"] == 0 or heartstop
	heartstop = ply.o2 <= 0 and true or heartstop
	local pulse = math.min(5000 / ply.Blood, 5) - math.min(ply.adrenaline / 5, 0.6) - math.min(100 / ply.stamina - 1, 0.5)

	return pulse, heartstop
end

hook.Add("Player Think", "hgBlood", function(ply, time)
	if not ply:Alive() or ply:HasGodMode() then return end

	ply.organs = ply.organs or {}

	local nextPulse, heartstop = homigradPulse(ply)

	ply.heartstop = heartstop
	ply.nextPulse = not heartstop and nextPulse or Lerp(0.1, ply.nextPulse or 0, 5)

	if (ply.CPRThink or 0) < time then
		ply.CPRThink = time + 1
		ply.CPR = math.max((ply.CPR or 0) - 5, 0)
		ply.o2 = ply.heartstop and math.max((ply.o2 or 1) - 0.1, -3) or math.min((ply.o2 or 1) + 0.1, 1)
	end

	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	local neckb = ent:LookupBone("ValveBiped.Bip01_Neck1")
	local neck = ent:GetBoneMatrix(neckb)

	if neckb and neck then
		neck = neck:GetTranslation()

		if ply.organs["artery"] == 0 and (ply.arteriaThink or 0) < time and ply.Blood > 0 then
			ply.arteriaThink = time + 0.1
			ply.Blood = math.max(ply.Blood - 10, 0)

			BloodParticle(neck, ent:GetAttachment(ent:LookupAttachment("eyes")).Ang:Forward() * 200)
		end
	end

	if ply.pulseStart + ply.nextPulse > time then return end

	ply.pulseStart = time

	-- ply:EmitSound("snd_jack_hmcd_heartpound.wav", 70, 100, 0.05 / ply.nextPulse, CHAN_AUTO)

	if ply.Bloodlosing > 0 then
		ply.Bloodlosing = ply.Bloodlosing - 0.5
		ply.Blood = math.max(ply.Blood - ply.Bloodlosing / 2, 0)

		BloodParticle(ent:GetPos() + ent:OBBCenter(), VectorRand(-15, 15))
	elseif ply.Blood < 5000 and not ply.heartstop then
		ply.Blood = ply.Blood + math.max(math.ceil(ply.hungryregen), 1) * 10 + ply.adrenaline * 20
	end

	if ply.bloodNext > time then return end

	ply.bloodNext = time + 0.25

	net.Start("info_blood")
		net.WriteFloat(ply.Blood)
	net.Send(ply)
end)

local math_random = math.random
local time

hook.Add("Think", "hgBleedingEnts", function()
	time = CurTime()

	for _, ent in pairs(BleedingEntities) do
		if not IsValid(ent) or ent:IsPlayer() or not ent.deadbody then continue end

		ent.bloodNext = ent.bloodNext or time
		if ent.bloodNext > time then continue end
		ent.bloodNext = time + math_random(0.6, 0.8)

		BloodParticle(ent:GetPos() + ent:OBBCenter(), VectorRand(-15, 15))

		ent.Blood = ent.Blood - 35

		if ent.Blood <= 0 then BleedingEntities[ent] = nil end
	end
end)

hook.Add("PlayerSpawn", "hgSpawnBlood", function(ply)
	if PLYSPAWN_OVERRIDE then return end

	ply.Attacker = nil

	hook.Run("Homigrad Heal", ply)
end)

hook.Add("Homigrad Heal", "hgSpawnBlood", function(ply)
	ply.IsBleeding = false

	ply.Blood = 5000
	ply.Bloodlosing = 0
	ply.stamina = 100

	ply.LeftLeg = 1
	ply.RightLeg = 1
	ply.RightArm = 1
	ply.LeftArm = 1

	ply.nopain = false

	ply.o2 = 1
	ply.Blood = 5000

	ply.heartstop = false
	ply.nextPulse = nil
	ply.bloodtype = 1 -- math.random(1, 8)
	ply.Speed = 0
	ply.arterybloodlosing = 0
	ply.pulseStart = 0

	ply:ConCommand("soundfade 0 1")

	ply.bloodNext = 0
end)

hook.Add("Player Death", "deathblood", function(ply)
	ply.Blood = 5000
	ply.Bloodlosing = 0
	ply.stamina = 100

	ply.LeftLeg = 1
	ply.RightLeg = 1
	ply.RightArm = 1
	ply.LeftArm = 1

	ply.o2 = 1

	ply.arterybleeding = nil
	ply.InternalBleeding = nil
	ply.InternalBleeding2 = nil
	ply.InternalBleeding3 = nil
	ply.InternalBleeding4 = nil
	ply.InternalBleeding5 = nil
	ply.brokenspine = false

	ply:ConCommand("soundfade 0 1")

	ply:SetDSP(0)

	net.Start("info_blood")
		net.WriteFloat(ply.Blood)
	net.Send(ply)
end)

hook.Add("EntityTakeDamage", "van", function(ent, dmginfo) if ent:GetClass() == "sim_fphys_van" then dmginfo:ScaleDamage(0.13) end end)
