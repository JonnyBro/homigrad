table.insert(LevelList,"css")
css = {}
css.Name = "Conter-Strike: Source Govno"
css.points = {}

css.WinPoints = css.WinPoints or {}
css.WinPoints[1] = css.WinPoints[1] or 0
css.WinPoints[2] = css.WinPoints[2] or 0

css.red = {"Террористы",Color(176,0,0),
	weapons = {"megamedkit","weapon_binokle","weapon_hands","weapon_hg_hatchet","med_band_small","med_band_big","med_band_small","painkiller","weapon_handcuffs","weapon_radio","shina"},
	main_weapon = {"weapon_galilsar", "weapon_mp5", "weapon_m3super","weapon_slb_g3sg1","weapon_slb_sg550","weapon_slb_awp" },
	secondary_weapon = {"weapon_beretta","weapon_fiveseven","weapon_beretta"},
	models = {"models/player/leet.mdl","models/player/phoenix.mdl"}
}

css.blue = {"Контр-Терористы",Color(79,59,187),
	weapons = {"megamedkit","weapon_binokle","weapon_hg_hatchet","weapon_hands","med_band_big","med_band_small","medkit","painkiller","weapon_handcuffs","weapon_radio","shina"},
	main_weapon = {"weapon_m4a1","weapon_mp7","weapon_galil","weapon_slb_awp","weapon_slb_sg552","weapon_slb_aug","weapon_slb_scout" },
	secondary_weapon = {"weapon_hk_usp", "weapon_deagle"},
	models = {"models/player/riot.mdl"}
}

css.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function css.StartRound()
    local ply = player.GetAll()
	game.CleanUpMap(false)
    css.points = {}
    if !file.Read( "homigrad/maps/controlpoint/"..game.GetMap()..".txt", "DATA" ) and SERVER then
        print("Скажите админу чтоб тот создал !point control_point или хуярьтесь без Точек Захвата.") 
        PrintMessage(HUD_PRINTCENTER, "Скажите админу чтоб тот создал !point control_point или хуярьтесь без Точек Захвата.")
    end

    css.LastWave = CurTime()

    css.WinPoints = {}
    css.WinPoints[1] = 0
    css.WinPoints[2] = 0

	team.SetColor(1,red)
	team.SetColor(2,blue)

    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        SetGlobalInt(i .. "PointProgress", 0)
        SetGlobalInt(i .. "PointCapture", 0)
        css.points[i] = {}
    end

    SetGlobalInt("CP_respawntime", CurTime())

	if CLIENT then return end

    timer.Create("CP_ThinkAboutPoints", 1, 0, function() --подумай о точках... засунул в таймер для оптимизации, ибо там каждый тик игроки в сфере подглядываются, ну и в целом для удобства
        css.PointsThink()
    end)

    css.StartRoundSV()
end

--тот кто это кодил нужно убить нахуй
css.RoundRandomDefalut = 1
css.SupportCenter = true

/*function css.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,red)
	team.SetColor(2,blue)

	if CLIENT then
		css.StartRoundCL()
		return
	end

	css.StartRoundSV()
end
css.RoundRandomDefalut = 2
css.SupportCenter = false*/