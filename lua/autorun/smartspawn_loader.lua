//
/*
	Smart Spawn Loader
	5/12/2018
	Author: Smart ( Badass Development )
*/

include("smartspawn/sh_config.lua");
if (SERVER) then 
	
	AddCSLuaFile();
	AddCSLuaFile("smartspawn/cl_main.lua");
	AddCSLuaFile("smartspawn/cl_menu.lua");
	AddCSLuaFile("smartspawn/plugins/cl_derma.lua");
	AddCSLuaFile("smartspawn/plugins/sh_notify.lua");
	AddCSLuaFile("smartspawn/sh_config.lua");

	include("smartspawn/sv_main.lua");
else 

	include("smartspawn/cl_main.lua");
end