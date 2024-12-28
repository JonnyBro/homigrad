table.insert(LevelList,"starwarsgalacticcw")
starwarsgalacticcw = {}
starwarsgalacticcw.Name = "Галактическая Гражданская Война"

starwarsgalacticcw.red = {"Империя",Color(255,75,60),
	weapons = {"megamedkit","weapon_binokle","weapon_hands","med_band_big","med_band_small","medkit"},
	main_weapon = {"weapon_752_e11","weapon_752_e11","weapon_752_e11","weapon_752_e11","weapon_752_e11","weapon_752_e11","weapon_752_e11","weapon_752_e11","weapon_752_e11","weapon_752_dlt19","weapon_752_ihr","weapon_752_t21","weapon_752_e11","weapon_752_dlt19","weapon_752_ihr","weapon_752_t21","weapon_752_e11","weapon_752_dlt19","weapon_752_ihr","weapon_752_t21","weapon_752_dc17m_at"},
	secondary_weapon = {"weapon_752_dsbp"},
	models = {
	"models/player/deckboy/atat_pilot_pm/atat_pilot_pm.mdl",
	"models/player/deckboy/dark_trooper_pm/dark_trooper_pm.mdl",
	"models/player/deckboy/shock_trooper_pm/shock_trooper_pm.mdl",
	"models/player/deckboy/storm_trooper_pm/storm_trooper_pm.mdl",
	"models/player/deckboy/storm_trooper_pm/storm_trooper_pm.mdl",
	"models/player/deckboy/storm_trooper_pm/storm_trooper_pm.mdl",
	"models/player/deckboy/storm_trooper_pm/storm_trooper_pm.mdl"
	}
}

--local models = {}
--for i = 1,9 do table.insert(models,"models/player/rusty/natguard/male_0" .. i .. ".mdl") end

starwarsgalacticcw.blue = {"Альянс Повстанцев",Color(125,125,255),
	weapons = {"megamedkit","weapon_binokle","weapon_hands","med_band_small","med_band_big","med_band_small", "medkit"},
	main_weapon = {"weapon_752_dh17","weapon_752_dh17","weapon_752_dh17","weapon_752_dh17","weapon_752_dh17","weapon_752_dh17","weapon_752_dh17","weapon_752_bowcaster","weapon_752_dh17","weapon_752_dlt19","weapon_752_ee3","weapon_752_t21","weapon_752_dc17m_at"},
	secondary_weapon = {"weapon_752_se14c", "weapon_752_kyd21"},
	models = {
	"models/Player/SGG/Starwars/Rebels/r_trooper/male_01.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper/male_02.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper/male_03.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper/male_04.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper/male_05.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper/male_07.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper/male_08.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper/male_09.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper_captain/male_01.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper_captain/male_02.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper_captain/male_03.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper_captain/male_04.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper_captain/male_05.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper_captain/male_06.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper_captain/male_07.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper_captain/male_08.mdl",
	"models/Player/SGG/Starwars/Rebels/r_trooper_captain/male_09.mdl",
	"models/player/rebel/rebel_commando.mdl"
	}
}

starwarsgalacticcw.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function starwarsgalacticcw.StartRound()
	game.CleanUpMap(false)
	starwarsgalacticcw.points = {}
    if !file.Read( "homigrad/maps/controlpoint/"..game.GetMap()..".txt", "DATA" ) and SERVER then
        print("Скажите админу чтоб тот создал !point control_point или хуярьтесь без Точек Захвата.") 
        PrintMessage(HUD_PRINTCENTER, "Скажите админу чтоб тот создал !point control_point или хуярьтесь без Точек Захвата.")
    end

	starwarsgalacticcw.LastWave = CurTime()

    starwarsgalacticcw.WinPoints = {}
    starwarsgalacticcw.WinPoints[1] = 0
    starwarsgalacticcw.WinPoints[2] = 0

	team.SetColor(1,starwarsgalacticcw.red[2])
	team.SetColor(2,starwarsgalacticcw.blue[2])

	for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        SetGlobalInt(i .. "PointProgress", 0)
        SetGlobalInt(i .. "PointCapture", 0)
        starwarsgalacticcw.points[i] = {}
    end

    SetGlobalInt("starwarsgalacticcw_respawntime", CurTime())

	if CLIENT then return end
		timer.Create("starwarsgalacticcw_ThinkAboutPoints", 1, 0, function() --подумай о точках... засунул в таймер для оптимизации, ибо там каждый тик игроки в сфере подглядываются, ну и в целом для удобства
        	starwarsgalacticcw.PointsThink()
    	end)

	if CLIENT then

		starwarsgalacticcw.StartRoundCL()
		return
	end

	starwarsgalacticcw.StartRoundSV()
end
starwarsgalacticcw.RoundRandomDefalut = 1
starwarsgalacticcw.SupportCenter = true
