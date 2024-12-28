DisconnectedPlayers = {};
local mov = 1;

hook.Add("PlayerDisconnected", "TrackInformation", function (leaver)
	local sid = tostring(leaver:SteamID());
	local nick = tostring(leaver:Nick());
	local lip = leaver:IPAddress();
	for i = 1, #DisconnectedPlayers do
		if (DisconnectedPlayers[i][1] == sid) then
			return;
		end
	end
	DisconnectedPlayers[mov] = {
		tostring(sid),
		tostring(nick),
		tostring(string.sub(tostring(lip), 1, string.len(lip) - 6)),
		tostring(os.date("%H:%M"));
	};
	mov = mov + 1;
end);

concommand.Add("print_disconnects", function (ply)
	if (!IsValid(ply) && SERVER) then
		PrintTable(DisconnectedPlayers, 4);
	elseif (IsValid(ply)) then
		ply:ChatPrint("[ERROR]: This is a server console command.");
	end
end);

util.AddNetworkString("DisconnectsRequestTable");
util.AddNetworkString("DisconnectsTransferTable");
net.Receive("DisconnectsRequestTable", function (_, sender)
	if (IsValid(sender) && sender:IsAdmin() && table.Count(DisconnectedPlayers) != 0) then
		net.Start("DisconnectsTransferTable");
			net.WriteTable(DisconnectedPlayers);
		net.Send(sender);
	elseif (table.Count(DisconnectedPlayers) == 0) then
		sender:ChatPrint("[ERROR]: The disconnections table is empty, " .. (sender.Nick && tostring(sender:Nick())) .. "!");
	elseif (IsValid(sender)) then
		sender:ChatPrint("[ERROR]: You don't have access to this command, " .. (sender.Nick && tostring(sender:Nick())) .. "!");
	end
end);
