
--[[
Copyright (C) 2016-2017 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

net.Receive('ULXPP.sin', function()
	local status = net.ReadBool()
	
	if status then
		local Pos = net.ReadVector()
		
		hook.Add('Move', 'ULXPP_SIN', function(ply, mv)
			mv:SetOrigin(Pos + Vector(0, 0, math.sin(CurTime()) * 50))
			return true
		end)
	else
		hook.Remove('Move', 'ULXPP_SIN')
	end
end)

net.Receive('ULXPP.confuse', function()
	local status = net.ReadBool()
	
	if status then
		hook.Add('Move', 'ULXPP_CONFUSE', function(ply, mv)
			mv:SetSideSpeed(-mv:GetSideSpeed())
		end)
	else
		hook.Remove('Move', 'ULXPP_CONFUSE')
	end
end)

net.Receive('ULXPP.banish', function()
	ULXPP.BANISHED = net.ReadBool()
end)

net.Receive('ULXPP.coloredmessage', function()
	chat.AddText(net.ReadColor(), net.ReadString())
end)

net.Receive('ULXPP.Chat', function()
	chat.AddText(unpack(net.ReadTable()))
end)

net.Receive('ULXPP.Profile', function()
	for k, ply in pairs(net.ReadTable()) do
		gui.OpenURL('http://steamcommunity.com/profiles/' .. ply:SteamID64())
	end
end)

hook.Add('PostDrawHUD', '!ULXPP.Banish', function()
	if ULXPP.BANISHED then 
		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		return true 
	end
end, -1)

hook.Add('HUDPaint', '!ULXPP.Banish', function()
	if ULXPP.BANISHED then 
		surface.SetDrawColor(color_black)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		return true 
	end
end, -1)

hook.Add('HUDShouldDraw', 'ULXPP.Banish', function(str)
	if not ULXPP.BANISHED then return end
	if str == 'CHudMenu' then return end
	if str == 'CHudChat' then return end
	if str == 'NetGraph' then return end
	if str == 'CHudGMod' then return end
	
	return false
end)