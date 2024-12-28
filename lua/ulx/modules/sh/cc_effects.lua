local CAT_NAME = "Fun";

local ULXCCTrails = {
	"trails/tube.vmt",
	"trails/electric.vmt",
	"trails/smoke.vmt",
	"trails/plasma.vmt",
	"trails/lol.vmt",
	"trails/physbeam.vmt",
	"trails/laser.vmt",
	"trails/love.vmt"
};

local ULXCCMaterials = {
	"nil",
	"models/wireframe",
	"debug/env_cubemap_model",
	"models/shadertest/shader3",
	"models/shadertest/shader4",
	"models/shadertest/shader5",
	"models/shiny",
	"models/debug/debugwhite",
	"Models/effects/comball_sphere",
	"Models/effects/comball_tape",
	"Models/effects/splodearc_sheet",
	"Models/effects/vol_light001",
	"models/props_combine/stasisshield_sheet",
	"models/props_combine/portalball001_sheet",
	"models/props_combine/com_shield001a",
	"models/props_c17/frostedglass_01a",
	"models/props_lab/Tank_Glass001",
	"models/props_combine/tprings_globe",
	"models/rendertarget",
	"models/screenspace",
	"brick/brick_model",
	"models/props_pipes/GutterMetal01a",
	"models/props_pipes/Pipesystem01a_skin3",
	"models/props_wasteland/wood_fence01a",
	"models/props_foliage/tree_deciduous_01a_trunk",
	"models/props_c17/FurnitureFabric003a",
	"models/props_c17/FurnitureMetal001a",
	"models/props_c17/paper01",
	"models/flesh",
	"phoenix_storms/metalset_1-2",
	"phoenix_storms/metalfloor_2-3",
	"phoenix_storms/plastic",
	"phoenix_storms/wood",
	"phoenix_storms/bluemetal",
	"phoenix_storms/cube",
	"phoenix_storms/dome",
	"phoenix_storms/gear",
	"phoenix_storms/stripes",
	"phoenix_storms/wire/pcb_green",
	"phoenix_storms/wire/pcb_red",
	"phoenix_storms/wire/pcb_blue",
	"hunter/myplastic"
};

local trailtbl = {};
function ulx.trail(calling_ply, target_plys, color, startWidth, endWidth, lifeTime, texture, bRemove)
	if (!endWidth) then
		endWidth = startWidth;
		calling_ply:ChatPrint("[CONSOLE]: Invalid value for \"endWidth\". Value has been set to startWidth.");
	end
	if (!lifeTime) then
		lifeTime = 16;
		calling_ply:ChatPrint("[CONSOLE]: Invalid value for \"lifeTime\". Value has been set to 16.");
	end
	if (!texture) then
		texture = table.Random(ULXCCTrails);
		calling_ply:ChatPrint("[CONSOLE]: Invalid value for \"texture\". Value has been randomized to \"" .. tostring(texture) .. "\".");
	end
	if (!bRemove) then
		color = string.lower(tostring(color));
		for k, v in pairs(ULXCCColors) do
			if (k == color) then
				color = ULXCCColors[k];
			end
		end
		for i = 1, #target_plys do
			if (trailtbl[target_plys[i]:SteamID()]) then
				table.RemoveByValue(trailtbl, target_plys[i]:SteamID());
				SafeRemoveEntity(trailtbl[target_plys[i]:SteamID()]);
			end
			trailtbl[target_plys[i]:SteamID()] = util.SpriteTrail(target_plys[i], 0, color, true, startWidth, endWidth, lifeTime, 1 / (startWidth + endWidth) * 0.5, texture);
		end
		ulx.fancyLogAdmin(calling_ply, "#A gave trails to #T", target_plys);
	else
		for i = 1, #target_plys do
			if (trailtbl[target_plys[i]:SteamID()]) then
				table.RemoveByValue(trailtbl, target_plys[i]:SteamID());
				SafeRemoveEntity(trailtbl[target_plys[i]:SteamID()]);
			end
		end
		ulx.fancyLogAdmin(calling_ply, "#A removed trails from #T", target_plys);
	end
end

local trail = ulx.command(CAT_NAME, "ulx trail", ulx.trail, "!trail");
trail:addParam{type = ULib.cmds.PlayersArg};
trail:addParam{type = ULib.cmds.StringArg, hint = "Color", completes = ULXCCColorTblTxt, ULib.cmds.restrictToCompletes};
trail:addParam{type = ULib.cmds.NumArg, default = 16, hint = "Start Width"};
trail:addParam{type = ULib.cmds.NumArg, default = 0, hint = "End Width"};
trail:addParam{type = ULib.cmds.NumArg, default = 5, hint = "Length"};
trail:addParam{type = ULib.cmds.StringArg, hint = "type", completes = ULXCCTrails, ULib.cmds.restrictToCompletes};
trail:addParam{type = ULib.cmds.BoolArg, invisible = true};
trail:defaultAccess(ULib.ACCESS_ADMIN);
trail:help("Attach a trail to the selected target(s).");
trail:setOpposite("ulx removetrail", {_, _, _, _, _, _, _, true}, "!removetrail");

function ulx.material(calling_ply, target_plys, material, bReset)
	if (!material) then
		material = table.Random(ULXCCTrails);
	end
	if (!bReset) then
		for _, v in ipairs(target_plys) do
			v:SetMaterial(material);
		end
		ulx.fancyLogAdmin(calling_ply, "#A set the material for #T to #s", target_plys, material);
	else
		for _, v in ipairs(target_plys) do
			v:SetMaterial(nil);
		end
		ulx.fancyLogAdmin(calling_ply, "#A reset the material for #T", target_plys);
	end
end
local material = ulx.command(CAT_NAME, "ulx material", ulx.material, {"!mat", "!material"});
material:addParam{type = ULib.cmds.PlayersArg};
material:addParam{type = ULib.cmds.StringArg, hint = "material", completes = ULXCCMaterials, ULib.cmds.restrictToCompletes};
material:addParam{type = ULib.cmds.BoolArg, invisible = true};
material:help("Set a player's material.");
material:defaultAccess(ULib.ACCESS_ADMIN);
material:setOpposite("ulx resetmaterial", {_, _, _, true}, {"!rmat", "!resetmaterial"});

function ulx.color(calling_ply, target_plys, color, bReset)
	if (bReset) then
		for _, v in ipairs(target_plys) do
			v:SetColor(255, 255, 255);
		end
		ulx.fancyLogAdmin(calling_ply, "#A reset the color for #T", target_plys);
	else
		color = string.lower(tostring(color));
		for k, v in pairs(ULXCCColors) do
			if (k == color) then
				color = ULXCCColors[k];
			end
		end
		for _, v in ipairs(target_plys) do
			v:SetColor(color);
		end
		ulx.fancyLogAdmin(calling_ply, "#A set the color for #T to #s", target_plys, color);
	end
end
local color = ulx.command(CAT_NAME, "ulx color", ulx.color, {"!color", "!setcolor"});
color:addParam{type = ULib.cmds.PlayersArg};
color:addParam{type = ULib.cmds.StringArg, hint = "Color", completes = ULXCCColorTblTxt, ULib.cmds.restrictToCompletes};
color:addParam{type = ULib.cmds.BoolArg, invisible = true};
color:defaultAccess(ULib.ACCESS_ADMIN);
color:help("Change target(s) color to a selected color.");
color:setOpposite("ulx resetcolor", {_, _, _, true}, {"!rcolor", "!rcol", "!resetcolor"});
