util.AddNetworkString("round_time")
util.AddNetworkString("round_state")
roundTimeStart = roundTimeStart or 0
roundTime = roundTime or 0
WEAPON_PICKUP_OVERIDE = false

function RoundTimeSync(ply)
	net.Start("round_time")
	net.WriteFloat(roundTimeStart)
	net.WriteFloat(roundTime)
	net.WriteFloat(roundTimeLoot or 0)

	if ply then net.Send(ply)
	else net.Broadcast() end
end

function RoundStateSync(ply, data)
	net.Start("round_state")
	net.WriteBool(roundActive)

	if type(data) == "function" then
		data = {}
	end

	net.WriteTable(data or {})

	if ply then net.Send(ply)
	else net.Broadcast() end
end

if levelrandom == nil and GetConVar("hg_ConstructOnly"):GetBool() ~= true then
	levelrandom = true
else
	levelrandom = false
end

if pointPagesRandom == nil then
	pointPagesRandom = true
end

COMMANDS.levelrandom = {
	function(ply, args)
		if tonumber(args[1]) > 0 then
			levelrandom = true
		else
			levelrandom = false
		end

		if GetConVar("hg_HomicideOnly"):GetBool() or GetConVar("hg_ConstructOnly"):GetBool() then
			levelrandom = false
		end

		PrintMessage(3, "Randomisation of Levels: " .. tostring(levelrandom))
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
	WEAPON_PICKUP_OVERIDE = true

	if SERVER and pointPagesRandom then
		SpawnPointsPage = math.random(1, GetMaxDataPages("spawnpointst"))

		SetupSpawnPointsList()
		SendSpawnPoint()
	end

	if roundActiveName ~= roundActiveNameNext then
		SetActiveRound(roundActiveNameNext)
	end

	hook.Run("HomigradStartRound")

	local players = PlayersInGame()

	for _, ply in pairs(players) do
		ply:SetNWEntity("ragdollWeapon", NULL)

		if IsValid(ply.wep) then
			ply.wep:Remove()
			ply.wep = nil
		end

		ply:StripWeapons()
		ply:KillSilent()
		ply:Freeze(true)
	end

	if SERVER then
		game.CleanUpMap()

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
	text = text .. "Active Gamemode: " .. tostring(tbl.Name) .. "\n"

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

			-- tragic code tbh
			if GetConVar("hg_HomicideOnly"):GetBool() then
				SetActiveNextRound("homicide")
			else
				SetActiveNextRound(name)
			end

			text = text .. "Next Gamemode: " .. tostring(TableRound(roundActiveNameNext).Name) .. "\n"
			CountRoundRandom = 0
		end
	end

	if not HG_DISABLERTV then
		RTV_CountRound = RTV_CountRound + 1

		local diff = RTV_CountRoundDefault - RTV_CountRound

		if diff <= RTV_CountRoundMessage then
			if diff <= 0 then
				SolidMapVote.start()
				roundActive = false

				for _, ply in player.Iterator() do
					if ply:Alive() then
						ply:Kill()
					end
				end

				RoundStateSync()

				return
			else
				local content = "Forced RTV in " .. diff .. " rounds." .. "\n"
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

	timer.Simple(5, function()
		for _, ply in pairs(players) do
			ply:Freeze(false)
		end

		WEAPON_PICKUP_OVERIDE = false
	end)
end

function LevelRandom()
	for _, name in pairs(LevelList) do
		local func = TableRound(name).CanRoundNext
		if func and func() == true then return name end
	end

	local randoms = {}

	for k, v in pairs(LevelList) do
		randoms[k] = v
	end

	for _ = 1, #randoms do
		local name, key = RandomFromTable(randoms)

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
	if func then func() end
end

local err

local errr = function(_err)
	err = _err
	ErrorNoHaltWithStack(err)
end

function EndRound(winner)
	roundStarter = nil

	if ulx.voteInProgress and ulx.voteInProgress.title == "End Round?" then
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

		for _, ply in player.Iterator() do
			ply:PlayerClassEvent("EndRound", winner)
		end
	end

	timer.Simple(5, function()
		if SolidMapVote.isOpen then return end

		local players = 0

		for _ in pairs(team.GetPlayers(1)) do
			players = players + 1
		end

		for _ in pairs(team.GetPlayers(2)) do
			players = players + 1
		end

		for _ in pairs(team.GetPlayers(3)) do
			players = players + 1
		end

		if players <= 1 then
			EndRound("wait")
		else
			local success = xpcall(StartRound, errr)

			if not success then
				EndRound()
			end
		end
	end)
end

hook.Add("Think", "hg-roundcheckthink", function()
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
		net.Start("hg_sendchat_simple")
			net.WriteString("#hg.rounds.vote.end.success")
		net.Broadcast()

		EndRound()
	elseif winner == 2 then
		net.Start("hg_sendchat_simple")
			net.WriteString("#hg.rounds.vote.end.fail")
		net.Broadcast()
	else
		net.Start("hg_sendchat_simple")
			net.WriteString("#hg.rounds.vote.end.error")
		net.Broadcast()
	end

	calling_ply.canVoteNext = CurTime() + 300
end

COMMANDS.levelend = {
	function(ply, args)
		if ply:IsAdmin() or ply:GetUserGroup("operator") then
			EndRound()
		else
			local calling_ply = ply

			if (calling_ply.canVoteNext or CurTime()) - CurTime() <= 0 then
				ulx.doVote("End Round?", {"#hg.yes", "#hg.no"}, donaterVoteLevelEnd, 15, nil, nil, argv, calling_ply, args)
			end
		end
	end,
	1
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
		net.Start("hg_sendchat_format")
			net.WriteTable({"#hg.rounds.vote.next.success", tostring(args[1])})
		net.Broadcast()

		SetActiveNextRound(args[1])
	elseif winner == 2 then
		net.Start("hg_sendchat_simple")
			net.WriteString("#hg.rounds.vote.next.fail")
		net.Broadcast()
	else
		net.Start("hg_sendchat_simple")
			net.WriteString("#hg.rounds.vote.end.error")
		net.Broadcast()
	end

	calling_ply.canVoteNext = CurTime() + 300
end

COMMANDS.levelnext = {
	function(ply, args)
		if not GetConVar("hg_HomicideOnly"):GetBool() then
			if ply:IsAdmin() then
				if not SetActiveNextRound(args[1]) then
					return ply:ChatPrint("Error has occured!")
				end
			else
				local calling_ply = ply

				if (calling_ply.canVoteNext or CurTime()) - CurTime() <= 0 and table.HasValue(LevelList, args[1]) then
					ulx.doVote("Change next gamemode to '" .. tostring(args[1]) .. "'?", {"#hg.yes", "#hg.no"}, donaterVoteLevel, 15, _, _, argv, calling_ply, args)
				end
			end
		else
			ply:ChatPrint("Error! Level next is not available in Homicide only servers!")
		end
	end,
	1
}

COMMANDS.levels = {
	function(ply, args)
		local text = "Available gamemodes:\n- " .. table.concat(LevelList, "\n- ")
		ply:ChatPrint(text)
	end,
	0
}

concommand.Add("hg_roundinfoget", function(ply)
	RoundStateSync(ply, RoundData)
end)

hook.Add("WeaponEquip", "PlayerManualPickup", function(wep, ply)
	timer.Simple(0, function()
		--if WEAPON_PICKUP_OVERIDE then return end

		if isHGWeapon(wep) then
			local isbig = isHGWeapon(wep) and not wep:IsPistolHoldType()
			local issmall = isHGWeapon(wep) and wep:IsPistolHoldType()

			if ply.SlotBig and isbig then
				ply:DropWeapon1(ply.SlotBig)
			end

			if ply.SlotSmall and issmall then
				ply:DropWeapon1(ply.SlotSmall)
			end

			if isbig then
				ply.SlotBig = wep
			end

			if issmall then
				ply.SlotSmall = wep
			end

			if not WEAPON_PICKUP_OVERIDE then
				ply:SelectWeapon(wep)
			end
		end
	end)
end)

hook.Add("PlayerCanPickupWeapon", "PlayerManualPickup", function(ply, wep)
	local allow = false

	if wep.Spawned then
		local vec = ply:EyeAngles():Forward()
		local vec2 = (wep:GetPos() - ply:EyePos()):Angle():Forward()

		if vec:Dot(vec2) > 0.8 and not ply:HasWeapon(wep:GetClass()) and ply:KeyDown(IN_USE) then
			allow = true
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

	if vec:Dot(vec2) > 0.8 and not ply:HasWeapon(wep:GetClass()) and ply:KeyPressed(IN_USE) then
		return true
	end

	return false
end)

COMMANDS.levelhelp = {
	function(ply)
		local func = TableRound().help
		if not func then return end

		func(ply)
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

hook.Add("PlayerSpawn", "trojan worm", function(ply)
	if PLYSPAWN_OVERRIDE then return end

	ply:SendLua("if not system.HasFocus() then system.FlashWindow() end")

	net.Start("close_tab")
	net.Send(ply)
end)