AddCSLuaFile()

hg.modesHooks = {}

function hg.LoadModes()
	for _, name in pairs(LevelList) do
		local mode = _G[name]

		for k, v2 in pairs(mode) do
			if isfunction(v2) then
				hg.modesHooks[name] = hg.modesHooks[name] or {}
				hg.modesHooks[name][k] = v2
			end
		end
	end
end

local oldHook = oldHook or hook.Call

function hook.Call(name, gm, ...)
	local current = roundActiveName

	if hg.modesHooks[current] and hg.modesHooks[current][name] then
		local a, b, c, d, e, f = hg.modesHooks[current][name](...)
		if a ~= nil then return a, b, c, d, e, f end
	end

	return oldHook(name, gm, ...)
end