
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

--Adding really fucking needed slash to commands
--i REALLY don't know why it is not added officially
local function sayCmdCheck(ply, strText, bTeam)
	if string.sub(strText, 1, 1) ~= '/' then return end
	strText = '!' .. string.sub(strText, 2)
	
	local match
	
	for str, data in pairs(ULib.sayCmds) do
		local str2 = str
		
		if strText:len() < str:len() then
			str2 = string.Trim(str)
		end

		if strText:sub(1, str2:len()):lower() == str2 then
			if not match or match:len() <= str:len() then
				match = str
			end
		end
	end

	if not match then return end
	
	local data = ULib.sayCmds[match]

	local args = string.Trim(strText:sub(match:len() + 1))
	local argv = ULib.splitArgs(args)

	if data.__cmd then
		local return_value = hook.Call(ULib.HOOK_COMMAND_CALLED, _, ply, data.__cmd, argv)
		if return_value == false then return end
	end

	if not ULib.ucl.query(ply, data.access) then
		ULib.tsay(ply, "You do not have access to this command, " .. ply:Nick() .. ".")
		return ""
	end

	local fn = data.fn
	local hide = data.hide

	ULib.pcallError(fn, ply, match:Trim(), argv, args)
	return ''
end

hook.Add("PlayerSay", "ULib_saycmdslash", sayCmdCheck, HOOK_HIGH)
