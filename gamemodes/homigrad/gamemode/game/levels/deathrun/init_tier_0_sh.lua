table.insert(LevelList,"deathrun")
deathrun = {}
deathrun.Name = "DeathRun"

deathrun.red = {"Смерть",Color(255,55,55),
    weapons = {"weapon_radio","weapon_hands"},
    main_weapon = {"weapon_hands"},
    secondary_weapon = {"weapon_hands"},
    models = tdm.models
}

deathrun.green = {"Убегающие",Color(55,255,55),
    weapons = {"weapon_hands"},
    main_weapon = {"weapon_hands","weapon_hands","adrenaline","weapon_hg_flashbang","weapon_hands","weapon_hands","food_monster"},
    models = tdm.models
}

deathrun.blue = {"Смерть",Color(55,55,255),
    weapons = {"weapon_radio","weapon_hands"},
    main_weapon = {"weapon_hands"},
    secondary_weapon = {"weapon_hands"},
    models = tdm.models
}

deathrun.teamEncoder = {
    [1] = "red",
    [2] = "green",
    [3] = "blue"
}

function deathrun.StartRound(data)
	team.SetColor(1,deathrun.red[2])
	team.SetColor(2,deathrun.green[2])
	team.SetColor(3,deathrun.green[2])

	game.CleanUpMap(false)

    if CLIENT then
		roundTimeLoot = data.roundTimeLoot

		return
	end

    return deathrun.StartRoundSV()
end

deathrun.SupportCenter = true
deathrun.NoSelectRandom = true
deathrun.RoundRandomDefalut = 999
