file.CreateDir("homigrad/fogs/")

local function getName()
	return "homigrad/fogs/" .. game.GetMap() .. ".txt"
end

function ReadFogSetting()
	return util.JSONToTable(file.Read(getName(), "DATA") or "") or {}
end

-- NOTE: Do we need this?

function SetupFogSetting()
	local tbl = ReadFogSetting()

	SetGlobalVar("Fog Dis", tbl[1] or false)

	local color = tbl[2]

	if color then
		SetGlobalVar("Fog Color", Vector(color.r, color.g, color.b))
	else
		SetGlobalVar("Fog Color", false)
	end
end

SetupFogSetting()