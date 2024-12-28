
include('shared.lua')

SWEP.PrintName			= "Кам ган"			
SWEP.Slot				= 3
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

HTable = {}
WTable = {}
XTable = {}
YTable = {}

local CumScreenMat = Material( "effects/blood_core" )

function DrawCum()

	local lfn = LocalPlayer():GetNWFloat("cum") or 0
	if (lfn <= 0) then return end

	surface.SetMaterial( CumScreenMat  )
	surface.SetDrawColor(255, 255, 255,255)
		
	for i=1,lfn do
		if XTable[i] and YTable[i] and WTable[i] and HTable[i] then
			surface.DrawTexturedRect(XTable[i], YTable[i], WTable[i], HTable[i])
		end
	end

end
hook.Add("HUDPaint","CumPaint",DrawCum)

function ToggleCum(msg)
	local lfn = LocalPlayer():GetNWFloat("cum") or 0
	if lfn <= 0 then return end
	for i=1,lfn do
		if HTable[i] == nil then
			RandomH = ScrH() * math.Rand(0.2,1)
			RandomW = ScrW() * math.Rand(0.2,1)
			RandomX = ScrW() * math.Rand(-0.2,1)
			RandomY = ScrH() * math.Rand(-0.2,1)
			table.insert(HTable,RandomH)
			table.insert(WTable,RandomW)
			table.insert(XTable,RandomX)
			table.insert(YTable,RandomY)
		end
	end
end
usermessage.Hook("Cumshot", ToggleCum) 