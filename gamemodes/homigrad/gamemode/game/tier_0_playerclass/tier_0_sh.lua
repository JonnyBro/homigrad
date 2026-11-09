player.classList = player.classList or {}

local classList = player.classList
local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:GetPlayerClass()
	return classList[self.PlayerClassName or ""]
end

local meta

function PlayerMeta:PlayerClassEvent(name, ...)
	meta = self:GetPlayerClass()
	meta = meta and meta[name]
	if meta then return meta(self, ...) end
end

function player.RegClass(name)
	local class = classList[name] or {}
	classList[name] = class

	return class
end

DEFAULT_VIEW_OFFSET = Vector(0, 0, 64)
DEFAULT_VIEW_OFFSET_DUCKED = Vector(0, 0, 32)

DEFAULT_JUMP_POWER = 185 -- 284
DEFAULT_STEP_SIZE = 18
DEFAULT_MASS = 80
DEFAULT_MODELSCALE = 1

hook.Add("PlayerFootstep", "PlayerClass", function(ply, ...)
	return ply:PlayerClassEvent("PlayerFootstep", ...)
end)

function player.EventPoint(pos, name, radius, ...)
	for _, ply in player.Iterator() do
		if ply:GetPos():Distance(pos) > radius then continue end

		ply:PlayerClassEvent("EventPoint", name, pos, radius, ...)
	end
end

function player.Event(ply, name, ...)
	ply:PlayerClassEvent("Event", name, ...)
end

hook.Add("Move", "PlayerClass", function(ply, mv) ply:PlayerClassEvent("Move", mv) end)
hook.Add("SetupMove", "PlayerClass", function(ply, mv) ply:PlayerClassEvent("SetupMove", mv) end)

if SERVER then return end

net.Receive("setupclass", function()
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end

	ply.PlayerClassName = net.ReadString()
	ply.PlayerClassNameOld = net.ReadString()

	old = classList[ply.PlayerClassNameOld]
	if old and old.Off then old.Off(ply) end

	ply:PlayerClassEvent("On")
end)

hook.Add("PreCalcView", "PlayerClass", function(ply, vec, ang, fov, znear, zfar) return ply:PlayerClassEvent("CalcView", vec, ang, fov, znear, zfar) end)
hook.Add("PrePlayerDraw", "PlayerClass", function(ply, flag) return ply:PlayerClassEvent("PlayerDraw", flag) end)
hook.Add("HUDPaint", "PlayerClass", function() LocalPlayer():PlayerClassEvent("HUDPaint") end)