zombie.GetTeamName = tdm.GetTeamName

local colorSpec = ScoreboardSpec
function zombie.Scoreboard_Status(ply)
	local lply = LocalPlayer()
	if not lply:Alive() or lply:Team() == 1002 then return true end

	return "Spectator",colorSpec
end

local green = Color(0,125,0)
local white = Color(255,255,255)

local playsound = true

function zombie.HUDPaint_RoundLeft(white2,time)
	local time = math.Round(roundTimeStart + roundTime - CurTime())
	local ftime = string.FormattedTime(time,"%02i:%02i")
	local lply = LocalPlayer()
	local name,color = zombie.GetTeamName(lply)

	local startRound = roundTimeStart + 5 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            --surface.PlaySound("snd_jack_hmcd_disaster.mp3") Nope!
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,220),0.5,4)


        --[[surface.SetFont("HomigradFontBig")
        surface.SetTextColor(color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255)
        surface.SetTextPos(ScrW() / 2 - 40,ScrH() / 2)

        surface.DrawText("Вы " .. name)]]--
        draw.DrawText( "You are on team: " .. name, "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Zombie Survival", "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        --draw.DrawText( roundTypes[roundType], "HomigradFontBig", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )

		draw.DrawText( "Survive from zombies until National Guards arrive, and dash for the exit!", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )

        return
    end

	if time > 0 then
		draw.SimpleText("Time Left before National Guards arrive: ","HomigradFont",ScrW() / 2 - 200,ScrH()-25,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		draw.SimpleText(ftime,"HomigradFont",ScrW() / 2 + 200,ScrH()-25,white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
		green.a = 0
	else
		green.a = 255
	end
	--[[
	local time = math.Round(roundTimeStart + (roundTimeLoot or 0) - CurTime())
	local ftime = string.FormattedTime(time,"%02i:%02i")

	if time > 0 then
		draw.SimpleText("До спавна лута :","HomigradFont",ScrW() / 2 - 200,ScrH() - 50,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		draw.SimpleText(ftime,"HomigradFont",ScrW() / 2 + 200,ScrH() - 50,white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
	end
	--]]

	if (lply:Team() == 1 or not lply:Alive()) and (time < 0) then
		local list = SpawnPointsList.spawnpoints_ss_exit
		--local list = ReadDataMap("spawnpoints_ss_exit")
		if list then
			for i,point in pairs(list[3]) do
				point = ReadPoint(point)
				local pos = point[1]:ToScreen()
				draw.SimpleText("EXIT","ChatFont",pos.x,pos.y,green,TEXT_ALIGN_CENTER)
			end

			--draw.SimpleText("Click Tab to see it again.","HomigradFont",ScrW() / 2,ScrH() - 100,white2,TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("If you're seeing this, please ask the admins to spawn escape points!","HomigradFont",ScrW() / 2,ScrH() - 100,white2,TEXT_ALIGN_CENTER)
		end
	end
end

function zombie.PlayerClientSpawn()
	if LocalPlayer():Team() ~= 3 then return end

	showRoundInfo = CurTime() + 10
end