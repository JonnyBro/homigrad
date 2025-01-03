function GuiltLogic(ply, att, dmgInfo, dontApply)
	if att == ply then return end
	if not roundActive then return end
	if #player.GetAll() <= 5 then return end

	local resultHook = hook.Run("Guilt Logic", ply, att, dmgInfo)
	if resultHook == false then return end

	local resultGame = TableRound().GuiltLogic
	resultGame = resultGame and resultGame(ply, att, dmgInfo)
	if resultGame == false then return end

	local resultClass = ply:PlayerClassEvent("GuiltLogic", att, dmgInfo)
	if resultClass == false then return end

	local plyTeam = ply:Team()
	local attTeam = att:Team()

	if resultGame or resultHook or resultClass or plyTeam == attTeam then
		if ply.DontGuiltProtect then
			if not dontApply then
				att.Guilt = math.max(att.Guilt - dmgInfo:GetDamage(), 0)
			end

			return false, true
		end

		if not dontApply then
			local customGuiltAdd = (type(resultHook) == "number" and resultHook) or (type(resultGame) == "number" and resultGame) or (type(resultClass) == "number" and resultClass)
			local previousGuilt = att.Guilt or 0 -- Сохраняем предыдущее значение Guilt
			local baseGuiltAdd = customGuiltAdd or math.min(dmgInfo:GetDamage() / 3, 50)

			-- Проверяем, если урон был нанесен с помощью weapon_hands
			local isWeaponHands = dmgInfo:GetAttacker():GetClass() == "weapon_hands"

			if isWeaponHands then
				baseGuiltAdd = baseGuiltAdd * 2 -- Увеличиваем начисленный Guilt в 2 раза
			end

			att.Guilt = (att.Guilt or 0) + baseGuiltAdd

			local guiltIncrease = att.Guilt - previousGuilt -- Вычисляем прирост Guilt
			att.DontGuiltProtect = true

			-- Передаем прирост Guilt в GuiltCheck
			GuiltCheck(att, ply, guiltIncrease, isWeaponHands)
		end

		return true
	end

	return false
end

COMMANDS.noguilt = {
	function(ply, args)
		if not ply:IsAdmin() then return end

		local value = tonumber(args[2]) > 0

		local plrList = player.GetListByName(ply, args[1])
		if not plrList then return ply:ChatPrint("Игрок(и) не найдены") end

		for i, ply in pairs(plrList) do
			ply.noguilt = value
			ply:ChatPrint("Guilt Protect: " .. tostring(value))
		end
	end,
	1
}

COMMANDS.fake = {
	function(ply, args)
		if not ply:IsAdmin() then return end

		local plrList = player.GetListByName(ply, args[1])
		if not plrList then return ply:ChatPrint("Игрок(и) не найдены") end

		for _, ply in pairs(plrList) do
			Faking(ply)
		end
	end,
	1
}

concommand.Add("faketarget", function(ply, cmd, args)
	if not ply:IsAdmin() then return end

	local targets = {}

	if args[1] == "@" then
		local tr = ply:GetEyeTrace()

		if IsValid(tr.Entity) then
			if tr.Entity:IsPlayer() then
				table.insert(targets, tr.Entity)
			elseif tr.Entity:IsRagdoll() then
				local owner = RagdollOwner(tr.Entity)

				if IsValid(owner) then
					table.insert(targets, owner)
				end
			end
		else
			return
		end
	elseif args[1] then
		targets = player.GetListByName(ply, args[1])
		if not targets then return ply:ChatPrint("No valid targets found.") end
	else
		table.insert(targets, ply)
	end

	for _, target in ipairs(targets) do
		Faking(target)
	end
end)

function GuiltCheck(att, ply, guiltIncrease, isWeaponHands)
	if att.noguilt or att:HasGodMode() then return end

	-- Увеличиваем боль только на основе прироста Guilt
	if guiltIncrease > 0 then
		local painIncrease = guiltIncrease * 3 -- Увеличиваем боль в 3 раза за каждый прирост Guilt

		if isWeaponHands then
			painIncrease = painIncrease * 3 -- Увеличиваем боль в 3 раза, если использовалось weapon_hands
		end

		att.pain = (att.pain or 0) + painIncrease
	end

	-- Проверка на превышение Guilt
	if att.Guilt >= 150 then
		att:Kill()
		att.Guilt = 0
	end
end

hook.Add("HomigradDamage", "guilt-logic", function(ply, hitGroup, dmgInfo, rag)
	local att = ply.LastAttacker

	if ply and att then
		GuiltLogic(ply, att, dmgInfo)
	end
end)

hook.Add("Should Fake Collide", "guilt", function(ply, hitEnt, data)
	if hitEnt == game.GetWorld() then return end

	hitEnt = RagdollOwner(hitEnt)

	if not hitEnt:IsPlayer() then return end

	local dmgInfo = DamageInfo()
		dmgInfo:SetAttacker(hitEnt)
		dmgInfo:SetDamage(10)
		dmgInfo:SetDamageType(DMG_CRUSH)
	GuiltLogic(ply, hitEnt, dmgInfo)
end)

hook.Add("PlayerInitialSpawn", "guiltasdd", function(ply)
	ply.Guilt = ply:GetPData("Guilt") or 0

	ply:ChatPrint("Ваш гилт: " .. tostring(ply.Guilt) .. "%")

	ply.RoundGuilt = 0
end)

hook.Add("PlayerSpawn", "guilt", function(ply)
	if PLYSPAWN_OVERRIDE then return end

	ply.DontGuiltProtect = nil
	ply.Seizure = false
	ply.Guilt = ply.Guilt or 0

	ply:ChatPrint("Ваш гилт: " .. tostring(math.floor(ply.Guilt)) .. "%")
end)

hook.Add("PlayerDisconnected", "guiltasd", function(ply)
	ply:SetPData("Guilt", ply.Guilt)
end)

local player_GetAll = player.GetAll

hook.Add("Think", "guilt reduction", function()
	local tbl = player_GetAll()

	for i = 1, #tbl do
		local ply = tbl[i]
		local time = CurTime()

		ply.GuiltReductionCooldown = ply.GuiltReductionCooldown or time

		if ply.GuiltReductionCooldown < time then
			ply.GuiltReductionCooldown = time + 5
			ply.Guilt = math.max((ply.Guilt or 0) - 1, 0)
		end
	end
end)

concommand.Add("hg_getguilt", function(ply)
	local text = "Guilt information\n"

	for i, ply in pairs(player.GetAll()) do
		text = text .. ply:Name() .. ": " .. tostring(ply.Guilt) .. "%\n"
	end

	ply:ConsolePrint(text)
end)