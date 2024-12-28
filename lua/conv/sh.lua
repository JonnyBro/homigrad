local Developer = GetConVar("developer")
local ENT = FindMetaTable("Entity")


--[[
==================================================================================================
                    TIMER / TICK STUFF
==================================================================================================
--]]


-- Do something next tick/frame
function conv.callNextTick( func, ... )

    local argtbl = table.Pack(...)

    timer.Simple(0, function()
        func(unpack(argtbl))
    end)

end


-- Do something after a certain amount of ticks/frames
function conv.callAfterTicks( ticknum, func, ... )

    conv.callNextTick( function( ... )

        if ticknum <= 0 then
            func(...)
        else
            conv.callAfterTicks( ticknum-1, func, ... )
        end
        

    end, ... )

end



--[[
==================================================================================================
                    WRAPPER FUNCTIONS
==================================================================================================
--]]



-- Create a wrapper function around the desired function
-- 'preFunc' - Function to run before running the target function, passes the same arguments
-- 'postFunc' - Code to run AFTER running the function, passes a table of return values followed by the function arguments,
--  you can override the return values by returning something else in this function
function conv.wrapFunc( uniqueID, func, preFunc, postFunc )
    if !isfunction(func) then
        error("The function does not exist!")
    end


    -- Store original func
    conv.wrapFunc_OriginalFuncs = conv.wrapFunc_OriginalFuncs or {}
    if !conv.wrapFunc_OriginalFuncs[uniqueID] then
        conv.wrapFunc_OriginalFuncs[uniqueID] = func
    end


    local wrappedFunc = function(...)
        if isfunction(preFunc) then
            preFunc( ... )
        end

        local returnValues = table.Pack( conv.wrapFunc_OriginalFuncs[uniqueID](...) )


        if isfunction(postFunc) then
            local returnValues = table.Pack( postFunc( returnValues, ... ) )

            if !table.IsEmpty(returnValues) then
                return unpack(returnValues)
            end
        end


        return unpack(returnValues)
    end

    return wrappedFunc
end


-- Same as above, but the original function is lost
function conv.wrapFunc2( func, preFunc, postFunc )
    if !isfunction(func) then
        error("The function does not exist!")
    end

    local wrappedFunc = function(...)
        if isfunction(preFunc) then
            preFunc( ... )
        end

        local returnValues = table.Pack( func(...) )


        if isfunction(postFunc) then
            local returnValues = table.Pack( postFunc( returnValues, ... ) )

            if !table.IsEmpty(returnValues) then
                return unpack(returnValues)
            end
        end


        return unpack(returnValues)
    end

    return wrappedFunc
end


--[[
==================================================================================================
                    FILES / INCLUDE
==================================================================================================
--]]


function conv.addFile( File, directory )
	local prefix = string.lower( string.Left( File, 3 ) )
    local isServerFile = (prefix == "sv_" or File=="sv.lua")
    local isClientFile = (prefix == "cl_" or File=="cl.lua")
    local isSharedFile = !isClientFile && !isServerFile

	if isServerFile && SERVER then

		include( directory .. File )
        return
    
    end


    if isClientFile then
		if SERVER then
			AddCSLuaFile( directory .. File )
		elseif CLIENT then
			include( directory .. File )
		end

        return
    end


	if isSharedFile then
		AddCSLuaFile( directory .. File )
		include( directory .. File )
	end
end


function conv.includeDir( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			conv.addFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		conv.includeDir( directory .. v )
	end
end

--[[
==================================================================================================
                    DEBUG
==================================================================================================
--]]


-- Debug Overlay QOL
-- https://wiki.facepunch.com/gmod/debugoverlay
-- conv.overlay("Something", function()
--     return {}
-- end)
function conv.overlay( funcname, argsFunc )
    if !Developer:GetBool() then return end
    local args = argsFunc()
    debugoverlay[funcname](unpack(args))
end


--[[
==================================================================================================
                    PLAYER VISIBILITY
==================================================================================================
--]]


-- Checks if any player on the server can see this position right now
function conv.playersSeePos( pos )
    for _, ply in player.Iterator() do
        if conv.plyCanSeePos( ply, pos ) then
            return true
        end
    end
end



-- Checks if a player on the server can see this position right now
function conv.plyCanSeePos( ply, pos )
    local eyePos = ply:GetShootPos()
    local eyeAngles = ply:EyeAngles()
    local direction = (pos - eyePos):GetNormalized() -- Get the direction from player's eye to the position
    local angleDifference = math.deg(math.acos(eyeAngles:Forward():Dot(direction))) -- Calculate angle difference

    local tr = util.TraceLine({
        start = eyePos,
        endpos = pos,
        mask = MASK_VISIBLE,
    })

    return angleDifference <= ply:GetFOV() && !tr.Hit
end


--[[
==================================================================================================
                    NPC SPAWNING
==================================================================================================
--]]


function conv.getSpawnMenuNPCs()
    return conv._SpawnMenuNPCs
end


--[[
==================================================================================================
                    ENTITY TIMER / TICK FUNCTIONS
==================================================================================================
--]]



-- Call a method for this ent next tick
function ENT:CONV_CallNextTick( methodname, ... )

    local function func( me, ... )
        if IsValid(me) then
            me[methodname](me, ...)
        end
    end


    conv.callNextTick( func, self, ... )

end


-- Temporarily set a variable on an entity
function ENT:CONV_TempVar( name, value, duration )

    self[name.."ValBefore"] = self[name.."ValBefore"] or self[name]
    self[name] = value


    timer.Create("TempVar"..name..self:EntIndex(), duration, 1, function()
        if IsValid(self) then
            self[name] = ValBefore
            self[name.."ValBefore"] = nil
        end
    end)

end


-- Temporarily sets variables created by ENT:NetworkVar()
function ENT:CONV_TempNetVar( funcName, value, duration )

    local setFuncName = "Set"..funcName
    local getFuncName = "Get"..funcName

    if !self[setFuncName.."NetValBefore"] then
        self[setFuncName](name, value)
    end

    self[setFuncName.."NetValBefore"] = self[setFuncName.."NetValBefore"] or self[getFuncName]()

    timer.Create("TempNetVar"..setFuncName..self:EntIndex(), duration, 1, function()
        if IsValid(self) then
            self[setFuncName](value)
            self[setFuncName.."NetValBefore"] = nil
        end
    end)

end


-- Like timer.Simple but with a built in valid check
function ENT:CONV_TimerSimple(dur, func)

    timer.Simple(dur, function()
        if IsValid(self) then
            func()
        end
    end)
end


-- Like timer.Create but with a built in valid check
-- Also automatically concatinates the name with the entity's entity index
function ENT:CONV_TimerCreate(name, dur, reps, func)
    local timerName = name..self:EntIndex()

    timer.Create(timerName, dur, reps, function()
        if !IsValid(self) then
            timer.Remove(timerName)
            return
        end

        func()
    end)
end


--[[
==================================================================================================
                    ENTITY UTILITIES
==================================================================================================
--]]


-- Stores the entity in a table, and removes it from said table when the entity is no longer valid
function ENT:CONV_StoreInTable( tbl )
    if !istable(tbl) then return end

    table.insert(tbl, self)

    self:CallOnRemove("RemoveFrom"..tostring(tbl), function()
        if istable(tbl) then
            table.RemoveByValue(tbl, self)
        end
    end)
end