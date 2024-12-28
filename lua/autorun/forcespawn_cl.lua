if SERVER then return end

local ADDON_NAME = "force_respawn"
usermessage.Hook(ADDON_NAME, function(data)
local Version1 = data:ReadString()
local Version2 = data:ReadString()
local ADDON_ACTUAL_NAME = data:ReadString()
local DOWNLOAD_LINK = data:ReadString()
local Frame = vgui.Create( "DFrame" )
Frame:SetSize( 300, 150 ) 
Frame:Center()
Frame:SetTitle( "Addon: "..ADDON_ACTUAL_NAME.." needs updating" ) 
Frame:SetSizable(false)
Frame:SetDraggable(false)
Frame:ShowCloseButton( false ) 
Frame:MakePopup() 

local FLabel = vgui.Create( "DLabel", Frame )
FLabel:Center()
FLabel:SetPos( 15, 27 )
--FLabel:SetColor(Color(255,255,255,255)) // Color
--FLabel:SetFont("default")
FLabel:SetText("The addon: "..ADDON_ACTUAL_NAME.." is outdated!")
FLabel:SizeToContents()

local FLabel2 = vgui.Create( "DLabel", Frame )
FLabel2:Center()
FLabel2:SetPos( 15, 40 )
--FLabel2:SetColor(Color(255,255,255,255)) // Color
--FLabel2:SetFont("default")
FLabel2:SetText("Please contact system administrator to update addon!")
FLabel2:SizeToContents()

local FLabel3 = vgui.Create( "DLabel", Frame )
FLabel3:Center()
FLabel3:SetPos( 15, 53 )
--FLabel3:SetColor(Color(255,255,255,255)) // Color
--FLabel3:SetFont("default")
FLabel3:SetText("Server's Version:")
FLabel3:SizeToContents()

local FLabel35 = vgui.Create( "DLabel", Frame )
FLabel35:Center()
FLabel35:SetPos( 100, 53 )
FLabel35:SetColor(Color(255,0,0,255)) // Color
--FLabel35:SetFont("default")
FLabel35:SetText(Version1)
FLabel35:SizeToContents()

local FLabel4 = vgui.Create( "DLabel", Frame )
FLabel4:Center()
FLabel4:SetPos( 15, 66 )
--FLabel4:SetColor(Color(255,255,255,255)) // Color
--FLabel4:SetFont("default")
FLabel4:SetText("Online Version:")
FLabel4:SizeToContents()

local FLabel45 = vgui.Create( "DLabel", Frame )
FLabel45:Center()
FLabel45:SetPos( 90, 66 )
FLabel45:SetColor(Color(255,0,0,255)) // Color
--FLabel45:SetFont("default")
FLabel45:SetText(Version2)
FLabel45:SizeToContents()

local FLabel5 = vgui.Create( "DLabel", Frame )
FLabel5:Center()
FLabel5:SetPos( 15, 81 )
--FLabel5:SetColor(Color(255,255,255,255)) // Color
--FLabel5:SetFont("default")
FLabel5:SetText("Addon:")
FLabel5:SizeToContents()

local FLabel55 = vgui.Create( "DButton", Frame )
FLabel55:SetSize(ScrW() * 0.025, ScrH() * 0.015)
FLabel55:Center()
FLabel55:SetPos( 52, 83 )
FLabel55:SetText("Link")
FLabel55.DoClick = function()
gui.OpenURL(DOWNLOAD_LINK)
end

local Close = vgui.Create("DButton", Frame)
Close:SetSize(ScrW() * 0.050, ScrH() * 0.025)
Close:Center()
Close:SetPos(105,120)
Close:SetText("Ok")
Close.DoClick = function()
if Checkbox:GetChecked() == true then
net.Start( ADDON_NAME )
	net.WriteEntity(LocalPlayer())
net.SendToServer()
end
end

local Checkbox = vgui.Create( "DCheckBox", Frame )
Checkbox:Center()
Checkbox:SetPos( 65, 105 )
Checkbox:SetChecked( false )

local FLabel6 = vgui.Create( "DLabel", Frame )
FLabel6:Center()
FLabel6:SetPos( 85, 105 )
FLabel6:SetColor(Color(255,0,0,255)) // Color
FLabel6:SetFont("default")
FLabel6:SetText("Never show message again!")
FLabel6:SizeToContents()

local Close = vgui.Create("DButton", Frame)
Close:SetSize(ScrW() * 0.050, ScrH() * 0.025)
Close:Center()
Close:SetPos(105,120)
Close:SetText("Ok")
Close.DoClick = function()
if Checkbox:GetChecked() == true then
net.Start( ADDON_NAME )
	net.WriteEntity(LocalPlayer())
net.SendToServer()
end
	Frame:Close()
end
end)