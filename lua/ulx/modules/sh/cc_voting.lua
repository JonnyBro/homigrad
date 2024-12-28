---------------------------------------
--  This file holds voting commands  --
---------------------------------------
if (SERVER) then
	ulx.convar("votegagSuccessratio", "0.75", _, ULib.ACCESS_SUPERADMIN);
	ulx.convar("votegagMinvotes", "6", _, ULib.ACCESS_SUPERADMIN);
	ulx.convar("votemuteSuccessratio", "0.75", _, ULib.ACCESS_SUPERADMIN);
	ulx.convar("votemuteMinvotes", "6", _, ULib.ACCESS_SUPERADMIN);
end

local function voteGagDone2(t, target, time, ply)
	local shouldGag = false;
	if (t.results[1] && t.results[1] > 0) then
		ulx.logUserAct(ply, target, "#A approved the votegag against #T (" .. time .. " minutes)");
		shouldGag = true;
	else
		ulx.logUserAct(ply, target, "#A denied the votegag against #T");
	end
	if (shouldGag) then
		target:SetPData("votegagged", time);
		target.cc_voting_votegagged = true;
	end
end

local function voteGagDone(t, target, time, ply)
	local results = t.results;
	local winner;
	local winnernum = 0;
	for id, numvotes in pairs(results) do
		if (numvotes > winnernum) then
			winner = id;
			winnernum = numvotes;
		end
	end
	local ratioNeeded = GetConVar("votegagSuccessratio"):GetInt();
	local minVotes = GetConVar("votegagMinvotes"):GetInt();
	local str;
	if ((winner != 1) || (winnernum < minVotes) || (winnernum / t.voters < ratioNeeded)) then
		str = "Vote results: User will not be gagged. (" .. (results[1] || "0") .. "/" .. t.voters .. ")";
	else
		str = "Vote results: User will now be gagged for " .. time .. " minutes, pending approval. (" .. winnernum .. "/" .. t.voters .. ")";
		ulx.doVote("Accept result and gag " .. target:Nick() .. "?", {"Yes", "No"}, voteGagDone2, 30000, {ply}, true, target, time, ply);
	end
	ULib.tsay(_, str);
	ulx.logString(str);
	Msg(str .. "\n");
end

function ulx.votegag(calling_ply, target_ply, minutes)
	local plys = 0;
	for _, v in ipairs(player.GetHumans()) do
		if (IsValid(v)) then
			plys = plys + 1;
		end
	end
	if (voteInProgress || plys <= 5) then
		ULib.tsayError(calling_ply, "There is already a vote in progress or not enough players. Your vote can't be passed at this time.", true);
		return;
	end
	local msg = "Gag " .. target_ply:Nick() .. " for " .. minutes .. " minutes?";
	ulx.doVote(msg, {"Yes", "No"}, voteGagDone, _, _, _, target_ply, minutes, calling_ply);
	ulx.fancyLogAdmin(calling_ply, "#A started a votegag of #i minute(s) against #T", minutes, target_ply);
end
local votegag = ulx.command("Voting", "ulx votegag", ulx.votegag, "!votegag");
votegag:addParam{type = ULib.cmds.PlayerArg};
votegag:addParam{type = ULib.cmds.NumArg, min = 0, max = 180, default = 10, hint = "minutes", ULib.cmds.allowTimeString, ULib.cmds.optional}; // Max = 180 (3 hours) to prevent abuse. Change if you want.
votegag:defaultAccess(ULib.ACCESS_ALL);
votegag:help("Starts a public vote gag against target.");

timer.Create("ulxcc_votingTimer", 60, 0, function ()
	for _, v in ipairs(player.GetHumans()) do
		local g = v:GetPData("votegagged");
		if (g && g != (0 || "0") && !v.cc_voting_votegagged) then
			v.cc_voting_votegagged = true;
			v:SetPData("votegagged", tonumber(g) - 1);
		end
		local m = v:GetPData("votemuted");
		if (m && (m != (0 || "0"))) then
			v:SetPData("votemuted", tonumber(v:GetPData("votemuted")) - 1);
		end
		timer.Simple(0, function ()
			if (IsValid(v) && v:GetPData("votegagged") == (0 || "0")) then
				v:RemovePData("votegagged");
				v.cc_voting_votegagged = nil;
				ULib.tsay(nil, v:Nick() .. " was auto-ungagged.");
			end
			if (IsValid(v) && v:GetPData("votemuted") == (0 || "0")) then
				v:RemovePData("votemuted");
				ULib.tsay(nil, v:Nick() .. " was auto-unmuted.");
			end
		end);
	end
end);

function ulx.unvotegag(calling_ply, target_plys)
	for _, v in ipairs(target_plys) do
		if (v:GetPData("votegagged") && (v:GetPData("votegagged") != (0 || "0"))) then
			v:RemovePData("votegagged");
			v.cc_voting_votegagged = nil;
			ulx.fancyLogAdmin(calling_ply, "#A ungagged #T", target_plys);
		else
			ULib.tsayError(calling_ply, v:Nick() .. " is not gagged.");
		end
	end
end
local unvotegag = ulx.command("Voting", "ulx unvotegag", ulx.unvotegag, "!unvotegag");
unvotegag:addParam{type = ULib.cmds.PlayersArg};
unvotegag:defaultAccess(ULib.ACCESS_ADMIN);
unvotegag:help("Ungag the player");

hook.Add("PlayerCanHearPlayersVoice", "ulxcc_VoteGagged", function (listener, talker)
	local g = talker.cc_voting_votegagged;
	if (g && (g != (0 || "0"))) then
		return false;
	end
end);

-- ULX Votemute --
local function voteMuteDone2(t, target, time, ply)
	local shouldMute = false;
	if (t.results[1] && t.results[1] > 0) then
		ulx.logUserAct(ply, target, "#A approved the vote mute against #T (" .. time .. " minutes)");
		shouldMute = true;
	else
		ulx.logUserAct(ply, target, "#A denied the vote mute against #T");
	end
	if (shouldMute) then
		target:SetPData("votemuted", time);
	end
end

local function voteMuteDone(t, target, time, ply)
	local results = t.results;
	local winner;
	local winnernum = 0;
	for id, numvotes in pairs(results) do
		if (numvotes > winnernum) then
			winner = id;
			winnernum = numvotes;
		end
	end
	local ratioNeeded = GetConVar("ulx_votemuteSuccessratio"):GetInt();
	local minVotes = GetConVar("ulx_votemuteMinvotes"):GetInt();
	local str;
	if ((winner != 1) || (winnernum < minVotes) || (winnernum / t.voters < ratioNeeded)) then
		str = "Vote results: User will not be muted. (" .. (results[1] || "0") .. "/" .. t.voters .. ")";
	else
		str = "Vote results: User will now be muted for " .. time .. " minutes, pending approval. (" .. winnernum .. "/" .. t.voters .. ")";
		ulx.doVote("Accept result and mute " .. target:Nick() .. "?", {"Yes", "No"}, voteMuteDone2, 30000, {ply}, true, target, time, ply);
	end
	ULib.tsay(_, str);
	ulx.logString(str);
	Msg(str .. "\n");
end

function ulx.votemute(calling_ply, target_ply, minutes)
	local plys = 0;
	for _, v in ipairs(player.GetHumans()) do
		if (IsValid(v)) then
			plys = plys + 1;
		end
	end
	if (voteInProgress || plys <= 5) then
		ULib.tsayError(calling_ply, "There is already a vote in progress or not enough players. Your vote can't be passed at this time.", true);
		return;
	end
	local msg = "Mute " .. target_ply:Nick() .. " for " .. minutes .. " minutes?";
	ulx.doVote(msg, {"Yes", "No"}, voteMuteDone, _, _, _, target_ply, minutes, calling_ply);
	ulx.fancyLogAdmin(calling_ply, "#A started a vote mute of #i minute(s) against #T", minutes, target_ply);
end
local votemute = ulx.command("Voting", "ulx votemute", ulx.votemute, "!votemute");
votemute:addParam{type = ULib.cmds.PlayerArg }
votemute:addParam{type = ULib.cmds.NumArg, min = 0, default = 3, hint = "minutes", ULib.cmds.allowTimeString, ULib.cmds.optional};
votemute:defaultAccess(ULib.ACCESS_ALL);
votemute:help("Starts a public vote mute against target.");

function ulx.unvotemute(calling_ply, target_plys)
	for _, v in ipairs(target_plys) do
		if (v:GetPData("votemuted") && v:GetPData("votemuted") != (0 || "0")) then
			v:RemovePData("votemuted");
			ulx.fancyLogAdmin(calling_ply, "#A unmuted #T", target_plys);
		else
			ULib.tsayError(calling_ply, v:Nick() .. " is not muted.");
		end
	end
end
local unvotemute = ulx.command("Voting", "ulx unvotemute", ulx.unvotemute, "!unvotemute");
unvotemute:addParam{type = ULib.cmds.PlayersArg};
unvotemute:defaultAccess(ULib.ACCESS_ADMIN);
unvotemute:help("Unmute the player");

hook.Add("PlayerSay", "ulxcc_VoteMuted", function (ply)
	if (ply:GetPData("votemtued") && (ply:GetPData("votemuted") != (0 || "0"))) then
		return "";
	end
end);
