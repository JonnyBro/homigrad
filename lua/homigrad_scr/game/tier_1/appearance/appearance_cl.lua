--[[
TODO:
 - Appearance menu like hmcd
 - Networking :/
--]]

EasyAppearance = EasyAppearance or {}

EasyAppearance.OpenedMenu = EasyAppearance.OpenedMenu or nil

local Models = {
	-- Male
	["models/player/group01/male_01.mdl"] = {1, 3},
	["models/player/group01/male_02.mdl"] = {1, 2},
	["models/player/group01/male_03.mdl"] = {1, 4},
	["models/player/group01/male_04.mdl"] = {1, 4},
	["models/player/group01/male_05.mdl"] = {1, 4},
	["models/player/group01/male_06.mdl"] = {1, 0},
	["models/player/group01/male_07.mdl"] = {1, 4},
	["models/player/group01/male_08.mdl"] = {1, 0},
	["models/player/group01/male_09.mdl"] = {1, 2},
	-- Female
	["models/player/group01/female_01.mdl"] = {2, 2},
	["models/player/group01/female_02.mdl"] = {2, 3},
	["models/player/group01/female_03.mdl"] = {2, 3},
	["models/player/group01/female_04.mdl"] = {2, 1},
	["models/player/group01/female_05.mdl"] = {2, 2},
	["models/player/group01/female_06.mdl"] = {2, 4},
}

function EasyAppearance.Menu()
	if IsValid(EasyAppearance.OpenedMenu) then
		EasyAppearance.OpenedMenu:Remove()
		EasyAppearance.OpenedMenu = nil
	end

	local _, Appearance = EasyAppearance.GetData()
	Appearance = Appearance or {}

	EasyAppearance.OpenedMenu = vgui.Create("DFrame")

	local MainPanel = EasyAppearance.OpenedMenu
	MainPanel:SetSize(512, 512)
	MainPanel:Center()
	MainPanel:MakePopup()
	MainPanel:SetTitle("Appearance Menu")
	MainPanel.ModelView = vgui.Create("DModelPanel", MainPanel)

	local ModelView = MainPanel.ModelView
	ModelView:Dock(LEFT)
	ModelView:SetSize(256, 512)

	local tModel = EasyAppearance.Models[Appearance.strModel]
	local sex = "Male"

	ModelView:SetModel(tModel and tModel.strPatch or table.Random(table.GetKeys(Models)))
	ModelView.Angles = Angle(0, 0, 0)

	function ModelView:DragMousePress()
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
	end

	function ModelView:DragMouseRelease() 
		self.Pressed = false 
	end

	function ModelView:LayoutEntity(ent)
		if (self.Pressed) then --360° model spin
			local mx, my = gui.MousePos()
			self.Angles = self.Angles - Angle(0,((self.PressX or mx) - mx) / 2, 0)
			self.PressX, self.PressY = gui.MousePos()
		end
		ent:SetAngles(self.Angles)
		ent:SetSubMaterial()

		sex = EasyAppearance.Sex[ent:GetModelSex()]

		ent:SetupBones()
		ent:SetSubMaterial(Models[ent:GetModel()][2], Appearance.strColthesStyle and EasyAppearance.Appearances[sex][Appearance.strColthesStyle] or "")
		-- EasyAppearance.DrawAttachment(ent, Appearance.strAttachmets)

		return
	end

	ModelView:SetFOV(37.5)

	MainPanel.RightPanel = vgui.Create("DPanel", MainPanel)
	local DPanel = MainPanel.RightPanel
	DPanel:Dock(FILL)
	DPanel.ComboMdlBox = vgui.Create("DComboBox", DPanel)

	local CombMdlBox = DPanel.ComboMdlBox
	CombMdlBox:Dock(TOP)
	CombMdlBox:DockMargin(15, 10, 15, 0)

	for k, v in pairs(EasyAppearance.Models) do
		CombMdlBox:AddChoice(k, v.strPatch)
	end

	function CombMdlBox:OnSelect(_, text, data)
		ModelView:SetModel(data)

		Appearance.strModel = text

		timer.Simple(0.1, function()
			DPanel.ComboApperBox:Clear()

			for k in pairs(EasyAppearance.Appearances[sex]) do
				DPanel.ComboApperBox:AddChoice(k, k)
			end
		end)
	end

	DPanel.ComboApperBox = vgui.Create("DComboBox", DPanel)
	local CombApperBox = DPanel.ComboApperBox
	CombApperBox:Dock(TOP)
	CombApperBox:DockMargin(15, 10, 15, 0)

	for k in pairs(EasyAppearance.Appearances[sex]) do
		CombApperBox:AddChoice(k, k)
	end

	function CombApperBox:OnSelect(_, text, _)
		Appearance.strColthesStyle = text
	end

	DPanel.CombAttBox = vgui.Create("DComboBox", DPanel)
	local CombAttBox = DPanel.CombAttBox
	CombAttBox:Dock(TOP)
	CombAttBox:DockMargin(15, 10, 15, 0)

	for k in pairs(EasyAppearance.Attachmets) do
		CombAttBox:AddChoice(k, k)
	end

	--[[
	function CombAttBox:OnSelect(index, text, data)
		Appearance.strAttachmets = text
	end --]]

	DPanel.ApplyButton = vgui.Create("DButton", DPanel)
	local AplyBtn = DPanel.ApplyButton
	AplyBtn:Dock(BOTTOM)
	AplyBtn:SetText("Apply appearance")

	function AplyBtn:DoClick()
		if not Appearance.strColthesStyle or not Appearance.strModel then
			LocalPlayer():PrintMessage(HUD_PRINTTALK, "Not valid.")

			return false
		end

		EasyAppearance.SaveData(Appearance)

		MainPanel:Close()
	end
end

concommand.Add("hg_appearance_menu", function()
	EasyAppearance.Menu(LocalPlayer())
end)

function EasyAppearance.SendNet(bRandom, tAppearanceData)
	net.Start("EasyAppearance_SendData")
		net.WriteBool(bRandom or false)
		net.WriteTable(tAppearanceData)
	net.SendToServer()
end

function EasyAppearance.SaveData(tAppearanceData)
	if not file.Exists("homigrad", "DATA") then
		file.CreateDir("homigrad")
	end

	file.Write("homigrad/appearancedata.json", util.TableToJSON(tAppearanceData, true))

	--SaveData() should call SendNet(). W/o this - Old skins are the same as the new skins for the host - Niik
	EasyAppearance.SendNet(bRandom, tAppearanceData or {})
end

function EasyAppearance.GetData(bForceRandom)
	if not file.Exists("homigrad", "DATA") then
		file.CreateDir("homigrad")
	end

	if bForceRandom then return true end
	if not file.Exists("homigrad/appearancedata.json", "DATA") then return true end
	local tAppearanceData = util.JSONToTable(file.Read("homigrad/appearancedata.json", "DATA"))

	return false, tAppearanceData
end

local cvrForceRandom = CreateClientConVar("hg_random_appearance", 0, true, false, "", 0, 1)

net.Receive("EasyAppearance_SendReqData", function()
	local bRandom, tAppearanceData = EasyAppearance.GetData(cvrForceRandom:GetBool())
	-- print(tAppearanceData)
	EasyAppearance.SendNet(bRandom, tAppearanceData or {})
end)

-- PrintTable(tAppearanceData)
-- self:SetNWEntity("Ragdoll", rag)
CreateClientConVar("hg_appearance_dis", "6000", true, false)

--[[
	["HatExample"] = {
		strModel = strModel,
		strMaterial = strMaterial,
		strBone = strBone,
		vPos = vPos or Vector( 0, 0, 0 ),
		vFPos = vFPos or Vector( 0, 0, 0 ),
		aAng = aAng or Angle( 0, 0, 0 ),
		aFAng = aFAng or Angle( 0, 0, 0 ),
		iSkin = iSkin or 0,
		strBodyGroups = strBodyGroups or "0000000"
	}
--]]

function EasyAppearance.DrawAttachment(eEnt, strAtt, ply)
	local att = EasyAppearance.Attachmets[strAtt]
	if not IsValid(eEnt) or not att then return end

	local iBone = eEnt:LookupBone(att.strBone)
	if not iBone then return end

	local matrix = eEnt:GetBoneMatrix(iBone)
	if not matrix then return end

	if eEnt:GetManipulateBoneScale(iBone):IsZero() then return end

	local pos = matrix:GetTranslation()
	local ang = matrix:GetAngles()
	local modelSex = eEnt:GetModelSex()

	if not IsValid(eEnt.AttachModel) then
		eEnt.AttachModel = ClientsideModel(att.strModel)

		eEnt:CallOnRemove("RemoveAttach", function()
			eEnt.AttachModel:Remove()
		end)

		eEnt.AttachModel:SetNoDraw(true)

		if att.strMaterial then
			eEnt.AttachModel:SetMaterial(att.strMaterial)
		end

		if att.iSkin then
			eEnt.AttachModel:SetSkin(att.iSkin)
		end

		eEnt.AttachModel:AddEffects(EF_BONEMERGE)
		-- eEnt.AttachModel:AddEffects(EF_FOLLOWBONE)
	elseif IsValid(eEnt.AttachModel) then
		-- if not IsValid(eEnt.AttachModel) then eEnt.AttachModel = nil return end
		if IsValid(eEnt.AttachModel) and eEnt.AttachModel:GetModel() ~= att.strModel then
			eEnt.AttachModel:SetModel(att.strModel)
		end

		if att.bDrawOnLocal or GetViewEntity() ~= ply then
			local lPos, lAng = LocalToWorld(modelSex > 1 and att.vFPos or att.vPos, modelSex > 1 and att.aFAng or att.aAng, pos, ang)
			-- eEnt.AttachModel:SetPos(lPos)
			eEnt.AttachModel:SetParent(eEnt, iBone)
			eEnt.AttachModel:SetRenderOrigin(lPos)
			eEnt.AttachModel:SetRenderAngles(lAng)
			eEnt.AttachModel:SetupBones()
			eEnt.AttachModel:DrawModel()
		end
	end
end

hook.Add("HG_PostPlayerDraw", "EA_AttachmentsRender", function(ent, ply)
	local Attachmets = ent:GetNWString("EA_Attachments", nil)
	if Attachmets == nil then return end

	ent:SetupBones()

	EasyAppearance.DrawAttachment(ent, Attachmets, ply)
end)