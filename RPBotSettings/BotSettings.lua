--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPBotSettings/BotSettings.lua
	* Component: Core
	* Details:
		This file contains the core of the RPBot. Handles start up, database initialization,
			database input and output.
]]

local db
RPBS = LibStub("AceAddon-3.0"):NewAddon("Raid Points Bot Settings")

--- Initial start up processes.
-- Register chat commands, minor events and setup AceDB
function RPBS:OnInitialize()
	-- Leverage SVN
	--@alpha@
	db = LibStub("AceDB-3.0"):New("rpDEBUGBotSettingsDB")
	--@end-alpha@. 
	--[===[@non-alpha@
	db = LibStub("AceDB-3.0"):New("rpBotSettingsDB", defaults, "Default")
	--@end-non-alpha@]===]
	self.db = db
	if not db.realm.settings then
		db.realm.settings = 
		{
			mode 			= "WEB",
			broadcast 		= "AUTO",
			bidtime 		= "30",
			lastcall	 	= "5",
			maxclass 		= "100",
			minclass 		= "50",
			maxnonclass 	= "100",
			minnonclass 	= "50",
			divisor 		= "2",
			diff 			= "50",
			allownegative 	= "1",
			rounding 		= "5",
		}
	end
	
	if not db.featureSets then
		db.featureSets = {}
		local featureSets = db.featureSets
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
				minclass = nil, -- Only override the value if its required by the feature
				maxclass = nil,
				minnonclass = nil,
				maxnonclass = nil,
				maxpoints = 50,
				divisor = nil,
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
				minclass = 50, -- Only override the value if its required by the feature
				maxclass = 50,
				minnonclass = 50,
				maxnonclass = 50,
				maxpoints = 50,
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
				minclass = 20, -- Only override the value if its required by the feature
				maxclass = 20,
				minnonclass = 20,
				maxnonclass = 20,
				maxpoints = 20,
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
function RPBS:OnEnable()
	self.options = self:RegisterPortfolio()
	self.options:refresh()
	
	--SetGuildRosterShowOffline(true)
	--self:Send("syncrequest", "to me")
	--enablecomm = false
	--AceComm:RegisterComm("wlupdate")
	
end
