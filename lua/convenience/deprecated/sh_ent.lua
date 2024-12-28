// DEPRECATED, DO NOT USE


local ENT = FindMetaTable("Entity")
local PLY = FindMetaTable("Player")

-- Call a method for this ent next tick
function ENT:CallNextTick( methodname, ... )

    local function func( me, ... )
        if IsValid(me) then
            me[methodname](me, ...)
        end
    end


    conv.callNextTick( func, self, ... )

end


-- Temporarily set a variable on an entity
function ENT:TempVar( name, value, duration )

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
function ENT:TempNetVar( funcName, value, duration )

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



-- DEPRECATED
-- A regular timer, but just for entities
-- Will stop if the ent is not valid
-- Id does not have to include entindex, that is done automatically
-- Returns timer name
function ENT:ConvTimer( id, delay, func, reps )

    local TimerName = id..self:EntIndex()


    timer.Create(TimerName, delay, reps or 1, function()

        if !IsValid(self) then
            timer.Remove(TimerName)
            return
        end

        func()

    end)


    return TimerName

end


-- Timer simple for entities with a built-in valid check
function ENT:Conv_STimer( delay, func, ... )
    local tbl = table.Pack(...)
    timer.Simple(delay, function()
        if IsValid(self) then
            func(unpack(tbl))
        end
    end)
end


-- Check if an entity has the supplied flags
function ENT:Conv_HasFlags( flags )
    if !IsValid(self) then return false end
    return bit.band(self:GetFlags(), flags)==flags
end


-- Check if the player can see this position
function PLY:PosInView( pos )

    local eyePos = self:GetShootPos()
    local eyeAngles = self:EyeAngles()
    local direction = (pos - eyePos):GetNormalized() -- Get the direction from player's eye to the position
    local angleDifference = math.deg(math.acos(eyeAngles:Forward():Dot(direction))) -- Calculate angle difference

    local tr = util.TraceLine({
        start = eyePos,
        endpos = pos,
        mask = MASK_VISIBLE,
    })


    return angleDifference <= self:GetFOV() && !tr.Hit

end