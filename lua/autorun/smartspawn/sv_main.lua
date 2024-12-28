//
/*
	Smart Spawn Manager Main 
	5/12/2018
	Author: Smart ( Badass Development )
*/

local notify = include("plugins/sh_notify.lua");

local main = {};
main.playerSpawnPoints = {};
main.playerSpawnPoints["all"] = {};
main.entitySpawnPoints = {};
main.spawnTimers = {}; // Used for storing entity spawn timers
main.modelCache	= {};

main.bRenderSpawns		= false; // Render spawns for staff?
main.bPlayerSpawns		= true; // Use custom player spawns?
main.bEntitySpawns		= true; // Use custom entity spawns?
main.bOverrideSpawns	= true; // Override default player spawns?

/*
	Pooled Strings
*/
util.AddNetworkString("smartspawn_controlpanel");
util.AddNetworkString("smartspawn_edit");
util.AddNetworkString("smartspawn_spawndata");

/*
	Generates a config var table 
*/
function main:GenerateConfigVariableTable()

	return {
		bRenderSpawns = main.bRenderSpawns,
		bPlayerSpawns = main.bPlayerSpawns,
		bEntitySpawns = main.bEntitySpawns,
		bOverrideSpawns = main.bOverrideSpawns,
	}
end

/*
	Saves all data 
*/

function main:Save()

	if (!file.IsDir(smartspawn_config.fileDir, "DATA")) then 
		file.CreateDir(smartspawn_config.fileDir);
	end 
	
	// Persist config data 
	file.Write(smartspawn_config.fileDir .. "/" .. smartspawn_config.configFileName, util.TableToJSON(self:GenerateConfigVariableTable()));
	// Persist spawn data for this map 
	file.Write(smartspawn_config.fileDir .. "/" .. string.format(smartspawn_config.spawnsFileName, game.GetMap()), util.TableToJSON({
		
		playerSpawnPoints = self.playerSpawnPoints,
		entitySpawnPoints = self.entitySpawnPoints,
	}));
end 

/*
	Loads all data 
*/

function main:Load()

	if (file.IsDir(smartspawn_config.fileDir, "DATA")) then 
		
		local configFilePath = smartspawn_config.fileDir .. "/" .. smartspawn_config.configFileName;
		if (file.Exists(configFilePath, "DATA")) then 
			for k,v in next, util.JSONToTable(file.Read(configFilePath, "DATA")) do 
			
				if (self[k]) then 
					self[k] = v;
				end
			end
		end
		
		local spawnsFilePath = smartspawn_config.fileDir .. "/" .. string.format(smartspawn_config.spawnsFileName, game.GetMap());
		if (file.Exists(spawnsFilePath, "DATA")) then 
			
			local data = util.JSONToTable(file.Read(spawnsFilePath, "DATA"));
			self.playerSpawnPoints = data.playerSpawnPoints;

			for class, spawnTable in next, data.entitySpawnPoints do 
				for uniqueID, spawn in next, spawnTable do 
				
					self:AddEntitySpawn(class, uniqueID, spawn.pos, spawn.ang || Angle(0, 0, 0), spawn.delay, spawn.limit || 0);
				end
			end
			if (self.playerSpawnPoints["all"] == nil) then 
				self.playerSpawnPoints["all"] = {};
			end			
		end
	end
end

/*
	Returns a bool if a player is staff or not 
*/
function main:IsStaff(ply)

	if (ply.GetUserGroup) then 
		if (smartspawn_config.staff[ply:GetUserGroup()]) then 
			return true;
		end 
	else 
		return ply:IsAdmin();
	end 
end

/*
	GenerateUniqueID
*/
function main:GenerateUniqueID(tableName, key)
	
	if (self[tableName][key] == nil) then 
		self[tableName][key] = {};
	end
	
	for i = 1, 9999 do 
	
		if (self[tableName][key][i] == nil) then 
			return i;
		end
	end
end

/*
	Generate Fake Entity 
*/
function main:GenerateFakeSpawnEntity(pos)

	local fake = {
		pos = pos,
	};
	function fake:GetPos()
		return self.pos;
	end 
	
	return fake;
end

/*
	Caches model paths from entity classes
*/
function main:CacheModelPathFromClass(class)
	
	if (self.modelCache[class]) then return end
	
	local ent = self:EntitySpawn(class, Vector(0, 0, 0), Angle(0, 0, 0), true);
	ent:Spawn();
	self.modelCache[class] = ent:GetModel();
	ent:Remove();
end

/*
	Networks spawn data to staff members 
*/
function main:NetworkSpawnDataForRendering()

	local allStaff = {};
	for k,v in next, player.GetAll() do 
		if (self:IsStaff(v)) then 
			allStaff[k] = v;
		end 
	end
	
	for class, spawnTable in next, self.entitySpawnPoints do 
		self:CacheModelPathFromClass(class);
	end

	net.Start("smartspawn_spawndata");
	
		net.WriteTable({
			bActive = self.bRenderSpawns,
			playerSpawnPoints = self.playerSpawnPoints,
			entitySpawnPoints = self.entitySpawnPoints,
			modelCache = self.modelCache,
		});
	net.Send(allStaff);
end

/*
	Adds a spawn point for players 
*/

function main:AddPlayerSpawn(teamName, uniqueID, pos)

	if (self.playerSpawnPoints[teamName] == nil) then 
		self.playerSpawnPoints[teamName] = {};
	end 
	
	self.playerSpawnPoints[teamName][uniqueID] = pos;
	self:NetworkSpawnDataForRendering();
	self:Save();
	print("adding spawn point", teamName, uniqueID);
end 

hook.Add("smartspawn_addplayerspawn", "add_player", function(teamName, uniqueID, pos, bAutoUniqueID)
	
	if (bAutoUniqueID == "1") then 
		uniqueID = main:GenerateUniqueID("playerSpawnPoints", teamName);
	end
	
	main:AddPlayerSpawn(teamName, uniqueID, pos);
end);

/*
	Removes a spawn point for players 
*/

function main:RemovePlayerSpawn(teamName, uniqueID)

	if (self.playerSpawnPoints[teamName]) then 
		self.playerSpawnPoints[teamName][uniqueID] = nil;
		self:NetworkSpawnDataForRendering();
		print("removing spawn point", teamName, uniqueID);
	end 
end 

hook.Add("smartspawn_removeplayerspawn", "remove_player", function(teamName, uniqueID)

	main:RemovePlayerSpawn(teamName, uniqueID);
end);

/*
	Removes a spawn point based on position 
*/

function main:RemovePlayerSpawnByPosition(targetPos)
	
	
	for teamName, spawnTable in next, self.playerSpawnPoints do 
		for uniqueID, pos in next, spawnTable do 
	
			if (pos:Distance(targetPos) < smartspawn_config.toolRemoveSearchRadius) then 
				self.playerSpawnPoints[teamName][uniqueID] = nil;
				self:NetworkSpawnDataForRendering();
				self:Save();
				break;
			end
		end 
	end 
end 

hook.Add("smartspawn_removeplayerspawnbyposition", "remove_player_pos", function(targetPos)

	main:RemovePlayerSpawnByPosition(targetPos);
end);

/*
	Adds a spawn point for entities 
*/

function main:AddEntitySpawn(class, uniqueID, pos, ang, delay, limit)

	if (class == "prop_physics" || class == "player") then 
		return;
	end

	if (self.entitySpawnPoints[class] == nil) then 
		self.entitySpawnPoints[class] = {};
	end 
	
	self.entitySpawnPoints[class][uniqueID] = {	
		pos = pos,
		ang = ang,
		delay = delay,
		limit = limit,
	};
	
	timer.Create("smartspawn_timer_"..class..uniqueID, delay, 0, function()
		if (limit > 0) then 
			if (table.Count(ents.FindByClass(class)) >= limit) then return end
		end
		main:EntitySpawn(class, pos, ang);
	end);
	
	self:NetworkSpawnDataForRendering();
	self:Save();
	print("adding entity spawn point", class, uniqueID, delay, limit);
end 

hook.Add("smartspawn_addentityspawn", "add_entity", function(class, uniqueID, pos, ang, delay, limit, bAutoUniqueID)

	if (bAutoUniqueID == "1") then 
		uniqueID = main:GenerateUniqueID("entitySpawnPoints", class);
	end
	
	main:AddEntitySpawn(class, uniqueID, pos, ang, delay, limit);
end);

/*
	Removes a spawn point for entities 
*/
function main:RemoveEntitySpawn(class, uniqueID) 

	if (self.entitySpawnPoints[class]) then 
		self.entitySpawnPoints[class][uniqueID] = nil;
		timer.Destroy("smartspawn_timer_"..class..uniqueID);
		self:NetworkSpawnDataForRendering();
		print("removing entity spawn point", class, uniqueID);
	end
end 

hook.Add("smartspawn_removeentityspawn", "remove_entity", function(class, uniqueID)

	main:RemoveEntitySpawn(class, uniqueID);
end);

/*
	Returns a bool if an entity of specified class is ontop of a given position 
*/
function main:IsPositionOccupied(pos)
	
	for k,v in next, player.GetAll() do 
		if (v:GetPos():Distance(pos) < 40) then return true end
	end
		
	return false; 
end

/*
	Handles player spawning 
*/
function main:PlayerSelectSpawn(ply)
	
	if (self.bPlayerSpawns) then 
		
		local bArrested = false;
		if (ply.isArrested) then 
			if (ply:isArrested()) then 
				bArrested = true;
			end 
		end 
		
		if (!bArrested) then 
			
			local teamName = team.GetName(ply:Team());
			local lastSpawnPos;
			
			//print(teamName, self.playerSpawnPoints[teamName]);
			if (self.playerSpawnPoints[teamName]) then // Attempt to select a spawn point for this player's team
				local possibleSpawns = {};
				for uniqueID, pos in next, self.playerSpawnPoints[teamName] do 
					if (!self:IsPositionOccupied(pos)) then 
						possibleSpawns[uniqueID] = pos;
						//print(pos);
					end
					lastSpawnPos = pos;
				end
				if (table.Count(possibleSpawns) > 0) then // Randomize spawn point
			
					return self:GenerateFakeSpawnEntity(table.Random(possibleSpawns));
				end
			end
			// Check category spawns 
			if (_G.DarkRP) then 
				local jobTable = ply:getJobTable();
				if (jobTable.category) then 
				
					if (self.playerSpawnPoints[jobTable.category]) then 
						
						local possibleSpawns = {};
						for uniqueID, pos in next, self.playerSpawnPoints[jobTable.category] do
						
							if (!self:IsPositionOccupied(pos)) then 
								possibleSpawns[uniqueID] = pos;
							end 
							lastSpawnPos = pos;
						end 
						if (table.Count(possibleSpawns) > 0) then 
							return self:GenerateFakeSpawnEntity(table.Random(possibleSpawns));
						end
					end
				end
			end 
			
			local possibleSpawns = {};
			// Check all purpose spawns 
			for uniqueID, pos in next, self.playerSpawnPoints["all"] do 
				
				if (!self:IsPositionOccupied(pos)) then 
					possibleSpawns[uniqueID] = pos;
				end
				lastSpawnPos = pos;
			end 
			if (table.Count(possibleSpawns) > 0) then 
				return self:GenerateFakeSpawnEntity(table.Random(possibleSpawns));
			end
			
			// All purpose positions are occupied... Check for override on default spawns 
			if (self.bOverrideSpawns) then 
				if (lastSpawnPos) then 
					return self:GenerateFakeSpawnEntity(lastSpawnPos);
				end
			end
			
			// Revert to default spawn points (info_player_spawn)
		end
	end
end
hook.Add("PlayerSelectSpawn", "smartspawn_player", function(ply)
		
	local result = main:PlayerSelectSpawn(ply);
	if (result) then
		ply:SetPos(result:GetPos());
		return result;
	end
end);

/*
	Handles entity spawning 
*/
function main:EntitySpawn(class, pos, ang, bForce)
	
	bForce = bForce || false;
	local ent;
	
	if (self.bEntitySpawns || bForce) then 
		if (!self:IsPositionOccupied(pos) || bForce) then 
		
			if (string.find(class, "sim_*")) then // Simphy's entity 
		
				local vList = list.Get( "simfphys_vehicles" )
				local vehicle = vList[class];
				if (!vehicle) then return end 
				
				ent = simfphys.SpawnVehicleSimple(class, pos, ang)
				//ent = simfphys.SpawnVehicle(player.GetAll()[1], pos, ang, vehicle.Model, vehicle.Class, class, vehicle);	
			
			else // Regular entity 
			
		
				ent = ents.Create(class);
				ent:SetPos(pos);
				ent:SetAngles(ang);
				ent:Spawn();
			end
		end
		
		if (IsValid(ent)) then // Correct z axis position so that the entity doesnt fucking spawn in the ground
			ent:SetPos(ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z/2));
		end 
	end
	
	return ent;
end

/*
	Opens the control panel for a player 
*/
function main:OpenControlPanel(ply)

	net.Start("smartspawn_controlpanel");
		net.WriteTable({
			spawnData = {
				playerSpawnPoints = self.playerSpawnPoints,
				entitySpawnPoints = self.entitySpawnPoints,
			},
			configData = self:GenerateConfigVariableTable(),
		});	
	net.Send(ply);
end

/*
	Handles chat commands 
*/
function main:PlayerSay(ply, text, bTeam)
	
	if (self:IsStaff(ply)) then 
		local lower = string.lower(text);
		if (lower == smartspawn_config.controlPanelCmd) then 
			
			self:OpenControlPanel(ply);
			return ""; // Suppress chat
		end
	end
end 
hook.Add("PlayerSay", "smartspawn_say", function(ply, text, bTeam)

	local result = main:PlayerSay(ply, text, bTeam);
	if (result) then 
		return result;
	end
end);

/*
	Handles net messages from the client
*/
function main.ReceiveNetMessage(len, ply)

	if (main:IsStaff(ply)) then 
	
		local data = net.ReadTable();
		if (data.action && data.key && data.uniqueID) then 
			if (data.action == "remove_player_spawn") then 
				
				notify:NotifyPlayer(ply, smartspawn_config.lang.removePlayer, 5);
				main:RemovePlayerSpawn(data.key, data.uniqueID);
				main:OpenControlPanel(ply);
				main:Save();
				
			elseif(data.action == "remove_entity_spawn") then 
				
				notify:NotifyPlayer(ply, smartspawn_config.lang.removeEntity, 5);
				main:RemoveEntitySpawn(data.key, data.uniqueID);
				main:OpenControlPanel(ply);
				main:Save();
			end 
		end 
		if (data.action) then 
			if (data.action == "config") then 
				
				main.bRenderSpawns = data.bRenderSpawns;
				main.bPlayerSpawns = data.bPlayerSpawns;
				main.bEntitySpawns = data.bEntitySpawns;
				main.bOverrideSpawns = data.bOverrideSpawns;
				notify:NotifyPlayer(ply, smartspawn_config.lang.saved, 5);
				main:NetworkSpawnDataForRendering();
				main:OpenControlPanel(ply);
				main:Save();
			end
		end
	end
end 
net.Receive("smartspawn_edit", main.ReceiveNetMessage);

/*
	Initializes the script 
*/
function main:Init()

	main:Load();
end 
hook.Add("InitPostEntity", "smartspawn_init", function()
	main:Init();
end);

