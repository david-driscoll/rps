local db
local prefix = "<RPB>"
local enablecomm = true
local syncrequest, syncowner, syncdone
local caninvite = false
local bidtime
local rollList
LoadAddOn("RPLibrary")
local RPLibrary = LibStub:GetLibrary("RPLibrary")

RPB = LibStub("AceAddon-3.0"):NewAddon("Raid Points Bot", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0")
RPB.frames = {}

function RPB:OnInitialize()
	db = LibStub("AceDB-3.0"):New("rpbDB", defaults, "Default")
	self.db = db
	self:RegisterChatCommand("rp", "ChatCommand")
	self:RegisterChatCommand("rpb", "ChatCommand")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterComm("rpb")
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
		db.realm.settings = 
		{
			bidtime = 30,
			lastcalltime = 5,
			showwhispers = false,
			notifyonchange = true,
			maxclass = 100,
			minclass = 50,
			maxnonclass = 100,
			minnonclass = 50,
			divisor = 2,
			allownegative = true,
			rounding = 5,
			defaultraid = "DI",
			defaultfeature = "deus",
		}
	end
end

function RPB:OnEnable()
	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("START_LOOT_ROLL")
	--self:RegisterEvent("LOOT_SLOT_CLEARED")
	--self:RegisterEvent("LOOT_CLOSED")	
	--self:RegisterEvent("CANCEL_LOOT_ROLL")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("SpecialEvents_ItemLooted")
	syncrequest = nil
	syncowner = nil
	syncdone = false
	self.activeraid = nil
	
	self.rollList = {}
	self.feature = {}
	self:AddFeatureSet(db.realm.settings.defaultfeature)
	
	--SetGuildRosterShowOffline(true)
	--self:Send("syncrequest", "to me")
	--enablecomm = false
	--AceComm:RegisterComm("wlupdate")
	
end

function RPB:CHAT_MSG_WHISPER()
	RPB:WhisperCommand(arg1, arg2)
end

function RPB:CHAT_MSG_SYSTEM()
	if (RPB.rollWindowRolling and event == "CHAT_MSG_SYSTEM" and string.find(arg1, "rolls") and string.find(arg1, "%(1%-100%)")) then
		_, _, player, roll = string.find(arg1, "(.+) " .. "rolls" .. " (%d+)");
		RPB:RollListUpdate(player, roll)
	end
end

function RPB:PlayerToArray(player)
	local list = {}
	if (player and type(player) == "string") then
		if player == "all" then
			-- Check if we are in a raid.
			-- If we are in a raid get raid contents
			-- Also get waitlist contents, only if in a raid.
		else
			playerlist = {}
			splitlist = RPLibrary:Split(player, ",")
			self:Print(splitlist)
			for i=1,#splitlist do
				if (RPLibrary.classList[splitlist[i]]) then
					-- Search raid for all of "class"
					-- Search waitlist for all of "class"
					-- Add to list
				elseif (splitlist[i] == "tier") then
					-- Find player class
					-- Determine which tier they belong to.
					-- Search raid for all of those classes
					-- Search waitlist for all of those classes
					-- Add to list
				else
					self:Print(splitlist[i])
					-- Assume this is a normal player, add them to the list.
					list[#list+1] = {
						name = splitlist[i],
						waitlist = RPWL:Check(splitlist[i]) or false,
					}
				end
			end
		end
	end
	return list
end

function RPB:Message(channel, to, message)
	SendChatMessage(prefix.." "..message, channel, nil, to);
end

function RPB:Whisper(to, message)
	SendChatMessage(prefix.." "..message, "WHISPER", nil, to);
end

function RPB:UseDatabase(database)
	if (database and db.realm.raid[string.lower(database)]) then
		self.activeraid = db.realm.raid[string.lower(database)]
		self:Print("Now running database", string.lower(database))
		return true
	else
		self:Print("Database ",database,"does not exist!")
		return false
	end
end

function RPB:CreateDatabase(database)
	db.realm.raid[string.lower(database)] = 
	{
	}
	self:Print("Database",database,"created!")
	db.realm.version.lastaction = time()
	RPB:UseDatabase(database)
end

function RPB:CreatePlayer(player)
	self.activeraid[string.lower(player)] = {
		id 				= -1,
		name 			= string.lower(player),
		fullname 		= player,
		class			= "Unknown",
		gender			= "Unknown",
		race			= "Unknown",
		talent			= "Unknown",
		points			= 0,
		lifetime		= 0,
		recenthistory 	= {},
		recentactions 	= {},
	}
end

function RPB:PointsAdd(datetime, player, value, ty, itemid, reason, waitlist, whisper, recieved)
	local playerlist = self:PlayerToArray(player);
	local playerdata

	for i=1, #playerlist do
		self:Print("Points Add For Loop",playerlist[i].name)
		if (not self.activeraid[playerlist[i].name]) then
			self:CreatePlayer(playerlist[i].name)
		end
		self.activeraid[playerlist[i].name].recentactions[(#(self.activeraid[playerlist[i].name].recentactions)+1)] = {
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
				self:Whisper(playerlist[i].name, "Added "..value.." points for "..reason)
			else
				self:Whisper(playerlist[i].name, "Deducted "..value.." points for "..reason)
			end
		end
		self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].points + tonumber(value)
		self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].lifetime + tonumber(value)
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
		if (self.activeraid[playerlist[i].name]) then
			for j=1, #self.activeraid[playerlist[i].name].recentactions do
				if (self.activeraid[playerlist[i].name].recentactions[j].datetime == datetime) then
					found = true
					db.realm.version.lastaction = actiontime
					if (whisper) then
						if (whisper) then
							self:Whisper(name, "Removed "..value.." points for "..reason)
						end
					end
					self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].points - tonumber(self.activeraid[playerlist[i].name].recentactions[j].value)
					self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].lifetime - tonumber(self.activeraid[playerlist[i].name].recentactions[j].value)
					tremove(self.activeraid[playerlist[i].name].recentactions,j)
					break
				end
			end
			if (not found and player ~= "all") then
				for j=1, #self.activeraid[playerlist[i].name].recenthistory do
					if (self.activeraid[playerlist[i].name].recenthistory[j].datetime == datetime) then
						self.activeraid[playerlist[i].name].recentactions[#((self.activeraid[playerlist[i].name].recentactions)+1)] = {
							datetime 	= self.activeraid[playerlist[i].name].recenthistory[j].datetime,
							ty			= self.activeraid[playerlist[i].name].recenthistory[j].ty,
							itemid		= self.activeraid[playerlist[i].name].recenthistory[j].itemid,
							reason		= self.activeraid[playerlist[i].name].recenthistory[j].reason,
							value		= self.activeraid[playerlist[i].name].recenthistory[j].value,
							waitlist	= self.activeraid[playerlist[i].name].recenthistory[j].waitlist,
							action	= "Delete",
						}
						db.realm.version.lastaction = actiontime
						if (whisper) then
							self:Whisper(playerlist[i].name, "Removed "..value.." points for "..reason)
						end
						self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].points - tonumber(self.activeraid[playerlist[i].name].recenthistory[j].value)
						self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].lifetime - tonumber(self.activeraid[playerlist[i].name].recenthistory[j].value)
						tremove(self.activeraid[playerlist[i].name].recenthistory,j)
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
		if (self.activeraid[playerlist[i].name]) then
			for j=1, #self.activeraid[playerlist[i].name].recentactions do
				if (self.activeraid[playerlist[i].name].recentactions[j].datetime == datetime) then
					local oldvalue = self.activeraid[playerlist[i].name].recentactions[j].value
					self.activeraid[playerlist[i].name].recentactions[j] = {
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
						self:Whisper(playerlist[i].name, "Updated points for "..reason.." Old: "..oldvalue.." New: "..points)
					end
					self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].points - oldvalue + points
					self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].lifetime - oldvalue + points
					break
				end
			end
			if (not found and player ~= "all") then
				for j=1, #self.activeraid[playerlist[i].name].recenthistory do
					if (self.activeraid[playerlist[i].name].recenthistory[j].datetime == datetime) then
						local oldvalue = self.activeraid[playerlist[i].name].recenthistory[j].value
						self.activeraid[playerlist[i].name].recenthistory[j] = {
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
							self:Whisper(playerlist[i].name, "Updated points for "..reason.." Old: "..oldvalue.." New: "..points)
						end
						self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].points - oldvalue + points
						self.activeraid[playerlist[i].name].points = self.activeraid[playerlist[i].name].lifetime - oldvalue + points
						break
					end
				end
			end
		end
	end
end

function RPB:PointsShow(player, channel, to, history)
	local playerlist = self:PlayerToArray(player);
	local playerdata
	
	if (#playerlist == 0) then
		playerlist = self:PlayerToArray(to);
	end
	
	for i=1, #playerlist do
		msg = playerlist[i].name .. ": " .. self.activeraid[playerlist[i].name].points
		if not channel then
			self:Print(msg)
		elseif not to then
			RPB:Message(channel, to, msg)
		else
			RPB:Whisper(to, msg)
		end
	end
end

function RPB:SpecialEvents_ItemLooted(recipient, item, count)
	-- When the recieved loot event fires.
	-- Goal here is to track all loot recieved events across all clients.
		-- Fires to hidden addon channel
		-- If the event is viewed by the "master", ignore this event otherwise,
			--take the first client that fired the event to the master for the next 20 seconds.  (So that duplicate data does not make it in)
	RPB:Loot(recipient, item, count, time(), false)
end

function RPB:Loot(recipient, item, count, datetime, recieved)

end

function RPB:ChatCommand(msg)
	if (not self.activeraid) then
		if (not self:UseDatabase(db.realm.settings.defaultraid)) then
			self:CreateDatabase(db.realm.settings.defaultraid)
		end
	end

	-- Get our arguements, any ones not in the command are returned as nil
	local cmd, pos = self:GetArgs(msg, 1, 1)
	self:Print(cmd, pos)
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
	self:RollListAdd(player, string.lower(cmd))
end

RPB.chatCommands["?"] = function (self, msg)
	RPB:Print("help stuff")
end
RPB.chatCommands["help"] = RPB.chatCommands["?"]

function RPB:WhisperCommand(msg, name)
	wcmd, pos = self:GetArgs(msg, 1, 1)
	-- Check to make sure the first line was "wl", otherwise this message isnt for us and we need to ignore it.
	if (string.lower(wcmd) == "bonus" or
		string.lower(wcmd) == "upgrade" or
		string.lower(wcmd) == "offspec" or
		string.lower(wcmd) == "sidegrade" or
		string.lower(wcmd) == "rot")
	then
		cmd = wcmd
		wcmd = "rp"
		self:Print(cmd)
	elseif (string.lower(wcmd) == "rp") then
		wcmd, cmd, pos = self:GetArgs(msg, 2, 1)
	end
	if (string.lower(wcmd) ~= "rp") then return false end
	
	if cmd and self.whisperCommands[string.lower(cmd)] then
		if (not self.activeraid) then
			self:UseDatabase(db.realm.settings.defaultraid)
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

function RPB:Send(cmd, data)
	if not enablecomm then return end
	self:SendCommMessage("rpb", self:Serialize(cmd,data), "GUILD")
end

function RPB:OnCommReceived(pre, message, distribution, sender)
	success, cmd, msg = self:Deserialize(message)
	--self:Print(pre, cmd, cansenderinvite, msg, distribution, sender)
	if not cmd then return end
	if cmd and self.syncCommands[string.lower(cmd)] then
		if (not self.activeraid) then
			self:UseDatabase(db.realm.settings.defaultraid)
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

