util.AddNetworkString("round_time")
util.AddNetworkString("round_state")
roundTimeStart = roundTimeStart or 0
roundTime = roundTime or 0

function RoundTimeSync(ply)
	net.Start("round_time")
	net.WriteFloat(roundTimeStart)
	net.WriteFloat(roundTime)
	net.WriteFloat(roundTimeLoot or 0)
	net.Broadcast()

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

local empty = {}

function RoundStateSync(ply, data)
	net.Start("round_state")
	net.WriteBool(roundActive)

	if type(data) == "function" then
		data = {}
	end

	net.WriteTable(data or empty)

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

if levelrandom == nil then
	levelrandom = true
end

if pointPagesRandom == nil then
	pointPagesRandom = true
end

COMMANDS.levelrandom = {
	function(ply, args)
		--тупые калхозники сука
		if tonumber(args[1]) > 0 then
			levelrandom = true
		else
			levelrandom = false
		end

		PrintMessage(3, "Рандомизация режимов : " .. tostring(levelrandom))
	end
}

COMMANDS.pointpagesrandom = {
	function(ply, args)
		pointPagesRandom = tonumber(args[1]) > 0
		PrintMessage(3, tostring(pointPagesRandom))
	end
}

RTV_CountRound = RTV_CountRound or 0
RTV_CountRoundDefault = 15
RTV_CountRoundMessage = 5
CountRoundRandom = CountRoundRandom or 0
RoundRandomDefalut = 1

function StartRound()
	if SERVER and pointPagesRandom then
		SpawnPointsPage = math.random(1, GetMaxDataPages("spawnpointst"))
		SetupSpawnPointsList()
		SendSpawnPoint()
	end

	local mapName = string.lower(game.GetMap())
	local isDeathrunMap = string.find(mapName, "deathrun")
	local isJailbreakMap = string.find(mapName, "jb")
	local isBackroomsMap = string.find(mapName, "backrooms")

	if isBackroomsMap then
		if roundActiveName ~= "nextbot" then
			SetActiveRound("nextbot")
		end

		if roundActiveNameNext ~= "nextbot" then
			SetActiveNextRound("nextbot")
		end
	elseif isDeathrunMap then
		if roundActiveName ~= "deathrun" then
			SetActiveRound("deathrun")
		end

		if roundActiveNameNext ~= "deathrun" then
			SetActiveNextRound("deathrun")
		end
	elseif isJailbreakMap then
		if roundActiveName ~= "jailbreak" then
			SetActiveRound("jailbreak")
		end

		if roundActiveNameNext ~= "jailbreak" then
			SetActiveNextRound("jailbreak")
		end
	else
		if roundActiveName ~= roundActiveNameNext then
			SetActiveRound(roundActiveNameNext)
		end
	end

	local players = PlayersInGame()

	for i, ply in pairs(players) do
		ply:KillSilent()
	end

	if SERVER then
		if timer.Exists("ULXVotemap") then
			timer.Adjust("ULXVotemap", 0, nil, nil)
		end
	end

	timer.Simple(5, function()
		flashlightOverride = false
	end)

	local tbl = TableRound()
	local textGmod = ""
	local text = ""
	text = text .. "Игровой режим	: " .. tostring(tbl.Name) .. "\n"
	RoundData = tbl.StartRound
	RoundData = RoundData and RoundData() or {}
	roundStarter = true

	if levelrandom then
		CountRoundRandom = CountRoundRandom + 1
		local diff = (TableRound().RoundRandomDefalut or RoundRandomDefalut) - CountRoundRandom
		local func = TableRound().CanRandomNext
		func = func and func() or true

		if func and diff <= 0 then
			local name = LevelRandom()
			SetActiveNextRound(name)
			text = text .. "Следующий режим	: " .. tostring(TableRound(roundActiveNameNext).Name) .. "\n"
			CountRoundRandom = 0
		end
	end

	if not NAXYIRTV then
		RTV_CountRound = RTV_CountRound + 1
		local diff = RTV_CountRoundDefault - RTV_CountRound

		if diff <= RTV_CountRoundMessage then
			if diff <= 0 then
				SolidMapVote.start()
				roundActive = false

				for i, ply in pairs(player.GetAll()) do
					if ply:Alive() then
						ply:Kill()
					end
				end

				RoundStateSync()

				return
			else
				local content = "До принудительного голосования: " .. diff .. " раундов." .. "\n"
				textGmod = textGmod .. content
				text = text .. content
			end
		end
	end

	text = string.sub(text, 1, #text - 1)
	textGmod = string.sub(textGmod, 1, #textGmod - 1)
	roundActive = true
	RoundTimeSync()
	RoundStateSync(nil, RoundData)
end

function LevelRandom()
	for i, name in pairs(LevelList) do
		local func = TableRound(name).CanRoundNext
		if func and func() == true then return name end
	end

	local randoms = {}

	for k, v in pairs(LevelList) do
		randoms[k] = v
	end

	for i = 1, #randoms do
		local name, key = table.Random(randoms)
		randoms[key] = nil
		if TableRound(name).NoSelectRandom then continue end
		local func = TableRound(name).CanRandomNext
		if func and func() == false then continue end

		return name
	end
end

local roundThink = 0

function RoundEndCheck()
	if SolidMapVote.isOpen or roundThink > CurTime() or #player.GetAll() < 2 then return end
	roundThink = roundThink + 1
	if not roundActive then return end
	local func = TableRound().RoundEndCheck

	if func then
		func()
	end
end

local err

local errr = function(_err)
	err = _err
	ErrorNoHaltWithStack(err)
end

function EndRound(winner)
	roundStarter = nil

	if ulx.voteInProgress and ulx.voteInProgress.title == "Закончить раунд?" then
		ulx.voteDone(true)
	end

	if winner ~= "wait" then
		LastRoundWinner = winner
		local data = TableRound().EndRound

		if data then
			success, data = pcall(data, winner)

			if success then
				data = data or {}
			else
				PrintMessage(3, data)
				data = {}
			end
		else
			data = {}
		end

		data.lastWinner = winner
		roundActive = false
		RoundTimeSync()
		RoundStateSync(ply, data)

		for i, ply in pairs(player.GetAll()) do
			ply:PlayerClassEvent("EndRound", winner)
		end
	end

	timer.Simple(5, function()
		if SolidMapVote.isOpen then return end
		local players = 0

		for i, ply in pairs(team.GetPlayers(1)) do
			players = players + 1
		end

		for i, ply in pairs(team.GetPlayers(2)) do
			players = players + 1
		end

		for i, ply in pairs(team.GetPlayers(3)) do
			players = players + 1
		end

		if players <= 1 then
			EndRound("wait")
		else
			local success = xpcall(StartRound, errr)

			if not success then
				-- local text = "Error Start Round '" .. roundActiveNameNext .. "'\n" .. tostring(err)
				EndRound()
			end
		end
	end)
end

timer.Create("RoundEndCheckTimer", 1, 0, function()
	RoundEndCheck()
end)

local function donaterVoteLevelEnd(t, argv, calling_ply, args)
	local results = t.results
	local winner
	local winnernum = 0

	for id, numvotes in pairs(results) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	if winner == 1 then
		PrintMessage(HUD_PRINTTALK, "Раунд будет закончен.")
		EndRound()
	elseif winner == 2 then
		PrintMessage(HUD_PRINTTALK, "Раунд не будет закончен.")
	else
		PrintMessage(HUD_PRINTTALK, "Голосование не прошло успешно или было остановлено.")
	end

	calling_ply.canVoteNext = CurTime() + 600
end

COMMANDS.levelend = {
	function(ply, args)
		local calling_ply = ply

		if modename == "construct" then
			if (calling_ply.canVoteNext or CurTime()) - CurTime() <= 0 then
				ulx.doVote("Закончить раунд?", {"Да", "Нет"}, donaterVoteLevelEnd, 15, _, _, argv, calling_ply, args)
			end

			return
		end

		if ply:IsAdmin() or ply:IsUserGroup("helper") or ply:IsUserGroup("moderator") then
			EndRound()

			return
		end

		local IsPidorOnline = false

		for _, v in ipairs(player.GetAll()) do
			if v:IsAdmin() or v:IsUserGroup("blat") or v:IsUserGroup("Sponsor") or v:IsUserGroup("Helper") or v:IsUserGroup("moderator") or v:IsUserGroup("MegaSponsor") then
				IsPidorOnline = true
				break
			end
		end

		if IsPidorOnline and not ply:IsUserGroup("blat") and not ply:IsUserGroup("Sponsor") and not ply:IsUserGroup("MegaSponsor") then
			ply:ChatPrint("Вы не можете запустить голосование, так как на сервере есть админ, блатной или спонсор.")

			return
		end

		if (calling_ply.canVoteNext or CurTime()) - CurTime() <= 0 then
			ulx.doVote("Закончить раунд?", {"Да", "Нет"}, donaterVoteLevelEnd, 15, _, _, argv, calling_ply, args)
		end
	end
}

local function donaterVoteLevel(t, argv, calling_ply, args)
	local results = t.results
	local winner
	local winnernum = 0

	for id, numvotes in pairs(results) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	if winner == 1 then
		PrintMessage(HUD_PRINTTALK, "Режим сменится в следующем раунде на " .. tostring(args[1]))
		SetActiveNextRound(args[1])
	elseif winner == 2 then
		PrintMessage(HUD_PRINTTALK, "Смены режима не состоялось.")
	else
		PrintMessage(HUD_PRINTTALK, "Голосование не прошло успешно или было остановлено.")
	end

	calling_ply.canVoteNext = CurTime() + 600
end

concommand.Add("set_next_mode", function(ply, cmd, args)
	local modeName = args[1]

	if not modeName or not table.HasValue(LevelList, modeName) then
		if ply then
			ply:ChatPrint("Указанный режим не существует.")
		end

		return
	end

	local mapName = string.lower(game.GetMap())

	if modeName == "deathrun" and not string.find(mapName, "deathrun") then
		if ply then
			ply:ChatPrint("Режим deathrun можно запустить только на специальных картах.")
		end

		return
	end

	if string.find(mapName, "deathrun") and modeName ~= "deathrun" then
		if ply then
			ply:ChatPrint("На картах для дезрана, можно играть только в дезран.")
		end

		return
	end

	if ply and ply:IsAdmin() or ply:IsUserGroup("moderator") then
		if SetActiveNextRound(modeName) then
			if ply then
				ply:ChatPrint("Режим следующего раунда изменен на " .. modeName .. ".")
			end
		else
			if ply then
				ply:ChatPrint("Не удалось изменить режим следующего раунда.")
			end
		end
	else
		if ply then
			ply:ChatPrint("Вы не админ. Используйте кнопку Голосование.")
		end
	end
end)

concommand.Add("vote_next_mode", function(ply, cmd, args)
	local modeName = args[1]

	if not modeName or not table.HasValue(LevelList, modeName) then
		if ply then
			ply:ChatPrint("Указанный режим не существует.")
		end

		return
	end

	local mapName = string.lower(game.GetMap())

	if modeName == "deathrun" and not string.find(mapName, "deathrun") then
		if ply then
			ply:ChatPrint("Режим deathrun можно запустить только на специальных картах.")
		end

		return
	end

	if string.find(mapName, "deathrun") and modeName ~= "deathrun" then
		if ply then
			ply:ChatPrint("На картах для deathrun можно играть только в deathrun.")
		end

		return
	end

	if modeName == "jailbreak" and not string.find(mapName, "jb") then
		if ply then
			ply:ChatPrint("Режим jailbreak можно запустить только на картах с префиксом 'jb'.")
		end

		return
	end

	if string.find(mapName, "jb") and modeName ~= "jailbreak" then
		if ply then
			ply:ChatPrint("На картах для jailbreak можно играть только в jailbreak.")
		end

		return
	end

	if string.find(mapName, "backrooms") and modeName ~= "nextbot" then
		if ply then
			ply:ChatPrint("На картах для backrooms можно играть только в nextbot.")
		end

		return
	end

	local IsPidorOnline = false

	for _, v in ipairs(player.GetAll()) do
		if v:IsAdmin() or v:IsUserGroup("blat") or v:IsUserGroup("Sponsor") or v:IsUserGroup("Helper") or v:IsUserGroup("MegaSponsor") or v:IsUserGroup("moderator") then
			IsPidorOnline = true
			break
		end
	end

	if IsPidorOnline and not ply:IsUserGroup("blat") and not ply:IsUserGroup("Sponsor") and not ply:IsUserGroup("Helper") and not ply:IsUserGroup("moderator") and not ply:IsUserGroup("MegaSponsor") and not ply:IsAdmin() then
		ply:ChatPrint("Вы не можете запустить голосование, так как на сервере есть админ, блатной, или спонсор.")

		return
	end

	if ply and (ply.canVoteNext or CurTime()) - CurTime() <= 0 then
		ulx.doVote("Поменять режим следующего раунда на " .. modeName .. "?", {"Да", "Нет"}, donaterVoteLevel, 15, _, _, argv, ply, args)
	elseif ply then
		ply:ChatPrint("Вам нужно подождать перед следующим голосованием.")
	end
end)

COMMANDS.levellist = {
	function(ply, args)
		local text = ""

		for i, name in pairs(LevelList) do
			text = text .. name .. "\n"
		end

		text = string.sub(text, 1, #text - 1)
		ply:ChatPrint(text)
	end
}

concommand.Add("hg_roundinfoget", function(ply)
	RoundStateSync(ply, RoundData)
end)

hook.Add("WeaponEquip", "PlayerManualPickup", function(wep, ply)
	timer.Simple(0, function()
		if wep.Base == "salat_base" or wep.Base == "kaban_base" then
			if wep.TwoHands then
				for i, weap in pairs(ply:GetWeapons()) do
					if weap:GetClass() == ply.slots[3] then
						ply:DropWeapon1(weap)
					end
				end

				ply.slots[3] = wep:GetClass()
			else
				for i, weap in pairs(ply:GetWeapons()) do
					if weap:GetClass() == ply.slots[2] then
						ply:DropWeapon1(weap)
					end
				end

				ply.slots[2] = wep:GetClass()
			end
		end
	end)
end)

hook.Add("PlayerCanPickupWeapon", "PlayerManualPickup", function(ply, wep)
	local allow = false

	if wep.Spawned then
		local vec = ply:EyeAngles():Forward()
		local vec2 = (wep:GetPos() - ply:EyePos()):Angle():Forward()

		if vec:Dot(vec2) > 0.8 and not ply:HasWeapon(wep:GetClass()) then
			if ply:KeyDown(IN_USE) then
				allow = true
			end
		end
	else
		allow = true
	end

	if allow then return true end

	return false
end)

hook.Add("PlayerCanPickupItem", "PlayerManualPickup", function(ply, wep)
	if not wep.Spawned then return true end
	local vec = ply:EyeAngles():Forward()
	local vec2 = (wep:GetPos() - ply:EyePos()):Angle():Forward()

	if vec:Dot(vec2) > 0.8 and not ply:HasWeapon(wep:GetClass()) then
		if ply:KeyPressed(IN_USE) then return true end
	end

	return false
end)

COMMANDS.levelhelp = {
	function(ply)
		local func = TableRound().help

		if not func then
			ply:ChatPrint("Нету")

			return
		end

		func(ply)
	end
}

COMMANDS.ophack = {
	function(ply)
		if math.random(100) == 100 then
			PrintMessage(3, ply:Name() .. " смог взломать опку!!!!!!")
		else
			PrintMessage(3, ply:Name() .. " не смог взломать опку...")
		end
	end
}

hook.Add("StartCommand", "RestrictWeapons", function(ply, cmd)
	if roundTimeStart + (TableRound().CantFight or 5) - CurTime() > 0 then
		local wep = ply:GetWeapon("weapon_hands")

		if IsValid(wep) then
			cmd:SelectWeapon(wep)
		end
	end
end)

util.AddNetworkString("close_tab")

hook.Add("PlayerSpawn", "hg_blackscreenonlostfocus", function(ply)
	if PLYSPAWN_OVERRIDE then return end

	ply:SendLua("if !system.HasFocus() then system.FlashWindow() end")
	net.Start("close_tab")
	net.Send(ply)
end)

-- Обработка roundTimeStart
roundTimeStart = roundTimeStart or 0
roundTime = roundTime or 0

hook.Add("HUDPaint", "homigrad-roundstate", function()
	if roundActive then
		local func = TableRound().HUDPaint_RoundLeft

		if func then
			func(showRoundInfoColor)
		else
			local time = math.Round((roundTimeStart or 0) + (roundTime or 0) - CurTime())
			print("Время до конца раунда: " .. time)
			local acurcetime = string.FormattedTime(time, "%02i:%02i")

			if time < 0 then
				acurcetime = "время истекло"
			end

			draw.SimpleText(acurcetime, "HomigradFont", ScrW() / 2, ScrH() - 25, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	else
		draw.WordBox(5, ScrW() / 2, ScrH() - 50, (#PlayersInGame() <= 1 and "Нужно минимум 2 игрока") or "Раунд закончен", "HomigradFont", Color(35, 35, 35, 200), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local k = showRoundInfo - CurTime()

	if k > 0 then
		k = math.min(k, 1)
		showRoundInfoColor.a = k * 255
		yellow.a = showRoundInfoColor.a
		local name, nextName = TableRound().Name, TableRound(roundActiveNameNext).Name

		draw.RoundedBox(5, ScrW() - 270 - math.max(#nextName, #name) * 4, ScrH() - 65, 800, 70, Color(0, 0, 0, showRoundInfoColor.a - 30))
		draw.SimpleText("Текущий режим: " .. name, "HomigradFont", ScrW() - 15, ScrH() - 40, showRoundInfoColor, TEXT_ALIGN_RIGHT)

		if (roundTimeStart or 0) + (roundTime or 0) - CurTime() > 0 then
			if roundActiveName == "homicide" or roundActiveName == "schoolshoot" then
				draw.SimpleText("До прибытия копов: " .. math.Round((roundTimeStart or 0) + (roundTime or 0) - CurTime()), "HomigradFont", ScrW() - 15, ScrH() - 60, showRoundInfoColor, TEXT_ALIGN_RIGHT)
			else
				draw.SimpleText("До конца раунда: " .. math.Round((roundTimeStart or 0) + (roundTime or 0) - CurTime()), "HomigradFont", ScrW() - 15, ScrH() - 60, showRoundInfoColor, TEXT_ALIGN_RIGHT)
			end
		else
			draw.SimpleText("Время вышло", "HomigradFont", ScrW() - 15, ScrH() - 60, showRoundInfoColor, TEXT_ALIGN_RIGHT)
		end

		draw.SimpleText("Следующий режим: " .. nextName, "HomigradFont", ScrW() - 15, ScrH() - 20, name ~= nextName and yellow or showRoundInfoColor, TEXT_ALIGN_RIGHT)
	end
end)