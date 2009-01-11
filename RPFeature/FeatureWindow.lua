--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPFot/FeatureWindow.lua
	* Component: Roll Interface
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

--local prefix = "<RPF>"
local db = RPF.db
--local RPLibrary = LibStub:GetLibrary("RPLibrary")
RPF.columnDefinitons = {}
RPF.columnDefinitons["FeatureSet"] = 
{
	{
	    ["name"] = "Feature Set",
	    ["width"] = 100,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
}

RPF.columnDefinitons["FeatureCommand"] = 
{
	{
	    ["name"] = "Command",
	    ["width"] = 100,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
}

--  Constants Roll List
local cfs = 
{
	set = 1,
}

local cfsArg = 
{
	[cfs.set]	= { },
}

-- Constants Loot List
local cfc = 
{
	command = 1,
}

local cfcArg =
{
	[cfc.command]	= { },
}

function RPF:CreateFrame()
	db = RPF.db
	-- if self.Frame then
	  -- self.Frame:Hide()
	-- end

	if not self.frames then
		self.frames = {}
	end
	self.frames["FeatureWindow"] = CreateFrame("Frame", "RPFFeatureWindow", UIParent)

	local f = self.frames["FeatureWindow"]
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	--   f:SetResizeable(true)
	f:SetFrameStrata("MEDIUM")
	f:SetHeight(440)
	f:SetWidth(620)
	f:SetPoint("CENTER",0,0)
	f:Hide()
	f:SetScript("OnShow", RPF.LoadData)

	-- Frame Textures, Drag Header, Close Button, Title
	do
		self:Skin(f);
		
	   
		local button = CreateFrame("Button", f:GetName() .. "_CloseButton", f, "UIPanelCloseButton")
		button:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
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
		f.dragheader = drag

		local title = f:CreateFontString("Title", "ARTWORK", "GameFontNormal")
		title:SetPoint("TOP", f, "TOP", 0, -6)
		title:SetText("Raid Points - Feature Editor")
		f.title = title
	end

    -- Scroll Frame
	do
		f.featureSetList = {}
	    f.scrollSetFrame = ScrollingTable:CreateST(self.columnDefinitons["FeatureSet"], 5, nil, nil, f, true);
		f.scrollSetFrame.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
		f.scrollSetFrame:SetData(f.featureSetList)
		f.scrollSetFrame:RegisterEvents({
			["OnClick"] = featureWindowSetScrollFrameOnClick,
		});

		f.featureList = {}
	    f.scrollFrame = ScrollingTable:CreateST(self.columnDefinitons["FeatureCommand"], 5, nil, nil, f, true);
		f.scrollFrame.frame:SetPoint("TOPLEFT", f.scrollSetFrame.frame, "BOTTOMLEFT", 0, -60)
		f.scrollFrame:SetData(f.featureList)
		f.scrollFrame:RegisterEvents({
			["OnClick"] = featureWindowScrollFrameOnClick,
		});
		
	end

	do
		f.button={}
		f.editbox={}

		-- Code originally created by Shadowed
		-- Seems generic enough, but giving credit where credit is due.
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["CreateFeatureSet"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(130)
		editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeatureSet() end)
		editbox:SetPoint("TOPLEFT", f.scrollSetFrame.frame, "BOTTOMLEFT", 4, 6)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)

		local button = CreateFrame("Button", f:GetName() .. "_ButtonCreateFeatureSet", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.editbox["CreateFeatureSet"], "BOTTOMLEFT", 4, 4)
		button:SetText("Create")
		button:SetScript("OnClick", 
			function(self)
				RPF:CreateFeatureSet()
			end
		)
		f.button["CreateFeatureSet"] = button	
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonDeleteFeatureSet", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["CreateFeatureSet"], "TOPRIGHT", 4, 0)
		button:SetText("Delete")
		button:SetScript("OnClick", 
			function(self)
				RPF:DeleteFeatureSet()
			end
		)
		f.button["DeleteFeatureSet"] = button

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["CreateFeature"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(130)
		editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.scrollFrame.frame, "BOTTOMLEFT", 4, 6)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)

		local button = CreateFrame("Button", f:GetName() .. "_ButtonCreateFeature", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.editbox["CreateFeature"], "BOTTOMLEFT", 2, 4)
		button:SetText("Create")
		button:SetScript("OnClick", 
			function(self)
				RPF:CreateFeature()
			end
		)
		f.button["CreateFeature"] = button	
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonDeleteFeature", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["CreateFeature"], "TOPRIGHT", 4, 0)
		button:SetText("Delete")
		button:SetScript("OnClick", 
			function(self)
				RPF:DeleteFeature()
			end
		)
		f.button["DeleteFeature"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonCommit", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("BOTTOM", f, "BOTTOM", -40, 10)
		button:SetText("Commit")
		button:SetScript("OnClick", 
			function(self)
				RPF:CommitChanges()
			end
		)
		f.button["Commit"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonCancel", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("BOTTOM", f, "BOTTOM", 40, 10)
		button:SetText("Cancel")
		button:SetScript("OnClick", 
			function(self)
				RPF:CancelChanges()
			end
		)
		f.button["Cancel"] = button
		
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["FeatureSetName"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.scrollSetFrame.frame, "TOPRIGHT", 100, 20)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Name","OVERLAY","GameTooltipText")
		font:SetText("Name:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)
		
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["FeatureSetDesc"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["FeatureSetName"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Description","OVERLAY","GameTooltipText")
		font:SetText("Description:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)
		
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["Name"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.scrollFrame.frame, "TOPRIGHT", 100, 20)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Name","OVERLAY","GameTooltipText")
		font:SetText("Name:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["Command"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["Name"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Command","OVERLAY","GameTooltipText")
		font:SetText("Command:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MinClass"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["Command"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MinClass","OVERLAY","GameTooltipText")
		font:SetText("Min Class:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MaxClass"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MinClass"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MaxClass","OVERLAY","GameTooltipText")
		font:SetText("Max Class:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MinNonclass"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MaxClass"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MinNonclass","OVERLAY","GameTooltipText")
		font:SetText("Min Nonclass:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MaxNonclass"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MinNonclass"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MaxNonclass","OVERLAY","GameTooltipText")
		font:SetText("Max Nonclass:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MaxPoints"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MaxNonclass"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MaxPoints","OVERLAY","GameTooltipText")
		font:SetText("Max Points:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["Divisor"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MaxPoints"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Divisor","OVERLAY","GameTooltipText")
		font:SetText("Divisor:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["Diff"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["Divisor"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Diff","OVERLAY","GameTooltipText")
		font:SetText("Roll Difference:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("CheckButton", nil, f, "OptionsCheckButtonTemplate")
		f.editbox["Nolist"] = editbox
		--editbox:SetAutoFocus(false)
		--editbox:SetHeight(32)
		--editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPF:CreateFeature() end)
		editbox:SetPoint("TOPLEFT", f.editbox["Diff"], "BOTTOMLEFT", -10, 8)
		--self:SkinEditBox(editbox)
		--self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Nolist","OVERLAY","GameTooltipText")
		font:SetText("No List:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", 0, -8)
				-- button = 
				-- {
					-- name = "Bonus",
					-- template = "UIPanelButtonTemplate",
					-- width = 91,
					-- height = 21,
					-- setpoint =
					-- {
						-- anchor = "TOPLEFT",
						-- frameanchor = "TOPLEFT",
						-- x = 10,
						-- y = -60
					-- },
					-- text = "Bonus",
				-- },
	end

	-- Create Loot Frames
	-- do
		-- f.item = {}
		-- for i=1, 1 do 
			-- f.item[i] = self:CreateLootFrame(f, i)
		-- end
		-- f.lootList = {}
	    -- f.scrollFrameLoot = ScrollingTable:CreateST(RPF.columnDefinitons["FeatureWindowLootList"], 10, nil, nil, f);
		-- f.scrollFrameLoot.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
		-- f.scrollFrame:SetData(f.lootList)
		-- f.scrollFrame:RegisterEvents({
			-- ["OnClick"] = FeatureWindowItemScrollFrameOnClick,
		-- });
		
	-- end
	
	f.state = "Initial"
end

function featureWindowSetScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	local f = RPF.frames["FeatureWindow"]
		if button == "LeftButton" then
			if data[realrow] then
					RPF:SaveData()
				if f.scrollSetFrame.selected then
					f.scrollSetFrame.selected.selected = false
					f.scrollSetFrame.selected.highlight = nil
					if f.scrollFrame.selected then
						f.scrollFrame.selected.selected = false
						f.scrollFrame.selected.highlight = nil
						f.scrollFrame.selected = nil
					end
				end
				f.scrollSetFrame.selected = data[realrow]
				f.scrollSetFrame.selected.selected = true
				f.scrollSetFrame.selected.highlight = { r = 0.0, g = 0.0, b = 0.5, a = 0.5 }
				f.editbox["FeatureSetName"]:SetText(f.featureSet[f.scrollSetFrame.selected.cols[cfs.set].value]["name"])
				f.editbox["FeatureSetDesc"]:SetText(f.featureSet[f.scrollSetFrame.selected.cols[cfs.set].value]["description"])
				--RPB:Print(f.featureSet[f.scrollSetFrame.selected.cols[cfs.set].value]["description"], f.featureSet[f.scrollSetFrame.selected.cols[cfs.set].value]["name"])
				f.scrollSetFrame:Refresh()
				f.featureList = {}
				for key,value in pairs(f.featureSet[f.scrollSetFrame.selected.cols[cfs.set].value]) do
					if type(value) == "table" then
						f.featureList[#f.featureList+1] = RPF:BuildRow(
							{
								[cfc.command]	= 	key,
							},
							cfcArg
						)
					end
				end
				f.scrollFrame:SetData(f.featureList)
				f.scrollFrame:SortData()
			end
		elseif button == "RightButton" then
			if data[realrow] then
				f.scrollFrame.selected = data[realrow]
				RPF:DeleteFeatureSet(data[realrow].cols[cfs.set].value)
				f.scrollFrame:SortData()
			end
		end
end

function featureWindowScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	local f = RPF.frames["FeatureWindow"]
		if button == "LeftButton" then
			if data[realrow] then
				if f.scrollFrame.selected then
					RPF:SaveData()
					f.scrollFrame.selected.selected = false
					f.scrollFrame.selected.highlight = nil
				end
				f.scrollFrame.selected = data[realrow]
				f.scrollFrame.selected.selected = true
				f.scrollFrame.selected.highlight = { r = 0.0, g = 0.0, b = 0.5, a = 0.5 }
				f.scrollFrame:Refresh()
				local Name = f.editbox["Name"]
				local Command = f.editbox["Command"]
				local MinClass = f.editbox["MinClass"]
				local MaxClass = f.editbox["MaxClass"]
				local MinNonclass = f.editbox["MinNonclass"]
				local MaxNonclass = f.editbox["MaxNonclass"]
				local MaxPoints = f.editbox["MaxPoints"]
				local Divisor = f.editbox["Divisor"]
				local Diff = f.editbox["Diff"]
				local Nolist = f.editbox["Nolist"]
				
				local data = f.featureSet[f.scrollSetFrame.selected.cols[cfs.set].value][f.scrollFrame.selected.cols[cfc.command].value]
				Name:SetText(data["name"] or "")
				Command:SetText(data["command"] or "")
				MinClass:SetText(data["minclass"] or "")
				MaxClass:SetText(data["maxclass"] or "")
				MinNonclass:SetText(data["minnonclass"] or "")
				MaxNonclass:SetText(data["maxnonclass"] or "")
				MaxPoints:SetText(data["maxpoints"] or "")
				Divisor:SetText(data["divisor"] or "")
				Diff:SetText(data["diff"] or "")
				Nolist:SetChecked(data["nolist"] or false)
			end
		elseif button == "RightButton" then
			if data[realrow] then
				f.scrollFrame.selected = data[realrow]
				RPF:DeleteFeature(data[realrow].cols[cfc.command].value)
				f.scrollFrame:SortData()
			end
		end
end

function RPF:LoadData()
	local f = RPF.frames["FeatureWindow"]
	f.featureSetList = {}
	f.featureList = {}
	f.featureSet = {}
	for key,value in pairs(RPF.db.realm.featureSets) do
		f.featureSetList[#f.featureSetList+1] = RPF:BuildRow(
			{
				[cfs.set]	= 	key,
			},
			cfsArg
		)
		f.featureSet[key] = {}
		for k,v in pairs(value) do
			if type(v) == "table" then
				f.featureSet[key][k] = {}
				for k2,v2 in pairs(v) do
					f.featureSet[key][k][k2] = v2
				end
			else
				f.featureSet[key][k] = v
			end
		end
	end
	f.scrollFrame.selected = nil
	f.scrollFrame:SetData(f.featureList)
	f.scrollFrame:SortData(f.featureList)
	f.scrollSetFrame.selected = nil
	f.scrollSetFrame:SetData(f.featureSetList)
	f.scrollSetFrame:SortData(f.featureSetList)

end

function RPF:CommitChanges()
	local f = RPF.frames["FeatureWindow"]
	self.db.realm.featureSets = {}
	self.db.realm.settings.version = time()
	self:SaveData()
	for i=1,#f.featureSetList do
		self.db.realm.featureSets[f.featureSetList[i].cols[cfs.set].value] = {}
		for key,value in pairs(f.featureSet[f.featureSetList[i].cols[cfs.set].value]) do
			if type(value) == "table" then
				self.db.realm.featureSets[f.featureSetList[i].cols[cfs.set].value][key] = {}
				for k,v in pairs(value) do
					self.db.realm.featureSets[f.featureSetList[i].cols[cfs.set].value][key][k] = v
				end
			else
				self.db.realm.featureSets[f.featureSetList[i].cols[cfs.set].value][key] = value
			end
		end
	end
	if RPB then
		RPB:Send("fssend", self.db.realm.featureSets)
	end
	f:Hide()
end

function RPF:CancelChanges()
	f:Hide()
end

function RPF:SaveData()
	local f = RPF.frames["FeatureWindow"]
	if not f.scrollSetFrame.selected then return end
	f.featureSet[f.scrollSetFrame.selected.cols[cfs.set].value]["name"] = f.editbox["FeatureSetName"]:GetText()
	f.featureSet[f.scrollSetFrame.selected.cols[cfs.set].value]["description"] = f.editbox["FeatureSetDesc"]:GetText()

	if not f.scrollFrame.selected then return end
	local Name = f.editbox["Name"]
	local Command = f.editbox["Command"]
	local MinClass = f.editbox["MinClass"]
	local MaxClass = f.editbox["MaxClass"]
	local MinNonclass = f.editbox["MinNonclass"]
	local MaxNonclass = f.editbox["MaxNonclass"]
	local MaxPoints = f.editbox["MaxPoints"]
	local Divisor = f.editbox["Divisor"]
	local Diff = f.editbox["Diff"]
	local Nolist = f.editbox["Nolist"]

	local data = f.featureSet[f.scrollSetFrame.selected.cols[cfs.set].value][f.scrollFrame.selected.cols[cfc.command].value]
	data["name"]		= Name:GetText()
	data["command"]		= Command:GetText()
	data["minclass"]	= tonumber(MinClass:GetText())
	data["maxclass"]	= tonumber(MaxClass:GetText())
	data["minnonclass"]	= tonumber(MinNonclass:GetText())
	data["maxnonclass"]	= tonumber(MaxNonclass:GetText())
	data["maxpoints"]	= tonumber(MaxPoints:GetText())
	data["divisor"]		= tonumber(Divisor:GetText())
	data["diff"]		= tonumber(Diff:GetText())
	data["nolist"]		= Nolist:GetChecked()
	
end

function RPF:CreateFeatureSet()
	local set = f.editbox["CreateFeatureSet"]:GetText()
	f.featureSetList[#f.featureSetList+1] = self:BuildRow(
		{
			[cfs.set]	= 	set,
		},
		cfsArg
	)
end

function RPF:DeleteFeatureSet()
	for i=1,#f.featureSetList do
		if f.featureSetList[i] == f.scrollSetFrame.selected then
			f.scrollSetFrame.selected = nil
			tremove(f.featureSetList,i)
		end
	end
end

function RPF:CreateFeature()
	if not f.scrollSetFrame.selected then return end
	local command = f.editbox["CreateFeature"]:GetText()
	f.featureList[#f.featureList+1] = self:BuildRow(
		{
			[cfc.command]	= 	command,
		},
		cfcArg
	)
	f.featureSet[f.scrollSetFrame.selected.cols[cfc.command].value][command] = {}
end

function RPF:DeleteFeature()
	for i=1,#f.featureList do
		if f.featureList[i] == f.scrollFrame.selected then
			tremove(f.featureSet[f.scrollSetFrame.selected.cols[cfc.command].value],f.scrollFrame.selected.cols[cfc.command].value)
			f.scrollFrame.selected = nil
			tremove(f.featureList,i)
		end
	end
end
