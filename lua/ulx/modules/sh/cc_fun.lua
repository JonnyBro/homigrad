------------------------------------
--  This file holds fun commands  --
------------------------------------
local easter_eggs_enabled = true;
// Default: true
local CAT_NAME = "Fun";
function ulx.explode(calling_ply, target_plys)
	for k, v in ipairs(target_plys) do
		local pos = v:GetPos();
		local waterlvl = v:WaterLevel();
		timer.Simple(0, function ()
			local tr = {};
			tr.start = pos;
			tr.endpos = tr.start + (Vector(0, 0, -1) * 250);
			local trw = util.TraceEntity(tr);
			local wp1 = trw.HitPos + trw.HitNormal;
			local wp2 = trw.HitPos - trw.HitNormal;
			util.Decal("Scorch", wp1, wp2);
		end);
		if GetConVar("explode_ragdolls"):GetInt() > 0 then
			v:SetVelocity(Vector(0, 0, 10) * math.Rand(75, 150));
			timer.Simple(0.1, function ()
				v:Kill();
			end);
		else
			v:Kill();
		end
		util.ScreenShake(pos, 5, 5, 1.5, 200);
		local vPoint = pos + Vector(0, 0, 10);
		local eData = EffectData();
		eData:SetStart(vPoint);
		eData:SetOrigin(vPoint);
		eData:SetScale(1);
		if (waterlvl > 1) then
			util.Effect("WaterSurfaceExplosion", eData);
			util.Effect("HelicopterMegaBomb", eData);
		else
			util.Effect("HelicopterMegaBomb", eData);
			v:EmitSound(Sound("ambient/explosions/explode_4.wav"))
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A exploded #T", target_plys);
end
local explode = ulx.command(CAT_NAME, "ulx explode", ulx.explode, "!explode");
explode:addParam{type = ULib.cmds.PlayersArg};
explode:defaultAccess(ULib.ACCESS_ADMIN);
explode:help("Explode your foes!");

function ulx.launch(calling_ply, target_plys)
	for k, v in ipairs(target_plys) do
		v:SetVelocity(Vector(0, 0, 50) * 50);
	end
	ulx.fancyLogAdmin(calling_ply, "#A Launched #T", target_plys);
end
local launch = ulx.command(CAT_NAME, "ulx launch", ulx.launch, "!launch");
launch:addParam{type = ULib.cmds.PlayersArg};
launch:defaultAccess(ULib.ACCESS_ADMIN);
launch:help("Is it possible to send someone to the moon without a rocket?");

function ulx.gravity(calling_ply, target_plys, grav)
	grav = tonumber(grav);
	for k, v in ipairs(target_plys) do
		if (grav == 0) then
			v:SetGravity(0.01);
		elseif (grav > 0) then
			v:SetGravity(grav);
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A set the gravity for #T to #s", target_plys, grav);
end
local gravity = ulx.command(CAT_NAME, "ulx gravity", ulx.gravity, {"!grav", "!gravity"});
gravity:addParam{type = ULib.cmds.PlayersArg};
gravity:addParam{type = ULib.cmds.StringArg, hint = "Number GravityAmount"};
gravity:defaultAccess(ULib.ACCESS_SUPERADMIN);
gravity:help("It's like mars, but it's on earth.");

hook.Add("PlayerInitialSpawn", "FetchSpeed", function (ply)
	timer.Simple(0, function ()
		if (IsValid(ply)) then
			ply.pWalk = ply:GetWalkSpeed();
			ply.pRun = ply:GetRunSpeed();
			if (CLIENT && GetConVar("developer"):GetInt() > 0) then
				ULib.console(ply, "Initial Speeds Fetched!\nWalk Speed: " .. ply.pWalk .. "\nRun Speed: " .. ply.pRun);
			end
		end
	end);
end);

function ulx.speed(calling_ply, target_plys, W, R)
	W = tonumber(W);
	R = tonumber(R);
	for k, v in ipairs(target_plys) do
		if (W == 0 && R == 0) then
			GAMEMODE:SetPlayerSpeed(v, v.pWalk, v.pRun);
			ulx.fancyLogAdmin(calling_ply, "#A reset the walk and run speed for #T", target_plys);
		else
			GAMEMODE:SetPlayerSpeed(v, W, R);
			ulx.fancyLogAdmin(calling_ply, "#A set #T's speeds to #s and #i", target_plys, W, R);
		end
	end
end
local speed = ulx.command(CAT_NAME, "ulx speed", ulx.speed, "!speed");
speed:addParam{type = ULib.cmds.PlayersArg};
speed:addParam{type = ULib.cmds.NumArg, default = 0, hint = "Number WalkSpeed", min = 0, max = 20000};
speed:addParam{type = ULib.cmds.NumArg, default = 0, hint = "Number RunSpeed", min = 0, max = 20000};
speed:defaultAccess(ULib.ACCESS_SUPERADMIN);
speed:help("Sets target's speed.\nSet both values to 0 to reset");

function ulx.model(calling_ply, target_plys, model)
	for k, v in ipairs(target_plys) do
		if (v:Alive() && v:Health() > 0) then
			v:SetModel(model);
		else
			ULib.tsayError(calling_ply, v:Nick() .. " is dead!", true);
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A set the model for #T to #s", target_plys, model);
end
local model = ulx.command(CAT_NAME, "ulx model", ulx.model, "!model");
model:addParam{type = ULib.cmds.PlayersArg};
model:addParam{type = ULib.cmds.StringArg, hint = "model"};
model:defaultAccess(ULib.ACCESS_ADMIN);
model:help("Set a player's model.");

function ulx.jumppower(calling_ply, target_plys, power)
	for k, v in ipairs(target_plys) do
		if (v:Alive() && v:Health() > 0) then
			v:SetJumpPower(power);
		else
			ULib.tsayError(calling_ply, v:Nick() .. " is dead!", true);
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A set the jump power for #T to #s", target_plys, power);
end
local jumppower = ulx.command(CAT_NAME, "ulx jumppower", ulx.jumppower, "!jumppower");
jumppower:addParam{type = ULib.cmds.PlayersArg};
jumppower:addParam{type = ULib.cmds.NumArg, default = 200, hint = "power", ULib.cmds.optional};
jumppower:defaultAccess(ULib.ACCESS_ADMIN);
jumppower:help("Set a player's jump power.\nDefault = 200");

function ulx.setStats(calling_ply, target_plys, num, bDeaths)
	if (GetConVar("sv_cheats"):GetInt() > 0) then
		if (bDeaths) then
			for k, v in ipairs(target_plys) do
				v:SetDeaths(num);
			end
			ulx.fancyLogAdmin(calling_ply, "#A set the deaths for #T to #s", target_plys, num);
		else
			for k, v in ipairs(target_plys) do
				v:SetFrags(num);
			end
			ulx.fancyLogAdmin(calling_ply, "#A set the frags for #T to #s", target_plys, num);
		end
	else
		ULib.tsayError(calling_ply, "This is only available with sv_cheats set to 1!");
		return;
	end
end
local SetStats = ulx.command(CAT_NAME, "ulx frags", ulx.setStats, "!frags");
SetStats:addParam{type = ULib.cmds.PlayersArg};
SetStats:addParam{type = ULib.cmds.NumArg, hint = "number"};
SetStats:addParam{type = ULib.cmds.BoolArg, invisible = true};
SetStats:defaultAccess(ULib.ACCESS_ADMIN);
SetStats:help("Set a player's frags and deaths.");
SetStats:setOpposite("ulx deaths", {_, _, _, true}, "!deaths");

function ulx.ammo(calling_ply, target_plys, amount, bSetAmmo)
	for i = 1, #target_plys do
		local ply = target_plys[i];
		local wep = ply:GetActiveWeapon();
		local ammo = wep:GetPrimaryAmmoType();
		if (bSetAmmo) then
			ply:SetAmmo(amount, ammo);
		else
			ply:GiveAmmo(amount, ammo);
		end
	end
	if (bSetAmmo) then
		ulx.fancyLogAdmin(calling_ply, "#A set the ammo for #T to #s", target_plys, amount);
	else
		ulx.fancyLogAdmin(calling_ply, "#A gave #T #i rounds", target_plys, amount);
	end
end
local ammo = ulx.command(CAT_NAME, "ulx giveammo", ulx.ammo, "!giveammo");
ammo:addParam{type = ULib.cmds.PlayersArg};
ammo:addParam{type = ULib.cmds.NumArg, min = 0, hint = "amount"};
ammo:addParam{type = ULib.cmds.BoolArg, invisible = true};
ammo:defaultAccess(ULib.ACCESS_ADMIN);
ammo:help("Set a player's ammo");
ammo:setOpposite("ulx setammo", {_, _, _, true}, "!setammo");

function ulx.scale(calling_ply, target_plys, scale)
	if (scale > 65535) then scale = 65535; end // 65535 is the max a 16 bit int can hold. Removing this and using something higher than 65535 will result in a lua error / !scale comamnd not working properly.
	for k, v in ipairs(target_plys) do
		if (SERVER && IsValid(v)) then
			v:SetModelScale(scale, 1);
			net.Start("SendViewModelCalc");
				net.WriteInt(scale, 16);
				if (scale == 1) then
					net.WriteBool(true); // We're setting them back to normal.
				else
					net.WriteBool(true);
				end
			net.Send(v);
		end
	end
	ulx.fancyLogAdmin(calling_ply, "#A set the scale for #T to #i", target_plys, scale);
end
local scale = ulx.command(CAT_NAME, "ulx scale", ulx.scale, "!scale");
scale:addParam{type = ULib.cmds.PlayersArg};
scale:addParam{type = ULib.cmds.NumArg, default = 1, min = 0, hint = "multiplier"};
scale:defaultAccess(ULib.ACCESS_ADMIN);
scale:help("Set the model scale of a player.");
// Why am I a fucking piece of paper? - Kam

local zaptable = {
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav"
};

if (SERVER) then
	util.AddNetworkString("ulxcc_blur");
	util.AddNetworkString("SendViewModelCalc");
elseif (CLIENT) then
	net.Receive("ulxcc_blur", function ()
		local n = 10;
		local t = 0.1;
		local k = 1.1;
		for i = 1, n do
			t = t + 0.2;
			k = k - 0.1;
			timer.Simple(t, function ()
				hook.Add("RenderScreenspaceEffects", "DrawMotionBlur", function ()
					DrawMotionBlur(0.1, k, 0.05);
				end);
			end);
			timer.Simple(2.5, function ()
				hook.Remove("RenderScreenspaceEffects", "DrawMotionBlur");
			end);
		end
	end);
	net.Receive("SendViewModelCalc", function ()
		local pScale = net.ReadInt(16);
		local normal = net.ReadBool();
		if (normal) then
			hook.Remove("CalcView", "ScaleCalcView");
		else
			hook.Add("CalcView", "ScaleCalcView", function (ply, pos, angles, fov)
				local view = {
					origin = pos + Vector(0, 0, pScale * 55),
					angles = angles,
					fov = fov,
					drawviewer = false
				};
				return view;
			end);
		end
	end);
end

function ulx.shock(calling_ply, target_plys, damage)
	for k, v in ipairs(target_plys) do
		local eData = EffectData();
		eData:SetEntity(v);
		eData:SetOrigin(v:GetPos());
		eData:SetStart(v:GetPos());
		eData:SetScale(1);
		eData:SetMagnitude(15);
		util.Effect("TeslaHitBoxes", eData);
		v:EmitSound(tostring(table.Random(zaptable)));
		local dmginfo = DamageInfo();
		dmginfo:SetDamage(damage);
		v:TakeDamageInfo(dmginfo);
		if (SERVER) then
			umsg.Start("ulx_blind", v);
				umsg.Bool(true);
				umsg.Short(255);
			umsg.End();
			timer.Simple(0.2, function ()
				for i = -255, 0 do
					if (i > 0) then
						umsg.Start("ulx_blind", v);
							umsg.Bool(true);
							umsg.Short(math.abs(i));
						umsg.End();
					else
						umsg.Start("ulx_blind", v);
							umsg.Bool(false);
							umsg.Short(0);
						umsg.End();
					end
				end
			end);
			net.Start("ulxcc_blur");
			net.Send(v);
		end
	end
	if (damage && damage > 0) then
		ulx.fancyLogAdmin(calling_ply, "#A shocked #T with #i damage", target_plys, damage);
	else
		ulx.fancyLogAdmin(calling_ply, "#A shocked #T", target_plys);
	end
end
local shock = ulx.command(CAT_NAME, "ulx shock", ulx.shock, "!shock");
shock:addParam{type = ULib.cmds.PlayersArg};
shock:addParam{type = ULib.cmds.NumArg, min = 0, hint = "damage", ULib.cmds.optional};
shock:defaultAccess(ULib.ACCESS_ADMIN);
shock:help("Shock players");

if (easter_eggs_enabled && SERVER) then
	util.AddNetworkString("ulxcc_egg");
	local blue = Color(50, 150, 255);
	local white = Color(255, 255, 255);
	hook.Add("PlayerSay", "cc_easteregg", function (ply, txt, pub)
		if (string.sub(txt:lower(), 1, 5) == "4bigz") && (!ply:GetPData("eastereggs1") == "true") then
			ply:SetPData("eastereggs1", "true");
			if (!ply:GetPData("eastereggs")) then
				ply:SetPData("eastereggs", 1);
			else
				ply:SetPData("eastereggs", ply:GetPData("eastereggs") + 1);
			end
			ULib.tsayColor(nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found easter egg #1!");
			if (ply:GetPData("eastereggs") != "3") then
				ULib.tsayColor(nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found ", white, ply:GetPData("eastereggs"), white, "/3 easter eggs.");
			else
				ULib.tsayColor(nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found all 3 easter eggs!");
			end
			for _, v in ipairs(player.GetHumans()) do
				v:SendLua([[surface.PlaySound("garrysmod/content_downloaded.wav")]]);
			end
			return;
		elseif (ply:GetPData("eastereggs1") == "true") then
			ply:ChatPrint("You've already found easter egg 1!");
		end
	end);
	concommand.Add("cc_egg2", function (ply)
		if (ply:GetPData("eastereggs2") == "true") then
			ply:ChatPrint("You have already found easter egg 2!");
		else
			ply:SetPData("eastereggs2", "true");
			if (!ply:GetPData("eastereggs")) then
				ply:SetPData("eastereggs", 1);
			else
				ply:SetPData("eastereggs", ply:GetPData("eastereggs") + 1);
			end
			ULib.tsayColor(nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found easter egg #2!");
			if (ply:GetPData("eastereggs") != "3") then
				ULib.tsayColor(nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found ", white, ply:GetPData("eastereggs"), white, "/3 easter eggs.");
			else
				ULib.tsayColor(nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found all 3 easter eggs!");
			end
			for _, v in ipairs(player.GetHumans()) do
				v:SendLua([[surface.PlaySound("garrysmod/content_downloaded.wav")]]);
			end
			return;
		end
	end);
	net.Receive("ulxcc_egg", function (_, ply)
		if (ply:GetPData("eastereggs3") == "true") then
			ply:ChatPrint("You have already found easter egg 3!");
		else
			ply:SetPData("eastereggs3", "true");
			if (!ply:GetPData("eastereggs")) then
				ply:SetPData("eastereggs", 1);
			else
				ply:SetPData("eastereggs", ply:GetPData("eastereggs") + 1);
			end
			ULib.tsayColor(nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found easter egg #3!");
			if (ply:GetPData("eastereggs") != "3") then
				ULib.tsayColor(nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found ", white, ply:GetPData("eastereggs"), white, "/3 easter eggs.");
			else
				ULib.tsayColor(nil, false, white, "[CC] ", blue, ply:Nick(), white, " has found all 3 easter eggs!");
			end
			for _, v in ipairs(player.GetHumans()) do
				v:SendLua([[surface.PlaySound("garrysmod/content_downloaded.wav")]]);
			end
		end
	end);
elseif (easter_eggs_enabled && CLIENT) then
	CreateConVar("eastereggs_enable", "0");
	cvars.AddChangeCallback("eastereggs_enable", function(cvar, oldVal, newVal)
		oldVal = tostring(oldVal);
		newVal = tostring(newVal);
		if (oldVal == "0" && newVal == "1") then
			net.Start("ulxcc_egg");
			net.SendToServer();
		end
	end);
end
if (easter_eggs_enabled) then
	function ulx.resetdata(calling_ply, target_ply)
		target_ply:RemovePData("eastereggs");
		target_ply:RemovePData("eastereggs1");
		target_ply:RemovePData("eastereggs2");
		target_ply:RemovePData("eastereggs3");
		ulx.fancyLogAdmin(calling_ply, true, "#A reset data for #T", target_ply);
	end
	local resetdata = ulx.command("Utility", "ulx resetdata", ulx.resetdata);
	resetdata:addParam{type = ULib.cmds.PlayerArg};
	resetdata:defaultAccess(ULib.ACCESS_ADMIN);
	resetdata:help("Reset easter egg data.");
end
