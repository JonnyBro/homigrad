table.insert(LevelList, "slovopacana")

slovopacana = {}
slovopacana.Name = "Пацанские тёрки"

slovopacana.red = {"Октябрьские",Color(66, 135, 245),
	weapons = {
		"weapon_hands",
		"med_band_small"
	},
	main_weapon = {
		"weapon_molotok",	
		"med_band_big",
		"med_band_small",
		"weapon_per4ik",
		"weapon_molotok",
		"med_band_big",
		"med_band_small",
		"weapon_per4ik",
		"shina"
	},
	secondary_weapon = {"weapon_hg_metalbat", "weapon_knife", "weapon_bat","weapon_pipe", "weapon_hg_metalbat", "weapon_bat","weapon_pipe","weapon_hg_metalbat", "weapon_bat","weapon_pipe"},
	models = {
		"models/player/Group02/male_02.mdl",
		"models/player/Group02/male_04.mdl",
		"models/player/Group02/male_06.mdl",
		"models/player/Group02/male_08.mdl",
	}
}


slovopacana.blue = {"Шароваровы",Color(105, 196, 59),
	weapons = {
		"weapon_hands",
		"med_band_small"
	},
	main_weapon = {
		"weapon_molotok",	
		"med_band_big",
		"med_band_small",
		"weapon_per4ik",
		"weapon_molotok",
		"med_band_big",
		"med_band_small",
		"weapon_per4ik",
		"shina"
	},

	secondary_weapon = {"weapon_hg_metalbat", "weapon_knife", "weapon_bat","weapon_pipe", "weapon_hg_metalbat", "weapon_bat","weapon_pipe","weapon_hg_metalbat", "weapon_bat","weapon_pipe"},
	models = {
		"models/player/Group02/male_02.mdl",
		"models/player/Group02/male_04.mdl",
		"models/player/Group02/male_06.mdl",
		"models/player/Group02/male_08.mdl",
	}
}

slovopacana.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function slovopacana.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,slovopacana.red[2])
	team.SetColor(2,slovopacana.blue[2])

	if CLIENT then

		slovopacana.StartRoundCL()
		return
	end

	slovopacana.StartRoundSV()
end

slovopacana.SupportCenter = true

slovopacana.NoSelectRandom = false