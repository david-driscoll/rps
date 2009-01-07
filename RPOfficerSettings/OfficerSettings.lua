--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPClientSettings/ClientSettings.lua
	* Component: Core
	* Details:
		This file contains the core of the RPBot. Handles start up, database initialization,
			database input and output.
]]

local db
RPOS = LibStub("AceAddon-3.0"):NewAddon("Raid Points Officer Settings")

--- Initial start up processes.
-- Register chat commands, minor events and setup AceDB
function RPOS:OnInitialize()
	-- Leverage SVN
	--@alpha@
	db = LibStub("AceDB-3.0"):New("rpDEBUGOfficerSettingsDB")
	--@end-alpha@. 
	--[===[@non-alpha@
	db = LibStub("AceDB-3.0"):New("rpOfficerSettingsDB", defaults, "Default")
	--@end-non-alpha@]===]
	self.db = db
	if not db.realm.settings then
		db.realm.settings  = 
		{
			syncPassword	= "",
			syncSettings	= "1",
			syncIn			= "1",
			syncOut			= "1",
			filterIn		= "0",
			filterOut		= "1",
			raid 			= "di",
			featureSet		= "deus",
			raidDropDown	= {},
			dbinfo			= {},
			versioninfo		= {},
		}
	end
	if not db.realm.settings.featureSet or db.realm.settings.featureSet == "" then
		db.realm.settings.featureSet = "deus"
	end
	if not db.realm.settings.dbinfo then
		db.realm.settings.dbinfo = {}
	end
	if not db.realm.settings.raidDropDown then
		db.realm.settings.raidDropDown = 
		{
			{
				text = "di",
				value = "di",
			},
		}
	end
	if not db.realm.featureSets then
		db.realm.featureSets = {}
		local featureSets = db.realm.featureSets
		featureSets["deus"] = 
		{
			["name"]		= "Deus Invictus",
			["description"] = "Deus Invictus - Default Rule Set",
			["bonus"] = 
			{
				name = "Bonus",
				button = 
				{
					name = "Bonus",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Bonus",
				},
				command = "bonus",
				minclass = 25, -- Only override the value if its required by the feature
				maxclass = 50,
				minnonclass = 25,
				maxnonclass = 50,
				--maxpoints = 50,
				divisor = 2,
				diff = 50,
				totalpoints = nil,
				color = nil,
				bgcolor = nil,
				nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
			},
			["upgrade"] = 
			{
				name = "Upgrade",
				command = "upgrade",
				button = 
				{
					name = "Upgrade",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Upgrade",
				},
				minclass = 25, -- Only override the value if its required by the feature
				maxclass = 25,
				minnonclass = 25,
				maxnonclass = 25,
				--maxpoints = 50,
				divisor = 2,
				diff = 50,
				color = nil,
				bgcolor = nil,
				nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
			},
			["offspec"] = 
			{
				name = "Offspec",
				command = "offspec",
				button = 
				{
					name = "Offspec",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Offspec",
				},
				minclass = 0, -- Only override the value if its required by the feature
				maxclass = 0,
				minnonclass = 0,
				maxnonclass = 0,
				maxpoints = 0,
				divisor = 2,
				diff = 50,
				color = nil,
				bgcolor = nil,
				nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
			},
			["sidegrade"] = 
			{
				name = "Sidegrade",
				command = "sidegrade",
				button = 
				{
					name = "Sidegrade",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Sidegrade",
				},
				minclass = 10, -- Only override the value if its required by the feature
				maxclass = 10,
				minnonclass = 10,
				maxnonclass = 10,
				maxpoints = 10,
				divisor = 2,
				diff = 50,
				color = nil,
				bgcolor = nil,
				nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
			},
		}
		featureSets["deus"]["rot"] = featureSets["deus"]["sidegrade"]

		featureSets["nikarma"] = 
		{
			["name"]		= "Ni Karma",
			["description"] = "Ni Karma - Default Rule Set",
			["bonus"] = 
			{
				name = "Bonus",
				button = 
				{
					name = "Bonus",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Bonus",
				},
				command = "bonus",
				minclass = nil, -- Only override the value if its required by the feature
				maxclass = nil,
				minnonclass = nil,
				maxnonclass = nil,
				divisor = nil,
				diff = nil,
				totalpoints = nil,
				color = nil,
				bgcolor = nil,
				nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
			},
			["nobonus"] = 
			{
				name = "Upgrade",
				command = "upgrade",
				button = 
				{
					name = "Upgrade",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Upgrade",
				},
				minclass = 50, -- Only override the value if its required by the feature
				maxclass = 50,
				minnonclass = 50,
				maxnonclass = 50,
				maxpoints = 50,
				divisor = 2,
				diff = nil,
				color = nil,
				bgcolor = nil,
				nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
			},
		}
	
	end
end

--- Enable processes
-- Register all events, setup inital state and load featureset
function RPOS:OnEnable()
	self.options = self:RegisterPortfolio()
	self.options:refresh()
	db.realm.settings.master = ""
	--SetGuildRosterShowOffline(true)
	--self:Send("syncrequest", "to me")
	--enablecomm = false
	--AceComm:RegisterComm("wlupdate")
	self:AddFeatureSet(db.realm.settings.featureSet)
	
end

function RPOS:AddRaid(raid)
	db.realm.settings.raidDropDown[#db.realm.settings.raidDropDown+1] = {text = raid, value = raid}
end

function RPOS:PushSettings()
	if RPB then
		RPB:Send("set", db.realm.settings)
		RPB:PushSettings()
	elseif RPWL then
		RPWL:Send("set", db.realm.settings)
	end
end

function RPOS:ChangePassword()
	if RPB then
		RPB.rpoSettings.master = ""
		RPB:Send("getmaster")
		if not self.masterTimer then
			RPB.masterTimer = RPB:ScheduleTimer("GetMaster", 10)
		end
	end
end
