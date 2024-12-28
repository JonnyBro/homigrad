----------------------------------------------
--  This file holds teleportation commands  --
----------------------------------------------

--This local function is required for ULX Bring to work--
------------------------------------------------------------------------------------
local function playerSend(from, to, force)
	if (!to:IsInWorld() || !force) then return false; end
	local yawF = to:EyeAngles().yaw;
	local directions = {
		math.NormalizeAngle(yawF - 180), // Behind
		math.NormalizeAngle(yawF + 90), // Right
		math.NormalizeAngle(yawF - 90), // Left
		yawF;
	};
	local t = {};
	t.start = (to:GetPos() + Vector(0, 0, 32)) // Move them up a bit so they can travel across the ground
	t.filter = {to, from};
	local i = 1;
	t.endpos = (to:GetPos() + Angle(0, directions[i], 0):Forward() * 47)
	local tr = util.TraceEntity(t, from);
	while tr.Hit do
		i = i + 1;
		if ((i > #directions) && force) then
			from.ulx_prevpos = from:GetPos();
			from.ulx_prevang = from:EyeAngles();
			return to:GetPos() + Angle(0, directions[1], 0):Forward() * 47;
		else
			return false;
		end
		t.endpos = to:GetPos() + Angle(0, directions[i], 0):Forward() * 47;
		tr = util.TraceEntity(t, from);
	end
	from.ulx_prevpos = from:GetPos();
	from.ulx_prevang = from:EyeAngles();
	return tr.HitPos;
end
------------------------------------------------------------------------------------

function ulx.fbring(calling_ply, target_ply)
	if (!IsValid(calling_ply)) then
		return;
	end
	if (ulx.getExclusive(calling_ply, calling_ply)) then
		ULib.tsayError(calling_ply, ulx.getExclusive(calling_ply, calling_ply), true);
		return;
	end
	if (ulx.getExclusive(target_ply, calling_ply)) then
		ULib.tsayError(calling_ply, ulx.getExclusive(target_ply, calling_ply), true);
		return;
	end
	if (!target_ply:Alive() || target_ply:Health() <= 0) then
		ULib.tsayError(calling_ply, target_ply:Nick() .. " is dead!", true);
		return;
	end
	if (!calling_ply:Alive() || calling_ply:Health() <= 0) then
		ULib.tsayError(calling_ply, "You're dead!", true);
		return;
	end
	if (calling_ply:InVehicle()) then
		ULib.tsayError(calling_ply, "Please leave the vehicle first!", true);
		return;
	end
	local newPos = playerSend(target_ply, calling_ply, target_ply:GetMoveAngles() == MOVETYPE_NOCLIP);
	if (!newPos) then
		ULib.tsayError(calling_ply, "Can't find a place to put the target!", true);
		return;
	end
	if (target_ply:InVehicle()) then
		target_ply:ExitVehicle();
	end
	local newAng = (calling_ply:GetPos() - newPos):Angle();
	target_ply:SetPos(newPos);
	target_ply:SetEyeAngles(newAng);
	target_ply:SetLocalVelocity(Vector(0, 0, 0));
	target_ply:Lock();
	target_ply.frozen = true;
	ulx.setExclusive(target_ply, "frozen");
	ulx.fancyLogAdmin(calling_ply, "#A brought and froze #T", target_ply);
end
local fbring = ulx.command("Teleport", "ulx fbring", ulx.fbring, "!fbring");
fbring:addParam{type = ULib.cmds.PlayerArg, target = "!^"};
fbring:defaultAccess(ULib.ACCESS_ADMIN);
fbring:help("Brings target to you and freezes them.");

--fteleport
function ulx.fteleport(calling_ply, target_ply)
	if (!IsValid(calling_ply)) then
		return;
	end
	if (ulx.getExclusive(target_ply, calling_ply)) then
		ULib.tsayError(calling_ply, ulx.getExclusive(target_ply, calling_ply), true);
		return;
	end
	if (!target_ply:Alive()) then
		ULib.tsayError(calling_ply, target_ply:Nick() .. " is dead!", true);
		return;
	end
	local t = {};
	t.start = calling_ply:GetPos() + Vector(0, 0, 32);
	t.endpos = calling_ply:GetPos() + calling_ply:EyeAngles():Forward() * 16384;
	t.filter = target_ply;
	if (target_ply != calling_ply) then
		t.filter = {target_ply, calling_ply};
	end
	local tr = util.TraceEntity(t, target_ply);
	local pos = tr.HitPos;
	if (target_ply == calling_ply && pos:Distance(target_ply:GetPos()) < 64) then
		return;
	end
	target_ply.ulx_prevpos = target_ply:GetPos();
	target_ply.ulx_prevang = target_ply:EyeAngles();
	if (target_ply:InVehicle()) then
		target_ply:ExitVehicle();
	end
	target_ply:SetPos(pos);
	target_ply:SetLocalVelocity(Vector(0, 0, 0));
	target_ply.frozen = true;
	ulx.setExclusive(target_ply, "frozen");
	ulx.fancyLogAdmin(calling_ply, "#A teleported and froze #T", target_ply);
end
local fteleport = ulx.command("Teleport", "ulx fteleport", ulx.fteleport, {"!ftp", "!fteleport"});
fteleport:addParam{type = ULib.cmds.PlayerArg};
fteleport:defaultAccess(ULib.ACCESS_ADMIN);
fteleport:help("Teleports target and freezes them.");

-- ULX Warp --
--Set positions to teleport to, then type !warp <position name> to TP to that location

local savedPos = {};
function ulx.setwarp(calling_ply, name)
	if (!name[1]) then return; end
	savedPos[tostring(name[1])] = calling_ply:GetPos();
	for _, v in ipairs(player.GetAll()) do
		if (v:IsUserGroup("operator") || v:IsAdmin()) then
			ULib.tsayColor(v, false, Color(255, 255, 255), "A new warp location has been created: ", Color(255, 0, 0), name);
		end
	end
	ulx.fancyLogAdmin(calling_ply, true, "#A set warp position #s", name);
end
local setwarp = ulx.command("Teleport", "ulx setwarp", ulx.setwarp, "!setwarp");
setwarp:addParam{type = ULib.cmds.StringArg, hint = "name"};
setwarp:addParam{type = ULib.cmds.BoolArg, invisible = true};
setwarp:defaultAccess(ULib.ACCESS_ADMIN);
setwarp:help("Sets a warp position.");

function ulx.warp(calling_ply, name)
	if (!name[1]) then return; end
	for k, v in pairs(savedPos) do
		if (k == tostring(name[1])) then
			calling_ply:SetPos(v);
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A warped to #s", name);
end
local warp = ulx.command("Teleport", "ulx warp", ulx.warp, "!warp");
warp:addParam{type = ULib.cmds.StringArg, hint = "name"};
warp:defaultAccess(ULib.ACCESS_ADMIN);
warp:help("Warps to a set position");
