local ScreenshotRequested = false
local sendInProgress = false
local mapListTable = {}
local mapIconFiles = {}
local xmapList = {}
local isTakingScreenshot = false

net.Receive( "mapicon_sendMapListReceive", function()
	local xmapList2 = net.ReadTable()
	PrintTable(xmapList2)
end )

net.Receive( "mapicon_sendMapIcon", function()
	local fileName = net.ReadString() 
	local fileLength = net.ReadUInt(16)
	local fileContent = net.ReadData(fileLength) 
	fileContent = util.Decompress(fileContent)
	file.Write(fileName, fileContent) 
	print("Map Icon received from server.."..fileName)
	
	net.Start("mapicon_acknowledgeToServer")
	net.SendToServer()
end )

local function getServerMapIcons()
	net.Start("mapicon_sendServerMapIconList")
	net.SendToServer()
end

local function sendMapIcons()
	getServerMapIcons()
end

local function checkTables()
	for k,v in pairs(mapIconFiles) do
		if table.HasValue(mapListTable, v) then
			mapIconFiles[k] = nil
		end
	end
	mapIconFiles = table.ClearKeys( mapIconFiles, false )
end

local function pushMapIconToServer()
	if next(mapIconFiles) == nil then print("All Map Icons sent.") return end
	
	local fileName = "mapicon/"..mapIconFiles[#mapIconFiles]
	local fileContent = file.Read(fileName, "DATA") 
	fileContent = util.Compress( fileContent )
	if fileContent:len()>=64000 then print("Error. File larger than 64kb!.."..fileName) return end
	print("Sending Map Icon..."..fileName)
	net.Start( "mapicon_sendMapIconsToServer" )
		net.WriteString(fileName) 
		net.WriteUInt(#fileContent, 16) 
		net.WriteData(fileContent, fileContent:len()) 
	net.SendToServer()
	mapIconFiles[#mapIconFiles] = nil 
end

local function queue()
	checkTables()
	pushMapIconToServer()
end

net.Receive("mapicon_acknowledgeToClient", function()
	queue()
end)

local function getLocalMapList2()
	local xtable = {}
	if file.Find("mapicon/*.png", "DATA") then
		local files = file.Find("mapicon/*.png", "DATA")
		for k, v in pairs(files) do 
			local v_trim = string.TrimRight( v, ".png" )
			if not table.HasValue( xtable, v_trim ) then
				xtable[table.Count( xtable )+1] = v_trim
			end 
		end
	end
	return xtable
end

local function sendLocalMapList()
	local xtable = getLocalMapList2()
	net.Start("mapicon_sendLocalMapList")
		net.WriteTable(xtable) 
	net.SendToServer()
end

local function getLocalMapList()
	if not LocalPlayer():IsAdmin() then return end
	local xtable = {}
	local files, directories = file.Find("mapicon/*", "DATA")
	for k, v in pairs(directories) do
		if file.Find("mapicon/"..v.."/maps/thumbs/*.png", "DATA") then
			local files2, directories2 = file.Find("mapicon/"..v.."/maps/thumbs/*.png", "DATA")
			for x, y in pairs(files2) do 
				local v_trim = string.TrimRight( y, ".png" )
				if not table.HasValue( xtable, v_trim ) then
					xtable[table.Count( xtable )+1] = v_trim
				end 
			end
		elseif file.Find("mapicon/*.png", "DATA") then
			local files2 = file.Find("mapicon/*.png", "DATA")
			for x, y in pairs(files2) do 
				local v_trim = string.TrimRight( y, ".png" )
				if not table.HasValue( xtable, v_trim ) then
					xtable[table.Count( xtable )+1] = v_trim
				end 
			end
		end
	end
	return xtable
end

local function sendGenRequest()
	xtable = getLocalMapList()
	net.Start( "mapicon_genMapList" )
		net.WriteTable(xtable)
	net.SendToServer()
end

local function getMapList()
	if not LocalPlayer():IsAdmin() then return end
	sendGenRequest()
	net.Start( "mapicon_sendMapList" )
	net.SendToServer()
end

local function RequestAScreenshot()
	if gui.IsGameUIVisible() then gui.HideGameUI() timer.Simple(1, function() gui.ActivateGameUI()  end) end
	ScreenshotRequested = true
	sendGenRequest()
	net.Start( "mapicon_switchmap" )
	net.SendToServer()
end

local function saveMapIcon(xdata)
	local xmaptext = GetConVar( "mapicon_screenshotSize" ):GetInt().."x"..GetConVar( "mapicon_screenshotSize" ):GetInt()
	if not file.Exists( "mapicon/"..xmaptext, "DATA" ) then
		file.CreateDir("mapicon/"..xmaptext.."/maps/thumbs/")
	end
	file.Write( "mapicon/"..xmaptext.."/maps/thumbs/"..game.GetMap()..".png", xdata )
	LocalPlayer():ChatPrint( "[Mapicon_Maker] Screenshot saved to ".."mapicon/"..xmaptext.."/maps/thumbs/"..game.GetMap()..".png" )
end

local function checkForSavedIcons(name)
	if file.Exists("maps/thumbs/" .. name .. ".png", "GAME") then
        return true
    elseif file.Exists("maps/" .. name .. ".png", "GAME") then
        return true
	else
        return false
    end 
end

local function clearSavedIcons()
	local files, directories = file.Find("mapicon/*", "DATA")
	for k, v in pairs(directories) do
		if file.Find("mapicon/"..v.."/maps/thumbs/*.png", "DATA") then
			local files2, directories2 = file.Find("mapicon/"..v.."/maps/thumbs/*.png", "DATA")
			for x, y in pairs(files2) do 
				local v_trim = string.TrimRight( y, ".png" )
				if checkForSavedIcons(v_trim) then
					file.Delete( "mapicon/"..v.."/maps/thumbs/"..y, "DATA" )
				end
			end
		end
	end
end

local function createBrowser()
	
	local panel = vgui.Create("DFrame")
	panel:MakePopup()
	panel:SetSize(ScrW() * 0.75, ScrH() * 0.75)
	panel:Center()
	panel:SetTitle("")
	panel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(132, 132, 132))
	end
	
	surface.CreateFont( "ButtonFont", {
		font = "DermaLarge",
		size = 22,
		weight = 900,
	} )

	local dprop = vgui.Create("DPropertySheet", panel)
	dprop:StretchToParent(10,30,10,10)
	dprop.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(125, 125, 125))
	end

	local clientPanel = vgui.Create("DPanel",dprop)
	clientPanel:StretchToParent(0,0,0,0)
	clientPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(179, 179, 179))
	end

	local outerFilterPanel = vgui.Create("DPanel", clientPanel)
	outerFilterPanel:SetWide(200)
	outerFilterPanel:SetPos(0,30)
	outerFilterPanel:StretchToParent(nil,nil,nil,50)
	outerFilterPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(125, 125, 125, 232))
	end

	-- local clientPanel = vgui.Create("DPanel",dprop)
	-- clientPanel:SetSize(500,500)
	-- clientPanel:StretchToParent(0,0,0,0)


	dprop:AddSheet("Client", clientPanel, "icon16/user.png", false, false)

	-- dprop:AddSheet("Server")
	-- dprop:AddSheet("Options")
end
concommand.Add("smm_menu", createBrowser)
hook.Add( "InitPostEntity", "AutoMapIcon", function()
	if LocalPlayer():IsAdmin() then 
		if !ConVarExists("mapicon_screenshotSize") then 
			CreateConVar( "mapicon_screenshotSize", "312", {FCVAR_ARCHIVE,FCVAR_USERINFO}, "Screenshot size in pixels" )
		end
		if !ConVarExists("mapicon_syncPlayerMapIconsWithServer") then 
			CreateConVar( "mapicon_syncPlayerMapIconsWithServer", "0", {FCVAR_ARCHIVE,FCVAR_USERINFO}, "Whether or not Map Icons inside server's /data/mapicon folder should be sent to clients" )
		end
		if !ConVarExists("mapicon_showScreenshotArea") then 
			CreateConVar( "mapicon_showScreenshotArea", "0", {FCVAR_ARCHIVE}, "Shows a small screen of what the screenshot will look like in the top left" )
		end
		if !ConVarExists("mapicon_switchMapAfterScreenshot") then 
			CreateConVar( "mapicon_switchMapAfterScreenshot", "1", {FCVAR_ARCHIVE,FCVAR_USERINFO}, "Whether or not to automatically switch map after you've made a screenshot" )
		end
		if !ConVarExists("mapicon_cleanAlreadyExistingMapIcons") then 
			CreateConVar( "mapicon_cleanAlreadyExistingMapIcons", "1", {FCVAR_ARCHIVE}, "Whether or not to delete Map Icons (that you took) of Maps that already have a Map Icon in their map files" )
		end
		concommand.Add( "mapicon_screenshot", RequestAScreenshot )
		concommand.Add( "mapicon_getMapList", getMapList )
		concommand.Add( "mapicon_pushMapIconsToServer", sendMapIcons )
		

		local xmaptext = GetConVar( "mapicon_screenshotSize" ):GetInt().."x"..GetConVar( "mapicon_screenshotSize" ):GetInt()
		if not file.Exists( "mapicon", "DATA" ) or not file.Exists( "mapicon/"..xmaptext.."/maps/thumbs/", "DATA" ) then
			file.CreateDir("mapicon/"..xmaptext.."/maps/thumbs/")
		end
		
		hook.Add( "HUDPaint", "mapicon_drawInfoText", function()
			if GetConVar( "mapicon_showScreenshotArea" ):GetInt()==1 then
				surface.SetFont( "CloseCaption_Bold" )
				surface.SetTextColor( 255, 255, 255 )
				surface.SetTextPos( 10, GetConVar( "mapicon_screenshotSize" ):GetInt()+8 ) 
				surface.DrawText( "Screenshot Size: "..xmaptext )
			end
		end )
		hook.Add( "PostRender", "take_screenshot", function()
		if isTakingScreenshot then return end
			if (( ScreenshotRequested ) or GetConVar( "mapicon_showScreenshotArea" ):GetInt()==1) and isTakingScreenshot == false then 
				if ScreenshotRequested then
					isTakingScreenshot = true
					
				end
				cam.Start2D()
					if ( ScreenshotRequested ) then
						render.PushRenderTarget(GetRenderTarget("screenshot_rt", 512, 512))
					end
					LocalPlayer():DrawViewModel(false)
					LocalPlayer():DrawShadow(false)
					for k, v in ipairs(ents.FindByClass("physgun_beam")) do
						if v:IsValid() and v:GetOwner() == LocalPlayer() then
							v:SetNoDraw(true)
						end
					end
					
					ent = LocalPlayer()
					local cdata = {}
					cdata.origin = ent:GetPos()+Vector(0,0,65)
					cdata.angles = ent:GetAngles()
					
					cdata.x = 0
					cdata.y = 0
					cdata.w = GetConVar( "mapicon_screenshotSize" ):GetInt()
					cdata.h = GetConVar( "mapicon_screenshotSize" ):GetInt()
					cdata.aspect = 1.0
					
					cdata.fov = LocalPlayer():GetFOV()-15
					cdata.znear = 20
					
					if not gui.IsGameUIVisible() or ScreenshotRequested then
						render.RenderView(cdata)
					end
					if ( ScreenshotRequested ) then
						local data = render.Capture(cdata)
						saveMapIcon(data)
						render.PopRenderTarget()
					end
					LocalPlayer():DrawViewModel(true)
					for _, v in ipairs(ents.FindByClass("physgun_beam")) do
						if v:IsValid() and v:GetOwner() == LocalPlayer() then
							v:SetNoDraw(false)
						end
					end
					
				cam.End2D()
				ScreenshotRequested = false
				isTakingScreenshot = false
			else return end
		end )
	end
	if ConVarExists( "mapicon_cleanAlreadyExistingMapIcons" ) then
		if GetConVar("mapicon_cleanAlreadyExistingMapIcons"):GetInt() == 1 then
			clearSavedIcons()
		end
	end
	sendLocalMapList()
end)

net.Receive( "mapicon_retrieveServerMapIconList", function()
	xmapList = net.ReadTable()
	if not table.IsEmpty(xmapList) then
		table.Merge( mapListTable, xmapList )
	end
	mapIconFiles = file.Find("mapicon/*.png", "DATA")
	queue()
end )


