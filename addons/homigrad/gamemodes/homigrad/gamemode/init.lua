AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("remove_jmod_effects")

local specColor = Vector(0.25, 0.25, 0.25)

function GM:PlayerSpawn(ply)
	ply:SetNWEntity("HeSpectateOn", false)

	if PLYSPAWN_OVERRIDE then return end

	ply.allowFlashlights = false

	ply:RemoveFlags(FL_ONGROUND)
	ply:SetMaterial("")

	net.Start("remove_jmod_effects")
	net.Broadcast()

	ply.firstTimeNotifiedLeftLeg = true
	ply.firstTimeNotifiedRightLeg = true
	ply.attackees = {}

	ply:SetCanZoom(false)

	ply.Blood = 5000
	ply.pain = 0

	if ply.NEEDKILLNOW then
		if ply.NEEDKILLNOW == 1 then
			ply:KillSilent()
		else
			ply:KillSilent()
		end

		ply.NEEDKILLNOW = nil

		return
	end

	if not ply:Alive() then return end

	ply:UnSpectate()
	ply:SetupHands()

	if ply:GetNWBool("DynamicFlashlight") then
		ply:Flashlight(false)
	end

	ply:SetHealth(150)
	ply:SetMaxHealth(150)
	ply:SetWalkSpeed(200)
	ply:SetRunSpeed(350)
	ply:SetSlowWalkSpeed(75)
	ply:SetLadderClimbSpeed(75)
	ply:SetJumpPower(200)

	local size = 9

	ply.slots = {}

	ply:SetNWVector("HullMin", Vector(-size, -size, 0))
	ply:SetNWVector("Hull", Vector(size, size, DEFAULT_VIEW_OFFSET[3]))
	ply:SetNWVector("HullDuck", Vector(size, size, DEFAULT_VIEW_OFFSET_DUCKED[3]))
	ply:SetHull(ply:GetNWVector("HullMin"), ply:GetNWVector("Hull"))
	ply:SetHullDuck(ply:GetNWVector("HullMin"), ply:GetNWVector("HullDuck"))
	ply:SetViewOffset(DEFAULT_VIEW_OFFSET)
	ply:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)

	local phys = ply:GetPhysicsObject()

	if phys:IsValid() then
		phys:SetMass(DEFAULT_MASS)
	end

	ply:SetPlayerClass()

	if ply:Team() == 1002 then
		ply:SetModel("models/player/gman_high.mdl")
		ply:SetPlayerColor(specColor)

		ply:Give("weapon_hands")
		ply:Give("weapon_physgun")

		return
	end

	ply:PlayerClassEvent("On")

	TableRound().PlayerSpawn(ply, ply:Team())
end

function GM:PlayerDeath(ply, inf, att)
	if not roundActive then return end

	if att == ply then
		att = ply.Attacker2
	end

	if not IsValid(att) or att == ply or not att:IsPlayer() then return end
	ply.allowGrab = false

	timer.Simple(3, function()
		ply.allowGrab = true
	end)
end

hook.Add("HandlePlayerLanding", "ebalgmods", function() return true end)

function GM:PlayerInitialSpawn(ply)
	local func = TableRound().PlayerInitialSpawn

	if func then
		func(ply)
	else
		ply:SetTeam(1002)
	end

	if #player.GetAll() < 2 then
		EndRound()
	end

	ply.NEEDKILLNOW = 2
	ply.allowGrab = true

	RoundTimeSync(ply)
	RoundStateSync(ply, RoundData)
	RoundActiveSync(ply)
	RoundActiveNextSync(ply)

	SendSpawnPoint(ply)
end

function GM:PlayerDeathThink(ply)
	local tbl = {}

	for _, ply in ipairs(player.GetAll()) do
		if not ply:Alive() then continue end
		tbl[#tbl + 1] = ply
	end

	local key = ply:KeyDown(IN_RELOAD)

	if key ~= ply.oldKeyWalk and key then
		ply.EnableSpectate = not ply.EnableSpectate

		ply:ChatPrint(ply.EnableSpectate and "#hg.spec.orbit" or "#hg.spec.free")
	end

	ply.oldKeyWalk = key
	ply.SpectateGuy = ply.SpectateGuy or 0

	if ply.SpectateGuy > #tbl then
		ply.SpectateGuy = #tbl
	end

	if ply.EnableSpectate then
		ply:Spectate(OBS_MODE_CHASE)

		local key1 = ply:KeyDown(IN_ATTACK)
		local key2 = ply:KeyDown(IN_ATTACK2)

		if ply.oldKeyAttack1 ~= key1 and key1 then
			ply.SpectateGuy = ply.SpectateGuy + 1

			if ply.SpectateGuy > #tbl then
				ply.SpectateGuy = 1
			end
		elseif ply.oldKeyAttack2 ~= key2 and key2 then
			ply.SpectateGuy = ply.SpectateGuy - 1

			if ply.SpectateGuy == 0 then
				ply.SpectateGuy = #tbl
			end
		end

		local spec = tbl[ply.SpectateGuy]

		if not IsValid(spec) then
			ply.SpectateGuy = 1

			return
		end

		ply:SetPos(spec:GetPos() + Vector(0, 0, 40))

		local spec = spec
		ply:SetNWEntity("HeSpectateOn", spec)
		ply:SetMoveType(MOVETYPE_NONE)

		ply.oldKeyAttack1 = key1
		ply.oldKeyAttack2 = key2
	else
		ply:UnSpectate()
		ply:SetMoveType(MOVETYPE_NOCLIP)
		ply:SetNWEntity("HeSpectateOn", false)

		if ply:KeyDown(IN_ATTACK) then
			local tr = {}
			tr.start = ply:GetPos()
			tr.endpos = tr.start + ply:GetAimVector() * 128
			tr.filter = ply

			local traceResult = util.TraceLine(tr)

			local ent = traceResult.Entity
			if not ent:IsNPC() then return end

			hook.Run("Spectate NPC", ply, ent)
		end
	end

	local func = TableRound().PlayerDeathThink

	if func then
		return func(ply)
	else
		if roundActive then
			return false
		else
			return true
		end
	end
end

function GM:PlayerDisconnected(ply)
end

function GM:PlayerDeathSound()
	return true
end

COMMANDS.afk = {
	function(ply, args)
		local ent = ply:GetEyeTrace().Entity
		if ent == game.GetWorld() then ent = ply end

		local plr = RagdollOwner(ent) or ent or false

		if plr then
			plr:SetTeam(1002)
			plr:KillSilent()
		end
	end
}

COMMANDS.teamforce = {
	function(ply, args)
		local teamID = tonumber(args[2])
		local plrList = player.GetListByName(ply, args[1])
		if not plrList then return ply:ChatPrint("#hg.commands.playernotfound") end

		for i, ply in pairs(plrList) do
			ply:SetTeam(teamID)
		end
	end
}

local function PlayerCanJoinTeam(ply, teamID)
	local addT, addCT = 0, 0

	if teamID == 1 then
		addT = 1
	end

	if teamID == 2 then
		addCT = 1
	end

	local favorT, count = NeedAutoBalance(addT, addCT)

	if count and ((teamID == 1 and favorT) or (teamID == 2 and not favorT)) then
		ply:ChatPrint("#hg.commands.teamisfull")

		return false
	end

	return true
end

function GM:PlayerCanJoinTeam(ply, teamID)
	if teamID == 1002 then
		ply.NEEDKILLNOW = 1
	end

	if ply:Team() == 1002 then
		ply.NEEDKILLNOW = 2
	end

	if teamID == 1002 then return true end

	local result = TableRound().PlayerCanJoinTeam(ply, teamID)
	if result ~= nil then return result end

	local result = PlayerCanJoinTeam(ply, teamID)
	if result ~= nil then return result end
end

COMMANDS.scared = {
	function(ply, args)
		local value = tonumber(args[1]) == 1 and true or false

		ply:SetNWBool("scared", value)
		ply:ChatPrint(value and "#hg.commands.enabled" or "hg.commands.disabled")
	end
}

local validUserGroup = {}
validUserGroup.superadmin = true

COMMANDS.nortv = {
	function(ply, args)
		if not validUserGroup[ply:GetUserGroup()] then return end

		local value = tonumber(args[1]) <= 0

		disableRTV = not value

		PrintMessageChat(3, "#hg.commands.nortv" .. " " .. value and "#hg.commands.enabled" or "hg.commands.disabled")
	end,
	2
}

if not ulx.hvotemap then
	ulx.hvotemap = ulx.votemap
end

if not ulx.hvotemap2 then
	ulx.hvotemap2 = ulx.votemap2
end

function ulx.votemap(...)
	if disableRTV then
		return ULib.tsayError(calling_ply, "rtv is disabled", true)
	else
		ulx.hvotemap(...)
	end
end

local votemap = ulx.command(CATEGORY_NAME, "ulx votemap", ulx.votemap, "!votemap")

votemap:addParam{
	type = ULib.cmds.StringArg,
	completes = ulx.votemaps,
	hint = "map",
	ULib.cmds.takeRestOfLine, ULib.cmds.optional
}

votemap:defaultAccess(ULib.ACCESS_ALL)
votemap:help("Vote for a map, no args lists available maps.")

function ulx.votemap2(...)
	if disableRTV then
		return ULib.tsayError(calling_ply, "rtv is disabled", true)
	else
		ulx.hvotemap2(...)
	end
end

local votemap2 = ulx.command(CATEGORY_NAME, "ulx votemap2", ulx.votemap2, "!votemap2")

votemap2:addParam{
	type = ULib.cmds.StringArg,
	completes = ulx.maps,
	hint = "map",
	error = "invalid map \"%s\" specified",
	ULib.cmds.restrictToCompletes, ULib.cmds.takeRestOfLine, repeat_min = 1,
	repeat_max = 10
}

votemap2:defaultAccess(ULib.ACCESS_ADMIN)
votemap2:help("Starts a public map vote.")

hook.Add("Player Think", "HasGodMode Rep", function(ply)
	ply:SetNWBool("HasGodMode", ply:HasGodMode())
end)

resource.AddWorkshop("864612139") -- https://steamcommunity.com/sharedfiles/filedetails/?id=864612139

COMMANDS.roll = {
	function(ply, args)
		if not args[1] then return ply:ChatPrint("#hg.commands.roll.nonumber") end

		local r = math.random(1, tonumber(args[1]))

		for i, ply2 in pairs(player.GetAll()) do
			if GAMEMODE:PlayerCanSeePlayersChat("gg", false, ply2, ply) then
				PrintMessageChat(ply2, "#hg.commands.roll" .. " " .. r)
			end
		end
	end,
	nil, nil, true
}

concommand.Add("fullup", function(ply, cmd, args)
	if not ply:IsAdmin() and not ply:IsUserGroup("helper") and not ply:IsUserGroup("moderator") then return print("no") end

	if args[1] then
		local targets = player.GetListByName(ply, args[1])
		if not targets then return ply:ChatPrint("#hg.commands.playernotfound") end

		names = {}

		for _, plr in pairs(targets) do
			plr.stamina = 100
			plr.pain = 0
			plr.Blood = 5000
			plr.Bloodlosing = 0
			plr.dmgimpulse = 0

			table.insert(names, plr:Name())
		end

		names = table.concat(names, ", ")
	else
		ply.stamina = 100
		ply.pain = 0
		ply.Blood = 5000
		ply.Bloodlosing = 0
		ply.dmgimpulse = 0

		names = ply:Name()
	end

	for _, plr in ipairs(player.GetAll()) do
		plr:ChatPrint(ply:Nick() .. " used 'fullup' on " .. names)
	end

	print(string.format("%s used 'fullup' on %s", ply:Nick(), names))
end)

concommand.Add("sfullup", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end

	if args[1] then
		local targets = player.GetListByName(ply, args[1])
		if not targets then return ply:ChatPrint("#hg.commands.playernotfound") end

		for _, plr in pairs(targets) do
			plr.stamina = 100
			plr.pain = 0
			plr.Blood = 5000
			plr.Bloodlosing = 0
			plr.dmgimpulse = 0
		end
	else
		ply.stamina = 100
		ply.pain = 0
		ply.Blood = 5000
		ply.Bloodlosing = 0
		ply.dmgimpulse = 0
	end
end)

function GM:DoPlayerDeath(ply)
end

function GM:PlayerStartVoice(ply)
	if ply:Alive() then return true end
end

util.AddNetworkString("lasertgg")

net.Receive("lasertgg", function(len, ply)
	local boolen = net.ReadBool()

	net.Start("lasertgg")
		net.WriteEntity(ply)
		net.WriteBool(boolen)
	net.Broadcast()
end)