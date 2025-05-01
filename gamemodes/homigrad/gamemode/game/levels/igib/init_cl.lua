local playsound = false

function igib.StartRoundCL()
	playsound = true
end

function igib.HUDPaint_RoundLeft(white)
	local lply = LocalPlayer()
	local spawn = GetGlobalInt("igib_respawntime", CurTime())
	local time = math.Round(spawn + 15 - CurTime(), 0)
	local timerr = string.FormattedTime(time, "%02i:%02i")
	local startRound = roundTimeStart + 5 - CurTime()

	if startRound > 0 and lply:Alive() then
		if playsound then
			playsound = false
			surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
		end

		lply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 220), 0.5, 4)

		draw.DrawText("InstaGib", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color(155, 155, 55, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText("УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color(55, 55, 55, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)

		return
	end

	draw.SimpleText("Время до респавна: " .. timerr, "HomigradFont", ScrW() / 2, ScrH() - 55, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end