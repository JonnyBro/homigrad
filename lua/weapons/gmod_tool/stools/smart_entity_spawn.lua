//
/*
	Smart Prop Control - Ghost Zone Tool 
	Smart Like My Shoe 
	3/3/2018
*/


TOOL.Category       = "Smart' s Tools";
TOOL.Name           = "#Entity Spawns";
TOOL.Command        = nil;
TOOL.ConfigName     = "";
 
TOOL.ClientConVar["auto_uniqueid"]			 	= "0";
TOOL.ClientConVar["class"]			 			= "Default";
TOOL.ClientConVar["uniqueid"]			 		= "Default";
TOOL.ClientConVar["delay"]						= "60";
TOOL.ClientConVar["pitch"]						= "0";
TOOL.ClientConVar["yaw"]						= "0";
TOOL.ClientConVar["roll"]						= "0";
TOOL.ClientConVar["limit"]						= "1";


function TOOL:LeftClick(trace)
	
	local autoGenerateUniqueID = self:GetClientInfo("auto_uniqueid");
	local class = self:GetClientInfo("class");
	local uniqueID = self:GetClientInfo("uniqueid");
	local delay = tonumber(self:GetClientInfo("delay"));
	local ang = Angle(tonumber(self:GetClientInfo("pitch")), tonumber(self:GetClientInfo("yaw")), tonumber(self:GetClientInfo("roll")));
	local limit = tonumber(self:GetClientInfo("limit"));
	
	hook.Call("smartspawn_addentityspawn", nil, class, uniqueID, trace.HitPos + trace.HitNormal * 10, ang, delay, limit, autoGenerateUniqueID);
	return true;
end

function TOOL:RightClick(trace)

	if (SERVER) then 
	
		if (IsValid(trace.Entity)) then 
			
			local ang = trace.Entity:GetAngles();
			
			local class = trace.Entity:GetClass();
			if (trace.Entity.VehicleName != nil) then 
				class = trace.Entity.VehicleName;
			end
			
			local p = self:GetOwner();
			
			p:ConCommand("smart_entity_spawn_class " .. class);
			p:ConCommand("smart_entity_spawn_pitch " .. ang.p);
			p:ConCommand("smart_entity_spawn_yaw " .. ang.y);
			p:ConCommand("smart_entity_spawn_roll " .. ang.r);
			
			p:ConCommand("smart_entity_spawn_tool_updatecpanel");
			
		end 
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
	language.Add("Tool.smart_entity_spawn.name", "Entity Spawn Manager");
    language.Add("Tool.smart_entity_spawn.desc", "Manage entity spawn locations.");
    language.Add("Tool.smart_entity_spawn.0", "Primary: Create spawn location | Right click: Copy entity class");
	
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
		
		panel:AddItem(MakeLabel("Class"));
		
		local classSelect = vgui.Create("DTextEntry");
		classSelect:SetText(GetConVarString("smart_entity_spawn_class"));
		classSelect.OnValueChange = function(s, value)
			RunConsoleCommand("smart_entity_spawn_class", value);
		end 
		classSelect:SetUpdateOnType(true);
		panel:AddItem(classSelect);
		
		panel:AddItem(MakeLabel("Spawn Delay (seconds)"));
		
		local delay = vgui.Create("DNumSlider");
		delay:SetMin(1);
		delay:SetMax(1000);
		delay:SetConVar("smart_entity_spawn_delay");
		delay:SetText("Delay");
		delay.Label:SetTextColor(color_black);
		
		panel:AddItem(delay);
		
		local pitch = vgui.Create("DNumSlider");
		pitch:SetMin(1);
		pitch:SetMax(360);
		pitch:SetConVar("smart_entity_spawn_pitch");
		pitch:SetText("Pitch");
		pitch.Label:SetTextColor(color_black);
		
		panel:AddItem(pitch);
		
		local yaw = vgui.Create("DNumSlider");
		yaw:SetMin(1);
		yaw:SetMax(360);
		yaw:SetConVar("smart_entity_spawn_yaw");
		yaw:SetText("Yaw");
		yaw.Label:SetTextColor(color_black);
		
		panel:AddItem(yaw);
		
		local roll = vgui.Create("DNumSlider");
		roll:SetMin(1);
		roll:SetMax(360);
		roll:SetConVar("smart_entity_spawn_roll");
		roll:SetText("Roll");
		roll.Label:SetTextColor(color_black);
		
		panel:AddItem(roll);
		
		panel:AddItem(MakeLabel("Unique ID"));
		
		local uniqueID = vgui.Create("DTextEntry");
		uniqueID:SetText("Some Unique Name");
		uniqueID.OnValueChange = function(s, value)
			RunConsoleCommand("smart_entity_spawn_uniqueid", value);
		end
		uniqueID:SetUpdateOnType(true);
		
		panel:AddItem(uniqueID);
		
		local autoUniqueID = vgui.Create("DCheckBoxLabel");
		autoUniqueID:SetText("Automatically generate unique ID");
		autoUniqueID:SetTextColor(color_black);
		autoUniqueID:SetConVar("smart_entity_spawn_auto_uniqueid");
		panel:AddItem(autoUniqueID);
		
		local limit = vgui.Create("DNumSlider");
		limit:SetDecimals(0);
		limit:SetText("Entity Limit");
		limit.Label:SetTextColor(color_black);
		limit:SetConVar("smart_entity_spawn_limit");
		limit:SetMin(0);
		limit:SetMax(999);
		
		panel:AddItem(MakeLabel("0 Limit = Infinite entities"));
		
		panel:AddItem(limit);
	end
	
	// Called when player selects this tool for the first time
    function TOOL.BuildCPanel(panel)
		
        BuildCPanel(panel);
    end
	
	local function UpdateCPanel()
		local panel = controlpanel.Get("smart_entity_spawn");
        if (!panel) then 
			return;
		end
        BuildCPanel(panel);
    end
    concommand.Add("smart_entity_spawn_tool_updatecpanel", UpdateCPanel);
end