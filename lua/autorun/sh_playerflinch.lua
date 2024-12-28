hook.Add("Initialize", "SetupUnstableFlinches", function()

	CreateConVar("sv_st_uselookups", "0", {FCVAR_REPLICATED, FCVAR_NOTIFY}, "Use more accurate, but less reliable animations? (THIS CAN LOOK VERY BAD)" )

end )