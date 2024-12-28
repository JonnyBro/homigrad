table.insert(LevelList,"jailbreak")
jailbreak = {}
jailbreak.Name = "JailBreak"

jailbreak.red = {"ФСИН",Color(55,55,255),
    weapons = {"weapon_radio","weapon_police_bat","weapon_hands","weapon_taser","weapon_handcuffs","weapon_glock","med_band_big","shina"},
    main_weapon = {"weapon_hands"},
    secondary_weapon = {"weapon_hands"},
    models = {"models/rashkinsk/fsin/camo/camo_07.mdl","models/rashkinsk/fsin/camo/camo_06.mdl","models/rashkinsk/fsin/camo/camo_07.mdl",}
}

jailbreak.green = {"Заключенный",Color(255,170,0),
    weapons = {"weapon_hands"},
    main_weapon = {"weapon_hands","weapon_hg_kitknife","weapon_hands","adrenaline","weapon_hg_flashbang","weapon_hands","weapon_hands","weapon_hands"},
    models = tdm.models
}

jailbreak.blue = {"ФСИН",Color(55,55,255),
    weapons = {"weapon_radio","weapon_hands","weapon_kabar","med_band_big","med_band_small","medkit","painkiller","weapon_hg_f1","weapon_handcuffs","weapon_taser","weapon_hg_flashbang","shina"},
    main_weapon = {"weapon_mk18","weapon_m4a1","weapon_m3super","weapon_mp7","weapon_xm1014","weapon_fal","weapon_galilsar","weapon_m249","weapon_mp5","weapon_mp40"},
    secondary_weapon = {"weapon_beretta","weapon_fiveseven","weapon_hk_usp"},
    models = tdm.models
}

jailbreak.teamEncoder = {
    [1] = "green",
    [2] = "red",
    [3] = "blue",
}

function jailbreak.StartRound(data)
    team.SetColor(1,jailbreak.red[2])
    team.SetColor(2,jailbreak.green[2])
    team.SetColor(3,jailbreak.green[2])

    game.CleanUpMap(false)

    if CLIENT then
        roundTimeLoot = data.roundTimeLoot

        return
    end

    return jailbreak.StartRoundSV()
end

jailbreak.SupportCenter = true