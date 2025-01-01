if not file.Exists("fancyerrors", "DATA") then
	file.CreateDir("fancyerrors")
end

local enable = CreateConVar("fancyerrors_enabled", "1", {FCVAR_ARCHIVE}, "Enable FancyErrors", 0, 1)

print("FancyErrors starting")
-- CreateConVar("fancyerrors_use_vismesh", "0", FCVAR_USERINFO + FCVAR_ARCHIVE)
-- TODO: figure how to use vismesh
_G.fancyerrors_meshes = _G.fancyerrors_meshes or {}
_G.fancyerrors_models = {}
local throwawayrt_texture = GetRenderTarget("fancyerrors_throwawayrt", 512, 512)
local validated = {}
local queue = {}
local downloading = {}
local messages = {}
local mesh_mat = Material("fancy_errors/tex.vmt")

local function fix_model(entity, model)
	print(model)
	local bones = _G.fancyerrors_models[model][1]
	print(bones)
	entity.fancyerrors_material = _G.fancyerrors_models[model][2]
	entity.fancyerrors_meshes = {}

	if #bones > 1 then
		net.Start("FancyErrors_misc")
		net.WriteString("startragbones")
		net.WriteEntity(entity)
		net.SendToServer()
	end

	for bonen, bone in pairs(bones) do
		PrintTable(bone)
		print(bonen, bone)
		local meshes = bone.meshes

		for _, mesh_ in pairs(meshes) do
			local obj = Mesh(mesh_mat)
			local bone_ = 0

			if bonen ~= 0 then
				bone_ = entity:TranslatePhysBoneToBone(bonen)
			end

			mesh.Begin(obj, MATERIAL_TRIANGLES, math.floor(#mesh_ / 3))

			for v = 1, #mesh_, 3 do
				local v1, v2, v3 = mesh_[v].pos, mesh_[v + 1].pos, mesh_[v + 2].pos
				local n = (v1 - v3):Cross(v1 - v2)

				for _, vt in pairs({v1, v2, v3}) do
					mesh.Position(vt)
					mesh.Normal(n)
					mesh.AdvanceVertex()
				end
			end

			mesh.End()
			_G.fancyerrors_meshes[#_G.fancyerrors_meshes + 1] = obj

			entity.fancyerrors_meshes[#entity.fancyerrors_meshes + 1] = {obj, bone_, bonen}
		end
	end

	local function render_()
		for _, mesh in pairs(entity.fancyerrors_meshes) do
			if not IsValid(mesh[1]) then continue end
			local mat = nil

			if mesh[2] == 0 then
				if entity.bonematrixes then
					mat = entity.bonematrixes[mesh[3]]
				else
					mat = entity:GetWorldTransformMatrix()
				end
			else
				if entity.bonematrixes then
					mat = entity.bonematrixes[mesh[3]]
				else
					mat = entity:GetBoneMatrix(mesh[2])
				end
			end

			local rmat = Matrix(mat)
			local wmat = entity:GetWorldTransformMatrix()

			if entity.bonematrixes then
				wmat = entity.bonematrixes[1]

				if mat == entity.bonematrixes[0] then
					wmat = entity.bonematrixes[0]
				end

				if mat == entity:GetWorldTransformMatrix() then
					wmat = entity:GetWorldTransformMatrix()
				end
			end

			rmat:SetTranslation(wmat:GetTranslation() + (rmat:GetTranslation() - wmat:GetTranslation()))
			cam.PushModelMatrix(rmat)
			mesh[1]:Draw()
			cam.PopModelMatrix()
		end
	end

	entity.fancyerrors_csentity = ClientsideModel("models/hunter/plates/plate.mdl")
	entity.fancyerrors_csentity:SetNoDraw(true)

	entity.fancyerrors_color = ({
		[MAT_ANTLION] = Color(63, 171, 63, 255),
		[MAT_BLOODYFLESH] = Color(255, 63, 0, 255),
		[MAT_CONCRETE] = Color(171, 171, 171, 255),
		[MAT_DIRT] = Color(128, 63, 32, 255),
		[MAT_EGGSHELL] = Color(63, 63, 63, 255),
		[MAT_FLESH] = Color(255, 63, 0, 255),
		[MAT_GRATE] = Color(128, 128, 128, 171),
		[MAT_ALIENFLESH] = Color(63, 171, 63, 255),
		[MAT_CLIP] = Color(0, 0, 0, 255),
		[MAT_SNOW] = Color(171, 171, 171, 255),
		[MAT_PLASTIC] = Color(63, 128, 171, 255),
		[MAT_METAL] = Color(128, 128, 128, 255),
		[MAT_SAND] = Color(203, 189, 147, 255),
		[MAT_FOLIAGE] = Color(0, 255, 127, 255),
		[MAT_COMPUTER] = Color(128, 128, 128, 255),
		[MAT_SLOSH] = Color(0, 128, 128, 128),
		[MAT_TILE] = Color(63, 63, 63, 255),
		[MAT_GRASS] = Color(0, 255, 127, 255),
		[MAT_VENT] = Color(128, 128, 128, 255),
		[MAT_WOOD] = Color(155, 118, 83, 255),
		[MAT_DEFAULT] = Color(255, 255, 255, 255),
		[MAT_GLASS] = Color(0, 171, 255, 128),
		[MAT_WARPSHIELD] = Color(255, 171, 0, 128)
	})[entity.fancyerrors_material] or Color(255, 255, 255, 255)

	-- TODO: collect average color from material and use that instead. lol.
	--entity:SetRenderMode(entity.fancyerrors_color.a >= 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSCOLOR)
	function entity:RenderOverride()
		if not entity.fancyerrors_meshes then return end
		entity:SetRenderMode(entity.fancyerrors_color.a >= 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSCOLOR)
		--render.ResetModelLighting(1, 1, 1)
		--render.ModelMaterialOverride(Material("fancy_errors/invis.vmt"))
		render.PushRenderTarget(throwawayrt_texture)

		render.Model({
			model = "models/hunter/plates/plate.mdl",
			pos = entity:GetPos(),
			angle = entity:GetAngles()
		}, entity.fancyerrors_csentity)

		render.PopRenderTarget()
		--render.ModelMaterialOverride(nil)
		render.SetMaterial(mesh_mat)
		mesh_mat:SetVector("$color", entity.fancyerrors_color:ToVector())
		--mesh_mat:SetVector4D("$color", entity.fancyerrors_color:Unpack())
		mesh_mat:SetFloat("$alpha", entity.fancyerrors_color.a / 255)
		render_()

		render.RenderFlashlights(function()
			render_()
		end)
	end
end

local function do_download(ent)
	if downloading[ent:GetModel() or tostring(ent)] then return end
	validated[ent] = true
	validated[ent:GetModel() or tostring(ent)] = true
	ent.FE_MODEL = ent:GetModel() or tostring(ent)

	if _G.fancyerrors_models[ent:GetModel() or tostring(ent)] then
		fix_model(ent, ent:GetModel() or tostring(ent))

		return
	end

	if file.Exists("fancyerrors/" .. string.Replace(ent:GetModel() or tostring(ent), "/", "_") .. "/data.txt", "DATA") then
		net.Start("FancyErrors_misc")
		net.WriteString("hash")
		net.WriteEntity(ent)
		net.SendToServer()

		return
	end

	downloading[ent:GetModel() or tostring(ent)] = true
	queue[#queue + 1] = ent:GetModel() or tostring(ent)
	net.Start("FancyErrors")
	net.WriteEntity(ent)
	net.SendToServer()
	if #queue > 5 then return true end

	return false
end

concommand.Add("fancyerrors_force_unknown", function()
	if not enable:GetBool() then return end
	local entity = LocalPlayer():GetEyeTrace().Entity
	if not IsValid(entity) or entity == game.GetWorld() then return end
	do_download(entity)
end)

local blacklist = {
	["class C_BaseFlex"] = true,
	["viewmodel"] = true,
	["worldspawn"] = true,
	["env_sprite"] = true,
	["beam"] = true
}

local function fixer()
	if LocalPlayer():IsListenServerHost() then return print("FancyErrors not starting fully: we are listenserver host") end
	if game.SinglePlayer() then return print("FancyErrors not starting fully: in a single player game") end

	timer.Create("fancyerrors_checker", 1, 0, function()
		if not enable:GetBool() then return end

		for k, v in pairs(queue) do
			if _G.fancyerrors_models[v] then
				queue[k] = nil
				downloading[v] = nil
			end
		end

		if #queue > 5 then return end

		for _, ent in ents.Iterator() do
			if blacklist[ent:GetClass()] then continue end
			if ent.FE_MODEL == ent:GetModel() then continue end
			if validated[ent:GetModel()] then continue end

			if not ent:GetModel() then
				ent.FE_PARSED = true
				continue
			end

			if ent:GetModel():StartsWith("*") then
				ent.FE_PARSED = ent:GetModel()
				continue
			end

			if validated[ent] or util.GetModelInfo(ent:GetModel()) then
				ent.FE_PARSED = ent:GetModel()
				continue
			end

			if do_download(ent) then break end
		end
	end)
end

if not IsValid(LocalPlayer()) then
	hook.Add("InitPostEntity", "fancyerrors_start", function()
		fixer()
	end)
else
	fixer()
end

net.Receive("FancyErrors_misc", function()
	local type = net.ReadString()

	if type == "ragbones" then
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		ent.bonematrixes = ent.bonematrixes or {}

		for b = 0, net.ReadUInt(16) do
			net.ReadUInt(16)
			local m = net.ReadMatrix()
			ent.bonematrixes[b] = m
		end
		--ent.bonematrixes[0] = Matrix(ent:GetWorldTransformMatrix())
	end

	if type == "hash" then
		local ent = net.ReadEntity()
		local hash = net.ReadString()
		local data = file.Read("fancyerrors/" .. string.Replace(ent:GetModel() or tostring(ent), "/", "_") .. "/data.txt")
		local hashes = string.Split(data, "\n")
		local found = false

		for _, hash_ in pairs(hashes) do
			if hash == hash_ then
				found = true
				break
			end
		end

		if not found then
			downloading[ent:GetModel() or tostring(ent)] = true
			queue[#queue + 1] = ent:GetModel() or tostring(ent)
			net.Start("FancyErrors")
			net.WriteEntity(ent)
			net.SendToServer()

			return
		end

		print("Found cached model " .. (ent:GetModel() or tostring(ent)) .. " for entity " .. tostring(ent) .. " with hash " .. hash)
		local model = file.Open("fancyerrors/" .. string.Replace(ent:GetModel() or tostring(ent), "/", "_") .. "/" .. hash .. ".txt", "rb", "DATA")

		if not model then
			downloading[ent:GetModel() or tostring(ent)] = true
			queue[#queue + 1] = ent:GetModel() or tostring(ent)
			net.Start("FancyErrors")
			net.WriteEntity(ent)
			net.SendToServer()

			return
		end

		local model_ = {}
		ent.fancyerrors_material = model:ReadUShort()
		local bones = model:ReadUShort()

		for bonen = 0, bones do
			model_[bonen] = {
				meshes = {}
			}

			local bone = model_[bonen].meshes
			local meshes = model:ReadUShort()

			for meshn = 1, meshes do
				bone[meshn] = {}
				local mesh = bone[meshn]
				local vertices = model:ReadULong()

				for vertexn = 1, vertices do
					mesh[vertexn] = {
						pos = Vector(model:ReadDouble(), model:ReadDouble(), model:ReadDouble())
					}
				end
			end
		end

		model:Close()

		_G.fancyerrors_models[ent:GetModel() or tostring(ent)] = {model_, ent.fancyerrors_material}

		fix_model(ent, ent:GetModel() or tostring(ent))
	end
end)

net.Receive("FancyErrors", function()
	local type = net.ReadUInt(2)
	local message_id = net.ReadUInt(16)
	if not messages[message_id] and type ~= 0 then return end

	if type == 0 then
		messages[message_id] = {
			model = net.ReadString(),
			ent = net.ReadEntity(),
			bones = {}
		}

		messages[message_id].ent.fancyerrors_material = net.ReadUInt(8)
		print("Got model " .. messages[message_id].model .. " for entity " .. tostring(messages[message_id].ent))
		notification.AddProgress("fancyerrors_" .. message_id, "[" .. message_id .. "] Downloading model " .. messages[message_id].model .. "... 0 bones 0 meshes (0 vertices)")
	end

	if type == 2 then
		local msg = messages[message_id]
		messages[message_id] = nil

		_G.fancyerrors_models[msg.model] = {msg.bones, msg.ent.fancyerrors_material}

		local hash = util.SHA256(util.TableToJSON(msg.bones))
		file.CreateDir("fancyerrors/" .. string.Replace(msg.ent:GetModel() or tostring(msg.ent), "/", "_"))
		local model = file.Open("fancyerrors/" .. string.Replace(msg.ent:GetModel() or tostring(msg.ent), "/", "_") .. "/" .. hash .. ".txt", "wb", "DATA")

		if model then
			model:WriteUShort(msg.ent.fancyerrors_material)
			model:WriteUShort(#msg.bones)

			for bonen = 0, #msg.bones do
				if msg.bones[bonen] == nil then continue end
				local bone = msg.bones[bonen].meshes
				model:WriteUShort(#bone)

				for meshn = 1, #bone do
					local mesh = bone[meshn]
					model:WriteULong(#mesh)

					for vertexn = 1, #mesh do
						model:WriteDouble(mesh[vertexn].pos.x)
						model:WriteDouble(mesh[vertexn].pos.y)
						model:WriteDouble(mesh[vertexn].pos.z)
					end
				end
			end

			model:Flush()
			file.Write("fancyerrors/" .. string.Replace(msg.ent:GetModel() or tostring(msg.ent), "/", "_") .. "/data.txt", (file.Read("fancyerrors/" .. string.Replace(msg.ent:GetModel() or tostring(msg.ent), "/", "_") .. "/data.txt") or "") .. "\n" .. hash)
		end

		fix_model(msg.ent, msg.model)
		notification.Kill("fancyerrors_" .. message_id)
	end

	if type == 1 then
		local current_bone = net.ReadUInt(16)
		local current_mesh = net.ReadUInt(16)
		local current_vert = net.ReadUInt(16)
		local vertex_count = net.ReadUInt(16)
		local msg = messages[message_id]
		local bone = msg.bones[current_bone]

		if not bone then
			bone = {
				meshes = {}
			}

			msg.bones[current_bone] = bone
		end

		local mesh = bone.meshes[current_mesh]

		if not mesh then
			mesh = {}
			bone.meshes[current_mesh] = mesh
		end

		for i = current_vert, vertex_count do
			mesh[i] = {
				pos = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
			}

			if net.BytesLeft() <= 0 then break end
		end

		local msh, vrt, bns = 0, 0, 0

		for _, v in pairs(msg.bones) do
			bns = bns + 1
			msh = msh + #v.meshes

			for __, vv in pairs(v.meshes) do
				vrt = vrt + #vv
			end
		end

		notification.AddProgress("fancyerrors_" .. message_id, "[" .. message_id .. "] Downloading model " .. messages[message_id].model .. "... " .. bns .. " bones " .. msh .. " meshes (" .. vrt .. " vertices)")
	end
end)

hook.Add("ShutDown", "fancyerrors_freemeshes", function()
	for _, mesh in pairs(_G.fancyerrors_meshes) do
		mesh:Destroy()
	end
end)