
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

if SERVER then
	AddCSLuaFile()
	AddCSLuaFile('autorun/ulxpp/sh_properties.lua')
	AddCSLuaFile('autorun/ulxpp/sh_commands.lua')
	AddCSLuaFile('autorun/ulxpp/cl_commands.lua')
	AddCSLuaFile('autorun/ulxpp/cl_chat.lua')
	
	util.AddNetworkString('ULXPP.Chat')
end

ULXPP = ULXPP or {}
ULXPP.COMMANDS = ULXPP.COMMANDS or {}
ULXPP.EMPTY_FUNCTION = function() end

function ULXPP.UnpackCommand(str)
	return string.sub(str, 5)
end

function ULXPP.GetCommand(class)
	if ULXPP.COMMANDS[class] then return ULXPP.COMMANDS[class].obj end
	
	for k, data in pairs(ulx.cmdsByCategory) do
		for i, obj in pairs(data) do
			if ULXPP.UnpackCommand(obj.cmd) == class then return obj end
		end
	end
end

function ULXPP.Error(ply, str)
	ULib.tsayError(ply, str, true)
end

function ULXPP.StorePreviousFuncsState(ply, class, array)
	ply.ULXPP_STATE = ply.ULXPP_STATE or {}
	ply.ULXPP_STATE[class] = {}
	
	for k, v in pairs(array) do
		table.insert(ply.ULXPP_STATE[class], {
			func = v.func,
			gfunc = v.gfunc,
			value = ply[v.gfunc](ply),
		})
		
		ply[v.func](ply, v.newval)
	end
end

function ULXPP.RestorePreviousFuncsState(ply, class)
	ply.ULXPP_STATE = ply.ULXPP_STATE or {}
	
	for k, v in pairs(ply.ULXPP_STATE[class]) do
		ply[v.func](ply, v.value)
	end
end

function ULXPP.CreateCommand(class, data)
	data.params = data.params or {}
	ULXPP.COMMANDS[class] = data
	
	local obj = ulx.command(data.category or 'ULXPP', 'ulx ' .. class, data.callback or ULXPP.EMPTY_FUNCTION, '!' .. class)
	obj:defaultAccess(data.access or ULib.ACCESS_ADMIN)
	obj:help(data.help or 'Undefined')
	
	if data.player then
		ULXPP.PlayerArg(obj)
	end
	
	for k, v in pairs(data.params) do
		obj:addParam(v)
	end
	
	ULXPP.COMMANDS[class].obj = obj
	
	return obj
end

function ULXPP.PlayerArg(obj)
	obj:addParam{type = ULib.cmds.PlayersArg}
	return obj
end

include('autorun/ulxpp/sh_properties.lua')
include('autorun/ulxpp/sh_commands.lua')

if SERVER then
	function ULXPP.PText(ply, ...)
		net.Start('ULXPP.Chat')
		net.WriteTable({...})
		net.Send(ply)
	end
	
	include('autorun/ulxpp/sv_chat.lua')
else
	include('autorun/ulxpp/cl_commands.lua')
	include('autorun/ulxpp/cl_chat.lua')
end

