local CATEGORY_NAME = "Голосования"

---------------
--Public vote--
---------------
if SERVER then ulx.convar( "voteEcho", "0", _, ULib.ACCESS_SUPERADMIN ) end -- Echo votes?

-- First, our helper function to make voting so much easier!
function ulx.doVote( title, options, callback, timeout, filter, noecho, ... )
	timeout = timeout or 20
	if ulx.voteInProgress then
		Msg( "Ошибка! ULX попытался начать голосование, когда проводилось другое голосование!\n" )
		return false
	end

	if not options[ 1 ] or not options[ 2 ] then
		Msg( "Ошибка! ULX попытался начать голосование, не имея по крайней мере двух вариантов!\n" )
		return false
	end

	local voters = 0
	local rp = RecipientFilter()
	if not filter then
		rp:AddAllPlayers()
		voters = #player.GetAll()
	else
		for _, ply in ipairs( filter ) do
			rp:AddPlayer( ply )
			voters = voters + 1
		end
	end

	umsg.Start( "ulx_vote", rp )
		umsg.String( title )
		umsg.Short( timeout )
		ULib.umsgSend( options )
	umsg.End()

	ulx.voteInProgress = { callback=callback, options=options, title=title, results={}, voters=voters, votes=0, noecho=noecho, args={...} }

	timer.Create( "ULXVoteTimeout", timeout, 1, ulx.voteDone )

	return true
end

function ulx.voteCallback( ply, command, argv )
	if not ulx.voteInProgress then
		ULib.tsayError( ply, "Не проводится голосование" )
		return
	end

	if not argv[ 1 ] or not tonumber( argv[ 1 ] ) or not ulx.voteInProgress.options[ tonumber( argv[ 1 ] ) ] then
		ULib.tsayError( ply, "недопустимое значение." )
		return
	end

	if ply.ulxVoted then
		ULib.tsayError( ply, "Ты уже проголосовал!" )
		return
	end

	local echo = ULib.toBool( GetConVarNumber( "ulx_voteEcho" ) )
	local id = tonumber( argv[ 1 ] )
	ulx.voteInProgress.results[ id ] = ulx.voteInProgress.results[ id ] or 0
	ulx.voteInProgress.results[ id ] = ulx.voteInProgress.results[ id ] + 1

	ulx.voteInProgress.votes = ulx.voteInProgress.votes + 1

	ply.ulxVoted = true -- Tag them as having voted

	local str = ply:Nick() .. " голосует за " .. ulx.voteInProgress.options[ id ]
	if echo and not ulx.voteInProgress.noecho then
		ULib.tsay( _, str ) -- TODO, color?
	end
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end

	if ulx.voteInProgress.votes >= ulx.voteInProgress.voters then
		ulx.voteDone()
	end
end
if SERVER then concommand.Add( "ulx_vote", ulx.voteCallback ) end

function ulx.voteDone( cancelled )
	local players = player.GetAll()
	for _, ply in ipairs( players ) do -- Clear voting tags
		ply.ulxVoted = nil
	end

	local vip = ulx.voteInProgress
	ulx.voteInProgress = nil
	timer.Remove( "ULXVoteTimeout" )
	if not cancelled then
		ULib.pcallError( vip.callback, vip, unpack( vip.args, 1, 10 ) ) -- Unpack is explicit in length to avoid odd LuaJIT quirk.
	end
end
-- End our helper functions





local function voteDone( t )
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local str
	if not winner then
		str = "Результат: Ничего!"
	else
		str = "Результат: '" .. t.options[ winner ] .. "' . (" .. winnernum .. "/" .. t.voters .. ")"
	end
	ULib.tsay( _, str ) -- TODO, color?
	ulx.logString( str )
	Msg( str .. "\n" )
end

function ulx.vote( calling_ply, title, ... )
	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, "Уже проводится голосование. Пожалуйста, дождитесь окончания.", true )
		return
	end

	ulx.doVote( title, { ... }, voteDone )
	ulx.fancyLogAdmin( calling_ply, "#A запустил голосование (#s)", title )
end
local vote = ulx.command( CATEGORY_NAME, "ulx vote", ulx.vote, "!vote" )
vote:addParam{ type=ULib.cmds.StringArg, hint="title" }
vote:addParam{ type=ULib.cmds.StringArg, hint="options", ULib.cmds.takeRestOfLine, repeat_min=2, repeat_max=10 }
vote:defaultAccess( ULib.ACCESS_ADMIN )
vote:help( "Starts a public vote." )

-- Stop a vote in progress
function ulx.stopVote( calling_ply )
	if not ulx.voteInProgress then
		ULib.tsayError( calling_ply, "В данный момент голосования нет.", true )
		return
	end

	ulx.voteDone( true )
	ulx.fancyLogAdmin( calling_ply, "#A отменил голосование." )
end
local stopvote = ulx.command( CATEGORY_NAME, "ulx stopvote", ulx.stopVote, "!stopvote" )
stopvote:defaultAccess( ULib.ACCESS_SUPERADMIN )
stopvote:help( "Останавливает голосование." )

local function voteMapDone2( t, changeTo, ply )
	local shouldChange = false

	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.logServAct( ply, "#A голосует ЗА" )
		shouldChange = true
	else
		ulx.logServAct( ply, "#A голосует ПРОТИВ" )
	end

	if shouldChange then
		ULib.consoleCommand( "changelevel " .. changeTo .. "\n" )
	end
end

local function voteMapDone( t, argv, ply )
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local ratioNeeded = GetConVarNumber( "ulx_votemap2Successratio" )
	local minVotes = GetConVarNumber( "ulx_votemap2Minvotes" )
	local str
	local changeTo
	-- Figure out the map to change to, if we're changing
	if #argv > 1 then
		changeTo = t.options[ winner ]
	else
		changeTo = argv[ 1 ]
	end

	if (#argv < 2 and winner ~= 1) or not winner or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "Результат: голосование не состоялось."
	elseif ply:IsValid() then
		str = "Результат: Вариант '" .. t.options[ winner ] .. "' победил, Ожидается подтверждение. (" .. winnernum .. "/" .. t.voters .. ")"

		ulx.doVote( "Принять результат? " .. changeTo .. "?", { "Да", "Нет" }, voteMapDone2, 30000, { ply }, true, changeTo, ply )
	else -- It's the server console, let's roll with it
		str = "Результат: Вариант '" .. t.options[ winner ] .. "' победил. (" .. winnernum .. "/" .. t.voters .. ")"
		ULib.tsay( _, str )
		ulx.logString( str )
		ULib.consoleCommand( "changelevel " .. changeTo .. "\n" )
		return
	end

	ULib.tsay( _, str ) -- TODO, color?
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end
end

function ulx.votemap2( calling_ply, ... )
	local argv = { ... }

	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, "Уже проводится голосование. Пожалуйста, дождитесь окончания.", true )
		return
	end

	for i=2, #argv do
	    if ULib.findInTable( argv, argv[ i ], 1, i-1 ) then
	        ULib.tsayError( calling_ply, "Карта " .. argv[ i ] .. " была указана дважды. Пожалуйста, попробуйте еще раз" )
	        return
	    end
	end

	if #argv > 1 then
		ulx.doVote( "Смена карты..", argv, voteMapDone, _, _, _, argv, calling_ply )
		ulx.fancyLogAdmin( calling_ply, "#A начал голосование за карты " .. string.rep( " #s", #argv ), ... )
	else
		ulx.doVote( "Принять результат " .. argv[ 1 ] .. "?", { "Да", "Нет" }, voteMapDone, _, _, _, argv, calling_ply )
		ulx.fancyLogAdmin( calling_ply, "#A начал голосование за #s", argv[ 1 ] )
	end
end
local votemap2 = ulx.command( CATEGORY_NAME, "ulx votemap2", ulx.votemap2, "!votemap2" )
votemap2:addParam{ type=ULib.cmds.StringArg, completes=ulx.maps, hint="map", error="invalid map \"%s\" specified", ULib.cmds.restrictToCompletes, ULib.cmds.takeRestOfLine, repeat_min=1, repeat_max=10 }
votemap2:defaultAccess( ULib.ACCESS_ADMIN )
votemap2:help( "Начинает публичное голосование за карту." )
if SERVER then ulx.convar( "votemap2Successratio", "0.5", _, ULib.ACCESS_ADMIN ) end -- The ratio needed for a votemap2 to succeed
if SERVER then ulx.convar( "votemap2Minvotes", "3", _, ULib.ACCESS_ADMIN ) end -- Minimum votes needed for votemap2



local function voteKickDone2( t, target, time, ply, reason )
	local shouldKick = false

	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.logUserAct( ply, target, "#A принял голосование за кик #T (" .. (reason or "") .. ")" )
		shouldKick = true
	else
		ulx.logUserAct( ply, target, "#A отверг голосование за кик #T" )
	end

	if shouldKick then
		if reason and reason ~= "" then
			ULib.kick( target, "Голосование успешно. (" .. reason .. ")" )
		else
			ULib.kick( target, "Голосование успешно." )
		end
	end
end

local function voteKickDone( t, target, time, ply, reason )
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local ratioNeeded = GetConVarNumber( "ulx_votekickSuccessratio" )
	local minVotes = GetConVarNumber( "ulx_votekickMinvotes" )
	local str
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "Результат: Провал голосования (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
	else
		if not target:IsValid() then
			str = "Результат: Успешно, но игрок уже вышел сам."
		elseif ply:IsValid() then
			str = "Результат: Увы, ничего не вышло. (" .. winnernum .. "/" .. t.voters .. ")"
			ulx.doVote( "Принять результат " .. target:Nick() .. "?", { "Да", "Нет" }, voteKickDone2, 30000, { ply }, true, target, time, ply, reason )
		else -- Vote from server console, roll with it
			str = "Результат: Игрок будет кикнут. (" .. winnernum .. "/" .. t.voters .. ")"
			ULib.kick( target, "Голосование состоялось." )
		end
	end

	ULib.tsay( _, str ) -- TODO, color?
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end
end

function ulx.votekick( calling_ply, target_ply, reason )
	if target_ply:IsListenServerHost() then
		ULib.tsayError( calling_ply, "Пользователь имеет иммунитет", true )
		return
	end

	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, "Голосование уже запущено.", true )
		return
	end

	local msg = "Выгнать " .. target_ply:Nick() .. "?"
	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end

	ulx.doVote( msg, { "Да", "Нет" }, voteKickDone, _, _, _, target_ply, time, calling_ply, reason )
	if reason and reason ~= "" then
		ulx.fancyLogAdmin( calling_ply, "#A начал голосование за кик #T (#s)", target_ply, reason )
	else
		ulx.fancyLogAdmin( calling_ply, "#A начал голосование за кик #T", target_ply )
	end
end
local votekick = ulx.command( CATEGORY_NAME, "ulx votekick", ulx.votekick, "!votekick" )
votekick:addParam{ type=ULib.cmds.PlayerArg }
votekick:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
votekick:defaultAccess( ULib.ACCESS_ADMIN )
votekick:help( "Начать публичное голосование." )
if SERVER then ulx.convar( "votekickSuccessratio", "0.6", _, ULib.ACCESS_ADMIN ) end -- The ratio needed for a votekick to succeed
if SERVER then ulx.convar( "votekickMinvotes", "2", _, ULib.ACCESS_ADMIN ) end -- Minimum votes needed for votekick



local function voteBanDone2( t, nick, steamid, time, ply, reason )
	local shouldBan = false

	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.fancyLogAdmin( ply, "#A принял решение за бан игрока на #s (#s minutes) (#s))", nick, time, reason or "" )
		shouldBan = true
	else
		ulx.fancyLogAdmin( ply, "#A отменил бан #s", nick )
	end

	if shouldBan then
		ULib.addBan( steamid, time, reason, nick, ply )
	end
end

local function voteBanDone( t, nick, steamid, time, ply, reason )
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local ratioNeeded = GetConVarNumber( "ulx_votebanSuccessratio" )
	local minVotes = GetConVarNumber( "ulx_votebanMinvotes" )
	local str
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "Результат: Игрок не забанен. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
	else
		reason = ("[BAN] " .. (reason or "")):Trim()
		if ply:IsValid() then
			str = "Результаты голосования: теперь пользователь будет заблокирован. В ожидании одобрения. (" .. winnernum .. "/" .. t.voters .. ")"
			ulx.doVote( "Принять результат " .. nick .. "?", { "Да", "Нет" }, voteBanDone2, 30000, { ply }, true, nick, steamid, time, ply, reason )
		else -- Vote from server console, roll with it
			str = "Результаты голосования: теперь пользователь будет заблокирован. (" .. winnernum .. "/" .. t.voters .. ")"
			ULib.addBan( steamid, time, reason, nick, ply )
		end
	end

	ULib.tsay( _, str ) -- TODO, color?
	ulx.logString( str )
	Msg( str .. "\n" )
end

function ulx.voteban( calling_ply, target_ply, minutes, reason )
	if target_ply:IsListenServerHost() or target_ply:IsBot() then
		ULib.tsayError( calling_ply, "Игрок имеет иммунитет", true )
		return
	end

	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, "Голосование уже запущено.", true )
		return
	end

	local msg = "Забанить " .. target_ply:Nick() .. " на " .. minutes .. " минут(ы)?"
	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end

	ulx.doVote( msg, { "Да", "Нет" }, voteBanDone, _, _, _, target_ply:Nick(), target_ply:SteamID(), minutes, calling_ply, reason )
	if reason and reason ~= "" then
		ulx.fancyLogAdmin( calling_ply, "#A начал голосование за бан на #i минут(ы) игроку #T (#s)", minutes, target_ply, reason )
	else
		ulx.fancyLogAdmin( calling_ply, "#A начал голосование за бан на #i минут(ы) игроку #T", minutes, target_ply )
	end
end
local voteban = ulx.command( CATEGORY_NAME, "ulx voteban", ulx.voteban, "!voteban" )
voteban:addParam{ type=ULib.cmds.PlayerArg }
voteban:addParam{ type=ULib.cmds.NumArg, min=0, default=1440, hint="minutes", ULib.cmds.allowTimeString, ULib.cmds.optional }
voteban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
voteban:defaultAccess( ULib.ACCESS_ADMIN )
voteban:help( "Начать публичное голосование." )
if SERVER then ulx.convar( "votebanSuccessratio", "0.7", _, ULib.ACCESS_ADMIN ) end -- The ratio needed for a voteban to succeed
if SERVER then ulx.convar( "votebanMinvotes", "3", _, ULib.ACCESS_ADMIN ) end -- Minimum votes needed for voteban

-- Our regular votemap command
local votemap = ulx.command( CATEGORY_NAME, "ulx votemap", ulx.votemap, "!votemap" )
votemap:addParam{ type=ULib.cmds.StringArg, completes=ulx.votemaps, hint="map", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
votemap:defaultAccess( ULib.ACCESS_ALL )
votemap:help( "Голосовать за карту, без списка доступных карт." )

-- Our veto command
local veto = ulx.command( CATEGORY_NAME, "ulx veto", ulx.votemapVeto, "!veto" )
veto:defaultAccess( ULib.ACCESS_ADMIN )
veto:help( "Принять карту на голосование." )
