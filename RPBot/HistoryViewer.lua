--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/HistoryViewer.lua
	* Component: Roll Interface
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

--local prefix = "<RPB>"
local db = RPB.db
local cs = RPSConstants.syncCommands["Bot"]

--  Constants Roll List
local c = RPSConstants.stConstants["HistoryViewer"]
local cArg = RPSConstants.stArgs["HistoryViewer"]

--  Constants Roll List
local cp = RPSConstants.stConstants["HistoryViewerPopup"]
local cpArg = RPSConstants.stArgs["HistoryViewerPopup"]

local AceGUI = LibStub:GetLibrary("AceGUI-3.0")
local ScrollingTable = LibStub:GetLibrary("ScrollingTable");
--local f
--local fp

local function myFilter(self, row)
	local f = RPB.frames["HistoryViewer"]
	
	local namePass = false
	if (f.editbox["Name"]:GetText() ~= "") then
		if string.find(string.lower(row.cols[c.player].value), string.lower(f.editbox["Name"]:GetText())) then
			namePass = true
		end
	else
		namePass = true
	end
	
	local classPass = true
	for i, widget in f.dropdown["Class"].pullout:IterateItems() do
		if widget.type == "Dropdown-Item-Toggle" and widget:GetValue() then
			if string.lower(row.cols[c.class].value) == string.lower(widget:GetText()) then
				classPass = true
				break
			else
				classPass = false
			end
		end
	end
	
	local rankPass = true
	for i, widget in f.dropdown["Rank"].pullout:IterateItems() do
		if widget.type == "Dropdown-Item-Toggle" and widget:GetValue() then
			if string.lower(row.cols[c.rank].value) == string.lower(widget:GetText()) then
				rankPass = true
				break
			else
				rankPass = false
			end
		end
	end
	
	local points = f.dropdown["Points"].value
	local compare = f.dropdown["Compare"].text:GetText()
	local EPoints = f.editbox["Points"]:GetText()
	
	local pointsPass = false
	if (points ~= "" and compare ~= "" and EPoints ~= "") then
		EPoints = tonumber(EPoints)
		local value
		if type(row.cols[3+points].value) == "function" then 
			value = row.cols[3+points].value(unpack(row.cols[3+points].args or {}));
		else
			value = row.cols[3+points].value;
		end
		if compare == "<" and value < EPoints then
				pointsPass = true
		elseif compare == "<=" and value <= EPoints then
			pointsPass = true
		elseif compare == ">=" and value >= EPoints then
			pointsPass = true
		elseif compare == ">" and value > EPoints then
			pointsPass = true
		elseif compare == "==" and value == EPoints then
			pointsPass = true
		end
	else
		pointsPass = true
	end
	return namePass and classPass and rankPass and pointsPass
end

function RPB:CreateFrameHistoryViewerPopup()
	db = RPB.db
	-- if self.Frame then
	  -- self.Frame:Hide()
	-- end

	if not self.frames then
		self.frames = {}
	end
	if self.frames["HistoryViewerPopup"] then
		return
	end
	self.frames["HistoryViewePopupr"] = CreateFrame("Frame", "RPBHistoryViewerPopup", UIParent)
	--f = self.frames["HistoryViewer"]

	local f = self.frames["HistoryViewerPopup"]
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:SetFrameStrata("HIGH")
	f:SetFrameLevel(104)
	f:SetHeight(310)
	f:SetWidth(560)
	f:SetPoint("CENTER")
	f:Hide()
	
	f.dropdown = {}
	f.label = {}
	f.editbox = {}
	f.button = {}
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
		title:SetText("History Viewer")
		f.title = title
	end
	
    -- Scroll Frame
	do
		f.nameList = {}
	    f.scrollFrame = ScrollingTable:CreateST(RPSConstants.columnDefinitons["HistoryViewerPopup"], 10, nil, nil, f);
		f.scrollFrame:EnableSelection(true);
		f.scrollFrame.frame:SetParent(f)
		f.scrollFrame.frame:SetPoint("TOP", f, "TOP", 0, -35)
		f.scrollFrame:SetData(f.nameList)
		f.scrollFrame:RegisterEvents({
			["OnClick"] = HistoryViewerPopupScrollFrameOnClick,
			["OnDoubleClick"] = HistoryViewerPopupScrollFrameOnDoubleClick,
		});
	end

	local raidDropDown = {}
	for k,v in pairs(self.db.realm.raid) do
		raidDropDown[k] = k
	end

	f.raid = self.rpoSettings.raid
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(raidDropDown)
	dropdown:SetWidth(120)
	dropdown:SetHeight(20)
	dropdown:SetValue(f.raid)
	dropdown:SetPoint("TOPRIGHT", f.scrollFrame.frame, "BOTTOMRIGHT", 0, 0)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, isSelected, ...)
			RPB.frames["HistoryViewerPopup"].raid = value
			RPB:HistoryViewerRepopulate()
		end
	)
	f.dropdown["Raid"] = dropdown
	local font = f:CreateFontString("Raid","OVERLAY","GameTooltipText")
	font:SetText("Raid:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	f.label["Raid"] = font
	
	local button = CreateFrame("Button", f:GetName() .. "_ButtonDelete", f, "UIPanelButtonTemplate")
	button:SetWidth(75)
	button:SetHeight(21)
	button:SetPoint("BOTTOM", f, "BOTTOM", 40, 10)
	button:SetText("Delete")
	button:SetScript("OnClick", 
		function(self)
			local sf = RPB.frames["HistoryViewerPopup"].scrollFrame
			if sf:GetSelection() then
				local player = RPB:GetPlayer(sf:GetRow(sf:GetSelection()).cols[c.player].value)
				player.delete = true
				sf:ClearSelection()
				RPB:HistoryViewerRepopulate()
			end
		end
	)
	f.button["Delete"] = button
	
	local editbox = CreateFrame("EditBox", nil, f)
	f.editbox["Name"] = editbox
	editbox:SetAutoFocus(false)
	editbox:SetHeight(32)
	editbox:SetWidth(106)
	editbox:SetScript("OnTextChanged", function(self) 
			RPB.frames["HistoryViewer"].scrollFrame:SortData()
		end)
	editbox:SetPoint("TOPLEFT", f.scrollFrame.frame, "BOTTOMLEFT", 46, 3)
	
	self:SkinEditBox(editbox)
	self:ScriptEditBox(editbox)
	local font = f:CreateFontString("Name","OVERLAY","GameTooltipText")
	font:SetText("Name:")
	font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -8, -10)
	f.label["Name"] = font
	
	local classDropDown = {}
	for k,v in pairs(RPSConstants.classList) do
		classDropDown[v] = v
	end
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(classDropDown)
	dropdown:SetMultiselect(true)
	dropdown:SetWidth(120)
	dropdown:SetHeight(20)
	dropdown:SetPoint("TOPLEFT", f.editbox["Name"], "BOTTOMLEFT", -10, 4)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB.frames["HistoryViewer"].scrollFrame:SortData()
		end
	)
	f.dropdown["Class"] = dropdown
	local font = f:CreateFontString("Class","OVERLAY","GameTooltipText")
	font:SetText("Class:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	f.label["Class"] = font
	
	local rankDropDown = {}
	local ranks = self:GuildRanks()
	for i=1,#ranks do
		rankDropDown[i] = ranks[i]
	end
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(rankDropDown)
	dropdown:SetMultiselect(true)
	dropdown:SetWidth(120)
	dropdown:SetHeight(20)
	dropdown:SetPoint("TOPLEFT", f.dropdown["Class"].frame, "BOTTOMLEFT", 0, -6)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, isSelected, ...)
			RPB.frames["HistoryViewer"].scrollFrame:SortData()
		end
	)
	f.dropdown["Rank"] = dropdown
	local font = f:CreateFontString("Rank","OVERLAY","GameTooltipText")
	font:SetText("Rank:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	f.label["Rank"] = font
	
	local pointsDropDown =
	{
		"Earned",
		"Spent",
		"Total",
	}
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(pointsDropDown)
	--dropdown:SetMultiselect(true)
	dropdown:SetValue(3)
	dropdown:SetWidth(80)
	dropdown:SetHeight(20)
	dropdown:SetPoint("TOPLEFT", f.dropdown["Rank"].frame, "BOTTOMLEFT", 0, -6)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, isSelected, ...)
			RPB.frames["HistoryViewer"].scrollFrame:SortData()
		end
	)
	f.dropdown["Points"] = dropdown
	local font = f:CreateFontString("Points","OVERLAY","GameTooltipText")
	font:SetText("Points:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	f.label["Points"] = font
	
	local compareDropDown =
	{
		"<",
		"<=",
		"==",
		">=",
		">",
	}
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(compareDropDown)
	--dropdown:SetMultiselect(true)
	dropdown:SetValue(5)
	dropdown:SetWidth(60)
	dropdown:SetHeight(20)
	dropdown:SetPoint("TOPLEFT", f.dropdown["Points"].frame, "TOPRIGHT", 6, 0)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, isSelected, ...)
			RPB.frames["HistoryViewer"].scrollFrame:SortData()
		end
	)
	f.dropdown["Compare"] = dropdown
	
	local editbox = CreateFrame("EditBox", nil, f)
	f.editbox["Points"] = editbox
	editbox:SetAutoFocus(false)
	--editbox:SetNumeric()
	editbox:SetHeight(32)
	editbox:SetWidth(50)
	editbox:SetScript("OnTextChanged", function(self) 
			RPB.frames["HistoryViewer"].scrollFrame:SortData()
		end)
	editbox:SetPoint("TOPLEFT", f.dropdown["Compare"].frame, "TOPRIGHT", 6, 2)
	
	self:SkinEditBox(editbox)
	self:ScriptEditBox(editbox)
	
	-- local button = CreateFrame("Button", f:GetName() .. "_ButtonRemovePlayer", f, "UIPanelButtonTemplate")
	-- button:SetWidth(90)
	-- button:SetHeight(21)
	-- button:SetPoint("TOPLEFT", f.scrollFrame.frame, "BOTTOMLEFT", 2, -6)
	-- button:SetText("Remove Player")
	-- button:SetScript("OnClick", 
		-- function(self)
			-- myPopup(RPB, self.frames["HistoryViewer"], "Are you sure you want to remove this player?", function() RPB:HistoryViewerRemovePlayer() end)
		-- end
	-- )
	-- f.button["Remove"] = button
	
	-- Generate Data
	f.scrollFrame:SetFilter(myFilter)
	self:HistoryViewerRepopulate()
end

function RPB:UpdateHistoryViewerUI()
	local f = self.frames["HistoryViewer"]
	f.scrollFrame:SortData()
end

function HistoryViewerScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, down)
	local f = RPB.frames["HistoryViewer"]
	local selected
	if button == "LeftButton" then
		if data[realrow] then
			if f.scrollFrame:GetSelection() == realrow then
				selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
				selected.selected = false
				selected.highlight = nil
				f.scrollFrame:ClearSelection()
				f.scrollFrame:Refresh()
			else
				selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
				if selected then
					selected.selected = false
					selected.highlight = nil
				end
				f.scrollFrame:SetSelection(realrow)
				selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
				selected.selected = true
				selected.highlight = GetColor(UnitName("player"))
				f.scrollFrame:Refresh()
			end
		end
	elseif button == "RightButton" then
		if data[realrow] then
			if not RPB.frames["HistoryViewerPopup"] then
				RPB:CreateFrameHistoryViewerPopup()
			end
			RPB:HistoryViewerPopupSetup(f.raid, data[realrow].cols[c.player].value)
			selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
			if selected then
				selected.selected = false
				selected.highlight = nil
			end
			f.scrollFrame:SetSelection(realrow)
			selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
			selected.selected = true
			selected.highlight = GetColor(UnitName("player"))
			f.scrollFrame:Refresh()
		end
	end
	return true
end

function HistoryViewerScrollFrameOnDoubleClick(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, down)
	local f = RPB.frames["HistoryViewer"]
	local selected
	if button == "LeftButton" then
		if data[realrow] then
			if not RPB.frames["HistoryViewerPopup"] then
				RPB:CreateFrameHistoryViewerPopup()
			end
			RPB:HistoryViewerPopupSetup(f.raid, data[realrow].cols[c.player].value)
			selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
			if selected then
				selected.selected = false
				selected.highlight = nil
			end
			f.scrollFrame:SetSelection(realrow)
			selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
			selected.selected = true
			selected.highlight = GetColor(UnitName("player"))
			f.scrollFrame:Refresh()
		end
	elseif button == "RightButton" then
		if data[realrow] then
			--myPopup(RPB, self.frames["HistoryViewer"], "Are you sure you want to remove this player?", function() RPB:HistoryViewerRemovePlayer() end)
		end
	end
	return true
end

local function GetEarned(player)
	local pdata = RPB:GetPlayerHistory(player)
	return pdata.lifetime or 0
end

local function GetSpent(player)
	local pdata = RPB:GetPlayerHistory(player)
	return ( pdata.points - pdata.lifetime ) or 0
end

local function GetTotal(player)
	local pdata = RPB:GetPlayerHistory(player)
	return ( pdata.points ) or 0
end

function RPB:HistoryViewerRepopulate()
	local f = self.frames["HistoryViewer"]
	for i, col in pairs(f.scrollFrame.cols) do 
		if i ~= c.player then -- clear out all other sort marks
			f.scrollFrame.cols[i].sort = nil;
		end
	end
	f.scrollFrame.cols[c.player].sort = "dsc";
	f.nameList = {}
	for p,v in pairs(self.db.realm.raid[f.raid]) do
		local class, rank, player, pinfo
		pinfo = self:GetPlayer(p)
		if pinfo and not pinfo.delete then
			player = self:GetPlayer(p, "fullname")
			class = self:GetPlayer(p, "class")
			rank = self:GetPlayer(p, "rank")
			f.nameList[#f.nameList+1] = self:BuildRow(
				{
					[c.player]		= 	player,
					[c.class]		=	class or "",
					[c.rank]		=	rank or "",
					[c.earned]		= 	{GetEarned, {player}},
					[c.spent]		=	{GetSpent, {player}},
					[c.total]		=	{GetTotal, {player}},
				},
				cArg
			)
			if not f.nameList[#f.nameList].cols[1] then
				tremove(f.nameList,#f.nameList)
			end
		end
	end
	f.scrollFrame:SetData(f.nameList)
end

function RPB:CreateFrameHistoryViewer()
	db = RPB.db
	-- if self.Frame then
	  -- self.Frame:Hide()
	-- end

	if not self.frames then
		self.frames = {}
	end
	if self.frames["HistoryViewerPopup"] then
		return
	end
	self.frames["HistoryViewerPopup"] = CreateFrame("Frame", "RPBHistoryViewerPopup", self.frames["HistoryViewer"])
	local f = self.frames["HistoryViewerPopup"]

	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:SetFrameStrata("DIALOG")
	f:SetHeight(400)
	f:SetWidth(860)
	f:SetPoint("CENTER")
	f:Hide()
	
	f.dropdown = {}
	f.label = {}
	f.editbox = {}
	f.button = {}
	f.checkbox = {}

	-- Frame Textures, Drag Header, Close Button, Title
	do
		self:Skin(f);

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
		title:SetText("Points Viewer")
		f.title = title
	end
	
	local button = CreateFrame("Button", f:GetName() .. "_ButtonCommit", f, "UIPanelButtonTemplate")
	button:SetWidth(75)
	button:SetHeight(21)
	button:SetPoint("BOTTOM", f, "BOTTOM", -40, 10)
	button:SetText("Commit")
	button:SetScript("OnClick", 
		function(self)
			RPB:HistoryViewerPopupCommitChanges()
		end
	)
	f.button["Commit"] = button
	
	local button = CreateFrame("Button", f:GetName() .. "_ButtonCancel", f, "UIPanelButtonTemplate")
	button:SetWidth(75)
	button:SetHeight(21)
	button:SetPoint("BOTTOM", f, "BOTTOM", 40, 10)
	button:SetText("Cancel")
	button:SetScript("OnClick", 
		function(self)
			RPB:HistoryViewerPopupCancelChanges()
		end
	)
	f.button["Cancel"] = button
	
    -- Scroll Frame
	do
		f.nameList = {}
	    f.scrollFrame = ScrollingTable:CreateST(RPSConstants.columnDefinitons["HistoryViewerPopup"], 10, nil, nil, f);
		f.scrollFrame:EnableSelection(true);
		f.scrollFrame.frame:SetParent(f)
		f.scrollFrame.frame:SetPoint("TOP", f, "TOP", 0, -35)
		f.scrollFrame:SetData(f.nameList)
		f.scrollFrame:RegisterEvents({
			["OnEnter"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...) 
				if data[realrow] then
					if RPB:GetItemID(data[realrow].cols[cp.reason].value) then
						GameTooltip:SetOwner(rowFrame, "ANCHOR_CURSOR")
						GameTooltip:ClearLines()
						GameTooltip:SetHyperlink(data[realrow].cols[cp.reason].value)
						GameTooltip:Show()
					end
				end
			end,
			["OnLeave"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...) 
				GameTooltip:Hide()
			end,
			["OnClick"] = HistoryViewerPopupScrollFrameOnClick,
			["OnDoubleClick"] = HistoryViewerPopupScrollFrameOnDoubleClick,
		});
	end
		
	local button = CreateFrame("Button", f:GetName() .. "_ButtonRemove", f, "UIPanelButtonTemplate")
	button:SetWidth(75)
	button:SetHeight(21)
	button:SetPoint("TOPRIGHT", f.scrollFrame.frame, "BOTTOMRIGHT", -6, 0)
	button:SetText("Remove")
	button:SetScript("OnClick", 
		function(self)
			RPB:HistoryViewerPopupRemoveClick()
		end
	)
	f.button["Remove"] = button

	local button = CreateFrame("Button", f:GetName() .. "_ButtonEdit", f, "UIPanelButtonTemplate")
	button:SetWidth(75)
	button:SetHeight(21)
	button:SetPoint("TOPRIGHT", f.button["Remove"], "TOPLEFT", -6, 0)
	button:SetText("Edit")
	button:SetScript("OnClick", 
		function(self)
			RPB:HistoryViewerPopupEditClick()
		end
	)
	f.button["Edit"] = button
	
	local button = CreateFrame("Button", f:GetName() .. "_ButtonAdd", f, "UIPanelButtonTemplate")
	button:SetWidth(75)
	button:SetHeight(21)
	button:SetPoint("TOPRIGHT", f.button["Edit"], "TOPLEFT", -6, 0)
	button:SetText("Add")
	button:SetScript("OnClick", 
		function(self)
			RPB:HistoryViewerPopupAddClick()
		end
	)
	f.button["Add"] = button
	
		-- id 				= -1,
		-- name 			= string.lower(k),
		-- fullname 		= v.fullname or player:gsub("^%l", string.upper),
		-- class			= v.class or "Unknown",
		-- talent			= "Unknown",
		-- points			= 0,
		-- lifetime		= 0,
	-- recenthistory 	=
	-- recentactions 	=
			-- datetime 	= 0,
			-- ty			= 'P',
			-- itemid		= 0,
			-- reason		= "Old Points",
			-- value		= 0,
			-- waitlist	= false,
			-- action		= "Insert",
	
	local editbox = CreateFrame("EditBox", nil, f)
	f.editbox["Name"] = editbox
	editbox:SetAutoFocus(false)
	editbox:SetHeight(32)
	editbox:SetWidth(106)
	--editbox:SetScript("OnTextChanged", function(self) end)
	editbox:SetPoint("TOPLEFT", f.scrollFrame.frame, "BOTTOMLEFT", 46, 3)
	self:SkinEditBox(editbox)
	self:ScriptEditBox(editbox)
	local font = f:CreateFontString("Name","OVERLAY","GameTooltipText")
	font:SetText("Name:")
	font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -8, -10)
	f.label["Name"] = font
	
	local classDropDown = {["Unknown"] = "Unknown"}
	for k,v in pairs(RPSConstants.classList) do
		classDropDown[v] = v
	end
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(classDropDown)
	dropdown:SetWidth(120)
	dropdown:SetHeight(20)
	dropdown:SetPoint("TOPLEFT", f.editbox["Name"], "BOTTOMLEFT", -10, 4)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
		end
	)
	f.dropdown["Class"] = dropdown
	local font = f:CreateFontString("Class","OVERLAY","GameTooltipText")
	font:SetText("Class:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	f.label["Class"] = font
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetWidth(120)
	dropdown:SetHeight(20)
	dropdown:SetPoint("TOPLEFT", f.dropdown["Class"].frame, "BOTTOMLEFT", 0, -6)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, isSelected, ...)
		end
	)
	f.dropdown["Spec"] = dropdown
	local font = f:CreateFontString("Spec","OVERLAY","GameTooltipText")
	font:SetText("Spec:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	f.label["Spec"] = font
	
	local font = f:CreateFontString("Points","OVERLAY","GameTooltipText")
	font:SetText("Points:")
	font:SetPoint("TOPLEFT", f.dropdown["Spec"].frame, "BOTTOMLEFT", 0, -6)
	f.label["Points"] = font
	
	local font = f:CreateFontString("Lifetime","OVERLAY","GameTooltipText")
	font:SetText("Lifetime:")
	font:SetPoint("TOPLEFT", f.label["Points"], "BOTTOMLEFT", 0, -6)
	f.label["Lifetime"] = font

	local dt = date()
	local timetable = 
	{
		year 	= tonumber("20"..string.sub(dt,7,8)),
		month 	= tonumber(string.sub(dt,1,2)),
		day 	= tonumber(string.sub(dt,4,5)),
		hour 	= tonumber(string.sub(dt,10,11)),
		min 	= tonumber(string.sub(dt,13,14)),
		sec 	= tonumber(string.sub(dt,16,17)),
	}
	
	local m = timetable.month-1
	local y = timetable.year
	if m == 0 then
		m = 1
		y = y - 1
	end
	local day = timetable.day - 30 + get_days_in_month(m, y)
	local dayDropDown = {}
	local dayUse = day
	for i=day,day+60 do
		local d = dayUse
		local dm = get_days_in_month(m, y)
		if d > dm then
			d = d - dm
			dayUse = dayUse - dm
			if m == timetable.month-1 then
				m = m + 1
				if m == 13 then
					m = 1
					y = y + 1
				end
			end
		end
		local tt = 
		{
			year 	= y,
			month 	= m,
			day 	= d,
		}
		local sd = d
		local sm = m
		local sy = y
		if d < 10 then
			sd = "0" .. d
		end
		if m < 10 then
			sm = "0" .. m
		end
		if y < 10 then
			sy = "0" .. y
		end
		dayDropDown[time(tt)] = sd .. "/" .. sm .. "/" .. sy
		dayUse = dayUse + 1
	end
	
	local hour = {}
	local minute = {}
	local second = {}
	for i=0,23 do
		if i < 10 then
			hour[i] = "0"..tostring(i)
		else
			hour[i] = tostring(i)
		end
	end
	for i=0,59 do
		if i < 10 then
			minute[i] = "0"..tostring(i)
		else
			minute[i] = tostring(i)
		end
	end
	for i=0,59 do
		if i < 10 then
			second[i] = "0"..tostring(i)
		else
			second[i] = tostring(i)
		end
	end
	
	
	
		
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(second)
	dropdown:SetWidth(75)
	dropdown:SetHeight(20)
	--dropdown:SetValue(0)
	dropdown:SetPoint("TOPRIGHT", f.button["Remove"], "BOTTOMRIGHT", 0, 0)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["Second"] = dropdown	

	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(minute)
	dropdown:SetWidth(75)
	dropdown:SetHeight(20)
	--dropdown:SetValue(0)
	dropdown:SetPoint("TOPRIGHT", f.dropdown["Second"].frame, "TOPLEFT", -6, 0)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["Minute"] = dropdown	

	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(hour)
	dropdown:SetWidth(75)
	dropdown:SetHeight(20)
	--dropdown:SetValue(18)
	dropdown:SetPoint("TOPRIGHT", f.dropdown["Minute"].frame, "TOPLEFT", -6, 0)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["Hour"] = dropdown
	local font = f:CreateFontString("Date","OVERLAY","GameTooltipText")
	font:SetText("Time:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)

	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(dayDropDown)
	dropdown:SetWidth(120)
	dropdown:SetHeight(20)
	--dropdown:SetValue(18)
	dropdown:SetPoint("TOPRIGHT", f.dropdown["Hour"].frame, "TOPLEFT", -46, 0)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["Date"] = dropdown
	local font = f:CreateFontString("Date","OVERLAY","GameTooltipText")
	font:SetText("Date:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	
	local editbox = CreateFrame("EditBox", nil, f)
	f.editbox["Type"] = editbox
	editbox:SetAutoFocus(false)
	editbox:SetHeight(32)
	editbox:SetWidth(40)
	editbox:SetScript("OnTextChanged", function(self) 
			--RPB.frames["HistoryViewer"].scrollFrame:SortData()
		end)
	editbox:SetPoint("TOPRIGHT", f.dropdown["Second"].frame, "BOTTOMRIGHT", 0, 0)
	self:SkinEditBox(editbox)
	self:ScriptEditBox(editbox)
	local font = f:CreateFontString("Type","OVERLAY","GameTooltipText")
	font:SetText("Type:")
	font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -8, -10)
	f.label["Type"] = font
	
	local editbox = CreateFrame("EditBox", nil, f)
	f.editbox["Value"] = editbox
	editbox:SetAutoFocus(false)
	editbox:SetHeight(32)
	editbox:SetWidth(40)
	editbox:SetScript("OnTextChanged", function(self) 
			--RPB.frames["HistoryViewer"].scrollFrame:SortData()
		end)
	editbox:SetPoint("TOPRIGHT", f.editbox["Type"], "BOTTOMRIGHT", 0, 8)
	--editbox:SetNumeric()
	self:SkinEditBox(editbox)
	self:ScriptEditBox(editbox)
	local font = f:CreateFontString("Value","OVERLAY","GameTooltipText")
	font:SetText("Value:")
	font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -8, -10)
	f.label["Value"] = font
	
	-- local editbox = CreateFrame("EditBox", nil, f)
	-- f.editbox["Itemid"] = editbox
	-- editbox:SetAutoFocus(false)
	-- editbox:SetHeight(32)
	-- editbox:SetWidth(106)
	-- editbox:SetScript("OnTextChanged", function(self) 
			--RPB.frames["HistoryViewer"].scrollFrame:SortData()
		-- end)
	-- editbox:SetPoint("TOPRIGHT", f.checkbox["Waitlist"], "BOTTOMRIGHT", 0, 8)
	-- self:SkinEditBox(editbox)
	-- self:ScriptEditBox(editbox)
	-- local font = f:CreateFontString("Itemid","OVERLAY","GameTooltipText")
	-- font:SetText("Itemid:")
	-- font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -8, -10)
	-- f.label["Itemid"] = font
		
	local editbox = CreateFrame("EditBox", nil, f)
	f.editbox["Reason"] = editbox
	editbox:SetAutoFocus(false)
	editbox:SetHeight(32)
	editbox:SetWidth(106)
	editbox:SetScript("OnTextChanged", function(self) 
			--RPB.frames["HistoryViewer"].scrollFrame:SortData()
		end)
	editbox:SetPoint("TOPRIGHT", f.editbox["Value"], "BOTTOMRIGHT", 0, 8)
	self:SkinEditBox(editbox)
	self:ScriptEditBox(editbox, true)
	local font = f:CreateFontString("Reason","OVERLAY","GameTooltipText")
	font:SetText("Reason:")
	font:SetPoint("TOPRIGHT", editbox, "TOPLEFT", -8, -10)
	f.label["Reason"] = font
	

	local checkbox = CreateFrame("CheckButton", nil, f, "OptionsCheckButtonTemplate")
	f.checkbox["Waitlist"] = checkbox
	checkbox:SetPoint("TOPRIGHT", f.editbox["Reason"], "BOTTOMRIGHT", 0, 8)
	local font = f:CreateFontString("Waitlist","OVERLAY","GameTooltipText")
	font:SetText("Waitlist:")
	font:SetPoint("TOPRIGHT", checkbox, "TOPLEFT", 0, -8)

	local checkbox = CreateFrame("CheckButton", nil, f, "OptionsCheckButtonTemplate")
	f.checkbox["Whisper"] = checkbox
	checkbox:SetPoint("BOTTOMRIGHT", f.button["Commit"], "TOPRIGHT", 0, 0)
	local font = f:CreateFontString("Whisper","OVERLAY","GameTooltipText")
	font:SetText("Whisper:")
	font:SetPoint("TOPRIGHT", checkbox, "TOPLEFT", 0, -8)
	
	local button = CreateFrame("Button", f:GetName() .. "_ButtonSave", f, "UIPanelButtonTemplate")
	button:SetWidth(75)
	button:SetHeight(21)
	button:SetPoint("TOPRIGHT", f.checkbox["Waitlist"], "BOTTOMRIGHT", 0, 0)
	button:SetText("Save")
	button:SetScript("OnClick", 
		function(self)
			RPB:HistoryViewerPopupSaveClick()
		end
	)
	f.button["Save"] = button
	-- Generate Data
	f.actionList = {}
end

function HistoryViewerPopupScrollFrameColor(row)
	local f = RPB.frames["HistoryViewerPopup"]
	for k,v in pairs(f.actionList) do
		if row.cols[cp.actiontime].value == v.at then
			if row.cols[cp.action].value ~= v.action then
				return {
					["r"] = 1.0,
					["g"] = 0.0,
					["b"] = 0.0,
					["a"] = 1.0
					}
				elseif row.cols[cp.action].value == "Update" then
				return {
					["r"] = 0.0,
					["g"] = 0.0,
					["b"] = 1.0,
					["a"] = 1.0
					}
			else
				return {
					["r"] = 0.0,
					["g"] = 1.0,
					["b"] = 0.0,
					["a"] = 1.0
					}
			end
		elseif row.cols[cp.actiontime].value == v.actiontime then
			if row.cols[cp.action].value ~= v.action then
				return {
					["r"] = 1.0,
					["g"] = 0.0,
					["b"] = 0.0,
					["a"] = 1.0
					}
			end
		end
	end
	return {
		["r"] = 1.0,
		["g"] = 1.0,
		["b"] = 1.0,
		["a"] = 1.0
		}
end

function RPB:HistoryViewerPopupScrollFrameRefresh()
	local f = self.frames["HistoryViewerPopup"]
	for i, col in pairs(f.scrollFrame.cols) do 
		if i ~= cp.actiontime then -- clear out all other sort marks
			f.scrollFrame.cols[i].sort = nil;
		end
	end
	f.scrollFrame.cols[cp.actiontime].sort = "asc";
	f.scrollFrame:SortData()
end

function RPB:HistoryViewerPopupSetup(raid, player)
	local f = self.frames["HistoryViewerPopup"]
	f.raid = raid
	f.player = player
	local pinfo = self:GuildRosterByName(player) or self:RosterByName(player:gsub("^%l", string.upper))
	local history = self:GetPlayerHistory(player, raid)
	player = self:GetPlayer(player)
	f.editbox["Name"]:SetText(player.fullname)
	f.dropdown["Class"]:SetValue(string.upper(player.class))
	local found = false
	f.dropdown["Spec"]:SetList(RPSConstants.talentList[string.upper(player.class)])
	for k,v in pairs(RPSConstants.talentList[string.upper(player.class)]) do
		if string.lower(v) == string.lower(player.talent) then
			f.dropdown["Spec"]:SetValue(k)
			found = true
			break
		end
	end
	if not found then f.dropdown["Spec"]:SetValue(3) end
	f.label["Points"]:SetText("Points: "..history.points)
	f.label["Lifetime"]:SetText("Lifetime: "..history.lifetime)
	
	f.historyList = {}
	for actiontime,value in pairs(history.recenthistory) do
		f.historyList[#f.historyList+1] = self:BuildRow(
			{
				[cp.datetime]	= 	value.datetime,
				[cp.ty]			=	value.ty,
				[cp.itemid]		=	value.itemid,
				[cp.reason]		=	value.reason,
				[cp.value]		=	value.value,
				[cp.waitlist]	=	value.waitlist,
				[cp.action]		=	value.action,
				[cp.actiontime]	=	actiontime,
			},
			cpArg, HistoryViewerPopupScrollFrameColor
		)
	end
	for actiontime,value in pairs(history.recentactions) do
		f.historyList[#f.historyList+1] = self:BuildRow(
			{
				[cp.datetime]	= 	value.datetime,
				[cp.ty]			=	value.ty,
				[cp.itemid]		=	value.itemid,
				[cp.reason]		=	value.reason,
				[cp.value]		=	value.value,
				[cp.waitlist]	=	value.waitlist,
				[cp.action]		=	value.action,
				[cp.actiontime]	=	actiontime,
			},
			cpArg, HistoryViewerPopupScrollFrameColor
		)
	end
	

	f.scrollFrame:SetData(f.historyList)
	f.title:SetText(player.fullname)
	f:Show()
	f:SetPoint("CENTER")
	
	local dt = date()
	local tt = 
	{
		year 	= tonumber("20"..string.sub(dt,7,8)),
		month 	= tonumber(string.sub(dt,1,2)),
		day 	= tonumber(string.sub(dt,4,5)),
	}
	f.dropdown["Date"]:SetValue(time(tt))
	f.dropdown["Hour"]:SetValue(0)
	f.dropdown["Minute"]:SetValue(0)
	f.dropdown["Second"]:SetValue(0)
	
	f.dropdown["Date"]:SetDisabled(true)
	f.dropdown["Hour"]:SetDisabled(true)
	f.dropdown["Minute"]:SetDisabled(true)
	f.dropdown["Second"]:SetDisabled(true)
	
	f.editbox["Type"]:SetText("")
	f.editbox["Value"]:SetText("")
	f.editbox["Reason"]:SetText("")
	f.checkbox["Waitlist"]:SetChecked(0)
	--f.checkbox["Whisper"]:SetChecked(0)
	
	f.actionList = {}
	self:HistoryViewerPopupScrollFrameRefresh()
end

function RPB:HistoryViewerPopupCommitChanges()
	local f = self.frames["HistoryViewerPopup"]
	
	-- f.actionList[#f.actionList+1] = 
	-- {
		-- at 			-- Time this action was processed.
		-- actiontime 	-- Time this action was done in the past
		-- datetime 	-- Time this action was done originally.
		-- --datetime = actiontime when they were added for the same time
		-- ty			-- Type, item or points
		-- itemid		-- Itemid if type is an item, this can always be gained from 'reason'
		-- reason		-- Item link, or reason text.
		-- value		-- Value given or taken away
		-- waitlist	-- Toggle if the person was on the waitlist
		-- whiser		-- Wether or not this change should be whispered to the player
		-- action		-- The action to be performed by the base data classes.
	-- }
	
	local whisper = f.checkbox["Whisper"]:GetChecked()
	
	for k,v in ipairs(f.actionList) do
		if v.action == "Insert" then
			self:PointsAdd(f.raid, v.actiontime, v.datetime, f.player, v.value, v.ty, v.itemid, v.reason, v.waitlist, whisper)
		elseif v.action == "Update" then
			self:PointsUpdate(f.raid, v.at, v.actiontime, v.datetime, f.player, v.value, v.ty, v.itemid, v.reason, v.waitlist, whisper)
		elseif v.action == "Delete" then
			self:PointsRemove(f.raid, v.at, v.actiontime, v.datetime, f.player, whisper)
		end
	end
	
	f:Hide()
end

function RPB:HistoryViewerPopupCancelChanges()
	local f = self.frames["HistoryViewerPopup"]
	f:Hide()
end

function RPB:HistoryViewerPopupAddClick()
	local f = self.frames["HistoryViewerPopup"]
	local dt = date()
	local tt = 
	{
		year 	= tonumber("20"..string.sub(dt,7,8)),
		month 	= tonumber(string.sub(dt,1,2)),
		day 	= tonumber(string.sub(dt,4,5)),
	}
	f.dropdown["Date"]:SetValue(time(tt))
	local tt = 
	{
		hour 	= tonumber(string.sub(dt,10,11)),
		min 	= tonumber(string.sub(dt,13,14)),
		sec 	= tonumber(string.sub(dt,16,17)),
	}
	f.dropdown["Hour"]:SetValue(tt.hour)
	f.dropdown["Minute"]:SetValue(tt.min)
	f.dropdown["Second"]:SetValue(tt.sec)
	
	f.dropdown["Date"]:SetDisabled(false)
	f.dropdown["Hour"]:SetDisabled(false)
	f.dropdown["Minute"]:SetDisabled(false)
	f.dropdown["Second"]:SetDisabled(false)
	
	f.editbox["Type"]:SetText("")
	f.editbox["Value"]:SetText("")
	f.editbox["Reason"]:SetText("")
	f.checkbox["Waitlist"]:SetChecked(0)
	--f.checkbox["Whisper"]:SetChecked(0)
	f.action = "Add"
end

function RPB:HistoryViewerPopupEditClick()
	local f = self.frames["HistoryViewerPopup"]
	if not f.scrollFrame:GetSelection() then return end
	
	local dt = date(nil,f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.datetime].value)
	local tt = 
	{
		year 	= tonumber("20"..string.sub(dt,7,8)),
		month 	= tonumber(string.sub(dt,1,2)),
		day 	= tonumber(string.sub(dt,4,5)),
	}
	f.dropdown["Date"]:SetValue(time(tt))
	local tt = 
	{
		hour 	= tonumber(string.sub(dt,10,11)),
		min 	= tonumber(string.sub(dt,13,14)),
		sec 	= tonumber(string.sub(dt,16,17)),
	}
	f.dropdown["Hour"]:SetValue(tt.hour)
	f.dropdown["Minute"]:SetValue(tt.min)
	f.dropdown["Second"]:SetValue(tt.sec)
	
	f.dropdown["Date"]:SetDisabled(true)
	f.dropdown["Hour"]:SetDisabled(true)
	f.dropdown["Minute"]:SetDisabled(true)
	f.dropdown["Second"]:SetDisabled(true)
	
	f.editbox["Type"]:SetText(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.ty].value)
	f.editbox["Value"]:SetText(tonumber(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.value].value))
	f.editbox["Reason"]:SetText(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.reason].value)
	f.checkbox["Waitlist"]:SetChecked(tonumber(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.waitlist].value) or 0)
	--f.checkbox["Whisper"]:SetChecked(0)
	f.action = "Edit"
	f.actiontime = f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.actiontime].value
	f.datetime = f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.datetime].value
end

function RPB:HistoryViewerPopupRemoveClick()
	local f = self.frames["HistoryViewerPopup"]
	if not f.scrollFrame:GetSelection() then return end

	local found = false
	for i=1,#f.actionList do
		if f.actionList[i].actiontime == f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.actiontime].value then
			tremove(f.historyList,f.actionList[i].historyList)
			tremove(f.actionList,i)
			found = true
			break
		elseif f.actionList[i].datetime == f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.actiontime].value then
			tremove(f.historyList,f.actionList[i].historyList)
			tremove(f.actionList,i)
			found = true
			break
		end
	end
	
	if found then RPB:HistoryViewerPopupScrollFrameRefresh() return end
	local deletetime = time()
	local action
	local color = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}
	if f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.action].value == "Insert" then
		f.actionList[#f.actionList+1] = 
		{
			at			= deletetime,
			actiontime 	= deletetime,
			datetime 	= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.datetime].value,
			ty			= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.ty].value,
			itemid		= self:GetItemID(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.reason].value) or 0,
			reason		= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.reason].value,
			value		= tonumber(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.value].value),
			waitlist	= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.waitlist].value,
			action		= "Delete",
		}
		action = "Delete"
	elseif f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.action].value == "Delete" then
		f.actionList[#f.actionList+1] = 
		{
			at			= deletetime,
			actiontime 	= deletetime,
			datetime 	= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.datetime].value,
			ty			= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.ty].value,
			itemid		= self:GetItemID(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.reason].value) or 0,
			reason		= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.reason].value,
			value		= -(tonumber(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.value].value)),
			waitlist	= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.waitlist].value,
			action		= "Insert",
		}
		action = "Insert"
	elseif f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.action].value == "Update" then
		f.actionList[#f.actionList+1] = 
		{
			at			= deletetime,
			actiontime 	= deletetime,
			datetime 	= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.datetime].value,
			ty			= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.ty].value,
			itemid		= self:GetItemID(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.reason].value) or 0,
			reason		= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.reason].value,
			value		= -(tonumber(f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.value].value)),
			waitlist	= f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.waitlist].value,
			action		= "Update",
		}
		action = "Update"
		color = {r = 0.0, g = 0.0, b = 1.0, a = 1.0}
	end
	f.historyList[#f.historyList+1] = self:BuildRow(
		{
			[cp.actiontime]	= 	deletetime,
			[cp.datetime]	= 	f.actionList[#f.actionList].datetime,
			[cp.ty]			=	f.actionList[#f.actionList].ty,
			[cp.itemid]		=	f.actionList[#f.actionList].itemid,
			[cp.reason]		=	f.actionList[#f.actionList].reason,
			[cp.value]		=	f.actionList[#f.actionList].value,
			[cp.waitlist]	=	f.actionList[#f.actionList].waitlist,
			[cp.action]		=	action,
		},
		cpArg, HistoryViewerPopupScrollFrameColor
	)
	self:HistoryViewerPopupScrollFrameRefresh()
	f.actionList[#f.actionList].historyList = #f.historyList
end

function RPB:HistoryViewerPopupSaveClick()
	local f = self.frames["HistoryViewerPopup"]
	local savetime = time()
	local action
	local color = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}
	
	local dt = date(nil, f.dropdown["Date"].value)
	local timetable = 
	{
		year 	= tonumber("20"..string.sub(dt,7,8)),
		month 	= tonumber(string.sub(dt,1,2)),
		day 	= tonumber(string.sub(dt,4,5)),
		hour 	= tonumber(f.dropdown["Hour"].value),
		min 	= tonumber(f.dropdown["Minute"].value),
		sec 	= tonumber(f.dropdown["Second"].value),
	}
	
	f.dropdown["Date"]:SetDisabled(true)
	f.dropdown["Hour"]:SetDisabled(true)
	f.dropdown["Minute"]:SetDisabled(true)
	f.dropdown["Second"]:SetDisabled(true)
	
	if f.action == "Add" then
		f.actionList[#f.actionList+1] = 
		{
			at 			= time(timetable),
			actiontime 	= time(timetable),
			datetime 	= time(timetable),
			ty			= f.editbox["Type"]:GetText(),
			itemid		= self:GetItemID(f.editbox["Reason"]:GetText()) or 0,
			reason		= f.editbox["Reason"]:GetText(),
			value		= f.editbox["Value"]:GetText(),
			waitlist	= f.checkbox["Waitlist"]:GetChecked(),
			action		= "Insert",
		}
		action = "Insert"
		color = {r = 0.0, g = 1.0, b = 0.0, a = 1.0}
	elseif f.action == "Edit" then
		if not f.scrollFrame:GetSelection() then return end
		local found = false
		for i=1,#f.actionList do
			if f.actionList[i].at == f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.actiontime].value then
				for j=1,#f.historyList do
					if f.historyList[j].cols[cp.actiontime].value == f.actionList[i].at then
						tremove(f.historyList,j)
						found = true
						break
					end
				end
				tremove(f.actionList,i)
				break
			elseif f.actionList[i].actiontime == f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.actiontime].value then
				for j=1,#f.historyList do
					if f.historyList[j].cols[cp.actiontime].value == f.actionList[i].at then
						tremove(f.historyList,j)
						found = true
						break
					end
				end
				tremove(f.actionList,i)
				break
			elseif f.actionList[i].datetime == f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.datetime].value then
				for j=1,#f.historyList do
					if f.historyList[j].cols[cp.actiontime].value == f.actionList[i].at then
						tremove(f.historyList,j)
						found = true
						break
					end
				end
				tremove(f.actionList,i)
				break
			end
		end
		
		for i=1,#f.actionList do
			if f.actionList[i].actiontime == f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols[cp.actiontime].value then
				tremove(f.historyList,f.actionList[i].historyList)
				tremove(f.actionList,i)
				break
			end
		end	
		
		f.actionList[#f.actionList+1] = 
		{
			at 			= savetime,
			actiontime 	= savetime,
			datetime 	= f.datetime,
			ty			= f.editbox["Type"]:GetText(),
			itemid		= self:GetItemID(f.editbox["Reason"]:GetText()) or 0,
			reason		= f.editbox["Reason"]:GetText(),
			value		= f.editbox["Value"]:GetText(),
			waitlist	= f.checkbox["Waitlist"]:GetChecked(),
			action		= "Update",
		}
		action = "Update"
		color = {r = 0.0, g = 0.0, b = 1.0, a = 1.0}
	end
	f.historyList[#f.historyList+1] = self:BuildRow(
		{
			[cp.actiontime]	= 	savetime,
			[cp.datetime]	= 	f.actionList[#f.actionList].datetime,
			[cp.ty]			=	f.actionList[#f.actionList].ty,
			[cp.itemid]		=	f.actionList[#f.actionList].itemid,
			[cp.reason]		=	f.actionList[#f.actionList].reason,
			[cp.value]		=	f.actionList[#f.actionList].value,
			[cp.waitlist]	=	f.actionList[#f.actionList].waitlist,
			[cp.action]		=	action,
		},
		cpArg, HistoryViewerPopupScrollFrameColor
	)
	self:HistoryViewerPopupScrollFrameRefresh()
	f.actionList[#f.actionList].historyList = #f.historyList
end

function HistoryViewerPopupScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, down)
	local f = RPB.frames["HistoryViewerPopup"]
	if button == "LeftButton" then
		if data[realrow] then
			local selected
			if f.scrollFrame:GetSelection() == realrow then
				selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
				selected.selected = false
				selected.highlight = nil
				f.scrollFrame:ClearSelection()
				f.scrollFrame:Refresh()
			else
				selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
				if f.scrollFrame:GetSelection() then
					selected.selected = nil
					selected.highlight = nil
				end
				f.scrollFrame:SetSelection(realrow)
				selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection())
				selected.selected = true
				selected.highlight = GetColor(UnitName("player"))
				f.scrollFrame:Refresh()
			end
		end
	elseif button == "RightButton" then
		if data[realrow] then
			--myPopup(RPB, self.frames["HistoryViewerPopup"], "Are you sure you want to remove this player?", function() RPB:HistoryViewerPopupRemovePlayer() end)
		end
	end
	return true
end
