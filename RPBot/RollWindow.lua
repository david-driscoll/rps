--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/RollWindow.lua
	* Component: Roll Interface
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

--local prefix = "<RPB>"
local db = RPB.db
local cs = RPSConstants.syncCommands["Bot"]

--  Constants Roll List
local crl = RPSConstants.stConstants["RollWindow"]
local crlArg = RPSConstants.stArgs["RollWindow"]

-- Constants Loot List
local cll = RPSConstants.stConstants["RollWindowLootList"]
local cllArg = RPSConstants.stArgs["RollWindowLootList"]

-- Constants  Officer Names
local con = RPSConstants.stConstants["RollWindowNameList"]
local conArg = RPSConstants.stArgs["RollWindowNameList"]

local AceGUI = LibStub:GetLibrary("AceGUI-3.0")
local ScrollingTable = LibStub:GetLibrary("ScrollingTable");

local function RPB_GetPoints(player)
	local pdata = RPB:GetPlayerHistory(player)
	return pdata.points or 0
end

local function RPB_GetTotal(player)
	local f = RPB.frames["RollWindow"]
	local rollList = f.rollList
	local pdata = RPB:GetPlayerHistory(player)
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			return RPB:CalculateMaxPoints(pdata.points, rollList[i].cols[crl.ty].value) + rollList[i].cols[crl.roll].value
		end
	end
	return 0
end

local function RPB_GetMaxPoints(player)
	local f = RPB.frames["RollWindow"]
	local rollList = f.rollList
	local pdata = RPB:GetPlayerHistory(player)
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			return RPB:CalculateMaxPoints(pdata.points, rollList[i].cols[crl.ty].value)
		end
	end
	return 0
end

local function RPB_GetLoss(player)
	local f = RPB.frames["RollWindow"]
	local rollList = f.rollList
	local pdata = RPB:GetPlayerHistory(player)
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			return RPB:CalculateLoss(pdata.points, rollList[i].cols[crl.ty].value)		
		end
	end
	return 0
end

function RPB:CreateFrameRollWindow()
	db = RPB.db
	-- if self.Frame then
	  -- self.Frame:Hide()
	-- end

	if not self.frames then
		self.frames = {}
	end
	self.frames["RollWindow"] = CreateFrame("Frame", "RPBRollWindow", UIParent)

	local f = self.frames["RollWindow"]
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	--   f:SetResizeable(true)
	f:SetFrameStrata("DIALOG")
	f:SetFrameLevel(103)
	f:SetHeight(440)
	f:SetWidth(620)
	f:SetPoint("CENTER")
	f:Hide()

	-- Frame Textures, Drag Header, Close Button, Title
	do
		self:Skin(f);
	   
		local button = CreateFrame("Button", f:GetName() .. "_CloseButton", f, "UIPanelCloseButton")
		button:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
		button:Show()
		f.CloseButton = button	   
		
		local button = CreateFrame("Button", f:GetName() .. "_MinimizeButton", f, "UIPanelCloseButton")
		button:SetPoint("TOPRIGHT", f.CloseButton, "TOPLEFT", 4, -5)
		button:SetHeight(18)
		button:SetWidth(18)
		button:SetNormalTexture("Interface\\AddOns\\RPBot\\MinimizeButton-Up.tga")
		button:SetPushedTexture("Interface\\AddOns\\RPBot\\MinimizeButton-Down.tga")
		button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
		--button:SetNormalTexture("Interface/AddOns/RPBot/MinimizeButton-Up")
		--button:SetPushedTexture("Interface/AddOns/RPBot/MinimizeButton-Down")
		button:Show()
		button:SetScript("OnClick", function(self)
			if f.minimize then
				RPB:MaximizeUI()
			else
				RPB:MinimizeUI()
			end
		end
		)
		f.MinimizeButton = button

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
		title:SetText("Roll Window")
		f.title = title

		local sbf = CreateFrame("FRAME",f:GetName() .. "_StatusBarFrame",f);
		sbf:SetPoint("TOP", f, "TOP", 60, -60)
		sbf:SetWidth(124);
		sbf:SetHeight(22);
		sbf:SetBackdrop({
			  bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
			  edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
			  tile=1, tileSize=10, edgeSize=10, 
			  insets={left=3, right=3, top=3, bottom=3}
		});
		local sb = CreateFrame("StatusBar", sbf:GetName().."StatusBar", sbf,"TextStatusBar")
		sb:SetPoint("CENTER", sbf, "CENTER", 0, 0)
		sb:SetOrientation("HORIZONTAL")
		sb:SetMinMaxValues(0, 100)
		sb:SetWidth(120)
		sb:SetHeight(16)
		sb:SetValue(0)
		sb:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
		local fs = sb:CreateFontString("$parentText","ARTWORK","GameFontNormal");
		fs:SetAllPoints();
		fs:SetText("");
		fs:SetPoint("CENTER",sb,"CENTER");
		local fss = sbf:CreateFontString("$parentText2","ARTWORK","GameFontNormal");
		fss:ClearAllPoints();
		fss:SetText("Recieve:");
		fss:SetPoint("RIGHT",sbf,"LEFT");
		local c = GetColor(UnitName("player"))
		sb:SetStatusBarColor(c.r, c.g, c.b, c.a)
		sbf:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
		sbf:SetBackdropColor(0, 0, 0, 1)
		sbf:SetScript("OnUpdate", function(self)
			local sbf = RPB.frames["RollWindow"].sbfin
			local sb = sbf.sb
			local fs = sb.fs

			local found = false
			for k,v in pairs(RPB.ip.incon) do
				if RPB.ip.incon[k] then
					found = true
					break
				end
			end
			if not found then
				if sb:GetValue() ~= 0 then
					sb:SetValue(0)
					fs:SetText("")
				end
				return nil
			end

			local ipin = 0
			for k,v in pairs(RPB.ip.inc) do
				ipin = ipin + v
			end

			local ipintotal = 0
			local desc
			local at = {}
			for k,v in pairs(RPB.ip.incactive) do
				ipintotal = ipintotal + RPB.ip.incl[k][v]
				if not desc then
					desc = RPSConstants.actionText["Bot"][RPB.ip.incactive[k]] or RPB.ip.incactive[k] or ""
				end
			end

			local perc = (ipin/ipintotal)*100
			sb:SetValue(perc)
			fs:SetText(desc.." " .. math.ceil(perc) .."%")
		end)
		sb:SetScript("OnEnter", function(self) 
			local found = false
			for k,v in pairs(RPB.ip.incwho) do
				if RPB.ip.incwho[k] then
					found = true
					break
				end
			end
			if not found then return end
			local found = false
			for k,v in pairs(RPB.ip.incon) do
				if RPB.ip.incon[k] then
					found = true
					break
				end
			end
			if not found then return end
			local color = GetColor(UnitName("player"))
			GameTooltip:SetOwner(RPB.frames["RollWindow"].sbfin, "ANCHOR_CURSOR")
			GameTooltip:ClearLines()
			for k,v in pairs(RPB.ip.incactive) do
				color = GetColor(RPB.ip.incwho[k] or UnitName("player"))
				GameTooltip:AddLine("Recieving from "..( RPB.ip.incwho[k] or "" ), color.r, color.g, color.b)
				GameTooltip:AddLine(RPB.ip.incactive[k])
				GameTooltip:AddLine(RPB.ip.inc[k] .. " of " .. RPB.ip.incl[k][RPB.ip.incactive[k]])
			end
			GameTooltip:Show()
		end)
		sb:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		
		f.sbfin = sbf
		sbf.sb = sb
		sb.fs = fs

		local sbf = CreateFrame("FRAME",f:GetName() .. "_StatusBarFrame",f);
		sbf:SetPoint("TOP", f, "TOP", 60, -30)
		sbf:SetWidth(124);
		sbf:SetHeight(22);
		sbf:SetBackdrop({
			  bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
			  edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
			  tile=1, tileSize=10, edgeSize=10, 
			  insets={left=3, right=3, top=3, bottom=3}
		});
		local sb = CreateFrame("StatusBar", sbf:GetName().."StatusBar", sbf,"TextStatusBar")
		sb:SetPoint("CENTER", sbf, "CENTER", 0, 0)
		sb:SetOrientation("HORIZONTAL")
		sb:SetMinMaxValues(0, 100)
		sb:SetWidth(120)
		sb:SetHeight(16)
		sb:SetValue(0)
		sb:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
		local fs = sb:CreateFontString("$parentText","ARTWORK","GameFontNormal");
		fs:SetAllPoints();
		fs:SetText("");
		fs:SetPoint("CENTER",sb,"CENTER");
		local fss = sbf:CreateFontString("$parentText2","ARTWORK","GameFontNormal");
		fss:ClearAllPoints();
		fss:SetText("Send:");
		fss:SetPoint("RIGHT",sbf,"LEFT");
		local c = GetColor(UnitName("player"))
		sb:SetStatusBarColor(c.r, c.g, c.b, c.a)
		sbf:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
		sbf:SetBackdropColor(0, 0, 0, 1)
		sbf:SetScript("OnUpdate", function(self)
			local sbf = RPB.frames["RollWindow"].sbfout
			local sb = sbf.sb
			local fs = sb.fs

			local found = false
			for k,v in pairs(RPB.ip.outon) do
				if RPB.ip.outon[k] then
					found = true
					break
				end
			end
			if not found then
				if sb:GetValue() ~= 0 then
					sb:SetValue(0)
					fs:SetText("")
				end
				return nil
			end


			local ipout = 0
			for k,v in pairs(RPB.ip.out) do
				ipout = ipout + v
			end

			local ipouttotal = 0
			local desc
			local at = {}
			for k,v in pairs(RPB.ip.outactive) do
				ipouttotal = ipouttotal + RPB.ip.outl[k][v]
				if not desc then
					desc = RPSConstants.actionText["Bot"][RPB.ip.outactive[k]] or RPB.ip.outactive[k] or ""
				end
			end

			local perc = (ipout/ipouttotal)*100
			sb:SetValue(perc)
			fs:SetText(desc.." " .. math.ceil(perc) .."%")
		end)
		sb:SetScript("OnEnter", function(self)
			local found = false
			for k,v in pairs(RPB.ip.outwho) do
				if RPB.ip.outwho[k] then
					found = true
					break
				end
			end
			if not found then return end
			local found = false
			for k,v in pairs(RPB.ip.outon) do
				if RPB.ip.outon[k] then
					found = true
					break
				end
			end
			if not found then return end
			local color = GetColor(UnitName("player"))
			GameTooltip:SetOwner(RPB.frames["RollWindow"].sbfout, "ANCHOR_CURSOR")
			GameTooltip:ClearLines()
			for k,v in pairs(RPB.ip.outactive) do
				color = GetColor(RPB.ip.outwho[k] or UnitName("player"))
				GameTooltip:AddLine("Sending to "..( RPB.ip.outwho[k] or "" ), color.r, color.g, color.b)
				GameTooltip:AddLine(RPB.ip.outactive[k])
				GameTooltip:AddLine(RPB.ip.out[k] .. " of " .. RPB.ip.outl[k][RPB.ip.outactive[k]])
			end
			GameTooltip:Show()
		end)
		sb:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		
		f.sbfout = sbf
		sbf.sb = sb
		sb.fs = fs
	end

    -- Scroll Frame
	do
		f.rollList = {}
	    f.scrollFrame = ScrollingTable:CreateST(RPSConstants.columnDefinitons["RollWindow"], 10, nil, nil, f);
		f.scrollFrame:EnableSelection(true);
		f.scrollFrame.frame:SetParent(f)
		f.scrollFrame.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -240)
		f.scrollFrame:SetData(f.rollList)
		f.scrollFrame:RegisterEvents({
			["OnClick"] = rollWindowScrollFrameOnClick,
			["OnEnter"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...) 
				if row and realrow then
					local selectedby = ""
					if data[realrow].selected then
						local color = GetColor(UnitName("player"))
						--selectedby = string.format("|cff%02x%02x%02x|r", color.r, color.g, color.b)
						selectedby = UnitName("player")
					end
					GameTooltip:SetOwner(rowFrame, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					GameTooltip:AddDoubleLine("Player", data[realrow].cols[crl.player].value)
					GameTooltip:AddDoubleLine("Class", data[realrow].cols[crl.class].value)
					GameTooltip:AddDoubleLine("Rank", data[realrow].cols[crl.rank].value)
					GameTooltip:AddDoubleLine("Type", data[realrow].cols[crl.ty].value)
					GameTooltip:AddDoubleLine("Points", RPB_GetPoints(data[realrow].cols[crl.total].args[1]))
					GameTooltip:AddDoubleLine("Total", RPB_GetTotal(data[realrow].cols[crl.total].args[1]))
					GameTooltip:AddDoubleLine("Roll", data[realrow].cols[crl.roll].value)
					GameTooltip:AddDoubleLine("Loss", RPB_GetPoints(data[realrow].cols[crl.loss].args[1]))
					if data[realrow].selected and data[realrow].highlight then
						GameTooltip:AddDoubleLine("Selected by:", selectedby, nil, nil, nil, data[realrow].highlight.r, data[realrow].highlight.g, data[realrow].highlight.b)
					end
					GameTooltip:Show()
				end
			end,
			["OnLeave"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...) 
				GameTooltip:Hide()
			end,
		});
		for i=1,#f.scrollFrame.cols do
			local colFrameName = f.scrollFrame.head:GetName().."Col"..i;
			local col = getglobal(colFrameName)
			col:SetScript("OnClick", nil)
		end

		-- f.item = {}
		-- for i=1, 1 do 
			-- f.item[i] = self:CreateLootFrame(f, i)
		-- end
		f.lootList = {}
	    f.scrollFrameLoot = ScrollingTable:CreateST(RPSConstants.columnDefinitons["RollWindowLootList"], 10, nil, nil, f);
		f.scrollFrameLoot:EnableSelection(true);
		f.scrollFrameLoot.frame:SetParent(f)
		f.scrollFrameLoot.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
		f.scrollFrameLoot:SetData(f.lootList)
		f.scrollFrameLoot:RegisterEvents({
			["OnClick"] = rollWindowItemScrollFrameOnClick,
			["OnEnter"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...) 
				if data[realrow] then
					if RPB:GetItemID(data[realrow].cols[cll.link].value) then
						GameTooltip:SetOwner(rowFrame, "ANCHOR_CURSOR")
						GameTooltip:ClearLines()
						GameTooltip:SetHyperlink(data[realrow].cols[cll.link].value)
						GameTooltip:Show()
					end
				end
			end,
			["OnLeave"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...) 
				GameTooltip:Hide()
			end,
		});
		for i=1,#f.scrollFrameLoot.cols do
			local colFrameName =  f.scrollFrameLoot.head:GetName().."Col"..i;
			local col = getglobal(colFrameName)
			col:SetScript("OnClick", nil)
		end
		
		-- f.item = {}
		-- for i=1, 1 do 
			-- f.item[i] = self:CreateLootFrame(f, i)
		-- end
		f.nameList = {}
	    f.scrollFrameName = ScrollingTable:CreateST(RPSConstants.columnDefinitons["RollWindowNameList"], 5, nil, nil, f);
		--f.scrollFrameName:EnableSelection(true);
		f.scrollFrameName.frame:SetParent(f)
		f.scrollFrameName.frame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -110)
		f.scrollFrameName:SetData(f.nameList)
		f.scrollFrameName:RegisterEvents({
			--["OnClick"] = rollWindowItemScrollFrameOnClick,
			["OnEnter"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...) 
				if data[realrow] then
					GameTooltip:SetOwner(rowFrame, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					local color = GetColor(data[realrow].cols[con.name].value)
					GameTooltip:AddDoubleLine("Officer", data[realrow].cols[con.name].value, color.r, color.g, color.b, color.r, color.g, color.b)
					GameTooltip:AddDoubleLine("Versions", "")
					GameTooltip:AddDoubleLine("Bot", RPB.rpoSettings.versioninfo[data[realrow].cols[con.name].value])
					GameTooltip:AddDoubleLine("Database", RPB.rpoSettings.dbinfo[data[realrow].cols[con.name].value].database)
					GameTooltip:AddDoubleLine("Lastaction", RPB.rpoSettings.dbinfo[data[realrow].cols[con.name].value].lastaction)
					GameTooltip:AddDoubleLine("Rules", RPB.rpoSettings.dbinfo[data[realrow].cols[con.name].value].rules)
					GameTooltip:Show()
				end
			end,
			["OnLeave"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...) 
				GameTooltip:Hide()
			end,
		});
		getglobal("ScrollTable2HeadCol1"):SetScript("OnClick", nil);

	end
	
	local raidDropDown = {}
	for k,v in pairs(self.db.realm.raid) do
		raidDropDown[k] = k
	end
	
	local rulesDropDown = {}
	for k,v in pairs(RPR.db.realm.rulesSets) do
		rulesDropDown[k] = v.name or k
	end
	
	f.dropdown = {}
	f.label = {}
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(raidDropDown)
	dropdown:SetWidth(120)
	dropdown:SetHeight(20)
	dropdown:SetValue(self.rpoSettings.raid)
	dropdown:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -30)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:UseDatabase(value)
		end
	)
	f.dropdown["Raid"] = dropdown
	local font = f:CreateFontString("Raid","OVERLAY","GameTooltipText")
	font:SetText("Raid:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	f.label["Raid"] = font
	
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(rulesDropDown)
	dropdown:SetWidth(120)
	dropdown:SetHeight(20)
	dropdown:SetValue(self.RPRSettings.rulesSet)
	dropdown:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -60)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPR:SwitchSet(value)
		end
	)
	f.dropdown["RulesSet"] = dropdown
	local font = f:CreateFontString("Rules","OVERLAY","GameTooltipText")
	font:SetText("Rules:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	f.label["RulesSet"] = font

	-- Buttons
		-- Start Bidding
		-- Stop Bidding
		-- Start Timed Bidding
		-- Award Item
		-- Remove Item
		-- Add Item
		-- Clear List
	do
		f.button={}
	  
		local button = CreateFrame("Button", f:GetName() .. "_ButtonStartBidding", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.scrollFrame.frame, "BOTTOMLEFT", 2, -6)
		button:SetText("Start Bidding")
		button:SetScript("OnClick", 
			function(self)
				RPB:StartBidding()
			end
		)
		f.button["StartBidding"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonStartTimedBidding", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["StartBidding"], "TOPRIGHT", 4, 0)
		button:SetText("Timed Bidding")
		button:SetScript("OnClick", 
			function(self)
				RPB:StartTimedBidding()
			end
		)
		f.button["StartTimedBidding"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonStopBidding", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["StartTimedBidding"], "TOPRIGHT", 4, 0)
		button:SetText("Stop Bidding")
		button:SetScript("OnClick", 
			function(self)
				RPB:StopBidding()
			end
		)
		button:Disable()
		f.button["StopBidding"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonAwardItem", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["StopBidding"], "TOPRIGHT", 4, 0)
		button:SetText("Award Item")
		button:SetScript("OnClick", 
			function(self)
				RPB:RollListAward()
			end
		)
		f.button["AwardItem"] = button

		f.editbox = {}
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["AwardItem"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(50)
		
		--editbox:SetScript("OnEnterPressed", function(self) RPB:ItemListAdd() end)
		editbox:SetPoint("TOPLEFT", f.button["AwardItem"], "TOPRIGHT", 10, 6)
		editbox:SetNumeric()
		
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonDisenchantItem", f, "UIPanelButtonTemplate")
		button:SetWidth(40)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.editbox["AwardItem"], "TOPRIGHT", 4, -6)
		button:SetText("DE")
		button:SetScript("OnClick", 
			function(self)
				RPB:RollListDisenchant()
			end
		)
		f.button["DisenchantItem"] = button

		local button = CreateFrame("Button", f:GetName() .. "_ButtonRollClear", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPRIGHT", f.scrollFrame.frame, "BOTTOMRIGHT", -4, -6)
		button:SetText("Clear List")
		button:SetScript("OnClick", 
			function(self)
				RPB:RollListClear()
			end
		)
		f.button["RollClear"] = button
		
		-- Code originally created by Shadowed
		-- Seems generic enough, but giving credit where credit is due.
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["AddItem"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(130)
		
		editbox:SetScript("OnEnterPressed", function(self) if RPB.rpoSettings.master == UnitName("Player") then RPB:ItemListAdd() end end)
		editbox:SetPoint("TOPLEFT", f.scrollFrameLoot.frame, "BOTTOMLEFT", 10, 6)
		
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox, true)

		local button = CreateFrame("Button", f:GetName() .. "_ButtonAddItem", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.editbox["AddItem"], "TOPRIGHT", 4, -6)
		button:SetText("Add Item")
		button:SetScript("OnClick", 
			function(self)
				RPB:ItemListAdd()
			end
		)
		f.button["AddItem"] = button	
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonRemoveItem", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["AddItem"], "TOPRIGHT", 4, 0)
		button:SetText("Remove Item")
		button:SetScript("OnClick", 
			function(self)
				RPB:ItemListRemove()
			end
		)
		f.button["RemoveItem"] = button
			
		local button = CreateFrame("Button", f:GetName() .. "_ButtonClearList", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["RemoveItem"], "TOPRIGHT", 4, 0)
		button:SetText("Clear List")
		button:SetScript("OnClick", 
			function(self)
				RPB:ItemListClear()
			end
		)
		f.button["ClearList"] = button	
	 		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonMaster", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOP", f.scrollFrameName.frame, "BOTTOM", 0, -2)
		button:SetText("Master")
		button:SetScript("OnClick", 
		function(self)
			RPB:SetMaster()
		end
		)
		f.button["Master"] = button
	end
	
	f.state = "Initial"
	f.minimize = false
end

function RPB:UpdateUI()
	local f = self.frames["RollWindow"]
	local Master = f.button["Master"]
	local EAddItem = f.editbox["AddItem"]
	local AddItem = f.button["AddItem"]
	local RemoveItem = f.button["RemoveItem"]
	local ClearList = f.button["ClearList"]
	local StartBidding = f.button["StartBidding"]
	local StartTimedBidding = f.button["StartTimedBidding"]
	local StopBidding = f.button["StopBidding"]
	local AwardItem = f.button["AwardItem"]
	local EAwardItem = f.editbox["AwardItem"]
	local DisenchantItem = f.button["DisenchantItem"]
	local RollClear = f.button["RollClear"]
	
	for k,v in pairs(self.rpoSettings.dbinfo) do
		local found = false
		if #f.nameList > 0 then
			for i=1,#f.nameList do
				if (f.nameList[i].cols[con.name].value == k) then
					found = true
				end
				if (f.nameList[i].cols[con.name].value == self.rpoSettings.master) then
					f.nameList[i].cols[con.name].selected = true
				end
			end
		end
		--self:Print(k)
		if not found then
			f.nameList[#f.nameList+1] = self:BuildRow(
				{
					[con.name]	= 	k,
				},
				conArg
			)
		end
	end
	f.scrollFrameName:SortData()
	f.scrollFrame:Refresh()
	f.scrollFrameLoot:Refresh()
	RPB:AutomationTimeGet()
	
	if f.scrollFrame and f.scrollFrame:GetSelection() then
		local selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols;
		EAwardItem:SetText(RPB_GetLoss(selected[crl.loss].args[1]))
	else
		EAwardItem:SetText("0")
	end
	f.dropdown["Raid"]:SetValue(self.rpoSettings.raid)
	f.dropdown["RulesSet"]:SetValue(self.RPRSettings.rulesSet)
	
	if self.rpoSettings.master == UnitName("player") then
		Master:Disable()
		if f.state == "Initial" then
			StartBidding:Enable()
			StartTimedBidding:Enable()
			StopBidding:Disable()
			EAddItem:Enable()
			AddItem:Enable()
			RemoveItem:Enable()
			ClearList:Enable()
		elseif f.state == "Bidding Started" then
			StartBidding:Disable()
			StartTimedBidding:Disable()
			StopBidding:Enable()
			EAddItem:Disable()
			EAddItem:ClearFocus()
			AddItem:Disable()
			RemoveItem:Disable()
			ClearList:Disable()
		elseif f.state == "Bidding Stopped" then
			StopBidding:Disable()
			EAddItem:Disable()
			EAddItem:ClearFocus()
			AddItem:Disable()
			RemoveItem:Disable()
			ClearList:Disable()
		end
		AwardItem:Enable()
		EAwardItem:Enable()
		DisenchantItem:Enable()
		RollClear:Enable()
		for k,v in pairs(f.dropdown) do
			v:SetDisabled(false)
		end
	else
		Master:Enable()
		EAddItem:Disable()
		EAddItem:ClearFocus()
		AddItem:Disable()
		RemoveItem:Disable()
		ClearList:Disable()
		StartBidding:Disable()
		StartTimedBidding:Disable()
		StopBidding:Disable()
		EAwardItem:Disable()
		EAwardItem:ClearFocus()
		AwardItem:Disable()
		DisenchantItem:Disable()
		RollClear:Disable()
		for k,v in pairs(f.dropdown) do
			v:SetDisabled(true)
		end
	end
end

function RPB:MinimizeUI()
	local f = self.frames["RollWindow"]
	local Master = f.button["Master"]
	local EAddItem = f.editbox["AddItem"]
	local AddItem = f.button["AddItem"]
	local RemoveItem = f.button["RemoveItem"]
	local ClearList = f.button["ClearList"]
	local StartBidding = f.button["StartBidding"]
	local StartTimedBidding = f.button["StartTimedBidding"]
	local StopBidding = f.button["StopBidding"]
	local AwardItem = f.button["AwardItem"]
	local EAwardItem = f.editbox["AwardItem"]
	local DisenchantItem = f.button["DisenchantItem"]
	local RollClear = f.button["RollClear"]
	local DRaid = f.dropdown["Raid"]
	local DRulesSet = f.dropdown["RulesSet"]
	local SName = f.scrollFrameName
	local SRoll = f.scrollFrame
	local SLoot = f.scrollFrameLoot
	local LRaid = f.label["Raid"]
	local LRulesSet = f.label["RulesSet"]
	
	SName:Hide()
	Master:Hide()
	EAddItem:Hide()
	AddItem:Hide()
	RemoveItem:Hide()
	ClearList:Hide()
	StartBidding:Hide()
	StartTimedBidding:Hide()
	StopBidding:Hide()
	AwardItem:Hide()
	EAwardItem:Hide()
	DisenchantItem:Hide()
	RollClear:Hide()
	DRaid.frame:Hide()
	DRulesSet.frame:Hide()
	LRaid:Hide()
	LRulesSet:Hide()
	SRoll.frame:ClearAllPoints()
	SRoll.frame:SetPoint("BOTTOM", f, "BOTTOM", 0, 5)
	SLoot.frame:ClearAllPoints()
	SLoot.frame:SetPoint("BOTTOMLEFT", SRoll.frame, "TOPLEFT", 0, 15)
	SRoll:SetDisplayRows(5, SRoll.rowHeight)
	SLoot:SetDisplayRows(3, SLoot.rowHeight)
	SLoot:Refresh()
	SRoll:Refresh()
	f:SetHeight(180)
	f:SetWidth(590)
	f.minimize = true
end

function RPB:MaximizeUI()
	local f = self.frames["RollWindow"]
	local Master = f.button["Master"]
	local EAddItem = f.editbox["AddItem"]
	local AddItem = f.button["AddItem"]
	local RemoveItem = f.button["RemoveItem"]
	local ClearList = f.button["ClearList"]
	local StartBidding = f.button["StartBidding"]
	local StartTimedBidding = f.button["StartTimedBidding"]
	local StopBidding = f.button["StopBidding"]
	local AwardItem = f.button["AwardItem"]
	local EAwardItem = f.editbox["AwardItem"]
	local DisenchantItem = f.button["DisenchantItem"]
	local RollClear = f.button["RollClear"]
	local DRaid = f.dropdown["Raid"]
	local DRulesSet = f.dropdown["RulesSet"]
	local SName = f.scrollFrameName
	local SRoll = f.scrollFrame
	local SLoot = f.scrollFrameLoot
	local LRaid = f.label["Raid"]
	local LRulesSet = f.label["RulesSet"]
	
	SName:Show()
	Master:Show()
	EAddItem:Show()
	AddItem:Show()
	RemoveItem:Show()
	ClearList:Show()
	StartBidding:Show()
	StartTimedBidding:Show()
	StopBidding:Show()
	AwardItem:Show()
	EAwardItem:Show()
	DisenchantItem:Show()
	RollClear:Show()
	DRaid.frame:Show()
	DRulesSet.frame:Show()
	LRaid:Show()
	LRulesSet:Show()
	SRoll.frame:ClearAllPoints()
	SRoll.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -240)
	SLoot.frame:ClearAllPoints()
	SLoot.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
	SRoll:SetDisplayRows(10, SRoll.rowHeight)
	SLoot:SetDisplayRows(10, SLoot.rowHeight)
	SLoot:Refresh()
	SRoll:Refresh()
	f:SetHeight(440)
	f:SetWidth(620)
	f.minimize = false
end

function RPB:CHAT_MSG_SYSTEM()
	local f = self.frames["RollWindow"]
	if (self.frames and f and f.inProgress and event == "CHAT_MSG_SYSTEM" and string.find(arg1, "rolls") and string.find(arg1, "%(1%-100%)")) then
		_, _, player, roll = string.find(arg1, "(.+) " .. "rolls" .. " (%d+)");
		--self:Print(string.find(arg1, "(.+) " .. "rolls" .. " (%d+)"))
		--self:Print("CHAT_MSG_SYSTEM fired!")
		self:RollListUpdateRoll(player, roll)
	end
end

function rollWindowScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, down)
	local f = RPB.frames["RollWindow"]
	if RPB.rpoSettings.master == UnitName("player") then
		if button == "LeftButton" then
			if data[realrow] then
				local selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection());
				if selected then
					selected.selected = false
					selected.highlight = nil
				end
				f.scrollFrame:SetSelection(realrow)
				selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection());
				selected.selected = true
				selected.highlight = GetColor(UnitName("player"))
				f.scrollFrame:Refresh()
				local sendData = RPB:StripRow(data[realrow])
				--RPB:Print(unpack(sendData))
				f.editbox["AwardItem"]:SetText(RPB_GetLoss(data[realrow].cols[crl.loss].args[1]))
				RPB:Send(cs.rolllistclick, {sendData, GetColor(UnitName("player"))})
				return true
			end
		elseif button == "RightButton" then
			if data[realrow] then
				RPB:RollListRemove(data[realrow].cols[crl.player].value)
				RPB:RollListSort()
				return true
			end
		end
	end
	return true
end

function rollWindowItemScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, down)
	local f = RPB.frames["RollWindow"]
	if RPB.rpoSettings.master == UnitName("player") and not f.inProgress then
		if button == "LeftButton" then
			if data[realrow] then
				local selected = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection());
				if selected then
					selected.selected = false
					selected.highlight = nil
				end
				f.scrollFrameLoot:SetSelection(realrow)
				selected = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection());
				selected.selected = true
				selected.highlight = GetColor(UnitName("player"))
				f.scrollFrameLoot:Refresh()

				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = RPB:GetItemInfo(selected.cols[cll.link].value) 
				RPB:Debug(itemLevel)
				RPR:FindIlvlSet(itemLevel)

				local sendData = RPB:StripRow(data[realrow])
				--RPB:Print(unpack(sendData))
				RPB:Send(cs.itemlistclick, {sendData, GetColor(UnitName("player"))})
				return true
			end
		elseif button == "RightButton" then
			if data[realrow] then
				f.scrollFrameLoot:SetSelection(realrow)
				RPB:ItemListRemove(data[realrow].cols[cll.link].value)
				f.scrollFrameLoot:SortData()
				return true
			end
		end
	end
	return true
end

function rollWindowScrollFrameColor(roll)
	local f = RPB.frames["RollWindow"]
	local rules = RPR.rules[string.lower(roll.cols[crl.ty].value)]
	-- Make this loaclizable, for generic changes.
	local diff = tonumber(rules.diff) or tonumber(RPB.rpbSettings.diff)
	local low = 0
	local rollList = f.rollList
	for i=1,#rollList do
		if (RPB_GetTotal(rollList[i].cols[crl.total].args[1]) < low) then
			low = RPB_GetTotal(rollList[i].cols[crl.total].args[1])
		end
	end
	local high = low
	for i=1,#rollList do
		if (RPB_GetTotal(rollList[i].cols[crl.total].args[1]) > high) then
			high = RPB_GetTotal(rollList[i].cols[crl.total].args[1])
		end
	end
	local color
	if high - RPB_GetTotal(roll.cols[crl.total].args[1]) > diff then
		color = {
		["r"] = 1.0,
		["g"] = 0.0,
		["b"] = 0.0,
		["a"] = 1.0
		}
	else
		--RPB:Print(high, roll.cols[crl.total].value, high - roll.cols[crl.total].value, diff)
		local ratio
		if diff == 0 then
			ratio = 1
		else
			ratio = ((high - RPB_GetTotal(roll.cols[crl.total].args[1])) / (diff * 1.000))
		end
		--RPB:Print(ratio)
		local r,g,b = ColorGradient(ratio, 0,1,0, 1,0.5,0)
		color = {
		["r"] = r,
		["g"] = g,
		["b"] = 0.0,
		["a"] = 1.0
		}
	end
	return color or {
		["r"] = 1.0,
		["g"] = 0.0,
		["b"] = 0.0,
		["a"] = 1.0
		}
end

function RPB:RollListAdd(player, cmd, recieved)
	local f = self.frames["RollWindow"]
	--local pinfo = self:GetInfo(player)
	if (not self:GetPlayer(player)) then
		self:CreatePlayer(player)
	end
	if not self:RosterByName(player:gsub("^%l", string.upper)) then
		return nil
	end
	local pinfo = self:GuildRosterByName(player) or self:RosterByName(player:gsub("^%l", string.upper))
	local class = self:GetPlayer(player, "class")
	local selected = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection());
	local item = selected.cols	
	local classes = self:GetClasses(item[cll.link].value)
	local cstring = ""
	local found = false
	for i, c in pairs(classes) do
		if cstring == "" then
			cstring = c
		else
			cstring = cstring..", "..c
		end
		if string.lower(class) == string.lower(c) then
			found = true
			break
		end
	end
	if not found and (table.getn(classes)>0) then
		return "noclass", cstring
	end

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = RPB:GetItemInfo(item[cll.link].value)
	if (RPSConstants.filterList[itemSubType]) then
		if not RPSConstants.filterClassList[string.upper(class)][itemSubType] then
			return "noarmor", itemSubType
		end
	end
	
	--self:Print("RPB:RollListAdd", player, cmd, recieved)
	local class, rank, ty, total, loss
	local rules = RPR.rules[string.lower(cmd)]
	local divisor = rules.divisor or 2
	ty = rules.name
	
	p = self:GetPlayer(player, "fullname")
	class = self:GetPlayer(player, "class")
	rank = self:GetPlayer(player, "rank")

	local rollList = self.frames["RollWindow"].rollList
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			if (string.lower(rollList[i].cols[crl.ty].value) ~= string.lower(ty)) then
				if rules.nolist then
					self:RollListRemove(player)
					return "nolist"
				else
					local oldty = rollList[i].cols[crl.ty].value
					self:RollListUpdateType(player, ty)
					return "newtype", oldty, ty
				end
			end
			return "alreadybidding", rollList[i].cols[crl.ty].value
		end
	end
	
	if not recieved then
		self:Send(cs.rolllistadd, {player, cmd, true})
	end
	
	if rules.nolist then
		return "nolist"
	end

	pdata = self:GetPlayerHistory(player)
	total = self:CalculateMaxPoints(pdata.points, cmd)
	
	--loss = self:CalculateLoss(total, cmd)
	rollList[#rollList+1] = self:BuildRow(
		{
			[crl.player]	= 	player,
			[crl.class]		=	class or "",
			[crl.rank]		=	rank or "",
			[crl.ty]		=	ty,
			[crl.points]	= 	{RPB_GetPoints, {player}},
			[crl.roll]		=	0,
			[crl.total]		=	{RPB_GetTotal, {player}},
			[crl.loss]		=	{RPB_GetLoss, {player}},
		},
		crlArg, rollWindowScrollFrameColor
	)
	self:RollListSort()
	return "added", total
end

function RPB:RollListRemove(player, recieved)
	local f = self.frames["RollWindow"]
	local rollList = f.rollList
	if not recieved then
		self:Send(cs.rolllistremove, {player, true})
	end			
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			if f.scrollFrame:GetSelection() == i then
				f.scrollFrame:ClearSelection()
			end
			tremove(rollList,i)
			break
		end
	end
	self:RollListSort()
end

function RPB:RollListClear(recieved)
	local f = self.frames["RollWindow"]
	if not recieved then
		self:Send(cs.rolllistclear, {true})
	end
	f.rollList = {}
	f.scrollFrame:ClearSelection()
	f.scrollFrame:SetData(f.rollList)
	self:RollListSort()
	if f.timer then
		self:CancelTimer(f.timer)
		f.timer = nil
		f.tm = 0
	end
	if f.stimer then
		self:CancelTimer(f.stimer)
		f.stimer = nil
		f.tm = 0
	end
	f.inProgress = false
	f.state = "Initial"
	self:UpdateUI()
end

function RPB:RollListUpdate(index, player)
	local f = self.frames["RollWindow"]
	local rollList = f.rollList
	local rules = RPR.rules[string.lower(cmd)]
	local pdata = self:GetPlayerHistory(player)
	--rollList[index].cols[crl.points].value = pdata.points
	--rollList[index].cols[crl.total].value = self:CalculateMaxPoints(pdata.points, rollList[index].cols[crl.ty].value)
	--rollList[index].cols[crl.loss].value = self:CalculateLoss(pdata.points, rollList[index].cols[crl.ty].value)
end

function RPB:RollListUpdateType(player, ty, recieved)
	local f = self.frames["RollWindow"]
	local found = false
	local rollList = f.rollList
	if not recieved then
		self:Send(cs.rolllistupdatetype, {player, ty, true})
	end

	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			if ty then
				rollList[i].cols[crl.ty].value = ty
			end
			--self:RollListUpdate(i, string.lower(player))
			found = true
			break
		end
	end
	if (found) then
		self:RollListSort()
	end
end

function RPB:RollListUpdateRoll(player, roll, recieved)
	local f = self.frames["RollWindow"]
	local found = false
	local rollList = f.rollList
	if not recieved then
		--self:Print("RollListUpdateRoll recieved fired!", player)
		self:Send(cs.rolllistupdateroll, {player, roll, true})
	end
	--self:Print("RollListUpdateRoll fired!")

	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			found = true
			if (tonumber(rollList[i].cols[crl.roll].value) > 0 and roll and roll ~= tonumber(rollList[i].cols[crl.roll].value)) then
				if self.rpoSettings.master == UnitName("player") and not recieved then
					self:Broadcast(player .. "  Previous Roll: " .. rollList[i].cols[crl.roll].value .. "   New Roll: " .. roll)
				end
				break
			end
			--self:RollListUpdate(i, string.lower(player))
			local total = RPB_GetTotal(rollList[i].cols[crl.total].args[1])
			if roll then
				rollList[i].cols[crl.roll].value = roll
				--rollList[i].cols[crl.total].value = total + roll
			else
				--rollList[i].cols[crl.total].value = total + rollList[i].cols[crl.roll].value
			end
			break
		end
	end
	if (found) then
		self:RollListSort()
	else
		if self.rpoSettings.master == UnitName("player") and not recieved then
			self:Broadcast(player.." is not bidding, roll ignored.")
		end
	end
end

function RPB:RollListSort()
	local f = self.frames["RollWindow"]
	-- Call the sort function for total?
	if f and f.scrollFrame then
		if f.scrollFrame and f.scrollFrame:GetSelection() then
			local selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols;
			f.editbox["AwardItem"]:SetText(RPB_GetLoss(selected[crl.loss].args[1]))
		end
		--f.scrollFrame.cols[crl.roll] = "asc"
		local st = f.scrollFrame
		local cols = st.cols
		for i, col in ipairs(cols) do 
			if i ~= crl.total then -- clear out all other sort marks
				cols[i].sort = nil;
			end
		end
		cols[crl.total].sort = "asc";
		f.scrollFrame:SortData();
		f.scrollFrame:Refresh()
	end
end

function RPB:RollListAward(recieved)
	local f = self.frames["RollWindow"]
	if not f.scrollFrameLoot:GetSelection() then return end
	if not f.scrollFrame:GetSelection() then return end
	if not recieved then
		self:Send(cs.rolllistaward, { true })
	end
	f.inProgress = false
	if recieved then
		return
	end

	local item, winner
	
	item = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection()).cols
	winner = f.scrollFrame:GetRow(f.scrollFrame:GetSelection()).cols
	local class, rank, ty, total, loss, roll, ptotal, player
	local editbox = f.editbox["AwardItem"]
	
	player = winner[crl.player].value
	class = winner[crl.class].value
	rank = winner[crl.rank].value
	ty = winner[crl.ty].value
	total = RPB_GetTotal(winner[crl.total].args[1])
	--loss = winner[crl.loss].value
	loss = tonumber(editbox:GetText()) or 0
	if loss > 0 then
		loss = -(loss)
	end
	roll = winner[crl.roll].value
	ptotal = RPB_GetMaxPoints(player)
	f.state = "Initial"
	self:UpdateUI()
	if self.rpoSettings.master == UnitName("player") then
		local dt = time()

		--self:Print(self.rpoSettings.raid, dt, player, -(loss), 'I', item[cll.item].value, item[cll.link].value, false, true)
		self:Broadcast(	player .. " wins " .. item[cll.link].value .. " via " .. ty .. " for cost of ".. (loss) .." with a total of " .. total .. " (" .. ptotal .. " points + " .. roll .. " roll).")
		self:PointsAdd(self.rpoSettings.raid, dt, dt, player, (loss), 'I', item[cll.item].value, item[cll.link].value, true, true)
		self:ItemListRemove(item[cll.link].value)
		self:RollListUpdateRoll(player)
		f.scrollFrame:ClearSelection()
	end
	if f.timer then
		self:CancelTimer(f.timer)
		f.timer = nil
	end
end

function RPB:RollListDisenchant(recieved)
	local f = self.frames["RollWindow"]
	if not f.scrollFrameLoot:GetSelection() then return end
	if not recieved then
		self:Send(cs.rolllistdisenchant, { true })
	end
	f.inProgress = false
	if recieved then
		return
	end
	
	local item
	item = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection()).cols
	f.state = "Initial"
	self:UpdateUI()
	if self.rpoSettings.master == UnitName("player") then
		--local dt = time()

		--self:Print(self.rpoSettings.raid, dt, player, -(loss), 'I', item[cll.item].value, item[cll.link].value, false, true)
		self:Broadcast(	"Disenchant wins " .. item[cll.link].value)
		self:ItemListRemove(item[cll.link].value)
	end
	if f.timer then
		self:CancelTimer(f.timer)
		f.timer = nil
	end
end

function RPB:StartBidding(recieved)
	local f = self.frames["RollWindow"]
	if not f.scrollFrameLoot:GetSelection() then return end
	local item
	if f.scrollFrameLoot:GetSelection() then
		item = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection()).cols
		if not recieved then
			self:Send(cs.startbidding, { true })
		end
		f.inProgress = true
		f.state = "Bidding Started"
		self:UpdateUI()
		if self.rpoSettings.master == UnitName("player") then
			self:Message("RAID_WARNING", "*** Declare on " .. item[cll.link].value .. ". ***")
			self:Broadcast("*** Declare on " .. item[cll.link].value .. ". ***")
			f.tm = (tonumber(self.rpbSettings.lastcall) or 5) + 1
		end
	end
end

function RPB:StartTimedBidding(recieved)
	local f = self.frames["RollWindow"]
	if not f.scrollFrameLoot:GetSelection() then return end
	local item = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection()).cols
	if not recieved then
		self:Send(cs.starttimedbidding, { true })
	end
	f.inProgress = true
	f.state = "Bidding Started"
	if self.rpoSettings.master == UnitName("player") then
		self:Message("RAID_WARNING", "*** Declare on " .. item[cll.link].value .. ". ***")
		self:Broadcast("*** Declare on " .. item[cll.link].value .. ".  Closing in " .. (tonumber(RPB.rpbSettings.bidtime) or 30) .. " seconds. ***")
		f.tm = (tonumber(self.rpbSettings.bidtime) or 30) - 1
		f.timer = self:ScheduleRepeatingTimer("ContinueBidding", 1)
		self:UpdateUI()
	end
end

function RPB:ContinueBidding()
	local f = self.frames["RollWindow"]
	if f.inProgress then
		f.tm = f.tm - 1
		local timeleft = f.tm
		local item = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection()).cols
		local lastcall = tonumber(self.rpbSettings.lastcalltonumber) or 5
		
		if (timeleft > lastcall and timeleft % (lastcall*2) == 0) then
			self:Broadcast("Bidding on " .. item[cll.link].value .. ".  Closing in " .. timeleft .. " seconds.")
		elseif (timeleft <= lastcall+1) then
			self:CancelTimer(f.timer)
			f.timer = nil
			RPB:StopBidding()
		end
		
		--Every 10 seconds
			-- call 'Bidding on [item].  Closing in XX seconds.'
		--At halfway or just beyond halfway
			-- If bonus/upgrade bids, call 'Bidding on [item]. Closing in XX seconds.'
			-- If offspec or nothing, call 'Bidding on [item]. Open to offspecs. Closing in XX seconds.'
	end
end

function RPB:StopBidding(recieved)
	local f = self.frames["RollWindow"]
	if f.inProgress then
		local lastcall = tonumber(self.rpbSettings.lastcall) or 5
		if f.timer then
			self:CancelTimer(f.timer)
			f.timer = nil
			f.tm = lastcall
		end
		f.stimer = self:ScheduleTimer("StopBidding", 1)
		f.tm = f.tm - 1
		local timeleft = f.tm
		local item = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection()).cols
		local lastcall = tonumber(self.rpbSettings.lastcall) or 5
		
		if (timeleft == lastcall) then
			self:Broadcast("Last call on " .. item[cll.link].value .. ".  Closing in "..lastcall.." seconds.")
		elseif (timeleft < lastcall) then
			self:Broadcast(timeleft)
		end
		if (timeleft == 1) then
			self:CancelTimer(f.stimer)
			f.stimer = nil
		end
		f.state = "Bidding Stopped"
		self:UpdateUI()
		-- At the 10 second mark
			-- If bonus/upgrade bids, call 'Bidding on [item]. Closing in 10 seconds.'
			-- If offspec or nothing, call 'Bidding on [item]. Open to offspecs. Closing in 10 seconds.'
		-- At 5 seconds and below
			-- If bonus/upgrade bids, call 'Last call on [item]. Closing in 5 seconds.'
			-- If offspec or nothing, call 'Any offspecs on [item]? Closing in 5 seconds.'
	end
end

function RPB:ItemListAdd(link, item, count, quality, recieved)
	local f = self.frames["RollWindow"]
	--if quality and quality < 3 then return end
	if not link then
		local editbox = f.editbox["AddItem"]
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = RPB:GetItemInfo(editbox:GetText())
		--RPB:Print(GetItemInfo(editbox:GetText()))
		link = editbox:GetText()
		item = self:GetItemID(link)
		--_, _, item  = string.find(link, "item:(%d+)");
		if not item then
			item = 0
		end
		count = itemCount
		quality = itemRarity
		editbox:SetText("")
		editbox:ClearFocus()
	end
	if link == "" then return false end
	if not count then count = 0 end
	if not quality then quality = 0 end
	--self:Print(link, item, count, quality, true)
	if not recieved then
		self:Send(cs.itemlistadd, {link, item, count, quality, true})
	end
	local lootList = f.lootList
	lootList[#lootList+1] = self:BuildRow(
		{
			[cll.link]		= 	link,
			[cll.item]		=	item,
			[cll.count]		=	count,
			[cll.quality]	=	quality,
		},
		cllArg
	)
	f.scrollFrameLoot:SortData()
end

function RPB:ItemListRemove(link, recieved)
	local f = self.frames["RollWindow"]
	if not link then
		link = f.scrollFrameLoot:GetRow(f.scrollFrameLoot:GetSelection()).cols[cll.link].value
	end
	if not recieved then
		self:Send(cs.itemlistremove, {link, true})
	end
	local lootList = f.lootList
	for i=1,#lootList do
		if (lootList[i] and lootList[i].cols[cll.link].value == link) then
			if f.scrollFrameLoot:GetSelection() == i then
				f.scrollFrameLoot:ClearSelection()
			end
			tremove(lootList,i)
			break
		end
	end
	f.scrollFrameLoot:SortData()
end

function RPB:ItemListClear(recieved)
	local f = self.frames["RollWindow"]
	if not f.inProgress then
		if not recieved then
			self:Send(cs.itemlistclear, {true})
		end
		f.lootList = {}
		f.scrollFrameLoot:SetData(f.lootList)
		f.scrollFrameLoot:SortData()
		f.scrollFrameLoot:ClearSelection()
	end
end

RPB.syncCommands[cs.itemlistget] = function(self, msg, sender)
	local f = self.frames["RollWindow"]
	if (self.rpoSettings.master == UnitName("player") and self.rpoSettings.master ~= sender) or (self.rpoSettings.master == sender and sender ~= UnitName("player")) then
		local sendTable = self:StripTable(f.lootList or {})
		local selectedTable = {}
		for i=1,#f.lootList do
			if f.lootList[i].selected then
				selectedTable[#selectedTable+1] =
					{
						sel = self:StripRow(f.lootList[i]),
						highlight = f.lootList[i].highlight,
					}
			end
		end
		self:Send(cs.itemlistset, {sendTable, selectedTable}, sender)
	end
end

RPB.syncCommands[cs.itemlistset] = function(self, msg, sender)
	local f = self.frames["RollWindow"]
	local temp = self:BuildTable(msg[1], cllArg)
	f.lootList = temp
	local frame = f.scrollFrameLoot
	for i=1,#temp do
		if msg[2] then
			for j=1,#msg[2] do
				--self:Print(msg[2][j][sel][cll.link], temp[i].cols[cll.link].value)
				if msg[2][j]["sel"][cll.link] and string.lower(temp[i].cols[cll.link].value) == string.lower(msg[2][j]["sel"][cll.link] ) then
					temp[i].selected = true
					temp[i].highlight = msg[2][j]["highlight"]
					frame:SetSelection(i)
				--elseif not (list[i].selected and list[i].highlight ~= RPB:GetColor(UnitName("player"))) then
				else
					temp[i].selected = false
					temp[i].highlight = nil
				end
			end
		end
	end
	f.scrollFrameLoot:SetData(f.lootList)
end
	
RPB.syncCommands[cs.rolllistget] = function(self, msg, sender)
	local f = self.frames["RollWindow"]
	if (self.rpoSettings.master == UnitName("player") and self.rpoSettings.master ~= sender) or (self.rpoSettings.master == sender and sender ~= UnitName("player")) then
		local sendTable = self:StripTable(f.rollList or {})
		local selectedTable = {}
		for i=1,#f.rollList do
			if f.rollList[i].selected then
				selectedTable[#selectedTable+1] =
					{
						sel = self:StripRow(f.rollList[i]),
						highlight = f.rollList[i].highlight,
					}
			end
		end
		self:Send(cs.rolllistset, {sendTable, selectedTable, f.state}, sender)
	end
end

RPB.syncCommands[cs.rolllistset] = function(self, msg, sender)
	local f = self.frames["RollWindow"]
	
	for i=1,#msg[1] do
		msg[1][i][crl.points]	= 	{RPB_GetPoints, {msg[1][i][crl.player]}}
		msg[1][i][crl.total]	=	{RPB_GetTotal, 	{msg[1][i][crl.player]}}
		msg[1][i][crl.loss]		=	{RPB_GetLoss, 	{msg[1][i][crl.player]}}
	end
	local temp = self:BuildTable(msg[1], crlArg, rollWindowScrollFrameColor)
	f.rollList = temp
	local frame = f.scrollFrame
	for i=1,#temp do
		if msg[2] then
			for j=1,#msg[2] do
				if msg[2][j]["sel"][crl.player] and string.lower(temp[i].cols[crl.player].value) == string.lower(msg[2][j]["sel"][crl.player] ) then
					temp[i].selected = true
					temp[i].highlight = msg[2][j]["highlight"]
					frame:SetSelection(i)
				--elseif not (list[i].selected and list[i].highlight ~= RPB:GetColor(UnitName("player"))) then
				else
					temp[i].selected = false
					temp[i].highlight = nil
				end
			end
		end
	end
	f.state = msg[3]
	f.scrollFrame:SetData(f.rollList)
	self:RollListSort()
end

RPB.syncCommands[cs.rolllistclick] = function(self, msg, sender)
	local f = self.frames["RollWindow"]
	if sender == UnitName("player") then return end
	local list = f.rollList
	local frame = f.scrollFrame
	if frame:GetSelection() then
		local selected = frame:GetRow(frame:GetSelection());
		selected.selected = false
		selected.highlight = nil
		frame:ClearSelection()
	end
	for i=1,#list do
		if (list[i].cols[crl.player].value == msg[1][crl.player]) then
			list[i].selected = true
			list[i].highlight = msg[2]
			f.editbox["AwardItem"]:SetText(RPB_GetLoss(list[i].cols[crl.loss].args[1]))
			frame:SetSelection(i)
			--elseif not (list[i].selected and list[i].highlight ~= RPB:GetColor(UnitName("player"))) then
		else
			list[i].selected = false
			list[i].highlight = nil
		end
	end
	self:RollListSort()
end

RPB.syncCommands[cs.itemlistclick] = function(self, msg, sender)
	local f = self.frames["RollWindow"]
	if sender == UnitName("player") then return end
	local list = f.lootList
	local frame = f.scrollFrameLoot
	--self:Print(msg, unpack(msg or {}))
	if frame:GetSelection() then
		local selected = frame:GetRow(frame:GetSelection());
		selected.selected = false
		selected.highlight = nil
		frame:ClearSelection()
	end
	for i=1,#list do
		if (list[i].cols[cll.item].value == msg[1][cll.item]) then
			list[i].selected = true
			list[i].highlight = msg[2]
			frame:SetSelection(i)
			--local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = RPB:GetItemInfo(list[i].cols[cll.item].value) 
			--RPR:FindIlvlSet(itemLevel)
			--elseif not (list[i].selected and list[i].highlight ~= RPB:GetColor(UnitName("player"))) then
		else
			list[i].selected = false
			list[i].highlight = nil
		end
	end
	f.scrollFrameLoot:SortData()
	f.scrollFrameLoot:Refresh()
end
