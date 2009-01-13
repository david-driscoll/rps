--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPWaitlist/Frame.lua
	* Component: Waitlist
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

--local RPLibrary = LibStub:GetLibrary("RPLibrary")

function RPWL:CreateFrame()
	-- if self.Frame then
	  -- self.Frame:Hide()
	-- end

	self.Frame = CreateFrame("Frame", "RPWaitlist", UIParent)

	local f = self.Frame
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	--   f:SetResizeable(true)
	f:SetFrameStrata("MEDIUM")
	f:SetHeight(512)
	f:SetWidth(640)
	f:SetPoint("CENTER",0,0)
	
	self:Skin(f)

	local button = CreateFrame("Button", "DIWL_CloseButton", f, "UIPanelCloseButton")
	button:SetPoint("TOPRIGHT", f, "TOPRIGHT", 5, 4)
	button:Show()
	f.CloseButton = button

	local drag = CreateFrame("Button", "DIWL_DragHeader", f)
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
	title:SetText("Raid Points Waitlist")
	self.title = title

	self.scrollFrame = ScrollingTable:CreateST(RPSConstants.columnDefinitons["Waitlist"], 12, nil, nil, self.Frame, true);
	self.scrollFrame.frame:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 100, -35)
	self.scrollFrame:SetData(self.db.realm.waitlist)
	self.scrollFrame:RegisterEvents({
		["OnClick"] = scrollFrameOnClick,
	});
	
	self.scrollFrameGuild = ScrollingTable:CreateST(RPSConstants.columnDefinitons["Roster"], 12, nil, nil, self.Frame, true);
	self.scrollFrameGuild.frame:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 100, -275)
	self.scrollFrameGuild:SetData({})
	self.scrollFrameGuild:RegisterEvents({
		["OnClick"] = scrollFrameGuildOnClick,
	});

  	self.button={}
  
	local button = CreateFrame("Button", "DIWL_ButtonAdd", f, "UIPanelButtonTemplate")
	button:SetWidth(90)
	button:SetHeight(21)
	button:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -60)
	button:SetText("Add")
	button:SetScript("OnClick", 
		function(self)
			RPWL:ButtonAdd()
		end
	)
	self.button["add"] = button

	button = CreateFrame("Button", "DIWL_ButtonRemove", f, "UIPanelButtonTemplate")
	button:SetWidth(90)
	button:SetHeight(21)
	button:SetPoint("TOPLEFT", self.button["add"], "BOTTOMLEFT", 0, 0)
	button:SetText("Remove")
	button:SetScript("OnClick", 
		function(self)
			RPWL:ButtonRemove()
		end
	)
	self.button["remove"] = button
end

