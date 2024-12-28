//
/*
	Smart Prop Control - Ghost Zone Tool 
	Smart Like My Shoe 
	3/3/2018
*/


TOOL.Category       = "Smart' s Tools";
TOOL.Name           = "#Category Spawns";
TOOL.Command        = nil;
TOOL.ConfigName     = "";
 
TOOL.ClientConVar["auto_uniqueid"]			 	= "0";
TOOL.ClientConVar["category"]			 		= "Default";
TOOL.ClientConVar["uniqueid"]			 		= "Default";

function TOOL:LeftClick(trace)
	
	if (_G.DarkRP) then 
		local autoGenerateUniqueID = self:GetClientInfo("auto_uniqueid");
		local category = self:GetClientInfo("category");
		local uniqueID = self:GetClientInfo("uniqueid");
		
		hook.Call("smartspawn_addplayerspawn", nil, category, uniqueID, trace.HitPos, autoGenerateUniqueID);
	end
	return true;
end

function TOOL:RightClick(trace)
	
	if (_G.DarkRP) then 
		hook.Call("smartspawn_removeplayerspawnbyposition", nil, trace.HitPos);
	end
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
	language.Add("Tool.smart_category_spawn.name", "Category Spawn Manager");
    language.Add("Tool.smart_category_spawn.desc", "Manage player spawn locations.");
    language.Add("Tool.smart_category_spawn.0", "Primary: Create spawn location | Secondary: Remove spawn location");
	
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
		
		if (_G.DarkRP) then 
			panel:AddItem(MakeLabel("Category"));
			
			local categorySelect = vgui.Create("DComboBox");
			local allCats = {};
			for catID, catTable in next, RPExtraTeams do 
				if (catTable.category) then 
					if (allCats[catTable.category] == nil) then 
						allCats[catTable.category] = true;
					end
				end
			end
			for category, bool in next, allCats do 
				categorySelect:AddChoice(category);
			end
			categorySelect.OnSelect = function(s, index, value, data)
		
				RunConsoleCommand("smart_category_spawn_category", value);
			end
			categorySelect:ChooseOptionID(1);
			panel:AddItem(categorySelect);
			
			panel:AddItem(MakeLabel("Unique ID"));
			
			local uniqueID = vgui.Create("DTextEntry");
			uniqueID:SetText("Some Unique Name");
			uniqueID.OnValueChange = function(s, value)
				RunConsoleCommand("smart_category_spawn_uniqueid", value);
			end
			uniqueID:SetUpdateOnType(true);
			
			panel:AddItem(uniqueID);
			
			local autoUniqueID = vgui.Create("DCheckBoxLabel");
			autoUniqueID:SetText("Automatically generate unique ID");
			autoUniqueID:SetTextColor(color_black);
			autoUniqueID:SetConVar("smart_category_spawn_auto_uniqueid");
			panel:AddItem(autoUniqueID);
		end
	end
	
	// Called when player selects this tool for the first time
    function TOOL.BuildCPanel(panel)
		
        BuildCPanel(panel);
    end
	
	local function UpdateCPanel()
		local panel = controlpanel.Get("smart_category_spawn");
        if (!panel) then 
			return;
		end
        BuildCPanel(panel);
    end
    concommand.Add("smart_category_spawn_tool_updatecpanel", UpdateCPanel);
end