hook.Add("Player Think", "hgHungerThink", function(ply, time)
	if not ply:Alive() or ply:HasGodMode() then return end
	if (ply.hungryNext or time) > time then return end

	ply.hungryNext = time + 2
	ply.hungryregen = math.Clamp((ply.hungryregen or 0) - 0.03, -0.01, 50)
	ply.hungry = math.Clamp((ply.hungry or 0) + ply.hungryregen, 0, 100)

	if ply.hungry < 5 then
		ply:SetHealth(ply:Health() - 1)

		if ply:Health() <= 0 then
			ply.KillReason = "hungry"
			-- ply:Kill()
			ply.nohook = true
			ply:TakeDamage(math.huge, ply.LastAttacker)
			ply.nohook = nil

			return
		end
	end

	if ply.hungry < 80 then
		if ply.hungry < 40 and ply.hungryMessage ~= 1 then
			ply.hungryMessage = 1

			net.Start("hg_sendchat_simple")
				net.WriteString("#hg.hunger.hungry")
			net.Send(ply)
		end

		if ply.hungry > 40 and ply.hungry < 65 and ply.hungryMessage ~= 2 then
			ply.hungryMessage = 2

			net.Start("hg_sendchat_simple")
				net.WriteString("#hg.hunger.veryhungry")
			net.Send(ply)
		end
	end

	if (ply.regenNext or time) > time then return end
	ply.regenNext = time + 5

	ply:SetHealth(not ply.heartstop and math.min(ply:Health() + math.max(math.ceil(ply.hungryregen), 1), 150) or ply:Health())
end)

hook.Add("Homigrad Heal", "hgHungerSpawn", function(ply)
	ply.hungry = 89
	ply.hungryregen = 0
	ply.hungryNext = 0
	ply.hungryMessage = nil
end)

concommand.Add("hg_hungryinfo", function(ply)
	if not ply:IsAdmin() then return end

	ply:ChatPrint("hungry: " .. ply.hungry)
	ply:ChatPrint("hungryregen: " .. ply.hungryregen)
end)