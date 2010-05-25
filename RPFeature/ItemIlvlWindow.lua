--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPRot/ItemIlvlWindow.lua
	* Component: Rules Interface
	* Details:
		This is the item Ilvl interface, certian items report as a different ilvl
		than the items they produce such as tier tokens, this comes pre populated
		and is updated once in a while, but this interface lets you add custom items.
]]

--local prefix = "<RPR>"
local db = RPR.db

--  Constants Roll List
local cil = RPSConstants.stConstants["ItemList"]
local cilArg = RPSConstants.stArgs["ItemList"]

local cs
local ScrollingTable = LibStub:GetLibrary("ScrollingTable");

function RPR:CreateItemFrame()
	cs = RPSConstants.syncCommands["Bot"]
	db = RPR.db
	-- if self.Frame then
	  -- self.Frame:Hide()
	-- end

	if not self.frames then
		self.frames = {}
	end
	self.frames["ItemWindow"] = CreateFrame("Frame", "RPRRulesItemWindow", UIParent)

	local f = self.frames["ItemWindow"]
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	--   f:SetResizeable(true)
	f:SetFrameStrata("DIALOG")
	f:SetFrameLevel(102)
	f:SetHeight(520)
	f:SetWidth(470)
	f:SetPoint("CENTER")
	f:Hide()
	f:SetScript("OnShow", RPR.LoadItemData)

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
		title:SetText("Raid Points - Item iLvl Editor")
		f.title = title
	end

    -- Scroll Frame
	do
		f.itemList = {}
	    f.scrollFrame = ScrollingTable:CreateST(RPSConstants.columnDefinitons["ItemList"], 25, nil, nil, f);
		f.scrollFrame:EnableSelection(true);
		f.scrollFrame.frame:SetParent(f)
		f.scrollFrame.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -30)
		f.scrollFrame:SetData(f.itemList)
		f.scrollFrame:RegisterEvents({
			["OnClick"] = itemWindowScrollFrameOnClick,
		});

	end

	do
		f.button={}
		f.editbox={}

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["AddItem"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(130)
		
		editbox:SetScript("OnEnterPressed", function(self) RPR:ItemListAdd() end)
		editbox:SetPoint("TOPLEFT", f.scrollFrame.frame, "BOTTOMLEFT", 10, 6)
		
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox, true)

		local button = CreateFrame("Button", f:GetName() .. "_ButtonAddItem", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.editbox["AddItem"], "TOPRIGHT", 4, -6)
		button:SetText("Add Item")
		button:SetScript("OnClick", 
			function(self)
				RPR:ItemListAdd()
			end
		)
		f.button["AddItem"] = button

		local editbox = CreateFrame("EditBox", nil, f)
		f.editbox["UpdateItem"] = editbox
		editbox:SetAutoFocus(false)
		editbox:SetHeight(32)
		editbox:SetWidth(130)
		
		editbox:SetScript("OnEnterPressed", function(self) RPR:ItemListUpdate() end)
		editbox:SetPoint("TOPLEFT", f.editbox["AddItem"], "BOTTOMLEFT", 0, -5)
		
		self:SkinEditBox(editbox)
		self:ScriptEditBox(editbox)

		local button = CreateFrame("Button", f:GetName() .. "_ButtonUpdateItem", f, "UIPanelButtonTemplate")
		button:SetWidth(90)
		button:SetHeight(21)
		button:SetPoint("TOPLEFT", f.editbox["UpdateItem"], "TOPRIGHT", 4, -6)
		button:SetText("Update Item")
		button:SetScript("OnClick", 
			function(self)
				RPR:ItemListUpdate()
			end
		)
		f.button["UpdateItem"] = button
	
		local button = CreateFrame("Button", f:GetName() .. "_ButtonCommit", f, "UIPanelButtonTemplate")
		button:SetWidth(60)
		button:SetHeight(21)
		button:SetPoint("BOTTOM", f, "BOTTOM", -40, 10)
		button:SetText("Commit")
		button:SetScript("OnClick", 
			function(self)
				RPR:CommitItemChanges()
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
				RPR:CancelItemChanges()
			end
		)
		f.button["Cancel"] = button
	end
end

function itemWindowScrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, down)
	local f = RPR.frames["ItemWindow"]
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
			selected.highlight = { r = 0.0, g = 0.0, b = 0.5, a = 0.5 }
			f.scrollFrame:Refresh()

			f.editbox["UpdateItem"]:SetText(selected.cols[cil.ilvl].value or "")
			return true
		end
	end
	return true
end

function RPR:ItemListAdd()
	local f = self.frames["ItemWindow"]
	--if quality and quality < 3 then return end
	local editbox = f.editbox["AddItem"]
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(editbox:GetText())
	--RPB:Print(GetItemInfo(editbox:GetText()))
	local link = editbox:GetText()
	local item = self:GetItemID(link)
	--_, _, item  = string.find(link, "item:(%d+)");
	if not item then
		item = 0
	end
	local count = itemCount
	local quality = itemRarity
	editbox:SetText("")
	editbox:ClearFocus()
	if link == "" then return false end
	if not count then count = 0 end
	if not quality then quality = 0 end

	local itemList = f.itemList
	itemList[#itemList+1] = self:BuildRow(
		{
			[cil.itemid]	= 	link,
			[cil.ilvl]		=	itemLevel,
		},
		cilArg
	)
	f.scrollFrame:SortData()
end

function RPR:ItemListUpdate()
	local f = self.frames["ItemWindow"]
	local selected = f.scrollFrame:GetRow(f.scrollFrame:GetSelection());

	local editbox = f.editbox["UpdateItem"]
	local ilvl = tonumber(editbox:GetText())

	selected.cols[cil.ilvl].value = ilvl
	f.scrollFrame:SortData()
end

function RPR:LoadItemData()
	local f = RPR.frames["ItemWindow"]
	f.itemList = {}
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture
	for key,value in pairs(RPR.db.realm.itemilvlDB) do
		itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = RPR:GetItemInfo(key)
		if not itemLink then
			itemLink = key
		end
		f.itemList[#f.itemList+1] = RPR:BuildRow(
			{
				[cil.itemid]	= 	itemLink,
				[cil.ilvl]		=	value,
			},
			cilArg
		)
	end
	f.scrollFrame:ClearSelection()
	f.scrollFrame:SetData(f.itemList)
	f.scrollFrame:SortData(f.itemList)
end

function RPR:CommitItemChanges()
	local f = RPR.frames["ItemWindow"]
	self.db.realm.itemilvlDB = {}
	self.db.realm.settings.itemversion = time()
	for i=1,#f.itemList do
		local itemid = self:GetItemID(f.itemList[i].cols[cil.itemid].value)
		if not itemid then
			itemid = tonumber(f.itemList[i].cols[cil.itemid].value)
		end
		itemid = tonumber(itemid)
		RPB:Debug(f.itemList[i].cols[cil.itemid].value, itemid)
		RPB:Debug(f.itemList[i].cols[cil.ilvl].value)
		self.db.realm.itemilvlDB[itemid] = f.itemList[i].cols[cil.ilvl].value
	end
	if RPB then
		RPB:Send(cs.iisend, {self.db.realm.itemilvlDB, self.db.realm.settings.itemversion})
	end
	f:Hide()
end

function RPR:CancelItemChanges()
	local f = RPR.frames["ItemWindow"]
	f:Hide()
end
