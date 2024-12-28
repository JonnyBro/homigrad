slovopacana.GetTeamName = tdm.GetTeamName

local playsound = false
local bhop
function slovopacana.StartRoundCL()
    playsound = true
end


function slovopacana.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local name,color = slovopacana.GetTeamName(lply)

	local startRound = roundTimeStart + 8 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound("snd_jack_hmcd_shining.mp3")
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,255),0.5,0.5)
        draw.DrawText( "Вы " .. name, "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Слово Пацана", "HomigradFontBig", ScrW() / 2, ScrH() / 2.3, Color( 155,155,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        if name == "Октябрьские" then
            draw.DrawText( "Спросите за базар у чушпанов", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 255,255,255,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        else
            draw.DrawText( "Выбейте дурь из чушпанов", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 255,255,255,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        end
        return
    end

    --draw.SimpleText(acurcetime,"HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end