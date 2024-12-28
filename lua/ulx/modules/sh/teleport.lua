CATEGORY_NAME = "Перемещение"

local function spiralGrid(rings)
	local grid = {}
	local col, row

	for ring=1, rings do -- For each ring...
		row = ring
		for col=1-ring, ring do -- Walk right across top row
			table.insert( grid, {col, row} )
		end

		col = ring
		for row=ring-1, -ring, -1 do -- Walk down right-most column
			table.insert( grid, {col, row} )
		end

		row = -ring
		for col=ring-1, -ring, -1 do -- Walk left across bottom row
			table.insert( grid, {col, row} )
		end

		col = -ring
		for row=1-ring, ring do -- Walk up left-most column
			table.insert( grid, {col, row} )
		end
	end

	return grid
end
local tpGrid = spiralGrid( 24 )

-- Utility function for bring, goto, and send
local function playerSend( from, to, force )
	if not to:IsInWorld() and not force then return false end -- No way we can do this one

	local yawForward = to:EyeAngles().yaw
	local directions = { -- Directions to try
		math.NormalizeAngle( yawForward - 180 ), -- Behind first
		math.NormalizeAngle( yawForward + 90 ), -- Right
		math.NormalizeAngle( yawForward - 90 ), -- Left
		yawForward,
	}

	local t = {}
	t.start = to:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
	t.filter = { to, from }

	local i = 1
	t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47 -- (33 is player width, this is sqrt( 33^2 * 2 ))
	local tr = util.TraceEntity( t, from )
	while tr.Hit do -- While it's hitting something, check other angles
		i = i + 1
		if i > #directions then	 -- No place found
			if force then
				from.ulx_prevpos = from:GetPos()
				from.ulx_prevang = from:EyeAngles()
				return to:GetPos() + Angle( 0, directions[ 1 ], 0 ):Forward() * 47
			else
				return false
			end
		end

		t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47

		tr = util.TraceEntity( t, from )
	end

	from.ulx_prevpos = from:GetPos()
	from.ulx_prevang = from:EyeAngles()
	return tr.HitPos
end

-- Based on code donated by Timmy (https://github.com/Toxsa)
function ulx.bring( calling_ply, target_plys )
	local cell_size = 50 -- Constance spacing value

  if not calling_ply:IsValid() then
    Msg( "Если вы принесли кого-то к нам, они мгновенно были бы уничтожены удивительной консолью.\n" )
    return
  end

  if ulx.getExclusive( calling_ply, calling_ply ) then
    ULib.tsayError( calling_ply, ulx.getExclusive( calling_ply, calling_ply ), true )
    return
  end

  if not calling_ply:Alive() then
    ULib.tsayError( calling_ply, "Ты мертв!", true )
    return
  end

  if calling_ply:InVehicle() then
    ULib.tsayError( calling_ply, "Выйди из транспорта!", true )
    return
  end

	local t = {
		start = calling_ply:GetPos(),
		filter = { calling_ply },
		endpos = calling_ply:GetPos(),
	}
	local tr = util.TraceEntity( t, calling_ply )

  if tr.Hit then
    ULib.tsayError( calling_ply, "Невозможно!", true )
    return
  end

  local teleportable_plys = {}

  for i=1, #target_plys do
    local v = target_plys[ i ]
    if ulx.getExclusive( v, calling_ply ) then
      ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
    elseif not v:Alive() then
      ULib.tsayError( calling_ply, v:Nick() .. " мертв!", true )
    else
      table.insert( teleportable_plys, v )
    end
  end
	local players_involved = table.Copy( teleportable_plys )
	table.insert( players_involved, calling_ply )

  local affected_plys = {}

  for i=1, #tpGrid do
		local c = tpGrid[i][1]
		local r = tpGrid[i][2]
    local target = table.remove( teleportable_plys )
		if not target then break end

		local yawForward = calling_ply:EyeAngles().yaw
		local offset = Vector( r * cell_size, c * cell_size, 0 )
		offset:Rotate( Angle( 0, yawForward, 0 ) )

		local t = {}
		t.start = calling_ply:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
		t.filter = players_involved
		t.endpos = t.start + offset
		local tr = util.TraceEntity( t, target )

    if tr.Hit then
      table.insert( teleportable_plys, target )
    else
      if target:InVehicle() then target:ExitVehicle() end
			target.ulx_prevpos = target:GetPos()
			target.ulx_prevang = target:EyeAngles()
      target:SetPos( t.endpos )
      target:SetEyeAngles( (calling_ply:GetPos() - t.endpos):Angle() )
      target:SetLocalVelocity( Vector( 0, 0, 0 ) )
      table.insert( affected_plys, target )
    end
  end

  if #teleportable_plys > 0 then
    ULib.tsayError( calling_ply, "Недостаточно места!", true )
  end

	if #affected_plys > 0 then
  	ulx.fancyLogAdmin( calling_ply, "#A привел к #T", affected_plys )
	end
end
local bring = ulx.command( CATEGORY_NAME, "ulx bring", ulx.bring, "!bring" )
bring:addParam{ type=ULib.cmds.PlayersArg, target="!^" }
bring:defaultAccess( ULib.ACCESS_ADMIN )
bring:help( "Перемещает цель к вам." )

function ulx.goto( calling_ply, target_ply )
	if not calling_ply:IsValid() then
		Msg( "Вы не можете уйти в мир смертных с консоли.\n" )
		return
	end

	if ulx.getExclusive( calling_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( calling_ply, calling_ply ), true )
		return
	end

	if not target_ply:Alive() then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " мертв!", true )
		return
	end

	if not calling_ply:Alive() then
		ULib.tsayError( calling_ply, "Ты мертв!", true )
		return
	end

	if target_ply:InVehicle() and calling_ply:GetMoveType() ~= MOVETYPE_NOCLIP then
		ULib.tsayError( calling_ply, "Цель в транспорте! Используй Режим полета.", true )
		return
	end

	local newpos = playerSend( calling_ply, target_ply, calling_ply:GetMoveType() == MOVETYPE_NOCLIP )
	if not newpos then
		ULib.tsayError( calling_ply, "Невозможно. Найди другое место или используй Режим полета.", true )
		return
	end

	if calling_ply:InVehicle() then
		calling_ply:ExitVehicle()
	end

	local newang = (target_ply:GetPos() - newpos):Angle()

	calling_ply:SetPos( newpos )
	calling_ply:SetEyeAngles( newang )
	calling_ply:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!

	ulx.fancyLogAdmin( calling_ply, "#A переместился к #T", target_ply )
end
local goto = ulx.command( CATEGORY_NAME, "ulx goto", ulx.goto, "!goto" )
goto:addParam{ type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget }
goto:defaultAccess( ULib.ACCESS_ADMIN )
goto:help( "Переместится к игроку." )

function ulx.send( calling_ply, target_from, target_to )
	if target_from == target_to then
		ULib.tsayError( calling_ply, "Вы указали одну и ту же цель дважды! Используйте две разные цели.", true )
		return
	end

	if ulx.getExclusive( target_from, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_from, calling_ply ), true )
		return
	end

	if ulx.getExclusive( target_to, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_to, calling_ply ), true )
		return
	end

	local nick = target_from:Nick() -- Going to use this for our error (if we have one)

	if not target_from:Alive() or not target_to:Alive() then
		if not target_to:Alive() then
			nick = target_to:Nick()
		end
		ULib.tsayError( calling_ply, nick .. " мертв!", true )
		return
	end

	if target_to:InVehicle() and target_from:GetMoveType() ~= MOVETYPE_NOCLIP then
		ULib.tsayError( calling_ply, "Цель в транспорте!", true )
		return
	end

	local newpos = playerSend( target_from, target_to, target_from:GetMoveType() == MOVETYPE_NOCLIP )
	if not newpos then
		ULib.tsayError( calling_ply, "Невозможно!", true )
		return
	end

	if target_from:InVehicle() then
		target_from:ExitVehicle()
	end

	local newang = (target_from:GetPos() - newpos):Angle()

	target_from:SetPos( newpos )
	target_from:SetEyeAngles( newang )
	target_from:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!

	ulx.fancyLogAdmin( calling_ply, "#A переместил #T к игроку #T", target_from, target_to )
end
local send = ulx.command( CATEGORY_NAME, "ulx send", ulx.send, "!send" )
send:addParam{ type=ULib.cmds.PlayerArg, target="!^" }
send:addParam{ type=ULib.cmds.PlayerArg, target="!^" }
send:defaultAccess( ULib.ACCESS_ADMIN )
send:help( "Переместить одного к другому." )

function ulx.teleport( calling_ply, target_ply )
	if not calling_ply:IsValid() then
		Msg( "Ты консоль, извини!\n" )
		return
	end

	if ulx.getExclusive( target_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		return
	end

	if not target_ply:Alive() then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " мертв!", true )
		return
	end

	local t = {}
	t.start = calling_ply:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
	t.endpos = calling_ply:GetPos() + calling_ply:EyeAngles():Forward() * 16384
	t.filter = target_ply
	if target_ply ~= calling_ply then
		t.filter = { target_ply, calling_ply }
	end
	local tr = util.TraceEntity( t, target_ply )

	local pos = tr.HitPos

	if target_ply == calling_ply and pos:Distance( target_ply:GetPos() ) < 64 then -- Laughable distance
		return
	end

	target_ply.ulx_prevpos = target_ply:GetPos()
	target_ply.ulx_prevang = target_ply:EyeAngles()

	if target_ply:InVehicle() then
		target_ply:ExitVehicle()
	end

	target_ply:SetPos( pos )
	target_ply:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!

	if target_ply ~= calling_ply then
		ulx.fancyLogAdmin( calling_ply, "#A переместил #T", target_ply ) -- We don't want to log otherwise
	end
end
local teleport = ulx.command( CATEGORY_NAME, "ulx teleport", ulx.teleport, {"!tp", "!teleport"} )
teleport:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
teleport:defaultAccess( ULib.ACCESS_ADMIN )
teleport:help( "Перемещение цели туда куда ты смотришь." )

function ulx.retrn( calling_ply, target_ply )
	if not target_ply:IsValid() then
		Msg( "Консоль, ты надоела.\n" )
		return
	end

	if not target_ply.ulx_prevpos then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " нет точки возврата.", true )
		return
	end

	if ulx.getExclusive( target_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		return
	end

	if not target_ply:Alive() then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " мертв!", true )
		return
	end

	if target_ply:InVehicle() then
		target_ply:ExitVehicle()
	end

	target_ply:SetPos( target_ply.ulx_prevpos )
	target_ply:SetEyeAngles( target_ply.ulx_prevang )
	target_ply.ulx_prevpos = nil
	target_ply.ulx_prevang = nil
	target_ply:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!

	ulx.fancyLogAdmin( calling_ply, "#A вернул #T на место до перемещения", target_ply )
end
local retrn = ulx.command( CATEGORY_NAME, "ulx return", ulx.retrn, "!return" )
retrn:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
retrn:defaultAccess( ULib.ACCESS_ADMIN )
retrn:help( "Возврат игрока на место откуда он был телепортирован." )
