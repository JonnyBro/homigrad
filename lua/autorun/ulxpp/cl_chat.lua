
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

--Because of how ULib is made
--I can not provide anything better for autocomplete in chat
--I just CAN'T EVEN UNDERTSAND ULib!

local ENABLE = CreateConVar('ulx_autocomplete', '1', FCVAR_ARCHIVE, 'Enable chat autocomplete')

local function RealSplit(str, ignore)
	local len = #str
	local reply = {}
	local TOKEN_LEVEL = 0
	local currentstr = ''
	
	for i = 1, len do
		local char = str[i]
		if not ignore and char == '-' then break end
		
		if char == ' ' and TOKEN_LEVEL == 0 then
			table.insert(reply, currentstr)
			currentstr = ''
			continue
		elseif char == '<' then
			TOKEN_LEVEL = TOKEN_LEVEL + 1
		elseif char == '>' or char == ']' then --[<Some text: <Some Val>] --!!!, > last one is missing
			TOKEN_LEVEL = math.max(TOKEN_LEVEL - 1, 0)
		end
		
		currentstr = currentstr .. char
	end
	
	table.insert(reply, currentstr)
	
	return reply
end

local ShouldDraw = false

local function StartChat()
	if not ENABLE:GetBool() then return end
	ShouldDraw = true
end

local function FinishChat()
	if not ENABLE:GetBool() then return end
	ShouldDraw = false
end

local Drawn = {}
local curcommand = ''
local curtoken = ''
local COMMAND_IS_VALID = false

local function ChatTextChanged(str)
	if not ENABLE:GetBool() then return end
	local token = str[1]
	Drawn = {}
	if token ~= '/' and token ~= '!' then return end
	curtoken = token
	
	local split = string.Explode(' ', str)
	local find = string.sub(split[1], 2)
	local len = #find
	
	local Found = {}
	
	for k, data in pairs(ulx.cmdsByCategory) do
		for i, obj in pairs(data) do
			if not obj.say_cmd then continue end
			if string.sub(ULXPP.UnpackCommand(obj.cmd), 1, len) == find then table.insert(Found, obj) end
		end
	end
	
	Drawn[1] = 'ULX Chat Commands:'
	local last
	
	local ply = LocalPlayer()
	local total = 0
	local playerTarget = false
	local targetPly
	
	for k, v in pairs(Found) do
		local access = ULib.ucl.query(ply, v.cmd)
		if not access then continue end
		
		playerTarget = false
		
		if total > 10 then
			table.insert(Drawn, '<...>')
			break
		end
		
		local usage = v:getUsage(ply)
		local usplit = RealSplit(usage, true)
		
		for k, v in pairs(usplit) do
			if v == '-' then break end
			if v == '<player>' or v == '<players>' then 
				playerTarget = true 
				targetPly = split[k + 1]
			end
			
			if split[k + 1] then
				usplit[k] = split[k + 1]
			end
		end
		
		local format = token .. ULXPP.UnpackCommand(v.cmd) .. ' ' .. table.concat(usplit, ' ')
		if table.HasValue(Drawn, format) then continue end --eh
		total = total + 1
		
		last = ULXPP.UnpackCommand(v.cmd)
		
		table.insert(Drawn, format)
	end
	
	if total == 0 then
		Drawn[1] = 'No ULX command match.'
		COMMAND_IS_VALID = false
	elseif total == 1 then
		Drawn[1] = 'ULX Chat Command, to paste all missed arguments press TAB.'
		curcommand = last
		COMMAND_IS_VALID = true
		
		local hit = false
		
		if playerTarget then
			local target = targetPly and targetPly ~= '' and targetPly ~= ' ' and string.lower(targetPly)
			
			for k, v in pairs(player.GetAll()) do
				if target then 
					if not string.find(string.lower(v:Nick()), target) then continue end
				end
				
				local return_value, msg = hook.Run(ULib.HOOK_PLAYER_TARGET, LocalPlayer(), curcommand, v)
				if return_value == false then continue end
				
				if not hit then
					hit = true
					
					if not target then
						table.insert(Drawn, 'Valid targets:')
					else
						table.insert(Drawn, 'Match targets:')
					end
				end
				
				table.insert(Drawn, v:Nick())
			end
			
			if not hit then
				table.insert(Drawn, 'No match')
			end
		end
	else
		COMMAND_IS_VALID = false
	end
end

surface.CreateFont('ULXPP.Autocomplete', {
	font = 'Roboto',
	size = 18,
	weight = 500,
	extended = true,
})

local function HUDPaint()
	if not ENABLE:GetBool() then return end
	if not ShouldDraw then return end
	
	local x, y = chat.GetChatBoxPos()
	local w, h = chat.GetChatBoxSize()
	
	x = x + w + 3
	y = y - 20
	
	surface.SetFont('ULXPP.Autocomplete')
	
	for k, v in pairs(Drawn) do
		local w, h = surface.GetTextSize(v)
		surface.SetDrawColor(0, 0, 0, 200)
		surface.SetTextColor(255, 255, 255)
		surface.DrawRect(x - 3, y - 2, w + 6, h + 4)
		surface.SetTextPos(x, y)
		surface.DrawText(v)
		y = y + h + 8
	end
end

local function OnChatTab(str)
	if not ENABLE:GetBool() then return end
	if not ShouldDraw then return end
	if not COMMAND_IS_VALID then return end
	
	local command = Drawn[2]
	local split1 = string.Explode(' ', str)
	local split2 = RealSplit(command)
	
	split1[1] = curtoken .. curcommand
	local output = table.concat(split1, ' ')
	
	for k, v in pairs(split2) do
		if v == '-' then break end --We hit help end
		if split1[k] then continue end
		output = output .. ' ' .. v
	end
	
	return output
end

hook.Add('StartChat', 'ULXPP.Autocomplete', StartChat)
hook.Add('FinishChat', 'ULXPP.Autocomplete', FinishChat)
hook.Add('ChatTextChanged', 'ULXPP.Autocomplete', ChatTextChanged)
hook.Add('HUDPaint', 'ULXPP.Autocomplete', HUDPaint)
hook.Add('OnChatTab', 'ULXPP.Autocomplete', OnChatTab)
