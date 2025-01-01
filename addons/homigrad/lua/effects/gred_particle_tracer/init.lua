
local PATTACH_WORLDORIGIN = PATTACH_WORLDORIGIN
local CAL_TABLE = {
	[1] = "7mm",
	[2] = "12mm",
	[3] = "20mm",
	[4] = "30mm",
	[5] = "40mm",
}
local COL_TABLE = {
	[1] = "red",
	[2] = "green",
	[3] = "white",
	[4] = "yellow",
	-- [5] = "blue",
}

local SPEED_TABLE = {
	[1] = 60000*60000,
	[2] = 42000*42000,
	[3] = 36000*36000,
	[4] = 30000*30000,
	[5] = 24000*24000,
}

function EFFECT:Init(data)
	local World = Entity(0)
	local particle = gred.Particles[data:GetFlags()]
	local pos = data:GetOrigin()
	local endpos = data:GetStart()
	local cal = data:GetFlags()
	local particle = CreateParticleSystem(World,"gred_tracers_"..COL_TABLE[data:GetMaterialIndex()].."_"..CAL_TABLE[cal],PATTACH_WORLDORIGIN,0,pos)
	if !particle then return end
	particle:SetControlPoint(1,endpos)
	timer.Simple((pos:DistToSqr(endpos)*6.8 / SPEED_TABLE[cal]),function()
		particle:StopEmission(false,true)
	end)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()

end