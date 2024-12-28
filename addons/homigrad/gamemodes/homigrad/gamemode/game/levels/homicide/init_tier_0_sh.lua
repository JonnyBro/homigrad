table.insert(LevelList,"homicide")
homicide = homicide or {}
homicide.Name = "Homicide"

homicide.red = {"Невиновный",Color(125,125,125),
    models = tdm.models
}

homicide.teamEncoder = {
    [1] = "red"
}

homicide.RoundRandomDefalut = 6

local playsound = false
if SERVER then
    util.AddNetworkString("roundType")
else
    net.Receive("roundType",function(len)
        homicide.roundType = net.ReadInt(5)
        playsound = true
    end)
end

--[[local turnTable = {
    ["standard"] = 2,
    ["soe"] = 1,
    ["wild-west"] = 4,
    ["gun-free-zone"] = 3
    ["THT"] = 5
}--]]

function homicide.IsMapBig()
    local mins,maxs = game.GetWorld():GetModelBounds()
    local skybox = 0
    for i,ent in pairs(ents.FindByClass("sky_camera")) do
        --local skyboxang = ent:GetPos():GetNormalized():Dot(maxs:GetNormalized())
        
        skybox = 0--skyboxang > 0 and ent:GetPos():Distance(-mins) or ent:GetPos():Distance(-maxs)
        --maxs:Sub(skybox)
    end
    
    --PrintMessage(3,tostring(mins:Distance(maxs) - skybox))
    return (mins:Distance(maxs) - skybox) > 5000
    --Vector(-10000, -2000, -2500) Vector(5000, 10000, 800)
end

-- Обновление команды "homicide_setmode"
local homicide_setmode = CreateConVar("homicide_setmode", "99", FCVAR_LUA_SERVER, "Select a round mode (1 - State of Emergency, 2 - Casual, 3 - Unarmed Zone, 4 - Wild West, 5-TTT)")

function homicide.StartRound(data)
    team.SetColor(1, homicide.red[2])
    game.CleanUpMap(false)

    if SERVER then
        -- Получаем значение из конфига
        local roundType = homicide_setmode:GetInt()
        -- Проверяем, чтобы значение находилось в допустимом диапазоне (1-4)
        if roundType < 1 or roundType > 5 then
            roundType = math.random(1, 5) -- Устанавливаем случайный режим, если значение некорректное
        end
        homicide.roundType = roundType
        
        -- Отправляем режим на клиент
        net.Start("roundType")
        net.WriteInt(homicide.roundType, 5)
        net.Broadcast()
    end

    if CLIENT then
        for i, ply in pairs(player.GetAll()) do
            ply.roleT = false
            ply.roleCT = false
            ply.countKick = 0
        end

        roundTimeLoot = data.roundTimeLoot
        return
    end

    return homicide.StartRoundSV()
end


if SERVER then return end

local red,blue = Color(200,0,10),Color(75,75,255)
local gray = Color(122,122,122,255)
function homicide.GetTeamName(ply)
    if ply.roleT then return "Предатель",red end
    if ply.roleCT then return "Невиновный",blue end

    local teamID = ply:Team()
    if teamID == 1 then
        return "Невиновный",ScoreboardSpec
    end
    if teamID == 3 then
        return "Спецназ",blue
    end
end

local black = Color(0,0,0,255)

net.Receive("homicide_roleget",function()
    local role = net.ReadTable()

    for i,ply in pairs(role[1]) do ply.roleT = true end
    for i,ply in pairs(role[2]) do ply.roleCT = true end
end)

function homicide.HUDPaint_Spectate(spec)
    --local name,color = homicide.GetTeamName(spec)
    --draw.SimpleText(name,"HomigradFontBig",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function homicide.Scoreboard_Status(ply)
    local lply = LocalPlayer()
    if not lply:Alive() or lply:Team() == 1002 then return true end

    return "Неизвестно",ScoreboardSpec
end

local red,blue = Color(200,0,10),Color(75,75,255)
local roundTypes = {"Чрезвычайное Положение", "Обычный", "Безоружная Зона", "Дикий Запад", "Trouble in Homigrad Town"}
local roundSound = {"snd_jack_hmcd_disaster.mp3","snd_jack_hmcd_shining.mp3","snd_jack_hmcd_panic.mp3","snd_jack_hmcd_wildwest.mp3","snd_jack_hmcd_psycho.mp3"}

function homicide.HUDPaint_RoundLeft(white2)
    local roundType = homicide.roundType or 2
    local lply = LocalPlayer()
    local name,color = homicide.GetTeamName(lply)

    local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound(roundSound[homicide.roundType])
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,255),3,0.5)


        --[[surface.SetFont("HomigradFontBig")
        surface.SetTextColor(color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255)
        surface.SetTextPos(ScrW() / 2 - 40,ScrH() / 2)

        surface.DrawText("Вы " .. name)]]--
        draw.DrawText( "Вы " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Хомисайд", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( roundTypes[roundType], "HomigradFontBig", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )

        if lply.roleT then --Traitor
            if homicide.roundType == 3 then --gunfree
                draw.DrawText( "Полицейские всех обыскали и забрали ваше оружие\nНа такой случай вы припрятали Арбалет...", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
                draw.DrawText( "Арбалет является скрытым оружием каким-то образом, имея огромные габариты...", "HomigradFontBig", ScrW() / 2, ScrH() / 1.1, Color( 155,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide.roundType == 4 then --wildwest
                draw.DrawText( "Вы взяли с собой револьвер заместо USP-S, дабы не выбиваться из толпы.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.1, Color( 155,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide.roundtype == 1 then --emergency/base
                draw.DrawText( "Ваша задача убить всех до прибытия полиции", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide.roundtype == 2 then --emergency/base
                draw.DrawText( "Ваша задача убить всех до прибытия полиции", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide.roundtype == 5 then
                draw.DrawText( "Вы решили убить всех жителей Хомиграда, но будьте аккуратны, в этом городе все вооружены.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            end
        elseif lply.roleCT then --Innocent with a gun
            if homicide.roundType == 1 then --emergency
                draw.DrawText( "У вас есть дробовик вашего деда, постарайтесь нейтрализовать предателя", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide.roundType == 2 then --base
                draw.DrawText( "У вас есть скрытое огнестрельное оружие, постарайтесь нейтрализовать предателя", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide.roundType == 3 then --gunfree
                draw.DrawText( "Полицейские у всех забрали оружие.\n\nВам, как сотруднику под прикрытием, выдали Шокер и Наручники. Постарайтесь связать или убить предателя", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide.roundType == 4 then --wildwest
                draw.DrawText( "У вас есть револьвер, постарайтесь нейтрализовать предателя", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide.roundType == 5 then
                draw.DrawText( "Вы житель Хомиграда, у вас есть ваше любимое оружие. Кто-то решил уничтожить ваш город, Защитите его.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            end
        elseif homicide.roundType == 5 then
            draw.DrawText( "Вы житель Хомиграда, у вас есть ваше любимое оружие. Кто-то решил уничтожить ваш город, Защитите его.", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )            
        else
            draw.DrawText( "Найдите предателя, свяжите или убейте его для победы. Не доверяйте никому...", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        end
        return
    end

    local time = math.Round(roundTimeStart + roundTimeLoot - CurTime())
    if time > 0 then
        local acurcetime = string.FormattedTime(time,"%02i:%02i")
        acurcetime = "До спавна лута : " .. acurcetime -- Нахуя? Это же не видно.

        draw.SimpleText(acurcetime,"HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local lply_pos = lply:GetPos()

    for i,ply in pairs(player.GetAll()) do
        local color = ply.roleT and red or ply.roleCT and blue
        if not color or ply == lply or not ply:Alive() then continue end

        local pos = ply:GetPos() + ply:OBBCenter()
        local dis = lply_pos:Distance(pos)
        if dis > 600 then continue end

        local pos = pos:ToScreen()
        if not pos.visible then continue end

        color.a = 255 * (1 - dis / 350)
        draw.SimpleText(ply:Nick(),"HomigradFont",pos.x,pos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

function homicide.VBWHide(ply,list)
    if (not ply:IsRagdoll() and ply:Team() == 1002) then return end -- t weps hide

    local blad = {}
    
    for i,wep in pairs(list) do
        local wep = type(i) == "string" and weapons.Get(i) or list[i]
        
        if not wep.TwoHands then continue end

        blad[#blad + 1] = wep
    end--ufff

    return blad
end

function homicide.Scoreboard_DrawLast(ply)
    if LocalPlayer():Team() ~= 1002 and LocalPlayer():Alive() then return false end
end

homicide.SupportCenter = true