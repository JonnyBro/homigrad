TFAVOX_Models = TFAVOX_Models or {}

if SERVER then
	--timer.Simple( 0.2, function()
		local tbl
		if lf_playermodel_selector_get_voxlist and isfunction( lf_playermodel_selector_get_voxlist ) then tbl = lf_playermodel_selector_get_voxlist() end
		if istable( tbl ) then
			for k, v in pairs( tbl ) do
				TFAVOX_Models[k] = TFAVOX_Models[v]
			end
		end
	--end )
end
