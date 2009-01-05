--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPClient/Portfolio.lua
	* Component: Core
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

local rpoSettings

local function settingUpdate(name, value, isGUI, isUpdate)
	if not rpoSettings then
		rpoSettings = RPOS.db.realm.settings
	end
	--RPWL:Print(name, value, isGUI, isUpdate)
	local rvalue = nil
	if (rpoSettings[name]) then
		rpoSettings[name] = value
	end
end

local function settingInit(frame)
	frame:Refresh()
end

local Portfolio = LibStub and LibStub("Portfolio")
if not Portfolio then return end

function RPOS:RegisterPortfolio()
	if not rpoSettings then
		rpoSettings = self.db.realm.settings
	end
	
	local featureDropDown = {}
	for k,v in pairs(self.db.realm.featureSets) do
		-- if self.currentFeature == k then
			
		-- end
		featureDropDown[#featureDropDown+1] = 
		{
			text = v.name,
			value = k,
		}
	end
		
	self.db.realm.settings.raidDropDown = {}
	local raidDropDown = self.db.realm.settings.raidDropDown
	
	local optionTable = {
		id="RPClientSettings",
		text="Client Settings",
		--addon="RPClientSettings",
		parent="Raid Points System",
		savedVarTable = rpoSettings,
		options = {
			{
				id = "syncHeader",
				text = "Synchronization Settings",
				subText = "Show or Hide inbound or outbound whispers.",
				type = CONTROLTYPE_HEADER,
			},
			{
				id = "syncPassword",
				text = "Officer Password",
				type = CONTROLTYPE_EDITBOX,
				defaultValue = rpoSettings["syncPassword"],
				init = function(frame) frame:SetPassword(); --[===[settingInit(frame)]===] end,
				callback = function(value, isGUI, isUpdate) if not isUpdate then RPOS:ChangePassword(); end end,
			},
			{
				id = "syncSettings",
				text = "Recieve Settings",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpoSettings["syncSettings"],
			},
			{
				id = "pushSettings",
				text = "Push Settings",
				type = CONTROLTYPE_BUTTON,
				callback = function(value, isGUI, isUpdate) RPOS:PushSettings(value, isGUI, isUpdate) end,
				point = {"TOPLEFT", "syncSettings", "TOPRIGHT", 100, 0},
			},
			{
				id = "syncIn",
				text = "Enable Inbound",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpoSettings["syncIn"],
				point = {nil, "syncSettings", nil, nil, nil},
				--dependentControls = {"syncSettings"},
			},
			{
				id = "syncOut",
				text = "Enable Outbound",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpoSettings["syncOut"],
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
				defaultValue = rpoSettings["filterIn"],
			},
			{
				id = "filterOut",
				text = "Enable Outbound Filter",
				type = CONTROLTYPE_CHECKBOX,
				defaultValue = rpoSettings["filterOut"],
			},
			{
				id = "settingsHeader",
				text = "Settings",
				subText = "Misc. settings.",
				type = CONTROLTYPE_HEADER,
				point = {nil, "filterOut", nil, nil, nil},
			},
			{
				id = "raid",
				headerText = "Current Raid",
				type = CONTROLTYPE_DROPDOWN,
				defaultValue = rpoSettings["raid"],
				menuList = raidDropDown,
				callback = function(value, isGUI, isUpdate) if not isUpdate then RPB:UseDatabase(value) end end,
			},
			{
				id = "featureSet",
				headerText = "Current Feature Set",
				type = CONTROLTYPE_DROPDOWN,
				defaultValue = rpoSettings["featureSet"],
				menuList = featureDropDown,
				callback = function(value, isGUI, isUpdate) if not isUpdate then RPOS:RemoveFeatureSet(); RPOS:AddFeatureSet(value) end end,
			},
		}
	}
	return Portfolio.RegisterOptionSet(optionTable)
end
