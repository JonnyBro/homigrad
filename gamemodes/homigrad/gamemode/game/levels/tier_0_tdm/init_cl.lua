local playsound = false

function tdm.HUDPaint_RoundLeft(white)
	local ply = LocalPlayer()
	local name, color = tdm.GetTeamName(ply)
	local startRound = roundTimeStart + 5 - CurTime()

	if startRound > 0 and ply:Alive() then
		if playsound then
			playsound = false

			ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 220), 0.5, 4)
		end

		draw.DrawText(language.GetPhrase("hg.modes.yourteam"):format(language.GetPhrase(name)), "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(language.GetPhrase("hg.tdm.name"), "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(language.GetPhrase("hg.tdm.desc"), "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color(55, 55, 55, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)

		return
	end
end