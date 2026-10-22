function tdm.CenterInit()
	for _, ply in player.Iterator() do
		ply.delayKill = nil
	end
end

function tdm.Center()
	if not GetGlobalVar("Center") then return end

	local point = ReadDataMap("center")
	if #point == 0 then return end

	for _, ply in player.Iterator() do
		if not ply:Alive() or ply:Team() == 1002 or ply:HasGodMode() then continue end

		if tdm.KCenter(ply:GetPos(), point) >= 1 then
			if not ply.delayKill then
				ply.delayKill = CurTime() + 10

				net.Start("hg_sendchat_simple")
					net.WriteTable("#hg.tdm.returncenter")
				net.Send(ply)
			elseif ply.delayKill < CurTime() then
				ply:Kill()
			end
		elseif ply.delayKill then
			ply.delayKill = nil
			-- ply:ChatPrint("Харош.")
		end
	end
end

if GetGlobalVar("Center") == nil then
	SetGlobalVar("Center", true)
end
