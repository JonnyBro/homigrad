//
/*
	Smart Spawn Manager Menu
	5/12/2018
	Author: Smart ( Badass Development )
*/

local menu = {
	
	spawnData = {},
	configData = {},
	lastTab = "",
};

local sDerma = include("plugins/cl_derma.lua");
sDerma:SetTransitionDuration(0.2);
sDerma:GenerateFont("smartspawn_font_small", "Trebuchet MS", 18, 400);
sDerma:GenerateFont("smartspawn_font_medium", "Trebuchet MS", 20, 400);
sDerma:GenerateFont("smartspawn_font_large", "Trebuchet MS", 32, 400);

/*	
	Gets a team color by team name 
*/
function menu:GetTeamColorByName(name)

	for k,v in next, team.GetAllTeams() do 
	
		if (v.Name == name) then 
			return v.Color;
		end
	end
end

/*	
	Sends a net message to the server to edit spawns
*/
function menu:Edit(action, key, uniqueID)

	net.Start("smartspawn_edit");
	
		net.WriteTable({
			action = action,
			key = key,
			uniqueID = uniqueID,
		});
	net.SendToServer();
end

/*
	Sends a net message to the server to save config 
*/
function menu:SaveConfig()

	net.Start("smartspawn_edit");
	
		net.WriteTable({
			action = "config",
			bRenderSpawns = self.configData.bRenderSpawns,
			bPlayerSpawns = self.configData.bPlayerSpawns,
			bEntitySpawns = self.configData.bEntitySpawns,
			bOverrideSpawns = self.configData.bOverrideSpawns,
		});
	net.SendToServer();
end

/*
	Opens the control panel 
*/
function menu:ControlPanel()

	local frame = sDerma:Frame(nil, nil, 600, 500, smartspawn_config.lang.menuTitle);
	frame:MakePopup();
	
	local sheet = sDerma:PropertySheet();
	sheet:SetParent(frame);
	sheet:SetPos(5, 25);
	sheet:SetSize(frame:GetWide() - 10, frame:GetTall() - 30);
	
	// Config 
	local tab1 = sDerma:Panel();
	
	local list1 = sDerma:List();
	list1:SetParent(tab1);
	list1:SetPos(0, 10);
	list1:SetSize(sheet:GetWide() - 20, sheet:GetTall() - 42);
	list1:SetPadding(10);
	
	local renderSpawns = sDerma:DropDownSheet(smartspawn_config.lang.renderSpawns, {"Enabled", "Disabled"}, self.configData.bRenderSpawns && 1 || 2, sheet:GetWide(), 20, function(s, index, value, data)

		if (value == "Enabled") then 
			self.configData.bRenderSpawns = true;
		else 
			self.configData.bRenderSpawns = false;
		end
	end);
	list1:AddItem(renderSpawns);
	
	local playerSpawns = sDerma:DropDownSheet(smartspawn_config.lang.playerSpawns, {"Enabled", "Disabled"}, self.configData.bPlayerSpawns && 1 || 2, sheet:GetWide(), 20, function(s, index, value, data)

		if (value == "Enabled") then 
			self.configData.bPlayerSpawns = true;
		else 
			self.configData.bPlayerSpawns = false;
		end
	end);
	list1:AddItem(playerSpawns);
	
	local entitySpawns = sDerma:DropDownSheet(smartspawn_config.lang.entitySpawns, {"Enabled", "Disabled"}, self.configData.bEntitySpawns && 1 || 2, sheet:GetWide(), 20, function(s, index, value, data)

		if (value == "Enabled") then 
			self.configData.bEntitySpawns = true;
		else 
			self.configData.bEntitySpawns = false;
		end
	end);
	list1:AddItem(entitySpawns);
	
	local override = sDerma:DropDownSheet(smartspawn_config.lang.overrideSpawns, {"Enabled", "Disabled"}, self.configData.bOverrideSpawns && 1 || 2, sheet:GetWide(), 20, function(s, index, value, data)

		if (value == "Enabled") then 
			self.configData.bOverrideSpawns = true;
		else 
			self.configData.bOverrideSpawns = false;
		end
	end);
	list1:AddItem(override);
	
	local save = sDerma:Button(smartspawn_config.lang.saveChanges, function()
		self:SaveConfig();
		frame.Dismiss();
	end);
	list1:AddItem(save);
	
	local sheet1 = sheet:AddSheet(smartspawn_config.lang.tab1Title, tab1, "icon16/page.png");
	
	// Player spawns tab
	local tab2 = sDerma:Panel();
	
	local list2 = sDerma:List();
	list2:SetParent(tab2);
	list2:SetPos(0, 10);
	list2:SetSize(sheet:GetWide() - 20, sheet:GetTall() - 42);
	list2:SetPadding(10);
	
	for teamName, spawnTable in next, self.spawnData.playerSpawnPoints do 
	
		if (table.Count(spawnTable) < 1) then continue end
	
		local catList = sDerma:CollapsibleCategoryList(list1:GetWide(), 20, self:GetTeamColorByName(teamName));
		if (teamName == "all") then 
			catList:SetLabel("All Teams");
		else 
			catList:SetLabel(teamName);
		end
		
		for uniqueID, spawn in next, spawnTable do 
			local panel = sDerma:Panel();
			panel:SetSize(catList:GetWide(), 26);
			panel.Paint = function(s)
				
				draw.RoundedBox(4, 0, 0, s:GetWide(), s:GetTall(), Color(50, 50, 50, 255));
			end
			
			local idLabel = sDerma:Label(smartspawn_config.lang.uniqueID .. " " .. uniqueID, "smartspawn_font_small");
			idLabel:SetParent(panel);
			idLabel:SetPos(5, 5);
			
			local remove = sDerma:Button(smartspawn_config.lang.remove, function()
				
				self:Edit("remove_player_spawn", teamName, uniqueID);
				frame.Dismiss();
			end);
			remove:SetSize(100, 20);
			remove:SetParent(panel);
			remove:SetPos(panel:GetWide()-125, 3);
		
			catList:AddItem(panel);
		end
		list2:AddItem(catList);
	end
	
	local sheet2 = sheet:AddSheet(smartspawn_config.lang.tab2Title, tab2, "icon16/status_online.png");
	
	// Entity spawns tab 
	local tab3 = sDerma:Panel();

	local list3 = sDerma:List();
	list3:SetParent(tab3);
	list3:SetPos(0, 10);
	list3:SetSize(sheet:GetWide() - 20, sheet:GetTall() - 42);
	list3:SetPadding(10);
	
	for class, spawnTable in next, self.spawnData.entitySpawnPoints do 
	
		if (table.Count(spawnTable) < 1) then continue end
	
		local catList = sDerma:CollapsibleCategoryList(list1:GetWide(), 20);
		catList:SetLabel(class);
		
		for uniqueID, spawn in next, spawnTable do 
			local panel = sDerma:Panel();
			panel:SetSize(catList:GetWide(), 26);
			panel.Paint = function(s)
				
				draw.RoundedBox(4, 0, 0, s:GetWide(), s:GetTall(), Color(50, 50, 50, 255));
			end
			
			local idLabel = sDerma:Label(smartspawn_config.lang.uniqueID .. " " .. uniqueID .. " | Limit: " .. spawn.limit || 0, "smartspawn_font_small");
			idLabel:SetParent(panel);
			idLabel:SetPos(5, 5);
			
			local remove = sDerma:Button(smartspawn_config.lang.remove, function()
				
				self:Edit("remove_entity_spawn", class, uniqueID);
				frame.Dismiss();
			end);
			remove:SetSize(100, 20);
			remove:SetParent(panel);
			remove:SetPos(panel:GetWide()-125, 3);
		
			catList:AddItem(panel);
		end
		list3:AddItem(catList);
	end
	
	local sheet3 = sheet:AddSheet(smartspawn_config.lang.tab3Title, tab3, "icon16/box.png");
	
	frame.Think = function()
		if (sheet:GetActiveTab() == sheet1.Tab) then 
			self.lastTab = smartspawn_config.lang.tab1Title;
		elseif(sheet:GetActiveTab() == sheet2.Tab) then 
			self.lastTab = smartspawn_config.lang.tab2Title;
		elseif(sheet:GetActiveTab() == sheet3.Tab) then 
			self.lastTab = smartspawn_config.lang.tab3Title;
		end
	end
	
	sheet:SwitchToName(self.lastTab);
	
	sheet:DoPaintSetup();
	frame.Request();
end 

/*
	Receives a net message to open the control panel 
*/
function menu.ReceiveOpenControlPanel()
	// Process data
	local dataBuffer = net.ReadTable();
	
	menu.spawnData = dataBuffer.spawnData;
	menu.configData = dataBuffer.configData;
	menu:ControlPanel();
end 
net.Receive("smartspawn_controlpanel", menu.ReceiveOpenControlPanel);