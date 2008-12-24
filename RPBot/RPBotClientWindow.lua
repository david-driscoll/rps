--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision:  @file-revision@
	* Project-Version:  @project-version@
	* Last edited by:  @file-author@ on  @file-date-iso@ 
	* Last commit:  @project-author@ on   @project-date-iso@ 
	* Filename: RPBot/RPBotClientWindow.lua
	* Component: Client
	* Details:
		This file creates the client window.  The client window is similar to the group loot interface
			in that it creates a window that shows the item to be rolled on with the ability to click the proper button.
]]


function RPB:CreateFrameClientWindow()
	db = self.db

	if not self.frames then
		self.frames = {}
	end
	self.frames["ClientWindow"] = {}
	self.frames["ClientWindow"][(#self.frames["ClientWindow"])+1] = CreateFrame("Frame", "RPBClientWindow"..(#self.frames["ClientWindow"])+1, UIParent)

	local f = self.frames["ClientWindow"]
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	--   f:SetResizeable(true)
	f:SetFrameStrata("MEDIUM")
	f:SetHeight(512)
	f:SetWidth(640)
	f:SetPoint("CENTER",0,0)

	-- Frame Textures, Drag Header, Close Button, Title
	do
		RPLibrary:Skin(f);
	   
	   local button = CreateFrame("Button", f:GetName() .. "_CloseButton", f, "UIPanelCloseButton")
	   button:SetPoint("TOPRIGHT", f, "TOPRIGHT", 5, 4)
	   button:Show()
	   f.CloseButton = button
	   
	   local drag = CreateFrame("Button", f:GetName() .. "_DragHeader", f)
	   drag:SetHeight(24)
	   drag:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	   drag:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
	   drag:SetScript("OnMouseDown",
		  function(self)
			 local parent = self:GetParent()
			 if parent:IsMovable() then
				parent:StartMoving()
			 end
		  end
	   )
	   drag:SetScript("OnMouseUp",
		  function(self)
			 local parent = self:GetParent()
			 parent:StopMovingOrSizing()
		  end
	   )
	   self.dragheader = drag
	   
	   local title = f:CreateFontString("Title", "ARTWORK", "GameFontNormal")
	   title:SetPoint("TOP", f, "TOP", 0, -6)
	   title:SetText("Raid Points - Roll Window")
	   self.title = title
	end

	-- Buttons
		-- Bonus
		-- Upgrade
		-- Sidegrade
		-- Pass
		-- Offspec
	do
		f.button={}
		-- These buttons are given from "features"
		
		-- local button = CreateFrame("Button", f:GetName() .. "_ButtonBonus", f, "UIPanelButtonTemplate")
		-- button:SetWidth(90)
		-- button:SetHeight(21)
		-- button:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -60)
		-- button:SetText("Bonus")
		-- button:SetScript("OnClick", 
			-- function(self)
				-- RPB:StartBidding()
			-- end
		-- )
		-- self.button["Bonus"] = button
		
		-- local button = CreateFrame("Button", f:GetName() .. "_ButtonUpgrade", f, "UIPanelButtonTemplate")
		-- button:SetWidth(90)
		-- button:SetHeight(21)
		-- button:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -30)
		-- button:SetText("Upgrade")
		-- button:SetScript("OnClick", 
			-- function(self)
				-- RPB:StopBidding()
			-- end
		-- )
		-- self.button["Upgrade"] = button
		
		-- local button = CreateFrame("Button", f:GetName() .. "_ButtonSidegrade", f, "UIPanelButtonTemplate")
		-- button:SetWidth(90)
		-- button:SetHeight(21)
		-- button:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 0)
		-- button:SetText("Sidegrade")
		-- button:SetScript("OnClick", 
			-- function(self)
				-- RPB:StartTimedBidding()
			-- end
		-- )
		-- self.button["Sidegrade"] = button
		
		-- local button = CreateFrame("Button", f:GetName() .. "_ButtonPass", f, "UIPanelButtonTemplate")
		-- button:SetWidth(90)
		-- button:SetHeight(21)
		-- button:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 30)
		-- button:SetText("Pass")
		-- button:SetScript("OnClick", 
			-- function(self)
				-- RPB:AwardItem()
			-- end
		-- )
		-- self.button["Pass"] = button
		
		-- local button = CreateFrame("Button", f:GetName() .. "_ButtonOffspec", f, "UIPanelButtonTemplate")
		-- button:SetWidth(90)
		-- button:SetHeight(21)
		-- button:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 60)
		-- button:SetText("Offspec")
		-- button:SetScript("OnClick", 
			-- function(self)
				-- RPB:RemoveItem()
			-- end
		-- )
		-- self.button["Offspec"] = button
	end

	-- Create Loot Frames
	do
		f.item = {}
		for i=1, 1 do 
			f.item[i] = self:CreateLootFrame(self, i)
		end
	end
end


