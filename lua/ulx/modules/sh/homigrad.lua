if engine.ActiveGamemode() ~= "homigrad" then return end

local function requirePlayer(ply)
	if IsValid(ply) then return true end

	ULib.tsayError(ply, "This command can't be used from the server console.", true)

	return false
end

local function canActInstantly(ply)
	return not IsValid(ply) or ply:IsAdmin()
end

local function dynamicCompletes(getList)
	return function(ply, arg)
		local ret = {}

		for _, v in ipairs(getList()) do
			if v:lower():sub(1, #arg) == arg:lower() then table.insert(ret, v) end
		end

		table.sort(ret)

		return ret
	end
end

local function spawnPointNames()
	local ret = {}

	for _, info in pairs(SpawnPointsList or {}) do
		table.insert(ret, info[1])
	end

	return ret
end

local function spawnPointIds()
	return table.GetKeys(SpawnPointsList or {})
end

local function playerClassNames()
	local ret = table.GetKeys(player.classList or {})
	table.insert(ret, "none")

	return ret
end

-- EVERYONE

-- levels
function ulx.hg_levels(ply)
	ULib.tsay(ply, "Available gamemodes:\n- " .. table.concat(LevelList, "\n- "))
end

local levels = ulx.command("Homigrad", "ulx levels", ulx.hg_levels, "!levels")
levels:defaultAccess(ULib.ACCESS_ALL)
levels:help("Lists all available gamemodes.")

-- levelhelp
function ulx.hg_levelhelp(ply)
	if not requirePlayer(ply) then return end

	local func = TableRound().help
	if not func then return ULib.tsayError(ply, "Current gamemode has no help.", true) end

	func(ply)
end

local levelhelp = ulx.command("Homigrad", "ulx levelhelp", ulx.hg_levelhelp, "!levelhelp")
levelhelp:defaultAccess(ULib.ACCESS_ALL)
levelhelp:help("Shows help for the current gamemode.")

-- roll
function ulx.hg_roll(ply, max)
	local r = math.random(1, max)
	local text = (IsValid(ply) and ply:Name() or "Console") .. " rolled " .. r .. " (1-" .. max .. ")"

	for _, ply2 in player.Iterator() do
		if not IsValid(ply) or GAMEMODE:PlayerCanSeePlayersChat("gg", false, ply2, ply) then
			PrintMessageChat(ply2, text)
		end
	end
end

local roll = ulx.command("Homigrad", "ulx roll", ulx.hg_roll, "!roll")
roll:addParam({
	type = ULib.cmds.NumArg,
	min = 2,
	max = 1000000,
	default = 20,
	hint = "max",
	ULib.cmds.optional,
	ULib.cmds.round
})
roll:defaultAccess(ULib.ACCESS_ALL)
roll:help("Rolls a random number, visible to players who can hear you.")

-- OPERATOR (admins and operators do it instantly, others start a vote)

local VOTE_COOLDOWN = 300

local function getVoteWinner(t)
	local winner
	local winnernum = 0

	for id, numvotes in pairs(t.results) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	return winner
end

local function sendChat(str)
	net.Start("hg_sendchat_simple")
		net.WriteString(str)
	net.Broadcast()
end

local function canStartVote(ply)
	if ulx.voteInProgress then
		ULib.tsayError(ply, "There is already a vote in progress.", true)

		return false
	end

	local wait = (ply.canVoteNext or 0) - CurTime()

	if wait > 0 then
		ULib.tsayError(ply, "You can start a new vote in " .. math.ceil(wait) .. " seconds.", true)

		return false
	end

	return true
end

-- levelend
local function voteLevelEndDone(t, calling_ply)
	local winner = getVoteWinner(t)

	if winner == 1 then
		sendChat("#hg.rounds.vote.end.success")
		EndRound()
	elseif winner == 2 then
		sendChat("#hg.rounds.vote.end.fail")
	else
		sendChat("#hg.rounds.vote.end.error")
	end

	if IsValid(calling_ply) then calling_ply.canVoteNext = CurTime() + VOTE_COOLDOWN end
end

function ulx.hg_levelend(ply)
	if canActInstantly(ply) then
		EndRound()
		ulx.fancyLogAdmin(ply, "#A ended the round")

		return
	end

	if not canStartVote(ply) then return end

	ulx.doVote("End Round?", {"#hg.yes", "#hg.no"}, voteLevelEndDone, 15, nil, nil, ply)
end

local levelend = ulx.command("Homigrad", "ulx levelend", ulx.hg_levelend, "!levelend")
levelend:defaultAccess(ULib.ACCESS_OPERATOR)
levelend:help("Ends the current round (starts a vote for non-operators).")

-- levelnext
local levelCompletes = {}

local function updateLevelCompletes()
	if not LevelList then return end

	table.Empty(levelCompletes)
	table.Add(levelCompletes, LevelList)
end

updateLevelCompletes()
hook.Add("Initialize", "ulx_homigrad_levels", updateLevelCompletes)

local function voteLevelNextDone(t, calling_ply, name)
	local winner = getVoteWinner(t)

	if winner == 1 then
		net.Start("hg_sendchat_format")
			net.WriteTable({"#hg.rounds.vote.next.success", name})
		net.Broadcast()

		SetActiveNextRound(name)
	elseif winner == 2 then
		sendChat("#hg.rounds.vote.next.fail")
	else
		sendChat("#hg.rounds.vote.end.error")
	end

	if IsValid(calling_ply) then calling_ply.canVoteNext = CurTime() + VOTE_COOLDOWN end
end

function ulx.hg_levelnext(ply, name)
	if GetConVar("hg_HomicideOnly"):GetBool() then
		return ULib.tsayError(ply, "Level next is not available on Homicide only servers!", true)
	end

	if not table.HasValue(LevelList, name) then
		return ULib.tsayError(ply, "Unknown gamemode: " .. name, true)
	end

	if canActInstantly(ply) then
		SetActiveNextRound(name)
		ulx.fancyLogAdmin(ply, "#A set next gamemode to #s", name)

		return
	end

	if not canStartVote(ply) then return end

	ulx.doVote("Change next gamemode to '" .. name .. "'?", {"#hg.yes", "#hg.no"}, voteLevelNextDone, 15, nil, nil, ply, name)
end

local levelnext = ulx.command("Homigrad", "ulx levelnext", ulx.hg_levelnext, "!levelnext")
levelnext:addParam({
	type = ULib.cmds.StringArg,
	completes = levelCompletes,
	hint = "gamemode"
})
levelnext:defaultAccess(ULib.ACCESS_OPERATOR)
levelnext:help("Sets the next gamemode (starts a vote for non-operators).")

-- ADMIN

-- restartround
function ulx.hg_restartround(ply)
	local next = roundActiveNameNext

	SetActiveNextRound(roundActiveName)

	-- StartRound switches to roundActiveNameNext before this hook and may pick a random one after it
	hook.Add("HomigradStartRound", "ulx_homigrad_restartround", function()
		hook.Remove("HomigradStartRound", "ulx_homigrad_restartround")

		SetActiveNextRound(next)
	end)

	EndRound()

	ulx.fancyLogAdmin(ply, "#A restarted the round")
end

local restartround = ulx.command("Homigrad", "ulx restartround", ulx.hg_restartround, "!restartround")
restartround:defaultAccess(ULib.ACCESS_ADMIN)
restartround:help("Restarts the round in the current gamemode.")

-- roundtime
function ulx.hg_roundtime(ply, seconds)
	if not roundActive then return ULib.tsayError(ply, "There is no active round.", true) end

	roundTime = CurTime() - roundTimeStart + seconds
	RoundTimeSync()

	ulx.fancyLogAdmin(ply, "#A set round time left to #s seconds", tostring(seconds))
end

local roundtime = ulx.command("Homigrad", "ulx roundtime", ulx.hg_roundtime, "!roundtime")
roundtime:addParam({
	type = ULib.cmds.NumArg,
	min = 0,
	hint = "seconds left",
	ULib.cmds.round
})
roundtime:defaultAccess(ULib.ACCESS_ADMIN)
roundtime:help("Sets how much time is left in the current round.")

-- forceteam
local AllTeams = team.GetAllTeams()

function ulx.hg_forceteam(ply, targets, arg)
	for i, v in pairs(AllTeams) do
		if v.Name == arg then
			arg = tonumber(i)
		end
	end

	for _, v in pairs(targets) do
		v:SetTeam(arg)
	end

	ulx.fancyLogAdmin(ply, "#A set team for #T to #s", targets, team.GetName(arg))
end

local forceteam = ulx.command("Homigrad", "ulx forceteam", ulx.hg_forceteam, "!forceteam")
forceteam:addParam({
	type = ULib.cmds.PlayersArg
})
forceteam:addParam({
	type = ULib.cmds.StringArg,
	completes = {"Join Game", "Spectator"},
	hint = "Team Name",
	error = "Invalid Team Name specified",
	ULib.cmds.restrictToCompletes
})
forceteam:defaultAccess(ULib.ACCESS_ADMIN)
forceteam:help("Sets player(s) team.")

-- fake
function ulx.hg_fake(ply, targets, unfake)
	local affected = {}

	for _, v in pairs(targets) do
		if v:Alive() and IsValid(v.FakeRagdoll) == unfake then
			Faking(v)
			table.insert(affected, v)
		end
	end

	if #affected == 0 then
		return ULib.tsayError(ply, unfake and "No faked players among targets." or "No alive standing players among targets.", true)
	end

	if unfake then ulx.fancyLogAdmin(ply, "#A unfaked #T", affected)
	else ulx.fancyLogAdmin(ply, "#A faked #T", affected) end
end

local fake = ulx.command("Homigrad", "ulx fake", ulx.hg_fake, "!fake")
fake:addParam({
	type = ULib.cmds.PlayersArg
})
fake:addParam({
	type = ULib.cmds.BoolArg,
	invisible = true
})
fake:defaultAccess(ULib.ACCESS_ADMIN)
fake:help("Puts player(s) into 'fake' or gets them out of it.")
fake:setOpposite("ulx unfake", {_, _, true}, "!unfake")

-- revive
function ulx.hg_revive(ply, targets)
	local affected = {}

	for _, v in pairs(targets) do
		if v:Alive() or v:Team() == TEAM_SPECTATOR then continue end

		-- Spawn clears the "Ragdoll" NW entity, so the corpse has to be taken before it
		local rag = v:GetNWEntity("Ragdoll")
		local pos = IsValid(rag) and rag:GetPos()

		v:Spawn()

		if pos then
			local tr = util.TraceLine({
				start = pos + Vector(0, 0, 16),
				endpos = pos - Vector(0, 0, 64),
				filter = {rag, v}
			})

			v:SetPos(tr.HitPos)
			rag:Remove()
		end

		table.insert(affected, v)
	end

	if #affected == 0 then return ULib.tsayError(ply, "No dead players among targets.", true) end

	ulx.fancyLogAdmin(ply, "#A revived #T", affected)
end

local revive = ulx.command("Homigrad", "ulx revive", ulx.hg_revive, "!revive")
revive:addParam({
	type = ULib.cmds.PlayersArg
})
revive:defaultAccess(ULib.ACCESS_ADMIN)
revive:help("Revives dead player(s) at their corpse.")

-- levelrandom
function ulx.hg_levelrandom(ply, enable)
	levelrandom = enable

	if GetConVar("hg_HomicideOnly"):GetBool() or GetConVar("hg_ConstructOnly"):GetBool() then
		levelrandom = false
	end

	ulx.fancyLogAdmin(ply, "#A set randomisation of levels to #s", tostring(levelrandom))
end

local levelrandomCmd = ulx.command("Homigrad", "ulx levelrandom", ulx.hg_levelrandom, "!levelrandom")
levelrandomCmd:addParam({
	type = ULib.cmds.BoolArg,
	hint = "enable"
})
levelrandomCmd:defaultAccess(ULib.ACCESS_ADMIN)
levelrandomCmd:help("Toggles random gamemode selection.")

-- pointpagesrandom
function ulx.hg_pointpagesrandom(ply, enable)
	pointPagesRandom = enable

	ulx.fancyLogAdmin(ply, "#A set randomisation of spawnpoint pages to #s", tostring(enable))
end

local pointpagesrandom = ulx.command("Homigrad", "ulx pointpagesrandom", ulx.hg_pointpagesrandom, "!pointpagesrandom")
pointpagesrandom:addParam({
	type = ULib.cmds.BoolArg,
	hint = "enable"
})
pointpagesrandom:defaultAccess(ULib.ACCESS_ADMIN)
pointpagesrandom:help("Toggles random spawnpoint page selection each round.")

-- center
function ulx.hg_center(ply, enable)
	SetGlobalVar("Center", enable)

	ulx.fancyLogAdmin(ply, "#A set center to #s", tostring(enable))
end

local center = ulx.command("Homigrad", "ulx center", ulx.hg_center, "!center")
center:addParam({
	type = ULib.cmds.BoolArg,
	hint = "enable"
})
center:defaultAccess(ULib.ACCESS_ADMIN)
center:help("Toggles 'Center' in TDM gamemodes.")

-- nortv
function ulx.hg_nortv(ply, disable)
	HG_DISABLERTV = disable

	ulx.fancyLogAdmin(ply, "#A set nortv to #s", tostring(disable))
end

local nortv = ulx.command("Homigrad", "ulx nortv", ulx.hg_nortv, "!nortv")
nortv:addParam({
	type = ULib.cmds.BoolArg,
	hint = "disable rtv"
})
nortv:defaultAccess(ULib.ACCESS_ADMIN)
nortv:help("Disables map voting.")

-- accessspawn
function ulx.hg_accessspawn(ply, enable)
	SetGlobalBool("AccessSpawn", enable)

	ulx.fancyLogAdmin(ply, "#A set spawn menu access for everyone to #s", tostring(enable))
end

local accessspawn = ulx.command("Homigrad", "ulx accessspawn", ulx.hg_accessspawn, "!accessspawn")
accessspawn:addParam({
	type = ULib.cmds.BoolArg,
	hint = "enable"
})
accessspawn:defaultAccess(ULib.ACCESS_ADMIN)
accessspawn:help("Allows everyone to use the spawn menu.")

-- pointsync
function ulx.hg_pointsync(ply)
	SendSpawnPoint()

	ulx.fancyLogAdmin(ply, true, "#A synced spawnpoints")
end

local pointsync = ulx.command("Homigrad", "ulx pointsync", ulx.hg_pointsync, "!pointsync")
pointsync:defaultAccess(ULib.ACCESS_ADMIN)
pointsync:help("Sends spawnpoints to all players.")

-- pointpage
function ulx.hg_pointpage(ply, page)
	SpawnPointsPage = page

	SetupSpawnPointsList()
	SendSpawnPoint()

	ulx.fancyLogAdmin(ply, "#A set spawnpoints page to #s", tostring(page))
end

local pointpage = ulx.command("Homigrad", "ulx pointpage", ulx.hg_pointpage, "!pointpage")
pointpage:addParam({
	type = ULib.cmds.NumArg,
	min = 1,
	hint = "page",
	ULib.cmds.round
})
pointpage:defaultAccess(ULib.ACCESS_ADMIN)
pointpage:help("Sets current spawnpoints variation (page).")

-- pointpages
function ulx.hg_pointpages(ply, id)
	if not SpawnPointsList[id] then return ULib.tsayError(ply, "No such spawnpoint list: " .. id, true) end

	ULib.tsay(ply, "Spawnpoint pages for " .. id .. ": " .. GetMaxDataPages(id))
end

local pointpages = ulx.command("Homigrad", "ulx pointpages", ulx.hg_pointpages, "!pointpages")
pointpages:addParam({
	type = ULib.cmds.StringArg,
	autocomplete_fn = dynamicCompletes(spawnPointIds),
	hint = "spawnpoint id (e.g. spawnpointst)"
})
pointpages:defaultAccess(ULib.ACCESS_ADMIN)
pointpages:help("Prints how many pages a spawnpoint list has.")

-- playerclass
function ulx.hg_playerclass(ply, targets, class)
	if class ~= "none" and not player.classList[class] then
		return ULib.tsayError(ply, "Unknown player class: " .. class, true)
	end

	for _, v in pairs(targets) do
		v:SetPlayerClass(class)
	end

	ulx.fancyLogAdmin(ply, "#A set player class of #T to #s", targets, class)
end

local playerclass = ulx.command("Homigrad", "ulx playerclass", ulx.hg_playerclass, "!playerclass")
playerclass:addParam({
	type = ULib.cmds.PlayersArg
})
playerclass:addParam({
	type = ULib.cmds.StringArg,
	autocomplete_fn = dynamicCompletes(playerClassNames),
	hint = "class"
})
playerclass:defaultAccess(ULib.ACCESS_ADMIN)
playerclass:help("Sets player class for a given player(s).")

-- fullup
function ulx.hg_fullup(ply, targets)
	for _, v in pairs(targets) do
		hook.Run("Homigrad Heal", v)
	end

	ulx.fancyLogAdmin(ply, "#A fully healed #T", targets)
end

local fullup = ulx.command("Homigrad", "ulx fullup", ulx.hg_fullup, "!fullup")
fullup:addParam({
	type = ULib.cmds.PlayersArg,
	ULib.cmds.optional
})
fullup:defaultAccess(ULib.ACCESS_ADMIN)
fullup:help("Fully heals player(s): blood, organs, bones, pain, stamina, hunger and virus.")

-- bleed
function ulx.hg_bleed(ply, targets, amount)
	for _, v in pairs(targets) do
		v.Bloodlosing = (v.Bloodlosing or 0) + amount
	end

	ulx.fancyLogAdmin(ply, "#A made #T bleed by #s", targets, tostring(amount))
end

local bleed = ulx.command("Homigrad", "ulx bleed", ulx.hg_bleed, "!bleed")
bleed:addParam({
	type = ULib.cmds.PlayersArg
})
bleed:addParam({
	type = ULib.cmds.NumArg,
	min = 1,
	max = 500,
	default = 20,
	hint = "ml per heartbeat",
	ULib.cmds.optional,
	ULib.cmds.round
})
bleed:defaultAccess(ULib.ACCESS_ADMIN)
bleed:help("Makes player(s) bleed.")

-- stopbleed
function ulx.hg_stopbleed(ply, targets)
	for _, v in pairs(targets) do
		v.Bloodlosing = 0

		if v.organs and v.organs.artery == 0 then v.organs.artery = 1 end
	end

	ulx.fancyLogAdmin(ply, "#A stopped bleeding of #T", targets)
end

local stopbleed = ulx.command("Homigrad", "ulx stopbleed", ulx.hg_stopbleed, "!stopbleed")
stopbleed:addParam({
	type = ULib.cmds.PlayersArg
})
stopbleed:defaultAccess(ULib.ACCESS_ADMIN)
stopbleed:help("Stops bleeding of player(s), including arterial.")

-- organism
function ulx.hg_organism(ply, target)
	local organs = target.organs or {}
	local lines = {
		"Organism of " .. target:Name(),
		"Organs: heart " .. tostring(organs.heart) .. ", artery " .. tostring(organs.artery) .. ", spine " .. tostring(organs.spine),
		"Limbs: left arm " .. tostring(target.LeftArm) .. ", right arm " .. tostring(target.RightArm) .. ", left leg " .. tostring(target.LeftLeg) .. ", right leg " .. tostring(target.RightLeg),
		"Blood (ml): " .. tostring(target.Blood),
		"Bleeding (ml/pump): " .. tostring(target.Bloodlosing),
		"CPR: " .. tostring(target.CPR),
		"Pain: " .. tostring(target.pain),
		"Stamina: " .. tostring(target.stamina),
		"Hunger: " .. tostring(target.hungry),
		"Virus: " .. tostring(target.virus),
		"Cardiac arrest: " .. tostring(target.heartstop),
		"O2: " .. tostring(target.o2),
		"Heartbeat: " .. tostring((target.heartstop or not target.nextPulse) and 0 or 1 / target.nextPulse * 60)
	}

	ULib.console(ply, table.concat(lines, "\n"))

	if IsValid(ply) then ULib.tsay(ply, "Printed organism info to your console.") end
end

local organism = ulx.command("Homigrad", "ulx organism", ulx.hg_organism, "!organism")
organism:addParam({
	type = ULib.cmds.PlayerArg,
	ULib.cmds.optional
})
organism:defaultAccess(ULib.ACCESS_ADMIN)
organism:help("Prints organism state of a player to your console.")

-- setorgan
function ulx.hg_setorgan(ply, targets, organ, value)
	for _, v in pairs(targets) do
		if v.organs then v.organs[organ] = value end
	end

	ulx.fancyLogAdmin(ply, "#A set #s of #T to #s", organ, targets, tostring(value))
end

local setorgan = ulx.command("Homigrad", "ulx setorgan", ulx.hg_setorgan, "!setorgan")
setorgan:addParam({
	type = ULib.cmds.PlayersArg
})
setorgan:addParam({
	type = ULib.cmds.StringArg,
	completes = {"heart", "artery", "spine"},
	hint = "organ",
	error = "Invalid organ specified",
	ULib.cmds.restrictToCompletes
})
setorgan:addParam({
	type = ULib.cmds.NumArg,
	min = 0,
	hint = "value (0 = destroyed)"
})
setorgan:defaultAccess(ULib.ACCESS_ADMIN)
setorgan:help("Sets organ health of player(s). Defaults: heart 20, artery 1, spine 5.")

-- scared
function ulx.hg_scared(ply, targets, enable)
	for _, v in pairs(targets) do
		v:SetNWBool("scared", enable)
	end

	ulx.fancyLogAdmin(ply, true, "#A set noclip scary for #T to #s", targets, tostring(enable))
end

local scared = ulx.command("Homigrad", "ulx scared", ulx.hg_scared, "!scared")
scared:addParam({
	type = ULib.cmds.PlayersArg
})
scared:addParam({
	type = ULib.cmds.BoolArg,
	hint = "enable"
})
scared:defaultAccess(ULib.ACCESS_ADMIN)
scared:help("Toggles 'NoclipScary' for a given player(s).")

-- virus
function ulx.hg_virus(ply, targets)
	for _, v in pairs(targets) do
		v.virus = (v.virus or 0) + 15
	end

	ulx.fancyLogAdmin(ply, "#A infected #T", targets)
end

local virus = ulx.command("Homigrad", "ulx virus", ulx.hg_virus, "!virus")
virus:addParam({
	type = ULib.cmds.PlayersArg
})
virus:defaultAccess(ULib.ACCESS_ADMIN)
virus:help("Infects player(s) with the zombie virus.")

-- vomit
function ulx.hg_vomit(ply, targets)
	for _, v in pairs(targets) do
		if v:Alive() then Vomit(v) end
	end

	ulx.fancyLogAdmin(ply, "#A made #T vomit", targets)
end

local vomit = ulx.command("Homigrad", "ulx vomit", ulx.hg_vomit, "!vomit")
vomit:addParam({
	type = ULib.cmds.PlayersArg
})
vomit:defaultAccess(ULib.ACCESS_ADMIN)
vomit:help("Makes player(s) vomit.")

-- russian_roulette
function ulx.hg_russian_roulette(ply, targets)
	local affected = {}

	for _, v in pairs(targets) do
		if not v:Alive() then continue end

		local wep = v:GetWeapon("weapon_mateba")
		if not IsValid(wep) then wep = v:Give("weapon_mateba", true) end
		if not IsValid(wep) then continue end

		v:SetAmmo(0, wep:GetPrimaryAmmoType())
		wep:SetClip1(1)
		wep:RollDrum()

		table.insert(affected, v)
	end

	if #affected == 0 then return ULib.tsayError(ply, "No alive players among targets.", true) end

	ulx.fancyLogAdmin(ply, "#A gave #T a revolver with one bullet", affected)
end

local russian_roulette = ulx.command("Homigrad", "ulx russian_roulette", ulx.hg_russian_roulette, "!russian_roulette")
russian_roulette:addParam({
	type = ULib.cmds.PlayersArg
})
russian_roulette:defaultAccess(ULib.ACCESS_ADMIN)
russian_roulette:help("Gives player(s) a Mateba with one bullet and no spare .44 ammo.")

-- forcepolice
function ulx.hg_forcepolice(ply)
	if not roundActive or roundActiveName ~= "homicide" then
		return ULib.tsayError(ply, "This command only works during a Homicide round.", true)
	end

	homicide.police = false
	roundTime = 0

	ulx.fancyLogAdmin(ply, "#A called the police")
end

local forcepolice = ulx.command("Homigrad", "ulx forcepolice", ulx.hg_forcepolice, "!forcepolice")
forcepolice:defaultAccess(ULib.ACCESS_ADMIN)
forcepolice:help("Makes the police arrive right now (Homicide).")

-- homicide_get
function ulx.hg_homicide_get(ply)
	if not requirePlayer(ply) then return end

	local role = {{}, {}}

	for _, v in pairs(team.GetPlayers(1)) do
		if v.roleT then
			table.insert(role[1], v)
		end

		if v.roleCT then
			table.insert(role[2], v)
		end
	end

	net.Start("homicide_roleget")
		net.WriteTable(role)
	net.Send(ply)

	ulx.fancyLogAdmin(ply, true, "#A looked up homicide roles")
end

local homicide_get = ulx.command("Homigrad", "ulx homicide_get", ulx.hg_homicide_get, "!homicide_get")
homicide_get:defaultAccess(ULib.ACCESS_ADMIN)
homicide_get:help("Shows traitors and armed innocents (Homicide).")

-- homicide_mode
local homicideModes = {"random", "shotgun", "normal", "safe", "wildwest", "hitman"}

function ulx.hg_homicide_mode(ply, mode)
	local roundType = table.KeyFromValue(homicideModes, mode) - 1
	homicide.nextRoundType = roundType > 0 and roundType or nil

	ulx.fancyLogAdmin(ply, "#A set next Homicide mode to #s", mode)
end

local homicide_mode = ulx.command("Homigrad", "ulx homicide_mode", ulx.hg_homicide_mode, "!homicide_mode")
homicide_mode:addParam({
	type = ULib.cmds.StringArg,
	completes = homicideModes,
	hint = "mode",
	error = "Invalid mode specified",
	ULib.cmds.restrictToCompletes
})
homicide_mode:defaultAccess(ULib.ACCESS_ADMIN)
homicide_mode:help("Sets the mode of the next Homicide round.")

-- setrole
function ulx.hg_setrole(ply, targets, role)
	for _, v in pairs(targets) do
		v.forceT = role == "traitor" or nil
		v.forceCT = role == "armed" or nil
		v.forceInnocent = role == "innocent" or nil
	end

	ulx.fancyLogAdmin(ply, true, "#A set next Homicide role of #T to #s", targets, role)
end

local setrole = ulx.command("Homigrad", "ulx setrole", ulx.hg_setrole, "!setrole")
setrole:addParam({
	type = ULib.cmds.PlayersArg
})
setrole:addParam({
	type = ULib.cmds.StringArg,
	completes = {"traitor", "armed", "innocent"},
	hint = "role",
	error = "Invalid role specified",
	ULib.cmds.restrictToCompletes
})
setrole:defaultAccess(ULib.ACCESS_ADMIN)
setrole:help("Sets the role of player(s) for the next Homicide round.")

-- arm
function ulx.hg_arm(ply)
	if not requirePlayer(ply) then return end

	local ent = ply:GetEyeTrace().Entity
	if not IsValid(ent) or not ent.Arm then return ULib.tsayError(ply, "You must look at an armable entity.", true) end

	ent:Arm()
	ent:Activate()

	ulx.fancyLogAdmin(ply, true, "#A armed #s", ent:GetClass())
end

local arm = ulx.command("Homigrad", "ulx arm", ulx.hg_arm, "!arm")
arm:defaultAccess(ULib.ACCESS_ADMIN)
arm:help("Arms the entity you are looking at.")

-- removebone
function ulx.hg_removebone(ply)
	if not requirePlayer(ply) then return end

	local trace = ply:GetEyeTrace()
	local ent = trace.Entity
	local physBone = trace.PhysicsBone

	if not IsValid(ent) or not ent:IsRagdoll() or not physBone or physBone == 0 then
		return ULib.tsayError(ply, "You must look at a ragdoll limb.", true)
	end

	Gib_RemoveBone(ent, ent:TranslatePhysBoneToBone(physBone), physBone)

	ulx.fancyLogAdmin(ply, true, "#A removed a bone from a ragdoll")
end

local removebone = ulx.command("Homigrad", "ulx removebone", ulx.hg_removebone, "!removebone")
removebone:defaultAccess(ULib.ACCESS_ADMIN)
removebone:help("Removes the ragdoll limb you are looking at.")

-- radio
function ulx.hg_radio(ply, destructible)
	if not requirePlayer(ply) then return end

	CreateRadio(ply:GetEyeTrace().HitPos + Vector(0, 0, 10), destructible)

	ulx.fancyLogAdmin(ply, true, "#A spawned a radio")
end

local radio = ulx.command("Homigrad", "ulx radio", ulx.hg_radio, "!radio")
radio:addParam({
	type = ULib.cmds.BoolArg,
	hint = "destructible",
	ULib.cmds.optional
})
radio:defaultAccess(ULib.ACCESS_ADMIN)
radio:help("Spawns a radio where you are looking.")

-- SUPERADMIN

-- spawnpoints
function ulx.hg_spawnpoints(ply)
	local lines = {}

	for id, info in SortedPairs(SpawnPointsList) do
		table.insert(lines, info[1] .. " (" .. id .. ")")
	end

	ULib.console(ply, table.concat(lines, "\n"))

	if IsValid(ply) then ULib.tsay(ply, "Printed all spawnpoints to your console.") end
end

local spawnpoints = ulx.command("Homigrad", "ulx spawnpoints", ulx.hg_spawnpoints, "!spawnpoints")
spawnpoints:defaultAccess(ULib.ACCESS_SUPERADMIN)
spawnpoints:help("Prints all spawnpoint names and ids to your console.")

-- point
local function findSpawnPoint(name)
	for id, info in pairs(SpawnPointsList) do
		if info[1] == name then return id end
	end
end

function ulx.hg_point(ply, name, radius)
	if not requirePlayer(ply) then return end

	local id = findSpawnPoint(name)
	if not id then return ULib.tsayError(ply, "No such point! See 'ulx spawnpoints'.", true) end

	local tbl = ReadDataMap(id)
	table.insert(tbl, {ply:GetPos() + Vector(0, 0, 5), Angle(0, ply:EyeAngles()[2], 0), radius > 0 and radius or nil})
	WriteDataMap(id, tbl)

	SetupSpawnPointsList()
	SendSpawnPoint()

	ulx.fancyLogAdmin(ply, "#A added a new point: #s", name)
end

local point = ulx.command("Homigrad", "ulx point", ulx.hg_point, "!point")
point:addParam({
	type = ULib.cmds.StringArg,
	autocomplete_fn = dynamicCompletes(spawnPointNames),
	hint = "point name"
})
point:addParam({
	type = ULib.cmds.NumArg,
	min = 0,
	default = 0,
	hint = "radius, 0 for default",
	ULib.cmds.optional
})
point:defaultAccess(ULib.ACCESS_SUPERADMIN)
point:help("Adds a spawnpoint at your position.")

-- pointreset
function ulx.hg_pointreset(ply, name)
	local id = findSpawnPoint(name)
	if not id then return ULib.tsayError(ply, "No such point! See 'ulx spawnpoints'.", true) end

	WriteDataMap(id)

	SetupSpawnPointsList()
	SendSpawnPoint()

	ulx.fancyLogAdmin(ply, "#A cleared points with name #s", name)
end

local pointreset = ulx.command("Homigrad", "ulx pointreset", ulx.hg_pointreset, "!pointreset")
pointreset:addParam({
	type = ULib.cmds.StringArg,
	autocomplete_fn = dynamicCompletes(spawnPointNames),
	hint = "point name"
})
pointreset:defaultAccess(ULib.ACCESS_SUPERADMIN)
pointreset:help("Removes all spawnpoints with a given name on the current page.")

-- fog
function ulx.hg_fog(ply, dist, r, g, b)
	if dist <= 0 then
		file.Delete("homigrad/fogs/" .. game.GetMap() .. ".txt")
		SetupFogSetting()

		ulx.fancyLogAdmin(ply, "#A reset fog settings")

		return
	end

	local color = r >= 0 and Color(r, g, b) or nil
	file.Write("homigrad/fogs/" .. game.GetMap() .. ".txt", util.TableToJSON({dist, color}))
	SetupFogSetting()

	ulx.fancyLogAdmin(ply, "#A set fog distance to #s", tostring(dist))
end

local fog = ulx.command("Homigrad", "ulx fog", ulx.hg_fog, "!fog")
fog:addParam({
	type = ULib.cmds.NumArg,
	min = 0,
	default = 0,
	hint = "distance, 0 to reset",
	ULib.cmds.optional
})
fog:addParam({
	type = ULib.cmds.NumArg,
	min = -1,
	max = 255,
	default = -1,
	hint = "r",
	ULib.cmds.optional,
	ULib.cmds.round
})
fog:addParam({
	type = ULib.cmds.NumArg,
	min = 0,
	max = 255,
	default = 0,
	hint = "g",
	ULib.cmds.optional,
	ULib.cmds.round
})
fog:addParam({
	type = ULib.cmds.NumArg,
	min = 0,
	max = 255,
	default = 0,
	hint = "b",
	ULib.cmds.optional,
	ULib.cmds.round
})
fog:defaultAccess(ULib.ACCESS_SUPERADMIN)
fog:help("Sets fog for the current map (saved to data).")

-- guilt
function ulx.hg_guilt(ply, targets, arg)
	for _, v in pairs(targets) do
		v.noguilt = not arg
	end

	if arg then ulx.fancyLogAdmin(ply, "#A enabled guilt system for #T", targets)
	else ulx.fancyLogAdmin(ply, "#A disabled guilt system for #T", targets) end
end

local guilt = ulx.command("Homigrad", "ulx guilt", ulx.hg_guilt, "!guilt")
guilt:addParam({
	type = ULib.cmds.PlayersArg
})
guilt:addParam({
	type = ULib.cmds.BoolArg,
	hint = "Enable or disable the guilt system"
})
guilt:defaultAccess(ULib.ACCESS_SUPERADMIN)
guilt:help("Toggles guilt gain for a given player(s).")

-- playermodel
local function resolveSteamID(ply, target)
	if string.match(target, "^STEAM_%d:%d:%d+$") then return target end

	local found, err = ULib.getUser(target, true, ply)
	if not found then return nil, err end

	return found:SteamID()
end

function ulx.hg_playermodel(ply, target, model)
	local steamID, err = resolveSteamID(ply, target)
	if not steamID then return ULib.tsayError(ply, err, true) end

	SetPlayerModelBySteamID(steamID, model)

	ulx.fancyLogAdmin(ply, true, "#A set custom player model of #s to #s", steamID, model)
end

local playermodel = ulx.command("Homigrad", "ulx playermodel", ulx.hg_playermodel, "!playermodel")
playermodel:addParam({
	type = ULib.cmds.StringArg,
	hint = "player name or SteamID"
})
playermodel:addParam({
	type = ULib.cmds.StringArg,
	hint = "model path"
})
playermodel:defaultAccess(ULib.ACCESS_SUPERADMIN)
playermodel:help("Assigns a custom player model to a player (applied on next spawn).")

-- removemodel
function ulx.hg_removemodel(ply, target)
	local steamID, err = resolveSteamID(ply, target)
	if not steamID then return ULib.tsayError(ply, err, true) end

	if not GetPlayerModelBySteamID(steamID) then
		return ULib.tsayError(ply, "No custom player model for " .. steamID, true)
	end

	SetPlayerModelBySteamID(steamID, nil)

	ulx.fancyLogAdmin(ply, true, "#A removed custom player model of #s", steamID)
end

local removemodel = ulx.command("Homigrad", "ulx removemodel", ulx.hg_removemodel, "!removemodel")
removemodel:addParam({
	type = ULib.cmds.StringArg,
	hint = "player name or SteamID"
})
removemodel:defaultAccess(ULib.ACCESS_SUPERADMIN)
removemodel:help("Removes a custom player model of a player.")

-- listmodels
function ulx.hg_listmodels(ply)
	local models = GetPlayerModels()

	if table.IsEmpty(models) then return ULib.tsay(ply, "No player models have been assigned.") end

	local lines = {"Assigned player models:"}

	for steamID, model in SortedPairs(models) do
		table.insert(lines, steamID .. ": " .. model)
	end

	ULib.console(ply, table.concat(lines, "\n"))

	if IsValid(ply) then ULib.tsay(ply, "Printed assigned player models to your console.") end
end

local listmodels = ulx.command("Homigrad", "ulx listmodels", ulx.hg_listmodels, "!listmodels")
listmodels:defaultAccess(ULib.ACCESS_SUPERADMIN)
listmodels:help("Prints all assigned custom player models to your console.")
