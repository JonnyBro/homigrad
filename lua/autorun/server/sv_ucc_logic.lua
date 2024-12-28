util.AddNetworkString("cmds")
util.AddNetworkString("sendcmds")
util.AddNetworkString("cmds_cl")

con_callers = {}
con_ticket_number = 1

net.Receive("sendcmds", function(_, ply)
	local rtable = net.ReadTable()
	local rtable2 = net.ReadTable()
	local call = net.ReadEntity()
	local targ = net.ReadString()
	local bool = net.ReadBool()
	local tn = tonumber(net.ReadString())

	if (not bool) or (not tn) or (tonumber(ply.sessionid) ~= tn) or (con_callers[tn] ~= call) or (ply.callerid ~= con_callers[tn]) then return end

	net.Start("cmds_cl")
		net.WriteTable(rtable)
		net.WriteTable(rtable2)
		net.WriteString(targ)
	net.Send(call)
end)

util.AddNetworkString("listfriends")
util.AddNetworkString("sendtable")

net.Receive("sendtable", function(_, ply)
	local caa = net.ReadEntity()
	local cak = net.ReadTable()
	if ply.expcall ~= caa then return end

	local rtbl = table.concat(cak, ", ")

	if string.len(rtbl) == 0 and table.Count(cak) == 0 then
		ulx.fancyLog({caa}, "#T has no friends on this server", ply)
	else
		ulx.fancyLog({caa}, "#T is friends with #s", ply, rtbl)
	end
end)