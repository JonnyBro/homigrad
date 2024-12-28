//
/*
	Smart Spawn Manager Configuration
	5/12/2018
	Author: Smart ( Badass Development )
*/

local config = {};

config.version 				= "1.0.9"; 			// What version of Smart Spawn Manger is this?
config.controlPanelCmd		= "!ss";			// What chat command do staff use to open the control panel?

config.fileDir				= "smartspawn";		// What directory do we store our data in?
config.configFileName		= "config.txt";		// What file do we store our config data in?
config.spawnsFileName		= "%s_spawns.txt";	// What file do we store our spawn data in?

config.staff				= {};				// What ULX usergroups are considered staff? (If you use ServerGuard ignore this)
config.staff["admin"]		= true;
config.staff["superadmin"]	= true;
config.staff["owner"]		= true;
config.staff["developer"]	= true;
config.staff["Founder"]		= true;
config.staff["Staff Manager"]	= true;

config.toolRemoveSearchRadius	= 30;			// How far to search when trying to find a spawn point to remove (with the toolgun)
config.spawnRenderRadius		= 1500;			// How far away do we render spawnpoints? (source units)

// Language settings 
config.lang 				= {};
config.lang.menuTitle		= "Smart Spawn Manager";
config.lang.tab1Title		= "Config";
config.lang.tab2Title		= "Player";
config.lang.tab3Title		= "Entities";
config.lang.tab4Title		= "Categories";

config.lang.uniqueID		= "UniqueID: ";
config.lang.remove			= "Remove";

config.lang.removePlayer	= "Removed player spawn!";
config.lang.removeEntity	= "Removed entity spawn!";
config.lang.saved			= "All changes saved!";

config.lang.renderSpawns	= "Render spawns for staff";
config.lang.playerSpawns	= "Custom Player Spawns";
config.lang.entitySpawns	= "Custom Entity Spawns";
config.lang.overrideSpawns	= "Override Default Player Spawns";
config.lang.saveChanges		= "Save";

// DONT TOUCH THIS
smartspawn_config = config;
