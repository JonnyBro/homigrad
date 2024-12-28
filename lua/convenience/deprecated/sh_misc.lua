// DEPRECATED, DO NOT USE


local Developer = GetConVar("developer")
local MaxAmmoCvar = GetConVar("gmod_maxammo")


--[[
==================================================================================================
                    TABLE
==================================================================================================
--]]


-- Insert an entity into a table, which is later removed once it is no longer valid
function table.InsertEntity( tbl, ent )

    if !IsValid(ent) then return end -- Must be ent

    table.insert(tbl, ent)


    ent:CallOnRemove("RemoveFrom_"..tostring(tbl), function()

        table.RemoveByValue(tbl, ent)
        
    end)

end


--[[
==================================================================================================
                    DEBUG
==================================================================================================
--]]



-- debug.Trace but you can choose which level to start from
function debug.ConvTraceFrom(level)
	while true do

		local info = debug.getinfo( level, "Sln" )
		if ( !info ) then break end

		if ( info.what ) == "C" then
			MsgN( string.format( "\t%i: C function\t\"%s\"", level, info.name ) )
		else
			MsgN( string.format( "\t%i: Line %d\t\"%s\"\t\t%s", level, info.currentline, info.name, info.short_src ) )
		end

		level = level + 1

	end
end


--[[
==================================================================================================
                    GAME
==================================================================================================
--]]

-- Just like https://wiki.facepunch.com/gmod/game.GetAmmoMax
-- But it respects the gmod_maxammo cvar
function game.GetCurrentAmmoMax(id)
    local cvarMax = MaxAmmoCvar:GetInt()


    if cvarMax <= 0 then
        return game.GetAmmoMax(id)
    else
        return cvarMax
    end

end