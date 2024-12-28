util.AddNetworkString( "mapicon_switchmap" )
util.AddNetworkString( "mapicon_genMapList" )
util.AddNetworkString( "mapicon_sendIconToServer" )
util.AddNetworkString( "mapicon_sendMapList" )
util.AddNetworkString( "mapicon_sendMapListReceive" )
util.AddNetworkString( "mapicon_sendLocalMapList" )
util.AddNetworkString( "mapicon_sendMapIcon" )
util.AddNetworkString( "mapicon_sendServerMapIconList" )
util.AddNetworkString( "mapicon_retrieveServerMapIconList" )
util.AddNetworkString( "mapicon_sendMapIconsToServer" )
util.AddNetworkString( "mapicon_acknowledgeToServer" )
util.AddNetworkString( "mapicon_acknowledgeToClient" )

local sendInProgress = false
local playerToMapList = {}

if !ConVarExists("mapicon_syncPlayerMapIconsWithServer") then 
	CreateConVar( "mapicon_syncPlayerMapIconsWithServer", "0", {FCVAR_ARCHIVE,FCVAR_REPLICATED}, "Whether or not Map Icons inside server's /data/mapicon folder should be sent to clients" )
end
if !ConVarExists("mapicon_switchMapAfterScreenshot") then 
	CreateConVar( "mapicon_switchMapAfterScreenshot", "1", {FCVAR_ARCHIVE,FCVAR_REPLICATED}, "Whether or not to automatically switch map after you've made a screenshot" )
end


local function checkForIcon(name)
	if file.Exists("maps/thumbs/" .. name .. ".png", "GAME") then
        return true
    elseif file.Exists("maps/" .. name .. ".png", "GAME") then
        return true
	elseif file.Exists("mapicon/" .. name .. ".png", "DATA") then
        return true
	else
        return false
    end 
end

local function genMapList(xtable)
	if xtable == nil then xtable = {} end
	local xmaps = file.Find("maps/*.bsp", "GAME")
	local mapList = {}
	local found = false
	for k, v in pairs(xmaps) do
		local v_trim = string.TrimRight( v, ".bsp" )
		if not checkForIcon(v_trim) and not (v_trim == "test_hardware" or v_trim == "test_speakers") and not table.HasValue( xtable, v_trim ) then
			mapList[#mapList + 1] = v_trim
			found = true
		end
	end
	if found then
		file.Write("mapicon/maplist.txt", util.TableToJSON( mapList, true ) )
	end
end

local function getMapList()
	if file.Exists("mapicon/maplist.txt", "DATA" ) then
		local xmapList = util.JSONToTable( file.Read( "mapicon/maplist.txt", "DATA" ) )
		return xmapList
	end
end

local function getMapIconList()
	local xtable = {}
	if file.Find("mapicon/*.png", "DATA") then
		xtable = file.Find("mapicon/*.png", "DATA")
	else 
		xtable = {}
	end
	return xtable
end

local function prepareMapIcons()
	local xmaplist = util.JSONToTable( file.Read( "mapicon/maplist.txt", "DATA" ) )
	local xmaplistkey = table.KeyFromValue( xmaplist, game.GetMap() )
	if xmaplist[xmaplistkey]!=nil then
		xmaplist[xmaplistkey] = nil
		file.Write("mapicon/maplist.txt", util.TableToJSON( xmaplist, true ) )
	end
	if GetConVar("mapicon_switchMapAfterScreenshot"):GetInt()==1 then
		timer.Simple( 1, function() 
			RunConsoleCommand("gamemode","sandbox")
			RunConsoleCommand("changelevel",xmaplist[#xmaplist])
		end )
	end
end

local function sendMapIconsToPlayer()
	
	local xtable2 = file.Find("mapicon/*.png", "DATA")
	if GetConVar("mapicon_syncPlayerMapIconsWithServer"):GetInt()~=1 
		or sendInProgress 
		or next(xtable2) == nil 
	then 
		return  
	end
	--PrintTable(playerToMapList)
	if table.Count(playerToMapList) == 0 then
		timer.Remove("mapicon_svqueueTimer") 
		return
	else
		for a, b in pairs(playerToMapList) do
			if table.Count(b) < 1 then
				playerToMapList[a] = nil
			else
				for c, d in pairs(b) do
					if table.Count(d) < 1 then
						b[c] = nil
					else
						for e, f in pairs(d) do
							if f == nil then
								d[e] = nil
							else
								local v_trim = string.TrimRight(f, ".png")
								local fileName = "mapicon/"..v_trim..".png"
								local fileContent = file.Read(fileName, "DATA")
								fileContent = util.Compress(fileContent)
								playerToMapList[a][c][e] = nil
								if fileContent:len()>=64000 then print("Error. File larger than 64kb!.."..fileName) return end
								net.Start("mapicon_sendMapIcon")
									net.WriteString(fileName)
									net.WriteUInt(#fileContent, 16)
									net.WriteData(fileContent, fileContent:len())
								net.Send(c)
								print("Map Icon sent.."..fileName.." to "..tostring(c))
								break
							end
						end
					end
				end
			end
		end
	end

	
end

local function queue()
	sendMapIconsToPlayer()
end

net.Receive("mapicon_acknowledgeToServer", function()
	queue()
end)

local function savePlayerToMapList(xtable, ply)
	local xtable2 = file.Find("mapicon/*.png", "DATA")
	for k,v in pairs(xtable2) do
		local v_trim = string.TrimRight( v, ".png" )
		if table.HasValue(xtable, v_trim) then
		xtable2[table.KeyFromValue( xtable2, v )] = nil
		end
	end
	xtable2 = table.ClearKeys( xtable2, false )
	playerToMapList[table.Count(playerToMapList)+1] = {[ply] = xtable2}
	queue()
end

hook.Add( "Initialize", "mapicon_setup", function()
	if not file.Exists( "mapicon", "DATA" ) then
		file.CreateDir("mapicon")
    end
	
	if not file.Exists( "mapicon/maplist.txt", "DATA" ) then
		genMapList()
	end
	local files, directories = file.Find( "mapicon/*.png", "DATA" )
	if not table.IsEmpty(files) then
		for k,v in ipairs(files) do
			resource.AddSingleFile( "data/mapicon/"..v )
		end
	end
end)

net.Receive( "mapicon_switchmap", function()
	prepareMapIcons()
end )

net.Receive( "mapicon_genMapList", function()
	local xtable = net.ReadTable()
	genMapList(xtable)
end )

net.Receive( "mapicon_sendLocalMapList", function(len, ply)
	if GetConVar("mapicon_syncPlayerMapIconsWithServer"):GetInt()~=1 then return end
	local xtable = {}
	xtable = net.ReadTable()
	savePlayerToMapList(xtable, ply)
end )

net.Receive( "mapicon_sendMapList", function( len, ply )
	local xmapList = getMapList()
	net.Start( "mapicon_sendMapListReceive" )
		net.WriteTable(xmapList)
	net.Send(ply)
end )

net.Receive( "mapicon_sendServerMapIconList", function( len, ply )
	local xmapList = getMapIconList()
	net.Start( "mapicon_retrieveServerMapIconList" )
		net.WriteTable(xmapList)
	net.Send(ply)
end )

net.Receive( "mapicon_sendMapIconsToServer", function(len, ply)
	local fileName = net.ReadString() 
	local fileLength = net.ReadUInt(16)
	local fileContent = net.ReadData(fileLength) 
	fileContent = util.Decompress(fileContent)
	file.Write(fileName, fileContent) 
	print("Received Map Icon.."..fileName.." from "..tostring(ply))
	net.Start("mapicon_acknowledgeToClient")
	net.Send(ply)
end )