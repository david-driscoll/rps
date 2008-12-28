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
local MD5 = LibStub:GetLibrary("MDFive-1.0")

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

local cs =
{
	rolllistadd		= "rolllistadd",
	rolllistremove	= "rolllistremove",
	rolllistupdate	= "rolllistupdate",
	rolllistaward	= "rolllistaward",
	startbidding	= "startbidding",
	starttimedbidding = "starttimedbidding",
	rolllistclick	= "rolllistclick",
	itemlistadd		= "itemlistadd",
	itemlistremove	= "itemlistremove",
	itemlistclick 	= "itemlistclick",
	getmaster		= "getmaster",
	setmaster		= "setmaster",
	
	pointsadd		= "pointsadd",
	pointsremove	= "pointsremove",
	pointsupdate	= "pointsupdate",
	loot			= "loot",
	-- Login Syncing
	logon			= "logon",
	alert			= "alert",
	dboutdate		= "dboutdate",
	dbupdate		= "dbupdate",
	dbmd5			= "dbmd5",
	dbrequest		= "dbrequest",
	dbsend			= "dbsend",
	settings		= "settings",
	-- rolllistadd		= "rla",
	-- rolllistremove	= "rlr",
	-- rolllistupdate	= "rlu",
	-- pointsadd		= "pa",
	-- pointsremove	= "pr",
	-- pointsupdate	= "pu",
	-- loot			= "lt",
	-- master			= "m",
	-- logon			= "lo",
	-- alert			= "a",
	-- dboutdate		= "dbod",
	-- dbupdate		= "dbu",
	-- dbmd5			= "db5",
	-- dbrequest		= "dbr",
	-- dbsend			= "dbs",
	--settings		= "s",
}
RPB.syncQueue = {}
RPB.syncHold = true

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
			database = 0, -- date and time downloaded from the website,
			lastaction = 0, -- date and time the last action was taken
			lastloot = 0, -- date and time last looted item was taken
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
	
	self:CreateFrameRollWindow()
	self.timer = self:ScheduleTimer("DatabaseSync", 10)
	self.master = nil
	self:Send(cs.getmaster)
	self.masterTimer = self:ScheduleTimer("GetMaster", 15)
end

function RPB:DatabaseSync()
	self:Send(cs.logon, db.realm.version)
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

function RPB:Send(cmd, data, player)
	if not enablecomm then return end
	if self.settings.syncOut == "0" then return end
	local channel = "GUILD"
	if player then
		channel = "WHISPER"
	end
	--if not enablecomm then return end
	--if data and type(data) == "table" then self:Print(unpack(data)) end
	self:SendCommMessage(CommCmd, self:Serialize(self.settings.syncPassword,cmd,data), channel, player)
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
		local t = time()
		db.realm.version.lastaction = t
		db.realm.version.database = t
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
		recenthistory 	=
			{
				datetime 	= 0,
				ty			= 'P',
				itemid		= 0,
				reason		= "Old Points",
				value		= 0,
				waitlist	= false,
				action		= "Insert",
			},
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

	if not recieved then
		self:Send(cs.pointsadd, {datetime, player, value, ty, itemid, reason, waitlist, false, true})
		-- self:Send(cs.pointsadd, 
			-- {
				-- ["datetime"] = datetime,
				-- ["player"] = player,
				-- ["value"] = value,
				-- ["ty"] = ty,
				-- ["itemid"] = itemid,
				-- ["reason"] = reason,
				-- ["waitlist"] = waitlist,
			-- }
		-- )
	end
	
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
	
	if not recieved then
		self:Send(cs.pointsremove, {datetime, player, actiontime, false, true})
		-- self:Send(cs.pointsremove, 
			-- {
				-- ["datetime"] = datetime,
				-- ["player"] = player,
				-- ["actiontime"] = actiontime,
			-- }
		-- )
	end
	
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
		
	if not recieved then
		self:Send(cs.pointsupdate, {datetime, player, value, ty, itemid, reason, waitlist, actiontime, false, true})
		-- self:Send(cs.pointsupdate, 
			-- {
				-- ["datetime"] = datetime,
				-- ["player"] = player,
				-- ["value"] = value,
				-- ["ty"] = ty,
				-- ["itemid"] = itemid,
				-- ["reason"] = reason,
				-- ["waitlist"] = waitlist,
				-- ["actiontime"] = actiontime,
			-- }
		-- )
	end

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

function RPB:CalculatePoints(player)
	local pdata = self:GetPlayer(player)
	local points = 0
	local lifetime = 0
	for i=1,#pdata.recenthistory do
		points = points + pdata.recenthistory[i].value
		if pdata.recenthistory[i].value > 0 then
			lifetime = lifetime + pdata.recenthistory[i].value
		end
	end
	for i=1,#pdata.recentactions do
		points = points + pdata.recentactions[i].value
		if pdata.recentactions[i].value > 0 then
			lifetime = lifetime + pdata.recentactions[i].value
		end
	end
	if points ~= pdata.points then
		pdata.points = points
	end
	if lifetime ~= pdata.lifetime then
		pdata.lifetime = lifetime
	end
end

function RPB:CompressPoints(player)
	self:CalculatePoints(player)
	local pdata = self:GetPlayer(player)
	local points = 0
	for i=1,#pdata.recentactions do
		if pdata.recentactions[i].ty == 'I' then
			pdata.recenthistory[#pdata.recenthistory+1] = pdata.recentactions[i]
		else
			points = points + pdata.recentactions[i].value
		end
	end
	for i=1,#pdata.recenthistory do
		if pdata.recenthistory[i].datetime == 0 and pdata.recenthistory[i].reason == "Old Points" then
			pdata.recenthistory[i].value = pdata.recenthistory[i].value + points
		end
	end
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
		if not self:GetPlayer(playerlist[i].name) then
			self:CreatePlayer(playerlist[i].name)
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

function RPB:SyncCommand()

end

function RPB:OnCommReceived(pre, message, distribution, sender)
	if self.settings.syncIn == "0" then return end

	if (not self.activeraid) then
		if (not self:UseDatabase(self.settings.raid)) then
			self:CreateDatabase(self.settings.raid)
		end
	end
	
	success, password, cmd, msg = self:Deserialize(message)
	if self.settings.syncPassword ~= password then return end
	if not cmd then return end

	--self:Print("RPB:OnCommReceived", cmd, msg, distribution, sender)
	if self.syncHold then
		if not (
			cmd == cs.getmaster or
			cmd == cs.setmaster or
			cmd == cs.logon or
			cmd == cs.alert or
			cmd == cs.dboutdate or
			cmd == cs.dbupdate or
			cmd == cs.dbmd5 or
			cmd == cs.dbrequest or
			cmd == cs.dbsend
		) then
			self:Print(self.syncHold, cmd)			
			if (
				cmd == cs.pointsadd or
				cmd == cs.pointsremove or
				cmd == cs.pointsupdate
			) then
				self.syncResync = true
				return false
			else
				self.syncQueue[#self.syncQueue+1] = {pre, message, distribution, sender}
				return false
			end
		end
	end

	if cmd and self.syncCommands[string.lower(cmd)] then
		self.syncCommands[string.lower(cmd)](self, msg, sender)
	end	
end

RPB.syncCommands = {}
RPB.syncCommands[cs.logon] = function(self, msg, sender)
	if sender ~= UnitName("player") then
		--self:Print("Database:", msg.database, db.realm.version.database)
		--self:Print("Lastaction:", msg.lastaction, db.realm.version.lastaction)
		if msg.database > db.realm.version.database then
			if msg.lastaction > db.realm.version.lastaction then
				self:Send(cs.dbupdate, "you", sender)
			elseif msg.lastaction < db.realm.version.lastaction then
				self:Send(cs.alert, "Version missmatch, please make sure the latest database is uploaded.  Any sync requests with "..UnitName("player").." will be ignored until a new database is loaded.")
			end
			-- 2 cases
			-- if msg.lastaction > db.realm.version.lastacction then we send for a sync
			-- if msg.lastaction <= db.realm.version.lastaction then we need to alert everyone about the inconistant settings, IE the savedvariables need to be uploaded.
		elseif msg.database == db.realm.version.database then
			if msg.lastaction > db.realm.version.lastaction then
				self:Send(cs.dbupdate, "you", sender)
			elseif msg.lastaction < db.realm.version.lastaction then
				self:Send(cs.dboutdate, "you", sender)
			else
				self.syncQueue = {}
				self.syncHold = false
				self.syncResync = false
			end
		elseif msg.database < db.realm.version.database then
			if msg.lastaction < db.realm.version.lastaction then
				self:Send(cs.alert, "Version missmatch, please make sure the latest database is uploaded.  Any sync requests with "..sender.." will be ignored until a new database is loaded.")
			else
				self:Send(cs.dboutdate, "you", sender)
			end
		end
	end
end

RPB.syncCommands[cs.alert] = function(self, msg, sender)
	self:Print(msg)
end

RPB.syncCommands[cs.dboutdate] = function(self, msg, sender)
	self:Send(cs.dbupdate, "you", sender)
end

local dbup = {}
RPB.syncCommands[cs.dbupdate] = function(self, msg, sender)
	if not self.dbupTimer then
		self.dbupTimer = self:ScheduleTimer("DatabaseUpdate", 10)
	end
	dbup[sender] = 1
end

function RPB:DatabaseUpdate()
	local md5Raid = {}
	for k,v in pairs(self.activeraid) do
		md5Raid[k] = MD5:MD5(self:Serialize(v))
	end
	
	for k,v in pairs(dbup) do
		self:Send(cs.dbmd5, md5Raid, k)
	end
	dbup = {}
	self.dbupTimer = nil
end

RPB.syncCommands[cs.dbmd5] = function(self, msg, sender)
	local md5Raid = {}
	for k,v in pairs(self.activeraid) do
		md5Raid[k] = MD5:MD5(self:Serialize(v))
	end
	
	local requestRaid = {}
	for k,v in pairs(msg) do
		if not md5Raid[k] then
			requestRaid[k] = true
		elseif md5Raid[k] ~= v then
			requestRaid[k] = true
		end
	end

	self:Send(cs.dbrequest, requestRaid, sender)
	
	for k,v in pairs(md5Raid) do
		if not msg[k] then
			self.activeraid[k].recentactions = nil
			self.activeraid[k].recenthistory = nil
			self.activeraid[k] = nil
		end
	end
end

local dbrq = {}
RPB.syncCommands[cs.dbrequest] = function(self, msg, sender)
	if not self.dbrqTimer then
		self.dbrqTimer = self:ScheduleTimer("DatabaseRequest", 10)
	end
	
	dbrq[sender] = msg
end

function RPB:DatabaseRequest()
	for k,v in pairs(dbrq) do
		local dataRaid = {}
		for key, value in pairs(v) do
			if value == true then
				dataRaid[key] = self.activeraid[key]
			end
		end
		self:Send(cs.dbsend, {dataRaid, db.realm.version.database, db.realm.version.lastaction}, k)
	end
	dbrq = {}
	self.dbrqTimer = nil
end

RPB.syncCommands[cs.dbsend] = function(self, msg, sender)
	if self.syncResync then
		self:Send(cs.logon, db.realm.version)
	else
		for k,v in pairs(msg[1]) do
			self.activeraid[k] = v
		end
		db.realm.version.database = msg[2]
		db.realm.version.lastaction = msg[3]
		for i=1,#self.syncQueue do
			RPB:OnCommReceived(unpack(self.syncQueue[i] or {}))
		end
		self.syncQueue = {}
		self.syncHold = false
	end
	self.syncResync = false
end

--- syncCommand: cs.settings.
-- Sent when the button to sync is clicked
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param sender Sender
RPB.syncCommands[cs.settings] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	local settings = self.settings
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

RPB.syncCommands[cs.pointsadd] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:PointsAdd(unpack(msg or {}))
end

RPB.syncCommands[cs.pointsremove] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:PointsRemove(unpack(msg or {}))
end

RPB.syncCommands[cs.pointsupdate] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:PointsUpdate(unpack(msg or {}))
end

RPB.syncCommands[cs.getmaster] = function(self, msg, sender)
	if self.master == UnitName("player") then
		self:Send(cs.setmaster, "")
	end
end

RPB.syncCommands[cs.setmaster] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	RPB:SetMaster(sender, true)
end

RPB.syncCommands[cs.rolllistadd] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	--self:Print(msg[1], msg[2], msg[3], #msg)
	self:RollListAdd(unpack(msg or {}))
	-- self:RollListAdd(msg[1], msg[2], msg[3])
end

RPB.syncCommands[cs.rolllistremove] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:RollListRemove(unpack(msg or {}))
	-- self:RollListRemove(msg[1], msg[2])
end

RPB.syncCommands[cs.rolllistupdate] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:RollListUpdate(unpack(msg or {}))
	-- self:RollListUpdate(msg[1], msg[2], msg[3], msg[4])
end

--  Constants Roll List
local crl = 
{
	player = 1,
	class = 2,
	rank = 3,
	ty = 4,
	current = 5,
	roll = 6,
	loss = 7,
}

RPB.syncCommands[cs.rolllistclick] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	local list = self.frames["RollWindow"].rollList
	for i=1,#list do
		if (list[i].cols[crl.player].value == msg[crl.player]) then
			self.frames["RollWindow"].scrollFrame.selected = list[i]
			break
		end
	end
	self.frames["RollWindow"].scrollFrame:SortData()
end

-- Constants Loot List
local cll = 
{
	link = 1,
	item = 2,
	count = 3,
	quality = 4,
}

RPB.syncCommands[cs.itemlistclick] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	local list = self.frames["RollWindow"].lootList
	--self:Print(msg, unpack(msg or {}))
	for i=1,#list do
		if (list[i].cols[cll.item].value == msg[cll.item]) then
			self.frames["RollWindow"].scrollFrameLoot.selected = list[i]
			break
		end
	end
	self.frames["RollWindow"].scrollFrameLoot:SortData()
end

RPB.syncCommands[cs.startbidding] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:StartBidding(unpack(msg or {}))
	-- self:StartBidding(msg[1])
end

RPB.syncCommands[cs.starttimedbidding] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:StartTimedBidding(unpack(msg or {}))
	-- self:StartTimedBidding(msg[1])
end

RPB.syncCommands[cs.rolllistaward] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:RollListAward(unpack(msg or {}))
	-- self:RollListAward(msg[1])
end

RPB.syncCommands[cs.itemlistadd] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	--self:Print(unpack(msg or {}))
	self:ItemListAdd(unpack(msg or {}))
	-- self:Print(msg[1], msg[2], msg[3], msg[4], msg[5], #msg)
	-- self:ItemListAdd(msg[1], msg[2], msg[3], msg[4], msg[5])
end

RPB.syncCommands[cs.itemlistremove] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:ItemListRemove(unpack(msg or {}))
	-- self:ItemListRemove(msg[1], msg[2])
end

function RPB:PushSettings(value, isGUI, isUpdate)
	self:Send(cs.settings, self.settings)
end

function RPB:ViewPoints()
	-- If Master, call data from table
	-- If Client, call sync points
end

function RPB:ViewHistory()
	-- If Master, call data from table
	-- If Client, call sync history
end


function RPB:GetMaster()
	if not self.master then
		RPB:SetMaster(UnitName("player"))
	end
end

function RPB:SetMaster(player, recieved)
	if not player then player = UnitName("player") end
	self.master = player
	if not recieved then
		self:Send(cs.setmaster, {player, true})
	end
	if player == UnitName("player") then
		self.frames["RollWindow"].button["StartBidding"]:Enable()
		self.frames["RollWindow"].button["StartTimedBidding"]:Enable()
		self.frames["RollWindow"].button["StopBidding"]:Disable()
		self.frames["RollWindow"].button["AwardItem"]:Enable()
		self.frames["RollWindow"].button["ClearList"]:Enable()
		self.frames["RollWindow"].button["AddItem"]:Enable()
		self.frames["RollWindow"].button["RemoveItem"]:Enable()
		self.frames["RollWindow"].button["RollClear"]:Enable()
		self.frames["RollWindow"].button["Master"]:Disable()
	else
		self.frames["RollWindow"].button["StartBidding"]:Disable()
		self.frames["RollWindow"].button["StartTimedBidding"]:Disable()
		self.frames["RollWindow"].button["StopBidding"]:Disable()
		self.frames["RollWindow"].button["AwardItem"]:Disable()
		self.frames["RollWindow"].button["ClearList"]:Disable()
		self.frames["RollWindow"].button["AddItem"]:Disable()
		self.frames["RollWindow"].button["RemoveItem"]:Disable()
		self.frames["RollWindow"].button["RollClear"]:Disable()
		self.frames["RollWindow"].button["Master"]:Enable()
	end
end
