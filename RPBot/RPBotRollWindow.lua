local db = RPB.db
local RPLibrary = LibStub:GetLibrary("RPLibrary")

RPB.columnDefinitons["RollWindow"] = 
{
	{
	    ["name"] = "Name",
	    ["width"] = 70,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Class",
	    ["width"] = 70,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Rank",
	    ["width"] = 70,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Type",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Currrent",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Roll",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Loss",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
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
RPB.columnDefinitons["RollWindowLootList"] = 
{
	{
	    ["name"] = "Items",
	    ["width"] = 120,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
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
local crl = 
{
	player = 1,
	class = 2,
	rank = 3,
	ty = 4,
	current = 5,
	roll = 6,
	loss = 7,
}

-- Constants Loot List
local cll = 
{
	link = 1,
	item = 2,
	count = 3,
	quality = 4,
}

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
	   f.dragheader = drag
	   
	   local title = f:CreateFontString("Title", "ARTWORK", "GameFontNormal")
	   title:SetPoint("TOP", f, "TOP", 0, -6)
	   title:SetText("Raid Points - Roll Window")
	   f.title = title
	end

    -- Scroll Frame
	do
		f.rollList = {}
	    f.scrollFrame = ScrollingTable:CreateST(RPB.columnDefinitons["RollWindow"], 10, nil, nil, f);
		f.scrollFrame.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 170, -30)
		f.scrollFrame:SetData(f.rollList)
		f.scrollFrame:RegisterEvents({
			["OnClick"] = rollWindowScrollFrameOnClick,
		});

		f.item = {}
		for i=1, 1 do 
			f.item[i] = self:CreateLootFrame(f, i)
		end
		f.lootList = {}
	    f.scrollFrameLoot = ScrollingTable:CreateST(RPB.columnDefinitons["RollWindowLootList"], 10, nil, nil, f);
		f.scrollFrameLoot.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
		f.scrollFrameLoot:SetData(f.lootList)
		f.scrollFrameLoot:RegisterEvents({
			["OnClick"] = rollWindowItemScrollFrameOnClick,
		});

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
		button:SetPoint("TOPLEFT", f.scrollFrame.frame, "BOTTOMLEFT", 10, -6)
		button:SetText("Start Bidding")
		button:SetScript("OnClick", 
			function(self)
				RPB:StartBidding()
			end
		)
		f.button["StartBidding"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonStopBidding", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["StartBidding"], "TOPRIGHT", 4, 0)
		button:SetText("Stop Bidding")
		button:SetScript("OnClick", 
			function(self)
				RPB:StopBidding()
			end
		)
		f.button["StopBidding"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonStartTimedBidding", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["StartBidding"], "BOTTOMLEFT", 0, -4)
		button:SetText("Timed Bidding")
		button:SetScript("OnClick", 
			function(self)
				RPB:StartTimedBidding()
			end
		)
		f.button["StartTimedBidding"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonAwardItem", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["StopBidding"], "TOPRIGHT", 4, 0)
		button:SetText("Award Item")
		button:SetScript("OnClick", 
			function(self)
				RPB:AwardItem()
			end
		)
		f.button["AwardItem"] = button
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonRemoveItem", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOP", f.scrollFrameLoot.frame, "BOTTOM", 0, 0)
		button:SetText("Remove Item")
		button:SetScript("OnClick", 
			function(self)
				RPB:RemoveItem()
			end
		)
		f.button["RemoveItem"] = button
			
		local button = CreateFrame("Button", f:GetName() .. "_ButtonAddItem", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 4, 90)
		button:SetText("Add Item")
		button:SetScript("OnClick", 
			function(self)
				RPB:AddItem()
			end
		)
		f.button["AddItem"] = button
			
		local button = CreateFrame("Button", f:GetName() .. "_ButtonClearList", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.button["RemoveItem"], "BOTTOMLEFT", 0, -4)
		button:SetText("Clear List")
		button:SetScript("OnClick", 
			function(self)
				RPB:ClearList()
			end
		)
		f.button["ClearList"] = button	
		
		local button = CreateFrame("Button", f:GetName() .. "_ButtonMaster", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f, "TOPLEFT", 10, 120)
		button:SetText("Master")
		button:SetScript("OnClick", 
			function(self)
				RPB:SetMaster()
			end
		)
		f.button["Master"] = button
	end
	
	--  Editbox
		-- Add Item
	do
		f.editbox = {}

		-- Code originally created by Shadowed
		-- Seems generic enough, but giving credit where credit is due.
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["AddItem"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(110)
		
		editbox:SetScript("OnEnterPressed", function(self) RPB:AddItem() end)
		editbox:SetPoint("TOPLEFT", f.button["AddItem"], "TOPRIGHT", 10, 6)
		
		RPLibrary:SkinEditBox(editbox)
		
		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["AwardItem"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(50)
		
		editbox:SetScript("OnEnterPressed", function(self) RPB:AddItem() end)
		editbox:SetPoint("TOPLEFT", f.button["AwardItem"], "TOPRIGHT", 10, 6)
		
		RPLibrary:SkinEditBox(editbox)
		
		
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
end

function RPB:CalculateLoss(points, cmd)
	local feature = self.feature[cmd]
	-- Make this loaclizable, for generic changes.
	local divisor = feature.divisor or db.realm.settings.divisor
	-- local minclass = feature.minclass or db.realm.settings.minclass
	-- local maxclass = feature.maxclass or db.realm.settings.maxclass
	local minnonclass = feature.minnonclass or db.realm.settings.minnonclass
	local maxnonclass = feature.maxnonclass or db.realm.settings.maxnonclass
	local loss
	
	current = ceil( ( points / divisor ) / db.realm.settings.rounding ) * db.realm.settings.rounding

	-- If I want to continue with class specific item logic, this is where we do it.
	if (current < minnonclass) then
		loss = minnonclass
	elseif (current > minnonclass and (not maxnonclass or current < maxnonclass)) then
		loss = current
	else
		loss = maxnonclass
	end

	if (current > 0 and loss > current and not db.realm.settings.allownegative) then
		loss = current
	end
	
	return loss
end

function RPB:RollListAdd(player, cmd, recieved)
	local rollList = self.frames["RollWindow"].rollList
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			return false
		end
	end
	--local pinfo = RPLibrary:GetInfo(player)
	local class, rank, ty, current, loss
	local feature = self.feature[cmd]
	local divisor = feature.divisor or 2
	
	if pinfo then
		class = pinfo["class"]
		rank = pinfo["rank"]
	end	
	
	ty = feature.name
	if (not self.activeraid[string.lower(player)]) then
		self:CreatePlayer(string.lower(player))
	end
	current = self.activeraid[string.lower(player)].points
	player = self.activeraid[string.lower(player)].fullname

	loss = self:CalculateLoss(current, cmd)

	rollList[#rollList+1] = RPLibrary:BuildRow(
		{
			[crl.player]	= 	RPLibrary:BuildColumn(player),
			[crl.class]		=	RPLibrary:BuildColumn(class),
			[crl.rank]		=	RPLibrary:BuildColumn(rank),
			[crl.ty]		=	RPLibrary:BuildColumn(ty),
			[crl.current]	=	RPLibrary:BuildColumn(current),
			[crl.roll]		=	RPLibrary:BuildColumn(100),
			[crl.loss]		=	RPLibrary:BuildColumn(loss)
		}
	)
	RPLibrary:AppendRow(
		rollList[#rollList],
		--rollWindowScrollFrameOnClick, {rollList[#rollList]},
		rollWindowScrollFrameColor, {rollList[#rollList]}
	)
	self:RollListSort()
	return true
end

function RPB:RollListRemove(player, recieved)
	local rollList = self.frames["RollWindow"].rollList
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			tremove(rollList,i)
			break
		end
	end
	self:RollListSort()
end

function RPB:RollListUpdate(player, roll, recieved)
	local found = false
	local rollList = self.frames["RollWindow"].rollList
	
	for i=1,#rollList do
		if (rollList[i].cols[crl.player] == player) then
			if (rollList[i].cols[crl.roll] > 0) then
				self:Print(player,"  Previous Roll:",rollList[i].cols[crl.roll].value,"   New Roll:",roll)
			end
			rollList[i].cols[crl.roll].value = roll
			rollList[i].cols[crl.current].value = self.activeraid[player].points + roll
			found = true
			break
		end
	end
	if (found) then
		self:RollListSort()
	else
		self:Print(player,"is not currently bidding, roll ignored.")
	end
end

function RPB:RollListSort()
	-- Call the sort function for current?
	if self.frames["RollWindow"] and self.frames["RollWindow"].scrollFrame then
		--self.frames["RollWindow"].scrollFrame.cols[crl.roll] = "asc"
		self.frames["RollWindow"].scrollFrame:SortData()
	end
end

function rollWindowScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	if button == "LeftButton" then
		RPB.frames["RollWindow"].scrollFrame.selected = data[realrow]
	elseif button == "RightButton" then
		RPB:RollListRemove(data[realrow].cols[crl.player].value)
	end
end

function rollWindowItemScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	-- if button == "LeftButton" then
		-- RPB.frames["RollWindow"].scrollFrameLoot.selected = data[realrow]
	-- elseif button == "RightButton" then
		-- RPB:RollListRemove(data[realrow].cols[cll.link])
	-- end
end

function rollWindowScrollFrameColor(roll)
	local high = roll.cols[crl.roll].value
	local rollList = RPB.frames["RollWindow"].rollList
	for i=1,#rollList do
		if (rollList[i].cols[crl.roll].value > high) then
			high = rollList[i].cols[crl.roll].value
		end
	end
	RPB:Print(roll.cols[crl.roll].value, high)
	ratio = roll.cols[crl.roll].value * 1.0 / high
	return {
		["r"] = (1-ratio),
		["g"] = ratio,
		["b"] = 0.0,
		["a"] = 1.0
	}
end

function RPB:StartBidding()
	local item = RPB.frames["RollWindow"].scrollFrameLoot.selected
	-- If in raid, send message to raid
	-- If in party, send message to party
	-- Else nothing.
	--  'Declare on [item].'
	if item then
		self:Print("Declare on " .. item[cll.link] .. ".")
	end
end

function RPB:StartTimedBidding()
	local item = RPB.frames["RollWindow"].scrollFrameLoot.selected
	-- If in raid, send message to raid
	-- If in party, send message to party
	-- Start timer at X seconds
		-- Callback to Continue Bidding
	if item then
		self:Print("Declare on [item]." .. item[cll.link] .. ".  Closing in " .. (db.realm.settings.bidtime or 30) .. " seconds.")
		self.frames["RollWindow"].inProgress = true
		self.frames["RollWindow"].tm = (db.realm.settings.bidtime or 30) - 1
		self.frames["RollWindow"].timer = self:ScheduleRepeatingTimer("ContinueBidding", 1)
	end
end

function RPB:ContinueBidding()
	self.frames["RollWindow"].tm = self.frames["RollWindow"].tm - 1
	local timeleft = self.frames["RollWindow"].tm
	local item = RPB.frames["RollWindow"].scrollFrameLoot.selected
	
	if (timeleft > 10 and timeleft % 10 == 0) then
		self:Print("Bidding on [item]." .. item[cll.link] .. ".  Closing in " .. timeleft .. " seconds.")
	elseif (timeleft == 10) then
		self:CancelTimer(self.frames["RollWindow"].timer)
		self.frames["RollWindow"].timer = self:ScheduleRepeatingTimer("StopBidding", 1)
		RPB:StopBidding()
	end
	
	
	--Every 10 seconds
		-- call 'Bidding on [item].  Closing in XX seconds.'
	--At halfway or just beyond halfway
		-- If bonus/upgrade bids, call 'Bidding on [item]. Closing in XX seconds.'
		-- If offspec or nothing, call 'Bidding on [item]. Open to offspecs. Closing in XX seconds.'
end

function RPB:StopBidding()
	self.frames["RollWindow"].tm = self.frames["RollWindow"].tm - 1
	local timeleft = self.frames["RollWindow"].tm
	local item = RPB.frames["RollWindow"].scrollFrameLoot.selected
	
	if (timeleft == 10) then
		self:Print("Bidding on [item]." .. item[cll.link] .. ".  Closing in 10 seconds.")
	elseif (timeleft == 5) then
		self:Print("Last call on [item]." .. item[cll.link] .. ".  Closing in 5 seconds.")
	elseif (timeleft < 4) then
		self:Print(timeleft)
	end
	if (timeleft == 1) then
		self:CancelTimer(self.frames["RollWindow"].timer)
	end
	-- At the 10 second mark
		-- If bonus/upgrade bids, call 'Bidding on [item]. Closing in 10 seconds.'
		-- If offspec or nothing, call 'Bidding on [item]. Open to offspecs. Closing in 10 seconds.'
	-- At 5 seconds and below
		-- If bonus/upgrade bids, call 'Last call on [item]. Closing in 5 seconds.'
		-- If offspec or nothing, call 'Any offspecs on [item]? Closing in 5 seconds.'
end

function rollWindowItemScrollFrameColor(quality)
	
end

function RPB:AddItem(link, item, count, quality, recieved)
	local lootList = self.frames["RollWindow"].lootList
	lootList[#lootList+1] = RPLibrary:BuildRow(
		{
			[cll.link]		= 	RPLibrary:BuildColumn(link),
			[cll.item]		=	RPLibrary:BuildColumn(item),
			[cll.count]		=	RPLibrary:BuildColumn(count),
			[cll.quality]	=	RPLibrary:BuildColumn(quality),
		}
	)
	RPLibrary:AppendRow(
		lootList[#lootList]
		--rollWindowItemScrollFrameOnClick
		--rollWindowScrollFrameColor, {lootList[#lootList][cll.quality]}
	)
end

function RPB:RemoveItem(link, recieved)
	local lootList = self.frames["RollWindow"].lootList

	for i=1,#self.frames["RollWindow"].lootList do
		if (self.frames["RollWindow"].lootList[i] and self.frames["RollWindow"].lootList[i][crl.link].value == link) then
			tremove(self.frames["RollWindow"].lootList[i])
			break
		end
	end
end

function RPB:AwardItem()
	local item = RPB.frames["RollWindow"].scrollFrameLoot.selected.cols
	local winner = RPB.frames["RollWindow"].scrollFrame.selected.cols
	local class, rank, ty, current, loss, roll, pcurrent, player
	
	player = winner[crl.player].value
	class = winner[crl.class].value
	rank = winner[crl.rank].value
	ty = winner[crl.ty].value
	current = winner[crl.current].value
	loss = winner[crl.loss].value
	roll = winner[crl.roll].value
	pcurrent = self.activeraid[player].points
	
	local dt = time()

	self:Print(	prefix .. " " .. player .. " wins " .. item[cll.link] .. " with a total of " .. current .. " (" .. pcurrent .. " points + " .. roll .. " roll).")
	self:PointsAdd(dt, player, -(loss), ty, item[cll.item], item[cll.link], false, true)
	self.frames["RollWindow"].inProgress = false
end
