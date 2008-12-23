local db = RPB.db
local RPLibrary = LibStub:GetLibrary("RPLibrary")
function RPB:CreateLootFrame(parent, id)
	-- Shamefully taken from XLoot
	-- Credits go to the original Dev, and the current Dev's maintaining it.  Still love the addon.
	local frame = CreateFrame("Frame", parent:GetName() .. "_LootFrame" .. id, parent)
	local bname = parent:GetName() .. "_LootButton"
	local button = CreateFrame(LootButton1:GetObjectType(), bname, frame, "LootButtonTemplate")
	-- Equivalent of XLootButtonTemplate
	local text = _G[bname.."Text"]
	local desc = button:CreateFontString(bname.."Description")
	local quality = button:CreateFontString(bname.."Quality")
	local bind = button:CreateFontString(bname.."Bind")
	
	local font = { STANDARD_TEXT_FONT, 10, "" }
	
	text:SetDrawLayer("OVERLAY")
	desc:SetDrawLayer("OVERLAY")
	quality:SetDrawLayer("OVERLAY")
	bind:SetDrawLayer("OVERLAY")
	
	desc:SetFont(unpack(font))
	quality:SetFont(unpack(font))
	font[2] = 9
	font[3] = "OUTLINE"
	bind:SetFont(unpack(font))
	
	desc:SetJustifyH("LEFT")
	quality:SetJustifyH("LEFT")
	bind:SetJustifyH("LEFT")
	
	desc:SetHeight(10)	
	quality:SetHeight(10)
	text:SetHeight(10)
	bind:SetHeight(10)
	
	quality:SetWidth(155)
	
	quality:SetPoint("TOPLEFT", button, "TOPLEFT", 45, -3)
	bind:SetPoint("BOTTOMLEFT",  button, "BOTTOMLEFT", 3, 3)

	button:SetHitRectInsets(0, -165, 0, -1)
	-- End template
	local border = RPLibrary:QualityBorder(button)
	local fborder = RPLibrary:QualityBorder(frame)
	button.wrapper = RPLibrary:ItemButtonWrapper(button, 6, 6)
	fborder:SetHeight(fborder:GetHeight() -3)
	fborder:SetPoint("CENTER", frame, "CENTER", 4, .5)
	fborder:SetAlpha(0.3)
	frame:SetWidth(200)
	frame:SetHeight(button:GetHeight()+1)
	button:ClearAllPoints()
	frame:ClearAllPoints()
	if (id == 1) then 
		frame:SetPoint("TOPLEFT", parent.frame, "TOPLEFT", 10, -10)
	else
		frame:SetPoint("TOPLEFT", parent.item[id-1], "BOTTOMLEFT", 0, -2)
	end
	button:SetPoint("LEFT", frame, "LEFT")
	-- button:RegisterForDrag("LeftButton")
	-- button:SetScript("OnDragStart", function(self) XLoot:DragStart() end)
	-- button:SetScript("OnDragStop", function(self) XLoot:DragStop() end)
	button:SetScript("OnEnter", 	function(self) 
		local slot = self:GetID() 
		if LootSlotIsItem(slot) then 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT") 
			GameTooltip:SetLootItem(slot) 
			if IsShiftKeyDown() then 
				GameTooltip_ShowCompareItem() 
			end 
			CursorUpdate(self) 
		end 
	end )
	button:SetScript("OnUpdate", function(self, elapsed) CursorOnUpdate(self) end)
	self.button = button
	self.button.border = border
	self.frame = frame
	self.frame.border = fborder
	--self:msg("Creation: self.buttons["..id.."] = ".. button:GetName())
	self.frame:SetHeight(self.frame:GetHeight() + frame:GetHeight())

	--Skin
	RPLibrary:Skin(frame)
	
	button.text = text
	button.desc = desc
	button.bind = bind
	button.quality = quality
	button:DisableDrawLayer("ARTWORK")
	button:Hide()
	frame:Hide()
end

function RPB:LOOT_OPENED()
	local texture, item, count, quality
	local numLoot = GetNumLootItems()
	for slot = 1, numLoot do
		texture, item, count, quality = GetLootSlotInfo(slot)
		self:UpdateLoot(texture, item, count, quality)
	end
end

function RPB:START_LOOT_ROLL()
	local rollID = item
	local link = GetLootRollItemLink(item)
	local texture, name, count, quality, bop = GetLootRollItemInfo(item)
	self:UpdateLoot(texture, item, count, quality)
	self:AddItem(link, item, count, quality)
end

function RPB:UpdateLoot(texture, item, count, quality)
	local db = self.db.profile
	-- LootLoop
	local slot, curslot, button, frame, texture, item, quantity, quality, color, qualitytext, textobj, infoobj, qualityobj
	local curshift, qualityTower, framewidth  = 0, 0, 0
		if (texture) then
			curshift = curshift +1
			-- If we're shifting loot, use position slots instead of item slots
			if db.collapse then
				button = self.buttons[curshift]
				frame = self.frames[curshift]
				curslot = curshift
			else
				button = self.buttons[slot]
				frame = self.frames[slot]
				curslot = slot
			end
			button:SetID(slot)
			button.slot = slot
			--self:msg("Attaching loot["..slot.."] ["..item.."] to slot ["..curslot.."], bSlot = "..button.slot);
			color = ITEM_QUALITY_COLORS[quality]
			qualityTower = max(qualityTower, quality)
			SetItemButtonTexture(button, texture)
			textobj = _G["XLootButton"..curslot.."Text"]
			infoobj = _G["XLootButton"..curslot.."Description"]
			qualityobj = _G["XLootButton"..curslot.."Quality"]
			infoobj:SetText("")
			infoobj:SetVertexColor(unpack(db.infocolor))
			qualityobj:SetText("")
			if LootSlotIsCoin(slot) then -- Fix and performance fix thanks to Dead_LAN
				item = string.gsub(item, "\n", " ", 1, true);
			end
			
			table.insert(self.currentloot, { texture = texture, item = item, quantity = quantity, quality = quality, link = GetLootSlotLink(slot) })
			
			if db.lootexpand then
				textobj:SetWidth(700)
				infoobj:SetWidth(700)
			else
				textobj:SetWidth(155)
				infoobj:SetWidth(155)
			end
			textobj:SetVertexColor(color.r, color.g, color.b);
			textobj:SetText(item);
			
			if db.qualitytext and not LootSlotIsCoin(slot) then 
				qualityobj:SetText(_G["ITEM_QUALITY"..quality.."_DESC"])
				qualityobj:SetVertexColor(.8, .8, .8, 1);
				textobj:SetPoint("TOPLEFT", button, "TOPLEFT", 42, -12)
				infoobj:SetPoint("TOPLEFT", button, "TOPLEFT", 45, -22)
				textobj:SetHeight(10)
			elseif LootSlotIsCoin(slot) then
				textobj:SetPoint("TOPLEFT", button, "TOPLEFT", 42, 2)
				qualityobj:SetText("")
				button.bind:SetText("")
				textobj:SetHeight(XLootButton1:GetHeight()+1)
			else
				qualityobj:SetText("")
				if db.infotext then
					textobj:SetPoint("TOPLEFT", button, "TOPLEFT", 42, -8)
				else
					textobj:SetPoint("TOPLEFT", button, "TOPLEFT", 42, -12)
					infoobj:SetText("")
				end
				infoobj:SetPoint("TOPLEFT", button, "TOPLEFT", 45, -18)
				textobj:SetHeight(10)
			end
			
			if db.lootqualityborder then
				frame:SetBackdropBorderColor(color.r, color.g, color.b, 1)
				button.wrapper:SetBackdropBorderColor(color.r, color.g, color.b, 1)
			else
				frame:SetBackdropBorderColor(unpack(db.lootbordercolor))
				button.wrapper:SetBackdropBorderColor(unpack(db.lootbordercolor))
			end
			
			if LootSlotIsItem(slot) and quality >= db.loothighlightthreshold then
				local r, g, b, hex = GetItemQualityColor(quality)
				if db.texcolor then
					button.border:SetVertexColor(r, g, b)
					button.border:Show()
				else button.border:Hide() end
				if db.loothighlightframe then
					frame.border:SetVertexColor(r, g, b)
					frame.border:Show()
				else frame.border:Hide() end
			else
				button.border:Hide()
				frame.border:Hide()
			end
			
			if LootSlotIsItem(slot) and db.infotext then
				self:SetSlotInfo(slot, button)
			end
			
			if db.lootexpand then 
				framewidth = max(framewidth, textobj:GetStringWidth(), infoobj:GetStringWidth())
			end
			
			SetItemButtonCount(button, quantity)
			button.quality = quality
			button:Show()
			frame:Show()
			
		--elseif not db.collapse then
			--curshift = curshift + 1
			--self.buttons[slot]:Hide()
			--self:msg("Hiding slot "..slot..", curshift: "..curshift)
		end
	
	--if slot == curshift then --Collapse lower buttons
	--	curshift = curshift -1
	--	--self:msg("Collapsing end slot "..slot..", curshift now "..curshift)
	--end
	
	--XLootFrame:SetScale(db.scale)
	local color = ITEM_QUALITY_COLORS[qualityTower]
	if db.qualityborder and not self.visible then 
		--self:msg("Quality tower: "..qualityTower)
		self.frame:SetBackdropBorderColor(color.r, color.g, color.b, 1)
	else
		 self.frame:SetBackdropBorderColor(unpack(db.bordercolor))
	end
	if db.qualityframe and not self.visible then
		self.frame:SetBackdropColor(color.r, color.g, color.b, db.bgcolor[4])
	else
		self.frame:SetBackdropColor(unpack(db.bgcolor))
	end
		
	--XLootFrame:SetHeight(20 + (curshift*(XLootButtonFrame1:GetHeight()+2)))
	
	if db.lootexpand then
		self.loothasbeenexpanded = true
		local fwidth, bwidth = (self.buttons[1]:GetWidth() + framewidth + 21), -(framewidth + 16)
		self:UpdateWidths(curshift, fwidth, bwidth, fwidth+24)
	else --if self.loothasbeenexpanded then
		self.loothasbeenexpanded = false
		self:UpdateWidths(table.getn(self.frames), 200, -163, 222)
	end
	
	
	if (db.collapse and db.cursor) or (not self.visible and db.cursor) then -- FruityLoot
		self:PositionAtCursor()
	end
	
	self.frame:Show()
	if db.linkallvis == "always" or (db.linkallvis == "raid" and GetNumRaidMembers() > 0) or (db.linkallvis == "party" and GetNumPartyMembers() > 0) then
		self.linkbutton:Show()
	else
		self.linkbutton:Hide()
	end
	--self:msg("Displaying at position: "..XLootFrame:GetLeft().." "..XLootFrame:GetTop());
	self.visible = true
	
	--Hopefully avoid non-looting/empty bar
	if self:AutoClose() then
		--self:msg("Possible hanger frame. Closing.. "..numLoot..", "..curshift)
	end
end

