--[[
TODO:
 - Easyly to add some appearances: ✔
 - GetModelSex: ✔
--]]

EasyAppearance = EasyAppearance or {}

local EntityMeta = FindMetaTable("Entity")

local Appearances = {
	Male = {
		--["Burgandy Jacket"] = "models/humans/modern/male/sheet_01",
		["#hg_appearance_firefighter"] = "models/humans/modern/male/sheet_02",
		["#hg_appearance_casual2"] = "models/humans/modern/male/sheet_03",
		["#hg_appearance_varsity"] = "models/humans/modern/male/sheet_04",
		["#hg_appearance_c13"] = "models/humans/modern/male/sheet_05",
		["#hg_appearance_redshirt"] = "models/humans/modern/male/sheet_08",
		--["Wood Shirt"] = "models/humans/modern/male/sheet_09",
		["#hg_appearance_punk3"] = "models/humans/modern/male/sheet_10",
		["#hg_appearance_orangetrack"] = "models/humans/modern/male/sheet_11",
		["#hg_appearance_punk2"] = "models/humans/modern/male/sheet_12",
		["#hg_appearance_punk1"] = "models/humans/modern/male/sheet_13",
		["#hg_appearance_greentriped"] = "models/humans/modern/male/sheet_14",
		["#hg_appearance_dawnofthedead"] = "models/humans/modern/male/sheet_16",
		["#hg_appearance_redhoodie"] = "models/humans/modern/male/sheet_17",
		["#hg_appearance_openleather"] = "models/humans/modern/male/sheet_18",
		["#hg_appearance_greensweater"] = "models/humans/modern/male/sheet_20",
		["#hg_appearance_leatherjack"] = "models/humans/modern/male/sheet_21",
		["#hg_appearance_casual1"] = "models/humans/modern/male/sheet_22",
		["#hg_appearance_slavic"] = "models/humans/modern/male/sheet_23",
		["#hg_appearance_closedleather"] = "models/humans/modern/male/sheet_24",
		["#hg_appearance_golfersdelight"] = "models/humans/modern/male/sheet_25",
		["#hg_appearance_sportsjack"] = "models/humans/modern/male/sheet_26",
		["#hg_appearance_denimjack"] = "models/humans/modern/male/sheet_27",
		["#hg_appearance_pufferjack"] = "models/humans/modern/male/sheet_28",
		["#hg_appearance_chemist"] = "models/humans/modern/male/sheet_29",
		["#hg_appearance_openjack"] = "models/humans/modern/male/sheet_30",
		["#hg_appearance_stripped"] = "models/humans/modern/male/sheet_31",
		["#hg_appearance_bornforced"] = "models/humans/modern/male/sheet_32",
		["#hg_appearance_werewolf"] = "models/humans/modern/male/sheet_33",
		["#hg_appearance_magdognuls"] = "models/humans/modern/male/sheet_34",
		["#hg_appearance_hawktuah"] = "models/humans/modern/male/sheet_35",
		["#hg_appearance_jeexp"] = "models/humans/modern/male/sheet_36",
		["#hg_appearance_harrison"] = "models/humans/modern/male/sheet_37",
		["#hg_appearance_homigradcomhater"] = "models/humans/modern/male/sheet_38",
		["#hg_appearance_muricafuckyeah"] = "models/humans/modern/male/sheet_39",
		["#hg_appearance_drunkdriver"] = "models/humans/modern/male/sheet_40",
		["#hg_appearance_realshirt"] = "models/humans/modern/male/sheet_41",
		["#hg_appearance_wolfforher"] = "models/humans/modern/male/sheet_42",
		["#hg_appearance_wolfforhim"] = "models/humans/modern/male/sheet_43",
		["#hg_appearance_meowing"] = "models/humans/modern/male/sheet_44",
		["#hg_appearance_iedlover"] = "models/humans/modern/male/sheet_45",
	},
	Female = {
		["#hg_appearance_casual1"] = "models/humans/modern/female/sheet_01",
		["#hg_appearance_casual2"] = "models/humans/modern/female/sheet_02",
		["#hg_appearance_casual3"] = "models/humans/modern/female/sheet_03",
		["#hg_appearance_casual4"] = "models/humans/modern/female/sheet_04",
		["#hg_appearance_c13"] = "models/humans/modern/female/sheet_05",
		["#hg_appearance_jacket"] = "models/humans/modern/female/sheet_06",
		--["Casual 7"] = "models/humans/modern/female/sheet_07", -- Police Outfit, removed for confusion
		["#hg_appearance_fitnessjacket"] = "models/humans/modern/female/sheet_08",
		["#hg_appearance_casual5"] = "models/humans/modern/female/sheet_09",
		["#hg_appearance_playboy"] = "models/humans/modern/female/sheet_10",
		["#hg_appearance_hellokitty"] = "models/humans/modern/female/sheet_11",
		["#hg_appearance_redsweater"] = "models/humans/modern/female/sheet_12",
		["#hg_appearance_pinksweater"] = "models/humans/modern/female/sheet_13",
		["#hg_appearance_formwinter"] = "models/humans/modern/female/sheet_14",
		["#hg_appearance_leatherjack"] = "models/humans/modern/female/sheet_15"
	}
}

local Models = {
	-- Male
	["Male 01"] = {strPatch = "models/player/group01/male_01.mdl", intSubMat = 3},
	["Male 02"] = {strPatch = "models/player/group01/male_02.mdl", intSubMat = 2},
	["Male 03"] = {strPatch = "models/player/group01/male_03.mdl", intSubMat = 4},
	["Male 04"] = {strPatch = "models/player/group01/male_04.mdl", intSubMat = 4},
	["Male 05"] = {strPatch = "models/player/group01/male_05.mdl", intSubMat = 4},
	["Male 06"] = {strPatch = "models/player/group01/male_06.mdl", intSubMat = 0},
	["Male 07"] = {strPatch = "models/player/group01/male_07.mdl", intSubMat = 4},
	["Male 08"] = {strPatch = "models/player/group01/male_08.mdl", intSubMat = 0},
	["Male 09"] = {strPatch = "models/player/group01/male_09.mdl", intSubMat = 2},
	-- Female
	["Female 01"] = {strPatch = "models/player/group01/female_01.mdl", intSubMat = 2},
	["Female 02"] = {strPatch = "models/player/group01/female_02.mdl", intSubMat = 3},
	["Female 03"] = {strPatch = "models/player/group01/female_03.mdl", intSubMat = 3},
	["Female 04"] = {strPatch = "models/player/group01/female_04.mdl", intSubMat = 1},
	["Female 05"] = {strPatch = "models/player/group01/female_05.mdl", intSubMat = 2},
	["Female 06"] = {strPatch = "models/player/group01/female_06.mdl", intSubMat = 4},
}

local Attachmets = {}

EasyAppearance.Attachmets = Attachmets
EasyAppearance.Models = Models
EasyAppearance.Appearances = Appearances

local sex = {
	[1] = "Male",
	[2] = "Female"
}

EasyAppearance.Sex = sex

function EasyAppearance.GetModelSex(entity)
	local tSubModels = entity:GetSubModels()

	for i = 1, #tSubModels do
		local name = tSubModels[i]["name"]
		if name == "models/m_anm.mdl" then return 1 end
		if name == "models/f_anm.mdl" then return 2 end
	end

	return false
end

function EntityMeta:GetModelSex()
	return EasyAppearance.GetModelSex(self)
end

function EasyAppearance.AddAppearances(intSex, strMame, strTexturePatch)
	if not intSex or not strName or not strTexturePatch then
		print("invalid vars")
		return false
	end

	local strSex = sex[math.Clamp(intSex, 1, 2)]
	EasyAppearance.Appearances[strSex][strName] = strTexturePatch

	return true
end

--[[
	["HatExample"] = {
		strModel = "",
		strMaterial = "",
		strBone = "",
		vPos = Vector( 0, 0, 0 ),
		aAng = Angle( 0, 0, 0 ),
		iSkin = 0,
		strBodyGroups = "0000000"
	}
--]]

function EasyAppearance.AddAttachmet(strName, strModel, strMaterial, strBone, bDrawOnLocal, vPos, vFPos, aAng, aFAng, iSkin, strBodyGroups)
	EasyAppearance.Attachmets[strName] = {
		strModel = strModel,
		strMaterial = strMaterial,
		strBone = strBone,
		vPos = vPos or Vector(0, 0, 0),
		vFPos = vFPos or vPos or Vector(0, 0, 0),
		aAng = aAng or Angle(0, 0, 0),
		aFAng = aFAng or aAng or Angle(0, 0, 0),
		bDrawOnLocal = bDrawOnLocal ~= nil and bDrawOnLocal or bDrawOnLocal == nil and true,
		iSkin = iSkin or 0,
		strBodyGroups = strBodyGroups or "0000000"
	}

	return true
end

local AddAttach = EasyAppearance.AddAttachmet
-- AddAttach("Hat", "ModelPath", "MaterialPath" or nil, Vector(0, 0, 0), Vector(0, 0, 0), Angle(0, 0, 0), Angle(0, 0, 0), 0, "00000")

--[[
    /\_/\
    |*_*| -- this is pluv cat or slugcat idk LOL
    |   |____
    /_|_\____\
--]]


-- uniName, modelPath, materialPath, Bone, ShoulDraw in localPlayer, PosMale, PosFemale, AngMale, AngFemale, Skin, Bodygroups
AddAttach("Gray Cap", "models/modified/hat07.mdl", nil, "ValveBiped.Bip01_Head1", false, Vector(5, 0, 0), Vector(4, 0.1, 0), Angle(0, -80, -90), Angle(0, -80, -90), 0, "00000")
AddAttach("Red Headphones", "models/modified/headphones.mdl", nil, "ValveBiped.Bip01_Head1", false, Vector(2.8, -.2, 0), Vector(1.3, -1, 0), Angle(0, -80, -90), Angle(0, -80, -90), 0, "00000")
AddAttach("Pinkman Hat", "models/modified/hat03.mdl", nil, "ValveBiped.Bip01_Head1", false, Vector(5, 0, 0), Vector(4, 0.1, 0), Angle(0, -80, -90), Angle(0, -80, -90), 0, "00000")
AddAttach("Gray Hat", "models/modified/hat01_fix.mdl", nil, "ValveBiped.Bip01_Head1", false, Vector(5, 0, 0), Vector(4, 0.1, 0), Angle(0, -80, -90), Angle(0, -80, -90), 0, "00000")
AddAttach("Bandana", "models/modified/bandana.mdl", nil, "ValveBiped.Bip01_Head1", false, Vector(-1, -1, 0), Vector(-2, -.9, 0), Angle(0, -80, -90), Angle(0, -80, -90), 0, "00000")
AddAttach("Small Backpack", "models/modified/backpack_3.mdl", nil, "ValveBiped.Bip01_Spine4", false, Vector(-7.5, 4, 0), Vector(-9, 3, 0), Angle(180, -100, -90), Angle(180, -90, -90), 0, "00000")
AddAttach("Big Backpack", "models/modified/backpack_1.mdl", nil, "ValveBiped.Bip01_Spine2", false, Vector(0.4, 3.6, 0), Vector(-1.5, 3.6, 0), Angle(180, -90, -90), Angle(180, -90, -90), 0, "00000")