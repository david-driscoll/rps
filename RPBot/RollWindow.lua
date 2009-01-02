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
--local RPLibrary = LibStub:GetLibrary("RPLibrary")

local cs =
{
	rolllistadd		= "rolllistadd",
	rolllistremove	= "rolllistremove",
	rolllistupdate	= "rolllistupdate",
	rolllistaward	= "rolllistaward",
	rolllistclear	= "rolllistclear",
	startbidding	= "startbidding",
	starttimedbidding = "starttimedbidding",
	rolllistclick	= "rolllistclick",
	itemlistadd		= "itemlistadd",
	itemlistremove	= "itemlistremove",
	itemlistclick 	= "itemlistclick",
	itemlistclear 	= "itemlistclear",
	getmaster		= "getmaster",
	setmaster		= "setmaster",
	itemlistset		= "itemlistset",
	itemlistget		= "itemlistget",
	rolllistset		= "rolllistset",
	rolllistget		= "rolllistget",
}

RPB.columnDefinitons["RollWindow"] = 
{
	{
	    ["name"] = "Name",
	    ["width"] = 90,
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
	{
	    ["name"] = "Class",
	    ["width"] = 80,
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
	{
	    ["name"] = "Rank",
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
	{
	    ["name"] = "Type",
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
	{
	    ["name"] = "Currrent",
	    ["width"] = 60,
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
	{
	    ["name"] = "Roll",
	    ["width"] = 60,
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
	{
	    ["name"] = "Loss",
	    ["width"] = 60,
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
RPB.columnDefinitons["RollWindowLootList"] = 
{
	{
	    ["name"] = "Items",
	    ["width"] = 300,
	    ["align"] = "LEFT",
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

local crlArg = 
{
	[crl.player]	= { },
	[crl.class]		= { nil, ClassColor },
	[crl.rank]		= { },
	[crl.ty]		= { },
	[crl.current]	= { },
	[crl.roll]		= { },
	[crl.loss]		= { },
}

-- Constants Loot List
local cll = 
{
	link = 1,
	item = 2,
	count = 3,
	quality = 4,
}

local cllArg =
{
	[cll.link]		= { },
	[cll.item]		= { },
	[cll.count]		= { },
	[cll.quality]	= { },
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
	f:SetHeight(440)
	f:SetWidth(620)
	f:SetPoint("CENTER",0,0)
	f:Hide()

	-- Frame Textures, Drag Header, Close Button, Title
	do
		self:Skin(f);
	   
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
	    f.scrollFrame = ScrollingTable:CreateST(RPB.columnDefinitons["RollWindow"], 10, nil, nil, f, true);
		f.scrollFrame.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -240)
		f.scrollFrame:SetData(f.rollList)
		f.scrollFrame:RegisterEvents({
			["OnClick"] = rollWindowScrollFrameOnClick,
		});

		-- f.item = {}
		-- for i=1, 1 do 
			-- f.item[i] = self:CreateLootFrame(f, i)
		-- end
		f.lootList = {}
	    f.scrollFrameLoot = ScrollingTable:CreateST(RPB.columnDefinitons["RollWindowLootList"], 10, nil, nil, f, true);
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
		button:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -40)
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
end

function RPB:RollListAdd(player, cmd, recieved)
	--local pinfo = self:GetInfo(player)
	local pinfo = self:GuildRosterByName(player) or self:RosterByName(player:gsub("^%l", string.upper))
	
	--self:Print("RPB:RollListAdd", player, cmd, recieved)
	local class, rank, ty, current, loss
	local feature = self.feature[string.lower(cmd)]
	local divisor = feature.divisor or 2
	
	if pinfo then
		class = pinfo["class"] or ""
		rank = pinfo["rank"] or ""
	end	
	
	pdata = self:GetPlayer(player)
	current = pdata.points
	player = pdata.fullname
	
	ty = feature.name
	local rollList = self.frames["RollWindow"].rollList
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			if (string.lower(rollList[i].cols[crl.ty].value) ~= string.lower(ty)) then
				self:RollListUpdate(player, nil, ty)
			end
			return false
		end
	end
	
	if not recieved then
		self:Send(cs.rolllistadd, {player, cmd, true})
	end
	if (not self:GetPlayer(player)) then
		self:CreatePlayer(player)
	end

	loss = self:CalculateLoss(current, cmd)
	rollList[#rollList+1] = self:BuildRow(
		{
			[crl.player]	= 	player,
			[crl.class]		=	class or "",
			[crl.rank]		=	rank or "",
			[crl.ty]		=	ty,
			[crl.current]	=	current,
			[crl.roll]		=	0,
			[crl.loss]		=	loss,
		},
		crlArg, rollWindowScrollFrameColor
	)
	self:RollListSort()
	return true
end

function RPB:RollListRemove(player, recieved)
	local rollList = self.frames["RollWindow"].rollList
	if not recieved then
		self:Send(cs.rolllistremove, {player, true})
	end			
	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			if self.frames["RollWindow"].scrollFrame.selected == rollList[i] then
				self.frames["RollWindow"].scrollFrame.selected = nil
			end
			tremove(rollList,i)
			break
		end
	end
	self:RollListSort()
end

function RPB:RollListClear(recieved)
	if not recieved then
		self:Send(cs.rolllistclear, {true})
	end
	self.frames["RollWindow"].rollList = {}
	self.frames["RollWindow"].scrollFrame:SetData(self.frames["RollWindow"].rollList)
	self.frames["RollWindow"].scrollFrame:SortData()
	self.frames["RollWindow"].scrollFrame.selected = nil
	self:RollListSort()
	self.frames["RollWindow"].inProgress = false
	if self.rpoSettings.master == UnitName("player") then
		self.frames["RollWindow"].button["StartBidding"]:Enable()
		self.frames["RollWindow"].button["StartTimedBidding"]:Enable()
		self.frames["RollWindow"].button["StopBidding"]:Disable()
	end
end

function RPB:RollListUpdate(player, roll, ty, recieved)
	local found = false
	local rollList = self.frames["RollWindow"].rollList

	for i=1,#rollList do
		if (string.lower(rollList[i].cols[crl.player].value) == string.lower(player)) then
			if (tonumber(rollList[i].cols[crl.roll].value) > 0 and roll) then
				self:Broadcast(player .. "  Previous Roll:" .. rollList[i].cols[crl.roll].value .. "   New Roll:" .. roll)
				break
			end
			if roll then
				rollList[i].cols[crl.roll].value = roll
				rollList[i].cols[crl.current].value = self:GetPlayer(player,"points") + roll
			else
				rollList[i].cols[crl.current].value = self:GetPlayer(player,"points") + rollList[i].cols[crl.roll].value
			end
			if ty then
				rollList[i].cols[crl.ty].value = ty
			end
			found = true
		
			if not recieved then
				self:Send(cs.rolllistupdate, {rollList[i].cols[crl.player].value, rollList[i].cols[crl.roll].value, rollList[i].cols[crl.ty].value, true})
			end
			break
		end
	end
	if (found) then
		self:RollListSort()
	else
		if self.rpoSettings.master == UnitName("player") then
			self:Broadcast(player.." is not currently bidding, roll ignored.")
		end
	end
end

function RPB:RollListSort()
	-- Call the sort function for current?
	if self.frames["RollWindow"] and self.frames["RollWindow"].scrollFrame then
		--self.frames["RollWindow"].scrollFrame.cols[crl.roll] = "asc"
		local st = self.frames["RollWindow"].scrollFrame
		local cols = st.cols
		for i, col in ipairs(cols) do 
			if i ~= crl.current then -- clear out all other sort marks
				cols[i].sort = nil;
			end
		end
		cols[crl.current].sort = "asc";
		self.frames["RollWindow"].scrollFrame:SortData();
	end
end

function RPB:CHAT_MSG_SYSTEM()
	if (self.frames and self.frames["RollWindow"] and self.frames["RollWindow"].inProgress and event == "CHAT_MSG_SYSTEM" and string.find(arg1, "rolls") and string.find(arg1, "%(1%-100%)")) then
		_, _, player, roll = string.find(arg1, "(.+) " .. "rolls" .. " (%d+)");
		--self:Print(string.find(arg1, "(.+) " .. "rolls" .. " (%d+)"))
		RPB:RollListUpdate(player, roll)
	end
end

function rollWindowScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	if RPB.rpoSettings.master == UnitName("player") then
		if button == "LeftButton" then
			if data[realrow] then
				RPB.frames["RollWindow"].scrollFrame.selected = data[realrow]
				RPB.frames["RollWindow"].scrollFrame:Refresh()
				local sendData = RPB:StripRow(data[realrow])
				--RPB:Print(unpack(sendData))
				RPB.frames["RollWindow"].editbox["AwardItem"]:SetText(data[realrow].cols[crl.loss].value)
				RPB:Send(cs.rolllistclick, sendData)
			end
		elseif button == "RightButton" then
			if data[realrow] then
				RPB:RollListRemove(data[realrow].cols[crl.player].value)
				RPB.frames["RollWindow"].scrollFrame:SortData()
			end
		end
	end
end

function rollWindowItemScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	if RPB.rpoSettings.master == UnitName("player") then
		if button == "LeftButton" then
			if data[realrow] then
				RPB.frames["RollWindow"].scrollFrameLoot.selected = data[realrow]
				RPB.frames["RollWindow"].scrollFrameLoot:Refresh()
				local sendData = RPB:StripRow(data[realrow])
				--RPB:Print(unpack(sendData))
				RPB:Send(cs.itemlistclick, sendData)
			end
		elseif button == "RightButton" then
			if data[realrow] then
				--RPB.frames["RollWindow"].scrollFrameLoot.selected = data[realrow]
				RPB:ItemListRemove(data[realrow].cols[cll.link].value)
				RPB.frames["RollWindow"].scrollFrameLoot:SortData()
			end
		end
	end
end

function rollWindowScrollFrameColor(roll)
	local feature = RPB.feature[string.lower(roll.cols[crl.ty].value)]
	-- Make this loaclizable, for generic changes.
	local diff = tonumber(feature.diff) or tonumber(self.settings.diff)
	local high = roll.cols[crl.current].value

	local rollList = RPB.frames["RollWindow"].rollList
	for i=1,#rollList do
		if (rollList[i].cols[crl.current].value > high) then
			high = rollList[i].cols[crl.current].value
		end
	end
	ratio = math.floor((roll.cols[crl.current].value) * 1.0 / ( high - diff ))
	if ratio == 1 then
		ratio = ((roll.cols[crl.current].value - high + diff + diff/2) * 1.0 / diff)
	end
	return {
		["r"] = (1-ratio),
		["g"] = ratio,
		["b"] = 0.0,
		["a"] = 1.0
	}
end

function RPB:StartBidding(recieved)
	if not RPB.frames["RollWindow"].scrollFrameLoot.selected then return end
	local item
	if RPB.frames["RollWindow"].scrollFrameLoot.selected then
		item = RPB.frames["RollWindow"].scrollFrameLoot.selected.cols	
		if not recieved then
			self:Send(cs.startbidding, { true })
		end
		self.frames["RollWindow"].inProgress = true
		if self.rpoSettings.master == UnitName("player") then
			self:Broadcast("Declare on " .. item[cll.link].value .. ".")
			self.frames["RollWindow"].tm = (tonumber(self.rpbSettings.lastcall) or 5) + 1
			self.frames["RollWindow"].button["StartBidding"]:Disable()
			self.frames["RollWindow"].button["StartTimedBidding"]:Disable()
			self.frames["RollWindow"].button["StopBidding"]:Enable()
			self.frames["RollWindow"].button["StopBidding"]:Enable()
		end
	end
end

function RPB:StartTimedBidding(recieved)
	if not RPB.frames["RollWindow"].scrollFrameLoot.selected then return end
	local item
	if RPB.frames["RollWindow"].scrollFrameLoot.selected then
		item = RPB.frames["RollWindow"].scrollFrameLoot.selected.cols	
		if not recieved then
			self:Send(cs.starttimedbidding, { true })
		end
		self.frames["RollWindow"].inProgress = true
		if self.rpoSettings.master == UnitName("player") then
			self:Broadcast("Declare on " .. item[cll.link].value .. ".  Closing in " .. (tonumber(self.settings.bidtime) or 30) .. " seconds.")
			self.frames["RollWindow"].tm = (tonumber(self.rpbSettings.bidtime) or 30) - 1
			self.frames["RollWindow"].timer = self:ScheduleRepeatingTimer("ContinueBidding", 1)
			self.frames["RollWindow"].button["StartBidding"]:Disable()
			self.frames["RollWindow"].button["StartTimedBidding"]:Disable()
			self.frames["RollWindow"].button["StopBidding"]:Enable()
		end
	end
end

function RPB:ContinueBidding()
	if self.frames["RollWindow"].inProgress then
		self.frames["RollWindow"].tm = self.frames["RollWindow"].tm - 1
		local timeleft = self.frames["RollWindow"].tm
		local item = RPB.frames["RollWindow"].scrollFrameLoot.selected.cols
		local lastcall = tonumber(self.rpbSettings.lastcalltonumber) or 5
		
		if (timeleft > lastcall and timeleft % lastcall*2 == 0) then
			self:Broadcast("Bidding on " .. item[cll.link].value .. ".  Closing in " .. timeleft .. " seconds.")
		elseif (timeleft == lastcall+1) then
			self:CancelTimer(self.frames["RollWindow"].timer)
			self.frames["RollWindow"].timer = nil
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
	if self.frames["RollWindow"].inProgress then
		self.frames["RollWindow"].button["StopBidding"]:Disable()
		self.frames["RollWindow"].timer = self:ScheduleTimer("StopBidding", 1)
		self.frames["RollWindow"].tm = self.frames["RollWindow"].tm - 1
		local timeleft = self.frames["RollWindow"].tm
		local item = RPB.frames["RollWindow"].scrollFrameLoot.selected.cols
		local lastcall = tonumber(self.rpbSettings.lastcall) or 5
		
		if (timeleft == lastcall) then
			self:Broadcast("Last call on " .. item[cll.link].value .. ".  Closing in "..lastcall.." seconds.")
		elseif (timeleft < lastcall) then
			self:Broadcast(timeleft)
		end
		if (timeleft == 1) then
			self:CancelTimer(self.frames["RollWindow"].timer)
			self.frames["RollWindow"].timer = nil
		end
		-- At the 10 second mark
			-- If bonus/upgrade bids, call 'Bidding on [item]. Closing in 10 seconds.'
			-- If offspec or nothing, call 'Bidding on [item]. Open to offspecs. Closing in 10 seconds.'
		-- At 5 seconds and below
			-- If bonus/upgrade bids, call 'Last call on [item]. Closing in 5 seconds.'
			-- If offspec or nothing, call 'Any offspecs on [item]? Closing in 5 seconds.'
	end
end

function RPB:RollListAward(recieved)
	local item = self.frames["RollWindow"].scrollFrameLoot.selected.cols
	local winner = self.frames["RollWindow"].scrollFrame.selected.cols
	local class, rank, ty, current, loss, roll, pcurrent, player
	local editbox = self.frames["RollWindow"].editbox["AwardItem"]
	
	player = winner[crl.player].value
	class = winner[crl.class].value
	rank = winner[crl.rank].value
	ty = winner[crl.ty].value
	current = winner[crl.current].value
	--loss = winner[crl.loss].value
	loss = tonumber(editbox:GetText())
	roll = winner[crl.roll].value
	pcurrent = self:GetPlayer(player,"points")
	if not recieved then
		self:Send(cs.rolllistaward, { true })
	end
	self.frames["RollWindow"].inProgress = false
	if self.rpoSettings.master == UnitName("player") then
		local dt = time()

		self:Print(dt, player, -(loss), 'I', item[cll.item].value, item[cll.link].value, false, true)
		self:Broadcast(	player .. " wins " .. item[cll.link].value .. " with a total of " .. current .. " (" .. pcurrent .. " points + " .. roll .. " roll).")
		self:PointsAdd(dt, player, -(loss), 'I', item[cll.item].value, item[cll.link].value, false, true)
		self:ItemListRemove(item[cll.link].value)
		self.frames["RollWindow"].button["StartBidding"]:Enable()
		self.frames["RollWindow"].button["StartTimedBidding"]:Enable()
		self.frames["RollWindow"].button["StopBidding"]:Disable()
		self:RollListUpdate(player)
	end
	self.frames["RollWindow"].timer = nil
end

function RPB:ItemListAdd(link, item, count, quality, recieved)
	--if quality and quality < 3 then return end
	if not link then
		local editbox = self.frames["RollWindow"].editbox["AddItem"]
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(editbox:GetText())
		--RPB:Print(GetItemInfo(editbox:GetText()))
		link = editbox:GetText()
		local item = self:GetItemID(link)
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
	local lootList = self.frames["RollWindow"].lootList
	lootList[#lootList+1] = self:BuildRow(
		{
			[cll.link]		= 	link,
			[cll.item]		=	item,
			[cll.count]		=	count,
			[cll.quality]	=	quality,
		},
		cllArg
	)
	self.frames["RollWindow"].scrollFrameLoot:SortData()
end

function RPB:ItemListRemove(link, recieved)
	if not link then
		link = RPB.frames["RollWindow"].scrollFrameLoot.selected.cols[cll.link].value
	end
	if not recieved then
		self:Send(cs.itemlistremove, {link, true})
	end
	local lootList = self.frames["RollWindow"].lootList
	for i=1,#lootList do
		if (lootList[i] and lootList[i].cols[cll.link].value == link) then
			if self.frames["RollWindow"].scrollFrameLoot.selected == lootList[i] then
				self.frames["RollWindow"].scrollFrameLoot.selected = nil
			end
			tremove(lootList,i)
			break
		end
	end
	self.frames["RollWindow"].scrollFrameLoot:SortData()
end

function RPB:ItemListClear(recieved)
	if not recieved then
		self:Send(cs.itemlistclear, {true})
	end
	self.frames["RollWindow"].lootList = {}
	self.frames["RollWindow"].scrollFrameLoot:SetData(self.frames["RollWindow"].lootList)
	self.frames["RollWindow"].scrollFrameLoot:SortData()
	self.frames["RollWindow"].scrollFrameLoot.selected = nil
end

RPB.syncCommands[cs.itemlistget] = function(self, msg, sender)
	if self.rpoSettings.master == UnitName("player") then
		local sendTable = self:StripTable(self.frames["RollWindow"].lootList or {})
		local selectedTable = {}
		if self.frames["RollWindow"].scrollFrameLoot.selected then
			selectedTable = self:StripRow(self.frames["RollWindow"].scrollFrameLoot.selected)
		end
		self:Send(cs.itemlistset, {sendTable, selectedTable})
	end
end

RPB.syncCommands[cs.itemlistset] = function(self, msg, sender)
	local temp = self:BuildTable(msg[1], cllArg)
	self.frames["RollWindow"].lootList = temp
	for i=1,#temp do
		if temp[i].cols[crl.player].value == msg[2][cll.link] then
			self.frames["RollWindow"].scrollFrameLoot.selected = temp[i]
		end
	end

	self.frames["RollWindow"].scrollFrameLoot:SetData(self.frames["RollWindow"].lootList)
end
	
RPB.syncCommands[cs.rolllistget] = function(self, msg, sender)
	if self.rpoSettings.master == UnitName("player") then
		local sendTable = self:StripTable(self.frames["RollWindow"].rollList or {})
		local selectedTable = {}
		if self.frames["RollWindow"].scrollFrame.selected then
			selectedTable = self:StripRow(self.frames["RollWindow"].scrollFrame.selected)
		end
		self:Send(cs.rolllistset, {sendTable, selectedTable})
	end
end

RPB.syncCommands[cs.rolllistset] = function(self, msg, sender)
	local temp = self:BuildTable(msg[1], crlArg, rollWindowScrollFrameColor)
	self.frames["RollWindow"].rollList = temp
	for i=1,#temp do
		if string.lower(temp[i].cols[crl.player].value) == string.lower(msg[2][crl.player]) then
			self.frames["RollWindow"].scrollFrame.selected = temp[i]
		end
	end
	self.frames["RollWindow"].scrollFrame:SetData(self.frames["RollWindow"].rollList)
	self:RollListSort()
end


