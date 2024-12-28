ww2.GetTeamName = tdm.GetTeamName

local red, blue, gray = Color(255,75,75), Color(75,75,255), Color(200, 200, 200)
local upvector = Vector(0, 0, 128)
local playsound = false

ww2.points = ww2.points or {}
ww2.WinPoints = ww2.WinPoints or {}

gameevent.Listen("player_activate")
hook.Add("player_activate","Bamhut_SendData",function(data)
    ww2.points = ww2.points or {}
    ww2.WinPoints = ww2.WinPoints or {}

    for i = 1, 2 do
        ww2.WinPoints[i] = GetGlobalInt("ww2_Winpoints" .. i)
    end

    timer.Create("ww2_ThinkAboutPoints", 1, 0, function() --подумай о точках... засунул в таймер для оптимизации, ибо там каждый тик игроки в сфере подглядываются, ну и в целом для удобства
        ww2.PointsThink()
    end)

    for k, v in pairs(ww2.points) do
        v.CaptureProgress = GetGlobalInt(k .. "PointProgress", 0)
        v.CaptureTeam = GetGlobalInt(k .. "PointCapture", nil)
    end
end)

function ww2.PointsThink()
    ww2.WinPoints = ww2.WinPoints or {}
    for i = 1, 3 do
        ww2.WinPoints[i] = GetGlobalInt("ww2_Winpoints" .. i, 0)
    end

    for k, v in pairs(ww2.points) do
        v.CaptureProgress = GetGlobalInt(k .. "PointProgress", 0)
        v.CaptureTeam = GetGlobalInt(k .. "PointCapture", nil)
    end
end

function ww2.StartRoundCL()
    playsound = true
end

function ww2.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local name,color = ww2.GetTeamName(lply)

	local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,255),0.5,0.5)
        draw.DrawText( "Ваша команда " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Вторая мировая", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 155,155,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Нейтрализуйте вражескую команду... ", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
    
    local ww2_points = ww2.points
    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        local pos = (point[1] + upvector):ToScreen()
        local v = ww2_points[i]
        if not v then
            v = {}
            ww2_points[i] = v
        end

        surface.SetDrawColor(100, 100, 100, 100)
        surface.DrawRect(pos.x - ScrW() * 0.005, pos.y, ScrW() * 0.011, ScrH() * 0.02)
        v.CaptureProgress = v.CaptureProgress or 0
        surface.SetDrawColor((v.CaptureProgress > 0 and red) or (v.CaptureProgress < 0 and blue) or gray)
        surface.DrawRect(pos.x - ScrW() * 0.005, pos.y, math.abs(v.CaptureProgress or 0) / 100 * ScrW() * 0.011, ScrH() * 0.02)
        draw.SimpleText(i,"ChatFont", pos.x,pos.y, gray,TEXT_ALIGN_CENTER)
    end
    surface.SetDrawColor(35, 35, 35, 100)
    surface.DrawRect(ScrW() * 0.39, ScrH() * 0.97, ScrW() * 0.1, ScrH() * 0.01)
    surface.DrawRect(ScrW() * 0.51, ScrH() * 0.97, ScrW() * 0.1, ScrH() * 0.01)

    surface.SetDrawColor(red)
    surface.DrawRect(ScrW() * 0.39 + ((1000 - ww2.WinPoints[1]) / 1000 * ScrW() * 0.1), ScrH() * 0.97, ww2.WinPoints[1] / 1000 * ScrW() * 0.1, ScrH() * 0.01)
    surface.SetDrawColor(blue)
    surface.DrawRect(ScrW() * 0.51, ScrH() * 0.97, ww2.WinPoints[2] / 1000 * ScrW() * 0.1, ScrH() * 0.01)

    --время раунда
    local time = math.Round(roundTimeStart + roundTime - CurTime())
    local acurcetime = string.FormattedTime( time, "%02i:%02i" )
	if time < 0 then acurcetime = "Иди нахуй" end

	draw.SimpleText(acurcetime,"HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    local respawntime = GetGlobalInt("ww2_respawntime", CurTime())
    
    local time2 = math.Round(respawntime + 60 - CurTime(),0)
    local acurcetime2 = string.FormattedTime( time2, "%02i:%02i" )
    draw.SimpleText("Время до респавна: " .. acurcetime2,"HomigradFont",ScrW()/2,ScrH()-55,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end