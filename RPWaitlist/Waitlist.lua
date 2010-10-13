--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPWaitlist/Waitlist.lua
	* Component: Waitlist
	* Details:
		Waitlist portion of the mod.
		The guild roster update needs to be changed a little bit, it is kind of
			forceful in its ways.  It should also be moved into its own library
			or moved to RPLibrary
]]

local db
local prefix = "<WL>"
-- Leverage SVN
--@alpha@
local CommCmd = "rpwlDEBUG"
--@end-alpha@. 
--[===[@non-alpha@
local CommCmd = "rpwl"
--@end-non-alpha@]===]
local syncrequest, syncowner, syncdone 
local rosterupdate
local minRank = 2
--local RPLibrary = LibStub:GetLibrary("RPLibrary")

RPWL = LibStub("AceAddon-3.0"):NewAddon("Raid Points Waitlist", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "RPLibrary", "GuildLib", "BLib")
local MDFive = LibStub:GetLibrary("MDFive-1.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local EncodeTable

local function MD5(data)
	return MDFive:MD5(data)
end

-- Local Table Constants
-- To use the grid properly, we need numbered index's.
-- Numbered index's aren't very specific, so lets get the best of both worlds

-- Watilist table constents
local cwl = RPSConstants.stConstants["Waitlist"]
local cwlArg = RPSConstants.stArgs["Waitlist"]

-- Guild Roster table contents
local cgr = RPSConstants.stConstants["Roster"]
local cgrArg = RPSConstants.stArgs["Roster"]

-- Sync commands, lets save some overhead
local cs = RPSConstants.syncCommands["Waitlist"]

local function whisperFilter(self, event, ...)
	local settings = RPWL.rpoSettings
	local arg1, arg2 = ...;
	if 		event == "CHAT_MSG_WHISPER_INFORM"
			and settings.filterOut == "1"
			and strfind(arg1, "^"..prefix) then
		return true
	elseif 	event == "CHAT_MSG_WHISPER"
			and settings.filterIn == "1"
			and strfind(arg1, "^wl") then
		return true
	end
	return false
end

function RPWL:Debug(...)
	if self.debugOn then
		self:Print(...)
	end
end

--- Initial start up processes.
-- Register chat commands, minor events and setup AceDB
function RPWL:OnInitialize()
	-- Leverage SVN
	--@alpha@
	db = LibStub("AceDB-3.0"):New("rpDEBUGWaitlistDB")
	--@end-alpha@. 
	--[===[@non-alpha@
	db = LibStub("AceDB-3.0"):New("rpwaitlistDB", defaults, "Default")
	--@end-non-alpha@]===]
	self.db = db
	if SlashCmdList["WOWHEAD_LOOTER"] then
		SLASH_WOWHEAD_LOOTER1 = "/whl"
	end
	self:RegisterChatCommand("wl", "ChatCommand")
	self:RegisterChatCommand("rpwl", "ChatCommand")
	if not db.realm.waitlist then
		db.realm.waitlist = {}
	end
	self.debugOn = false
end

--- Enable processes
-- Register all events, setup inital state
function RPWL:OnEnable()
	self:RegisterEvent("CHAT_MSG_WHISPER")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", whisperFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", whisperFilter)
	self:RegisterMessage("GuildLib_Update")
	self:RegisterComm(CommCmd)
	self:RegisterComm(CommCmd.."LC")
	self:RegisterComm("rpos")
	syncrequest = nil
	syncowner = nil
	syncdone = false
	rosterupdate = true
	local guildname, _, gr = GetGuildInfo("player")
	-- if (not (gr <= minRank)) then
		-- enablecomm = false
	-- end
	--self.guildRoster = {}
	self.guildRosterIndex = {}
	EncodeTable = LibCompress:GetAddonEncodeTable()
	
	db.realm.waitlist = self:StripTable(db.realm.waitlist)
	local temp = db.realm.waitlist
	temp = self:BuildTable(temp, cwlArg, CheckOnline)
	db.realm.waitlist = temp
	
	self.options = self:RegisterPortfolio()
	self.options:refresh()
	
	self.rpoSettings = RPOS.db.realm.settings
	SetGuildRosterShowOffline(true)
	self:Send(cs.syncrequest, "to me")
	
	
	--enablecomm = false
	--AceComm:RegisterComm("wlupdate")
end

--- Event: GuildRosterLib_Update.
-- Fires when the guild roster has been updated.
-- @param arg1 Unknown
function RPWL:GuildLib_Update(arg1)
	RPWL:RosterUpdate()
end

--- Event: CHAT_MSG_WHISPER.
-- Fires when any whisper has been recieved
-- param arg1 = Message received 
-- param arg2 = Author 
-- param arg3 = Language (or nil if universal, like messages from GM) (always seems to be an empty string; argument may have been kicked because whispering in non-standard language doesn't seem to be possible [any more?]) 
-- param arg6 = status (like "DND" or "GM") 
-- param arg7 = (number) message id (for reporting spam purposes?) (default: 0) 
-- param arg8 = (number) unknown (default: 0)
function RPWL:CHAT_MSG_WHISPER(event, ...)
	-- Fire our event off to our handler
	local arg1, arg2 = ...
	-- TODO: Hide or Show whispers depending on the state that whisper command comes back as.
	--		This will let us hide the whisper if settings tell us to.
	self:WhisperCommand(arg1, arg2)
end

--- Sends hidden channel information
-- Serialized data on send so it can be retrieved as it was.
-- @param cmd The command to be sent with the data
-- @param data The data to send
function RPWL:Send(cmd, data, player, nopwp, comm)
	--if not enablecomm then return end
	if self.rpoSettings.syncOut == "0" then return end
	if not comm then comm = CommCmd end
	local channel = "GUILD"
	if player then
		channel = "WHISPER"
	end
	--if not enablecomm then return end
	--if data and type(data) == "table" then self:Print(unpack(data)) end
	local senttime = time()
	local sendpassword = ""
	if not nopwp then
		sendpassword = MD5(self.rpoSettings.syncPassword .. senttime)
	end
	self:SendCommMessage(CommCmd, self:Serialize(sendpassword,senttime,cmd,data), channel, player)
end

--- Sends a chat message
-- @param channel Target Channel
-- @param to Target player
-- @param message Message to send, minus our prefix
function RPWL:Message(channel, message, to)
	ChatThrottleLib:SendChatMessage("BULK", CommCmd, prefix.." "..message, channel, nil, to);
end

--- Sends a whisper
-- @param to Target player
-- @param message Message to send
function RPWL:Whisper(message, to)
	RPWL:Message("WHISPER", message, to);
end

--- Checks to see if someone is on the waitlist, and returns their index.
-- If they arent found returns nil.  Checks for alts if known.
-- @param name Name of the player to check for
-- @param alt Alt character
function RPWL:Check(name, alt)
	if not name then return nil end
	for i=1,(#(db.realm.waitlist)) do
		-- Main is on the list
		if (string.lower(db.realm.waitlist[i].cols[cwl.name].value) == string.lower(name)) then
			return i, "main"
		-- Alt talking for a main
		elseif (string.lower(db.realm.waitlist[i].cols[cwl.alt].value) == string.lower(name)) then
			return i, "alt"
		-- Alt looking for alt change.
		elseif (alt and string.lower(db.realm.waitlist[i].cols[cwl.name].value) == string.lower(alt)) then
			return i, "change"
		end
	end
	return nil
end

--- Add someone to the waitlist.
-- Checks to see if they are on the waitlist.
-- @param name Character Name
-- @param alt Alt character
-- @param timestamp Time added
-- @param recieved Wether this command came from :SyncCommand or :WhisperCommand/:ChatCommand.  SyncCommand just wants to relay the information given, nothing has been generated.
function RPWL:Add(name, alt, timestamp, recieved)
	-- Make sure they are not on the wait list
	local guildRoster = self:GuildRoster()
	local index, action = self:Check(name, alt)
	if not index then
		if guildRoster[string.lower(name)] then
			class = guildRoster[string.lower(name)]["class"]
		else
			class = "Unknown"
		end
		index = (#db.realm.waitlist)+1
		db.realm.waitlist[index] = self:BuildRow(
			{
				[cwl.name] 		= name,
				[cwl.alt] 		= alt,
				[cwl.class]		= class,
				[cwl.status] 	= "",
				[cwl.timestamp] = timestamp,
			},
			cwlArg, CheckOnline
		)
		
		if not recieved then
			self:Send(cs.add, self:StripRow(db.realm.waitlist[index]))
		end
		self:Print(prefix.." Added",name," to the waitlist.")
		self:UpdateList()
		return true
	-- They are on the waitlist, tell them!
	else
		if action == "change" then
			self:Print(prefix.." Updated alt of",name," to",alt," from",db.realm.waitlist[index].cols[cwl.alt].value, " on the waitlist.")
			db.realm.waitlist[index].cols[cwl.alt].value = alt
			self:UpdateList()
			return true
		else
			if not recieved then
				self:Print(prefix, name, " is already on the waitlist.")
			end
			return false			
		end
	end
end

--- Add someone to the waitlist.
-- Checks to see if they are on the waitlist.
-- @param name Character Name
-- @param recieved Wether this command came from :SyncCommand or :WhisperCommand/:ChatCommand.
function RPWL:Remove(name, recieved)
	-- Check for our special name, lets us clear the waitlist
	if (string.lower(name) == "all") then
		db.realm.waitlist = {}
		if not recieved then
			self:Send(cs.remove, name)
		end
		if recieved then
			self:Print(prefix.." Waitlist cleared!")
		end
		self:UpdateList()
		if (self.scrollFrame) then
			self.scrollFrame:SetData(db.realm.waitlist)
		end
		return true
	end

	-- Get our index
	local index, action = self:Check(name, name)
	-- If we have an index they're on the waitlist and we want to remove them
	if (index) then
		tremove(db.realm.waitlist,index)
		if not recieved then
			self:Send(cs.remove, name)
		end
		self:Print(prefix.." Removed",name," from the waitlist.")
		self:UpdateList()
		return true
	-- They aren't on the waitlist, tell them!
	else
		if not recieved then
			self:Print(prefix, name, " is not on the waitlist.")
		end
		return false
	end
end

--- Shows the waitlist in a chat channel.
-- @param channel Channel
-- @param to Target player
function RPWL:Show(channel, to)
	-- Build our message string
	msg = "Currently on the waitlist: "
	for i=1,(#(db.realm.waitlist)) do
		-- Some better logic to handle comma's could be helpful I guess
		msg = msg .. db.realm.waitlist[i].cols[cwl.name].value .. ", "
	end
	msg:sub(-1)
	
	-- Send to the right channel
	-- nil = Chatwindow
	if not channel then
		self:Print(prefix.." "..msg)
	-- No to field, send it to a normal chat
	elseif not to then
		RPWL:Message(channel, msg)
	-- We need to whisper
	else
		RPWL:Whisper(msg, to);
	end
end

local helpmsg =
{
	"-- Raid Points Waitlist --",
	"  Commands:",
	"rp help - Raid Points help menu.",
	"wl help - This menu.",
	"wl show - Show the waitlist.",
	"wl add [alt] - Add yourself to the waitlist, optionally include the alt you will be online with.",
	"wl add [main] - Update the waitlist with the character you are currently on as your listed alt.",
	"wl remove - Remove yourself from the waitlist.",
}
--- Send help to chat.
-- @param channel Channel
-- @param to Target player
function RPWL:Help(channel, to)

	-- Send to the right channel
	if to then
		for i=1, #msg do
			RPWL:Whisper(msg[i], to)
		end
	elseif channel then
		for i=1, #msg do
			RPWL:Message(channel, msg[i])
		end
	-- We need to whisper
	else
		for i=1, #msg do
			self:Print(msg[i])
		end
	end
end

--- Process command given by the /wl command.
-- Each chat function is stored as a function, it works similarly to an if..else ladder but adding additional commands is faster and I feel a little cleaner.
-- @param msg The message given by the event
function RPWL:ChatCommand(msg)
	-- Get our arguements, any ones not in the command are returned as nil
	if msg then
		local cmd, pos = self:GetArgs(msg, 1, 1)
		if cmd and self.chatCommands[string.lower(cmd)] then
			self.chatCommands[string.lower(cmd)](self, msg)
		else
			self.chatCommands["open"](self)
		end
	else
		self.chatCommands["open"](self)
	end
end

RPWL.chatCommands = {}

--- chatCommand: Debug.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPWL.chatCommands["debug"] = function (self, msg)
	if self.debugOn then
		self.debugOn = false
	else
		self.debugOn = true
	end
end

--- chatCommand: Add.
-- Adds a player to the waitlist
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPWL.chatCommands["add"] = function (self, msg)
	local _, name, alt, pos = self:GetArgs(msg, 3, 1)
	if not alt then alt = name end
	-- get timestamp here
	self:Add(name, alt, time())
end

--- chatCommand: Remove.
-- Removes a player from the waitlist
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPWL.chatCommands["remove"] = function (self, msg)
	local _, name, pos = self:GetArgs(msg, 2, 1)
	self:Remove(name)
end

--- chatCommand: Show.
-- Shows the waitlist to the given channel, if channel is nil uses :Print
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPWL.chatCommands["show"] = function (self, msg)
	local _, channel, to, pos = self:GetArgs(msg, 3, 1)
	self:Show(channel, to)
end

--- chatCommand: Help.
-- Shows the help message
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPWL.chatCommands["help"] = function (self, msg)
	local _, channel, to, pos = self:GetArgs(msg, 3, 1)
	self:Help(channel, to)
end

--- chatCommand: Open.
-- Opens the waitlist frame.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPWL.chatCommands["open"] = function (self, msg)
	if not self.Frame then
		self:CreateFrame()
	end
	self:UpdateList()
	self.Frame:Show()
end

--- chatCommand: Settings.
-- Opens the settings frame.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPWL.chatCommands["settings"] = function (self, msg)
	InterfaceOptionsFrame_OpenToCategory(self.options)
end
RPWL.chatCommands["options"] = RPWL.chatCommands["settings"]

--- Process whispers given by the event.
-- Each whisper function is stored as a function, it works similarly to an if..else ladder but adding additional commands is faster and I feel a little cleaner.
-- @param msg The message given by the event
-- @param from Sender
function RPWL:WhisperCommand(msg, from)
	-- Get our arguements, any ones not in the command are returned as nil
	wcmd, cmd, pos = self:GetArgs(msg, 2, 1)
	-- Check to make sure the first line was "wl", otherwise this message isnt for us and we need to ignore it.
	if (string.lower(wcmd) ~= "wl") then return false end
	if cmd and self.whisperCommands[string.lower(cmd)] then
		self.whisperCommands[string.lower(cmd)](self, msg, from)
	else
		msg = "wl help"
		self.whisperCommands["help"](self, msg, from)
	end
	return true
end

RPWL.whisperCommands = {}

--- whisperCommand: Add.
-- Adds a player to the waitlist
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param from Sender
RPWL.whisperCommands["add"] = function(self, msg, from)
	_, _, alt, pos = self:GetArgs(msg, 3, 1)
	if not alt then alt = from end
	-- get timestamp here
	if self:Add(from, alt, time()) then
		self:Whisper("You have been added to the waitlist.", from)
	else
		self:Whisper("You are already on the waitlist.", from)
	end
end

--- whisperCommand: Remove.
-- Remove a player from the waitlist
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param from Sender
RPWL.whisperCommands["remove"] = function(self, msg, from)
	if self:Remove(from) then
		self:Whisper("You have been removed from the waitlist.", from)
	else
		self:Whisper("You are not on the waitlist.", from)
	end
end

--- whisperCommand: Show.
-- Shows the waitlist
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param from Sender
RPWL.whisperCommands["show"] = function(self, msg, from)
	self:Show("WHISPER", from)
end

--- whisperCommand: Help.
-- Shows the help
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param from Sender
RPWL.whisperCommands["help"] = function(self, msg, from)
	local _, _, channel, pos = self:GetArgs(msg, 3, 1)
	self:Help(channel, from)
end

--- Process sync events.
-- Each sync function is stored as a function, it works similarly to an if..else ladder but adding additional commands is faster and I feel a little cleaner.
-- @param msg The message given by the event
-- @param from Sender
function RPWL:OnCommReceived(pre, message, distribution, sender)
	if self.rpoSettings.syncIn == "0" then return end
	local success, sentpassword, senttime, cmd, msg = self:Deserialize(message)
	--self:Print(pre, password, self.rpoSettings.syncPassword, self.rpoSettings.syncPassword == password, cmd, msg, distribution, sender)
	local ourpassword = self.rpoSettings.syncPassword
	ourpassword = MD5(ourpassword .. senttime)
	
	if ourpassword ~= sentpassword then return end
	if not cmd then return end
	if cmd and self.syncCommands[string.lower(cmd)] then
		self.syncCommands[string.lower(cmd)](self, msg, sender)
	end	
end

RPWL.syncCommands = {}

--- syncCommand: cs.add.
-- Sync - Add player to the waitlist
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param sender Sender
RPWL.syncCommands[cs.add] = function(self, msg, sender)
	self:Add(msg[cwl.name], msg[cwl.alt], msg[cwl.timestamp], true)
end

--- syncCommand: cs.remove.
-- Sync - Remove player from the waitlist
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param sender Sender
RPWL.syncCommands[cs.remove] = function(self, msg, sender)
	self:Remove(msg, true)
end

--- syncCommand: cs.syncrequest.
-- Sent on login by this mod.
-- You can not sync with yourself.
-- The first client to respond is the one that we listen for.
-- That client will broadcast the sync message.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param sender Sender
RPWL.syncCommands[cs.syncrequest] = function(self, msg, sender)
	syncrequest = sender
	if not syncowner and syncrequest ~= UnitName("player") then
		self:Send(cs.syncowner, "me")
	end
end

--- syncCommand: cs.syncowner.
-- Sent after a syncrequest is heard.
-- You can not sync with yourself.
-- The first client to respond is the one that we listen for.
-- That client will broadcast the sync message.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param sender Sender
RPWL.syncCommands[cs.syncowner] = function(self, msg, sender)
	if not syncowner and syncrequest ~= UnitName("player") then
		syncowner = sender
		if syncowner == UnitName("player") then
			self:Send(cs.sync, self:StripTable(db.realm.waitlist))
		end
	end
end

--- syncCommand: cs.syncowner.
-- Sent after the client accepts itself as the owner.
-- You can not sync with yourself.
-- The first client to respond is the one that we listen for.
-- That client will broadcast the sync message.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param sender Sender
RPWL.syncCommands[cs.sync] = function(self, msg, sender)
	if not syncdone and syncowner ~= sender then
		local temp = msg
		db.realm.waitlist = self:BuildTable(temp, cwlArg, CheckOnline)
		syncdone = true
	end
	syncowner = nil
	syncrequest = nil
end

--- syncCommand: cs.settings.
-- Sent when the button to sync is clicked
-- You can not sync with yourself.
-- The first client to respond is the one that we listen for.
-- That client will broadcast the sync message.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param sender Sender
RPWL.syncCommands[cs.rpoSettings] = function(self, msg, sender)
	local settings = self.rpoSettings
	if (settings.syncSettings == "0") then return end
	for k,v in pairs(settings) do
		if (k ~= "syncPassword") then
			if (settings[k] ~= msg[k]) then
				settings[k] = msg[k]
			end
		end
	end
	self.options:refresh()
end

function RPWL:PushSettings(value, isGUI, isUpdate)
	self:Send(cs.rpoSettings, self.rpoSettings)
end

--- Force the waitlist scrolling table to refresh.
function RPWL:UpdateList()
	if self.Frame then
		self.scrollFrame:SortData();
	end
end

-- Force the guildlist scrolling table to refresh.
-- function RPWL:UpdateGuildList()
	-- if self.Frame then
		-- self.scrollFrameGuild:SortData();
	-- end
-- end

--- Handle the event fired when clicking on any row in the waitlist scrolling table.
function scrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, down)
	if button == "LeftButton" then
		return false
	elseif button == "RightButton" then
		if data[realrow] then
			RPWL:Remove(RPWL.scrollFrame:GetRow(realrow).cols[cwl.name].value, false, false)
			RPWL.scrollFrame:Refresh()
			RPWL.scrollFrame:SortData()
		end
		return true
	end
end

-- Handle the event fired when clicking on any row in the guildlist scrolling table.
-- function scrollFrameGuildOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	-- if button == "LeftButton" then
		-- if data[realrow] then
			-- if RPWL.scrollFrameGuild.selected == data[realrow] then
				-- RPWL.scrollFrameGuild.selected = nil
			-- else
				-- RPWL.scrollFrameGuild.selected = data[realrow]
			-- end
			-- RPWL.scrollFrameGuild:Refresh()
		-- end
	-- elseif button == "RightButton" then
		-- if data[realrow] then
			-- RPWL.scrollFrameGuild.selected = data[realrow]
			-- RPWL:ButtonAdd()
			-- RPWL.scrollFrameGuild:SortData()
		-- end
	-- end
-- end

--- Returns a color object depending if the person is online or not.
-- @param row The row that we are checking for.
function CheckOnline(row)
	local guildRoster = RPWL:GuildRoster()
	local name = row.cols[cwl.name].value
	--if (RPWL:Check(name)) then
		if (guildRoster[string.lower(name)]) then
			if (guildRoster[string.lower(name)]["online"]) then
				return {["r"] = 0.0, ["g"] = 1.0, ["b"] = 0.0, ["a"] = 1.0}
			end
		end
	--end
	return {["r"] = 0.5, ["g"] = 0.5, ["b"] = 0.5, ["a"] = 1.0}
end

--- Adds the selected person to the waitlist.
-- function RPWL:ButtonAdd()
	-- if (self.scrollFrameGuild.selected) then
		-- self:Add(self.scrollFrameGuild.selected.cols[cgr.name].value, "", time())
	-- end
-- end

--- Removes the selected person from the waitlist.
function RPWL:ButtonRemove()
	if (self.scrollFrame:GetSelection()) then
		self:Remove(self.scrollFrame:GetRow(self.scrollFrame:GetSelection()).cols[cwl.name].value, false, false)
		self.scrollFrame:ClearSelection()
		self.scrollFrame:Refresh();
	end
end

--- Roster Update
-- Update the internal table with the current guild roster.
function RPWL:RosterUpdate()
	--if not rosterupdate then return end
	-- if not GetGuildRosterShowOffline() then
		-- SetGuildRosterShowOffline(true)
	-- end
	--self.guildRosterIndex = {}
	local guildRoster = self:GuildRoster()
	for key, value in pairs(guildRoster) do
		local online
		local found = false
		if (value["online"]) then online = 'Y' else online = 'N' end
		for i=1,#self.guildRosterIndex do
			if self.guildRosterIndex[i].cols[cgr.name].value == value["name"] then
				found = i
			end
		end
		if not found then
			self.guildRosterIndex[#self.guildRosterIndex+1] = self:BuildRow(
				{
					[cgr.name] 			=	value["name"],
					[cgr.rank] 			=	value["rank"],
					[cgr.level] 		=	value["level"],
					[cgr.class] 		=	value["class"],
					[cgr.zone] 			=	value["zone"],
					[cgr.officernote] 	=	value["officernote"],
					[cgr.online] 		=	online,
					[cgr.status] 		=	value["status"],
					[cgr.rankindex]		= 	value["rankIndex"],
				},
				cgrArg, CheckOnline
			)
			found = #self.guildRosterIndex
		end
		if self.guildRosterIndex[found].cols[cgr.rank].value ~= value["rank"] then self.guildRosterIndex[found].cols[cgr.rank].value = value["rank"] end
		if self.guildRosterIndex[found].cols[cgr.level].value ~= value["level"] then self.guildRosterIndex[found].cols[cgr.level].value = value["level"] end
		if self.guildRosterIndex[found].cols[cgr.class].value ~= value["class"] then self.guildRosterIndex[found].cols[cgr.class].value = value["class"] end
		if self.guildRosterIndex[found].cols[cgr.officernote].value ~= value["officernote"] then self.guildRosterIndex[found].cols[cgr.officernote].value = value["officernote"] end
		if self.guildRosterIndex[found].cols[cgr.online].value ~= online then self.guildRosterIndex[found].cols[cgr.online].value = online end
		if self.guildRosterIndex[found].cols[cgr.status].value ~= value["status"] then self.guildRosterIndex[found].cols[cgr.status].value = value["status"] end
		if self.guildRosterIndex[found].cols[cgr.rankindex].value ~= value["rankindex"] then self.guildRosterIndex[found].cols[cgr.rankindex].value = value["rankindex"] end
	end
	-- if self.scrollFrameGuild then
		-- self.scrollFrameGuild:SetData(self.guildRosterIndex)
		-- self:UpdateGuildList()
	-- end
end

--- Expose the waitlist table.
function RPWL:Waitlist()
	return db.realm.waitlist, cwl
end

