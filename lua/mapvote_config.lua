-- Time in seconds until the mapvote is over from
-- when it starts.
SolidMapVote["Config"]["Length"] = 25

-- The time in seconds that the vote will stay on the screen
-- after the winning map has been chosen.
SolidMapVote["Config"]["Post Vote Length"] = 5

-- This option controls the size of the map vote buttons.
-- This will effect how the images look. If your switching from tall to
-- the square option, then the images should look fine. Vice Versa you'll
-- need to get some new pictures because up scaling small images up looks like butt.
-- 1 = Tall and skinny vote buttons
-- 2 = Square vote buttons
SolidMapVote["Config"]["Map Button Size"] = 0.5

-- This option allows you to set a time for when the map vote will
-- appear after. The first option must be set to true, then the second
-- option controls how long before it comes up in seconds. Simply math
-- can be used to control the length. The last option sets how long before
-- the vote pops up to show a reminder that it is going to happen.
SolidMapVote["Config"]["Enable Vote Autostart"] = false
SolidMapVote["Config"]["Vote Autostart Delay"] = 60 * 60 -- 60 Minutes
SolidMapVote["Config"]["Autostart Reminder"] = 3 * 60 -- 3 minutes
SolidMapVote["Config"]["Time Left Commands"] = {"!timeleft", "/timeleft", ".timeleft"}

-- This it the prefix for maps you want to unclude into
-- the possible maps for the mapvote.
-- List of typical gamemodes prefixes.
-- ttt  = Trouble in Terrorist Town
-- bhop = Bunny Hop
-- surf = Surf
-- hmcd = Homicide
-- rp   = Role Play
SolidMapVote["Config"]["Map Prefix"] = {"ttt", "rp", "gm", "mu", "hmcd", "de", "cs"}

local namecolor = {
	default = COLOR_WHITE,
	servermanager = Color(255, 50, 55),
	owner = Color(0, 227, 255),
	admin = Color(0, 191, 255),
	veteran = Color(255, 20, 147),
	moderator = Color(124, 252, 0),
	supporter = Color(255, 225, 0),
	servertreuer = Color(178, 34, 34),
	nutzer = Color(65, 105, 225),
	user = Color(230, 230, 250)
}

-- Use this function to give specific players or groups different colored
-- avatar borders on the map vote.
SolidMapVote["Config"]["Avatar Border Color"] = function(ply)
	if ply:IsUserGroup("servermanager") then return HSVToColor(math.sin(2 * RealTime()) * 128 + 127, 1, 1) end
	if ply:IsUserGroup("servertreuer") then return namecolor.servertreuer end

	-- This is the default color
	return color_white
end

-- Use this function to give players more vote power than others.
-- I would personally keep all players at the same power because
-- I beleive in equal vote power, but this is up to you.
SolidMapVote["Config"]["Vote Power"] = function(ply)
	if ply:IsAdmin() then return 1 end -- You can make admin's votes more powerfull

	--[[ Give our supporters the big benefits!
	if ply:IsUserGroup("supporterplus") then
		return 2
	elseif ply:IsUserGroup("sponsor") then
		return 3
	else
		return 1
	end --]]

	-- Default vote power
	-- Would keep this at 1, unless you know what your doing (you"re*)
	return 1
end

-- Enabling this option will give greater a chance to maps
-- that are played less often to be selected in the vote.
-- Disabling it will let the map vote randomly choose maps for the vote.
SolidMapVote["Config"]["Fair Map Recycling"] = true

-- Setting this to true will display on the map vote button how many
-- times the map was played in the past.
SolidMapVote["Config"]["Show Map Play Count"] = true

-- Setting the option below to true will allow you to manually set the
-- map pool using the table below. Only the maps inside the table will
-- be able to be chosen for the vote.
SolidMapVote["Config"]["Manual Map Pool"] = true
SolidMapVote["Config"]["Map Pool"] = {
	"cs_insertion2_dusk",
	"cs_office-unlimited",
	"freeway_thicc_v3",
	"gm_abandoned_factory",
	"gm_apartments_hl2",
	"gm_assault_sandbox",
	"gm_building",
	"gm_grant_street",
	"gm_hmcd_rooftops",
	"gm_kleinercomcenter",
	"gm_paradise_resort",
	"gm_wick",
	"mu_smallotown_v2_snow",
	"tdm_city18",
	"ttt_airbus_b3",
	"ttt_amsterville_open",
	"ttt_blackmesa_bahpu",
	"ttt_clue_2022",
	"ttt_fastfood_a6",
	"ttt_grovestreet_a13",
	"ttt_ile_v4",
	"ttt_mc_island_2013",
	"ttt_minecraft_b5",
	"ttt_minecraftcity_v4",
	"ttt_terrortrain_2020_b5",
	"zavod",
	"zs_adrift_v4",

	-- "ttt_freeway_rain",
	-- "dm_steamlab",
	-- "gm_lilys_bedroom",
	-- "mu_smallotown_v2_13",
	-- "ph_scotch",
	-- "ttt_bank_change",

	-- Maps that need fixing
	-- "gm_church", -- Requires Checks for info_player spawns to be removed
	-- "ttt_pizzeria", -- Buggy NPCs and Players
}

SolidMapVote["Config"]["Construct Map Pool"] = {"gm_construct", "gm_flatgrass", "gm_bigcity_winter_day"}

-- Allow players to use their mics while in the mapvote
SolidMapVote["Config"]["Enable Voice"] = true

-- Allow players to use the chat box while in the mapvote
SolidMapVote["Config"]["Enable Chat"] = false

-- Here you can specify what players can force the mapvote to appear.
SolidMapVote["Config"]["Force Vote Permission"] = function(ply) return ply:IsAdmin() end

-- These commands can be used by players specified above to
-- start the mapvote regarless of the amount of players that rtv
SolidMapVote["Config"]["Force Vote Commands"] = {"!forcertv", "/forcertv", ".forcertv"}

-- This is the percentage of players that need to rtv in order for the vote
-- to come up
SolidMapVote["Config"]["RTV Percentage"] = 0.6

-- This is the time in seconds that must pass before players can begin to RTV
SolidMapVote["Config"]["RTV Delay"] = 60

-- If this is set to true, players will be able to remove their RTV
-- by typing the RTV command again.
SolidMapVote["Config"]["Enable UnVote"] = true

-- These commands will add to rocking the vote.
SolidMapVote["Config"]["Vote Commands"] = {"!rtv", "/rtv", ".rtv"}

-- Set this option to true if you want to ignore the
-- prefix and just use all the maps in your maps folder.
SolidMapVote["Config"]["Ignore Prefix"] = true

-- These commands will open the nomination menu
SolidMapVote["Config"]["Nomination Commands"] = {"!nominate", "/nominate", ".nominate"}

-- Set this option to true if you want players to be able to
-- nominate maps.
SolidMapVote["Config"]["Allow Nominations"] = true

-- You can use this function to only allow certain players to be able to
-- use the nomination system. Open a support ticket if you need assistance
-- setting this up.
SolidMapVote["Config"]["Nomination Permissions"] = function(ply) return true end

-- Set this to true if you want the option to extend the map on the vote
-- Set to false to disable
SolidMapVote["Config"]["Enable Extend"] = true
SolidMapVote["Config"]["Extend Image"] = "http://i.imgur.com/zzBeMid.png"

-- Set this to true if you want the option to choose a random map
-- Set to false to disable
SolidMapVote["Config"]["Enable Random"] = false
-- This option controls how the random button works
-- 1 = Random map will be selected from the maps on the vote menu
-- 2 = Random map will be selected from the entire map pool
SolidMapVote["Config"]["Random Mode"] = 2
SolidMapVote["Config"]["Random Image"] = "http://i.imgur.com/oqeqWhl.png"

-- This is the image for maps that are missing an image
SolidMapVote["Config"]["Missing Image"] = ""
SolidMapVote["Config"]["Missing Image Size"] = {
	width = 1920,
	height = 1080
}

-- In this table you can add information for the map to make it more
-- appealing on the mapvote.
SolidMapVote["Config"]["Specific Maps"] = {
	{
		filename = "ttt_minecraft_b5",
		displayname = "Minecraft B5",
		image = "https://i.imgur.com/u2pFlcs.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_wick",
		displayname = "Wick's House",
		image = "https://i.imgur.com/qPwmEke.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_church",
		displayname = "Country Church",
		image = "https://i.imgur.com/AjtJ3NW.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "mu_smallotown_v2_snow",
		displayname = "Small Town (Snow)",
		image = "https://i.imgur.com/xquWM5T.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_terminal_v1a",
		displayname = "Terminal",
		image = "https://i.imgur.com/3DZBDGS.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_deschool",
		displayname = "School",
		image = "https://i.imgur.com/JoPG7Wm.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_freeway_rain",
		displayname = "Freeway",
		image = "https://i.imgur.com/3CFCdky.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_freeway_spacetunnel",
		displayname = "Freeway (Space Tunnel)",
		image = "materials/levels/minecraftb5.jpg",
		width = 1920,
		height = 1080
	},
	{
		filename = "hmcd_aircraft",
		displayname = "Floating Ship",
		image = "https://i.imgur.com/j9Ahytp.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_fastfood_a6",
		displayname = "Fastfood",
		image = "https://i.imgur.com/AZmGWhd.jpeg",
		width = 1920,
		height = 1080
	},
	--[[
	{
		filename = "ttt_clue_xmas",
		displayname = "Clue (Christmas)",
		image = "materials/levels/minecraftb5.jpg",
		width = 1920,
		height = 1080
	}, --]]
	{
		filename = "ttt_minecraftcity_v4",
		displayname = "Minecraft City",
		image = "https://i.imgur.com/LGlZOMT.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_winterplant_v4",
		displayname = "Winter Power Plant",
		image = "materials/levels/minecraftb5.jpg",
		width = 1920,
		height = 1080
	},
	{
		filename = "dm_lockdown",
		displayname = "Nova Prospekt Lockdown",
		image = "https://i.imgur.com/iykF5Ji.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "dm_overwatch",
		displayname = "City 17's Streets",
		image = "https://i.imgur.com/PzfgnHc.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "dm_resistance",
		displayname = "Resistance HQ",
		image = "https://i.imgur.com/ZPXmjle.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "dm_underpass",
		displayname = "City 17 Underpass",
		image = "https://i.imgur.com/oFzdbq3.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "dm_steamlab",
		displayname = "Steam HQ",
		image = "https://i.imgur.com/2nuVKJr.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "cs_office",
		displayname = "Office",
		image = "https://i.imgur.com/8kVbpdc.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "de_dust2",
		displayname = "Dust II",
		image = "https://i.imgur.com/09vBwAA.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_retreat",
		displayname = "Antartica Facility",
		image = "https://i.imgur.com/aUCTqLH.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_airbus_b3",
		displayname = "Airbus",
		image = "https://i.imgur.com/QZBCtOb.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_grovestreet_a13",
		displayname = "Grove Street",
		image = "https://i.imgur.com/1w3FxcH.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_liminal_hotel",
		displayname = "Liminal Hotel",
		image = "https://i.imgur.com/olQX174.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_terrortrain_2020_b5",
		displayname = "Terror Train",
		image = "https://i.imgur.com/HJNGC9p.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_abandoned_factory",
		displayname = "Abandoned Factory",
		image = "https://i.imgur.com/qa3zbOn.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_assault_sandbox",
		displayname = "Assault",
		image = "https://i.imgur.com/l9uncGb.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_grant_street",
		displayname = "Neon Tokyo",
		image = "https://i.imgur.com/3VUaVT5.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_hmcd_rooftops",
		displayname = "Rooftops",
		image = "https://i.imgur.com/u88YPdE.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_pizzeria",
		displayname = "Pizzeria",
		image = "https://i.imgur.com/CrXVvnL.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "tdm_city18",
		displayname = "City 18",
		image = "https://i.imgur.com/FAFS23T.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "cs_insertion2_dusk",
		displayname = "Insertion II (Fixed)",
		image = "https://i.imgur.com/KJAthSW.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_kleinercomcenter",
		displayname = "Communtity Center",
		image = "https://i.imgur.com/NfqaleF.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "mu_smallotown_v2_13",
		displayname = "Small Town (Day)",
		image = "https://i.imgur.com/gYI8nD0.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_building",
		displayname = "Office Building",
		image = "https://i.imgur.com/DIgrELg.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_apartments_v2",
		displayname = "Apartments",
		image = "https://i.imgur.com/KPBfKDx.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_clue_2022",
		displayname = "Clue",
		image = "https://i.imgur.com/dHWDpkI.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_bank_change",
		displayname = "Bank",
		image = "https://i.imgur.com/aGJXyWJ.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_ile_v4",
		displayname = "Lighthouse",
		image = "https://i.imgur.com/pcBZ56Z.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "freeway_thicc_v3",
		displayname = "Freeway",
		image = "https://i.imgur.com/w9wUmsm.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "zavod",
		displayname = "EFT Factory",
		image = "https://i.imgur.com/0o19pTl.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_amsterville_open",
		displayname = "Amsterville",
		image = "https://i.imgur.com/i64MVDT.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "zs_adrift_v4",
		displayname = "Adrift",
		image = "https://i.imgur.com/D1UWlcz.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_blackmesa_bahpu",
		displayname = "Black Mesa",
		image = "https://i.imgur.com/v0zYPia.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_mc_island_2013",
		displayname = "Minecraft Island",
		image = "https://i.imgur.com/FBkaQTn.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "cs_office-unlimited",
		displayname = "Office",
		image = "https://i.imgur.com/S2T3jQ8.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "sm_manhattanmegamallnightv1",
		displayname = "New York Mall",
		image = "https://i.imgur.com/JDbC6hu.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_lilys_bedroom",
		displayname = "Bedroom",
		image = "https://i.imgur.com/n8XfLIa.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ph_scotch",
		displayname = "Scotch",
		image = "https://i.imgur.com/pWp9Az4.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_paradise_resort",
		displayname = "Paradise Resort",
		image = "https://i.imgur.com/KkqgNll.jpeg",
		width = 1920,
		height = 1080
	},
}