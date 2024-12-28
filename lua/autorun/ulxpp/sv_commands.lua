
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

util.AddNetworkString('ULXPP.sin')
util.AddNetworkString('ULXPP.banish')
util.AddNetworkString('ULXPP.coloredmessage')
util.AddNetworkString('ULXPP.Profile')
util.AddNetworkString('ULXPP.confuse')

DAMAGE_MODE_NONE = 0
DAMAGE_MODE_BUDDHA = 1
DAMAGE_MODE_ENABLED = 2
DAMAGE_MODE_AIM = 3

local C = ULib.cmds
local UP = Vector(0, 0, 10000)

ULXPP.Funcs = {
	mhp = function(ply, targets, hp)
		for k, ply in ipairs(targets) do
			ply:SetMaxHealth(hp)
		end
		
		ulx.fancyLogAdmin(ply, "#A set max health for #T to #i", targets, hp)
	end,
	
	rocket = function(ply, targets)
		for k, ply in pairs(targets) do
			ply:SetVelocity(UP)
		end
		
		timer.Simple(1, function()
			for k, ply in ipairs(targets) do
				if not IsValid(ply) then continue end
				
				local effectdata = EffectData()
				effectdata:SetOrigin(ply:GetPos())
				
				util.Effect("Explosion", effectdata)
				ply:Kill()
			end
		end)
		
		ulx.fancyLogAdmin(ply, "#A rocketed #T", targets)
	end,
	
	trainfuck = function(ply, targets)
		for k, ply in pairs(targets) do
			local ent = ents.Create('dbot_admin_train')
			ent:Spawn()
			ent:SetPlayer(ply)
			ply:ExitVehicle()
			ent.time = CurTime() + 4
		end
		
		ulx.fancyLogAdmin(ply, "#A trainfucked #T", targets)
	end,
	
	roll = function(ply, amount)
		amount = amount or 6
		local r = math.random(1, amount)
		ulx.fancyLogAdmin(ply, "#A rolled (#i) #i", amount, r)
	end,
	
	unsin = function(ply, targets)
		for k, ply in pairs(targets) do
			if not ply.ULXPP_SINPOS then 
				ULXPP.Error(ply, string.format('%s is not sinused!', ply:Nick()))
				targets[k] = nil
				continue 
			end
			
			local id = tostring(ply) .. '_ulxpp_sin'
			
			timer.Remove(id)
			
			hook.Remove('Think', id)
			hook.Remove('Move', id)
			
			ply.ULXPP_SINPOS = nil
			
			net.Start('ULXPP.sin')
			net.WriteBool(false)
			net.Send(ply)
		end
		
		ulx.fancyLogAdmin(ply, "#A unsinused #T", targets)
	end,
	
	sin = function(ply, targets, time)
		for k, ply in pairs(targets) do
			if ply.ULXPP_SINPOS then 
				ULXPP.Error(ply, string.format('%s is already sinused!', ply:Nick()))
				targets[k] = nil
				continue 
			end
			
			ply:ExitVehicle()
			ply.ULXPP_SINPOS = ply:GetPos() + Vector(0, 0, 50)
			local id = tostring(ply) .. '_ulxpp_sin'
			
			net.Start('ULXPP.sin')
			net.WriteBool(true)
			net.WriteVector(ply.ULXPP_SINPOS)
			net.Send(ply)
			
			hook.Add('Think', id, function()
				if not IsValid(ply) then return end
				ply:ExitVehicle()
				ply:SetPos(ply.ULXPP_SINPOS + Vector(0, 0, math.sin(CurTime()) * 50))
			end)
			
			hook.Add('Move', id, function(ply2, mv)
				if ply2 ~= ply then return end
				mv:SetOrigin(ply.ULXPP_SINPOS + Vector(0, 0, math.sin(CurTime()) * 50))
				return true
			end)
			
			timer.Create(id, time, 1, function()
				hook.Remove('Think', id)
				hook.Remove('Move', id)
				
				if IsValid(ply) then
					ply.ULXPP_SINPOS = nil
					
					net.Start('ULXPP.sin')
					net.WriteBool(false)
					net.Send(ply)
				end
			end)
		end
		
		ulx.fancyLogAdmin(ply, "#A sinused #T for #i seconds", targets, time)
	end,
	
	unbanish = function(ply, targets)
		for k, ply in pairs(targets) do
			if not ply.ULXPP_BANISHED then 
				ULXPP.Error(ply, string.format('%s is not banished!', ply:Nick()))
				targets[k] = nil
				continue 
			end
			
			ply.ULXPP_BANISHED = false
			
			net.Start('ULXPP.banish')
			net.WriteBool(false)
			net.Send(ply)
			ULXPP.RestorePreviousFuncsState(ply, 'banish')
		end
		
		ulx.fancyLogAdmin(ply, "#A unbanished #T", targets)
	end,
	
	banish = function(ply, targets)
		for k, ply in pairs(targets) do
			if ply.ULXPP_BANISHED then 
				ULXPP.Error(ply, string.format('%s is already banished!', ply:Nick()))
				targets[k] = nil
				continue 
			end
			
			ply.ULXPP_BANISHED = true
			
			ULXPP.StorePreviousFuncsState(ply, 'banish', {
				{
					func = 'SetNoDraw',
					gfunc = 'GetNoDraw',
					newval = true,
				},{
					func = 'SetSolid',
					gfunc = 'GetSolid',
					newval = SOLID_NONE,
				},{
					func = 'SetCollisionGroup',
					gfunc = 'GetCollisionGroup',
					newval = COLLISION_GROUP_NONE,
				},{
					func = 'Freeze',
					gfunc = 'IsFrozen',
					newval = true,
				},{
					func = 'SetPos',
					gfunc = 'GetPos',
					newval = Vector(0, 0, -16000),
				},
			})
			
			net.Start('ULXPP.banish')
			net.WriteBool(true)
			net.Send(ply)
		end
		
		ulx.fancyLogAdmin(ply, "#A banished #T", targets)
	end,
	
	loadout = function(ply, targets)
		for k, ply in pairs(targets) do
			hook.Run('PlayerLoadout', ply)
		end
		
		ulx.fancyLogAdmin(ply, "#A loadouted #T", targets)
	end,
	
	giveammo = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			local wep = ply:GetActiveWeapon()
			
			if not IsValid(wep) then
				ULXPP.Error(ply, string.format('%s is not holding a valid weapon!', ply:Nick()))
				targets[k] = nil
				continue 
			end
			
			ply:GiveAmmo(amount, wep:GetPrimaryAmmoType())
			ply:GiveAmmo(amount, wep:GetSecondaryAmmoType())
		end
		
		ulx.fancyLogAdmin(ply, "#A gived ammo to #T #i", targets, amount)
	end,
	
	giveweapon = function(ply, targets, str)
		for k, ply in pairs(targets) do
			local wep = ply:Give(str)
			
			if not IsValid(wep) then
				ULXPP.Error(ply, string.format('Failed to give weapon to %s!', ply:Nick()))
				targets[k] = nil
				continue 
			end
		end
		
		ulx.fancyLogAdmin(ply, "#A gave weapon #s to #T", str, targets)
	end,
	
	nodraw = function(ply, targets)
		for k, ply in pairs(targets) do
			ply:SetNoDraw(true)
		end
		
		ulx.fancyLogAdmin(ply, "#A set no draw for #T to true", targets)
	end,
	
	unnodraw = function(ply, targets)
		for k, ply in pairs(targets) do
			ply:SetNoDraw(false)
		end
		
		ulx.fancyLogAdmin(ply, "#A set no draw for #T to false", targets)
	end,
	
	uarmor = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			ply:SetArmor(amount)
		end
		
		ulx.fancyLogAdmin(ply, "#A set armor for #T to #i", targets, amount)
	end,
	
	jumppower = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			ply:SetJumpPower(amount)
		end
		
		ulx.fancyLogAdmin(ply, "#A set the jump power for #T to #i", targets, amount)
	end,
	
	walkspeed = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			ply:SetWalkSpeed(amount)
		end
		
		ulx.fancyLogAdmin(ply, "#A set the walk speed for #T to #i", targets, amount)
	end,
	
	runspeed = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			ply:SetRunSpeed(amount)
		end
		
		ulx.fancyLogAdmin(ply, "#A set the run speed for #T to #i", targets, amount)
	end,
	
	ctsay = function(ply, color, message)
		net.Start('ULXPP.coloredmessage')
		net.WriteColor(Color(unpack(string.Explode(' ', color))))
		net.WriteString(message)
		net.Broadcast()
	end,
	
	ip = function(ply, targets)
		local c = ply
		
		for k, ply in pairs(targets) do
			ULXPP.PText(c, Color(200, 200, 200), 'IP address of ', team.GetColor(ply:Team()), ply:Nick(), Color(200, 200, 200), ' is ', string.Explode(':', ply:IPAddress())[1])
		end
	end,
	
	uid = function(ply, targets)
		local c = ply
		
		for k, ply in pairs(targets) do
			ULXPP.PText(c, Color(200, 200, 200), 'UniqueID of ', team.GetColor(ply:Team()), ply:Nick(), Color(200, 200, 200), ' is ', ply:UniqueID())
		end
	end,
	
	steamid64 = function(ply, targets)
		local c = ply
		
		for k, ply in pairs(targets) do
			ULXPP.PText(c, Color(200, 200, 200), 'SteamID 64 of ', team.GetColor(ply:Team()), ply:Nick(), Color(200, 200, 200), ' is ', ply:SteamID64())
		end
	end,
	
	steamid = function(ply, targets)
		local c = ply
		
		for k, ply in pairs(targets) do
			ULXPP.PText(c, Color(200, 200, 200), 'SteamID of ', team.GetColor(ply:Team()), ply:Nick(), Color(200, 200, 200), ' is ', ply:SteamID())
		end
	end,
	
	profile = function(ply, targets)
		net.Start('ULXPP.Profile')
		net.WriteTable(targets)
		net.Send(ply)
	end,
	
	confuse = function(ply, targets)
		for k, ply in pairs(targets) do
			if ply.ULXPP_CONFUSED then 
				ULXPP.Error(ply, string.format('%s is already confused!', ply:Nick()))
				targets[k] = nil
				continue 
			end
			
			ply.ULXPP_CONFUSED = true
			local id = tostring(ply) .. '_ulxpp_confuse'
			
			net.Start('ULXPP.confuse')
			net.WriteBool(true)
			net.Send(ply)
			
			hook.Add('Move', id, function(ply2, mv)
				if not IsValid(ply) then
					hook.Remove('Move', id)
					return
				end
				
				if ply2 ~= ply then return end
				mv:SetSideSpeed(-mv:GetSideSpeed())
			end)
		end
		
		ulx.fancyLogAdmin(ply, "#A confused #T", targets)
	end,
	
	unconfuse = function(ply, targets)
		for k, ply in pairs(targets) do
			if not ply.ULXPP_CONFUSED then 
				ULXPP.Error(ply, string.format('%s is not confused!', ply:Nick()))
				targets[k] = nil
				continue 
			end
			
			ply.ULXPP_CONFUSED = nil
			local id = tostring(ply) .. '_ulxpp_confuse'
			
			net.Start('ULXPP.confuse')
			net.WriteBool(false)
			net.Send(ply)
			
			hook.Remove('Move', id)
		end
		
		ulx.fancyLogAdmin(ply, "#A unconfused #T", targets)
	end,
	
	respawn = function(ply, targets)
		for k, ply in pairs(targets) do
			if ply:Alive() then 
				ULXPP.Error(ply, string.format('%s is not dead!', ply:Nick()))
				targets[k] = nil
				continue 
			end
			
			ply:Spawn()
		end
		
		ulx.fancyLogAdmin(ply, "#A respawned #T", targets)
	end,
	
	sendlua = function(ply, targets, str)
		for k, ply in pairs(targets) do
			ply:SendLua(str)
		end
	end,
	
	frespawn = function(ply, targets)
		for k, ply in pairs(targets) do
			if ply:Alive() then 
				ply:Kill()
			end
			
			--Next frame
			timer.Simple(0, function()
				ply:Spawn()
			end)
		end
		
		ulx.fancyLogAdmin(ply, "#A respawned #T", targets)
	end,
	
	bot = function(ply, num)
		num = num or 1
		
		for i = 1, num do
			RunConsoleCommand('bot')
		end
		
		ulx.fancyLogAdmin(ply, "#A created #i bots", num)
	end,
	
	kickbots = function(ply)
		for k, v in pairs(player.GetAll()) do
			if v:IsBot() then
				v:Kick('Kicked bot from server')
			end
		end
		
		ulx.fancyLogAdmin(ply, "#A kicked all bots from server")
	end,
	
	silence = function(ply, targets)
		for k, v in pairs(targets) do
			v.ulx_gagged = true
			v.gimp = 2
			v:SetNWBool("ulx_gagged", true)
			v:SetNWBool("ulx_muted", true)
		end
		
		ulx.fancyLogAdmin(ply, "#A silenced #T", targets)
	end,
	
	unsilence = function(ply, targets)
		for k, v in pairs(targets) do
			v.ulx_gagged = false
			v.gimp = nil
			v:SetNWBool("ulx_gagged", false)
			v:SetNWBool("ulx_muted", false)
		end
		
		ulx.fancyLogAdmin(ply, "#A unsilenced #T", targets)
	end,
	
	cleanmap = function(ply)
		ulx.fancyLogAdmin(ply, "#A cleaned up map")
		
		game.CleanUpMap()
	end,
	
	buddha = function(ply, targets)
		for k, v in pairs(targets) do
			v:GodDisable() --Remove godmode flag
			v:SetSaveValue('m_takedamage', DAMAGE_MODE_BUDDHA)
		end
		
		ulx.fancyLogAdmin(ply, "#A enabled buddha mode on #T", targets)
	end,
	
	unbuddha = function(ply, targets)
		for k, v in pairs(targets) do
			v:GodDisable() --Remove godmode flag
			v:SetSaveValue('m_takedamage', DAMAGE_MODE_ENABLED)
		end
		
		ulx.fancyLogAdmin(ply, "#A disabled buddha mode on #T", targets)
	end,
}

hook.Add('PlayerDeath', 'ULX++', function(ply)
	if ply:GetSaveTable().m_takedamage == DAMAGE_MODE_BUDDHA then
		ply:SetSaveValue('m_takedamage', DAMAGE_MODE_ENABLED)
	end
end)
