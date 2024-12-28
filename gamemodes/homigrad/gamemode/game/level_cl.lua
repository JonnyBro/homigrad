dataRound = dataRound
endDataRound = endDataRound
net.Receive("round_state",function()
	roundActive = net.ReadBool()
	local data = net.ReadTable()

	if roundActive == true then
        dataRound = data

		local func = TableRound().StartRound
		if func then func(data) end
	else
        endDataRound = data

		local func = TableRound().EndRound
		if func then func(data.lastWinner,data) end
	end
end)

net.Receive("round_time",function()
	roundTimeStart = net.ReadFloat()
	roundTime = net.ReadFloat()
	roundTimeLoot = net.ReadFloat()
end)

showRoundInfo = CurTime() + 3
roundActiveName = roundActiveName or "tdm"
roundActiveNameNext = roundActiveNameNext or "tdm"

net.Receive("round",function()
	roundActiveName = net.ReadString()
	showRoundInfo = CurTime() + 10

	system.FlashWindow()

	chat.AddText("Игровой режим сменился на : " .. TableRound().Name)
end)

net.Receive("round_next",function()
	roundActiveNameNext = net.ReadString()
	showRoundInfo = CurTime() + 10

	chat.AddText("Следующий режим : " .. TableRound(roundActiveNameNext).Name)
end)

local white = Color(255,255,255)
showRoundInfoColor = Color(255,255,255)
local yellow = Color(255,255,0)

hook.Add("HUDPaint","homigrad-roundstate",function()
	if roundActive then
		local func = TableRound().HUDPaint_RoundLeft

		if func then
			func(showRoundInfoColor)
		else
			local time = math.Round(roundTimeStart + roundTime - CurTime())
			local acurcetime = string.FormattedTime(time,"%02i:%02i")
			if time < 0 then acurcetime = "акедумадекосай;3" end

			draw.SimpleText(acurcetime,"HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	else
		draw.WordBox(5, ScrW() / 2, ScrH() - 50, (#PlayersInGame() <= 1 and "Нужно минимум 2 игрока") or " Раунд закончен ", 'HomigradFont', Color(35, 35, 35, 200), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local k = showRoundInfo - CurTime()

	if k > 0 then
		k = math.min(k,1)

		showRoundInfoColor.a = k * 255
		yellow.a = showRoundInfoColor.a

		local name,nextName = TableRound().Name,TableRound(roundActiveNameNext).Name
		if name == "Conter-Strike: Source Govno" then
			RunConsoleCommand("hg_bodycam", "0")
		elseif name == "Bodycam" then
			RunConsoleCommand("hg_bodycam", "1")
		else
		    RunConsoleCommand("hg_bodycam", "0")
		end


		draw.RoundedBox(5, ScrW() - 270 - math.max(#nextName, #name) * 4, ScrH() - 65, 800, 70, Color(0, 0, 0, showRoundInfoColor.a - 30))
		draw.SimpleText("Текущий режим: " .. name,"HomigradFont",ScrW() - 15, ScrH() - 40, showRoundInfoColor, TEXT_ALIGN_RIGHT)
		if math.Round(roundTimeStart + roundTime - CurTime()) > 0 then
			if roundActiveName == "homicide" or roundActiveName == "schoolshoot" then
				draw.SimpleText("До прибытия копов: " .. math.Round(roundTimeStart + roundTime - CurTime()),"HomigradFont",ScrW() - 15, ScrH() - 60, showRoundInfoColor, TEXT_ALIGN_RIGHT)
			--elseif roundActiveName == "scp" then
				--draw.SimpleText("До прибытия МОГ: " .. math.Round(scp.spawnMOG),"HomigradFont",ScrW() - 15, ScrH() - 60, showRoundInfoColor, TEXT_ALIGN_RIGHT)
			else
				draw.SimpleText("До конца раунда: " .. math.Round(roundTimeStart + roundTime - CurTime()),"HomigradFont",ScrW() - 15, ScrH() - 60, showRoundInfoColor, TEXT_ALIGN_RIGHT) 
			end
			else draw.SimpleText("Время вышло","HomigradFont",ScrW() - 15, ScrH() - 60, showRoundInfoColor, TEXT_ALIGN_RIGHT)
		end
		draw.SimpleText("Следующий режим: " .. nextName,"HomigradFont",ScrW() - 15, ScrH() - 20,name ~= nextName and yellow or showRoundInfoColor, TEXT_ALIGN_RIGHT)
	end
end)


hook.Add("PostDrawOpaqueRenderables","homigrad-PostDrawOpaqueRenderables",function()
	local func = TableRound().PostDrawOpaqueRenderables_RoundLeft

	if func then
		func(showRoundInfoColor)
	
	end
end)