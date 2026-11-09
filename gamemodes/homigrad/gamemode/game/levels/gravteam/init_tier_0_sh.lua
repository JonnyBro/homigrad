--table.insert(LevelList,"gravteam")
gravteam = {}
gravteam.Name = "Gravity Gun Gambit (TDM)"

local models = {}
for i = 1,9 do table.insert(models,"models/player/group03/male_0" .. i .. ".mdl") end

gravteam.red = {"Resistance",Color(125,95,60),
	weapons = {"weapon_hands","weapon_physcannon","weapon_hg_shovel","medkit","med_band_big"},
	models = models
}

gravteam.blue = {"Combine",Color(75,75,125),
	weapons = {"weapon_hands","weapon_physcannon","weapon_hg_shovel","medkit","med_band_big"},
	models = {"models/player/combine_soldier.mdl"}
}

gravteam.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function gravteam.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,gravteam.red[2])
	team.SetColor(2,gravteam.blue[2])

	if CLIENT then

		gravteam.StartRoundCL()
		return
	end

	gravteam.StartRoundSV()
end
gravteam.RoundRandomDefalut = 2
gravteam.SupportCenter = true
gravteam.NoSelectRandom = true