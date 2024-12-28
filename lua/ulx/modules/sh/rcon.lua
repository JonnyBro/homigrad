-- This module holds any type of remote execution functions (IE, 'dangerous')
local CATEGORY_NAME = "Серверная чать"

function ulx.rcon( calling_ply, command )
	ULib.consoleCommand( command .. "\n" )

	ulx.fancyLogAdmin( calling_ply, true, "#A выполнил команду через серверную консоль: #s", command )
end
local rcon = ulx.command( CATEGORY_NAME, "ulx rcon", ulx.rcon, "!rcon", true, false, true )
rcon:addParam{ type=ULib.cmds.StringArg, hint="command", ULib.cmds.takeRestOfLine }
rcon:defaultAccess( ULib.ACCESS_SUPERADMIN )
rcon:help( "Выполнение серверных команд на стороне сервера." )

function ulx.luaRun( calling_ply, command )
	local return_results = false
	if command:sub( 1, 1 ) == "=" then
		command = "tmp_var" .. command
		return_results = true
	end

	RunString( command )

	if return_results then
		if type( tmp_var ) == "table" then
			ULib.console( calling_ply, "Результат:" )
			local lines = ULib.explode( "\n", ulx.dumpTable( tmp_var ) )
			local chunk_size = 50
			for i=1, #lines, chunk_size do -- Break it up so we don't overflow the client
				ULib.queueFunctionCall( function()
					for j=i, math.min( i+chunk_size-1, #lines ) do
						ULib.console( calling_ply, lines[ j ]:gsub( "%%", "<p>" ) )
					end
				end )
			end
		else
			ULib.console( calling_ply, "Результат: " .. tostring( tmp_var ):gsub( "%%", "<p>" ) )
		end
	end

	ulx.fancyLogAdmin( calling_ply, true, "#A выполнил: #s", command )
end
local luarun = ulx.command( CATEGORY_NAME, "ulx luarun", ulx.luaRun, nil, false, false, true )
luarun:addParam{ type=ULib.cmds.StringArg, hint="command", ULib.cmds.takeRestOfLine }
luarun:defaultAccess( ULib.ACCESS_SUPERADMIN )
luarun:help( "Выполнение функций. ('=' для окончания)" )

function ulx.exec( calling_ply, config )
	if string.sub( config, -4 ) ~= ".cfg" then config = config .. ".cfg" end
	if not ULib.fileExists( "cfg/" .. config ) then
		ULib.tsayError( calling_ply, "Конфиг не найден!", true )
		return
	end

	ULib.execFile( "cfg/" .. config )
	ulx.fancyLogAdmin( calling_ply, "#A открыл #s", config )
end
local exec = ulx.command( CATEGORY_NAME, "ulx exec", ulx.exec, nil, false, false, true )
exec:addParam{ type=ULib.cmds.StringArg, hint="file" }
exec:defaultAccess( ULib.ACCESS_SUPERADMIN )
exec:help( "Открытие спец.конфигов с сервера." )

function ulx.cexec( calling_ply, target_plys, command )
	for _, v in ipairs( target_plys ) do
		v:ConCommand( command )
	end

	ulx.fancyLogAdmin( calling_ply, "#A выполнил #s у игрока #T", command, target_plys )
end
local cexec = ulx.command( CATEGORY_NAME, "ulx cexec", ulx.cexec, "!cexec", false, false, true )
cexec:addParam{ type=ULib.cmds.PlayersArg }
cexec:addParam{ type=ULib.cmds.StringArg, hint="команда", ULib.cmds.takeRestOfLine }
cexec:defaultAccess( ULib.ACCESS_SUPERADMIN )
cexec:help( "Выполнение консольных команд на стороне клиента (например retry)." )

function ulx.ent( calling_ply, classname, params )
	if not calling_ply:IsValid() then
		Msg( "Невозможно создать.\n" )
		return
	end

	classname = classname:lower()
	newEnt = ents.Create( classname )

	-- Make sure it's a valid ent
	if not newEnt or not newEnt:IsValid() then
		ULib.tsayError( calling_ply, "Неизвестный тип (" .. classname .. ").", true )
		return
	end

	local trace = calling_ply:GetEyeTrace()
	local vector = trace.HitPos
	vector.z = vector.z + 20

	newEnt:SetPos( vector ) -- Note that the position can be overridden by the user's flags

	params:gsub( "([^|:\"]+)\"?:\"?([^|]+)", function( key, value )
		key = key:Trim()
		value = value:Trim()
		newEnt:SetKeyValue( key, value )
	end )

	newEnt:Spawn()
	newEnt:Activate()

	undo.Create( "ulx_ent" )
		undo.AddEntity( newEnt )
		undo.SetPlayer( calling_ply )
	undo.Finish()

	if not params or params == "" then
		ulx.fancyLogAdmin( calling_ply, "#A создал объект #s", classname )
	else
		ulx.fancyLogAdmin( calling_ply, "#A создал объект #s с параметрами #s", classname, params )
	end
end
local ent = ulx.command( CATEGORY_NAME, "ulx ent", ulx.ent, nil, false, false, true )
ent:addParam{ type=ULib.cmds.StringArg, hint="classname" }
ent:addParam{ type=ULib.cmds.StringArg, hint="<flag> : <value> |", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
ent:defaultAccess( ULib.ACCESS_SUPERADMIN )
ent:help( "Создание объекта. ':', флаг:значение '|'." )
