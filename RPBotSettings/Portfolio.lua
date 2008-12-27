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
	
	local featureDropDown = {}
	for k,v in pairs(self.db.featureSets) do
		-- if self.currentFeature == k then
			
		-- end
		featureDropDown[#featureDropDown+1] = 
		{
			text = v.name,
			value = k,
		}
	end
		
	local raidDropDown = self.db.realm.settings.raidDropDown
	
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
	
	local optionTable = {
		id="RPBotSettings",
		text="Bot Settings",
		addon="RPBotSettings",
		parent="Raid Points System",
		savedVarTable = rpbSettings,
		options = {
			{
				id = "syncHeader",
				text = "Synchronization Settings",
				subText = "Show or Hide inbound or outbound whispers.",
				type = CONTROLTYPE_HEADER,
			},
			{
				id = "syncPassword",
				text = "Password",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["syncPassword"],
				init = function(frame) frame:SetPassword(); --[===[settingInit(frame)]===] end,
			},
			{
				id = "pushSettings",
				text = "Push Settings",
				type = CONTROLTYPE_BUTTON,
				callback = function(value, isGUI, isUpdate) RPB:PushSettings(value, isGUI, isUpdate) end,
			},
			{
				id = "syncSettings",
				text = "Recieve Settings",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpbSettings["syncSettings"],
				point = {"TOPLEFT", "pushSettings", "TOPRIGHT", 20, 0},
			},
			{
				id = "syncIn",
				text = "Enable Inbound",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpbSettings["syncIn"],
				point = {"TOPLEFT", "pushSettings", "TOPLEFT", 0, -40},
				--dependentControls = {"syncSettings"},
			},
			{
				id = "syncOut",
				text = "Enable Outbound",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpbSettings["syncOut"],
				--dependentControls = {"pushSettings"},
			},
			{
				id = "whisperHeader",
				text = "Whisper Settings",
				subText = "Show or Hide inbound or outbound whispers.",
				type = CONTROLTYPE_HEADER,
				point = {nil, "syncOut", nil, nil, nil},
			},
			{
				id = "filterIn",
				text = "Enable Inbound Filter",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpbSettings["filterIn"],
			},
			{
				id = "filterOut",
				text = "Enable Outbound Filter",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpbSettings["filterOut"],
			},
			{
				id = "botHeader",
				text = "Bot Settings",
				subText = "Misc. settings.",
				type = CONTROLTYPE_HEADER,
				point = {nil, "filterOut", nil, nil, nil},
			},
			{
				id = "raid",
				headerText = "Current Raid",
				type = CONTROLTYPE_DROPDOWN,
				defaultValue = rpbSettings["raid"],
				menuList = raidDropDown,
				callback = function(value, isGUI, isUpdate) if not isUpdate then RPB:UseDatabase(value) end end,
			},
			{
				id = "featureSet",
				headerText = "Current Feature Set",
				type = CONTROLTYPE_DROPDOWN,
				defaultValue = rpbSettings["featureSet"],
				menuList = featureDropDown,
				callback = function(value, isGUI, isUpdate) if not isUpdate then RPBS:RemoveFeatureSet(rpbSettings["featureSet"]); RPBS:AddFeatureSet(value) end end,
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
				subText = "Defaults for when the current feature set holds no specific value.",
				type = CONTROLTYPE_HEADER,
				point = {nil, "broadcast", nil, nil, nil},
			},
			{
				id = "maxclass",
				text = "Max Class Cost",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["maxclass"],
				
			},
			{
				id = "minclass",
				text = "Max Class Cost",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["minclass"],
				
			},
			{
				id = "maxnonclass",
				text = "Max Non-Class Cost",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["maxnonclass"],
				
			},
			{
				id = "minnonclass",
				text = "Min Non-Class Cost",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpbSettings["maxnonclass"],
				
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
		},
	}
	return Portfolio.RegisterOptionSet(optionTable)
end
