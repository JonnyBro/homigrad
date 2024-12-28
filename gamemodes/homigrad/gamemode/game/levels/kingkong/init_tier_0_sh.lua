table.insert(LevelList,"kingkong")
kingkong = kingkong or {}
kingkong.Name = "King Kong"

kingkong.red = {"Люди",Color(125,125,125),
    models = tdm.models
}

kingkong.teamEncoder = {
    [1] = "red"
}

kingkong.RoundRandomDefalut = 1
kingkong.CanRandomNext = false

local playsound = false
if SERVER then
    util.AddNetworkString("roundType2")
else
    net.Receive("roundType2",function(len)
        playsound = true
    end)
end

function kingkong.StartRound(data)
    team.SetColor(1,kingkong.red[2])

    game.CleanUpMap(false)

    if SERVER then
        net.Start("roundType2")
        net.Broadcast()
    end

    if CLIENT then

        return
    end

    return kingkong.StartRoundSV()
end

if SERVER then return end

local red,blue = Color(200,0,10),Color(75,75,255)
local gray = Color(122,122,122,255)
function kingkong.GetTeamName(ply)
    if ply.roleT then return "King Kong",red end

    local teamID = ply:Team()
    if teamID == 1 then
        return "Люди",ScoreboardSpec
    end
end

local black = Color(0,0,0,255)

net.Receive("homicide_roleget2",function()
    for i,ply in pairs(player.GetAll()) do ply.roleT = nil end
    local role = net.ReadTable()

    for i,ply in pairs(role[1]) do ply.roleT = true end
end)

function kingkong.HUDPaint_Spectate(spec)
    local name,color = kingkong.GetTeamName(spec)
    draw.SimpleText(name,"HomigradFontBig",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function kingkong.Scoreboard_Status(ply)
    local lply = LocalPlayer()

    return true
    --if not lply:Alive() or lply:Team() == 1002 then return true end

    --return "Неизвестно",ScoreboardSpec
end

local red = Color(200, 0, 10)
local roundSound = "snd_jack_hmcd_wildwest.mp3"

function kingkong.HUDPaint_RoundLeft()
    local lply = LocalPlayer()
    local name, color = kingkong.GetTeamName(lply)

    local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound(roundSound)
        end
        lply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 3, 0.5)

        draw.DrawText("Вы " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color(color.r, color.g, color.b, math.Clamp(startRound - 0.5, 0, 1) * 255), TEXT_ALIGN_CENTER)
        draw.DrawText("King Kong", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color(55, 55, 155, math.Clamp(startRound - 0.5, 0, 1) * 255), TEXT_ALIGN_CENTER)

        if lply.roleT then
            draw.DrawText("Вы - Кинг Конг, разберитесь со всеми людми. Нажмите R чтобы активировать ярость.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color(155, 55, 55, math.Clamp(startRound - 0.5, 0, 1) * 255), TEXT_ALIGN_CENTER)
        else
            draw.DrawText("Нейтрализуйте Кинг Конга", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color(55, 55, 55, math.Clamp(startRound - 0.5, 0, 1) * 255), TEXT_ALIGN_CENTER)
        end
        return
    end

    local lply_pos = lply:GetPos()

    for _, ply in pairs(player.GetAll()) do
        local color
        local shouldHighlight = false

        if lply.roleT then
            shouldHighlight = ply ~= lply and ply:Alive()
            color = red
        else
            if ply.roleT and ply:Alive() then
                shouldHighlight = true
                color = red
            end
        end

        if shouldHighlight then
            local pos = ply:GetPos() + ply:OBBCenter()
            local dis = lply_pos:Distance(pos)
            local screenPos = pos:ToScreen()

            if lply.roleT then
                color.a = 255 * (1 - dis / 750)
            else
                color.a = 255
            end

            if screenPos.visible then
                draw.SimpleText(ply.roleT and "Кинг Конг" or "Людь", "HomigradFont", screenPos.x, screenPos.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
end

kingkong.NoSelectRandom = false