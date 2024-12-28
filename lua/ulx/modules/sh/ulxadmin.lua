local CATEGORY_NAME = "Admin"

-- Admin Calls a !sit to Teleport to Sit Room.

function ulx.sit( calling_ply, target_ply )
local sspos = file.Read( "ssp.txt", "DATA" )
    print(sspos)
    target_ply.ulx_prevpos = target_ply:GetPos()
	target_ply.ulx_prevang = target_ply:EyeAngles()

    if sspos != nil then -- if its not nil then do what we want    
    calling_ply:SetPos( Vector(sspos) )
    ULib.tsay( calling_ply, "You have been put in the sit room!", true )
    else -- if its nil then tell a nibba
        ULib.tsay( calling_ply, "Set the sit position!", true )
    end
end

local sit = ulx.command( CATEGORY_NAME, "ulx sit", ulx.sit, "!sit" )
sit:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
sit:defaultAccess( ULib.ACCESS_ADMIN )
sit:help( "Teleport to Sit Room." )



function ulx.ssp( calling_ply )
local plypos = tostring(calling_ply:GetPos())
 if file.Exists( "ssp", "DATA" ) != true then
		file.Delete( "ssp.txt" )
		file.Write( "ssp.txt", plypos )
		ULib.tsay( calling_ply, "You have set the sit position!", true )
	end
end

local ssp = ulx.command( CATEGORY_NAME, "ulx ssp", ulx.ssp, "!ssp" )
ssp:defaultAccess( ULib.ACCESS_ADMIN )
ssp:help( "Set sit position." )



function ulx.sspdel( calling_ply )
		if file.Exists( "ssp", "DATA" ) != true then
		file.Delete( "ssp.txt" )
		ULib.tsay( calling_ply, "You have deleted the sit position!", true )
		else end
	end

local sspdel = ulx.command( CATEGORY_NAME, "ulx sspdel", ulx.sspdel, "!sspdel" )
sspdel:defaultAccess( ULib.ACCESS_ADMIN )
sspdel:help( "Delete sit position." )



-- Force Dead Players to Respawn from !menu

function ulx.respawn( calling_ply, target_ply )
    if not target_ply:Alive() then
	    target_ply:Spawn()
		ulx.fancyLogAdmin( calling_ply, true, "#A Respawned #T", target_ply )
	end
end

local respawn = ulx.command( CATEGORY_NAME, "ulx respawn", ulx.respawn,
"!respawn", true )
respawn:addParam{ type=ULib.cmds.PlayerArg }
respawn:defaultAccess( ULib.ACCESS_ADMIN )
respawn:help( "Respawn a target player." )



-- Set a players name

local PlayerNameOrNick = debug.getregistry().Player
PlayerNameOrNick.RealName = PlayerNameOrNick.Nick
PlayerNameOrNick.Nick = function(self) if self != nil then return self:GetNWString("PlayerName", self:RealName()) else return "" end end
PlayerNameOrNick.Name = PlayerNameOrNick.Nick
PlayerNameOrNick.GetName = PlayerNameOrNick.Nick

function ulx.setName( calling_ply, target_ply, name )
local PlayerNick = target_ply:Nick() 
    target_ply:SetNWString("PlayerName",name)
    ulx.fancyLogAdmin( calling_ply, "#A set "..PlayerNick.." Name to "..name, target_ply, name )
end
local setName = ulx.command( CATEGORY_NAME, "ulx setname", ulx.setName, "!setname" )
setName:addParam{ type=ULib.cmds.PlayerArg }
setName:addParam{ type=ULib.cmds.StringArg, hint="name", ULib.cmds.takeRestOfLine }
setName:defaultAccess( ULib.ACCESS_ADMIN )
setName:help( "Set a target's Name." )



-- Admin Mode (Noclip, & God Mode)

function ulx.admin( calling_ply, should_revoke )

	if not should_revoke then
		calling_ply:GodEnable()
	else
		calling_ply:GodDisable()
	end

	
	if not should_revoke then
		calling_ply:SetMoveType( MOVETYPE_NOCLIP )
	else
		calling_ply:SetMoveType( MOVETYPE_WALK )
	end
	
	if not should_revoke then
		ulx.fancyLogAdmin( calling_ply, true, "#A is now administrating" )
	else
		ulx.fancyLogAdmin( calling_ply, true, "#A has stopped administrating" )
	end

end
local admin = ulx.command( "Admin", "ulx admin", ulx.admin, { "!admin", "!admin"}, true )
admin:addParam{ type=ULib.cmds.BoolArg, invisible=true }
admin:defaultAccess( ULib.ACCESS_SUPERADMIN )
admin:help( "Noclip, & God Mode yourself" )
admin:setOpposite( "ulx unadmin", { _, true }, "!unadmin", true )