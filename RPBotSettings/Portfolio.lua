--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/Portfolio.lua
	* Component: Core
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

local rpbSettings

local function settingUpdate(name, value, isGUI, isUpdate)
	if not rpbSettings then
		rpbSettings = RPBS.db.realm.settings
	end
	--RPWL:Print(name, value, isGUI, isUpdate)
	local rvalue = nil
	if (rpbSettings[name]) then
		rpbSettings[name] = value
	end
end

local function settingInit(frame)
	frame:Refresh()
end

local Portfolio = LibStub and LibStub("Portfolio")
if not Portfolio then return end

function RPBS:RegisterPortfolio()
	if not rpbSettings then
		rpbSettings = self.db.realm.settings
	end

	local broadcastDropDown = 
	{
		{
			text = "Auto",
			value = "AUTO",
		},
		{
			text = "Raid",
			value = "RAID",
		},
		{
			text = "Party",
			value = "PARTY",
		},
		{
			text = "Guild",
			value = "GUILD",
		},
		{
			text = "Chat",
			value = "PRINT",
		},
		{
			text = "Say",
			value = "SAY",
		}
	}
	
	local modeDropDown =
	{
		{
			text = "Web Based",
			value = "WEB",
		},
		{
			text = "Standalone",
			value = "STANDALONE",
		},
	}
	
	local optionTable = {
		id="RPBotSettings",
		text="Bot Settings",
		--addon="RPBotSettings",
		parent="Raid Points System",
		savedVarTable = rpbSettings,
		options = {
			{
				id = "modeHeader",
				text = "Database Settings",
				subText = "Show or Hide inbound or outbound whispers.",
				type = CONTROLTYPE_HEADER,
			},
			{
				id = "mode",
				headerText = "Mode",
				type = CONTROLTYPE_DROPDOWN,
				defaultValue = rpbSettings["mode"],
				menuList = modeDropDown,
				--callback = function(value, isGUI, isUpdate) if not isUpdate then RPB:UseDatabase(value) end end,
			},
			{
				id = "compress",
				text = "Compress",
				type = CONTROLTYPE_BUTTON,
				callback = function(value, isGUI, isUpdate) RPB:CompressDatabase(value, isGUI, isUpdate) end,
				point = {"TOPLEFT", "mode", "TOPRIGHT", 40, -6},
			},
			{
				id = "botHeader",
				text = "Bot Settings",
				subText = "Misc. settings.",
				type = CONTROLTYPE_HEADER,
				point = {nil, "mode", nil, nil, nil},
			},
			{
				id = "bidtime",
				text = "Bid Time",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["bidtime"],
				
			},
			{
				id = "lastcall",
				text = "Last Call Time",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["lastcall"],
				
			},
			{
				id = "broadcast",
				text = "Broadcast Channel",
				type = CONTROLTYPE_DROPDOWN,
				menuList = broadcastDropDown,
				defaultValue = rpbSettings["broadcast"],
				
			},
			{
				id = "rulesHeader",
				text = "Default Rules",
				subText = "Defaults for when the current rules set holds no specific value.",
				type = CONTROLTYPE_HEADER,
				point = {nil, "broadcast", nil, nil, nil},
			},
			-- {
				-- id = "maxclass",
				-- text = "Max Class Cost",
				-- type = CONTROLTYPE_EDITBOX,
				-- defaultValue = rpbSettings["maxclass"],
				
			-- },
			-- {
				-- id = "minclass",
				-- text = "Max Class Cost",
				-- type = CONTROLTYPE_EDITBOX,
				-- defaultValue = rpbSettings["minclass"],
				
			-- },
			-- {
				-- id = "maxnonclass",
				-- text = "Max Non-Class Cost",
				-- type = CONTROLTYPE_EDITBOX,
				-- defaultValue = rpbSettings["maxnonclass"],
				
			-- },
			-- {
				-- id = "minnonclass",
				-- text = "Min Non-Class Cost",
				-- type = CONTROLTYPE_EDITBOX,
				-- defaultValue = rpbSettings["maxnonclass"],
				
			-- },
			{
				id = "maxnonclass",
				text = "Max Cost",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["maxnonclass"],
				
			},
			{
				id = "minnonclass",
				text = "Min Cost",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["maxnonclass"],
				
			},
			{
				id = "maxpoints",
				text = "Max Points",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["maxpoints"],
				
			},
			{
				id = "allownegative",
				text = "Allow Negative Values",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpbSettings["allownegative"],
			},
			{
				id = "divisor",
				text = "Divisor",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["divisor"],
				
			},
			{
				id = "diff",
				text = "Roll Difference",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["diff"],
				
			},
			{
				id = "rounding",
				text = "Rounding",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["rounding"],
				
			},
			{
				id = "automationWaitlistPenalty",
				text = "Late Penalty (% off)",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["automationWaitlistPenalty"],
				
			},
			{
				id = "automationInterval",
				text = "Points Interval (minutes)",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["automationInterval"],
				
			},
		},
	}
	return Portfolio.RegisterOptionSet(optionTable)
end
