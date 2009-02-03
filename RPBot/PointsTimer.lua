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

local AceGUI = LibStub:GetLibrary("AceGUI-3.0")
local framebuilt = false

function RPB:CreateFramePointsTimer()

	self.frames["PointsTimer"] = CreateFrame("Frame", "RPBPointsTimer", UIParent)

	local f = self.frames["PointsTimer"]
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	--   f:SetResizeable(true)
	f:SetFrameStrata("HIGH")
	f:SetHeight(150)
	f:SetWidth(420)
	f:SetPoint("CENTER")
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
		title:SetText("Points Automation")
		f.title = title
	end

	local hour = {}
	local minute = {}
	for i=1,24 do
		if i < 10 then
			hour[i] = "0"..tostring(i)
		else
			hour[i] = tostring(i)
		end
	end
	for i=0,55,5 do
		if i < 10 then
			minute[i] = "0"..tostring(i)
		else
			minute[i] = tostring(i)
		end
	end
	
	f.dropdown = {}
	f.button = {}
	f.editbox = {}
	

	local editbox = CreateFrame("EditBox", nil, f)
	f.editbox["PointsAdd"] = editbox
	editbox:SetAutoFocus(false)
	editbox:SetHeight(32)
	editbox:SetWidth(50)
	editbox:SetNumeric()
	--editbox:SetScript("OnEnterPressed", function(self) end)
	editbox:SetPoint("TOPLEFT", f, "TOPLEFT", 60, -30)
	
	self:SkinEditBox(editbox)
	self:ScriptEditBox(editbox, true)	
	local font = f:CreateFontString("PointsAdd","OVERLAY","GameTooltipText")
	font:SetText("Points:")
	font:SetPoint("TOPRIGHT", f.editbox["PointsAdd"], "TOPLEFT", -8, -8)
	
	local editbox = CreateFrame("EditBox", nil, f)
	f.editbox["Reason"] = editbox
	editbox:SetAutoFocus(false)
	editbox:SetHeight(32)
	editbox:SetWidth(130)
	
	--editbox:SetScript("OnEnterPressed", function(self) end)
	editbox:SetPoint("TOPLEFT", f.editbox["PointsAdd"], "BOTTOMLEFT", 0, 10)
	
	self:SkinEditBox(editbox)
	self:ScriptEditBox(editbox, true)	
	local font = f:CreateFontString("Reason","OVERLAY","GameTooltipText")
	font:SetText("Reason:")
	font:SetPoint("TOPRIGHT", f.editbox["Reason"], "TOPLEFT", -8, -8)
	
	local button = CreateFrame("Button", f:GetName() .. "_ButtonAddPoints", f, "UIPanelButtonTemplate")
	button:SetWidth(90)
	button:SetHeight(21)
	button:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -84)
	button:SetText("Add Points")
	button:SetScript("OnClick", 
	function(self)
		local datetime = time()
		local value = tonumber(f.editbox["PointsAdd"]:GetText()) or 0
		local total = duration / interval
		local reason = ( f.editbox["Reason"]:GetText() or "" )
		if reason ~= "" then reason = "<blank>" end
		RPB:PointsAdd(self.rpoSettings.raid, datetime, 'all', value, 'P', 0, reason, false, true)
	end
	)
	f.button["AddPoints"] = button
	
		
	local button = CreateFrame("Button", f:GetName() .. "_ButtonMaster", f, "UIPanelButtonTemplate")
	button:SetWidth(90)
	button:SetHeight(21)
	button:SetPoint("TOP", f.button["AddPoints"], "BOTTOM", 0, -2)
	button:SetText("Master")
	button:SetScript("OnClick", 
	function(self)
		RPB:SetMaster()
	end
	)
	f.button["Master"] = button
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(hour)
	dropdown:SetWidth(60)
	dropdown:SetHeight(20)
	--dropdown:SetValue(18)
	dropdown:SetPoint("TOPRIGHT", f, "TOPRIGHT", -80, -40)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["RaidStartHour"] = dropdown
	local font = f:CreateFontString("StartTime","OVERLAY","GameTooltipText")
	font:SetText("Start Time:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(minute)
	dropdown:SetWidth(60)
	dropdown:SetHeight(20)
	--dropdown:SetValue(0)
	dropdown:SetPoint("TOPLEFT", f.dropdown["RaidStartHour"].frame, "TOPRIGHT", 6, 0)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["RaidStartMinute"] = dropdown	
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(hour)
	dropdown:SetWidth(60)
	dropdown:SetHeight(20)
	--dropdown:SetValue(22)
	dropdown:SetPoint("TOPLEFT", f.dropdown["RaidStartHour"].frame, "BOTTOMLEFT", 0, -6)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["RaidEndHour"] = dropdown
	local font = f:CreateFontString("EndTime","OVERLAY","GameTooltipText")
	font:SetText("End Time:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(minute)
	dropdown:SetWidth(60)
	dropdown:SetHeight(20)
	--dropdown:SetValue(0)
	dropdown:SetPoint("TOPLEFT", f.dropdown["RaidEndHour"].frame, "TOPRIGHT", 6, 0)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["RaidEndMinute"] = dropdown		
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(hour)
	dropdown:SetWidth(60)
	dropdown:SetHeight(20)
	--dropdown:SetValue(18)
	dropdown:SetPoint("TOPLEFT", f.dropdown["RaidEndHour"].frame, "BOTTOMLEFT", 0, -6)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["WaitlistCutoffHour"] = dropdown
	local font = f:CreateFontString("WaitlistCutoff","OVERLAY","GameTooltipText")
	font:SetText("Waitlist Cutoff:")
	font:SetPoint("TOPRIGHT", dropdown.frame, "TOPLEFT", -2, -8)
	
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.frame:SetParent(f)
	dropdown:SetList(minute)
	dropdown:SetWidth(60)
	dropdown:SetHeight(20)
	--dropdown:SetValue(0)
	dropdown:SetPoint("TOPLEFT", f.dropdown["WaitlistCutoffHour"].frame, "TOPRIGHT", 6, 0)
	dropdown:SetCallback("OnValueChanged", function(object, event, value, ...)
			RPB:AutomationTimeSet()
		end
	)
	f.dropdown["WaitlistCutoffMinute"] = dropdown	

	-- local editbox = CreateFrame("EditBox", nil, f)
	-- f.editbox["WaitlistPenalty"] = editbox
	-- editbox:SetAutoFocus(false)
	-- editbox:SetHeight(32)
	-- editbox:SetWidth(50)
	-- editbox:SetNumeric()
	----editbox:SetScript("OnEnterPressed", function(self) end)
	-- editbox:SetPoint("TOPLEFT", f.dropdown["WaitlistCutoffMinute"].frame, "BOTTOMLEFT", 8, -6)
	
	-- self:SkinEditBox(editbox)
	-- self:ScriptEditBox(editbox, true)	
	-- local font = f:CreateFontString("WaitlistPenalty","OVERLAY","GameTooltipText")
	-- font:SetText("Waitlist Penalty %:")
	-- font:SetPoint("TOPRIGHT", f.editbox["WaitlistPenalty"], "TOPLEFT", -10, -8)
	
	local button = CreateFrame("Button", f:GetName() .. "_ButtonStartTimer", f, "UIPanelButtonTemplate")
	button:SetWidth(60)
	button:SetHeight(21)
	button:SetPoint("TOPLEFT", f.dropdown["WaitlistCutoffHour"].frame, "BOTTOMLEFT", 0, -8)
	button:SetText("Start")
	button:SetScript("OnClick", 
	function(self)
		RPB:AutomationStartTimer()
	end
	)
	f.button["StartTimer"] = button
	
	local button = CreateFrame("Button", f:GetName() .. "_ButtonStopTimer", f, "UIPanelButtonTemplate")
	button:SetWidth(60)
	button:SetHeight(21)
	button:SetPoint("TOPLEFT", f.button["StartTimer"], "TOPRIGHT", 6, 0)
	button:SetText("Stop")
	button:SetScript("OnClick", 
	function(self)
		RPB:AutomationStopTimer()
	end
	)
	f.button["StopTimer"] = button
	
	framebuilt = true
	RPB:AutomationTimeGet()
end

function RPB:AutomationTimeSet(recieved)
	if framebuilt then
		local f = self.frames["PointsTimer"]
		local dt = date()
		local hour = f.dropdown["RaidStartHour"]
		local minute = f.dropdown["RaidStartMinute"]

		local timetable = 
		{
			year 	= tonumber("20"..string.sub(dt,7,8)),
			month 	= tonumber(string.sub(dt,1,2)),
			day 	= tonumber(string.sub(dt,4,5)),
			hour 	= tonumber(hour.value),
			min 	= tonumber(minute.value),
		}
		self.rpbSettings.automationRaidStart = time(timetable)

		hour = f.dropdown["WaitlistCutoffHour"]
		minute = f.dropdown["WaitlistCutoffMinute"]

		local incday = false
		if hour.value < f.dropdown["WaitlistCutoffHour"].value then
			if get_days_in_month(timetable.month, timetable.year) == timetable.day then
				timetable.month = timetable.month + 1
				if timetable.month > 12 then
					timetable.month = 1
				end
				 timetable.day = 1
			else
				timetable.day = timetable.day + 1
			end
			incday = true
		end
		timetable.hour = tonumber(hour.value)
		timetable.min = tonumber(minute.value)
		self.rpbSettings.automationWaitlistCutoff = time(timetable)
		
		hour = f.dropdown["RaidEndHour"]
		minute = f.dropdown["RaidEndMinute"]
		
		if not incday and hour.value < f.dropdown["RaidStartHour"].value then
			if get_days_in_month(timetable.month, timetable.year) == timetable.day then
				timetable.month = timetable.month + 1
				if timetable.month > 12 then
					timetable.month = 1
				end
				 timetable.day = 1
			else
				timetable.day = timetable.day + 1
			end
			incday = true
		end
		timetable.hour = tonumber(hour.value)
		timetable.min = tonumber(minute.value)
		self.rpbSettings.automationRaidEnd = time(timetable)
		
		-- if not recieved then
			-- self:Send(cs.automationset, {self.rpbSettings.automationRaidStart,self.rpbSettings.automationRaidEnd,self.rpbSettings.automationWaitlistCutoff})
		-- end
	end
end

function RPB:AutomationTimeGet()
	local f = self.frames["PointsTimer"]
	local hour = f.dropdown["RaidStartHour"]
	local minute = f.dropdown["RaidStartMinute"]

	local dt = date(nil, self.rpbSettings.automationRaidStart)
	--self:Print(dt)
	hour:SetValue(tonumber(string.sub(dt,10,11)))
	minute:SetValue(tonumber(string.sub(dt,13,14)))
	
	hour = f.dropdown["RaidEndHour"]
	minute = f.dropdown["RaidEndMinute"]
	dt = date(nil, self.rpbSettings.automationRaidEnd)
	--self:Print(dt)
	hour:SetValue(tonumber(string.sub(dt,10,11)))
	minute:SetValue(tonumber(string.sub(dt,13,14)))

	hour = f.dropdown["WaitlistCutoffHour"]
	minute = f.dropdown["WaitlistCutoffMinute"]
	
	dt = date(nil, self.rpbSettings.automationWaitlistCutoff)
	--self:Print(dt)
	hour:SetValue(tonumber(string.sub(dt,10,11)))
	minute:SetValue(tonumber(string.sub(dt,13,14)))
	RPB:AutomationUpdateUI()
end

function RPB:AutomationUpdateUI()
	local f = self.frames["PointsTimer"]
	if self.rpoSettings.master == UnitName("player") then
		f.button["Master"]:Disable()
		if self.rpbSettings.automationTimer then
			if not self.automationTimer then
				f.editbox["PointsAdd"]:SetText(self.rpbSettings.automationPoints or 0)
				f.editbox["Reason"]:SetText(self.rpbSettings.automationReason or "")
				RPB:AutomationStartTimer()
			end
			f.button["AddPoints"]:Disable()
			f.button["StartTimer"]:Disable()
			f.button["StopTimer"]:Enable()
			for k,v in pairs(f.editbox) do
				v:Disable()
				v:ClearFocus()
			end
			for k,v in pairs(f.dropdown) do
				v:SetDisabled(true)
			end
		else
			f.button["AddPoints"]:Enable()
			f.button["StartTimer"]:Enable()
			f.button["StopTimer"]:Disable()
			for k,v in pairs(f.editbox) do
				v:Enable()
			end
			for k,v in pairs(f.dropdown) do
				v:SetDisabled(false)
			end
		end
	else
		f.button["AddPoints"]:Disable()
		f.button["StartTimer"]:Disable()
		f.button["StopTimer"]:Disable()
		f.button["Master"]:Enable()
		for k,v in pairs(f.editbox) do
			v:Disable()
			v:ClearFocus()
		end
		for k,v in pairs(f.dropdown) do
			v:SetDisabled(true)
		end
	end
end

function RPB:AutomationStartTimer(recieved)
	local f = self.frames["PointsTimer"]
	self.rpbSettings.automationTimer = true
	RPB:AutomationTimeSet()
	self.rpbSettings.automationPoints = tonumber(f.editbox["PointsAdd"]:GetText()) or 0
	self.rpbSettings.automationReason = f.editbox["Reason"]:GetText() or ""
	RPB:AutomationTimer()
	self.automationTimer = self:ScheduleRepeatingTimer("AutomationTimer", 60)
	RPB:AutomationUpdateUI()
	if not recieved then
		self:Debug(msg[1], self.rpbSettings.automationRaidStart)
		self:Debug(msg[2], self.rpbSettings.automationRaidEnd)
		self:Debug(msg[3], self.rpbSettings.automationWaitlistCutoff)
		self:Debug(f.editbox["PointsAdd"]:GetText(), self.rpbSettings.automationPoints)
		self:Debug(f.editbox["Reason"]:GetText(), self.rpbSettings.automationReason)
		self:Send(cs.automationstart, {
			self.rpbSettings.automationRaidStart,
			self.rpbSettings.automationRaidEnd,
			self.rpbSettings.automationWaitlistCutoff,
			self.rpbSettings.automationPoints,
			self.rpbSettings.automationReason,
		})
	end
end

function RPB:AutomationTimer()
	if self.rpoSettings.master == UnitName("player") then
		local f = self.frames["PointsTimer"]
		self:Debug("AutomationTimer")
		
		local dt = date()
		local timetable = 
		{
			year 	= tonumber("20"..string.sub(dt,7,8)),
			month 	= tonumber(string.sub(dt,1,2)),
			day 	= tonumber(string.sub(dt,4,5)),
			hour 	= tonumber(string.sub(dt,10,11)),
			min 	= tonumber(string.sub(dt,13,14)),
		}
		local tme = time(timetable)
		if not self.rpbSettings.automationInterval then self.rpbSettings.automationInterval = 60 end
		local interval = tonumber(self.rpbSettings.automationInterval)*60
		local startTime = self.rpbSettings.automationRaidStart
		local endTime = self.rpbSettings.automationRaidEnd
		local duration = endTime - startTime
		local temp
		if tme >= endTime then
			RPB:AutomationStopTimer()
		end
		for temp=startTime,endTime,interval do
			if temp == tme then
				local datetime = time()
				local value = tonumber(self.rpbSettings.automationPoints) or 0
				local total = duration / interval
				local reason = ( self.rpbSettings.automationReason or "" )
				if reason ~= "" then reason = reason .. " " end
				reason = reason .. ((temp-startTime) / interval) .." / " .. total
				RPB:PointsAdd(self.rpoSettings.raid, datetime, 'all', value, 'P', 0, reason, false, true)
			end
		end
	end
end

function RPB:AutomationStopTimer(recieved)
	self:CancelTimer(self.automationTimer)
	self.rpbSettings.automationTimer = false
	self.automationTimer = nil
	RPB:AutomationUpdateUI()
	if not recieved then
		self:Send(cs.automationstop, "adf")
	end
end


RPB.syncCommands[cs.automationget] = function(self, msg, sender)
	local f = self.frames["PointsTimer"]
	if self.rpoSettings.master ~= UnitName("player") then return end
	self:Send(cs.automationset, {
		self.rpbSettings.automationTimer,
		self.rpbSettings.automationRaidStart,
		self.rpbSettings.automationRaidEnd,
		self.rpbSettings.automationWaitlistCutoff,
		self.rpbSettings.automationPoints,
		self.rpbSettings.automationReason,
	}, sender)
end

RPB.syncCommands[cs.automationset] = function(self, msg, sender)
	local f = self.frames["PointsTimer"]
	if sender == UnitName("player") then return end
	self.rpbSettings.automationTimer = msg[1]
	self.rpbSettings.automationRaidStart = msg[2]
	self.rpbSettings.automationRaidEnd = msg[3]
	self.rpbSettings.automationWaitlistCutoff = msg[4]
	self.rpbSettings.automationPoints = msg[5]
	self.rpbSettings.automationReason = msg[6]
	f.editbox["PointsAdd"]:SetText(msg[5] or "")
	f.editbox["Reason"]:SetText(msg[6] or "")
	RPB:AutomationTimeGet()
end

RPB.syncCommands[cs.automationstart] = function(self, msg, sender)
	local f = self.frames["PointsTimer"]
	if sender == UnitName("player") then return end
	self.rpbSettings.automationRaidStart = msg[1]
	self.rpbSettings.automationRaidEnd = msg[2]
	self.rpbSettings.automationWaitlistCutoff = msg[3]
	self.rpbSettings.automationPoints = msg[4]
	self.rpbSettings.automationReason = msg[5]
	self:Debug(msg[1], self.rpbSettings.automationRaidStart)
	self:Debug(msg[2], self.rpbSettings.automationRaidEnd)
	self:Debug(msg[3], self.rpbSettings.automationWaitlistCutoff)
	self:Debug(msg[4], self.rpbSettings.automationPoints)
	self:Debug(msg[5], self.rpbSettings.automationReason)
	f.editbox["PointsAdd"]:SetText(msg[4] or "")
	f.editbox["Reason"]:SetText(msg[5] or "")
	RPB:AutomationTimeGet()
	RPB:AutomationStartTimer(true)
end

RPB.syncCommands[cs.automationstop] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	RPB:AutomationTimeGet()
	RPB:AutomationStopTimer(true)
end
