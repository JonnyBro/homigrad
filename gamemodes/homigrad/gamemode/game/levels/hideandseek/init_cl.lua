hideandseek.GetTeamName = tdm.GetTeamName

local colorSpec = ScoreboardSpec

function hideandseek.Scoreboard_Status(ply)
	local lply = LocalPlayer()
	if not lply:Alive() or lply:Team() == 1002 then return true end

	return "Spectator", colorSpec
end

local green = Color(0, 125, 0)
local playsound = true

function hideandseek.HUDPaint_RoundLeft(white2, time)
	local time = math.Round(roundTimeStart + roundTime - CurTime())
	local ftime = string.FormattedTime(time, "%02i:%02i")
	local lply = LocalPlayer()
	local name, color = hideandseek.GetTeamName(lply)
	local startRound = roundTimeStart + 5 - CurTime()

	if startRound > 0 and lply:Alive() then
		if playsound then
			playsound = false
			lply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 220), 0.5, 4)
		end

		draw.DrawText(language.GetPhrase("hg.modes.yourteam"):format(language.GetPhrase(name)), "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(language.GetPhrase("hg.hideandseek.name"), "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)

		if lply:Team() == 1 then
			draw.DrawText(language.GetPhrase("hg.hideandseek.desc1"), "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		else
			draw.DrawText(language.GetPhrase("hg.hideandseek.desc2"), "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color(color.r, color.g, color.b, math.Clamp(startRound, 0, 1) * 255), TEXT_ALIGN_CENTER)
		end

		return
	end

	if time > 0 then
		draw.SimpleText(language.GetPhrase("hg.levels.swatarrive"):format(ftime), "HomigradFont", ScrW() / 2 / 1.1, ScrH() - 25, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		green.a = 0
	else
		green.a = 255
	end

	if lply:Team() == 3 or lply:Team() == 2 or not lply:Alive() and hideandseek.police and time < 0 then
		local tbl = SpawnPointsList.spawnpoints_ss_exit

		if tbl then
			for _, point in pairs(tbl[3]) do
				point = ReadPoint(point)
				local pos = point[1]:ToScreen()
				draw.SimpleText("EXIT", "ChatFont", pos.x, pos.y, green, TEXT_ALIGN_CENTER)
			end
		else
			draw.SimpleText("If you're seeing this, please ask the admins to set exit points '!point exit'!", "HomigradFont", ScrW() / 2, ScrH() - 100, white2, TEXT_ALIGN_CENTER)
		end
	end
end
