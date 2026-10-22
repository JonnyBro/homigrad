util.AddNetworkString("info_pain")

hook.Add("Homigrad Heal", "homigrad-pain", function(ply)
	ply.painlosing = 1
	ply.pain = 0
	ply.painNext = 0
	ply.painNextNet = 0
	ply.poisoned = false
	ply.poisoned2 = false
end)

hook.Add("HomigradDamage", "PlayerPainGrowth", function(ply, hitGroup, dmginfo, rag, armorMul)
	if dmginfo:GetAttacker():IsRagdoll() then return end

	local dmg = dmginfo:GetDamage() * 1.3 * armorMul
	local isBlast = dmginfo:IsDamageType(DMG_BLAST)
	local isSlash = dmginfo:IsDamageType(DMG_SLASH)
	local isBullet = dmginfo:IsDamageType(DMG_BULLET)
	local isVehicle = dmginfo:IsDamageType(DMG_VEHICLE + DMG_CRUSH + DMG_BUCKSHOT + DMG_GENERIC)
	local isClub = dmginfo:IsDamageType(DMG_CLUB + DMG_BURN + DMG_DROWN + DMG_SHOCK)
	local isGeneric = dmginfo:IsDamageType(DMG_GENERIC)

	if isBlast or isSlash or isBullet then
		if isSlash then dmg = dmg * 4.5 end
		dmg = dmg * 2
	elseif isVehicle then
		dmg = dmg * 1.5
	elseif isClub then
		dmg = dmg * 6.5
	elseif not dmginfo:IsDamageType(DMG_BLAST + DMG_NERVEGAS) then
		dmg = dmg * 2
	else
		if dmginfo:GetAttacker():IsRagdoll() then dmg = 0 end

		dmginfo:SetDamage(dmginfo:GetDamage())

		if ply.painlosing > 10 or ply.pain > 250 + ply:GetNWInt("SharpenAMT") * 5 or ply.Blood < 3000 and not ply.unconscious then ply.gotuncon = true end
	end

	if isClub or isGeneric then dmginfo:ScaleDamage(IsValid(wep) and wep.GetBlocking and not wep:GetBlocking() and 1 or 0.25) end

	dmg = dmg / ply.painlosing
	dmg = ply.nopain and 1 or dmg

	ply.pain = ply.pain + dmg
end)

hook.Add("Player Think", "homigrad-pain", function(ply, time)
	if not ply:Alive() or (ply.painNext or time) > time or ply:HasGodMode() then return end

	ply.painNext = time + 0.1

	local pain = ply.pain
	local painlosing = ply.painlosing
	if painlosing > 5 then
		ply.stamina = 30
		pain = pain + 8
	end

	if pain >= 1800 then
		ply.KillReason = "pain"
		ply.nohook = true
		ply:TakeDamage(math.huge, ply.LastAttacker)
		ply.nohook = nil

		return
	end

	local k = ply.adrenaline <= 2 and 1 - ply.adrenaline / 2 or 0

	if ply.adrenaline > 2 then
		ply.stamina = 30
		pain = pain + 5
	end

	ply.pain = math.max(pain - painlosing * 2 + ply.adrenalineNeed * k, 0)

	ply.painlosing = math.max(painlosing - 0.01, 1)

	if ply.painNextNet <= time then
		ply.painNextNet = time + 0.25

		net.Start("info_pain")
			net.WriteFloat(ply.pain)
			net.WriteFloat(ply.painlosing)
		net.Send(ply)
	end

	if IsUnconscious(ply) then
		GetUnconscious(ply)
	else
		ply:ConCommand("soundfade 0 1")
	end
end)

hook.Add("PostPlayerDeath", "RefreshPain", function(ply)
	ply.pain = 0
	ply.painlosing = 1
	ply.poisoned = false
	ply.poisoned2 = false

	ply:ConCommand("soundfade 0 1")

	ply.unconscious = false

	net.Start("info_pain")
		net.WriteFloat(ply.pain)
		net.WriteFloat(ply.painlosing)
	net.Send(ply)
end)

function IsUnconscious(ply)
	if ply.painlosing > 20 or ply.pain > 250 + ply:GetNWInt("SharpenAMT") * 5 or ply.Blood < 3000 or ply.heartstop then
		ply.unconscious = true
		ply:SetDSP(16)
	else
		ply.unconscious = false
		ply:SetDSP(ply.EZarmor.effects.earPro and 58 or 1)
	end

	ply:SetNWInt("unconscious", ply.unconscious)

	return ply.unconscious
end

function GetUnconscious(ply)
	if ply:Alive() then ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 0.5, 0.5) end
	if not IsValid(ply.FakeRagdoll) then Faking(ply) end
	if ply.gotuncon then ply.pain = ply.pain + 100 end

	ply.gotuncon = false

	local rag = ply:GetNWEntity("Ragdoll")
	if IsValid(rag) and ply.unconscious then rag:SetEyeTarget(Vector(0, 0, 0)) end
end