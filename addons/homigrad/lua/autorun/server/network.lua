if game.SinglePlayer() then return end
module("seats_network_optimizer")

local i
local seats
local last_enabled

hook.Add("OnEntityCreated", "seats_network_optimizer", function(ent)
	if ent:IsValid() and ent:GetClass() == "prop_vehicle_prisoner_pod" then
		ent:AddEFlags(EFL_NO_THINK_FUNCTION)
		ent.seats_network_optimizer = true
	end
end)

hook.Add("Think", "seats_network_optimizer", function()
	if not seats or not seats[i] then
		i = 1
		seats = {}

		for _, seat in ipairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
			if seat.seats_network_optimizer then
				table.insert(seats, seat)
			end
		end
	end

	while seats[i] and not IsValid(seats[i]) do
		i = i + 1
	end

	local seat = seats[i]

	if last_enabled ~= seat and IsValid(last_enabled) then
		local saved = last_enabled:GetSaveTable()

		if not saved["m_bEnterAnimOn"] and not saved["m_bExitAnimOn"] then
			last_enabled:AddEFlags(EFL_NO_THINK_FUNCTION)
			last_enabled = nil
		end
	end

	if IsValid(seat) then
		seat:RemoveEFlags(EFL_NO_THINK_FUNCTION)
		last_enabled = seat
	end

	i = i + 1
end)

local function EnteredOrLeaved(ply, seat)
	if IsValid(seat) and seat.seats_network_optimizer then
		table.insert(seats, i, seat)
	end
end

hook.Add("PlayerEnteredVehicle", "seats_network_optimizer", EnteredOrLeaved)
hook.Add("PlayerLeaveVehicle", "seats_network_optimizer", EnteredOrLeaved)