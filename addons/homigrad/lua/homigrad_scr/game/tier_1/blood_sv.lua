BleedingEntities = BleedingEntities or {}

hook.Add("HomigradDamage", "phildcorn", function(ply, hitGroup, dmginfo, rag, armorMul)
	if armorMul <= 0.75 or not dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER + DMG_BUCKSHOT) then return end

	local dmg

	if dmginfo:IsDamageType(DMG_BUCKSHOT + DMG_SLASH) then
		dmg = dmginfo:GetDamage() * 2
	else
		dmg = dmginfo:GetDamage() * 0.8
	end

	ply.Bloodlosing = ply.Bloodlosing + dmg
end)

hook.Add("EntityTakeDamage", "asdsdads", function(ent, dmginfo)
	--[[
	if ent and not ent.IsBleeding and dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER) then
		table.insert(BleedingEntities, ent)
		ent.bloodNext = CurTime()
		ent.Blood = ent.Blood or 5000
	end
	--]]
end)

util.AddNetworkString("info_blood")

function homigradPulse(ply)
	local heartstop = (ply.Blood + (ply.CPR or 0) + (math.min(ply.adrenaline * 500, 1000) or 0)) < 2000
	heartstop = ply.Organs["heart"] == 0 or heartstop
	heartstop = ply.o2 <= 0 and true or heartstop

	local pulse = math.min(5000 / ply.Blood, 5) - math.min(ply.adrenaline / 5, 0.6) - math.min(100 / ply.stamina - 1, 0.5)

	return pulse, heartstop
end

hook.Add("Player Think", "homigrad-blood", function(ply, time)
	if not ply:Alive() or ply:HasGodMode() then return end

	ply.Organs = ply.Organs or {}

	local nextPulse, heartstop = homigradPulse(ply)

	ply.heartstop = heartstop
	ply.nextPulse = not heartstop and nextPulse or Lerp(0.1, ply.nextPulse or 0, 5)

	if (ply.CPRThink or 0) < time then
		ply.CPRThink = time + 1
		ply.CPR = math.max((ply.CPR or 0) - 5, 0)
		ply.o2 = ply.heartstop and math.max((ply.o2 or 1) - 0.1, -3) or math.min((ply.o2 or 1) + 0.1, 1)
	end

	local ent = IsValid(ply.fakeragdoll) and ply.fakeragdoll or ply
	local neck = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Neck1")):GetTranslation()

	if ply.Organs["artery"] == 0 and (ply.arteriaThink or 0) < time and ply.Blood > 0 then
		ply.arteriaThink = time + 0.1

		if not ply.holdingartery then
			ply.Blood = math.max(ply.Blood - 10, 0)
			BloodParticle(neck, ent:GetAttachment(ent:LookupAttachment("eyes")).Ang:Forward() * 200)
		else
			ply.Blood = math.max(ply.Blood - 2, 0)
			BloodParticle(neck, ent:GetAttachment(ent:LookupAttachment("eyes")).Ang:Forward() * 50)
		end
	end

	if ply.heartstop and (ply.brainDeathThink or 0) < time then
		ply.Organs["brain"] = math.max(ply.Organs["brain"] - 0.1, 0)
		ply.brainDeathThink = time + 1
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

local time

hook.Add("Think", "homigrad-bleeding-ents", function()
	time = CurTime()

	for i, ent in pairs(BleedingEntities) do
		if not IsValid(ent) or ent:IsPlayer() or not ent.deadbody then continue end

		ent.bloodNext = ent.bloodNext or time
		if ent.bloodNext > time then continue end

		ent.bloodNext = time + math.random(0.6, 0.8)
		BloodParticle(ent:GetPos() + ent:OBBCenter(), VectorRand(-15, 15))
		ent.Blood = ent.Blood - 35

		if ent.Blood <= 0 then
			BleedingEntities[ent] = nil
		end
	end
end)

hook.Add("PlayerSpawn", "homigrad-blood", function(ply)
	if PLYSPAWN_OVERRIDE then return end

	ply.IsBleeding = false
	ply.Blood = 5000
	ply.Bloodlosing = 0
	ply.stamina = 100
	ply.LeftLeg = 1
	ply.RightLeg = 1
	ply.RightArm = 1
	ply.LeftArm = 1
	ply.Attacker = nil
	ply.nopain = false
	ply.o2 = 1

	ply.Blood = 5000
	ply.heartstop = false
	ply.nextPulse = nil
	ply.Bloodlosing = 0
	ply.bloodtype = math.random(1, 8)
	ply.Speed = 0
	ply.arterybloodlosing = 0

	ply.pulseStart = 0

	ply:ConCommand("soundfade 0 1")

	ply.bloodNext = 0
end)

hook.Add("PlayerDeath", "deathblood", function(ply)
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

hook.Add("EntityTakeDamage", "van", function(ent, dmginfo)
	if ent:GetClass() == "sim_fphys_van" then
		dmginfo:ScaleDamage(0.13)
	end
end)

util.AddNetworkString("organism_info")

concommand.Add("hg_organisminfo", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not args[1] then return end

	local plrs = player.GetListByName(ply, args[1])
	if not plrs then return print("Игрок не найден") end

	local plr = plrs[1]

	net.Start("organism_info")
		net.WriteTable(plr.Organs)
		net.WriteString("Кровь (мл): " .. tostring(plr.Blood) .. "\n" .. "Кровотечение (мл/удар): " .. tostring(plr.Bloodlosing) .. "\n" .. "СЛР: " .. tostring(plr.CPR) .. "\n" .. "Боль: " .. tostring(plr.pain) .. "\n" .. "Остановка сердца: " .. tostring(plr.heartstop) .. "\n" .. "o2 (1 = полный запас кислорода): " .. tostring(plr.o2) .. "\n" .. "Удары в минуту: " .. tostring(plr.heartstop and 0 or 1 / plr.nextPulse * 60) .. "\n" .. "Игрок: " .. plr:Name())
	net.Send(ply)
end)

concommand.Add("hg_organism_setvalue", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if not args[1] or not args[2] or not args[3] then return end

	local plrs = args[3] and player.GetListByName(ply, args[3])
	if not plrs then return ply:ChatPrint("Игрок(и) не найдены") end

	local plr = plrs[1]

	plr.Organs[args[1]] = args[2]
end)