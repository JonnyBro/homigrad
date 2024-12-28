AddCSLuaFile()
JMod = JMod or {}
-- EZ radio stations
JMod.EZ_RADIO_STATIONS = {}
JMod.EZ_STATION_STATE_READY = 2
JMod.EZ_STATION_STATE_DELIVERING = 3
JMod.EZ_STATION_STATE_BUSY = 4

-- resource definitions --
JMod.EZ_RESOURCE_TYPES = {
	WATER = "water",
	WOOD = "wood",
	ORGANICS = "organics",
	OIL = "oil",
	GAS = "gas",
	POWER = "power",
	DIAMOND = "diamond",
	COAL = "coal",
	--
	IRONORE = "iron ore",
	LEADORE = "lead ore",
	ALUMINUMORE = "aluminum ore",
	COPPERORE = "copper ore",
	TUNGSTENORE = "tungsten ore",
	TITANIUMORE = "titanium ore",
	SILVERORE = "silver ore",
	GOLDORE = "gold ore",
	URANIUMORE = "uranium ore",
	PLATINUMORE = "platinum ore",
	--
	STEEL = "steel",
	LEAD = "lead",
	ALUMINUM = "aluminum",
	COPPER = "copper",
	TUNGSTEN = "tungsten",
	TITANIUM = "titanium",
	SILVER = "silver",
	GOLD = "gold",
	URANIUM = "uranium",
	PLATINUM = "platinum",
	--
	FUEL = "fuel",
	PLASTIC = "plastic",
	RUBBER = "rubber",
	GLASS = "glass",
	CLOTH = "cloth",
	CERAMIC = "ceramic",
	PAPER = "paper",
	--
	AMMO = "ammo",
	MUNITIONS = "munitions",
	PROPELLANT = "propellant",
	EXPLOSIVES = "explosives",
	MEDICALSUPPLIES = "medical supplies",
	CHEMICALS = "chemicals",
	NUTRIENTS = "nutrients",
	COOLANT = "coolant",
	--
	BASICPARTS = "basic parts",
	PRECISIONPARTS = "precision parts",
	ADVANCEDTEXTILES = "advanced textiles",
	ADVANCEDPARTS = "advanced parts",
	FISSILEMATERIAL = "fissile material",
	--
	ANTIMATTER = "antimatter"
}

JMod.ResourceToIndex = {}
JMod.IndexToResource = {}

for keyNumber, keyName in pairs(table.GetKeys(JMod.EZ_RESOURCE_TYPES)) do
	local value = JMod.EZ_RESOURCE_TYPES[keyName]
	JMod.ResourceToIndex[value] = keyNumber
	JMod.IndexToResource[keyNumber] = value
end

JMod.EZ_RESOURCE_TYPE_ICONS = {}
JMod.EZ_RESOURCE_TYPE_ICONS_SMOL = {}

for k, v in pairs(JMod.EZ_RESOURCE_TYPES) do
	JMod.EZ_RESOURCE_TYPE_ICONS[v] = Material("ez_resource_icons/" .. v .. ".png")
	JMod.EZ_RESOURCE_TYPE_ICONS_SMOL[v] = Material("ez_resource_icons/" .. v .. " smol.png")
end

JMod.EZ_RESOURCE_ENTITIES = {
	/*[JMod.EZ_RESOURCE_TYPES.WATER] = "ent_jack_gmod_ezwater",
	[JMod.EZ_RESOURCE_TYPES.WOOD] = "ent_jack_gmod_ezwood",
	[JMod.EZ_RESOURCE_TYPES.ORGANICS] = "ent_jack_gmod_ezorganics",
	[JMod.EZ_RESOURCE_TYPES.OIL] = "ent_jack_gmod_ezoil",
	[JMod.EZ_RESOURCE_TYPES.GAS] = "ent_jack_gmod_ezgas",
	[JMod.EZ_RESOURCE_TYPES.POWER] = "ent_jack_gmod_ezbattery",
	[JMod.EZ_RESOURCE_TYPES.DIAMOND] = "ent_jack_gmod_ezdiamond",
	[JMod.EZ_RESOURCE_TYPES.COAL] = "ent_jack_gmod_ezcoal",
	[JMod.EZ_RESOURCE_TYPES.IRONORE] = "ent_jack_gmod_ezironore",
	[JMod.EZ_RESOURCE_TYPES.LEADORE] = "ent_jack_gmod_ezleadore",
	[JMod.EZ_RESOURCE_TYPES.ALUMINUMORE] = "ent_jack_gmod_ezaluminumore",
	[JMod.EZ_RESOURCE_TYPES.COPPERORE] = "ent_jack_gmod_ezcopperore",
	[JMod.EZ_RESOURCE_TYPES.TUNGSTENORE] = "ent_jack_gmod_eztungstenore",
	[JMod.EZ_RESOURCE_TYPES.TITANIUMORE] = "ent_jack_gmod_eztitaniumore",
	[JMod.EZ_RESOURCE_TYPES.SILVERORE] = "ent_jack_gmod_ezsilverore",
	[JMod.EZ_RESOURCE_TYPES.GOLDORE] = "ent_jack_gmod_ezgoldore",
	[JMod.EZ_RESOURCE_TYPES.URANIUMORE] = "ent_jack_gmod_ezuraniumore",
	[JMod.EZ_RESOURCE_TYPES.PLATINUMORE] = "ent_jack_gmod_ezplatinumore",
	[JMod.EZ_RESOURCE_TYPES.STEEL] = "ent_jack_gmod_ezsteel",
	[JMod.EZ_RESOURCE_TYPES.LEAD] = "ent_jack_gmod_ezlead",
	[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = "ent_jack_gmod_ezaluminum",
	[JMod.EZ_RESOURCE_TYPES.COPPER] = "ent_jack_gmod_ezcopper",
	[JMod.EZ_RESOURCE_TYPES.TUNGSTEN] = "ent_jack_gmod_eztungsten",
	[JMod.EZ_RESOURCE_TYPES.TITANIUM] = "ent_jack_gmod_eztitanium",
	[JMod.EZ_RESOURCE_TYPES.SILVER] = "ent_jack_gmod_ezsilver",
	[JMod.EZ_RESOURCE_TYPES.GOLD] = "ent_jack_gmod_ezgold",
	[JMod.EZ_RESOURCE_TYPES.URANIUM] = "ent_jack_gmod_ezuranium",
	[JMod.EZ_RESOURCE_TYPES.PLATINUM] = "ent_jack_gmod_ezplatinum",
	[JMod.EZ_RESOURCE_TYPES.FUEL] = "ent_jack_gmod_ezfuel",
	[JMod.EZ_RESOURCE_TYPES.PLASTIC] = "ent_jack_gmod_ezplastic",
	[JMod.EZ_RESOURCE_TYPES.RUBBER] = "ent_jack_gmod_ezrubber",
	[JMod.EZ_RESOURCE_TYPES.GLASS] = "ent_jack_gmod_ezglass",
	[JMod.EZ_RESOURCE_TYPES.CLOTH] = "ent_jack_gmod_ezcloth",
	[JMod.EZ_RESOURCE_TYPES.CERAMIC] = "ent_jack_gmod_ezceramic",
	[JMod.EZ_RESOURCE_TYPES.PAPER] = "ent_jack_gmod_ezpaper",
	[JMod.EZ_RESOURCE_TYPES.AMMO] = "ent_jack_gmod_ezammo",
	[JMod.EZ_RESOURCE_TYPES.MUNITIONS] = "ent_jack_gmod_ezmunitions",
	[JMod.EZ_RESOURCE_TYPES.PROPELLANT] = "ent_jack_gmod_ezpropellant",
	[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES] = "ent_jack_gmod_ezexplosives",
	[JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES] = "ent_jack_gmod_ezmedsupplies",
	[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = "ent_jack_gmod_ezchemicals",
	[JMod.EZ_RESOURCE_TYPES.NUTRIENTS] = "ent_jack_gmod_eznutrients",
	[JMod.EZ_RESOURCE_TYPES.COOLANT] = "ent_jack_gmod_ezcoolant",
	[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = "ent_jack_gmod_ezbasicparts",
	[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = "ent_jack_gmod_ezprecparts",
	[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES] = "ent_jack_gmod_ezadvtextiles",
	[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS] = "ent_jack_gmod_ezadvparts",
	[JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL] = "ent_jack_gmod_ezfissilematerial",*/
	[JMod.EZ_RESOURCE_TYPES.ANTIMATTER] = "ent_jack_gmod_ezantimatter"
}

for k, v in pairs({
	"models/squad/sf_tris/sf_tri8x8.mdl",
	"models/squad/sf_tris/sf_tri7x7.mdl",
	"models/squad/sf_tris/sf_tri6x6.mdl",
	"models/squad/sf_tris/sf_tri5x5.mdl",
	"models/squad/sf_tris/sf_tri4x4.mdl",
	"models/squad/sf_tris/sf_tri3x3.mdl",
	"models/squad/sf_tris/sf_tri2x2.mdl",
	"models/squad/sf_tris/sf_tri1x1.mdl",
}) do
	util.PrecacheModel(v)
end

JMod.EZ_GRADE_BASIC = 1
JMod.EZ_GRADE_COPPER = 2
JMod.EZ_GRADE_SILVER = 3
JMod.EZ_GRADE_GOLD = 4
JMod.EZ_GRADE_PLATINUM = 5

JMod.EZ_GRADE_BUFFS = {1, 1.25, 1.5, 1.75, 2}

JMod.EZ_GRADE_NAMES = {"basic", "copper", "silver", "gold", "platinum"}

JMod.EZ_GRADE_MATS = {Material("models/mats_jack_grades/1"), Material("models/mats_jack_grades/2"), Material("models/mats_jack_grades/3"), Material("models/mats_jack_grades/4"), Material("models/mats_jack_grades/5")}

JMod.EZ_GRADE_UPGRADE_COSTS = {.5, 1, 1.5, 2}

JMod.EZ_UPGRADE_RESOURCE_BLACKLIST = {}

JMod.EZ_GRADE_BUFFS = {1, 1.25, 1.5, 1.75, 2}

JMod.EZ_GRADE_NAMES = {"basic", "copper", "silver", "gold", "platinum"}

JMod.EZ_GRADE_UPGRADE_COSTS = {.5, 1, 1.5, 2}

JMod.EZ_UPGRADE_RESOURCE_BLACKLIST = {}

JMod.EZ_STATE_BROKEN = -1
JMod.EZ_STATE_OFF = 0
JMod.EZ_STATE_ON = 1
JMod.EZ_STATE_PRIMED = 2
JMod.EZ_STATE_ARMING = 3
JMod.EZ_STATE_ARMED = 4
JMod.EZ_STATE_WARNING = 5

JMod.EZ_HAZARD_PARTICLES = {
	["ent_jack_gmod_ezgasparticle"] = {JMod.EZ_RESOURCE_TYPES.CHEMICALS, .5},
	["ent_jack_gmod_ezvirusparticle"] = {JMod.EZ_RESOURCE_TYPES.CHEMICALS, .1},
	["ent_jack_gmod_ezfalloutparticle"] = {JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL, .2}
}

JMod.RadiationShieldingValues = {
	[MAT_METAL] = .2,
	[MAT_CONCRETE] = .15,
	[MAT_DIRT] = .1,
	[MAT_GRASS] = .1,
	[MAT_SAND] = .07,
	[MAT_SNOW] = .07,
	[MAT_TILE] = .06,
	[MAT_WOOD] = .05,
	[MAT_GLASS] = .05,
	[MAT_PLASTIC] = .04
}

JMod.MapSolarPowerModifiers = {
	{
		{"clouds_", "_clouds", "cloudy_", "_cloudy"},
		.5
	},
	{
		{"stormy_", "storm_", "_storm", "_shady", "shady_", "_marsh", "marsh_"},
		.2
	},
	{
		{"_night", "night_"},
		0
	}
}

JMod.HitMatColors = {
	[MAT_ANTLION] = {Color(194, 193, 109)},
	[MAT_BLOODYFLESH] = {Color(116, 57, 50)},
	[MAT_CONCRETE] = {Color(202, 202, 202)},
	[MAT_DIRT] = {Color(142, 132, 122)},
	[MAT_EGGSHELL] = {Color(255, 255, 230)},
	[MAT_FLESH] = {Color(136, 64, 64)},
	[MAT_GRATE] = {Color(148, 132, 122)},
	[MAT_ALIENFLESH] = {Color(220, 31, 31)},
	[MAT_SNOW] = {Color(242, 242, 242), "models/debug/debugwhite"},
	[MAT_PLASTIC] = {Color(242, 242, 242)},
	[MAT_METAL] = {Color(144, 124, 110)},
	[MAT_SAND] = {Color(244, 222, 197)},
	[MAT_FOLIAGE] = {Color(67, 72, 40)},
	[MAT_COMPUTER] = {Color(242, 242, 242)},
	[MAT_SLOSH] = {Color(108, 85, 58)},
	[MAT_TILE] = {Color(255, 255, 230)},
	[MAT_GRASS] = {Color(134, 158, 93)},
	[MAT_VENT] = {Color(144, 124, 110)},
	[MAT_WOOD] = {Color(190, 171, 141)},
	[MAT_DEFAULT] = {Color(128, 128, 128)},
	[MAT_GLASS] = {Color(200, 200, 255)},
	[MAT_WARPSHIELD] = {Color(255, 255, 255)}
}

include("jmod/sh_locales.lua")
AddCSLuaFile("jmod/sh_locales.lua")

for i, f in pairs(file.Find("jmod/*.lua", "LUA")) do
	if string.Left(f, 3) == "sv_" then
		if SERVER then
			include("jmod/" .. f)
		end
	elseif string.Left(f, 3) == "cl_" then
		if CLIENT then
			include("jmod/" .. f)
		else
			AddCSLuaFile("jmod/" .. f)
		end
	elseif string.Left(f, 3) == "sh_" then
		AddCSLuaFile("jmod/" .. f)
		include("jmod/" .. f)
	else
		print("JMod detected unaccounted-for lua file '" .. f .. "'-check prefixes!")
	end
end