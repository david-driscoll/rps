--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPWaitlist/Portfolio.lua
	* Component: Waitlist
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

local rpwlSettings

local function settingUpdate(name, value, isGUI, isUpdate)
	if not rpwlSettings then
		rpwlSettings = RPWL.db.realm.settings
	end
	--RPWL:Print(name, value, isGUI, isUpdate)
	local rvalue = nil
	if (rpwlSettings[name]) then
		rpwlSettings[name] = value
	end
end

local function settingInit(frame)
	frame:Refresh()
end

local Portfolio = LibStub and LibStub("Portfolio")
if not Portfolio then return end

function RPWL:RegisterPortfolio()
	if not rpwlSettings then
		rpwlSettings = RPWL.db.realm.settings
	end
	local optionTable = {
		id="RPWaitlist",
		text="Waitlist Settings",
		addon="RPWaitlist",
		parent="Raid Points System",
		savedVarTable = rpwlSettings,
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
				defaultValue = rpwlSettings["syncPassword"],
				init = function(frame) frame:SetPassword(); --[===[settingInit(frame)]===] end,
			},
			{
				id = "pushSettings",
				text = "Push Settings",
				type = CONTROLTYPE_BUTTON,
				callback = function(value, isGUI, isUpdate) RPWL:PushSettings(value, isGUI, isUpdate) end,
			},
			{
				id = "syncSettings",
				text = "Recieve Settings",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpwlSettings["syncSettings"],
				point = {"TOPLEFT", "pushSettings", "TOPRIGHT", 20, 0},
			},
			{
				id = "syncIn",
				text = "Enable Inbound",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpwlSettings["syncIn"],
				point = {"TOPLEFT", "pushSettings", "TOPLEFT", 0, -25},
				--dependentControls = {"syncSettings"}
			},
			{
				id = "syncOut",
				text = "Enable Outbound",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpwlSettings["syncOut"],
				--dependentControls = {"pushSettings"}
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
				defaultValue = rpwlSettings["filterIn"],
			},
			{
				id = "filterOut",
				text = "Enable Outbound Filter",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpwlSettings["filterOut"],
			},
		},
	}
	return Portfolio.RegisterOptionSet(optionTable)
end
