COMMANDS = COMMANDS or {}

function COMMAND_FAKEPLYCREATE()
	local fakePly = {}

	function fakePly:IsValid() return true end
	function fakePly:IsAdmin() return true end
	function fakePly:GetUserGroup() return "superadmin" end
	function fakePly:Name() return "Console" end

	fakePly.fakePly = true

	return fakePly
end

local plyServer = COMMAND_FAKEPLYCREATE()
local speak = {}

if not HPrintMessage then
	HPrintMessage = PrintMessage
end

function PrintMessage(type, text)
	HPrintMessage(type, text)
	print("\t" .. text)
end

local validUserGroupSuperAdmin = {
	superadmin = true,
	admin = true,
	headadmin = true
}

local validUserGroup = {
	megapenis = true,
	MegaSponsor = true,
	user = true,
	blat = true,
	Sponsor = true,
	helper = true,
	moderator = true
}

function COMMAND_GETASSES(ply)
	local group = ply:GetUserGroup()

	if validUserGroup[group] then
		return 1
	elseif validUserGroupSuperAdmin[group] then
		return 2
	end

	return 0
end

function COMMAND_ASSES(ply, cmd)
	local access = cmd[2] or 1
	if access ~= 0 and COMMAND_GETASSES(ply) < access then return end

	return true
end

function COMMAND_GETARGS(args)
	local newArgs = {}
	local waitClose, waitCloseText

	for i, text in pairs(args) do
		if not waitClose and string.sub(text, 1, 1) == "\"" then
			waitClose = true

			if string.sub(text, #text, #text) == "\n" then
				newArgs[#newArgs + 1] = string.sub(text, 2, #text - 1)
				waitClose = nil
			else
				waitCloseText = string.sub(text, 2, #text)
			end

			continue
		end

		if waitClose then
			if string.sub(text, #text, #text) == "\"" then
				waitClose = nil
				newArgs[#newArgs + 1] = waitCloseText .. string.sub(text, 1, #text - 1)
			else
				waitCloseText = waitCloseText .. string.sub(text, 1, #text)
			end

			continue
		end

		newArgs[#newArgs + 1] = text
	end

	return newArgs
end

function PrintMessageChat(id, text)
	timer.Simple(0, function()
		if type(id) == "table" or type(id) == "Player" then
			if not IsValid(id) then return end

			id:ChatPrint(text)
		else
			PrintMessage(id, text)
		end
	end)
end

function COMMAND_Input(ply, args)
	local cmd = COMMANDS[args[1]]
	if not cmd then return false end
	if not COMMAND_ASSES(ply, cmd) then return true, false end

	table.remove(args, 1)

	return true, cmd[1](ply, args)
end

concommand.Add("hg_say", function(ply, cmd, args, text)
	if not IsValid(ply) then ply = plyServer end

	COMMAND_Input(ply, COMMAND_GETARGS(string.Split(text, " ")))
end)

hook.Add("PlayerCanSeePlayersChat", "AddSpawn", function(text, _, _, ply)
	if not IsValid(ply) then ply = plyServer end

	if speak[ply] then return end
	speak[ply] = true

	COMMAND_Input(ply, COMMAND_GETARGS(string.Split(string.sub(text, 2, #text), " ")))

	local func = TableRound().ShouldDiscordOutput
	if ply.fakePly or not func or (func and func(ply, text) == nil) then end
end)

hook.Add("Think", "Speak Chat Shit", function()
	for k in pairs(speak) do
		speak[k] = nil
	end
end)

local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:ConsolePrint(text)
	print(text)
end

COMMANDS.help = {
	function(ply, args)
		local text = ""

		if args[1] then
			local cmd = COMMANDS[args[1]]
			if not cmd then return end

			local argsList = cmd[3]

			if argsList then
				argsList = " - " .. argsList
			else
				argsList = ""
			end

			text = text .. "	" .. args[1] .. argsList .. "\n"
		else
			local list = {}

			for name in pairs(COMMANDS) do
				list[#list + 1] = name
			end

			table.sort(list, function(a, b) return a > b end)

			for _, name in pairs(list) do
				local cmd = COMMANDS[name]
				if not COMMAND_ASSES(ply, cmd) then continue end

				local argsList = cmd[3]

				if argsList then
					argsList = " - " .. argsList
				else
					argsList = ""
				end

				text = text .. "	" .. name .. argsList .. "\n"
			end
		end

		text = string.sub(text, 1, #text - 1)
		ply:ChatPrint(text)
	end,
	0
}

concommand.Add("setrolesilent", function(ply, cmd, args)
	if not ply:IsAdmin() then return end
	if #args < 2 then return ply:ChatPrint("Используйте: setrolesilent <имя_игрока> <T|CT>") end

	local targetPlayers = player.GetListByName(ply, args[1])
	if not targetPlayers then return ply:ChatPrint("Игрок(и) не найдены") end

	for _, targetPlayer in pairs(targetPlayers) do
		if not IsValid(targetPlayer) then return ply:ChatPrint("Игрок " .. args[1] .. " не найден.") end
		local role = string.upper(args[2]) -- Получаем роль (T или CT)

		if role == "T" then
			targetPlayer.forceT = true
			targetPlayer.forceCT = nil
		elseif role == "CT" then
			targetPlayer.forceCT = true
			targetPlayer.forceT = nil
		else
			ply:ChatPrint("Неверная роль. Используйте T или CT.")

			return
		end
	end
end)

concommand.Add("setrolesilentplayer", function(ply, cmd, args)
	if not ply:IsAdmin() then return end

	if #args < 2 then
		ply:ChatPrint("Используйте: setrolesilentplayer <имя_игрока> <T|CT>")

		return
	end

	local targetPlayers = player.GetListByName(ply, args[1])

	for _, targetPlayer in pairs(targetPlayers) do
		if not IsValid(targetPlayer) then
			ply:ChatPrint("Игрок " .. args[1] .. " не найден.")

			return
		end

		local role = string.upper(args[2]) -- Получаем роль (T или CT)

		if role == "T" then
			targetPlayer.forceT = true
			targetPlayer.forceCT = nil
			targetPlayer:ChatPrint("Ты будешь предателем в следующем раунде.")
		elseif role == "CT" then
			targetPlayer.forceCT = true
			targetPlayer.forceT = nil
			targetPlayer:ChatPrint("Ты будет невиновным в следующем раунде.")
		else
			ply:ChatPrint("Неверная роль. Используйте T или CT.")

			return
		end
	end
end)

COMMANDS.setrole = {
	function(ply, args)
		if not ply:IsAdmin() then return end

		if #args < 2 then
			ply:ChatPrint("Используйте: !setrole <имя_игрока> <T|CT>")

			return
		end

		local role = string.upper(args[2])
		local foundPlayers = player.GetListByName(ply, args[1])
		if not foundPlayers then return ply:ChatPrint("Игрок(и) не найдены") end

		for _, targetPlayer in ipairs(foundPlayers) do
			if role == "T" then
				targetPlayer.forceT = true
				targetPlayer.forceCT = nil

				targetPlayer:ChatPrint("Ты будешь предателем в следующем раунде.")

				local message = ply:Nick() .. " установил роль предателя для " .. targetPlayer:Nick() .. " на следующий раунд."
				PrintMessage(HUD_PRINTTALK, message)
				print(message)
			elseif role == "CT" then
				targetPlayer.forceCT = true
				targetPlayer.forceT = nil

				targetPlayer:ChatPrint("Ты будешь невиновным в следующем раунде.")

				local message = ply:Nick() .. " установил роль невиновного для " .. targetPlayer:Nick() .. " на следующий раунд."
				PrintMessage(HUD_PRINTTALK, message)
				print(message)
			else
				ply:ChatPrint("Неверная роль. Используйте T или CT.")

				return
			end
		end
	end
}

COMMANDS.sync = { -- а зачем?
	function(ply, args)
		Sync = tobool(args[1])

		if Sync then
			hook.Add("PlayerDeath", "synchronisation", function(ply)
				if ply:IsAdmin() or ply:Team() == 1002 then return end

				ply:Kick(tostring(args[2] or "noob"))
			end)

			hook.Add("PlayerSilentDeath", "synchronisation", function(ply)
				if ply:IsAdmin() or ply:Team() == 1002 then return end

				ply:Kick(tostring(args[2] or "noob"))
			end)
		else
			hook.Remove("PlayerDeath", "synchronisation")
			hook.Remove("PlayerSilentDeath", "synchronisation")
		end

		PrintMessage(3, "Синхра: " .. tostring(Sync))
	end
}

local validUserGroup = {
	superadmin = true,
	admin = true,
	meagsponsor = true,
	viptest = true,
	donator = true,
	blat = true
}

--[[
local function getNotDonaters()
	local list = player.GetAll()

	for i, ply in pairs(list) do
		local steamID = ply:SteamID()
		local group = ULib.ucl.users[steamID]

		if group and validUserGroup[group.group] then
			list[i] = nil
		end
	end

	return list
end
--]]

local function getDonaters()
	local list = {}

	for i, ply in pairs(player.GetAll()) do
		local steamID = ply:SteamID()
		local group = ULib.ucl.users[steamID]

		if group and validUserGroup[group.group] then
			list[#list + 1] = ply
		end
	end

	return list
end

MaxPlayers = tonumber(SData_Get("maxplayers"))
--[[
hook.Add("CheckPassword", "sync", function(steamID)
	steamID = util.SteamIDFrom64(steamID)

	local group = ULib.ucl.users[steamID]

	if group and validUserGroup[group.group] then
		RunConsoleCommand("sv_visiblemaxplayers", tostring(MaxPlayers + #getDonaters()))

		return
	end

	if MaxPlayers and #getNotDonaters() + 1 > MaxPlayers then return false, "Сервер заполнен." end
	if Sync then return false, "xd" end
end)
--]]

COMMANDS.setmaxplayers = {
	function(ply, args)
		if tonumber(args[1]) >= 0 then
			MaxPlayers = tonumber(args[1])
		else
			MaxPlayers = nil
		end

		SData_Set("maxplayers", MaxPlayers)

		RunConsoleCommand("sv_visiblemaxplayers", tostring(MaxPlayers + #getDonaters()))
		PrintMessageChat(3, "Лимит игроков : " .. tostring(MaxPlayers))
	end
}

CloseDev = tobool(SData_Get("dev"))

COMMANDS.closedev = {
	function(ply, args)
		CloseDev = tonumber(args[1]) > 0
		SData_Set("dev", tostring(CloseDev))

		if CloseDev then
			PrintMessageChat(3, "Сервер закрыт")
		else
			PrintMessageChat(3, "Сервер открыт")
		end
	end
}

function player.GetListByName(plr, name)
	local tbl = {}

	if name == "^" then
		return {plr}
	elseif name == "*" then
		return player.GetAll()
	end

	for i, ply in pairs(player.GetAll()) do
		if string.find(string.lower(ply:Name()), string.lower(name)) then
			tbl[#tbl + 1] = ply
		end
	end

	return (not table.IsEmpty(tbl) and tbl) or nil
end

COMMANDS.submat = {
	function(ply, args)
		if args[2] == "^" then
			ply:SetSubMaterial(tonumber(args[1], 10), args[2])
		end
	end
}