function injectPointshop1Module()
	hook.Add("PlayerInitialSpawn", "ULXCC_VariableSet", function (ply)
		timer.Simple(10, function ()
			if (IsValid(ply)) then
				ply.canbrag = true;
			end
		end);
	end);
	function startTimer(ply)
		timer.Simple(180, function ()
			if (IsValid(ply)) then
				ply.canbrag = true;
			end
		end);
	end
	function ulx.brag(calling_ply)
		if (IsValid(calling_ply) && calling_ply.canbrag) then
			calling_ply.canbrag = false;
			startTimer(calling_ply);
			local pts = tonumber(calling_ply:PS_GetPoints());
			if (isnumber(pts) && (pts != 0)) then
				for _, v in ipairs(player.GetHumans()) do
					if (IsValid(v)) then
						v:ChatPrint("[BRAG]: " .. ((calling_ply.Nick && calling_ply:Nick()) || "?") .. " has " .. tostring(pts) .. " points!");
					end
				end
			else
				ULib.tsayError(calling_ply, "[ERROR]: What are you gonna do, brag about being broke?");
			end
		elseif (IsValid(calling_ply) && !calling_ply.canbrag) then
			ULib.tsayError(calling_ply, "[ERROR]: You can't brag yet!");
		end
	end
	local brag = ulx.command("Custom", "ulx brag", ulx.brag, {"!brag", "!mypoints"}, true);
	brag:defaultAccess(ULib.ACCESS_ALL);
	brag:help("Brag about your pointshop points!");
	function ulx.viewpoints(calling_ply, target_plys)
		for _, v in ipairs(target_plys) do
			if (IsValid(v)) then
				local pts = v:PS_GetPoints();
				calling_ply:ChatPrint("[POINTS]: " .. ((v.Nick && v:Nick()) || "?") .. " has " .. pts .. " points!");
			else
				ULib.tsayError(calling_ply, "[ERROR]: Not a valid player!");
			end
		end
	end
	local viewpoints = ulx.command("Custom", "ulx viewpoints", ulx.viewpoints, "!viewpoints", true);
	viewpoints:addParam({type = ULib.cmds.PlayersArg});
	viewpoints:defaultAccess(ULib.ACCESS_ALL);
	viewpoints:help("View a players points");
	function ulx.givepoints(calling_ply, target_plys, points)
		for _, v in ipairs(target_plys) do
			if (IsValid(v) && !v:IsBot()) then
				v:PS_GivePoints(tonumber(points) || 0);
				v:ChatPrint(calling_ply:Nick() .. " has given you " .. (tostring(points) || 0) .. " points!");
			end
		end
		ulx.fancyLogAdmin(calling_ply, "#A gave #i points to #T", points, target_plys);
	end
	local givepoints = ulx.command("Fun", "ulx givepoints", ulx.givepoints, "!givepoints", true);
	givepoints:addParam({type = ULib.cmds.PlayersArg});
	givepoints:addParam({type = ULib.cmds.NumArg, min = 5, max = 99999999, hint = "Points", ULib.cmds.round});
	givepoints:help("Give a player pointshop points.");
	givepoints:defaultAccess(ULib.ACCESS_SUPERADMIN);
end

timer.Simple(3, function (MadeByZero)
	if (istable(PS)) then
		print("[ULXCC]: Pointshop is installed! Adding pointshop module!");
		injectPointshop1Module();
	end
end);
