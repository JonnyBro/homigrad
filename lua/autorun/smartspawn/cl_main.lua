//
/*
	Smart Spawn Manager Clientside Main 
	5/12/2018
	Author: Smart ( Badass Development )
*/

include("cl_menu.lua");
local notify = include("plugins/sh_notify.lua");

local main = {};
main.playerSpawnPoints = {};
main.entitySpawnPoints = {};
main.modelCache	= {}; // stores model paths 
main.clientModelCache = {}; // stores clientside models 
main.bRenderActive	= false;

/*
	Receives a net message from the server for spawn data 
	This allows the client to render such data 
*/

function main.ReceiveSpawnData(len)

	local dataBuffer = net.ReadTable();
	main.bRenderActive = dataBuffer.bActive;

	main.playerSpawnPoints = dataBuffer.playerSpawnPoints;
	main.entitySpawnPoints = dataBuffer.entitySpawnPoints;
	main.modelCache = dataBuffer.modelCache;
	
	for class,model in next, main.modelCache do 
	
		main.clientModelCache[class] = ClientsideModel(model);
		main.clientModelCache[class]:SetNoDraw(true);
		main.clientModelCache[class]:SetMaterial("models/wireframe");
	end
end
net.Receive("smartspawn_spawndata", main.ReceiveSpawnData);

/*
	Renders spawn locations 
*/

local playerModel = ClientsideModel("models/Humans/Group03/Male_05.mdl");
playerModel:SetNoDraw(true);
playerModel:SetMaterial("models/wireframe");

function main.RenderSpawns()

	if (!main.bRenderActive) then return end

	local ang = EyeAngles() - Angle(0,90,0);
	ang.p = 0;
	ang.r = 90;
	
	local myPos = LocalPlayer():GetPos();
	
	for teamName, spawnTable in next, main.playerSpawnPoints do 
	
		for uniqueID, spawnPos in next, spawnTable do 
			
			if (spawnPos:Distance(myPos) > smartspawn_config.spawnRenderRadius) then continue end
			
			playerModel:SetPos(spawnPos);
			playerModel:SetupBones();
			playerModel:DrawModel();
			
			cam.Start3D2D(spawnPos + Vector(0, 0, 80), ang, 0.3);
			
				draw.SimpleTextOutlined(teamName .. " | " .. uniqueID, "smartspawn_font_large", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black);
			cam.End3D2D();	
		end
	end
	
	for class, spawnTable in next, main.entitySpawnPoints do 
		if (main.clientModelCache[class] == nil) then continue end 
		for uniqueID, spawn in next, spawnTable do 
		
			if (spawn.pos:Distance(myPos) > smartspawn_config.spawnRenderRadius) then continue end
		
			main.clientModelCache[class]:SetPos(spawn.pos);
			main.clientModelCache[class]:SetAngles(spawn.ang || Angle(0, 0, 0));
			main.clientModelCache[class]:SetupBones();
			main.clientModelCache[class]:DrawModel();
						
			cam.Start3D2D(spawn.pos + Vector(0, 0, 40), ang, 0.2);
			 
				draw.SimpleTextOutlined(class  .. " | " .. uniqueID, "smartspawn_font_large", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black);
				draw.SimpleTextOutlined("Delay: " .. spawn.delay .. "s", "smartspawn_font_large", 0, 25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black);
				draw.SimpleTextOutlined("Limit: " .. spawn.limit, "smartspawn_font_large", 0, 50, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black);
			cam.End3D2D();	
		end 
	end
end 
hook.Add("PostDrawTranslucentRenderables", "smartspawn_renderspawns", main.RenderSpawns);
