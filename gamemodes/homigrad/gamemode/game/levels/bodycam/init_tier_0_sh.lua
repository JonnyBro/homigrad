table.insert(LevelList,"bodycam")
bodycam = {}
bodycam.Name = "Bodycam"
bodycam.points = {}

bodycam.WinPoints = bodycam.WinPoints or {}
bodycam.WinPoints[1] = bodycam.WinPoints[1] or 0
bodycam.WinPoints[2] = bodycam.WinPoints[2] or 0

bodycam.red = {"Террористы",Color(176,0,0),
	weapons = {"weapon_hands","weapon_hg_hatchet","med_band_big","weapon_radio","shina","medkit"},
	main_weapon = {"weapon_galilsar", "weapon_mp5", "weapon_m3super","weapon_xm1014","weapon_akm","weapon_ak74u","weapon_cppsh41","weapon_slb_g3sg1","weapon_slb_sg550","weapon_slb_awp" },
	secondary_weapon = {"weapon_beretta","weapon_fiveseven","weapon_beretta"},
	models = {"models/player/leet.mdl","models/player/phoenix.mdl"}
}

bodycam.blue = {"Контр-Терористы",Color(79,59,187),
	weapons = {"megamedkit","weapon_hg_hatchet","weapon_hands","medkit","painkiller","weapon_handcuffs","weapon_radio","shina","weapon_slb_awp","weapon_slb_sg552","weapon_slb_aug","weapon_slb_scout" },
	main_weapon = {"weapon_m4a1","weapon_mp7","weapon_galil","weapon_ar15"},
	secondary_weapon = {"weapon_hk_usp", "weapon_deagle"},
	models = {"models/player/riot.mdl"}
}

bodycam.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function bodycam.StartRound()
    local ply = player.GetAll()
	game.CleanUpMap(false)
    bodycam.points = {}
    if !file.Read( "homigrad/maps/controlpoint/"..game.GetMap()..".txt", "DATA" ) and SERVER then
        print("Скажите админу чтоб тот создал !point control_point или хуярьтесь без Точек Захвата.") 
        PrintMessage(HUD_PRINTCENTER, "Скажите админу чтоб тот создал !point control_point или хуярьтесь без Точек Захвата.")
    end

    bodycam.LastWave = CurTime()

    bodycam.WinPoints = {}
    bodycam.WinPoints[1] = 0
    bodycam.WinPoints[2] = 0

	team.SetColor(1,red)
	team.SetColor(2,blue)

    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        SetGlobalInt(i .. "PointProgress", 0)
        SetGlobalInt(i .. "PointCapture", 0)
        bodycam.points[i] = {}
    end

    SetGlobalInt("CP_respawntime", CurTime())

	if CLIENT then return end

    timer.Create("CP_ThinkAboutPoints", 1, 0, function() --подумай о точках... засунул в таймер для оптимизации, ибо там каждый тик игроки в сфере подглядываются, ну и в целом для удобства
        bodycam.PointsThink()
    end)

    bodycam.StartRoundSV()
end

--тот кто это кодил нужно убить нахуй
bodycam.RoundRandomDefalut = 1
bodycam.SupportCenter = true

/*function bodycam.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,red)
	team.SetColor(2,blue)

	if CLIENT then
		bodycam.StartRoundCL()
		return
	end

	bodycam.StartRoundSV()
end
bodycam.RoundRandomDefalut = 2
bodycam.SupportCenter = false*/