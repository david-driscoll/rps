--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/Bot.lua
	* Component: Core
	* Details:
		This file contains the core of the RPBot. Handles start up, database initialization,
			database input and output.
]]

local db
local prefix = "<RPB>"
-- Leverage SVN
--@alpha@
local CommCmd = "rpbDEBUG"
--@end-alpha@. 
--[===[@non-alpha@
local CommCmd = "rpb"
--@end-non-alpha@]===]
local enablecomm = true
local syncrequest, syncowner, syncdone
local caninvite = false
local bidtime
local rollList
--LoadAddOn("RPLibrary")
--local RPLibrary = LibStub:GetLibrary("RPLibrary")

RPB = LibStub("AceAddon-3.0"):NewAddon("Raid Points Bot", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0", "RPLibrary", "GuildRoster-3.0", "Roster-3.0")
RPB.frames = {}

local function whisperFilter()
	local settings = RPB.settings
	if 		event == "CHAT_MSG_WHISPER_INFORM"
			and settings.filterOut == "1"
			and strfind(arg1, "^"..prefix)
	then
		return true
	elseif 	event == "CHAT_MSG_WHISPER"
			and settings.filterIn == "1"
			and (
				strfind(arg1, "^rp")
				or strfind(arg1, "^bonus")
				or strfind(arg1, "^upgrade")
				or strfind(arg1, "^offspec")
				or strfind(arg1, "^sidegrade")
				or strfind(arg1, "^rot")
			)
	then
		return true
	end
	return false
end

--- Initial start up processes.
-- Register chat commands, minor events and setup AceDB
function RPB:OnInitialize()
	-- Leverage SVN
	--@alpha@
	db = LibStub("AceDB-3.0"):New("rpDEBUGBotDB", defaults, "Default")
	--@end-alpha@. 
	--[===[@non-alpha@
	db = LibStub("AceDB-3.0"):New("rpbDB", defaults, "Default")
	--@end-non-alpha@]===]
	self.db = db
	self:RegisterChatCommand("rp", "ChatCommand")
	self:RegisterChatCommand("rpb", "ChatCommand")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", whisperFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", whisperFilter)
	self:RegisterComm(CommCmd)
	if not db.realm.version then
		--self.activeraid = nil
		db.realm.raid = {} 
		db.realm.recentloot = {}
		db.realm.version =
		{
			database, -- date and time downloaded from the website,
			lastaction, -- date and time the last action was taken
			lastloot, -- date and time last looted item was taken
		}
	end
	-- if not db.realm.settings then
		-- db.realm.settings = 
		-- {
			-- syncPassword	= "",
			-- syncSettings	= "1",
			-- syncIn			= "1",
			-- syncOut			= "1",
			-- filterIn		= "0",
			-- filterOut		= "1",
			-- raid 			= "di",
			----defaultRaid 	= "di",
			-- featureSet			= "deus",
			----defaultfeatureSet 	= "deus",
			-- broadcast 		= "AUTO",
			-- bidtime 		= "30",
			-- lastcall	 	= "5",
			-- maxclass 		= "100",
			-- minclass 		= "50",
			-- maxnonclass 	= "100",
			-- minnonclass 	= "50",
			-- divisor 		= "2",
			-- diff 			= "50",
			-- allownegative 	= "1",
			-- rounding 		= "5",
		-- }
	-- end
end

--- Enable processes
-- Register all events, setup inital state and load featureset
function RPB:OnEnable()
	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("START_LOOT_ROLL")
	--self:RegisterEvent("LOOT_SLOT_CLEARED")
	--self:RegisterEvent("LOOT_CLOSED")	
	--self:RegisterEvent("CANCEL_LOOT_ROLL")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("SpecialEvents_ItemLooted")
	self:RosterScan()
	self:GuildRosterScan()
	syncrequest = nil
	syncowner = nil
	syncdone = false
	self.activeraid = nil
	
	self.settings = RPBS.db.realm.settings
	self.feature = RPBS.feature
	self.options = RPBS.options
	-- self:AddFeatureSet(db.realm.settings.featureSet)
	
	-- self.options = self:RegisterPortfolio()
	-- self.options:refresh()
	
	--SetGuildRosterShowOffline(true)
	--self:Send("syncrequest", "to me")
	--enablecomm = false
	--AceComm:RegisterComm("wlupdate")
	
end

--- Event: CHAT_MSG_WHISPER.
-- Fires when any whisper has been recieved
-- param arg1 = Message received 
-- param arg2 = Author 
-- param arg3 = Language (or nil if universal, like messages from GM) (always seems to be an empty string; argument may have been kicked because whispering in non-standard language doesn't seem to be possible [any more?]) 
-- param arg6 = status (like "DND" or "GM") 
-- param arg7 = (number) message id (for reporting spam purposes?) (default: 0) 
-- param arg8 = (number) unknown (default: 0)
function RPB:CHAT_MSG_WHISPER()
	-- Fire our event off to our handler
	
	-- TODO: Hide or Show whispers depending on the state that whisper command comes back as.
	--		This will let us hide the whisper if settings tell us to.
	self:WhisperCommand(arg1, arg2)
end

function RPB:Send(cmd, data)
	if not enablecomm then return end
	self:SendCommMessage(CommCmd, self:Serialize(cmd,data), "GUILD")
end

function RPB:Message(channel, message, to)
	ChatThrottleLib:SendChatMessage("BULK", CommCmd, prefix.." "..message, channel, nil, to);
end

function RPB:Whisper(message, to)
	RPB:Message("WHISPER", message, to);
end

function RPB:Broadcast(message)
	local channel = self.settings.broadcast
	if channel == "AUTO" then
		if UnitInRaid("player") then
			channel = "RAID"
		elseif UnitInParty("player") then
			channel = "PARTY"
		elseif GetGuildInfo("player") then
			channel = "GUILD"
		else
			channel = "PRINT"
		end
	end

	if channel == "PRINT" then
		self:Print(prefix.." "..message)
	else
		self:Message(channel, message);
	end
end

function RPB:UseDatabase(database)
	if (database and db.realm.raid[string.lower(database)]) then
		self.settings.raid = string.lower(database)
		self.activeraid = db.realm.raid[string.lower(database)]
		self:Print("Now running database", string.lower(database))
		return true
	else
		self:Print("Database ",database,"does not exist!")
		return false
	end
end

function RPB:CreateDatabase(database)
	if database then
		db.realm.raid[string.lower(database)] = 
		{
		}
		self:Print("Database",database,"created!")
		db.realm.version.lastaction = time()
		RPBS:AddRaid(database)
		RPB:UseDatabase(database)
	end
end

function RPB:CreatePlayer(player)
	local pinfo = self:GuildRosterByName(player) or self:RosterByName(player)
	self.activeraid[string.lower(player)] = {
		id 				= -1,
		name 			= string.lower(pinfo.name) or string.lower(name),
		fullname 		= pinfo.name or player,
		class			= pinfo.class or "Unknown",
		rank			= pinfo.rank or "Unknown",
		gender			= "Unknown",
		race			= "Unknown",
		talent			= "Unknown",
		points			= 0,
		lifetime		= 0,
		recenthistory 	= {},
		recentactions 	= {},
	}
end

function RPB:GetPlayer(player, col)
	if self.activeraid and self.activeraid[string.lower(player)] then
		if col then
			return self.activeraid[string.lower(player)][col]
		else
			return self.activeraid[string.lower(player)]
		end
	end
	return nil
end

function RPB:SetPlayer(player, col, val)
	if self.activeraid and self.activeraid[string.lower(player)] then
		self.activeraid[string.lower(player)][col] = val
		return true
	end
	return false
end

function RPB:PlayerToArray(player, to)
	local list = {}
	if (player and type(player) == "string") then
		if player == "all" then
			local roster = self:Roster()
			for k, v in pairs(roster) do
				list[#list+1] = {
					name = v.name,
					waitlist = false
				}
			end
			if RPWL then
				local waitlist, cwl = RPWL:Waitlist()
				for i=1,#waitlist do
					list[#list+1] = {
						name = waitlist[i].cols[cwl.name].value,
						waitlist = true
					}
				end
			end
			-- Check if we are in a raid.
			-- If we are in a raid get raid contents
			-- Also get waitlist contents, only if in a raid.
		else
			playerlist = {}
			splitlist = { strsplit(",",player) }
			--self:Print(splitlist)
			for i=1,#splitlist do
				if (self.classList[string.lower(splitlist[i])]) then
					local class = self.classList[string.lower(splitlist[i])]
					local roster = self:Roster()
					for k, v in pairs(roster) do
						if v.class == class then
							list[#list+1] = {
								name = v.name,
								waitlist = false
							}
						end
					end
					if RPWL then
						local waitlist, cwl = RPWL:Waitlist()
						for i=1,#waitlist do
							if string.upper(waitlist[i].cols[cwl.class].value) == class then
								list[#list+1] = {
									name = waitlist[i].cols[cwl.name].value,
									waitlist = true
								}
							end
						end
					end
					-- Search raid for all of "class"
					-- Search waitlist for all of "class"
					-- Add to list
				elseif (string.lower(splitlist[i]) == "tier") then
					if to then
						local roster = self:Roster()
						if roster[to] then
							local tier = self.tierList[roster[to].class]
							for i=1,#tier do
								local class = tier[i]
								local roster = self:Roster()
								for k, v in pairs(roster) do
									if v.class == class then
										list[#list+1] = {
											name = v.name,
											waitlist = false
										}
									end
								end
								if RPWL then
									local waitlist, cwl = RPWL:Waitlist()
									for i=1,#waitlist do
										if string.upper(waitlist[i].cols[cwl.class].value) == class then
											list[#list+1] = {
												name = waitlist[i].cols[cwl.name].value,
												waitlist = true
											}
										end
									end
								end
							end
						end
					end
					-- Find player class
					-- Determine which tier they belong to.
					-- Search raid for all of those classes
					-- Search waitlist for all of those classes
					-- Add to list
				else
					--self:Print(splitlist[i])
					-- Assume this is a normal player, add them to the list.
					local wl = false
					if RPWL and RPWL:Check(splitlist[i]) then
						wl = true
					end
					list[#list+1] = {
						name = splitlist[i],
						waitlist = wl,
					}
				end
			end
		end
	end
	return list
end

function RPB:PointsAdd(datetime, player, value, ty, itemid, reason, waitlist, whisper, recieved)
	local playerlist = self:PlayerToArray(player);
	local playerdata
	if not reason then return nil end

	for i=1, #playerlist do
		--self:Print("Points Add For Loop",playerlist[i].name)
		if (not self.activeraid[string.lower(playerlist[i].name)]) then
			self:CreatePlayer(playerlist[i].name)
		end
		if not itemid or type(itemid) == string then
			_, _, itemid  = string.find(reason, "item:(%d+)");
			itemid = tonumber(itemid)
			--itemid = tonumber(string.gsub(reason,".*(item:%d+:%d+:%d+:%d+).*","%1"))
			if not itemid then
				itemid = 0
			end
		end
		self.activeraid[string.lower(playerlist[i].name)].recentactions[(#(self.activeraid[string.lower(playerlist[i].name)].recentactions)+1)] = {
			datetime 	= datetime,
			ty			= ty,
			itemid		= tonumber(itemid),
			reason		= reason,
			value		= tonumber(value),
			waitlist	= waitlist or playerlist[i].waitlist,
			action		= "Insert",
		}
		db.realm.version.lastaction = datetime
		if (whisper) then
			if (tonumber(value) > 0) then
				self:Whisper("Added "..value.." points for "..reason, playerlist[i].name)
			else
				self:Whisper("Deducted "..value.." points for "..reason, playerlist[i].name)
			end
		end
		self.activeraid[string.lower(playerlist[i].name)].points = self.activeraid[string.lower(playerlist[i].name)].points + tonumber(value)
		self.activeraid[string.lower(playerlist[i].name)].lifetime = self.activeraid[string.lower(playerlist[i].name)].lifetime + tonumber(value)
	end
end

function RPB:PointsRemove(datetime, player, actiontime, whisper, recieved)
	local playerlist
	-- If we're removing "all" this is a special case
	-- we want to remove all points, only in recentactions.
	if (player == "all") then
		playerlist = {}
		for name, value in pairs(self.activeraid) do
			playerlist[#playerlist+1] = { name = name, waitlist = false }
		end
	else
		playerlist = self:PlayerToArray(player)
	end
	local playerdata
	local found
	
	for i=1, #playerlist do
		found = false
		if (self.activeraid[string.lower(playerlist[i].name)]) then
			for j=1, #self.activeraid[string.lower(playerlist[i].name)].recentactions do
				if (self.activeraid[string.lower(playerlist[i].name)].recentactions[j].datetime == datetime) then
					found = true
					db.realm.version.lastaction = actiontime
					if (whisper) then
						if (whisper) then
							self:Whisper("Removed "..value.." points for "..reason, name)
						end
					end
					self.activeraid[string.lower(playerlist[i].name)].points = self.activeraid[string.lower(playerlist[i].name)].points - tonumber(self.activeraid[string.lower(playerlist[i].name)].recentactions[j].value)
					self.activeraid[string.lower(playerlist[i].name)].lifetime = self.activeraid[string.lower(playerlist[i].name)].lifetime - tonumber(self.activeraid[string.lower(playerlist[i].name)].recentactions[j].value)
					tremove(self.activeraid[string.lower(playerlist[i].name)].recentactions,j)
					break
				end
			end
			if (not found and player ~= "all") then
				for j=1, #self.activeraid[string.lower(playerlist[i].name)].recenthistory do
					if (self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].datetime == datetime) then
						self.activeraid[string.lower(playerlist[i].name)].recentactions[#((self.activeraid[string.lower(playerlist[i].name)].recentactions)+1)] = {
							datetime 	= self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].datetime,
							ty			= self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].ty,
							itemid		= self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].itemid,
							reason		= self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].reason,
							value		= self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].value,
							waitlist	= self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].waitlist,
							action	= "Delete",
						}
						db.realm.version.lastaction = actiontime
						if (whisper) then
							self:Whisper("Removed "..value.." points for "..reason, playerlist[i].name)
						end
						self.activeraid[string.lower(playerlist[i].name)].points = self.activeraid[string.lower(playerlist[i].name)].points - tonumber(self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].value)
						self.activeraid[string.lower(playerlist[i].name)].lifetime = self.activeraid[string.lower(playerlist[i].name)].lifetime - tonumber(self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].value)
						tremove(self.activeraid[string.lower(playerlist[i].name)].recenthistory,j)
						break
					end
				end
			end
		end
	end
end

function RPB:PointsUpdate(datetime, player, points, ty, itemid, reason, waitlist, actiontime, whisper, recieved)
	local playerlist
	-- If we're updating "all" this is a special case
	-- we want to update all points, only in recentactions.
	if (player == "all") then
		playerlist = {}
		for name, value in pairs(self.activeraid) do
			playerlist[#playerlist+1] = { name = name, waitlist = false }
		end
	else
		playerlist = self:PlayerToArray(player)
	end
	local playerdata
	local found
	
	for i=1, #playerlist do
		found = false
		if (self.activeraid[string.lower(playerlist[i].name)]) then
			for j=1, #self.activeraid[string.lower(playerlist[i].name)].recentactions do
				if (self.activeraid[string.lower(playerlist[i].name)].recentactions[j].datetime == datetime) then
					local oldvalue = self.activeraid[string.lower(playerlist[i].name)].recentactions[j].value
					self.activeraid[string.lower(playerlist[i].name)].recentactions[j] = {
						datetime 	= datetime,
						ty			= ty,
						itemid		= itemid,
						reason		= reason,
						value		= points,
						waitlist	= waitlist or playerlist[i].waitlist,
						action		= "Insert",
					}
					db.realm.version.lastaction = actiontime
					found = true
					if (whisper) then
						self:Whisper("Updated points for "..reason.." Old: "..oldvalue.." New: "..points, playerlist[i].name)
					end
					self.activeraid[string.lower(playerlist[i].name)].points = self.activeraid[string.lower(playerlist[i].name)].points - oldvalue + points
					self.activeraid[string.lower(playerlist[i].name)].lifetime = self.activeraid[string.lower(playerlist[i].name)].lifetime - oldvalue + points
					break
				end
			end
			if (not found and player ~= "all") then
				for j=1, #self.activeraid[string.lower(playerlist[i].name)].recenthistory do
					if (self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].datetime == datetime) then
						local oldvalue = self.activeraid[string.lower(playerlist[i].name)].recenthistory[j].value
						self.activeraid[string.lower(playerlist[i].name)].recenthistory[j] = {
							datetime 	= datetime,
							ty			= ty,
							itemid		= itemid,
							reason		= reason,
							value		= value,
							waitlist	= waitlist or playerlist[i].waitlist,
							action	= "Update",
						}
						db.realm.version.lastaction = actiontime
						if (whisper) then
							self:Whisper("Updated points for "..reason.." Old: "..oldvalue.." New: "..points, playerlist[i].name)
						end
						self.activeraid[string.lower(playerlist[i].name)].points = self.activeraid[string.lower(playerlist[i].name)].points - oldvalue + points
						self.activeraid[string.lower(playerlist[i].name)].lifetime = self.activeraid[string.lower(playerlist[i].name)].lifetime - oldvalue + points
						break
					end
				end
			end
		end
	end
end

function RPB:CalculateLoss(points, cmd)
	local feature = self.feature[cmd]
	-- Make this loaclizable, for generic changes.
	local divisor = tonumber(feature.divisor) or tonumber(self.settings.divisor)
	-- local minclass = feature.minclass or db.realm.settings.minclass
	-- local maxclass = feature.maxclass or db.realm.settings.maxclass
	local minnonclass = tonumber(feature.minnonclass) or tonumber(self.settings.minnonclass)
	local maxnonclass = tonumber(feature.maxnonclass) or tonumber(self.settings.maxnonclass)
	local loss
	
	current = ceil( ( points / divisor ) / tonumber(self.settings.rounding) ) * tonumber(self.settings.rounding)

	-- If I want to continue with class specific item logic, this is where we do it.
	if (current < minnonclass) then
		loss = minnonclass
	elseif (current > minnonclass and (not maxnonclass or current < maxnonclass)) then
		loss = current
	else
		loss = maxnonclass
	end

	if (current > 0 and loss > current and not tonumber(self.settings.allownegative)) then
		loss = current
	end
	
	return loss
end

function RPB:PointsShow(player, channel, to, history)
	local playerlist = self:PlayerToArray(player, to);
	local playerdata
	
	if (#playerlist == 0) then
		if not to then return end
		playerlist = self:PlayerToArray(string.lower(to));
	end
	
	for i=1, #playerlist do
		local wait = ""
		if playerlist[i].waitlist then
			wait = "{star}"
		end
		msg = wait .. self:GetPlayer(playerlist[i].name,"fullname") .. ": " .. self:GetPlayer(playerlist[i].name,"points")
		if not channel then
			self:Print(msg)
		elseif not to then
			RPB:Message(channel, msg)
		else
			RPB:Whisper(msg, to)
		end
	end
end

function RPB:ChatCommand(msg)
	if (not self.activeraid) then
		if (not self:UseDatabase(self.settings.raid)) then
			self:CreateDatabase(self.settings.raid)
		end
	end

	-- Get our arguements, any ones not in the command are returned as nil
	local cmd, pos = self:GetArgs(msg, 1, 1)
	--self:Print(cmd, pos)
	if cmd and self.chatCommands[string.lower(cmd)] then
		self.chatCommands[string.lower(cmd)](self, msg)
	else
		self.chatCommands["help"](self)
	end
end

RPB.chatCommands = {}
RPB.chatCommands["use"] = function (self, msg)
-- args[1] - database
	local _, database, pos = self:GetArgs(msg, 2, 1)
	self:UseDatabase(database)
end

RPB.chatCommands["create"] = function (self, msg)
-- args[1] - database
	local _, database, pos = self:GetArgs(msg, 2, 1)
	self:CreateDatabase(database)
end

RPB.chatCommands["roll"] = function (self, msg)
	if (not self.frames["RollWindow"]) then
		self:CreateFrameRollWindow()
	end
	self.frames["RollWindow"]:Show()
end

RPB.chatCommands["add"] = function (self, msg)
	local _, value, player, reason, wl, pos = self:GetArgs(msg, 5, 1)
	--playerlist = RPB:PlayerToArray(player)
	datetime = time()
	wl = wl or false
	RPB:PointsAdd(datetime, player, value, 'P', 0, reason, wl, true)
end

RPB.chatCommands["additem"] = function (self, msg)
	local _, points, player, reason, pos = self:GetArgs(msg, 4, 1)
	--playerlist = RPB:PlayerToArray(player)
	local itemid = RPB:GetItemid(reason) or 0
	datetime = time()
	wl = wl or false
	RPB:PointsAdd(datetime, playerlist, value, 'I', itemid, reason, wl, true)
end

RPB.chatCommands["show"] = function (self, msg)
	_, player, history, pos = self:GetArgs(msg, 3, 1)
	self:PointsShow(player, nil, nil, history)
end

RPB.chatCommands["force"] = function (self, msg)
	_, player, cmd, pos = self:GetArgs(msg, 3, 1)
	self:RollListAdd(player, cmd)
end

RPB.chatCommands["?"] = function (self, msg)
	RPB:Print("help stuff")
end
RPB.chatCommands["help"] = RPB.chatCommands["?"]

--- chatCommand: Settings.
-- Opens the settings frame.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPB.chatCommands["settings"] = function (self, msg)
	InterfaceOptionsFrame_OpenToCategory(self.options)
end
RPB.chatCommands["options"] = RPB.chatCommands["settings"]

function RPB:WhisperCommand(msg, name)
	wcmd, pos = self:GetArgs(msg, 2, 1)
	-- Check to make sure the first line was "wl", otherwise this message isnt for us and we need to ignore it.
	if (string.lower(wcmd) == "bonus" or
		string.lower(wcmd) == "upgrade" or
		string.lower(wcmd) == "offspec" or
		string.lower(wcmd) == "sidegrade" or
		string.lower(wcmd) == "rot")
	then
		cmd = wcmd
		wcmd = "rp"
		--self:Print(cmd)
	elseif (string.lower(wcmd) == "rp") then
		wcmd, cmd, pos = self:GetArgs(msg, 2, 1)
	end
	if (string.lower(wcmd) ~= "rp") then return false end
	
	if cmd and self.whisperCommands[string.lower(cmd)] then
		if (not self.activeraid) then
			self:UseDatabase(self.settings.raid)
		end
		self.whisperCommands[string.lower(cmd)](self, msg, name)
	else
		self.whisperCommands["help"](self, msg, name)
	end
	return true
end

RPB.whisperCommands = {}
RPB.whisperCommands["show"] = function (self, msg, name)
	_, _, player, history = self:GetArgs(msg, 4, 1)
	self:PointsShow(player, "WHISPER", name, history)
end

RPB.whisperCommands["?"] = function (self, msg, name)
	-- Help topics, how to, etc, etc.
end
RPB.whisperCommands["help"] = RPB.whisperCommands["?"]

local cs =
{
	rolllistadd		= "rla",
	rolllistremove	= "rlr",
	pointsadd		= "pa",
	pointsremove	= "pr",
	pointsupdate	= "pu",
	loot			= "lt",
	database		= "db",
	master			= "m",
	logon			= "lo",
}

function RPB:SyncCommand()

end

function RPB:OnCommReceived(pre, message, distribution, sender)
	success, cmd, msg = self:Deserialize(message)
	--self:Print(pre, cmd, cansenderinvite, msg, distribution, sender)
	if not cmd then return end
	if cmd and self.syncCommands[string.lower(cmd)] then
		if (not self.activeraid) then
			self:UseDatabase(self.settings.raid)
		end
		self.syncCommands[string.lower(cmd)](msg, sender)
	end	
end

RPB.syncCommands = {}
RPB.syncCommands["add"] = function (self, from, datetime, player, points, ty, itemid, reason, waitlist)

end

RPB.syncCommands["remove"] = function (self, from, datetime, player)

end

RPB.syncCommands["update"] = function (self, from, datetime, player, points, ty, itemid, reason, waitlist)

end

RPB.syncCommands["loot"] = function (self, from, datetime, player, itemid)

end

RPB.syncCommands["show"] = function (self, from, player, history)

end

function RPB:ViewPoints()
	-- If Master, call data from table
	-- If Client, call sync points
end

function RPB:ViewHistory()
	-- If Master, call data from table
	-- If Client, call sync history
end

