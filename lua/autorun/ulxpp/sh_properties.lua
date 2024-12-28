
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

ULXPP.Properties = ULXPP.Properties or {}

function ULXPP.AddProperty(class, menuopen)
	ULXPP.Properties[class] = {obj = ULXPP.GetCommand(class), menuopen = menuopen}
end

local Property = {
	MenuLabel = 'ULX',
	Order = 0,
	Filter = function(self, ent, ply)
		return ent:IsPlayer()
	end,
	
	MenuOpen = function(self, menu, ent, tr)
		local ply = LocalPlayer()
		local hit = false
		
		local sub = menu:AddSubMenu()
		local nick = ent:Nick()
		
		for k, v in pairs(ULXPP.Properties) do
			local access = ULib.ucl.query(ply, 'ulx ' .. k)
			if not access then continue end
			hit = true
			local menu2 = sub:AddOption(k, function()
				RunConsoleCommand('ulx', k, nick)
			end)
			
			if v.obj then
				menu2:SetTooltip(v.obj:getUsage(ply))
			end
			
			menu2.command = k
			menu2.nick = nick
			
			if v.menuopen then
				v.menuopen(self, menu2, ent, tr)
			end
		end
		
		if not hit then
			menu:Remove()
		end
	end,
	
	Action = function() end,
}

properties.Add('ulxpp', Property)

local function CreateLoop(start, End, step, format)
	return function(self, menu2, ent, tr)
		local sub = menu2:AddSubMenu()
		
		for i = start, End, step do
			sub:AddOption(string.format(format, i), function()
				RunConsoleCommand('ulx', menu2.command, menu2.nick, i)
			end)
		end
	end
end

ULXPP.AddProperty('slap', CreateLoop(5, 100, 5, '%s damage'))
ULXPP.AddProperty('slay')
ULXPP.AddProperty('sslay')
ULXPP.AddProperty('jail', CreateLoop(20, 120, 20, 'For %s seconds'))
ULXPP.AddProperty('sin', CreateLoop(5, 20, 5, 'For %s seconds'))
ULXPP.AddProperty('ignite', CreateLoop(20, 300, 20, 'For %s seconds'))
ULXPP.AddProperty('hp', CreateLoop(20, 500, 20, '%s hp'))
ULXPP.AddProperty('mhp', CreateLoop(20, 500, 20, '%s hp'))
ULXPP.AddProperty('unignite')
ULXPP.AddProperty('unjail')
ULXPP.AddProperty('unsin')
ULXPP.AddProperty('ip')
ULXPP.AddProperty('uid')
ULXPP.AddProperty('steamid64')
ULXPP.AddProperty('steamid')
ULXPP.AddProperty('profile')
ULXPP.AddProperty('freeze')
ULXPP.AddProperty('unfreeze')
ULXPP.AddProperty('loadout')
ULXPP.AddProperty('trainfuck')
ULXPP.AddProperty('rocket')
ULXPP.AddProperty('frespawn')
