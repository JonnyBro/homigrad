
if not ConVarExists("hg_precache_models") then CreateConVar("hg_precache_models", "1", {FCVAR_ARCHIVE}, "Should we cache used models in Gamemode? 1 - Yes | 0 - No. If you change from 0 to 1 - Reconnect on server.", 0, 1) end
    if GetConVar("hg_precache_models"):GetInt() == 1 then
        util.PrecacheModel("models/monolithservers/mpd/male_04_2.mdl") -- gamemodes models
        util.PrecacheModel("models/monolithservers/mpd/male_06_2.mdl")
        util.PrecacheModel("models/monolithservers/mpd/male_07_2.mdl")
        util.PrecacheModel("models/monolithservers/mpd/male_08_2.mdl")
        util.PrecacheModel("models/monolithservers/mpd/male_09_2.mdl")
        util.PrecacheModel("models/player/leet.mdl")
        util.PrecacheModel("models/player/phoenix.mdl")
        util.PrecacheModel("models/player/riot.mdl")
        util.PrecacheModel("models/knyaje pack/sso_politepeople/sso_politepeople.mdl")
        util.PrecacheModel("models/player/combine_soldier.mdl")
        util.PrecacheModel("models/player/rusty/natguard/male_01.mdl")
        util.PrecacheModel("models/player/rusty/natguard/male_02.mdl")
        util.PrecacheModel("models/player/rusty/natguard/male_03.mdl")
        util.PrecacheModel("models/player/rusty/natguard/male_04.mdl")
        util.PrecacheModel("models/player/rusty/natguard/male_05.mdl")
        util.PrecacheModel("models/player/rusty/natguard/male_06.mdl")
        util.PrecacheModel("models/player/rusty/natguard/male_07.mdl")
        util.PrecacheModel("models/player/rusty/natguard/male_08.mdl")
        util.PrecacheModel("models/player/rusty/natguard/male_09.mdl")
        util.PrecacheModel("models/player/group01/male_01.mdl")
        util.PrecacheModel("models/player/group01/male_02.mdl")
        util.PrecacheModel("models/player/group01/male_03.mdl")
        util.PrecacheModel("models/player/group01/male_04.mdl")
        util.PrecacheModel("models/player/group01/male_05.mdl")
        util.PrecacheModel("models/player/group01/male_06.mdl")
        util.PrecacheModel("models/player/group01/male_07.mdl")
        util.PrecacheModel("models/player/group01/male_08.mdl")
        util.PrecacheModel("models/player/group01/male_09.mdl")
        util.PrecacheModel("models/player/group01/female_01.mdl")
        util.PrecacheModel("models/player/group01/female_02.mdl")
        util.PrecacheModel("models/player/group01/female_03.mdl")
        util.PrecacheModel("models/player/group01/female_04.mdl")
        util.PrecacheModel("models/player/group01/female_05.mdl")
        util.PrecacheModel("models/player/group01/female_06.mdl")
        util.PrecacheModel("models/monolithservers/mpd/male_02.mdl")
        util.PrecacheModel("models/monolithservers/mpd/male_03.mdl")
        util.PrecacheModel("models/monolithservers/mpd/male_04.mdl")
        util.PrecacheModel("models/monolithservers/mpd/male_05.mdl")
        util.PrecacheModel("models/jmod/ballistic_mask.mdl") -- jmod armor
        util.PrecacheModel("models/player/helmet_achhc_black/achhc_black.mdl")
        util.PrecacheModel("models/player/helmet_ulach_black/ulach.mdl")
        util.PrecacheModel("models/player/helmet_psh97_jeta/jeta.mdl")
        util.PrecacheModel("models/jmod/helmet_riot_heavy.mdl")
        util.PrecacheModel("models/jmod/helmet_riot.mdl")
        util.PrecacheModel("models/jmod/helmet_maska.mdl")
        util.PrecacheModel("models/props_interiors/pot02a.mdl")
        util.PrecacheModel("models/player/armor_paca/paca.mdl")
        util.PrecacheModel("models/player/armor_gjel/gjel.mdl")
        util.PrecacheModel("models/player/armor_6b13_killa/6b13_killa.mdl")
        util.PrecacheModel("models/jmod/heavy_armor.mdl")
        util.PrecacheModel("models/jmod/respirator.mdl")
        util.PrecacheModel("models/splinks/kf2/cosmetics/gas_mask.mdl")
        util.PrecacheModel("models/pwb/weapons/w_m134.mdl") -- weapons
        util.PrecacheModel("models/pwb/weapons/w_aks74u.mdl")
        util.PrecacheModel("models/pwb/weapons/w_akm.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_m4a1.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_remington870police.mdl")
        util.PrecacheModel("models/pwb/weapons/w_m9.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_famasg2.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_matebahomeprotection.mdl")
        util.PrecacheModel("models/pwb/weapons/w_l85a1.mdl")
        util.PrecacheModel("models/pwb/weapons/w_p99.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_ace23.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_asval.mdl")
        util.PrecacheModel("models/pwb/weapons/w_glock17.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_fiveseven.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_usptactical.mdl")
        util.PrecacheModel("models/weapons/w_bean_beansmusp.mdl")
        util.PrecacheModel("models/pwb/weapons/w_tar21.mdl")
        util.PrecacheModel("models/pwb/weapons/w_vz61.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_m4super90.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_m4a1.mdl")
        util.PrecacheModel("models/pwb/weapons/w_tmp.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_m249paratrooper.mdl")
        util.PrecacheModel("models/pwb/weapons/w_m590a1.mdl")
        util.PrecacheModel("models/pwb/weapons/w_hk416.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_mp5a3.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_mp7.mdl")
        util.PrecacheModel("models/pwb/weapons/w_p90.mdl")
        util.PrecacheModel("models/pwb/weapons/w_cz75.mdl")
        util.PrecacheModel("models/bydistac/weapons/w_shot_m3juper90.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_rpk.mdl")
        util.PrecacheModel("models/weapons/arccw/w_irifle.mdl")
        util.PrecacheModel("models/pwb/weapons/w_spas_12.mdl")
        util.PrecacheModel("models/pwb/weapons/w_uzi.mdl")
        util.PrecacheModel("models/pwb/weapons/w_xm1014.mdl")
        util.PrecacheModel("models/weapons/tfa_ins2/w_doublebarrel_sawnoff.mdl")
        util.PrecacheModel("models/weapons/tfa_ins2/w_doublebarrel.mdl")
        util.PrecacheModel("models/weapons/w_jmod_crossbow.mdl")
        util.PrecacheModel("models/weapons/w_jmod_milkormgl.mdl")
        util.PrecacheModel("models/weapons/w_jmod_at4.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_vectorsmg.mdl")
        util.PrecacheModel("models/pwb2/weapons/w_xm8lmg.mdl")
        util.PrecacheModel("models/weapons/w_knije_t.mdl") -- melees
        util.PrecacheModel("models/weapons/insurgency/w_gurkha.mdl")
        util.PrecacheModel("models/weapons/insurgency/w_marinebayonet.mdl")
        util.PrecacheModel("models/pwb/weapons/w_knife.mdl")
        util.PrecacheModel("models/pwb/weapons/w_tomahawk.mdl")
        util.PrecacheModel("models/weapons/me_sledge/w_me_sledge.mdl")
        util.PrecacheModel("models/weapons/me_crowbar/w_me_crowbar.mdl")
        util.PrecacheModel("models/weapons/me_bat_metal_tracer/w_me_bat_metal.mdl")
        util.PrecacheModel("models/weapons/me_kitknife/w_me_kitknife.mdl")
        util.PrecacheModel("models/weapons/me_hatchet/w_me_hatchet.mdl")
        util.PrecacheModel("models/weapons/me_fubar/w_me_fubar.mdl")
        util.PrecacheModel("models/weapons/me_axe_fire_tracer/w_me_axe_fire.mdl")
        util.PrecacheModel("models/weapons/me_spade/w_me_spade.mdl")
        util.PrecacheModel("models/weapons/w_models/w_jyringe_jroj.mdl") -- meds
        util.PrecacheModel("models/blood_bag/models/blood_bag.mdl")
        util.PrecacheModel("models/bandages.mdl")
        util.PrecacheModel("models/w_models/weapons/w_eq_medkit.mdl")
        util.PrecacheModel("models/bloocobalt/l4d/items/w_eq_adrenaline.mdl")
        util.PrecacheModel("models/w_models/weapons/w_eq_painpills.mdl")
        util.PrecacheModel("models/alusplint.mdl")
    end