table.insert(LevelList,"igib")
igib = {}
igib.Name = "InstaGib"
igib.LoadScreenTime = 2.5
igib.RoundRandomDefalut = 1

local red = Color(155,155,255)

function igib.GetTeamName(ply)
    local teamID = ply:Team()

     if teamID == 1 then return "Боец",red end
end

function igib.StartRound(data)
    team.SetColor(1,red)
    --team.SetColor(2,blue)
    --team.SetColor(1,green)
    game.CleanUpMap(false)

    if CLIENT then
        roundTimeStart = data[1]
        roundTime = data[2]
        igib.StartRoundCL()
        return
    end

    return igib.StartRoundSV()
end

if SERVER then return end
local kill = 4
local white,red = Color(255,255,255),Color(255,0,0)
local fuck,fuckLerp = 0,0

local playsound = false
function igib.StartRoundCL()
    playsound = true
end

function igib.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local startRound = roundTimeStart + 3 - CurTime()

    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,255),0.5,0.5)
        draw.DrawText( "SHOOT & RUN", "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( 155,155,255,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "InstaGib", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 155,155,255,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
end

net.Receive("dm die",function()
    timeStartAnyDeath = CurTime()
end)

function igib.CanUseSpectateHUD() return false end

igib.RoundRandomDefalut = 3