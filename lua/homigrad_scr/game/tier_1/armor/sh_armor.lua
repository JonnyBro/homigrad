-- Bullet hits only touch the slots of the hit bodypart, everything else (blast, burn, melee) spreads over the whole body
hg.LocationalDmgTypes = {DMG_BULLET, DMG_BUCKSHOT, DMG_AIRBOAT, DMG_SNIPER}
hg.FullBodyDmgTypes = {DMG_CRUSH, DMG_SLASH, DMG_BURN, DMG_VEHICLE, DMG_BLAST, DMG_CLUB, DMG_PLASMA, DMG_ACID, DMG_POISON}
hg.BiologicalDmgTypes = {DMG_NERVEGAS, DMG_RADIATION}

hg.ArmorSlotHealthMults = {
	eyes = .05,
	mouthnose = .05,
	ears = 0,
	head = .18,
	chest = .25,
	back = 0,
	abdomen = .1,
	pelvis = .05,
	waist = 0,
	leftthigh = .04,
	leftcalf = .04,
	rightthigh = .04,
	rightcalf = .04,
	rightshoulder = .04,
	rightforearm = .04,
	leftshoulder = .04,
	leftforearm = .04
}

local BasicArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .999,
	[DMG_CLUB] = .99,
	[DMG_SLASH] = .99,
	[DMG_BULLET] = .98,
	[DMG_BLAST] = .95,
	[DMG_SNIPER] = .9,
	[DMG_AIRBOAT] = .85,
	[DMG_CRUSH] = .75,
	[DMG_VEHICLE] = .65,
	[DMG_BURN] = .65,
	[DMG_PLASMA] = .65,
	[DMG_ACID] = .55
}

local PoorArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .6,
	[DMG_CLUB] = .6,
	[DMG_SLASH] = .6,
	[DMG_BULLET] = .2,
	[DMG_BLAST] = .2,
	[DMG_SNIPER] = .1,
	[DMG_AIRBOAT] = .2,
	[DMG_CRUSH] = .3,
	[DMG_VEHICLE] = .2,
	[DMG_BURN] = .2,
	[DMG_PLASMA] = .1,
	[DMG_ACID] = .1
}

local NonArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .05,
	[DMG_BLAST] = .05,
	[DMG_BULLET] = .05,
	[DMG_SNIPER] = .05,
	[DMG_AIRBOAT] = .05,
	[DMG_CLUB] = .05,
	[DMG_SLASH] = .05,
	[DMG_CRUSH] = .05,
	[DMG_VEHICLE] = .05,
	[DMG_BURN] = .05,
	[DMG_PLASMA] = .05,
	[DMG_ACID] = .05
}

-- keep in mind that all armor model names must be all lower-case
hg.ArmorTable = {
	["GasMask"] = {
		PrintName = "Gas Mask",
		mdl = "models/splinks/kf2/cosmetics/gas_mask.mdl", -- kf2
		slots = {
			eyes = 1,
			mouthnose = 1
		},
		def = table.Inherit({
			[DMG_NERVEGAS] = 1,
			[DMG_RADIATION] = .75
		}, NonArmorProtectionProfile),
		dur = 2,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1),
		pos = Vector(0, .1, 0),
		ang = Angle(100, 180, 90),
		wgt = 5,
		mskmat = "mats_jack_gmod_sprites/vignette_gray.png",
		sndlop = "snds_jack_gmod/mask_breathe.wav",
		ent = "ent_hg_armor_gasmask",
		tgl = {
			pos = Vector(3, 3, 0),
			ang = Angle(190, 180, 90),
			eff = {},
			mskmat = "",
			sndlop = "",
			def = NonArmorProtectionProfile,
			slots = {
				eyes = 0,
				mouthnose = 0
			}
		}
	},
	["BallisticMask"] = {
		PrintName = "Ballistic Mask",
		mdl = "models/jmod/ballistic_mask.mdl", -- csgo misc
		slots = {
			eyes = .8,
			mouthnose = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 4, 0),
		ang = Angle(100, 180, 90),
		wgt = 5,
		dur = 400,
		mskmat = "mats_jack_gmod_sprites/hard_vignette.png",
		ent = "ent_hg_armor_balmask",
		tgl = {
			pos = Vector(-2, 4, 0),
			ang = Angle(170, 180, 90),
			mskmat = "",
			slots = {
				eyes = 0,
				mouthnose = 0
			}
		}
	},
	["Respirator"] = {
		PrintName = "Respirator",
		mdl = "models/jmod/respirator.mdl", -- MGSV
		slots = {
			mouthnose = 1
		},
		def = table.Inherit({
			[DMG_NERVEGAS] = .25,
			[DMG_RADIATION] = .75
		}, NonArmorProtectionProfile),
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1),
		pos = Vector(3.25, 1, 0),
		ang = Angle(100, 180, 90),
		wgt = 5,
		dur = 2,
		sndlop = "snds_jack_gmod/mask_breathe.wav",
		ent = "ent_hg_armor_respirator",
		tgl = {
			def = NonArmorProtectionProfile,
			eff = {},
			slots = {
				mouthnose = 0
			},
			pos = Vector(3.25, -4, 0),
			ang = Angle(110, 180, 90),
			sndlop = ""
		}
	},
	["Light-Helmet"] = {
		PrintName = "Helmet-Light",
		mdl = "models/player/helmet_achhc_black/achhc_black.mdl", -- tarkov
		slots = {
			head = .6
		},
		mskmat = "sprites/mat_jack_hmcd_helmover",
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.07, 1, 1.1),
		pos = Vector(1, -2, 0),
		ang = Angle(-90, 0, -90),
		wgt = 10,
		dur = 200,
		ent = "ent_hg_armor_lhead"
	},
	["Medium-Helmet"] = {
		PrintName = "Helmet-Medium",
		mdl = "models/player/helmet_ulach_black/ulach.mdl", -- tarkov
		slots = {
			head = .8
		},
		mskmat = "sprites/mat_jack_hmcd_helmover",
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1, 1.05),
		pos = Vector(1, -2, 0),
		ang = Angle(-90, 0, -90),
		wgt = 15,
		dur = 300,
		ent = "ent_hg_armor_mhead"
	},
	["Heavy-Helmet"] = {
		PrintName = "Helmet-Heavy",
		mdl = "models/player/helmet_psh97_jeta/jeta.mdl", -- tarkov
		slots = {
			head = 1
		},
		mskmat = "sprites/mat_jack_hmcd_helmover",
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.1, 1, 1.1),
		pos = Vector(1, -3, 0),
		ang = Angle(-90, 0, -90),
		wgt = 20,
		dur = 350,
		ent = "ent_hg_armor_hhead"
	},
	["Riot-Helmet"] = {
		PrintName = "Helmet-Riot",
		mdl = "models/jmod/helmet_riot_heavy.mdl", -- csgo
		slots = {
			head = 0.6,
			eyes = .4,
			mouthnose = .4
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1.1),
		pos = Vector(1, 3.5, 0),
		ang = Angle(-70, 0, -90),
		mskmat = "mats_jack_gmod_sprites/gray_translucent.png",
		wgt = 15,
		dur = 150,
		ent = "ent_hg_armor_riot",
		bdg = {
			[0] = 0
		},
		tgl = {
			mskmat = "",
			slots = {
				head = 0.6,
				eyes = 0,
				mouthnose = 0
			},
			bdg = {
				[0] = 1
			}
		}
	},
	["Heavy-Riot-Helmet"] = {
		PrintName = "Helmet-Heavy Riot",
		mdl = "models/jmod/helmet_riot.mdl",
		slots = {
			head = 0.8,
			eyes = .6,
			mouthnose = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		mskmat = "mats_jack_gmod_sprites/gray_translucent.png",
		siz = Vector(1.1, 1, 1.1),
		pos = Vector(0, 1, 0),
		ang = Angle(-90, 0, -90),
		wgt = 25,
		dur = 250,
		ent = "ent_hg_armor_rioth",
		bdg = {
			[1] = 0
		},
		tgl = {
			mskmat = "",
			slots = {
				head = 0.8,
				eyes = 0,
				mouthnose = 0
			},
			bdg = {
				[1] = 1
			}
		}
	},
	["Ultra-Heavy-Helmet"] = {
		PrintName = "Helmet-UltraHeavy",
		mdl = "models/jmod/helmet_maska.mdl", -- tarkov
		slots = {
			head = 1,
			eyes = 1,
			mouthnose = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1.05, 1.05),
		pos = Vector(1.5, -2, 0),
		ang = Angle(-80, 0, -90),
		wgt = 35,
		dur = 500,
		mskmat = "mats_jack_gmod_sprites/slit_vignette.png",
		ent = "ent_hg_armor_maska",
		bdg = {
			[1] = 0
		},
		tgl = {
			slots = {
				head = 1,
				eyes = 0,
				mouthnose = 0
			},
			bdg = {
				[1] = 1
			},
			mskmat = ""
		}
	},
	["Metal Bucket"] = {
		PrintName = "BUCKET",
		mdl = "models/props_junk/metalbucket01a.mdl", -- hl2
		slots = {
			head = 1,
			eyes = .75
		},
		def = PoorArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(.75, .75, .75),
		pos = Vector(1, 5, 0),
		ang = Angle(90, 10, 0),
		wgt = 10,
		dur = 100,
		mskmat = "mats_jack_gmod_sprites/three-quarter-from-top-blocked.png",
		ent = "ent_hg_armor_metalbucket"
	},
	["Metal Pot"] = {
		PrintName = "COOKIN POT",
		mdl = "models/props_interiors/pot02a.mdl", -- hl2
		clr = {
			r = 255,
			g = 255,
			b = 255
		},
		slots = {
			head = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.15, 1.15, 1.15),
		pos = Vector(5.2, 7.2, -3),
		ang = Angle(80, 20, 30),
		wgt = 20,
		dur = 150,
		mskmat = "mats_jack_gmod_sprites/one-quarter-from-top-blocked.png",
		ent = "ent_hg_armor_metalpot"
	},
	["Ceramic Pot"] = {
		PrintName = "CERAMIC POT",
		mdl = "models/props_junk/terracotta01.mdl", -- hl2
		clr = {
			r = 255,
			g = 255,
			b = 255
		},
		slots = {
			head = .9,
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(.61, .61, .61),
		pos = Vector(-2, 11, .5),
		ang = Angle(90, 20, 0),
		wgt = 15,
		dur = 10,
		mskmat = "mats_jack_gmod_sprites/one-quarter-from-top-blocked.png",
		ent = "ent_hg_armor_ceramicpot"
	},
	["Traffic Cone"] = {
		PrintName = "CONE",
		mdl = "models/props_junk/trafficcone001a.mdl", -- hl2
		mat = "models/mat_jack_gmod_trafficcone",
		clr = {
			r = 240,
			g = 120,
			b = 0
		},
		slots = {
			head = .7,
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(.85, .85, .85),
		pos = Vector(-3.5, 15.5, 0),
		ang = Angle(-90, 18, 0),
		wgt = 4,
		dur = 10,
		mskmat = "mats_jack_gmod_sprites/one-quarter-from-top-blocked.png",
		ent = "ent_hg_armor_trafficcone"
	},
	["Light-Vest"] = {
		PrintName = "Vest-Light",
		mdl = "models/player/armor_paca/paca.mdl", -- tarkov
		slots = {
			chest = .4,
			abdomen = .3
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1, 1.05, .9),
		pos = Vector(-2.5, -4.5, 0),
		ang = Angle(-90, 0, 90),
		wgt = 5,
		dur = 250,
		ent = "ent_hg_armor_ltorso",
	},
	["Medium-Light-Vest"] = {
		PrintName = "Vest-Medium-Light",
		mdl = "models/player/armor_trooper/trooper.mdl", -- tarkov
		slots = {
			chest = .6,
			abdomen = .4
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1.05, 1.05, .95),
		pos = Vector(-3, -4.5, 0),
		ang = Angle(-90, 0, 90),
		wgt = 10,
		dur = 450,
		ent = "ent_hg_armor_mltorso",
	},
	["Medium-Vest"] = {
		PrintName = "Vest-Medium",
		mdl = "models/player/armor_gjel/gjel.mdl", -- tarkov
		slots = {
			chest = .7,
			abdomen = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1.05, 1.05, 1),
		pos = Vector(-2.5, -7, 0),
		ang = Angle(-90, 0, 90),
		wgt = 20,
		dur = 625,
		ent = "ent_hg_armor_mtorso",
	},
	["Medium-Heavy-Vest"] = {
		PrintName = "Vest-Medium-Heavy",
		mdl = "models/player/armor_6b13_killa/6b13_killa.mdl", -- tarkov
		slots = {
			chest = .8,
			abdomen = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1.05, 1.05, 1),
		pos = Vector(-4.5, -12, 0),
		ang = Angle(-85, 0, 90),
		wgt = 40,
		dur = 725,
		ent = "ent_hg_armor_mhtorso",
	},
	["Heavy-Vest"] = {
		PrintName = "Vest-Heavy",
		mdl = "models/jmod/heavy_armor.mdl", -- csgo hydra
		slots = {
			chest = 1,
			abdomen = .9
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(.9, .9, 1),
		pos = Vector(-3, 2.5, 0),
		ang = Angle(-85, 0, 90),
		wgt = 80,
		dur = 900,
		ent = "ent_hg_armor_htorso"
	},
	["Pelvis-Panel"] = {
		PrintName = "Pelvis Panel",
		mdl = "models/jmod/pelviscover.mdl", -- csgo misc
		slots = {
			pelvis = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Pelvis",
		siz = Vector(1.5, 1.4, 1.8),
		pos = Vector(6, 0, 5),
		ang = Angle(90, -90, 0),
		wgt = 10,
		dur = 350,
		ent = "ent_hg_armor_spelvis"
	},
	["Light-Left-Shoulder"] = {
		PrintName = "Shoulder-Light (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlbicep.mdl", -- aegis
		slots = {
			leftshoulder = .5
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 0, -.5),
		ang = Angle(-90, -90, -90),
		wgt = 5,
		dur = 200,
		ent = "ent_hg_armor_llshoulder"
	},
	["Heavy-Left-Shoulder"] = {
		PrintName = "Shoulder-Heavy (L)",
		mdl = "models/jmod/heavy_left_armor_pad.mdl", -- csgo hydra
		slots = {
			leftshoulder = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 4, 0),
		ang = Angle(90, -20, 90),
		wgt = 15,
		dur = 300,
		ent = "ent_hg_armor_hlshoulder"
	},
	["Light-Right-Shoulder"] = {
		PrintName = "Shoulder-Light (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrbicep.mdl", -- aegis
		slots = {
			rightshoulder = .5
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 0, .5),
		ang = Angle(-90, -90, -90),
		wgt = 5,
		dur = 200,
		ent = "ent_hg_armor_lrshoulder"
	},
	["Heavy-Right-Shoulder"] = {
		PrintName = "Shoulder-Heavy (R)",
		mdl = "models/jmod/heavy_right_armor_pad.mdl", -- csgo hydra
		slots = {
			rightshoulder = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 4, 0),
		ang = Angle(90, 20, 90),
		wgt = 15,
		dur = 300,
		ent = "ent_hg_armor_hrshoulder"
	},
	["Left-Forearm"] = {
		PrintName = "Forearm (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlforearm.mdl", -- aegis
		slots = {
			leftforearm = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Forearm",
		siz = Vector(1.1, 1, 1),
		pos = Vector(0, 0, -.5),
		ang = Angle(0, -90, -50),
		wgt = 10,
		dur = 250,
		ent = "ent_hg_armor_slforearm",
	},
	["Right-Forearm"] = {
		PrintName = "Forearm (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrforearm.mdl", -- aegis
		slots = {
			rightforearm = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Forearm",
		siz = Vector(1.1, 1, 1),
		pos = Vector(-.5, 0, .5),
		ang = Angle(0, -90, 50),
		wgt = 10,
		dur = 250,
		ent = "ent_hg_armor_srforearm",
	},
	["Light-Left-Thigh"] = {
		PrintName = "Thigh-Light (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlthigh.mdl", -- aegis
		slots = {
			leftthigh = .5
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Thigh",
		siz = Vector(.9, 1, 1.05),
		pos = Vector(-.5, 0, -1.5),
		ang = Angle(90, -85, 110),
		wgt = 10,
		dur = 200,
		ent = "ent_hg_armor_llthigh",
	},
	["Heavy-Left-Thigh"] = {
		PrintName = "Thigh-Heavy (L)",
		mdl = "models/jmod/heavy_left_thigh_armor.mdl", -- csgo hydra
		slots = {
			leftthigh = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Thigh",
		siz = Vector(0.9, 1, 1),
		pos = Vector(2, 10, 0),
		ang = Angle(-90, 180, 0),
		wgt = 25,
		dur = 250,
		ent = "ent_hg_armor_hlthigh"
	},
	["Light-Right-Thigh"] = {
		PrintName = "Thigh-Light (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrthigh.mdl", -- aegis
		slots = {
			rightthigh = .5
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Thigh",
		siz = Vector(.9, 1, 1.05),
		pos = Vector(.5, 0, 1),
		ang = Angle(90, -95, 80),
		wgt = 10,
		dur = 200,
		ent = "ent_hg_armor_lrthigh",
	},
	["Heavy-Right-Thigh"] = {
		PrintName = "Thigh-Heavy (R)",
		mdl = "models/jmod/heavy_right_thigh_armor.mdl", -- csgo hydra
		slots = {
			rightthigh = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Thigh",
		siz = Vector(0.9, 1, 1),
		pos = Vector(2, 10, 0),
		ang = Angle(-90, 180, 0),
		wgt = 25,
		dur = 250,
		ent = "ent_hg_armor_hrthigh"
	},
	["Left-Calf"] = {
		PrintName = "Calf (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlcalf.mdl", -- aegis
		slots = {
			leftcalf = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Calf",
		siz = Vector(1, 1, 1),
		pos = Vector(-1.5, -1, -.5),
		ang = Angle(-180, -83, -180),
		wgt = 15,
		dur = 300,
		ent = "ent_hg_armor_slcalf"
	},
	["Right-Calf"] = {
		PrintName = "Calf (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrcalf.mdl", -- aegis
		slots = {
			rightcalf = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Calf",
		siz = Vector(1, 1, 1),
		pos = Vector(-1.5, -1, .5),
		ang = Angle(-180, -83, -180),
		wgt = 15,
		dur = 300,
		ent = "ent_hg_armor_srcalf"
	}
}

function hg.GetArmorInfo(item)
	local info = hg.ArmorTable[item.name]
	if not info or not (item.tgl and info.tgl) then return info end

	info = table.Copy(info)

	-- table.Merge skips empty tables, but an empty toggled table must replace the original
	for k, v in pairs(info.tgl) do
		info[k] = istable(v) and table.IsEmpty(v) and {} or v
	end

	return info
end

function hg.GetArmorInSlot(ply, slot)
	local armor = ply.hgArmor
	if not armor then return end

	for id, item in pairs(armor.items) do
		local info = hg.ArmorTable[item.name]
		if info and info.slots[slot] then return id, item, info end
	end
end

for name, info in pairs(hg.ArmorTable) do
	scripted_ents.Register({
		Base = "ent_hg_armor",
		PrintName = info.PrintName or name,
		Spawnable = true,
		Category = "Homigrad Armor",
		ArmorName = name
	}, info.ent)
end
