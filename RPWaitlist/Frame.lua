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

RPWL.columnDefiniton = {}
RPWL.columnDefiniton["waitlist"] =
{  
	{
		["name"] = "Name", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	},
	{ 
		["name"] = "Alt", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	},
	{ 
		["name"] = "Class", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 1,
	},
	{
		["name"] = "Status",
		["index"] = "i",
		["width"] = 120, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	},
	{ 
		["name"] = "Time", 
		["width"] = 150, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	},
}

RPWL.columnDefiniton["roster"] =
{
	{ 
		["name"] = "Name", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	}, -- [2]
	{ 
		["name"] = "Rank", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 3,
	},
	{ 
		["name"] = "Level", 
		["width"] = 40, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 1,
		["defaultsort"] = "asc",
	}, -- [2]
	{ 
		["name"] = "Class", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 3,
	}, -- [2]
	{ 
		["name"] = "Zone", 
		["width"] = 160, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 3,
	}, -- [2]
	{ 
		["name"] = "Status", 
		["width"] = 50, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	}, -- [2]
	{
		["name"] = "O", 
		["width"] = 20, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 1,
		["defaultsort"] = "asc",
	}, -- [2]
}



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

	self.scrollFrame = ScrollingTable:CreateST(self.columnDefiniton["waitlist"], 12, nil, nil, self.Frame, true);
	self.scrollFrame.frame:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 100, -35)
	self.scrollFrame:SetData(self.db.realm.waitlist)
	self.scrollFrame:RegisterEvents({
		["OnClick"] = scrollFrameOnClick,
	});
	
	self.scrollFrameGuild = ScrollingTable:CreateST(self.columnDefiniton["roster"], 12, nil, nil, self.Frame, true);
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

