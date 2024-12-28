//
/*
	Smart Prop Control - Ghost Zone Tool 
	Smart Like My Shoe 
	3/3/2018
*/


TOOL.Category       = "Smart' s Tools";
TOOL.Name           = "#Player Spawns";
TOOL.Command        = nil;
TOOL.ConfigName     = "";
 
TOOL.ClientConVar["auto_uniqueid"]			 	= "0";
TOOL.ClientConVar["team"]			 			= "Default";
TOOL.ClientConVar["uniqueid"]			 		= "Default";

function TOOL:LeftClick(trace)
	
	local autoGenerateUniqueID = self:GetClientInfo("auto_uniqueid");
	local teamName = self:GetClientInfo("team");
	local uniqueID = self:GetClientInfo("uniqueid");
	
	hook.Call("smartspawn_addplayerspawn", nil, teamName, uniqueID, trace.HitPos, autoGenerateUniqueID);
	return true;
end

function TOOL:RightClick(trace)
	
	hook.Call("smartspawn_removeplayerspawnbyposition", nil, trace.HitPos);
	return true;
end 

function TOOL:Reload(trace)
	
end

function TOOL:Deploy()
end 

function TOOL:Holster()
end 

function TOOL:Think()

end 

if (CLIENT) then 

	// Top left hud language strings
	language.Add("Tool.smart_player_spawn.name", "Player Spawn Manager");
    language.Add("Tool.smart_player_spawn.desc", "Manage player spawn locations.");
    language.Add("Tool.smart_player_spawn.0", "Primary: Create spawn location | Secondary: Remove spawn location");
	
	// Undo language 
	//language.Add("Undone_smart_npc", "Undone Smart Npc!");
	
	// Derma utility methods 
	local function MakeLabel(text, font)
	
		font = font || "Trebuchet18";
	
		local l = vgui.Create("DLabel");
		l:SetText(text);
		l:SetFont(font);
		l:SetTextColor(Color(0,0,0,255));
		l:SizeToContents();
		
		return l;
	end
	
	// Control panel (derma)
	local function BuildCPanel(panel)
		panel:ClearControls();
		
		panel:AddItem(MakeLabel("Team"));
		
		local teamSelect = vgui.Create("DComboBox");
		for teamID, teamTable in next, team.GetAllTeams() do 
			teamSelect:AddChoice(teamTable.Name, teamID);
		end
		teamSelect:AddChoice("All Teams", "all");
		teamSelect.OnSelect = function(s, index, value, data)
	
			if (value == "All Teams") then 
				RunConsoleCommand("smart_player_spawn_team", data);
			else 
				RunConsoleCommand("smart_player_spawn_team", value);
			end
		end
		teamSelect:ChooseOptionID(2);
		panel:AddItem(teamSelect);
		
		panel:AddItem(MakeLabel("Unique ID"));
		
		local uniqueID = vgui.Create("DTextEntry");
		uniqueID:SetText("Some Unique Name");
		uniqueID.OnValueChange = function(s, value)
			RunConsoleCommand("smart_player_spawn_uniqueid", value);
		end
		uniqueID:SetUpdateOnType(true);
		
		panel:AddItem(uniqueID);
		
		local autoUniqueID = vgui.Create("DCheckBoxLabel");
		autoUniqueID:SetText("Automatically generate unique ID");
		autoUniqueID:SetTextColor(color_black);
		autoUniqueID:SetConVar("smart_player_spawn_auto_uniqueid");
		panel:AddItem(autoUniqueID);
	end
	
	// Called when player selects this tool for the first time
    function TOOL.BuildCPanel(panel)
		
        BuildCPanel(panel);
    end
	
	local function UpdateCPanel()
		local panel = controlpanel.Get("smart_player_spawn");
        if (!panel) then 
			return;
		end
        BuildCPanel(panel);
    end
    concommand.Add("smart_player_spawn_tool_updatecpanel", UpdateCPanel);
end