--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPRot/RulesWindow.lua
	* Component: Roll Interface
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

--local prefix = "<RPR>"
local db = RPR.db

--  Constants Roll List
local cfs = RPSConstants.stConstants["RulesSet"]
local cfsArg = RPSConstants.stArgs["RulesSet"]

-- Constants Loot List
local cfc = RPSConstants.stConstants["RulesCommand"]
local cfcArg = RPSConstants.stArgs["RulesCommand"]

local cs
local ScrollingTable = LibStub:GetLibrary("ScrollingTable");

function RPR:CreateFrame()
	cs = RPSConstants.syncCommands["Bot"]
	db = RPR.db
	-- if self.Frame then
	  -- self.Frame:Hide()
	-- end

	if not self.frames then
		self.frames = {}
	end
	self.frames["RulesWindow"] = CreateFrame("Frame", "RPRRulesWindow", UIParent)

	local f = self.frames["RulesWindow"]
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	--   f:SetResizeable(true)
	f:SetFrameStrata("DIALOG")
	f:SetFrameLevel(101)
	f:SetHeight(500)
	f:SetWidth(400)
	f:SetPoint("CENTER")
	f:Hide()
	f:SetScript("OnShow", RPR.LoadData)

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
		title:SetText("Raid Points - Rules Editor")
		f.title = title
	end

    -- Scroll Frame
	do
		f.rulesSetList = {}
	    f.scrollSetFrame = ScrollingTable:CreateST(RPSConstants.columnDefinitons["RulesSet"], 5, nil, nil, f);
		f.scrollSetFrame:EnableSelection(true);
		f.scrollSetFrame.frame:SetParent(f)
		f.scrollSetFrame.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
		f.scrollSetFrame:SetData(f.rulesSetList)
		f.scrollSetFrame:RegisterEvents({
			["OnClick"] = rulesWindowSetScrollFrameOnClick,
		});

		f.rulesList = {}
	    f.scrollFrame = ScrollingTable:CreateST(RPSConstants.columnDefinitons["RulesCommand"], 5, nil, nil, f);
		f.scrollFrame:EnableSelection(true);
		f.scrollFrame.frame:SetParent(f)
		f.scrollFrame.frame:SetPoint("TOPLEFT", f.scrollSetFrame.frame, "BOTTOMLEFT", 0, -60)
		f.scrollFrame:SetData(f.rulesList)
		f.scrollFrame:RegisterEvents({
			["OnClick"] = rulesWindowScrollFrameOnClick,
		});
		
	end

	do
		f.button={}
		f.editbox={}

		-- Code originally created by Shadowed
		-- Seems generic enough, but giving credit where credit is due.
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["CreateRulesSet"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(130)
		editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRulesSet() end)
		editbox:SetPoint("TOPLEFT", f.scrollSetFrame.frame, "BOTTOMLEFT", 4, 6)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)

		local button = CreateFrame("Button", f:GetName() .. "_ButtonCreateRulesSet", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.editbox["CreateRulesSet"], "BOTTOMLEFT", 4, 4)
		button:SetText("Create")
		button:SetScript("OnClick", 
			function(self)
				RPR:CreateRulesSet()
			end
		)
		f.button["CreateRulesSet"] = button	
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonDeleteRulesSet", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["CreateRulesSet"], "TOPRIGHT", 4, 0)
		button:SetText("Delete")
		button:SetScript("OnClick", 
			function(self)
				RPR:DeleteRulesSet()
			end
		)
		f.button["DeleteRulesSet"] = button

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["CreateRules"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(130)
		editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.scrollFrame.frame, "BOTTOMLEFT", 4, 6)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)

		local button = CreateFrame("Button", f:GetName() .. "_ButtonCreateRules", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.editbox["CreateRules"], "BOTTOMLEFT", 2, 4)
		button:SetText("Create")
		button:SetScript("OnClick", 
			function(self)
				RPR:CreateRules()
			end
		)
		f.button["CreateRules"] = button	
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonDeleteRules", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["CreateRules"], "TOPRIGHT", 4, 0)
		button:SetText("Delete")
		button:SetScript("OnClick", 
			function(self)
				RPR:DeleteRules()
			end
		)
		f.button["DeleteRules"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonCommit", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("BOTTOM", f, "BOTTOM", -40, 10)
		button:SetText("Commit")
		button:SetScript("OnClick", 
			function(self)
				RPR:CommitChanges()
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
				RPR:CancelChanges()
			end
		)
		f.button["Cancel"] = button
		
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["RulesSetName"] = editbox
		editbox.tabPos = 1
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.scrollSetFrame.frame, "TOPRIGHT", 100, 0)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Name","OVERLAY","GameTooltipText")
		font:SetText("Name:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)
		
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["RulesSetDesc"] = editbox
		editbox.tabPos = 2
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["RulesSetName"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Description","OVERLAY","GameTooltipText")
		font:SetText("Description:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["RulesSetIlvlMin"] = editbox
		editbox.tabPos = 3
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["RulesSetDesc"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MiniLvl","OVERLAY","GameTooltipText")
		font:SetText("Min iLvl:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["RulesSetIlvlMax"] = editbox
		editbox.tabPos = 4
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["RulesSetIlvlMin"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MaxiLvl","OVERLAY","GameTooltipText")
		font:SetText("Max iLvl:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["Name"] = editbox
		editbox.tabPos = 5
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.scrollFrame.frame, "TOPRIGHT", 100, 20)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Name","OVERLAY","GameTooltipText")
		font:SetText("Name:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["Command"] = editbox
		editbox.tabPos = 6
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["Name"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Command","OVERLAY","GameTooltipText")
		font:SetText("Command:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)
		
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["Desc"] = editbox
		editbox.tabPos = 7
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["Command"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Description","OVERLAY","GameTooltipText")
		font:SetText("Description:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MinClass"] = editbox
		editbox.tabPos = 8
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["Desc"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MinClass","OVERLAY","GameTooltipText")
		font:SetText("Min Class:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MaxClass"] = editbox
		editbox.tabPos = 9
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MinClass"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MaxClass","OVERLAY","GameTooltipText")
		font:SetText("Max Class:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MinNonclass"] = editbox
		editbox.tabPos = 10
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MaxClass"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MinNonclass","OVERLAY","GameTooltipText")
		font:SetText("Min Nonclass:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MaxNonclass"] = editbox
		editbox.tabPos = 11
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MinNonclass"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MaxNonclass","OVERLAY","GameTooltipText")
		font:SetText("Max Nonclass:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["MaxPoints"] = editbox
		editbox.tabPos = 12
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MaxNonclass"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("MaxPoints","OVERLAY","GameTooltipText")
		font:SetText("Max Points:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["Divisor"] = editbox
		editbox.tabPos = 13
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["MaxPoints"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Divisor","OVERLAY","GameTooltipText")
		font:SetText("Divisor:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["Diff"] = editbox
		editbox.tabPos = 14
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(100)
		editbox:SetNumeric()
		--editbox:SetScript("OnEnterPressed", function(self) RPR:CreateRules() end)
		editbox:SetPoint("TOPLEFT", f.editbox["Divisor"], "BOTTOMLEFT", 0, 8)
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		local font = f:CreateFontString("Diff","OVERLAY","GameTooltipText")
		font:SetText("Roll Difference:")
		font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -10, -8)

		f.checkbox = {}
		local checkbox = CreateFrame("CheckButton", nil, f, "OptionsCheckButtonTemplate")
		f.checkbox["Offspec"] = checkbox
		checkbox:SetPoint("TOPLEFT", f.editbox["Diff"], "BOTTOMLEFT", -10, 8)
		local font = f:CreateFontString("Offspec","OVERLAY","GameTooltipText")
		font:SetText("Offspec:")
		font:SetPoint("TOPRIGHT", checkbox, "TOPLEFT", 0, -8)
		
		local checkbox = CreateFrame("CheckButton", nil, f, "OptionsCheckButtonTemplate")
		f.checkbox["Nolist"] = checkbox
		checkbox:SetPoint("TOPLEFT", f.checkbox["Offspec"], "BOTTOMLEFT", 0, 8)
		local font = f:CreateFontString("Nolist","OVERLAY","GameTooltipText")
		font:SetText("No List:")
		font:SetPoint("TOPRIGHT", checkbox, "TOPLEFT", 0, -8)
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
	
	for k,editbox in pairs(f.editbox) do
		if editbox.tabPos and editbox.tabPos > 0 then
			editbox:SetScript("OnTabPressed", function(self, ...)
				local focusset = false
				local tabone
				for k,eb in pairs(self:GetParent().editbox) do
					if eb.tabPos == 1 then
						tabone = eb
					end
					if eb.tabPos == self.tabPos+1 then
						eb:SetFocus()
						focusset = true
					end
				end
				if not focusset then
					tabone:SetFocus()
				end
			end)	
		end
	end

	-- Create Loot Frames
	-- do
		-- f.item = {}
		-- for i=1, 1 do 
			-- f.item[i] = self:CreateLootFrame(f, i)
		-- end
		-- f.lootList = {}
	    -- f.scrollFrameLoot = ScrollingTable:CreateST(RPR.columnDefinitons["RulesWindowLootList"], 10, nil, nil, f);
		-- f.scrollFrameLoot.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
		-- f.scrollFrame:SetData(f.lootList)
		-- f.scrollFrame:RegisterEvents({
			-- ["OnClick"] = RulesWindowItemScrollFrameOnClick,
		-- });
		
	-- end
end

function rulesWindowSetScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, down)
	local f = RPR.frames["RulesWindow"]
	if button == "LeftButton" then
		if data[realrow] then
			RPR:SaveData()
			local selected = f.scrollSetFrame:GetRow(f.scrollSetFrame:GetSelection());
			if selected then
				selected.selected = false
				selected.highlight = nil
			end
			f.scrollSetFrame:SetSelection(realrow)
			selected = f.scrollSetFrame:GetRow(f.scrollSetFrame:GetSelection());
			selected.selected = true
			selected.highlight = { r = 0.0, g = 0.0, b = 0.5, a = 0.5 }
			f.scrollSetFrame:Refresh()
			f.editbox["RulesSetName"]:SetText(f.rulesSet[selected.cols[cfs.set].value]["name"] or "")
			f.editbox["RulesSetDesc"]:SetText(f.rulesSet[selected.cols[cfs.set].value]["description"] or "")
			f.editbox["RulesSetIlvlMin"]:SetText(f.rulesSet[selected.cols[cfs.set].value]["ilvlmin"] or "")
			f.editbox["RulesSetIlvlMax"]:SetText(f.rulesSet[selected.cols[cfs.set].value]["ilvlmax"] or "")
			--RPB:Print(f.rulesSet[f.scrollSetFrame.selected.cols[cfs.set].value]["description"], f.rulesSet[f.scrollSetFrame.selected.cols[cfs.set].value]["name"])
			f.rulesList = {}
			for key,value in pairs(f.rulesSet[selected.cols[cfs.set].value]) do
				if type(value) == "table" then
					f.rulesList[#f.rulesList+1] = RPR:BuildRow(
						{
							[cfc.command]	= 	key,
						},
						cfcArg
					)
				end
			end
			f.scrollFrame:SetData(f.rulesList)
			f.scrollFrame:SortData()
			f.scrollFrame:ClearSelection()

			local Name = f.editbox["Name"]
			local Command = f.editbox["Command"]
			local Desc = f.editbox["Desc"]
			local MinClass = f.editbox["MinClass"]
			local MaxClass = f.editbox["MaxClass"]
			local MinNonclass = f.editbox["MinNonclass"]
			local MaxNonclass = f.editbox["MaxNonclass"]
			local MaxPoints = f.editbox["MaxPoints"]
			local Divisor = f.editbox["Divisor"]
			local Diff = f.editbox["Diff"]
			local Nolist = f.checkbox["Nolist"]
			local Offspec = f.checkbox["Offspec"]
				
			Name:SetText("")
			Command:SetText("")
			Desc:SetText("")
			MinClass:SetText("")
			MaxClass:SetText("")
			MinNonclass:SetText("")
			MaxNonclass:SetText("")
			MaxPoints:SetText("")
			Divisor:SetText("")
			Diff:SetText("")
			Nolist:SetChecked(false)
			Offspec:SetChecked(false)

			return true
		end
	elseif button == "RightButton" then
		if data[realrow] then
			f.scrollSetFrame:SetSelection(realrow)
			RPR:DeleteRulesSet()
			return true
		end
	end
	return true
end

function rulesWindowScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, down)
	local f = RPR.frames["RulesWindow"]
	if button == "LeftButton" then
		if data[realrow] then
			if not f.scrollSetFrame:GetSelection() then return end
			local selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection());
			local selectedSet = f.scrollSetFrame:GetRow(f.scrollSetFrame:GetSelection())
			if selected then
				RPR:SaveData()
				selected.selected = false
				selected.highlight = nil
			end
			f.scrollFrame:SetSelection(realrow)
			selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection());
			selected.selected = true
			selected.highlight = { r = 0.0, g = 0.0, b = 0.5, a = 0.5 }
			f.scrollFrame:Refresh()

			local Name = f.editbox["Name"]
			local Command = f.editbox["Command"]
			local Desc = f.editbox["Desc"]
			local MinClass = f.editbox["MinClass"]
			local MaxClass = f.editbox["MaxClass"]
			local MinNonclass = f.editbox["MinNonclass"]
			local MaxNonclass = f.editbox["MaxNonclass"]
			local MaxPoints = f.editbox["MaxPoints"]
			local Divisor = f.editbox["Divisor"]
			local Diff = f.editbox["Diff"]
			local Nolist = f.checkbox["Nolist"]
			local Offspec = f.checkbox["Offspec"]
				
			local data = f.rulesSet[selectedSet.cols[cfs.set].value][selected.cols[cfc.command].value]
			Name:SetText(data["name"] or "")
			Command:SetText(data["command"] or "")
			Desc:SetText(data["desc"] or "")
			MinClass:SetText(data["minclass"] or "")
			MaxClass:SetText(data["maxclass"] or "")
			MinNonclass:SetText(data["minnonclass"] or "")
			MaxNonclass:SetText(data["maxnonclass"] or "")
			MaxPoints:SetText(data["maxpoints"] or "")
			Divisor:SetText(data["divisor"] or "")
			Diff:SetText(data["diff"] or "")
			Nolist:SetChecked(data["nolist"] or false)
			Offspec:SetChecked(data["offspec"] or false)
			return true
		end
	elseif button == "RightButton" then
		if data[realrow] then
			f.scrollFrame:SetSelection(realrow)
			RPR:DeleteRules()
		end
	end
	return true
end

function RPR:LoadData()
	local f = RPR.frames["RulesWindow"]
	f.rulesSetList = {}
	f.rulesList = {}
	f.rulesSet = {}
	for key,value in pairs(RPR.db.realm.rulesSets) do
		f.rulesSetList[#f.rulesSetList+1] = RPR:BuildRow(
			{
				[cfs.set]	= 	key,
			},
			cfsArg
		)
		f.rulesSet[key] = {}
		for k,v in pairs(value["commands"]) do
			if type(v) == "table" then
				f.rulesSet[key][k] = {}
				for k2,v2 in pairs(v) do
					f.rulesSet[key][k][k2] = v2
				end
			else
				f.rulesSet[key][k] = v
			end
		end
		for k,v in pairs(value) do
			if k ~= "commands" then
				f.rulesSet[key][k] = v
			end
		end
	end
	f.scrollFrame:ClearSelection()
	f.scrollFrame:SetData(f.rulesList)
	f.scrollFrame:SortData(f.rulesList)
	f.scrollSetFrame:ClearSelection()
	f.scrollSetFrame:SetData(f.rulesSetList)
	f.scrollSetFrame:SortData(f.rulesSetList)

end

function RPR:CommitChanges()
	local f = RPR.frames["RulesWindow"]
	self.db.realm.rulesSets = {}
	self.db.realm.settings.version = time()
	self:SaveData()
	for i=1,#f.rulesSetList do
		local index = f.rulesSetList[i].cols[cfs.set].value
		self.db.realm.rulesSets[index] = {}
		for key,value in pairs(f.rulesSet[index]) do
			if type(value) == "table" then
				if not self.db.realm.rulesSets[index]["commands"] then
					self.db.realm.rulesSets[index]["commands"] = {}
				end
				self.db.realm.rulesSets[index]["commands"][key] = value
			else
				self.db.realm.rulesSets[f.rulesSetList[i].cols[cfs.set].value][key] = value
			end
		end
	end
	if RPB then
		RPB:Send(cs.fssend, {self.db.realm.rulesSets, self.db.realm.settings.version})
	end
	f:Hide()
end

function RPR:CancelChanges()
	local f = RPR.frames["RulesWindow"]
	f:Hide()
end

function RPR:SaveData()
	local f = RPR.frames["RulesWindow"]
	if not f.scrollSetFrame:GetSelection() then return end
	local selectedSet = f.scrollSetFrame:GetRow(f.scrollSetFrame:GetSelection())
	local dataSet = f.rulesSet[selectedSet.cols[cfs.set].value]
	dataSet["name"] = f.editbox["RulesSetName"]:GetText()
	dataSet["description"] = f.editbox["RulesSetDesc"]:GetText()
	dataSet["ilvlmin"] = tonumber(f.editbox["RulesSetIlvlMin"]:GetText())
	dataSet["ilvlmax"] = tonumber(f.editbox["RulesSetIlvlMax"]:GetText())

	if not f.scrollFrame:GetSelection() then return end
	local selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
	local Name = f.editbox["Name"]
	local Command = f.editbox["Command"]
	local Desc = f.editbox["Desc"]
	local MinClass = f.editbox["MinClass"]
	local MaxClass = f.editbox["MaxClass"]
	local MinNonclass = f.editbox["MinNonclass"]
	local MaxNonclass = f.editbox["MaxNonclass"]
	local MaxPoints = f.editbox["MaxPoints"]
	local Divisor = f.editbox["Divisor"]
	local Diff = f.editbox["Diff"]
	local Nolist = f.checkbox["Nolist"]
	local Offspec = f.checkbox["Offspec"]

	local data = f.rulesSet[selectedSet.cols[cfs.set].value][selected.cols[cfc.command].value]
	data["name"]		= Name:GetText()
	data["command"]		= Command:GetText()
	data["desc"]		= Desc:GetText()
	data["minclass"]	= tonumber(MinClass:GetText())
	data["maxclass"]	= tonumber(MaxClass:GetText())
	data["minnonclass"]	= tonumber(MinNonclass:GetText())
	data["maxnonclass"]	= tonumber(MaxNonclass:GetText())
	data["maxpoints"]	= tonumber(MaxPoints:GetText())
	data["divisor"]		= tonumber(Divisor:GetText())
	data["diff"]		= tonumber(Diff:GetText())
	data["nolist"]		= Nolist:GetChecked()
	data["offspec"]		= Offspec:GetChecked()
	
end

function RPR:CreateRulesSet()
	local f = self.frames["RulesWindow"]
	local set = f.editbox["CreateRulesSet"]:GetText()
	if set ~= "" then
		f.rulesSetList[#f.rulesSetList+1] = self:BuildRow(
			{
				[cfs.set]	= 	set,
			},
			cfsArg
		)
		f.rulesSet[set] = {}
		f.scrollSetFrame:SortData()
		f.editbox["CreateRulesSet"]:SetText("")
		f.editbox["CreateRulesSet"]:ClearFocus()
	end
end

function RPR:DeleteRulesSet()
	local f = self.frames["RulesWindow"]
	if not f.scrollSetFrame:GetSelection() then return end
	local selectedSet = f.scrollSetFrame:GetRow(f.scrollSetFrame:GetSelection())
	for i=1,#f.rulesSetList do
		if f.rulesSetList[i] == selectedSet then
			tremove(f.rulesSetList,i)
			f.scrollSetFrame:ClearSelection()
			f.scrollSetFrame:SortData()
			break
		end
	end
end

function RPR:CreateRules()
	local f = self.frames["RulesWindow"]
	if not f.scrollSetFrame:GetSelection() then return end
	local command = f.editbox["CreateRules"]:GetText()
	if command ~= "" then
		local selectedSet = f.scrollSetFrame:GetRow(f.scrollSetFrame:GetSelection())
		f.rulesList[#f.rulesList+1] = self:BuildRow(
			{
				[cfc.command]	= 	command,
			},
			cfcArg
		)
		f.rulesSet[selectedSet.cols[cfc.command].value][command] = {}
		f.scrollFrame:SortData()
		f.editbox["CreateRules"]:SetText("")
		f.editbox["CreateRules"]:ClearFocus()
	end
end

function RPR:DeleteRules()
	local f = self.frames["RulesWindow"]
	if not f.scrollSetFrame:GetSelection() then return end
	if not f.scrollFrame:GetSelection() then return end
	local selectedSet = f.scrollSetFrame:GetRow(f.scrollSetFrame:GetSelection())
	local selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
	for i=1,#f.rulesList do
		if f.rulesList[i] == selected then
			f.rulesSet[selectedSet.cols[cfc.command].value][selected.cols[cfc.command].value] = nil
			tremove(f.rulesList,i)
			f.scrollFrame:ClearSelection()
			f.scrollFrame:SortData()
			break
		end
	end
end
