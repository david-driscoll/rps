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
	f:SetFrameStrata("MEDIUM")
	f:SetHeight(440)
	f:SetWidth(620)
	f:SetPoint("CENTER",0,0)
	f:Hide()

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
		title:SetText("Raid Points - Roll Window")
		f.title = title
	end

    -- Scroll Frame
	do
		f.rollList = {}
	    f.scrollFrame = ScrollingTable:CreateST(RPSConstants.columnDefinitons["RollWindow"], 10, nil, nil, f, true);
		f.scrollFrame.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -240)
		f.scrollFrame:SetData(f.rollList)
		f.scrollFrame:RegisterEvents({
			["OnClick"] = rollWindowScrollFrameOnClick,
			["OnEnter"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, ...) 
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
					GameTooltip:AddDoubleLine("Total", data[realrow].cols[crl.total].value)
					GameTooltip:AddDoubleLine("Roll", data[realrow].cols[crl.roll].value)
					GameTooltip:AddDoubleLine("Total", data[realrow].cols[crl.loss].value)
					if data[realrow].selected and data[realrow].highlight then
						GameTooltip:AddDoubleLine("Selected by:", selectedby, nil, nil, nil, data[realrow].highlight.r, data[realrow].highlight.g, data[realrow].highlight.b)
					end
					GameTooltip:Show()
				end
			end,
			["OnLeave"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, ...) 
				GameTooltip:Hide()
			end,
		});

		-- f.item = {}
		-- for i=1, 1 do 
			-- f.item[i] = self:CreateLootFrame(f, i)
		-- end
		f.lootList = {}
	    f.scrollFrameLoot = ScrollingTable:CreateST(RPSConstants.columnDefinitons["RollWindowLootList"], 10, nil, nil, f, true);
		f.scrollFrameLoot.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
		f.scrollFrameLoot:SetData(f.lootList)
		f.scrollFrameLoot:RegisterEvents({
			["OnClick"] = rollWindowItemScrollFrameOnClick,
			["OnEnter"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, ...) 
				if data[realrow] then
					GameTooltip:SetOwner(rowFrame, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					GameTooltip:SetHyperlink(data[realrow].cols[cll.link].value)
					GameTooltip:Show()
				end
			end,
			["OnLeave"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, ...) 
				GameTooltip:Hide()
			end,
		});
		getglobal("ScrollTable2HeadCol1"):SetScript("OnClick", nil);
		
		-- f.item = {}
		-- for i=1, 1 do 
			-- f.item[i] = self:CreateLootFrame(f, i)
		-- end
		f.nameList = {}
	    f.scrollFrameName = ScrollingTable:CreateST(RPSConstants.columnDefinitons["RollWindowNameList"], 9, nil, nil, f, true);
		f.scrollFrameName.frame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -45)
		f.scrollFrameName:SetData(f.nameList)
		f.scrollFrameName:RegisterEvents({
			--["OnClick"] = rollWindowItemScrollFrameOnClick,
			["OnEnter"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, ...) 
				if data[realrow] then
					GameTooltip:SetOwner(rowFrame, "ANCHOR_CURSOR")
					GameTooltip:ClearLines()
					local color = GetColor(data[realrow].cols[con.name].value)
					GameTooltip:AddDoubleLine("Officer", data[realrow].cols[con.name].value, color.r, color.g, color.b, color.r, color.g, color.b)
					GameTooltip:AddDoubleLine("Versions", "")
					GameTooltip:AddDoubleLine("Bot", RPB.rpoSettings.versioninfo[data[realrow].cols[con.name].value])
					GameTooltip:AddDoubleLine("Database", RPB.rpoSettings.dbinfo[data[realrow].cols[con.name].value].database)
					GameTooltip:AddDoubleLine("Lastaction", RPB.rpoSettings.dbinfo[data[realrow].cols[con.name].value].lastaction)
					GameTooltip:AddDoubleLine("Feature", RPB.rpoSettings.dbinfo[data[realrow].cols[con.name].value].feature)
					GameTooltip:Show()
				end
			end,
			["OnLeave"] = 
			function(rowFrame, cellFrame, data, cols, row, realrow, column, ...) 
				GameTooltip:Hide()
			end,
		});
		getglobal("ScrollTable2HeadCol1"):SetScript("OnClick", nil);

end
	
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
		button:SetPoint("TOP", f.scrollFrameName.frame, "BOTTOM", 0, -10)
		button:SetText("Master")
		button:SetScript("OnClick", 
		function(self)
			RPB:SetMaster()
		end
		)
		f.button["Master"] = button
	end

	-- Create Loot Frames
	-- do
		-- f.item = {}
		-- for i=1, 1 do 
			-- f.item[i] = self:CreateLootFrame(f, i)
		-- end
		-- f.lootList = {}
	    -- f.scrollFrameLoot = ScrollingTable:CreateST(RPB.columnDefinitons["RollWindowLootList"], 10, nil, nil, f);
		-- f.scrollFrameLoot.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
		-- f.scrollFrame:SetData(f.lootList)
		-- f.scrollFrame:RegisterEvents({
			-- ["OnClick"] = rollWindowItemScrollFrameOnClick,
		-- });
		
	-- end
	
	f.state = "Initial"
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
	
	if self.rpoSettings.master == UnitName("player") then
		Master:Disable()
		if f.state == "Initial" then
			StartBidding:Enable()
			StartTimedBidding:Enable()
			StopBidding:Disable()
			AddItem:Enable()
			RemoveItem:Enable()
			ClearList:Enable()
		elseif f.state == "Bidding Started" then
			StartBidding:Disable()
			StartTimedBidding:Disable()
			StopBidding:Enable()
			AddItem:Disable()
			RemoveItem:Disable()
			ClearList:Disable()
		elseif f.state == "Bidding Stopped" then
			StopBidding:Disable()
			AddItem:Disable()
			RemoveItem:Disable()
			ClearList:Disable()
		end
		AwardItem:Enable()
		--EAwardItem:Enable()
		DisenchantItem:Enable()
		RollClear:Enable()
	else
		Master:Enable()
		--EAddItem:Disable()
		AddItem:Disable()
		RemoveItem:Disable()
		ClearList:Disable()
		StartBidding:Disable()
		StartTimedBidding:Disable()
		StopBidding:Disable()
		AwardItem:Disable()
		--EAwardItem:Disable()
		DisenchantItem:Disable()
		RollClear:Disable()
	end
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

function rollWindowScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	local f = RPB.frames["RollWindow"]
	if RPB.rpoSettings.master == UnitName("player") then
		if button == "LeftButton" then
			if data[realrow] then
				if f.scrollFrame.selected then
					f.scrollFrame.selected.selected = false
					f.scrollFrame.selected.highlight = nil
				end
				f.scrollFrame.selected = data[realrow]
				f.scrollFrame.selected.selected = true
				f.scrollFrame.selected.highlight = GetColor(UnitName("player"))

				f.scrollFrame:Refresh()
				local sendData = RPB:StripRow(data[realrow])
				--RPB:Print(unpack(sendData))
				f.editbox["AwardItem"]:SetText(data[realrow].cols[crl.loss].value)
				RPB:Send(cs.rolllistclick, {sendData, GetColor(UnitName("player"))})
			end
		elseif button == "RightButton" then
			if data[realrow] then
				RPB:RollListRemove(data[realrow].cols[crl.player].value)
				f.scrollFrame:SortData()
			end
		end
	end
end

function rollWindowItemScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	local f = RPB.frames["RollWindow"]
	if RPB.rpoSettings.master == UnitName("player") and not f.inProgress then
		if button == "LeftButton" then
			if data[realrow] then
				if f.scrollFrameLoot.selected then
					f.scrollFrameLoot.selected.selected = false
					f.scrollFrameLoot.selected.highlight = nil
				end
				f.scrollFrameLoot.selected = data[realrow]
				f.scrollFrameLoot.selected.selected = true
				f.scrollFrameLoot.selected.highlight = GetColor(UnitName("player"))
				f.scrollFrameLoot:Refresh()
				local sendData = RPB:StripRow(data[realrow])
				--RPB:Print(unpack(sendData))
				RPB:Send(cs.itemlistclick, {sendData, GetColor(UnitName("player"))})
			end
		elseif button == "RightButton" then
			if data[realrow] then
				--f.scrollFrameLoot.selected = data[realrow]
				RPB:ItemListRemove(data[realrow].cols[cll.link].value)
				f.scrollFrameLoot:SortData()
			end
		end
	end
end

function rollWindowScrollFrameColor(roll)
	local f = RPB.frames["RollWindow"]
	local feature = RPB.feature[string.lower(roll.cols[crl.ty].value)]
	-- Make this loaclizable, for generic changes.
	local diff = tonumber(feature.diff) or tonumber(RPB.rpbSettings.diff)
	local low = 0
	local rollList = f.rollList
	for i=1,#rollList do
		if (rollList[i].cols[crl.total].value < low) then
			low = rollList[i].cols[crl.total].value
		end
	end
	local high = low
	for i=1,#rollList do
		if (rollList[i].cols[crl.total].value > high) then
			high = rollList[i].cols[crl.total].value
		end
	end
	local color
	if high - roll.cols[crl.total].value > diff then
		color = {
		["r"] = 1.0,
		["g"] = 0.0,
		["b"] = 0.0,
		["a"] = 1.0
		}
	else
		--RPB:Print(high, roll.cols[crl.total].value, high - roll.cols[crl.total].value, diff)
		local ratio = ((high - roll.cols[crl.total].value) / (diff * 1.000))
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
	--local pinfo = self:GetInfo(player)
	if (not self:GetPlayer(player)) then
		self:CreatePlayer(player)
	end
	if not self:RosterByName(player:gsub("^%l", string.upper)) then
		return nil
	end
	local pinfo = self:GuildRosterByName(player) or self:RosterByName(player:gsub("^%l", string.upper))
	
	--self:Print("RPB:RollListAdd", player, cmd, recieved)
	local class, rank, ty, total, loss
	local feature = self.feature[string.lower(cmd)]
	local divisor = feature.divisor or 2
	
	if pinfo then
		class = pinfo["class"] or ""
		rank = pinfo["rank"] or ""
	end	
	
	pdata = self:GetPlayerHistory(player)
	total = pdata.points
	local maxpoints = self.feature[string.lower(feature.name)].maxpoints or tonumber(self.rpbSettings.maxpoints) or 0
	if maxpoints > 0 and total > maxpoints then
		total = maxpoints
	end
	player = pinfo.name
	
	ty = feature.name
	local rollList = self.frames["RollWindow"].rollList
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			if (string.lower(rollList[i].cols[crl.ty].value) ~= string.lower(ty)) then
				if feature.nolist then
					self:RollListRemove(player)
				else
					self:RollListUpdateType(player, ty)
					return true
				end
			end
			return false
		end
	end
	
	if not recieved then
		self:Send(cs.rolllistadd, {player, cmd, true})
	end
	
	if feature.nolist then
		return false
	end

	loss = self:CalculateLoss(total, cmd)
	rollList[#rollList+1] = self:BuildRow(
		{
			[crl.player]	= 	player,
			[crl.class]		=	class or "",
			[crl.rank]		=	rank or "",
			[crl.ty]		=	ty,
			[crl.points]	= 	pdata.points,
			[crl.roll]		=	0,
			[crl.total]		=	total,
			[crl.loss]		=	loss,
		},
		crlArg, rollWindowScrollFrameColor
	)
	self:RollListSort()
	return true
end

function RPB:RollListRemove(player, recieved)
	local f = self.frames["RollWindow"]
	local rollList = f.rollList
	if not recieved then
		self:Send(cs.rolllistremove, {player, true})
	end			
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			if f.scrollFrame.selected == rollList[i] then
				f.scrollFrame.selected = nil
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
	f.scrollFrame:SetData(f.rollList)
	f.scrollFrame:SortData()
	f.scrollFrame.selected = nil
	self:RollListSort()
	f.inProgress = false
	f.state = "Initial"
	self:UpdateUI()
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
			local total = self:GetPlayerHistory(player).points
			local maxpoints = self.feature[string.lower(rollList[i].cols[crl.ty].value)].maxpoints or tonumber(self.rpbSettings.maxpoints) or 0
			if maxpoints > 0 and total > maxpoints then
				total = maxpoints
			end
			if roll then
				rollList[i].cols[crl.roll].value = roll
				rollList[i].cols[crl.total].value = total + roll
			else
				rollList[i].cols[crl.total].value = total + rollList[i].cols[crl.roll].value
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
	end
end

function RPB:RollListAward(recieved)
	local f = self.frames["RollWindow"]
	if not f.scrollFrameLoot.selected then return end
	if not f.scrollFrame.selected then return end
	if not recieved then
		self:Send(cs.rolllistaward, { true })
	end
	f.inProgress = false
	if recieved then
		return
	end

	local item = f.scrollFrameLoot.selected.cols
	local winner = f.scrollFrame.selected.cols
	local class, rank, ty, total, loss, roll, ptotal, player
	local editbox = f.editbox["AwardItem"]
	
	player = winner[crl.player].value
	class = winner[crl.class].value
	rank = winner[crl.rank].value
	ty = winner[crl.ty].value
	total = winner[crl.total].value
	--loss = winner[crl.loss].value
	loss = tonumber(editbox:GetText()) or 0
	loss = -(loss)
	roll = winner[crl.roll].value
	ptotal = self:GetPlayerHistory(player).points
	f.state = "Initial"
	self:UpdateUI()
	if self.rpoSettings.master == UnitName("player") then
		local dt = time()

		--self:Print(self.rpoSettings.raid, dt, player, -(loss), 'I', item[cll.item].value, item[cll.link].value, false, true)
		self:Broadcast(	player .. " wins " .. item[cll.link].value .. " via " .. ty .. " for cost of ".. (loss) .." with a total of " .. total .. " (" .. ptotal .. " points + " .. roll .. " roll).")
		self:PointsAdd(self.rpoSettings.raid, dt, player, (loss), 'I', item[cll.item].value, item[cll.link].value, true, true)
		self:ItemListRemove(item[cll.link].value)
		self:RollListUpdateRoll(player)
	end
	f.timer = nil
end

function RPB:RollListDisenchant(recieved)
	local f = self.frames["RollWindow"]
	if not f.scrollFrameLoot.selected then return end
	if not recieved then
		self:Send(cs.rolllistdisenchant, { true })
	end
	f.inProgress = false
	if recieved then
		return
	end
	
	local item = f.scrollFrameLoot.selected.cols
	f.state = "Initial"
	self:UpdateUI()
	if self.rpoSettings.master == UnitName("player") then
		--local dt = time()

		--self:Print(self.rpoSettings.raid, dt, player, -(loss), 'I', item[cll.item].value, item[cll.link].value, false, true)
		self:Broadcast(	"Disenchant wins " .. item[cll.link].value)
		self:ItemListRemove(item[cll.link].value)
	end
	f.timer = nil
end

function RPB:StartBidding(recieved)
	local f = self.frames["RollWindow"]
	if not f.scrollFrameLoot.selected then return end
	local item
	if f.scrollFrameLoot.selected then
		item = f.scrollFrameLoot.selected.cols	
		if not recieved then
			self:Send(cs.startbidding, { true })
		end
		f.inProgress = true
		f.state = "Bidding Started"
		self:UpdateUI()
		if self.rpoSettings.master == UnitName("player") then
			self:Broadcast("Declare on " .. item[cll.link].value .. ".")
			f.tm = (tonumber(self.rpbSettings.lastcall) or 5) + 1
		end
	end
end

function RPB:StartTimedBidding(recieved)
	local f = self.frames["RollWindow"]
	if not f.scrollFrameLoot.selected then return end
	local item
	if f.scrollFrameLoot.selected then
		item = f.scrollFrameLoot.selected.cols	
		if not recieved then
			self:Send(cs.starttimedbidding, { true })
		end
		f.inProgress = true
		f.state = "Bidding Started"
		if self.rpoSettings.master == UnitName("player") then
			self:Broadcast("Declare on " .. item[cll.link].value .. ".  Closing in " .. (tonumber(RPB.rpbSettings.bidtime) or 30) .. " seconds.")
			f.tm = (tonumber(self.rpbSettings.bidtime) or 30) - 1
			f.timer = self:ScheduleRepeatingTimer("ContinueBidding", 1)
			self:UpdateUI()
		end
	end
end

function RPB:ContinueBidding()
	local f = self.frames["RollWindow"]
	if f.inProgress then
		f.tm = f.tm - 1
		local timeleft = f.tm
		local item = f.scrollFrameLoot.selected.cols
		local lastcall = tonumber(self.rpbSettings.lastcalltonumber) or 5
		
		if (timeleft > lastcall and timeleft % (lastcall*2) == 0) then
			self:Broadcast("Bidding on " .. item[cll.link].value .. ".  Closing in " .. timeleft .. " seconds.")
		elseif (timeleft == lastcall+1) then
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
		f.timer = self:ScheduleTimer("StopBidding", 1)
		f.tm = f.tm - 1
		local timeleft = f.tm
		local item = f.scrollFrameLoot.selected.cols
		local lastcall = tonumber(self.rpbSettings.lastcall) or 5
		
		if (timeleft == lastcall) then
			self:Broadcast("Last call on " .. item[cll.link].value .. ".  Closing in "..lastcall.." seconds.")
		elseif (timeleft < lastcall) then
			self:Broadcast(timeleft)
		end
		if (timeleft == 1) then
			self:CancelTimer(f.timer)
			f.timer = nil
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
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(editbox:GetText())
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
	if not f.scrollFrameLoot.selected then return end
	if not link then
		link = f.scrollFrameLoot.selected.cols[cll.link].value
	end
	if not recieved then
		self:Send(cs.itemlistremove, {link, true})
	end
	local lootList = f.lootList
	for i=1,#lootList do
		if (lootList[i] and lootList[i].cols[cll.link].value == link) then
			if f.scrollFrameLoot.selected == lootList[i] then
				f.scrollFrameLoot.selected = nil
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
		f.scrollFrameLoot.selected = nil
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
					frame.selected = temp[i]
					temp[i].selected = true
					temp[i].highlight = msg[2][j]["highlight"]
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
		self:Send(cs.rolllistset, {sendTable, selectedTable}, sender)
	end
end

RPB.syncCommands[cs.rolllistset] = function(self, msg, sender)
	local f = self.frames["RollWindow"]
	local temp = self:BuildTable(msg[1], crlArg, rollWindowScrollFrameColor)
	f.rollList = temp
	local frame = f.scrollFrame
	for i=1,#temp do
		if msg[2] then
			for j=1,#msg[2] do
				if msg[2][j]["sel"][crl.player] and string.lower(temp[i].cols[crl.player].value) == string.lower(msg[2][j]["sel"][crl.player] ) then
					frame.selected = temp[i]
					temp[i].selected = true
					temp[i].highlight = msg[2][j]["highlight"]
				--elseif not (list[i].selected and list[i].highlight ~= RPB:GetColor(UnitName("player"))) then
				else
					temp[i].selected = false
					temp[i].highlight = nil
				end
			end
		end
	end
	f.scrollFrame:SetData(f.rollList)
	self:RollListSort()
end

RPB.syncCommands[cs.rolllistclick] = function(self, msg, sender)
	local f = self.frames["RollWindow"]
	if sender == UnitName("player") then return end
	local list = f.rollList
	local frame = f.scrollFrame
	if frame.selected then
		frame.selected.selected = false
		frame.selected.highlight = nil
		frame.selected = nil
	end
	for i=1,#list do
		if (list[i].cols[crl.player].value == msg[1][crl.player]) then
			frame.selected = list[i]
			list[i].selected = true
			list[i].highlight = msg[2]
		--elseif not (list[i].selected and list[i].highlight ~= RPB:GetColor(UnitName("player"))) then
		else
			list[i].selected = false
			list[i].highlight = nil
		end
	end
	f.scrollFrame:SortData()
end

RPB.syncCommands[cs.itemlistclick] = function(self, msg, sender)
	local f = self.frames["RollWindow"]
	if sender == UnitName("player") then return end
	local list = f.lootList
	local frame = f.scrollFrameLoot
	--self:Print(msg, unpack(msg or {}))
	if frame.selected then
		frame.selected.selected = false
		frame.selected.highlight = nil
		frame.selected = nil
	end
	for i=1,#list do
		if (list[i].cols[cll.item].value == msg[1][cll.item]) then
			frame.selected = list[i]
			list[i].selected = true
			list[i].highlight = msg[2]
		--elseif not (list[i].selected and list[i].highlight ~= RPB:GetColor(UnitName("player"))) then
		else
			list[i].selected = false
			list[i].highlight = nil
		end
	end
	f.scrollFrameLoot:SortData()
end
