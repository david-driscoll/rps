local db
local prefix = "<WL>"
local enablecomm = true
local syncrequest, syncowner, syncdone
local rosterupdate
local minRank = 2
local RPLibrary = LibStub:GetLibrary("RPLibrary")

RPWL = LibStub("AceAddon-3.0"):NewAddon("Raid Points Waitlist", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

-- Local Table Constants
-- To use the grid properly, we need numbered index's.
-- Numbered index's aren't very specific, so lets get the best of both worlds

-- Watilist table contents
local cwl = 
{
	name		= 1,
	alt			= 2,
	class		= 3,
	status		= 4,
	--datetime	= 5,
	timestamp	= 5,
}

-- Guild Roster table contents
local cgr = 
{
	name		= 1,
	rank		= 2,
	level		= 3,
	class		= 4,
	zone		= 5,
	status		= 6,
	online		= 7,
	officernote	= 8,
	rankindex	= 9,
}

-- Sync commands, lets save some overhead
local cs = 
{
	["add"]			= "a",
	["remove"]		= "r",
	["syncrequest"]	= "sr",
	["syncowner"]	= "so",
	["sync"]		= "s",
}

function RPWL:OnInitialize()
	db = LibStub("AceDB-3.0"):New("rpwaitlistDB", defaults, "Default")
	self.db = db
	if SlashCmdList["WOWHEAD_LOOTER"] then
		SLASH_WOWHEAD_LOOTER1 = "/whl"
	end
	self:RegisterChatCommand("wl", "ChatCommand")
	self:RegisterChatCommand("rpwl", "ChatCommand")
	if not db.realm.waitlist then
		db.realm.waitlist = {}
	end
end

function RPWL:OnEnable()
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterComm("RPWL")
	syncrequest = nil
	syncowner = nil
	syncdone = false
	rosterupdate = true
	local guildname, _, gr = GetGuildInfo("player")
	if (not (gr <= minRank)) then
		enablecomm = false
	end
	self.guildRoster = {}
	self.guildRosterIndex = {}
	
	-- db.realm.waitlist = RPLibrary:StripTable(db.realm.waitlist)
	-- for i=1,#db.realm.waitlist do
		-- db.realm.waitlist[i] = RPLibrary:BuildRow(
			-- {
				-- [cwl.name] 		= RPLibrary:BuildColumn(db.realm.waitlist[i].cols[cwl.name].value),
				-- [cwl.alt] 		= RPLibrary:BuildColumn(db.realm.waitlist[i].cols[cwl.alt].value), 
				-- [cwl.class] 	= RPLibrary:BuildColumn(db.realm.waitlist[i].cols[cwl.class].value, RPLibrary:ClassColor(db.realm.waitlist[i].cols[cwl.class].value)),
				-- [cwl.status] 	= RPLibrary:BuildColumn(db.realm.waitlist[i].cols[cwl.status].value),
				----[cwl.datetime] 	= RPLibrary:BuildColumn(db.realm.waitlist[i].cols[cwl.datetime].value),
				-- [cwl.timestamp] = RPLibrary:BuildColumn(db.realm.waitlist[i].cols[cwl.timestamp].value),
			-- }
		-- )	
		-- db.realm.waitlist[i].cols[cwl.timestamp]["DoCellUpdate"] = DoTimestampUpdate;
		-- RPLibrary:AppendRow(
			-- db.realm.waitlist[i],
			-- CheckOnline, {db.realm.waitlist[i].cols[cwl.name].value}
		-- )
	-- end
	
	SetGuildRosterShowOffline(true)
	self:Send(cs.syncrequest, "to me")
	--enablecomm = false
	--AceComm:RegisterComm("wlupdate")
	
end

function RPWL:GUILD_ROSTER_UPDATE(arg1)
	RPWL:RosterUpdate()
end

function RPWL:RosterUpdate()
	--if not rosterupdate then return end
	if not GetGuildRosterShowOffline() then
		SetGuildRosterShowOffline(true)
	end
	
	self.guildRoster = {}
	self.guildRosterIndex = {}
	for i=1,GetNumGuildMembers(true) do
		name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
		self.guildRoster[string.lower(name)] = {
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
		--if (self.guildRoster[string.lower(name)]["online"]) then
		local online
		if (self.guildRoster[string.lower(name)]["online"]) then online = 'Y' else online = 'N' end
			self.guildRosterIndex[#self.guildRosterIndex+1] = RPLibrary:BuildRow(
				{
					[cgr.name] 			=	RPLibrary:BuildColumn(self.guildRoster[string.lower(name)]["name"]),
					[cgr.rank] 			=	RPLibrary:BuildColumn(self.guildRoster[string.lower(name)]["rank"]),
					[cgr.level] 		=	RPLibrary:BuildColumn(self.guildRoster[string.lower(name)]["level"]),
					[cgr.class] 		=	RPLibrary:BuildColumn(self.guildRoster[string.lower(name)]["class"], RPLibrary:ClassColor(class)),
					[cgr.zone] 			=	RPLibrary:BuildColumn(self.guildRoster[string.lower(name)]["zone"]),
					[cgr.officernote] 	=	RPLibrary:BuildColumn(self.guildRoster[string.lower(name)]["officernote"]),
					[cgr.online] 		=	RPLibrary:BuildColumn(online),
					[cgr.status] 		=	RPLibrary:BuildColumn(self.guildRoster[string.lower(name)]["status"]),
					[cgr.rankindex]		= 	RPLibrary:BuildColumn(self.guildRoster[string.lower(name)]["rankIndex"]),
				}
			)
			RPLibrary:AppendRow(
				self.guildRosterIndex[#self.guildRosterIndex],
				CheckOnline, {name}
			)
		--end
		
	end
	if self.scrollFrameGuild then
		self.scrollFrameGuild:SetData(self.guildRosterIndex)
		self:UpdateGuildList()
	end
end

function RPWL:Send(cmd, data)
	if not enablecomm then return end
	self:SendCommMessage("RPWL", self:Serialize(cmd,data), "GUILD")
end
-- RPWL:SendCommMessage(prefix, text, distribution[, target])
-- RPWL:Serialize(...)
-- RPWL:Deserialize(data)

function RPWL:CHAT_MSG_WHISPER()
-- arg1 = Message received 
-- arg2 = Author 
-- arg3 = Language (or nil if universal, like messages from GM) (always seems to be an empty string; argument may have been kicked because whispering in non-standard language doesn't seem to be possible [any more?]) 
-- arg6 = status (like "DND" or "GM") 
-- arg7 = (number) message id (for reporting spam purposes?) (default: 0) 
-- arg8 = (number) unknown (default: 0)

	-- Fire our event off to our handler
	self:WhisperCommand(arg1, arg2)
end

-- Sends whispers, self explainitory
function RPWL:Whisper(to, message)
	SendChatMessage(prefix.." "..message, "WHISPER", nil, to);
end

-- Checks to see if someone is on the waitlist, and returns their index.
-- If they arent found returns 0/false/nil
function RPWL:Check(name, alt)
	for i=1,(getn(db.realm.waitlist)) do
		-- Main is on the list
		if (string.lower(db.realm.waitlist[i].cols[cwl.name].value) == string.lower(name)) then
			return i
		-- Alt talking for a main
		elseif (string.lower(db.realm.waitlist[i].cols[cwl.alt].value) == string.lower(name)) then
			return i
		-- Alt looking for alt change.
		elseif (alt and string.lower(db.realm.waitlist[i].cols[cwl.name].value) == string.lower(alt)) then
			return i
		end
	end
	return nil
end

-- Add someone to the waitlist
function RPWL:Add(name, alt, timestamp, recieved)
	-- Make sure they are not on the wait list
	if not self:Check(name, alt) then
		if self.guildRoster[string.lower(name)] then
			class = self.guildRoster[string.lower(name)]["class"]
		else
			class = "Unknown"
		end
		index = (getn(db.realm.waitlist)+1)
		db.realm.waitlist[index] = RPLibrary:BuildRow(
			{
				--[cwl.index] 		= RPLibrary:BuildColumn(index),
				[cwl.name] 		= RPLibrary:BuildColumn(name),
				[cwl.alt] 		= RPLibrary:BuildColumn(alt), 
				[cwl.class] 	= RPLibrary:BuildColumn(class, RPLibrary:ClassColor(class)),
				[cwl.status] 	= RPLibrary:BuildColumn(""),
				--[cwl.datetime] 	= RPLibrary:BuildColumn(date("%A %b %d %I:%M%p",timestamp)),
				[cwl.timestamp] = RPLibrary:BuildColumn(timestamp),
			}
		)
		db.realm.waitlist[index].cols[cwl.timestamp]["DoCellUpdate"] = DoTimestampUpdate;
		RPLibrary:AppendRow(
			db.realm.waitlist[index],
			CheckOnline, {name}
		)
		
		if not recieved then
			self:Send(cs.add, RPLibrary:StripRow(db.realm.waitlist[index]))
		end
		self:Print(prefix.." Added",name," to the waitlist.")
		self:UpdateList()
		return true
	-- They are on the waitlist, tell them!
	else
		if not recieved then
			self:Print(prefix, name, " is already on the waitlist.")
		end
		return false
	end
end

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
	index = self:Check(name, name)
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

-- Shows the waitlist in chat
function RPWL:Show(channel, to)
	-- Build our message string
	msg = "Currently on the waitlist: "
	for i=1,(#(db.realm.waitlist)) do
		-- Some better logic to handle comma's could be helpful I guess
		msg = msg .. db.realm.waitlist[i].cols[cwl.name].value .. ", "
	end
	
	-- Send to the right channel
	-- nil = Chatwindow
	if not channel then
		self:Print(prefix.." "..msg)
	-- No to field, send it to a normal chat
	elseif not to then
		SendChatMessage(msg, channel)
	-- We need to whisper
	else
		SendChatMessage(msg, channel, nil, to);
	end
end

-- Send help to chat
function RPWL:Help(channel, to)
	msg =
	{
		"-- Raid Points Waitlist --",
		"  Commands:",
		"wl help - This menu.",
		"wl show - Show the waitlist.",
		"wl add [alt] - Add yourself to the waitlist, optionally include the alt you will be online with.",
		"wl add [main] - Update the waitlist with the character you are currently on as your listed alt.",
		"wl remove - Remove yourself from the waitlist.",
	}

	-- Send to the right channel
	-- nil = Chatwindow
	if not channel then
		for i=1, #msg do
			self:Print(msg[i])
		end
	-- No to field, send it to a normal chat
	elseif not to then
		for i=1, #msg do
			SendChatMessage(msg[i], channel)
		end
	-- We need to whisper
	else
		for i=1, #msg do
			SendChatMessage(msg[i], channel, nil, to)
		end
	end
end

-- Process command given by the /wl command
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
RPWL.chatCommands["add"] = function (self, msg)
	local _, name, alt, pos = self:GetArgs(msg, 3, 1)
	if not alt then alt = name end
	-- get timestamp here
	self:Add(name, alt, time())
end

RPWL.chatCommands["remove"] = function (self, msg)
	local _, name, pos = self:GetArgs(msg, 2, 1)
	self:Remove(name)
end

RPWL.chatCommands["show"] = function (self, msg)
	local _, channel, pos = self:GetArgs(msg, 2, 1)
	self:Show(channel)
end

RPWL.chatCommands["help"] = function (self, msg)
	local _, query, pos = self:GetArgs(msg, 2, 1)
	self:Help(query)
end

RPWL.chatCommands["open"] = function (self, msg)
	if not self.Frame then
		self:CreateFrame()
	end
	self:UpdateList()
	self.Frame:Show()
end

function RPWL:WhisperCommand(msg, from)
	-- Whatever to get args, CraftList2 has an interesting Arg function that might work better!
	-- Get our arguements, any ones not in the command are returned as nil
	wcmd, cmd, pos = self:GetArgs(msg, 2, 1)
	-- Check to make sure the first line was "wl", otherwise this message isnt for us and we need to ignore it.
	if (string.lower(wcmd) ~= "wl") then return false end
	if cmd and self.whisperCommands[string.lower(cmd)] then
		self.whisperCommands[string.lower(cmd)](self, msg, from)
	else
		self.whisperCommands["help"](self, msg)
	end
	return true
end

RPWL.whisperCommands = {}
RPWL.whisperCommands["add"] = function(self, msg, name)
	_, _, alt, pos = self:GetArgs(msg, 3, 1)
	if not alt then alt = name end
	-- get timestamp here
	if self:Add(name, alt, time()) then
		self:Whisper(name, "You have been added to the waitlist.")
	else
		self:Whisper(name, "You are already on the waitlist.")
	end
end

RPWL.whisperCommands["remove"] = function(self, msg, name)
	if self:Remove(name) then
		self:Whisper(name, "You have been removed from the waitlist.")
	else
		self:Whisper(name, "You are not on the waitlist.")
	end
end

RPWL.whisperCommands["show"] = function(self, msg, name)
	self:Show("WHISPER", name)
end

RPWL.whisperCommands["help"] = function(self, msg, name)
	local _, _, query, pos = self:GetArgs(msg, 3, 1)
	self:Help(query)
end

function RPWL:OnCommReceived(pre, message, distribution, sender)
	success, cmd, msg = self:Deserialize(message)
	self:Print(pre, cmd, msg, distribution, sender)
	if not cmd then return end
	if cmd and self.syncCommands[string.lower(cmd)] then
		self.syncCommands[string.lower(cmd)](self, msg, sender)
	end	
end

RPWL.syncCommands = {}
RPWL.syncCommands[cs.add] = function(self, msg, sender)
	self:Add(msg[cwl.name], msg[cwl.alt], msg[cwl.timestamp], true)
end

RPWL.syncCommands[cs.remove] = function(self, msg, sender)
	self:Remove(msg, true)
end

RPWL.syncCommands[cs.syncrequest] = function(self, msg, sender)
	syncrequest = sender
	if not syncowner and syncrequest ~= UnitName("player") then
		self:Send(cs.syncowner, "me")
	end
end

RPWL.syncCommands[cs.syncowner] = function(self, msg, sender)
	if not syncowner and syncrequest ~= UnitName("player") then
		syncowner = sender
		if syncowner == UnitName("player") then
			self:Send(cs.sync, RPLibrary:StripTable(db.realm.waitlist))
		end
	end
end

RPWL.syncCommands[cs.sync] = function(self, msg, sender)
	if not syncdone and syncowner ~= sender then
		local temp = msg
		for i=1,#temp do
			db.realm.waitlist[i] = RPLibrary:BuildRow(
				{
					[cwl.name] 		= RPLibrary:BuildColumn(temp[i][cwl.name]),
					[cwl.alt] 		= RPLibrary:BuildColumn(temp[i][cwl.alt]), 
					[cwl.class] 	= RPLibrary:BuildColumn(temp[i][cwl.class], RPLibrary:ClassColor(temp[i][cwl.class])),
					[cwl.status] 	= RPLibrary:BuildColumn(temp[i][cwl.status]),
					--[cwl.datetime]	= RPLibrary:BuildColumn(db.realm.waitlist[i].cols[cwl.datetime].value),
					[cwl.timestamp] = RPLibrary:BuildColumn(temp[i][cwl.timestamp]),
				}
			)
			db.realm.waitlist[i].cols[cwl.timestamp]["DoCellUpdate"] = DoTimestampUpdate;
			RPLibrary:AppendRow(
				db.realm.waitlist[i],
				CheckOnline, {temp[i][cwl.name]}
			)
		end
		syncdone = true
	end
	syncowner = nil
	syncrequest = nil
end

function RPWL:UpdateList()
	if self.Frame then
		self.scrollFrame:SortData();
	end
end

function RPWL:UpdateGuildList()
	if self.Frame then
		self.scrollFrameGuild:SortData();
	end
end

function scrollFrameOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	if button == "LeftButton" then
		RPWL.scrollFrame.selected = data[realrow]
		RPWL.scrollFrame:Refresh()
	elseif button == "RightButton" then
		RPWL.scrollFrame.selected = data[realrow]
		RPWL:ButtonRemove()
		RPWL.scrollFrame:SortData()
	end
end

function scrollFrameGuildOnClick(rowFrame, cellFrame, data, cols, row, realrow, column, button, down)
	if button == "LeftButton" then
		RPWL.scrollFrameGuild.selected = data[realrow]
		RPWL.scrollFrameGuild:Refresh()
	elseif button == "RightButton" then
		RPWL.scrollFrameGuild.selected = data[realrow]
		RPWL:ButtonAdd()
		RPWL.scrollFrameGuild:SortData()
	end
end

function CheckOnline(name)
	--if (RPWL:Check(name)) then
		if (RPWL.guildRoster[string.lower(name)]) then
			if (RPWL.guildRoster[string.lower(name)]["online"]) then
				return {["r"] = 0.0, ["g"] = 1.0, ["b"] = 0.0, ["a"] = 1.0}
			end
		end
	--end
	return {["r"] = 0.5, ["g"] = 0.5, ["b"] = 0.5, ["a"] = 1.0}
end

function RPWL:ButtonAdd()
	if (self.scrollFrameGuild.selected) then
		self:Add(self.scrollFrameGuild.selected.cols[cgr.name].value, "", time())
	end
end

function RPWL:ButtonRemove()
	if (self.scrollFrame.selected ~= nil) then
		self:Remove(self.scrollFrame.selected.cols[cwl.name].value, false, false)
		self.scrollFrame.selected = nil
		self.scrollFrame:Refresh();
	end
end
