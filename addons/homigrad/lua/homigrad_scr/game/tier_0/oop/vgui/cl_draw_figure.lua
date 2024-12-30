local pngParametrs = "mips"
local materials = {}
local constructManual = {"sphere"}

for i, name in pairs(constructManual) do
	materials[name] = Material("homigrad/vgui/models/" .. name .. ".png", pngParametrs)
end

function surface.SetFigure(name)
	surface.SetMaterial(materials[name])
end

function draw.Figure(x, y, w, h)
	surface.DrawTexturedRect(x, y, w, h)
end