table.insert(LevelList,"starwarsclonewars")
starwarsclonewars = {}
starwarsclonewars.Name = "Война Клонов"

starwarsclonewars.red = {"Республика",Color(255,75,60),
	weapons = {"megamedkit","weapon_binokle","weapon_hands","med_band_big","med_band_small","medkit"},
	main_weapon = {"weapon_752_dc15a","weapon_752_dc15s","weapon_752_dc17m_br","weapon_752_dc15a","weapon_752_dc15s","weapon_752_dc17m_br","weapon_752_dc15a","weapon_752_dc15s","weapon_752_dc17m_br","weapon_752_dc17m_sn", "weapon_752_dc17m_at"},
	secondary_weapon = {"weapon_752_dc15sa", "weapon_752_dc17"},
	models = {
	"models/player/Star Wars Battlefront 2/Republic/rep_inf_clonecommander.mdl",
	"models/player/Star Wars Battlefront 2/Republic/rep_inf_ep3trooper.mdl",
	"models/player/Star Wars Battlefront 2/Republic/rep_inf_ep3armoredpilot.mdl",
	"models/player/Star Wars Battlefront 2/Republic/rep_inf_ep3heavytrooper.mdl",
	"models/player/Star Wars Battlefront 2/Republic/rep_inf_ep3jettrooper.mdl",
	"models/player/Star Wars Battlefront 2/Republic/rep_inf_feluciatrooper.mdl",
	"models/player/Star Wars Battlefront 2/Republic/rep_inf_ep3sniper.mdl"
	}
}

--local models = {}
--for i = 1,9 do table.insert(models,"models/player/rusty/natguard/male_0" .. i .. ".mdl") end

starwarsclonewars.blue = {"КНС",Color(125,125,255),
	weapons = {"megamedkit","weapon_binokle","weapon_hands","med_band_small","med_band_big","med_band_small", "medkit"},
	main_weapon = {"weapon_752_e5", "weapon_752_ee3", "weapon_752_kotor_blaster_rifle","weapon_752_e5", "weapon_752_ee3", "weapon_752_kotor_blaster_rifle","weapon_752_e5", "weapon_752_ee3", "weapon_752_kotor_blaster_rifle", "weapon_752_dc17m_at"},
	secondary_weapon = {"weapon_752_se14c", "weapon_752_kyd21"},
	models = {
	"models/Player/SGG/Starwars/battledroid.mdl",
	"models/Player/SGG/Starwars/battledroid_geo.mdl",
	"models/Player/SGG/Starwars/battledroid_commander.mdl",
	"models/Player/SGG/Starwars/battledroid_pilot.mdl",
	"models/Player/SGG/Starwars/battledroid_security.mdl"
	}
}

starwarsclonewars.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function starwarsclonewars.StartRound()
	game.CleanUpMap(false)
	starwarsclonewars.points = {}
    if !file.Read( "homigrad/maps/controlpoint/"..game.GetMap()..".txt", "DATA" ) and SERVER then
        print("Скажите админу чтоб тот создал !point control_point или хуярьтесь без Точек Захвата.") 
        PrintMessage(HUD_PRINTCENTER, "Скажите админу чтоб тот создал !point control_point или хуярьтесь без Точек Захвата.")
    end

	starwarsclonewars.LastWave = CurTime()

    starwarsclonewars.WinPoints = {}
    starwarsclonewars.WinPoints[1] = 0
    starwarsclonewars.WinPoints[2] = 0

	team.SetColor(1,starwarsclonewars.red[2])
	team.SetColor(2,starwarsclonewars.blue[2])

	for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        SetGlobalInt(i .. "PointProgress", 0)
        SetGlobalInt(i .. "PointCapture", 0)
        starwarsclonewars.points[i] = {}
    end

    SetGlobalInt("starwarsclonewars_respawntime", CurTime())

	if CLIENT then return end
		timer.Create("starwarsclonewars_ThinkAboutPoints", 1, 0, function() --подумай о точках... засунул в таймер для оптимизации, ибо там каждый тик игроки в сфере подглядываются, ну и в целом для удобства
        	starwarsclonewars.PointsThink()
    	end)

	if CLIENT then

		starwarsclonewars.StartRoundCL()
		return
	end

	starwarsclonewars.StartRoundSV()
end
starwarsclonewars.RoundRandomDefalut = 1
starwarsclonewars.SupportCenter = true
