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
			raidDropDown	= {},
			dbinfo			= {},
			versioninfo		= {},
		}
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
end

--- Enable processes
-- Register all events, setup inital state and load rulesset
function RPOS:OnEnable()
	self.options = self:RegisterPortfolio()
	self.options:refresh()
	db.realm.settings.master = ""
	--SetGuildRosterShowOffline(true)
	--self:Send("syncrequest", "to me")
	--enablecomm = false
	--AceComm:RegisterComm("wlupdate")
	
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
