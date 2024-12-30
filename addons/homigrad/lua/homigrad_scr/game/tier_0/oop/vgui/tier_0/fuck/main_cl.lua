local PANEL = ents.Get("v_panel")
if not PANEL then return end

local manual = {
	main = vgui.color.main
}

local manualFrame1 = {
	main = vgui.color.frame1
}

local manualFrame2 = {
	main = vgui.color.frame2
}

PANEL:Event_Add("Init", "Main", function(self)
	self:Color_Manual("main", manual, 0.1)
	self:Color_Manual("frame1", manualFrame1, 0.1)
	self:Color_Manual("frame2", manualFrame2, 0.1)
end)

PANEL:Event_Add("Draw", "Main", function(self, w, h, color)
	local main = color.main
	draw.RoundedBox(0, 0, 0, w, h, main)
	draw.Frame(0, 0, w, h, color.frame1, color.frame2)
end)