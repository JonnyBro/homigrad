if game.GetMap() ~= "rp_desert_conflict" then return end

local ids = {2493, 2496, 2502, 2500}

hook.Add("PostCleanupMap", "RemoveMapEnts", function()
	for _, id in ipairs(ids) do
		local ent = ents.GetMapCreatedEntity(id)

		if IsValid(ent) then
			ent:Remove()
		end
	end
end)