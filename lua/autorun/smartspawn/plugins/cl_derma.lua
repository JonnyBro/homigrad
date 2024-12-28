//
/*
	Smart's Derma Script
	Date: 1/24/2018
	Time: 2:24pm
	Author: Smart Like My Shoe 
	Defines a bunch of functions that make my Derma life easier 
*/

///////////
// Vars 
///////////

local smart = {
	blur = Material( "pp/blurscreen" ),
	
	defaultFont = "Default",
	
	cornerRadius = 6,
	backGroundColor = Color(20, 20, 20, 200),
	panelColor = Color(30, 30, 30, 200),
	buttonTextColor = Color(255, 255, 255, 255),
	buttonColor = Color(100, 100, 100, 255),
	buttonColorHovered = Color(120, 120, 120, 255),
	buttonSuccessSound = "buttons/button3.wav",
	buttonErrorSound = "buttons/button2.wav",
	transitionDuration = 0.5,
};

/////////////
// Accessor methods 
/////////////

function smart:SetCornerRadius(radius)
	self.cornerRadius = radius;
end

function smart:SetBackgroundColor(color)
	self.backGroundColor = color;
end 

function smart:SetButtonTextColor(color)
	self.buttonTextColor = color;
end 

function smart:SetButtonColor(color)
	self.buttonColor = color;
end 

function smart:SetColorHovered(color)
	self.buttonColorHovered = color;
end 

function smart:SetSuccessSound(path)
	self.buttonSuccessSound = path;
end 

function smart:SetTransitionDuration(duration)
	self.transitionDuration = duration;
end

function smart:SetDefaultFont(font)
	self.defaultFont = font;
end

function smart:SetPanelColor(color)
	self.panelColor = color;
end

////////////
// Methods 
////////////

/*
	GenerateFont 
	Parameters: string
	Returns: void 
	Description: Calls surface.createfont method
*/
function smart:GenerateFont(name, font, size, weight)

	weight = weight || 500;

	surface.CreateFont(name, {
		font = font,
		extended = false,
		size = size,
		weight = weight,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	});
	
	if (self.defaultFont == "Default") then 
		self.defaultFont = name;
	end 
	print("Generating font", name, size)
end

/*
	Blur 
	Parameters: panel, integer, integer, integer 
	Returns: void 
	Description: Draws a nice blur effect 
*/

function smart:Blur(panel, layers, density, alpha)
	local x, y = panel:LocalToScreen(0, 0);

	surface.SetDrawColor(255, 255, 255, alpha);
	surface.SetMaterial(self.blur);

	for i = 1, 3 do
		self.blur:SetFloat("$blur", ( i / layers ) * density);
		self.blur:Recompute();
		render.UpdateScreenEffectTexture();
		surface.DrawTexturedRect(-x, -y, ScrW(), ScrH());
	end
end

/*
	Slide 
	Parameters: panel, integer, integer
	Returns: void 
	Description: Slides a panel to an absolute position over time (seconds)
*/
function smart:Slide(p, x, y)

	// Calculate differences 
	local pX, pY = p:GetPos();
	local diffX = x - pX;
	local diffY = y - pY;
	
	local startTime = CurTime();
	
	// Hook the think method to run our animation
	local oldThink = p.Think || function(_p) end;
	
	p.Think = function(_p)
		oldThink(p);
		
		local timeElapsed = CurTime() - startTime;
		local progress = (timeElapsed/self.transitionDuration);
		
		p:SetPos(pX + (diffX*progress), pY + (diffY*progress));
		
		if (progress >= 1) then // Unhook the think method
			p.Think = oldThink;
			p:SetPos(x, y);
		end
	end 
end 

/*
	Frame 
	Parameters: integer, integer, integer (optional), integer (optional), string (optional)
	Returns: panel
	Description: Generates a custom derma frame 
*/
function smart:Frame(x, y, width, height, title, closeButton)

	x = x || ScrW()/2-width/2;
	y = y || ScrH()/2-height/2;
	title = title || "";
	if (closeButton == nil) then 
		closeButton = true;
	end

	local frame = vgui.Create("DFrame");
	frame:SetSize(width, height);
	frame:SetPos(x, y);
	frame:ShowCloseButton(false);
	frame:SetDraggable(false);
	frame:SetTitle(title);
	frame._x = x;
	frame._y = y;
	frame.Paint = function(p)
		self:Blur(frame, 1, 2, 255);
		draw.RoundedBox(self.cornerRadius, 0, 0, p:GetWide(), p:GetTall(), self.backGroundColor);
	end
	
	if (closeButton) then 
		frame.close = vgui.Create("DImageButton");
		frame.close:SetParent(frame);
		frame.close:SetIcon("icon16/cancel.png");
		frame.close:SetPos(frame:GetWide() - 21, 5);
		frame.close:SetSize(16, 16);
		frame.close.DoClick = function(p)
			
			surface.PlaySound(self.buttonSuccessSound);
			frame.Dismiss();
		end
	end
	
	frame.Request = function(x2, y2, x3, y3)
		
		local centerX = ScrW() / 2 - frame:GetWide() / 2;
		local centerY = ScrH() / 2 - frame:GetTall() / 2;
		
		x2 = x2 || centerX;
		y2 = y2 || -frame:GetTall();
		x3 = x3 || centerX;
		y3 = y3 || centerY;
		
		frame:SetPos(x2, y2);
		self:Slide(frame, x3, y3);
	end
	
	frame.Dismiss = function(x2, y2)
		x2 = x2 || x;
		y2 = y2 || ScrH();
		
		self:Slide(frame, x2, y2);
		timer.Simple(self.transitionDuration, function()
			if (IsValid(frame)) then 
				frame:Close();
			end
		end);
	end
	
	return frame;
end

/*
	Panel 
	Parameters: int, int 
	Returns: panel 
*/
function smart:Panel(w, h)

	local panel = vgui.Create("DPanel");
	panel:SetSize(w, h);
	panel.Paint = function(s)
	
		draw.RoundedBox(self.cornerRadius, 0, 0, s:GetWide(), s:GetTall(), self.panelColor);
	end
	
	return panel;
end

/*
	List 
	Parameters: panel (optional), boolean (optional)
	Returns: panel 
*/
function smart:List(parent, bHorizontal)

	bHorizontal = bHorizontal || false;
	
	local dList = vgui.Create("DPanelList");
	dList:SetSpacing(2);
	dList:EnableVerticalScrollbar(true);
	dList:EnableHorizontal(bHorizontal);
	
	if (parent) then 
		dList:SetParent(parent);
		dList:SetPos(5, 25);
		dList:SetSize(parent:GetWide() - 10, parent:GetTall() - 30);
	end 
	
	return dList;
end

/*
	CollapsibleCategoryList
	Parameters: int, int
	Returns: panel 
*/
function smart:CollapsibleCategoryList(w, h, color)

	color = color || Color(20, 20, 20, 255);

	local cat = vgui.Create("DCollapsibleCategory");
	cat:SetWide(w);
	cat.Paint = function() end
	cat.Header:SetFont(self.defaultFont);
	cat.Header.Paint = function(s)
		draw.RoundedBox(4, 0, 0, s:GetWide(), s:GetTall(), color);
	end
	
	local internalList = self:List(nil, false);
	
	cat.internalList = internalList;
	cat:SetContents(internalList);
	
	cat.AddItem = function(s, p)
		internalList:AddItem(p);
	end
	
	return cat;
end

/*
	Button
	Parameters: string, function 
	Returns: panel
*/
function smart:Button(text, func)

	func = func || function() end

	local button = vgui.Create("DButton");
	button:SetText(text);
	button:SetTextColor(self.buttonTextColor);
	button.DoClick = function() 
		surface.PlaySound(self.buttonSuccessSound);
		func();
	end
	button.Paint = function(p)
		
		local color;
		if (button:IsHovered()) then 
			color = self.buttonColorHovered;
		else
			color = self.buttonColor;
		end 
		
		local highLightColor = Color(color.r + 5, 
									color.g + 5,
									color.b + 5,
									color.a);
									
		local highLightCornerRadius = self.cornerRadius - 2;
		if (highLightCornerRadius < 0) then 
			highLightCornerRadius = 0;
		end
									
		draw.RoundedBox(self.cornerRadius, 0, 0, p:GetWide(), p:GetTall(), color);
		draw.RoundedBox(highLightCornerRadius, 0, 0, p:GetWide(), p:GetTall()/2, highLightColor);
	end 

	return button;
end

/*
	Label 
	Parameters: string, string 
	Return: panel 
*/
function smart:Label(text, font, color)

	color = color || Color(255,255,255,255);

	local lab = vgui.Create("DLabel");
	lab:SetFont(font);
	lab:SetText(text);
	lab:SetTextColor(color);
	lab:SizeToContents();
	
	return lab;
end

/*
	SpawnIcon
	Parameters: string 
	Return: panel
*/
function smart:SpawnIcon(model, size)

	local spawnIcon = vgui.Create("SpawnIcon");
	spawnIcon:SetModel(model);
	spawnIcon:SetSize(size, size);
	
	/* Unneccesary?
	if (self.BuiltSpawnIcons[model] == nil) then
		spawnIcon:RebuildSpawnIcon();
		self.BuiltSpawnIcons[model] = true;
	end
	*/
	
	return spawnIcon;
end


/*
	DPropertySheet 
	Parameters: void 
	Return: panel
*/
function smart:PropertySheet()

	local propertySheet = vgui.Create("DPropertySheet");
	propertySheet.Paint = function(s)
		draw.RoundedBox(0, 0, 0, s:GetWide(), s:GetTall(), Color(0, 0, 0, 200));
	end
	
	propertySheet.DoPaintSetup = function(s)
	
		for k, v in pairs(s.Items) do
			if (!v.Tab) then 
				continue;
			end
		
			v.Tab.Paint = function(self,w,h)
		
				if (s:GetActiveTab() == v.Tab) then 
					draw.RoundedBox(4, 0, 0, w, h-5, Color(80, 80, 80, 200));
				else 
			
					draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200));
				end
			end
		end
	end 
	
	return propertySheet;
end

/*
	Dropdown sheet
	Parameters: void 
	Return: panel
*/
function smart:DropDownSheet(txt, options, defaultOption, width, height, onSelectOption)

	local parent = vgui.Create("DPanel");
	parent:SetSize(width, height);
	parent.Paint = function() end

	local lab = self:Label(txt, "Trebuchet18");
	lab:SetPos(0, 0);
	lab:SetParent(parent);
	lab:SizeToContents();

	local combo = vgui.Create("DComboBox", parent);
	combo:SetSize(100, 20);
	combo:SetPos(width - 140, 0);
	combo.OnSelect = onSelectOption;

	for k,v in next, options do 
		combo:AddChoice(v);
	end

	combo:SetText(options[defaultOption]);

	return parent;
end

/*
	Notification
	Parameters: string, int 
	Return: Panel
*/
local iconMaterial = Material("icon16/exclamation.png");
function smart:Notification(text, duration, index)
	
	local label = self:Label(text, "Trebuchet24");
	local width = label:GetWide() + 31;
	local height = label:GetTall() + 5;
	
	local x = ScrW() - width;
	local y = ScrH() / 2 - height / 2 + index * height;
	
	local frame = self:Frame(x, y, width, height, "", false);
	label:SetParent(frame);
	label:SetPos(21, 2.5);
	
	local iconMat
	local icon = vgui.Create("DPanel", frame);
	icon:SetPos(3, height/2 - 8);
	icon:SetSize(16, 16);
	icon.Paint = function()
		
		surface.SetDrawColor(color_white);
		surface.SetMaterial(iconMaterial);
		surface.DrawTexturedRect(0, 0, icon:GetWide(), icon:GetTall());
	end
	
	frame.Request(ScrW(), y, x, y); 
	
	timer.Simple(duration, function()
		frame.Dismiss(ScrW(), y);
	end);
end

/*
	NumSlider
	Parameters: Int, Int, Int, String
*/
function smart:NumSlider(min, max, decimals, conVar)

	local dSlider = vgui.Create("DNumSlider");
	dSlider:SetMin(min);
	dSlider:SetMax(max);
	dSlider:SetDecimals(decimals);
	if (conVar != nil) then 
		dSlider:SetConVar(conVar);
	end
	
	dSlider.Label:SetFont("Trebuchet18");
	dSlider.Label:SetTextColor(Color(255, 255, 255, 255));
	
	dSlider.Slider.Knob.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(80, 80, 80, 255));
	end
	dSlider.Slider.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 100));
	end
	dSlider.TextArea.Paint = function(self)
		draw.SimpleText(self:GetText(), "Trebuchet18", 6, 3, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT);
	end
	
	return dSlider;
end

/*
	Graph Plot Point 
	Parameters: String
*/
function smart:PlotPoint(txt)
	
	local tLab = self:Label(txt, "Trebuchet18", color_black);

	local point = self:Panel();
	point:SetSize(8, 8);
	point.Paint = function(s)
		draw.RoundedBox(2, 0, 0, s:GetWide(), s:GetTall(), Color(255, 255, 255, 200));
	end
	
	point:SetTooltipPanel(tLab);
	
	return point;
end

/*
	Line Graph
	Parameters: String, String, Int, Int, Int, Table, Int, Int
*/
function smart:LineGraph(title, xAxisLabel, w, h, axisPadding, dataPoints, xInterval, yInterval)
	
	local plottedPoints = {};
	local thresholds = {};
	
	local graph = self:Panel()
	graph:SetSize(w, h);
	graph.Paint = function(s) 
	
		local yOrigin = s:GetTall();
		local yPadded = yOrigin - axisPadding;

		surface.SetDrawColor(color_white);
		surface.DrawLine(axisPadding, yPadded, s:GetWide(), yPadded); // X Axis
		surface.DrawLine(axisPadding, yPadded, axisPadding, 0); // Y Axis
		
		// X Axis Label 
		draw.SimpleText(xAxisLabel, "Trebuchet18", s:GetWide()/2, s:GetTall() - axisPadding - 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
		
		local maxX = #dataPoints;
		//local minX = 0;
		local maxY = math.Round(math.max(unpack(dataPoints)));
		local minY = math.Round(math.min(unpack(dataPoints)));
		
		local diffY = math.max((maxY - minY) + yInterval, yInterval);	
		local scaleX = w / 10;
		local scaleY = (h-axisPadding*2) / diffY;
		
		local xCounter = 0;
		for x = maxX - 10, maxX do // Draw the numbers on the x axis
			
			if (x < 0) then continue end
		
			local text = tostring(x * xInterval);
			draw.SimpleText(text, "Trebuchet18", axisPadding + scaleX * xCounter, yPadded + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
			
			xCounter = xCounter + 1;
		end
	
		for y = minY, diffY, yInterval do // Draw the text along the y axis
			local text = tostring(y);
			draw.SimpleText(text, "Trebuchet18", axisPadding - 12, yPadded - y * scaleY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		end
		
		// Plots the line graph 
		surface.SetDrawColor(color_white);
		xCounter = 0;
		for x = maxX - 10, maxX do 
			local y1 = dataPoints[x];
			local y2 = dataPoints[x + 1];
			if (!y1 || !y2) then continue end 
		
			local y1Unscaled = y1;
			y1 = y1 * scaleY;
			y2 = y2 * scaleY;
			local x1 = axisPadding + scaleX * xCounter;
			local x2 = axisPadding + scaleX * (xCounter + 1);
			
			surface.DrawLine(x1, yPadded - y1, x2, yPadded - y2);
			
			if (plottedPoints[x] == nil) then 
					
				local point = self:PlotPoint(tostring(math.Round(y1Unscaled)));
				point:SetParent(graph);
				point:SetPos(x1 - point:GetWide()/2, (yPadded - y1) - point:GetTall()/2);
				plottedPoints[x] = true;
			end
			
			
			xCounter = xCounter + 1;
		end
		
		// Plot thresholds 
		for k,v in next, thresholds do 
		
			if (diffY > v.y) then 
				
				local y = yPadded - v.y * scaleY;
				surface.SetDrawColor(v.color);
				surface.DrawLine(axisPadding, y, w, y);
				draw.SimpleText(tostring(v.y) .. " - " .. v.text, "Trebuchet18", w/2, y - 7, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
			end
		end
		
		// Draw title 
		draw.SimpleText(title, "Trebuchet18", w/2, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
	end
	
	function graph:AddThreshold(y, text, color)
	
		thresholds[#thresholds+1] = {
			y = y,
			text = text,
			color = color,
		};
	end
	
	return graph;
end

return smart;