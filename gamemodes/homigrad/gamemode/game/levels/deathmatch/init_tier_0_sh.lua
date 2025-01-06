table.insert(LevelList,"dm")
dm = {}
dm.Name = "Deathmatch"
dm.LoadScreenTime = 5.5
dm.CantFight = dm.LoadScreenTime

dm.NoSelectRandom = false

local red = Color(155,155,255)

function dm.GetTeamName(ply)
    local teamID = ply:Team()

     if teamID == 1 then return "Fighter",red end
end

function dm.StartRound(data)
    team.SetColor(1, red)
    team.SetColor(2, red)
    team.SetColor(3, red)

    game.CleanUpMap(false)

    if CLIENT then
        roundTimeStart = data[1]
        roundTime = data[2]
        dm.StartRoundCL()

        return
    end

    return dm.StartRoundSV()
end

if SERVER then return end

local black = Color(0,0,0)
local red = Color(255,0,0)

local kill = 4

local white,red = Color(255,255,255),Color(255,0,0)

local fuck,fuckLerp = 0,0


local playsound = false
function dm.StartRoundCL()
    playsound = true
end

function dm.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()

	local startRound = roundTimeStart + 5 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
            lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,220),0.5,4)
        end

        --[[surface.SetFont("HomigradRoundFont")
        surface.SetTextColor(color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255)
        surface.SetTextPos(ScrW() / 2 - 40,ScrH() / 2)

        surface.DrawText("Вы " .. name)]]--
        draw.DrawText( "It's Only You.", "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color( 155,155,255,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Deathmatch.", "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color( 155,155,255,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        --draw.DrawText( roundTypes[roundType], "HomigradRoundFont", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )

        draw.DrawText( "Kill everyone!", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( 155,155,255,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
end
--[[
net.Receive("dm die",function()
    timeStartAnyDeath = CurTime()
end)]]

function dm.CanUseSpectateHUD()
    return false
end

dm.RoundRandomDefalut = 2