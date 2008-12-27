--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision:  22
	* Project-Version:  r22
	* Last edited by:  sithy on  2008-12-24T05:51:45Z 
	* Last commit:  sithy on   2008-12-24T05:51:45Z 
	* Filename: GuildRoster/GuildRoster.lua
	* Component: Library
	* Details:
		This file deals with various functions that are shared between the RPBot and RPWaitlist.
		Skining, lib-st building primarily.
]]

-- Leverage SVN
--@alpha@
local MAJOR,MINOR = "GuildRoster-3.0", 1
--@end-alpha@. 
--[===[@non-alpha@
local MAJOR,MINOR = "GuildRoster-3.0", @file-revision@
--@end-non-alpha@]===]
local GuildRosterLib = LibStub:NewLibrary(MAJOR, MINOR)
if not GuildRosterLib then return end

GuildRosterLib.embeds = GuildRosterLib.embeds or {} -- what objects embed this lib

local lib = LibStub:GetLibrary("AceTimer-3.0")
lib:Embed(GuildRosterLib)
lib = LibStub:GetLibrary("AceBucket-3.0")
lib:Embed(GuildRosterLib)
lib = LibStub:GetLibrary("AceEvent-3.0")
lib:Embed(GuildRosterLib)

--- embedding and embed handling
local mixins = {
	"GuildRosterByName",
	"GuildRosterByUnit",
	"GuildRosterCount",
	"GuildRoster",
	"GuildRosterScan"
} 

guildRoster = {}

--- Event: GUILD_ROSTER_UPDATE.
-- Fires when the guild roster has been updated.
-- @param arg1 Unknown
function GuildRosterLib:GUILD_ROSTER_UPDATE(arg1)
	self:RosterUpdate(false)
end

--- Event: PLAYER_GUILD_UPDATE.
-- Fires when someone has left or been kicked
-- @param arg1 Unknown
function GuildRosterLib:PLAYER_GUILD_UPDATE(arg1)
	self:RosterUpdate(true)
end

--- Get the player information if it exists.
-- @param name Name of the player to find
function GuildRosterLib:GuildRosterByName(name)
	if guildRoster[string.lower(name)] then
		return guildRoster[string.lower(name)]
	end
end

--- Get the player information if it exists.
-- @param name Name of the player to find
function GuildRosterLib:GuildRosterByUnit(unit)
	local name = UnitName(unit)
	if guildRoster[string.lower(name)] then
		return guildRoster[string.lower(name)]
	else
		return nil
	end
end

--- Return the count of guildRoster
function GuildRosterLib:GuildRosterCount()
	return #guildRoster
end

--- Return guildRoster
function GuildRosterLib:GuildRoster()
	return guildRoster
end

--- Roster Update
-- Update the internal table with the current guild roster.
local rebuildOffline = true
function GuildRosterLib:RosterUpdate(rebuild)
	if rebuild or rebuildOffline then
		if not GetGuildRosterShowOffline() then
			SetGuildRosterShowOffline(true)
			rebuildOffline = true
		else
			rebuildOffline = false
		end
		for name, value in pairs(guildRoster) do
			guildRoster[name] = {}
		end
		guildRoster = {}
	end
	for i=1,GetNumGuildMembers(true) do
		name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
		if guildRoster[string.lower(name)] then
			local myRoster = guildRoster[string.lower(name)]
			myRoster["name"]		= name
			myRoster["rank"]		= rank
			myRoster["rankIndex"]	= rankIndex
			myRoster["level"]		= level
			myRoster["class"]		= class
			myRoster["zone"]		= zone
			myRoster["officernote"]	= officernote
			myRoster["online"]		= online
			myRoster["status"]		= status
		else
			guildRoster[string.lower(name)] = {
				["name"]		= name,
				["rank"]		= rank,
				["rankIndex"]	= rankIndex,
				["level"]		= level,
				["class"]		= class,
				["zone"]		= zone,
				["officernote"]	= officernote,
				["online"]		= online,
				["status"]		= status,
			}
		end
	end
	self:SendMessage("GuildRosterLib_Update")
end

function GuildRosterLib:GuildRosterScan()
	GuildRosterLib:RosterUpdate(true)
end

local roster = {}
GuildRosterLib:RegisterBucketEvent("GUILD_ROSTER_UPDATE", 1, "GUILD_ROSTER_UPDATE")
GuildRosterLib:RegisterBucketEvent("PLAYER_GUILD_UPDATE", 1, "PLAYER_GUILD_UPDATE")

function GuildRosterLib:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

--- Finally: upgrade our old embeds
for target, v in pairs(GuildRosterLib.embeds) do
	GuildRosterLib:Embed(target)
end
