util.AddNetworkString("info_virus")

local zombies = {
	["npc_zombie"] = true,
	["npc_zombie_torso"] = true,
	["npc_poisonzombie"] = true
}

local vomitsfxs = {"homigradsfx/blevota/blevotahmcd.mp3", "homigradsfx/blevota/blevotalarge.mp3", "homigradsfx/blevota/blevotamedium.mp3", "homigradsfx/blevota/blevotasmall.mp3"}

local function CanSee(ply, ent)
	local Tr = util.TraceLine({
		start = ply:GetPos(),
		endpos = ent:GetPos(),
		filter = {ply, ent}, -- self, ent
		mask = MASK_SHOT
	})

	return not Tr.Hit
end

local function ZsVirusCough(ply)
	local r = math.random(0, 25)

	if r > 15 and not ply.unconscious then
		-- ply:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 75, math.random(90, 110))
		if r > 22 then
			local snd = vomitsfxs[math.random(#vomitsfxs)]

			ply:EmitSound(snd)

			timer.Create("Blevota" .. ply:EntIndex(), 0.1, 14, function() BloodParticle(ply:EyePos(), ply:EyeAngles():Forward() * 150 + Vector(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)) * 30) end)
		else
			ply:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 75, math.random(90, 110))
		end

		for _, obj in pairs(ents.FindInSphere(ply:GetPos(), 130)) do
			if not obj == ply and obj:IsPlayer() and CanSee(ply, obj) then obj.virus = obj.virus + math.random(0, 3) end
		end
	end
end

hook.Add("HomigradDamage", "PlayerZombVirus", function(ply, hitGroup, dmginfo, rag, armorMul)
	if zombies[dmginfo:GetAttacker():GetClass()] then
		ply.virus = ply.virus + math.random(1, 7)
	end
end)

hook.Add("Player Think", "homigrad-virus", function(ply, time)
	if not ply:Alive() or ply:HasGodMode() then return end
	if (ply.virusNext or time) > time then return end

	ply.virus = ply.virus or 0
	ply.virusNext = time + 3
	ply.virusNextNet = ply.virusNextNet or 0

	if ply.virus > 5 then
		ply.virus = ply.virus + 1
		if ply.virusNextNet <= time then
			ply.virusNextNet = time + 2

			net.Start("info_virus")
				net.WriteFloat(ply.virus)
			net.Send(ply)
		end

		ZsVirusCough(ply)
	end

	if ply.virus > 90 then ply.pain = 1000 end

	if ply.virus > 100 then
		-- ply:Kill()
		ply.KillReason = "virus"
		ply.nohook = true
		ply:TakeDamage(math.huge, ply.LastAttacker)
		ply.nohook = nil
	end
end)

hook.Add("Homigrad Heal", "homigrad-virus", function(ply)
	ply.virus = 0

	net.Start("info_virus")
		net.WriteFloat(ply.virus)
	net.Send(ply)
end)

hook.Add("PostPlayerDeath", "RefreshPain", function(ply)
	ply.virus = 0

	net.Start("info_virus")
		net.WriteFloat(ply.virus)
	net.Send(ply)
end)

function Vomit(ply)
	ply:EmitSound(vomitsfxs[math.random(#vomitsfxs)])

	timer.Create("Blevota" .. ply:EntIndex(), 0.1, 15, function()
		if not IsValid(ply) or not ply:Alive() then return end

		ply.Blood = math.Clamp(ply.Blood - 10, 0, 5000)

		local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
		local att = ent:GetAttachment(ent:LookupAttachment("eyes"))
		if not att then return end

		BloodParticle(att.Pos - att.Ang:Up() * 2, ply:EyeAngles():Forward() * 150 + VectorRand(-15, 15) + ply:GetVelocity())
	end)
end

concommand.Add("vomit", function(ply, cmd, args)
	if not ply:Alive() or ply.unconscious then return end

	local r = math.random(1, 30)
	-- r = 26 -- xd

	if r > 25 then
		Vomit(ply)
	else
		net.Start("hg_sendchat_simple")
			net.WriteString("#hg.virus.vomitfail")
		net.Send(ply)
	end
end)