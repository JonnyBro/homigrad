print("FancyErrors starting")
util.AddNetworkString("FancyErrors")
util.AddNetworkString("FancyErrors_misc")

local function fake_send(entity, ply)
	local message_id = math.random(0, 65535)
	net.Start("FancyErrors")
	net.WriteUInt(0, 2) -- transfer initialise
	net.WriteUInt(message_id, 16)

	if IsValid(entity) then
		net.WriteString(entity:GetModel() or tostring(entity))
	else
		net.WriteString("")
	end

	net.WriteEntity(entity)
	net.Send(ply)
	net.Start("FancyErrors")
	net.WriteUInt(2, 2) -- transfer finished
	net.WriteUInt(message_id, 16)
	net.Send(ply)

	return
end

net.Receive("FancyErrors_misc", function(_, ply)
	local type = net.ReadString()

	if type == "hash" then
		local ent = net.ReadEntity()
		net.Start("FancyErrors_misc")
		net.WriteString("hash")
		net.WriteEntity(ent)

		if not IsValid(ent:GetPhysicsObject()) then
			net.WriteString("ffffffffffffffffffffffffffffffff")
		else
			local bones = {
				[0] = {
					meshes = {ent:GetPhysicsObject():GetMesh()}
				}
			}

			if ent:GetPhysicsObjectCount() > 1 then
				for i = 0, ent:GetPhysicsObjectCount() - 1 do
					local bone = ent:GetPhysicsObjectNum(i)

					bones[i] = {
						meshes = {bone:GetMesh()}
					}
				end
			end

			net.WriteString(util.SHA256(util.TableToJSON(bones)))
		end

		net.Send(ply)

		return
	end

	if type == "startragbones" then
		local entity = net.ReadEntity()

		local bones = {
			[0] = {
				meshes = {entity:GetPhysicsObject():GetMesh()}
			}
		}

		if entity:GetPhysicsObjectCount() > 1 then
			for i = 0, entity:GetPhysicsObjectCount() - 1 do
				local bone = entity:GetPhysicsObjectNum(i)

				bones[i] = {
					meshes = {bone:GetMesh()}
				}
			end

			local tname = "fancyerrors_ragdoll_bonesync_" .. entity:EntIndex() .. "_ply_" .. ply:AccountID()

			timer.Create(tname, 1 / 5, 0, function()
				if not IsValid(entity) then return timer.Remove(tname) end
				net.Start("FancyErrors_misc", true)
				net.WriteString("ragbones")
				net.WriteEntity(entity)
				net.WriteUInt(#bones, 16)

				for b = 0, #bones do
					net.WriteUInt(entity:TranslatePhysBoneToBone(b), 16)
					net.WriteMatrix(entity:GetBoneMatrix(entity:TranslatePhysBoneToBone(b)))
				end

				net.Send(ply)
			end)
		end

		return
	end
end)

net.Receive("FancyErrors", function(_, ply)
	local entity = net.ReadEntity()
	if not IsValid(entity) or entity == game.GetWorld() then return fake_send(entity, ply) end
	local physobj = entity:GetPhysicsObject()
	if not IsValid(physobj) then return fake_send(entity, ply) end

	local bones = {
		[0] = {
			meshes = {physobj:GetMesh()}
		}
	}

	if entity:GetPhysicsObjectCount() > 1 then
		for i = 0, entity:GetPhysicsObjectCount() - 1 do
			local bone = entity:GetPhysicsObjectNum(i)

			bones[i] = {
				meshes = {bone:GetMesh()}
			}
		end
	end

	local message_id = math.random(0, 65535)
	net.Start("FancyErrors")
	net.WriteUInt(0, 2) -- transfer initialise
	net.WriteUInt(message_id, 16)
	net.WriteString(entity:GetModel())
	net.WriteEntity(entity)
	net.WriteUInt(entity:GetMaterialType(), 8)
	net.Send(ply)
	local current_mesh = 1
	local current_bone = 0
	local current_vert = 1
	local max_message_size = 63.5 * 1024

	local function write_vec(vec)
		net.WriteFloat(vec[1])
		net.WriteFloat(vec[2])
		net.WriteFloat(vec[3])
	end

	local coro = coroutine.create(function()
		-- just for safety
		for _ = 0, 10000 do
			local message_size = 0
			net.Start("FancyErrors")
			net.WriteUInt(1, 2) -- transfer in progress
			net.WriteUInt(message_id, 16)
			net.WriteUInt(current_bone, 16)
			net.WriteUInt(current_mesh, 16)
			net.WriteUInt(current_vert, 16)
			message_size = message_size + 2 * 3 -- message id, current mesh and vert
			local bone = bones[current_bone]
			local mesh = bone.meshes[current_mesh]
			local verticies = util.GetModelMeshes(entity:GetModel())[current_mesh].verticies
			net.WriteUInt(#mesh, 16)
			message_size = message_size + 2 -- vert amount

			for i = current_vert, #mesh do
				if not verticies[i] then
					verticies[i] = {}
				end

				write_vec(mesh[i].pos)
				message_size = message_size + 4 * 3
				current_vert = i
				if message_size >= max_message_size then break end
			end

			if current_vert >= #mesh then
				current_mesh = current_mesh + 1
				current_vert = 1
			end

			net.Send(ply)

			if current_mesh > #bone + 1 then
				current_bone = current_bone + 1
				current_mesh = 1
			end

			if current_bone > #bones then break end
			coroutine.yield()
		end

		net.Start("FancyErrors")
		net.WriteUInt(2, 2) -- transfer finished
		net.WriteUInt(message_id, 16)
		net.Send(ply)
	end)

	timer.Create("fancyerrors_message_" .. message_id, 0.5, 0, function()
		if coroutine.status(coro) ~= "suspended" then
			timer.Remove("fancyerrors_message_" .. message_id)

			return
		end

		coroutine.resume(coro)
	end)
end)