table.insert(LevelList,"zombo")
zombo = {}
zombo.Name = "Zombo VIRUS"



zombo.red = {"Люди",Color(255,155,120),
    weapons = {"weapon_radio","weapon_gurkha","weapon_hands","med_band_big","med_band_small","medkit","painkiller"},
    main_weapon = {"weapon_m3super","weapon_remington870","weapon_xm1014", "weapon_civil_famas", "weapon_mp5", "weapon_xm8_lmg", "weapon_csmg40", "weapon_ak74u", "weapon_akm", "weapon_m249", "weapon_doublebarrel", "weapon_cmosin", "weapon_l1a1", "weapon_m1a1", "weapon_ar15"},
    secondary_weapon = {"weapon_p220","weapon_deagle","weapon_glock","weapon_fiveseven", "weapon_glock18"},
    models = tdm.models
}

zombo.green = {"Зомбо",Color(55,255,55),
    weapons = {"weapon_braaains"},
    models = tdm.models
}

zombo.blue = {"ОРДО ЗОМБО",Color(55, 135, 112),
    weapons = {"weapon_braaains"},
    models = tdm.models
}

zombo.teamEncoder = {
    [1] = "red",
    [2] = "green",
    [3] = "blue"
}

function zombo.StartRound(data)
	team.SetColor(1,zombo.red[2])
	team.SetColor(2,zombo.green[2])
	team.SetColor(3,zombo.blue[2])

	game.CleanUpMap(false)

    if CLIENT then
		roundTimeLoot = data.roundTimeLoot

		return
	end

    return zombo.StartRoundSV()
	

end

zombo.SupportCenter = true
