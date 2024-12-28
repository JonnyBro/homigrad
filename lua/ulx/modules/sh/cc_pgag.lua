----------------------------------------
--  This file holds the PGag command  --
----------------------------------------

function ulx.pgag(calling_ply, target_plys, bUnPgag)
	if (bUnPgag) then
		for _, v in ipairs(target_plys) do
			v:RemovePData("permgagged");
		end
		ulx.fancyLogAdmin(calling_ply, "#A un-permagagged #T ", target_plys);
	else
		for _, v in ipairs(target_plys) do
			v:SetPData("permgagged", true);
		end
		ulx.fancyLogAdmin(calling_ply, "#A permanently gagged #T", target_plys);
	end
end
local pgag = ulx.command("Chat", "ulx pgag", ulx.pgag, "!pgag");
pgag:addParam{type = ULib.cmds.PlayersArg};
pgag:addParam{type = ULib.cmds.BoolArg, invisible = true};
pgag:defaultAccess(ULib.ACCESS_ADMIN);
pgag:help("Gag target(s), disables microphone using pdata.");
pgag:setOpposite("ulx unpgag", {_, _, true}, "!unpgag");

hook.Add("PlayerCanHearPlayersVoice", "ULXCC_PgagManager", function (list, talk)
	if (!talk.cantalk) then return false; end
end);

hook.Add("PlayerDisconnected", "ULXCC_pgagDisconnect", function (ply)
	if (ply:GetPData("permgagged") == true) then
		for _, v in ipairs(player.GetAll()) do
			if (v:IsAdmin()) then
				ULib.tsayError(v, ply:Nick() .. " has left the server and is permanently gagged.");
			end
		end
	end
end);

hook.Add("PlayerAuthed", "ULXCC_SetPGagData", function (ply)
	if (ply:GetPData("permgagged") == true) then
		ply.cantalk = false;
		for _, v in ipairs(player.GetAll()) do
			if (v:IsAdmin()) then
				ULib.tsayError(v, ply:Nick() .. " has joined and is permanently gagged.");
			end
		end
	else
		ply.cantalk = true;
	end
end);

function ulx.printpgags(calling_ply)
	local p = {};
	for _, v in ipairs(player.GetAll()) do
		if (v:GetPData("permgagged") == true) then
			table.insert(p, v:Nick())
		end
	end
	p = table.concat(p, ", ");
	ulx.fancyLog({calling_ply}, "PGagged: #s ", p);
end
local ppgags = ulx.command("Chat", "ulx printpgags", ulx.printpgags, {"!pgags", "!listpgags", "!plist", "!pgaglist", "!printpgags"});
ppgags:defaultAccess(ULib.ACCESS_ADMIN);
ppgags:help("Prints players who are pgagged.");
