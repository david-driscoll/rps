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
			maxpoints	 	= "0",
			divisor 		= "2",
			diff 			= "50",
			allownegative 	= "1",
			rounding 		= "5",
			automationRaidStart = 0,
			automationRaidEnd = 0,
			automationWaitlistCutoff = 0,
			automationWaitlistPenalty = "0",
			automationInterval = "60",
		}
	end
end

--- Enable processes
-- Register all events, setup inital state and load rulesset
function RPBS:OnEnable()
	self.options = self:RegisterPortfolio()
	self.options:refresh()
	
	--SetGuildRosterShowOffline(true)
	--self:Send("syncrequest", "to me")
	--enablecomm = false
	--AceComm:RegisterComm("wlupdate")
	
end
