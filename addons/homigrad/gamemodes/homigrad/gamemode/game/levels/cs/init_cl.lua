css.GetTeamName = tdm.GetTeamName
local red, blue, gray = Color(255, 75, 75), Color(75, 75, 255), Color(200, 200, 200)

gameevent.Listen("player_activate")

hook.Add("player_activate", "CSS_SendData", function(data)
	css.points = {}
	css.WinPoints = {}

	for i = 1, 2 do
		css.WinPoints[i] = GetGlobalInt("CSS_Winpoints" .. i)
	end

	timer.Create("CSS_ThinkAboutPoints", 1, 0, function()
		css.PointsThink()
	end)

	for k, v in pairs(css.points) do
		v.CaptureProgress = GetGlobalInt(k .. "PointProgress", 0)
		v.CaptureTeam = GetGlobalInt(k .. "PointCapture", nil)
	end
end)

function css.PointsThink()
	for i = 1, 3 do
		css.WinPoints[i] = GetGlobalInt("CSS_Winpoints" .. i, 0)
	end

	for k, v in pairs(css.points) do
		v.CaptureProgress = GetGlobalInt(k .. "PointProgress", 0)
		v.CaptureTeam = GetGlobalInt(k .. "PointCapture", nil)
	end
end

local upvector = Vector(0, 0, 128)

-- Позиции точек и счёт
function css.HUDPaint_RoundLeft(white2)
	local lply = LocalPlayer()
	local name, color = css.GetTeamName(lply)
	local startRound = roundTimeStart + 7 - CurTime()

	if startRound > 0 and lply:Alive() then
		lply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 0.5, 0.5)

		draw.DrawText("Ваша команда " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText("Захват точек", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color(155, 55, 155, math.Clamp(startRound - 0.5, 0, 1) * 255), TEXT_ALIGN_CENTER)
		draw.DrawText("Захватите точки, наберайте очки для победы", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color(155, 155, 155, math.Clamp(startRound - 0.5, 0, 1) * 255), TEXT_ALIGN_CENTER)

		return
	end

	local css_points = css.points

	for i, point in pairs(SpawnPointsList.controlpoint[3]) do
		local pos = (point[1] + upvector):ToScreen()
		local v = css_points[i]

		if not v then
			v = {}
			css_points[i] = v
		end

		surface.SetDrawColor(100, 100, 100, 100)
		surface.DrawRect(pos.x - ScrW() * 0.005, pos.y, ScrW() * 0.011, ScrH() * 0.02)

		v.CaptureProgress = v.CaptureProgress or 0

		surface.SetDrawColor((v.CaptureProgress > 0 and red) or (v.CaptureProgress < 0 and blue) or gray)
		surface.DrawRect(pos.x - ScrW() * 0.005, pos.y, math.abs(v.CaptureProgress or 0) / 100 * ScrW() * 0.011, ScrH() * 0.02)
		draw.SimpleText(i, "ChatFont", pos.x, pos.y, gray, TEXT_ALIGN_CENTER)
	end

	surface.SetDrawColor(35, 35, 35, 100)
	surface.DrawRect(ScrW() * 0.39, ScrH() * 0.97, ScrW() * 0.1, ScrH() * 0.01)
	surface.DrawRect(ScrW() * 0.51, ScrH() * 0.97, ScrW() * 0.1, ScrH() * 0.01)
	surface.SetDrawColor(red)
	surface.DrawRect(ScrW() * 0.39 + ((1000 - css.WinPoints[1]) / 1000 * ScrW() * 0.1), ScrH() * 0.97, css.WinPoints[1] / 1000 * ScrW() * 0.1, ScrH() * 0.01)
	surface.SetDrawColor(blue)
	surface.DrawRect(ScrW() * 0.51, ScrH() * 0.97, css.WinPoints[2] / 1000 * ScrW() * 0.1, ScrH() * 0.01)

	-- Время раунда
	local time = math.Round(roundTimeStart + roundTime - CurTime())
	local acurcetime = string.FormattedTime(time, "%02i:%02i")

	if time < 0 then
		acurcetime = "Иди нахуй"
	end

	draw.SimpleText(acurcetime, "HomigradFont", ScrW() / 2, ScrH() - 25, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local respawntime = GetGlobalInt("CSS_respawntime", CurTime())
	local time2 = math.Round(respawntime + 60 - CurTime(), 0)
	local acurcetime2 = string.FormattedTime(time2, "%02i:%02i")

	draw.SimpleText("Время до респавна: " .. acurcetime2, "HomigradFont", ScrW() / 2, ScrH() - 55, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end