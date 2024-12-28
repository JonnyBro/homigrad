include("shared.lua")

local posX = {
	0.29,
	0.5,
	0.71,
	0.71,
	0.71,
	0.5,
	0.29,
	0.29,
}
local posY = {
	0.29,
	0.29,
	0.29,
	0.5,
	0.71,
	0.71,
	0.71,
	0.5,
}

local COLOR_GREEN 			= Color(0,255,0,255)
local COLOR_BLACK 			= Color(0,0,0,255)
local COLOR_WHITE 			= Color(255,255,255,255)
local COLOR_WHITE_HOVERED	= Color(200,200,200,150)
local HOOK_ADDED = false
local LANGUAGE

local ints = {
	[8] = 1,
	[2] = 2,
	[4] = 3,
}

function SWEP:DrawHUD()
	surface.SetDrawColor(0,0,0,self.Zoom.Val*255)
	surface.SetTexture(surface.GetTextureID("gredwitch/overlay_binoculars"))
	
	local X = ScrW()
	local Y = ScrH()
	
	surface.DrawTexturedRect(0,-(X-Y)/2,X,X)
	
	if self.Zoom.Val == 0 then
		local tab = self:GetTableFromTrace()
		
		if tab then
			draw.DrawText("Click to pair this emplacement","Trebuchet24",X*0.5,Y*0.25,color_white,TEXT_ALIGN_CENTER)
		end
	end
end

function SWEP:CalcView(ply,pos,ang,fov)
	return pos,ang,fov - (self.Zoom.Val * self.Zoom.FOV)
end

function SWEP:AdjustMouseSensitivity()
	return self.Owner:KeyDown(IN_ATTACK2) and 0.1 or 1
end

function SWEP:CalcViewModelView(ViewModel,OldEyePos)
	if self.Zoom.Val > 0.8 then
		return Vector(0,0,0)
	else
		return OldEyePos - Vector(0,0,1.3)
	end
end

function SWEP:PrimaryAttackHack()
	if IsValid(self.Menu) then self.Menu:Close() end
	local X = ScrW()*0.45
	local Y = ScrH()*0.75
	local DFrame = vgui.Create("DFrame")
	DFrame:SetSize(X,Y)
	DFrame:Center()
	DFrame:MakePopup()
	DFrame:SetAlpha(0)
	DFrame:AlphaTo(255,0.3)
	DFrame:ShowCloseButton(false)
	DFrame:SetTitle("")
	DFrame.Close = function(DFrame)
		if DFrame.IsClosing then return end
		DFrame.IsClosing = true
		DFrame:AlphaTo(0,0.1,0,function(tab,DFrame)
			DFrame:Remove()
		end)
	end
	DFrame.Paint = function(DFrame,x,y)
		surface.SetDrawColor(COLOR_BLACK)
		surface.DrawRect(0,Y*0.391,x,y*0.01)
		surface.DrawRect(0,Y*0.6,x,y*0.01)
		surface.DrawRect(x*0.391,0,x*0.01,y)
		surface.DrawRect(x*0.6,0,x*0.01,y)
		
		surface.SetDrawColor(COLOR_WHITE)
		surface.DrawRect(0,Y*0.393,x,y*0.006)
		surface.DrawRect(0,Y*0.603,x,y*0.006)
		surface.DrawRect(x*0.393,0,x*0.006,y)
		surface.DrawRect(x*0.602,0,x*0.006,y)
	end
	self.Menu = DFrame
	
	local DButton = vgui.Create("DButton",DFrame)
	local X_m,Y_m = X*posX[2],Y*posY[2]
	local x,y = X*0.2,Y*0.2
	DButton:SetPos(X_m-x*0.5,Y_m-y*0.5)
	DButton:SetSize(x,y)
	-- local X_m,Y_m = X*0.5,Y*0.5
	-- local x,y = X*0.2,Y*0.2
	-- DButton:SetPos(X_m-x*0.5,Y_m-y*0.5)
	-- DButton:SetSize(x,y)
	DButton:SetText("Close")
	DButton:SetTextColor(COLOR_BLACK)
	DButton.Paint = function(DButton,x,y)
		if DButton:IsHovered() then
			surface.SetDrawColor(COLOR_WHITE_HOVERED)
			surface.DrawRect(0,0,x,y)
		end
	end
	DButton.DoClick = function(DButton)
		DFrame:Close()
	end
	
	local buttons = {}
	local function AddButtons(tab,DFrame,X,Y,X_m,Y_m,x,y,INDEX)
		for k,v in pairs(tab) do
			local DButton = vgui.Create("DButton",DFrame)
			if k == 2 then
				X_m,Y_m = X*0.5,Y*0.5
				x,y = X*0.2,Y*0.2
			else
				X_m,Y_m = X*posX[k],Y*posY[k]
				x,y = X*0.2,Y*0.2
			end
			DButton:SetPos(X_m-x*0.5,Y_m-y*0.5)
			DButton:SetSize(x,y)
			DButton:SetText(v.name)
			DButton:SetTextColor(COLOR_BLACK)
			DButton:SetAlpha(0)
			DButton:AlphaTo(255,0.2)
			DButton:SetToolTip(v.name)
			DButton.Paint = function(DButton,x,y)
				if DButton:IsHovered() then
					surface.SetDrawColor(COLOR_WHITE_HOVERED)
					surface.DrawRect(0,0,x,y)
				end
			end
			if v.choices or v.less then
				DButton.DoClick = function(DButton)
					for _,b in pairs(buttons) do
						if IsValid(b) then 
							b:AlphaTo(0,0.2,0,function()
								b:Remove()
							end)
						end
					end
					buttons = {}
					if v.less then
						table.remove(INDEX,#INDEX)
						table.remove(INDEX,#INDEX)
						tab = self.Choices
						for k,v in pairs(INDEX) do
							tab = tab[v]
						end
						AddButtons(tab,DFrame,X,Y,X_m,Y_m,x,y,INDEX)
					else
						table.insert(INDEX,k)
						table.insert(INDEX,"choices")
						AddButtons(v.choices,DFrame,X,Y,X_m,Y_m,x,y,INDEX)
					end
				end
			else
				DButton.DoClick = function(DButton)
					if !v.Decor then
						DFrame:Close()
						table.insert(INDEX,k)
						net.Start("gred_net_emp_striketype")
							net.WriteUInt(ints[k],2)
						net.SendToServer()
					end
				end
			end
			buttons[k] = DButton
		end
	end
	AddButtons(self.Choices,DFrame,X,Y,X_m,Y_m,x,y,{})
end

function SWEP:Think()
	local keydown = self.Owner:KeyDown(IN_ATTACK2)
	
	self.Zoom.Val = math.Clamp(self.Zoom.Val + (keydown and self.Zoom.Rate or -self.Zoom.Rate),0,1)
	
	if keydown and not self.IsZooming then
		self.IsZooming = true
		self.IsUnZooming = false
		
		self.Weapon:SendWeaponAnim(ACT_VM_DEPLOY)
	elseif !keydown and not self.IsUnZooming and self.IsZooming then
		self.IsZooming = false
		self.IsUnZooming = true
		
		self.Weapon:SendWeaponAnim(ACT_VM_UNDEPLOY)
	end
	
	if not HOOK_ADDED then
		local ply = self.Owner
	
		hook.Add("PreDrawHalos","gred_empbinoculars_halos",function()
			if not IsValid(self) or ply:GetActiveWeapon() != self then
				hook.Remove("PreDrawHalos","gred_empbinoculars_halos")
				
				HOOK_ADDED = false
				
				return
			end
			
			local tab = self:GetTableFromTrace()
			
			if tab and self.Zoom.Val == 0 then
				halo.Add(tab,COLOR_GREEN)
			end
		end)
		
		HOOK_ADDED = true
	end
	
	self.CurAttack = self.Owner:KeyDown(IN_ATTACK)
	
	if self.CurAttack and self.CurAttack != self.PrevAttack and not self:GetTableFromTrace() then
		self:PrimaryAttackHack()
	end
	
	self.PrevAttack = self.CurAttack
end