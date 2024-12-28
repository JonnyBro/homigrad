
--Not running in ULX folder because it does not being loaded using VLL
if SERVER then
	AddCSLuaFile('autorun/ulxpp/sh_init.lua')
end

timer.Simple(0, function()
	include('autorun/ulxpp/sh_init.lua')
end)
