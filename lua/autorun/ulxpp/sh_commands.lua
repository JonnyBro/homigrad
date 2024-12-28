
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

local C = ULib.cmds

local ENT = {}

ENT.Type = 'anim'
ENT.PrintName = 'Trainfuck'
ENT.Author = 'DBot'

function ENT:Initialize()
	self.time = CurTime() + 4
	self:SetModel("models/props_combine/CombineTrain01a.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:Wake()
			phys:EnableGravity(false)
			self.phys = phys
		end
	end
end

function ENT:SetPlayer(ply)
	self.Player = ply
	
	local pos = ply:GetPos()
	pos.x = pos.x + math.random(-1000,1000)
	pos.y = pos.y + math.random(-1000,1000)
	pos.z = pos.z + 20
	
	self:SetPos(pos)
end

function ENT:PhysicsCollide(tab)
	if tab.HitEntity ~= self.Player then return end
	self.Player:GodDisable()
	self.Player:TakeDamage(2 ^ 31 - 1, self, self)
end

function ENT:Think()
	if CLIENT then return end
	
	if self.time < CurTime() then
		SafeRemoveEntity(self)
		return
	end
	
	if not IsValid(self.Player) then return end
	local ply = self.Player
	
	ply:ExitVehicle()
	local pos = ply:GetPos()
	local newpos = self:GetPos()
	
	local normal = pos - newpos
	
	local ang = (normal):Angle()
	ang.y = ang.y + 180
	
	self:SetAngles(ang)
	
	if self.phys then
		self.phys:ApplyForceCenter(normal:GetNormalized() * 10^10) --heh c:
	end
	
	if not ply:GetNWBool("Spectator") and ply:GetMoveType() ~= MOVETYPE_WALK then 
		ply:SetMoveType(MOVETYPE_WALK) 
	end
end

scripted_ents.Register(ENT, 'dbot_admin_train')

ULXPP.Funcs = {}
--Functions not called clientside
if SERVER then
	include('autorun/ulxpp/sv_commands.lua')
end

ULXPP.Declared = {
	mhp = {
		help = 'Set max health of target(s)',
		category = 'Дополнительно',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2^31 - 1, hint = 'hp', C.round}
		}
	},
	
	roll = {
		help = 'Rolls the dice',
		category = 'Дополнительно',
		access = ULib.ACCESS_ALL,
		params = {
			{type = C.NumArg, min = 1, max = 256, hint = 'number of faces', C.round, C.optional}
		}
	},
	
	rocket = {
		help = 'Rockets target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	trainfuck = {
		help = 'Trainfucks target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	sin = {
		help = 'Forces target(s) to float in air',
		category = 'Дополнительно',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 20, hint = 'time', C.round}
		}
	},
	
	unsin = {
		help = 'Unfloats target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	banish = {
		help = 'Banish target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	unbanish = {
		help = 'Banish target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	loadout = {
		help = 'Gives their loadout to target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	giveammo = {
		help = 'Gives ammo for their current weapon to target(s)',
		category = 'Дополнительно',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 9999, hint = 'amount', C.round}
		}
	},
	
	giveweapon = {
		help = 'Gives weapon to target(s)',
		category = 'Дополнительно',
		player = true,
		params = {
			{type = C.StringArg, default = 'weapon_crowbar'}
		}
	},
	
	nodraw = {
		help = 'SetNoDraw for target(s) to true',
		category = 'Дополнительно',
		player = true,
	},
	
	unnodraw = {
		help = 'SetNoDraw for target(s) to false',
		category = 'Дополнительно',
		player = true,
	},
	
	uarmor = {
		help = 'Same as ulx armor but unlimited',
		category = 'Дополнительно',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2 ^ 31 - 1, hint = 'amount', C.round}
		}
	},
	
	ctsay = {
		help = 'Prints colored message to chatbox of all players',
		category = 'Дополнительно',
		params = {
			{type = C.StringArg, default = '200 200 200', hint = 'color'},
			{type = C.StringArg, default = 'Sample text', hint = 'message'},
		}
	},
	
	ip = {
		help = 'Prints target(s) IPs',
		category = 'Дополнительно',
		player = true,
	},
	
	confuse = {
		help = 'Confuses target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	unconfuse = {
		help = 'Unconfuses target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	respawn = {
		help = 'Respawns target(s) if they are dead',
		category = 'Дополнительно',
		player = true,
	},
	
	sendlua = {
		help = 'SendLua for target(s)',
		category = 'Дополнительно',
		player = true,
		access = ULib.ACCESS_SUPERADMIN,
		params = {
			{type = C.StringArg, default = '', hint = 'lua'},
		}
	},
	
	frespawn = {
		help = 'Forces Respawn of target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	uid = {
		help = 'Prints target(s) UniqueID',
		category = 'Дополнительно',
		player = true,
		access = ULib.ACCESS_ALL,
	},
	
	steamid64 = {
		help = 'Prints target(s) SteamID64',
		category = 'Дополнительно',
		player = true,
		access = ULib.ACCESS_ALL,
	},
	
	steamid = {
		help = 'Prints target(s) SteamID',
		category = 'Дополнительно',
		player = true,
		access = ULib.ACCESS_ALL,
	},
	
	profile = {
		help = 'Opens profile(s) of target(s)',
		category = 'Дополнительно',
		player = true,
		access = ULib.ACCESS_ALL,
	},
	
	jumppower = {
		help = 'Sets Jump Power of Target(s)',
		category = 'Дополнительно',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2 ^ 16, hint = 'power', C.round}
		}
	},
	
	walkspeed = {
		help = 'Sets Walk Speed of Target(s)',
		category = 'Дополнительно',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2 ^ 16, hint = 'power', C.round}
		}
	},
	
	runspeed = {
		help = 'Sets Run Speed of Target(s)',
		category = 'Дополнительно',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2 ^ 16, hint = 'power', C.round}
		}
	},
	
	silence = {
		help = 'Mute and Gag target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	unsilence = {
		help = 'Unmute and Ungag target(s)',
		category = 'Дополнительно',
		player = true,
	},
	
	buddha = {
		help = 'Enable buddha mode\nSame as godmode, but player\ngetting affected by knockback',
		category = 'Дополнительно',
		player = true,
	},
	
	unbuddha = {
		help = 'Disable buddha mode',
		category = 'Дополнительно',
		player = true,
	},
	
	bot = {
		help = 'Creates bots',
		category = 'Дополнительно',
		access = ULib.ACCESS_SUPERADMIN,
		params = {
			{type = C.NumArg, min = 1, max = 32, hint = 'number', C.round, C.optional, default = 1}
		}
	},
	
	kickbots = {
		help = 'Kicks all bots',
		category = 'Дополнительно',
	},
	
	cleanmap = {
		help = 'Runs game.CleanUpMap()',
		category = 'Дополнительно',
	},
}

for k, v in pairs(ULXPP.Declared) do
	v.callback = ULXPP.Funcs[k]
	local obj = ULXPP.CreateCommand(k, v)
	if v.post then
		v.post(obj)
	end
end
