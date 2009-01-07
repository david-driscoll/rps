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

local version = tonumber("@file-revision@") or 10000
local compversion = 67

--local MD5 = LibStub:GetLibrary("MDFive-1.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local EncodeTable

local function MD5(data)
	local code = LibCompress:fcs16init()
	code = LibCompress:fcs16update(code, data)
	code = LibCompress:fcs16final(code)
	return code
end

RPB = LibStub("AceAddon-3.0"):NewAddon("Raid Points Bot", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0", "RPLibrary", "GuildLib", "BLib")
RPB.frames = {}

local function whisperFilter()
	local settings = RPB.rpoSettings
	if 		event == "CHAT_MSG_WHISPER_INFORM"
			and settings.filterOut == "1"
			and strfind(arg1, "^"..prefix)
	then
		return true
	elseif 	event == "CHAT_MSG_WHISPER"
			and settings.filterIn == "1"
			and (
				strfind(string.lower(arg1), "^rp")
				or strfind(string.lower(arg1), "^bonus")
				or strfind(string.lower(arg1), "^upgrade")
				or strfind(string.lower(arg1), "^offspec")
				or strfind(string.lower(arg1), "^sidegrade")
				or strfind(string.lower(arg1), "^rot")
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
	rolllistclear	= "rolllistclear",
	startbidding	= "startbidding",
	starttimedbidding = "starttimedbidding",
	rolllistclick	= "rolllistclick",
	itemlistadd		= "itemlistadd",
	itemlistremove	= "itemlistremove",
	itemlistclick 	= "itemlistclick",
	itemlistclear 	= "itemlistclear",
	getmaster		= "getmaster",
	setmaster		= "setmaster",
	itemlistset		= "itemlistset",
	itemlistget		= "itemlistget",
	rolllistset		= "rolllistset",
	rolllistget		= "rolllistget",
	
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
	getla			= "getla",
	sendla			= "sendla",
	rpoSettings		= "set",
	rpbSettings		= "sb",
	dballupdate		= "dballupdate",
	setraid			= "setraid",
}
RPB.syncQueue = {}
RPB.syncHold = true

--- Initial start up processes.
-- Register chat commands, minor events and setup AceDB
function RPB:OnInitialize()
	-- Leverage SVN
	--@alpha@
	db = LibStub("AceDB-3.0"):New("rpDEBUGBotDB")
	--@end-alpha@. 
	--[===[@non-alpha@
	db = LibStub("AceDB-3.0"):New("rpbDB")
	--@end-non-alpha@]===]
	self.db = db
	self:RegisterChatCommand("rp", "ChatCommand")
	self:RegisterChatCommand("rpb", "ChatCommand")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", whisperFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", whisperFilter)
	self:RegisterComm(CommCmd)
	self:RegisterComm(CommCmd.."LC")
	self:RegisterComm("rpos")
	EncodeTable = LibCompress:GetAddonEncodeTable()
	if not db.realm.version then
		--self.activeraid = nil
		db.realm.raid = {} 
		db.realm.player = {}
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
	self:RegisterMessage("GuildLib_Update")
	
	self.rpbSettings = RPBS.db.realm.settings
	self.rpoSettings = RPOS.db.realm.settings
	self.feature = RPOS.feature
	self.options = RPBS.options

	self:RosterScan()
	self:GuildRosterScan()
	syncrequest = nil
	syncowner = nil
	syncdone = false
	--self.activeraid = nil
	
	self:CreateFrameRollWindow()
	self.timer = self:ScheduleTimer("DatabaseSync", 10)
	self.masterTimer = self:ScheduleTimer("GetMaster", math.random(15, 25))
	self:Send(cs.getmaster)
end

function RPB:DatabaseSync()
	self:Send(cs.logon, db.realm.version)
	self.timer = nil
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

function RPB:Send(cmd, data, player, compress, nopwp, comm)
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
	local senddata
	if compress then
		comm = comm .. "LC"
		senddata = self:Serialize(sendpassword,senttime,version,cmd,data)
		senddata = LibCompress:Compress(senddata)
		senddata = EncodeTable:Encode(senddata)
	else
		senddata = self:Serialize(sendpassword,senttime,version,cmd,data)
		compress = false
	end
	self:Print(comm, sendpassword,senttime,version,cmd,compress)
	
	self:SendCommMessage(comm, senddata, channel, player)
end

function RPB:Message(channel, message, to)
	ChatThrottleLib:SendChatMessage("BULK", CommCmd, prefix.." "..message, channel, nil, to);
end

function RPB:Whisper(message, to)
	RPB:Message("WHISPER", message, to);
end

function RPB:Broadcast(message)
	local channel = self.rpbSettings.broadcast
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

function RPB:UseDatabase(database, recieved)
	if (
		database
		and db.realm.raid[string.lower(database)]
		and self.rpoSettings.master == UnitName("player")
		or recieved
	) then
		self.rpoSettings.raid = string.lower(database)
		if (not recieved) then
			RPB:Send(cs.setraid, database)
		end
		--self.activeraid = db.realm.raid[string.lower(database)]
		self:Print("Now running database", string.lower(database))
		return true
	else
		self:Print("Database ",database,"does not exist!")
		return false
	end
end

function RPB:CreateDatabase(database, nouse)
	if database then
		db.realm.raid[string.lower(database)] = 
		{
		}
		self:Print("Database",database,"created!")
		local t = time()
		
	
		-- local rdd = self.rpoSettings.raidDropDown
		-- for i=1,#rdd do
			-- tremove(rdd,1)
		-- end
		-- for k,v in pairs(db.realm.raid) do
			-- RPOS:AddRaid(k)
		-- end
		--db.realm.version.lastaction = t
		--db.realm.version.database = t
		if not nouse then
			RPB:UseDatabase(database)
		end
	end
end

function RPB:CreatePlayer(player)
	local pinfo = self:GuildRosterByName(player) or self:RosterByName(player:gsub("^%l", string.upper)) or {}
	db.realm.player[string.lower(player)] = {
		id 				= -1,
		name 			= string.lower(pinfo.name or player),
		fullname 		= pinfo.name or player:gsub("^%l", string.upper),
		class			= pinfo.class or "Unknown",
		rank			= pinfo.rank or "Unknown",
		gender			= "Unknown",
		race			= "Unknown",
		talent			= "Unknown",
	}
end

function RPB:UpdatePlayer(player)
	local pinfo = self:GuildRosterByName(player) or self:RosterByName(player:gsub("^%l", string.upper)) or {}
	db.realm.player[string.lower(player)].id 			= db.realm.player[string.lower(player)].id or -1
	db.realm.player[string.lower(player)].name 			= string.lower(pinfo.name or player)
	db.realm.player[string.lower(player)].fullname 		= pinfo.name or player:gsub("^%l", string.upper)
	db.realm.player[string.lower(player)].class			= pinfo.class or db.realm.player[string.lower(player)].class
	db.realm.player[string.lower(player)].rank			= pinfo.rank or db.realm.player[string.lower(player)].rank
	db.realm.player[string.lower(player)].gender		= db.realm.player[string.lower(player)].gender or "Unknown"
	db.realm.player[string.lower(player)].race			= db.realm.player[string.lower(player)].race or "Unknown"
	db.realm.player[string.lower(player)].talent		= db.realm.player[string.lower(player)].talent or "Unknown"
end

function RPB:UpdateAllPlayers()
	for k,v in pairs(db.realm.player) do
		self:UpdatePlayer(k)
	end
end

function RPB:CreatePlayerHistory(player, raid)
	if not raid then raid = self.rpoSettings.raid end
	--if not db.realm.raid[raid] then self:CreateDatabase(raid) end
	if raid and db.realm.raid[raid] then
		db.realm.raid[raid][string.lower(player)] = 
			{
				points			= 0,
				lifetime		= 0,
				recenthistory = 
				{
					[0] = {
						datetime 	= 0,
						ty			= 'P',
						itemid		= 0,
						reason		= "Old Points",
						value		= 0,
						waitlist	= false,
						action		= "Insert",
					},
				},
				recentactions 	= {},
			}
		return db.realm.raid[raid][string.lower(player)]
	end
	return nil
end

function RPB:GetPlayer(player, col)
	if db.realm.player[string.lower(player)] then
		if col then
			return db.realm.player[string.lower(player)][col]
		else
			return db.realm.player[string.lower(player)]
		end
	end
	return nil
end

function RPB:GetPlayerHistory(player, raid)
	if not raid then raid = self.rpoSettings.raid end
	if raid then
		if not db.realm.raid[raid][string.lower(player)] then
			return self:CreatePlayerHistory(player, raid)
		else
			return db.realm.raid[raid][string.lower(player)]
		end
	end
	return nil
end

function RPB:SetPlayer(player, col, val)
	if self.rpoSettings.raid and db.realm.raid[self.rpoSettings.raid][string.lower(player)] then
		db.realm.raid[self.rpoSettings.raid][string.lower(player)][col] = val
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
				if v.class ~= "PET" then
					list[#list+1] = {
						name = v.name,
						waitlist = false
					}
				end
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

function RPB:PointsAdd(raid, datetime, player, value, ty, itemid, reason, waitlist, whisper, recieved)
	local playerlist = self:PlayerToArray(player);
	local playerdata
	if not reason then return nil end
	if not raid then return nil end

	if not recieved then
		-- Edge Case
		-- We can have two bots both running.  One is in the raid, one isn't.
		-- If the one that isnt in the raid does /rp add, both raids get points added to different people.
		-- This will cause the databases to have the same version but be missmatched giving us bad data.
		-- Fix: When all is called we need to process the playerlist and create a new one to send to the
		--	other clients. This will cause them to run the exact same command.
		-- This edge case can not happen in Update or Remove because they handle "all" differently,
		--	since they are searching the entire database to deal with that specific entry.
		local p = ""
		if player == "all" then
			for i=1, #playerlist do
				local p = p .. playerlist[i].name .. ","
			end
			p:sub(-1)
		else
			p = nil
		end
		self:Send(cs.pointsadd, {raid, datetime, p or player, value, ty, itemid, reason, waitlist, false, true})
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
		if (not db.realm.player[string.lower(playerlist[i].name)]) then
			self:CreatePlayer(playerlist[i].name)
		end
		if (not db.realm.raid[raid][string.lower(playerlist[i].name)]) then
			self:CreatePlayerHistory(playerlist[i].name, raid)
		end
		if not itemid or type(itemid) == string then
			local itemid = self:GetItemID(reason)
			itemid = tonumber(itemid)
			--itemid = tonumber(string.gsub(reason,".*(item:%d+:%d+:%d+:%d+).*","%1"))
			if not itemid then
				itemid = 0
			end
		end
		db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime] = {
			datetime 	= datetime,
			ty			= ty,
			itemid		= tonumber(itemid),
			reason		= reason,
			value		= tonumber(value),
			waitlist	= waitlist or playerlist[i].waitlist,
			action		= "Insert",
		}
		db.realm.version.lastaction = datetime
		if (whisper and not recieved) then
			if (tonumber(value) > 0) then
				self:Whisper("Added "..value.." points for "..reason, playerlist[i].name)
			else
				self:Whisper("Deducted "..(-value).." points for "..reason, playerlist[i].name)
			end
		end
		db.realm.raid[raid][string.lower(playerlist[i].name)].points 	= db.realm.raid[raid][string.lower(playerlist[i].name)].points 	+ tonumber(value)
		db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	= db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	+ tonumber(value)
	end
end

function RPB:PointsRemove(raid, datetime, player, actiontime, whisper, recieved)
	local playerlist
	-- If we're removing "all" this is a special case
	-- we want to remove all points, only in recentactions.
	if (player == "all") then
		playerlist = {}
		for name, value in pairs(db.realm.player) do
			playerlist[#playerlist+1] = { name = name, waitlist = false }
		end
	else
		playerlist = self:PlayerToArray(player)
	end
	local playerdata
	local found
	
	if not recieved then
		self:Send(cs.pointsremove, {raid, datetime, player, actiontime, false, true})
		-- self:Send(cs.pointsremove, 
			-- {
				-- ["datetime"] = datetime,
				-- ["player"] = player,
				-- ["actiontime"] = actiontime,
			-- }
		-- )
	end
	for i=1, #playerlist do
		--found = false
		--if (db.realm.raid[raid][string.lower(playerlist[i].name)]) then
			if (db.realm.raid[raid][string.lower(playelist[i].name)]) then
			
			if db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime] then
			--for k,v in pairs(self.activeraid[string.lower(playerlist[i].name)].recentactions) do
				--if (db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[k].datetime == datetime) then
					--found = true
					db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[actiontime] = {
						datetime 	= db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].datetime,
						ty			= db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].ty,
						itemid		= db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].itemid,
						reason		= db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].reason,
						value		= db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].value,
						waitlist	= db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].waitlist,
						action	= "Delete",
					}
					db.realm.version.lastaction = actiontime
					if (whisper) then
						if (whisper) then
							self:Whisper("Removed "..value.." points for "..reason, name)
						end
					end
					db.realm.raid[raid][string.lower(playerlist[i].name)].points 	= db.realm.raid[raid][string.lower(playerlist[i].name)].points 		- tonumber(db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].value)
					db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	= db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	- tonumber(db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].value)
					--tremove(self.activeraid[string.lower(playerlist[i].name)].recentactions,k)
					break
				--end
			end
			--if (not found and player ~= "all") then
				--for k,v in pairs(self.activeraid[string.lower(playerlist[i].name)].recenthistory) do
			if (db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime]) then
						db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[actiontime] = {
							datetime 	= db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].datetime,
							ty			= db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].ty,
							itemid		= db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].itemid,
							reason		= db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].reason,
							value		= db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].value,
							waitlist	= db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].waitlist,
							action	= "Delete",
						}
						db.realm.version.lastaction = actiontime
						if (whisper) then
							self:Whisper("Removed "..value.." points for "..reason, playerlist[i].name)
						end
						db.realm.raid[raid][string.lower(playerlist[i].name)].points 	= db.realm.raid[raid][string.lower(playerlist[i].name)].points 		- tonumber(db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].value)
						db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	= db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	- tonumber(db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].value)
						--tremove(self.activeraid[string.lower(playerlist[i].name)].recenthistory,k)
						break
					--end
				--end
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
		for name, value in pairs(db.realm.player) do
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
		--found = false
		if (db.realm.raid[raid][string.lower(playerlist[i].name)]) then
			if db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime] then
			--for k,v in pairs(self.activeraid[string.lower(playerlist[i].name)].recentactions) do
			--for j=1, #self.activeraid[string.lower(playerlist[i].name)].recentactions do
				--if (db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[k].datetime == datetime) then
					local oldvalue = db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].value
					db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[actiontime] = {
						datetime 	= datetime,
						ty			= ty,
						itemid		= itemid,
						reason		= reason,
						value		= points,
						waitlist	= waitlist or playerlist[i].waitlist,
						action		= "Update",
					}
					--tremove(self.activeraid[string.lower(playerlist[i].name)].recentactions,k)
					db.realm.version.lastaction = actiontime
					--found = true
					if (whisper) then
						self:Whisper("Updated points for "..reason.." Old: "..oldvalue.." New: "..points, playerlist[i].name)
					end
					db.realm.raid[raid][string.lower(playerlist[i].name)].points 	= db.realm.raid[raid][string.lower(playerlist[i].name)].points 		- oldvalue + points
					db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	= db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	- oldvalue + points
					--break
				--end
			end
			--if (not found and player ~= "all") then
				--for k,v in pairs(self.activeraid[string.lower(playerlist[i].name)].recenthistory) do
					if (db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime]) then
						local oldvalue = db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].value
						db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[actiontime] = {
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
						db.realm.raid[raid][string.lower(playerlist[i].name)].points 	= db.realm.raid[raid][string.lower(playerlist[i].name)].points 		- oldvalue + points
						db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	= db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	- oldvalue + points
						--break
					end
				--end
			--end
		end
	end
end

function RPB:CalculateLoss(points, cmd)
	local feature = self.feature[cmd]
	-- Make this loaclizable, for generic changes.
	local divisor = tonumber(feature.divisor) or tonumber(self.rpbSettings.divisor)
	-- local minclass = feature.minclass or db.realm.settings.minclass
	-- local maxclass = feature.maxclass or db.realm.settings.maxclass
	local minnonclass = tonumber(feature.minnonclass) or tonumber(self.rpbSettings.minnonclass)
	local maxnonclass = tonumber(feature.maxnonclass) or tonumber(self.rpbSettings.maxnonclass)
	local loss
	
	current = ceil( ( points / divisor ) / tonumber(self.rpbSettings.rounding) ) * tonumber(self.rpbSettings.rounding)

	-- If I want to continue with class specific item logic, this is where we do it.
	if (current < minnonclass) then
		loss = minnonclass
	elseif (current > minnonclass and (not maxnonclass or current < maxnonclass)) then
		loss = current
	else
		loss = maxnonclass
	end

	if (current > 0 and loss > current and not tonumber(self.rpbSettings.allownegative)) then
		loss = current
	end
	
	return loss
end

function RPB:CalculatePoints(player, raid)
	local phistory = self:GetPlayerHistory(player, raid)
	local points = 0
	local lifetime = 0
	for k,v in pairs(phistory.recenthistory) do
		points = points + v.value
		if v.value > 0 then
			lifetime = lifetime + v.value
		end
	end
	for k,v in pairs(phistory.recentactions) do
		points = points + v.value
		if v.value > 0 then
			lifetime = lifetime + v.value
		end
	end
	if points ~= phistory.points then
		phistory.points = points
	end
	if lifetime ~= phistory.lifetime then
		phistory.lifetime = lifetime
	end
end

function RPB:CompressPoints(player, raid)
	local phistory = self:GetPlayerHistory(player, raid)
	local points = 0
	for k,v in pairs(phistory.recentactions) do
		if phistory.recentactions[k].ty == 'I' then
			phistory.recenthistory[k] = phistory.recentactions[k]
		else
			points = points + phistory.recentactions[k].value
		end
	end
	phistory.recenthistory[0].value = phistory.recenthistory[0].value + points
	phistory.recentactions = {}
	self:CalculatePoints(player)
end

function RPB:CompressDatabase()
	if self.rpbSettings.mode == "WEB" then self:Print("You can only compress in Standalone Mode"); return end
	for k,v in pairs(db.realm.raid) do
		for key, value in pairs(v) do
			RPB:CompressPoints(key, k)
		end
	end
	local ti = time()
	db.realm.version.database = ti
	db.realm.version.lastaction = ti
	self:Print("Database Compressed!")
end

function RPB:ConvertDatabase()
	if not KarmaList then return end
	db.realm.player = {}
	db.realm.raid = {}
	for key, value in pairs(KarmaList) do
		self:CreateDatabase(key, true)
		for k, v in pairs (value) do
			if not db.realm.player[string.lower(k)] then
				db.realm.player[string.lower(k)] = {
					id 				= -1,
					name 			= string.lower(k),
					fullname 		= v.fullname or player:gsub("^%l", string.upper),
					class			= v.class or "Unknown",
					rank			= "Unknown",
					gender			= "Unknown",
					race			= "Unknown",
					talent			= "Unknown",
				}
			end
			db.realm.raid[string.lower(key)][string.lower(k)] = {
				points			= 0,
				lifetime		= 0,
				recenthistory 	=
				{
					[0] = {
						datetime 	= 0,
						ty			= 'P',
						itemid		= 0,
						reason		= "Old Points",
						value		= 0,
						waitlist	= false,
						action		= "Insert",
					},
				},
				recentactions 	= {},
			}
			for id, data in pairs(v) do
				if (tonumber(id)) then
					if data.reason == "Karma From Old Entries" then
						db.realm.raid[string.lower(key)][string.lower(k)].recenthistory[0].value = data.value
						db.realm.raid[string.lower(key)][string.lower(k)].lifetime = data.value
					else
						local timetable = 
						{
							year 	= tonumber("20"..string.sub(data.DT,7,8)),
							month 	= tonumber(string.sub(data.DT,1,2)),
							day 	= tonumber(string.sub(data.DT,4,5)),
							hour 	= tonumber(string.sub(data.DT,10,11)),
							min 	= tonumber(string.sub(data.DT,13,14)),
							sec 	= tonumber(string.sub(data.DT,16,17)),
						}
						local itemid = self:GetItemID(data.reason)
						db.realm.raid[string.lower(key)][string.lower(k)].recentactions[time(timetable)] = {
							datetime 	= time(timetable),
							ty			= data.type,
							itemid		= itemid or 0,
							reason		= data.reason,
							value		= tonumber(data.value),
							waitlist	= false,
							action		= "Insert",
						}
					end
				end
			end
			self:CalculatePoints(string.lower(k), string.lower(key))
		end
	end
	local t = time()
	self.rpoSettings.dbinfo = {}
	db.realm.version =
	{
		database = t, -- date and time downloaded from the website,
		lastaction = t, -- date and time the last action was taken
		lastloot = 0, -- date and time last looted item was taken
	}
	self:Print("Database Converted!");
end

function RPB:PointsShow(player, channel, to, history)
	local playerlist = self:PlayerToArray(player, to);
	local playerdata
	
	if (#playerlist == 0) then
		if not to then to = UnitName("player") end
		playerlist = self:PlayerToArray(string.lower(to));
	end
	
	for i=1, #playerlist do
		local wait = ""
		if playerlist[i].waitlist then
			wait = "{star}"
		end
		--self:Print(playerlist[i].name, self:GetPlayer(playerlist[i].name),  self:GetPlayerHistory(playerlist[i].name,self.rpoSettings.raid) )
		if self:GetPlayer(playerlist[i].name) and self:GetPlayerHistory(playerlist[i].name,self.rpoSettings.raid) then
			local history = self:GetPlayerHistory(playerlist[i].name,self.rpoSettings.raid)
			local p = self:GetPlayer(playerlist[i].name)
			msg = p.fullname .. ": " .. history.points
		else
			msg = player .. ": " .. "0"
		end
		if not channel then
			if wait == "{star}" then
				wait = "(wl)"
			end
			--self:Print(wait .. msg)
		elseif not to then
			RPB:Message(channel, wait .. msg)
		else
			RPB:Whisper(wait .. msg, to)
		end
	end
end

function RPB:ChatCommand(msg)
	if (not db.realm.raid[self.rpoSettings.raid]) then
		self:CreateDatabase(self.rpoSettings.raid)
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
	self:Send(cs.itemlistget, "")
	self:Send(cs.rolllistget, "")
end

RPB.chatCommands["add"] = function (self, msg)
	local _, value, player, pos = self:GetArgs(msg, 3, 1)
	--playerlist = RPB:PlayerToArray(player)
	local reason = string.sub(msg, pos)
	datetime = time()
	wl = wl or false
	RPB:PointsAdd(self.rpoSettings.raid, datetime, player, value, 'P', 0, reason, false, true)
end

RPB.chatCommands["additem"] = function (self, msg)
	local _, value, player, pos = self:GetArgs(msg, 3, 1)
	--playerlist = RPB:PlayerToArray(player)
	--local itemid = RPB:GetItemid(reason) or 0
	local reason = string.sub(msg, pos)
	datetime = time()
	wl = wl or false
	RPB:PointsAdd(self.rpoSettings.raid, datetime, player, value, 'I', 0, reason, wl, true)
end

RPB.chatCommands["show"] = function (self, msg)
	_, player, history, pos = self:GetArgs(msg, 3, 1)
	self:PointsShow(player, nil, nil, history)
end

RPB.chatCommands["convert"] = function (self, msg)
	self:ConvertDatabase()
end

RPB.chatCommands["master"] = function (self, msg)
	self:SetMaster()
end

RPB.chatCommands["dbupdate"] = function (self, msg)
	if self.rpoSettings.master ~= UnitName("player") then
		self:Send(db.dboutdate, "you", self.rpoSettings.master)
	end
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

function RPB:OnCommReceived(pre, message, distribution, sender)
	if self.rpoSettings.syncIn == "0" then return end

	if (not db.realm.raid[self.rpoSettings.raid]) then
		self:CreateDatabase(self.rpoSettings.raid)
	end
	--self:Print("RPB:OnCommReceived", pre, CommCmd.."LC", distribution, sender)
	local success, sentpassword, senttime, ver, cmd, ms
	if pre == CommCmd.."LC" then
		local data
		data = EncodeTable:Decode(message)
		data = LibCompress:Decompress(data)
		success, sentpassword, senttime, ver, cmd, msg = self:Deserialize(data)
	else
		success, sentpassword, senttime, ver, cmd, msg = self:Deserialize(message)
	end
	--self:Print(sentpassword, senttime, ver, cmd)
	local ourpassword = self.rpoSettings.syncPassword
	ourpassword = MD5(ourpassword .. senttime)
	-- Add command "by" here.
	-- If a command can be given without a password, ie for data query from a client.
	if ourpassword ~= sentpassword then return end
	if not cmd then return end

	if not self.rpoSettings.versioninfo then self.rpoSettings.versioninfo = {} end
	if not self.rpoSettings.versioninfo[sender] then self.rpoSettings.versioninfo[sender] = ver end
	if ver < compversion then
		self:Send(cs.alert, "Your bot version is out of date.  Version: "..version.." Your Version: "..ver.." Compatible Version: "..compversion..".", sender);
		return
	end
	
	--self:Print("RPB:OnCommReceived", cmd, msg, distribution, sender)
	if self.syncHold then
		if not (
			cmd == cs.getla or
			cmd == cs.sendla or
			cmd == cs.setmaster or
			cmd == cs.logon or
			cmd == cs.alert or
			cmd == cs.dboutdate or
			cmd == cs.dbupdate or
			cmd == cs.dbmd5 or
			cmd == cs.dbrequest or
			cmd == cs.dbsend
		) then
			--self:Print(self.syncHold, cmd)			
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
	--if sender ~= UnitName("player") then
		--self:Print("Checking database version...");
		if not self.rpoSettings.dbinfo then
			self.rpoSettings.dbinfo = {}
		end
		if not self.rpoSettings.dbinfo[sender] then 
			self.rpoSettings.dbinfo[sender] = 
			{
				database = msg.database, -- date and time downloaded from the website,
				lastaction = msg.lastaction, -- date and time the last action was taken
				lastloot = msg.lastloot, -- date and time last looted item was taken
			}
		end
		--self:Print("Database:", "   msg.database:", msg.database, "   db.realm.version.database:", db.realm.version.database, "   self.settings.dbinfo[sender].database:", self.rpoSettings.dbinfo[sender].database)
		--self:Print("Lastaction:", "   msg.lastaction:", msg.lastaction, "   db.realm.version.lastaction:", db.realm.version.lastaction, "   self.settings.dbinfo[sender].lastaction:", self.rpoSettings.dbinfo[sender].lastaction)
		if msg.database == db.realm.version.database then
			if msg.lastaction == db.realm.version.lastaction then
				for i=1,#self.syncQueue do
					RPB:OnCommReceived(unpack(self.syncQueue[i] or {}))
				end
				self.syncQueue = {}
				self.syncHold = false
				self.syncResync = false
				self.rpoSettings.dbinfo[sender] = 
				{
					database = db.realm.version.database, -- date and time downloaded from the website,
					lastaction = db.realm.version.lastaction, -- date and time the last action was taken
					lastloot = db.realm.version.lastloot, -- date and time last looted item was taken
				}
				--self:Print("Database is up to date")
			end
		end
		if self.rpoSettings.master == UnitName("player") then
			if msg.database == db.realm.version.database then
				if msg.lastaction < db.realm.version.lastaction then
					if self.rpoSettings.dbinfo[sender].lastaction < msg.lastaction then
						self:Send(cs.sendla, { RPB:GetLatestActions(self.rpoSettings.dbinfo[sender].lastaction), self.rpoSettings.dbinfo[sender], msg }, sender)
					else
						self:Send(cs.dboutdate, "you", sender)
					end
				elseif msg.lastaction > db.realm.version.lastaction then
					if self.rpoSettings.dbinfo[sender].lastaction < db.realm.version.lastaction then
						self:Send(cs.getla, { self.rpoSettings.dbinfo[sender].lastaction, msg }, sender)
					else
						self:Send(cs.dbupdate, "you", sender)
					end
				end
			elseif msg.database > db.realm.version.database then
				if msg.lastaction == db.realm.version.lastaction then
					self:Send(cs.dbupdate, "you", sender)
				elseif msg.lastaction < db.realm.version.lastaction then
					self:Send(cs.sendla, { RPB:GetLatestActions(self.rpoSettings.dbinfo[sender].lastaction), self.rpoSettings.dbinfo[sender], msg }, sender)
				elseif msg.lastaction > db.realm.version.lastaction then
					self:Send(cs.dbupdate, "you", sender)
				end
				-- 2 cases
				-- if msg.lastaction > db.realm.version.lastacction then we send for a sync
				-- if msg.lastaction <= db.realm.version.lastaction then we need to alert everyone about the inconistant settings, IE the savedvariables need to be uploaded.
			elseif msg.database < db.realm.version.database then
				if msg.lastaction == db.realm.version.lastaction then
					self:Send(cs.dboutdate, "you", sender)
				elseif msg.lastaction < db.realm.version.lastaction then
					self:Send(cs.dboutdate, "you", sender)
				elseif msg.lastaction > db.realm.version.lastaction then
					self:Send(cs.getla, { self.rpoSettings.dbinfo[sender].lastaction, msg }, sender)
				end
			end
		end
	--end
end

RPB.syncCommands[cs.alert] = function(self, msg, sender)
	self:Print(msg)
end

function RPB:GetLatestActions(comparetime)
	local ra = {}
	for k,v in pairs(db.realm.raid) do
		ra[k] = {}
		for player, value in pairs(v) do
			ra[k][player] = {
				points			= value.points,
				lifetime		= value.lifetime,
				recentactions 	= {},
			}
			for actiontime,recenta in pairs(value.recentactions) do
				if actiontime > comparetime then
					ra[k][player].recentactions[actiontime] = {
						datetime 	= recenta.datetime,
						ty			= recenta.ty,
						itemid		= recenta.itemid,
						reason		= recenta.reason,
						value		= recenta.value,
						waitlist	= recenta.waitlist,
						action		= recenta.action,
					}
				end
			end
			--value.recentactions
		end
	end
	return ra
end

RPB.syncCommands[cs.getla] = function(self, msg, sender)
	self.syncQueue = {}
	self.syncHold = true
	self:Send(cs.sendla, { RPB:GetLatestActions(self.rpoSettings.dbinfo[sender].lastaction), self.rpoSettings.dbinfo[sender], msg[2] }, sender, true)
	--self.latimer = self:ScheduleTimer("LastActionSync", 10, msg[2])
end

RPB.syncCommands[cs.sendla] = function(self, msg, sender)
	for k,v in pairs(msg[1]) do
		if not db.realm.raid[k] then
			self:CreateDatabase(k, true)
		end
		for player, value in pairs(v) do
			if not db.realm.raid[k][player] then
				db.realm.raid[k][player] = {
					points			= value.points,
					lifetime		= value.lifetime,
					recenthistory 	=
					{
						[0] = {
							datetime 	= 0,
							ty			= 'P',
							itemid		= 0,
							reason		= "Old Points",
							value		= 0,
							waitlist	= false,
							action		= "Insert",
						},
					},
					recentactions 	= {},
				}
			end
			for actiontime,recenta in pairs(value.recentactions) do
				--self:Print("actiontime:",actiontime,"msg[2].lastaction",msg[2].lastaction)
				if actiontime > msg[2].lastaction then
					db.realm.raid[k][player].recentactions[actiontime] = {
						datetime 	= recenta.datetime,
						ty			= recenta.ty,
						itemid		= recenta.itemid,
						reason		= recenta.reason,
						value		= recenta.value,
						waitlist	= recenta.waitlist,
						action		= recenta.action,
					}
				end
			end
			self:CalculatePoints(player)
			--value.recentactions
		end
	end
	--self:Print(msg)
	--self.latimer = self:ScheduleTimer("LastActionSync", 10)
	self.db.realm.version.database = msg[3].database
	self.db.realm.version.lastaction = msg[3].lastaction
	self:Send(cs.dboutdate, "you", sender)
end

function RPB:LastActionSync(msg)
	self:Send(cs.logon, db.realm.version)
	self.latimer = nil
end

RPB.syncCommands[cs.dboutdate] = function(self, msg, sender)
	self:Send(cs.dbupdate, "you", sender)
end

RPB.syncCommands[cs.dballupdate] = function(self, msg, sender)
	if self.rpoSettings.master ~= UnitName("player") then
		self:Send(cs.dbupdate, "you", sender)
	end
end

local dbup = {}
RPB.syncCommands[cs.dbupdate] = function(self, msg, sender)
	if not self.dbupTimer then
		self.dbupTimer = self:ScheduleTimer("DatabaseUpdate", 10)
	end
	dbup[sender] = 1
end

function RPB:DatabaseUpdate()
	self.dbupTimer = nil
	local md5Raid =
	{
		player = {},
		raid   = {},
	}
	for k,v in pairs(db.realm.raid) do
		md5Raid.raid[k] = {}
		for player, value in pairs(v) do
			md5Raid.raid[k][player] = MD5(self:Serialize(value))
		end
	end
	for k,v in pairs(db.realm.player) do
		md5Raid.player[k] = MD5(self:Serialize(value))
	end
	
	for k,v in pairs(dbup) do
		self:Send(cs.dbmd5, md5Raid, k, true)
	end
	dbup = {}
end

RPB.syncCommands[cs.dbmd5] = function(self, msg, sender)
	local md5Raid =
	{
		player = {},
		raid   = {},
	}
	for k,v in pairs(db.realm.raid) do
		md5Raid.raid[k] = {}
		for player, value in pairs(v) do
			md5Raid.raid[k][player] = MD5(self:Serialize(value))
		end
	end
	for k,v in pairs(db.realm.player) do
		md5Raid.player[k] = MD5(self:Serialize(value))
	end
	
	local requestRaid =
	{
		player = {},
		raid   = {},
	}
	for k,v in pairs(msg.raid) do
		requestRaid.raid[k] = {}
		if not md5Raid.raid[k] then
			md5Raid.raid[k] = {}
			--db.realm.raid[k] = {}
		end
		for player, value in pairs(v) do
			if not md5Raid.raid[k][player] then
				requestRaid.raid[k][player] = true
			elseif md5Raid.raid[k][player] ~= value then
				requestRaid.raid[k][player] = true
			end
		end
	end
	for k,v in pairs(msg.player) do
		if not md5Raid.player[k] then
			requestRaid.player[k] = true
		elseif md5Raid.player[k] ~= value then
			requestRaid.player[k] = true
		end
	end

	self:Send(cs.dbrequest, requestRaid, sender, true)
	
	-- for k,v in pairs(md5Raid) do
		-- if not msg[k] then
			-- self.activeraid[k].recentactions = nil
			-- self.activeraid[k].recenthistory = nil
			-- self.activeraid[k] = nil
		-- end
	-- end
end

local dbrq = {}
RPB.syncCommands[cs.dbrequest] = function(self, msg, sender)
	if not self.dbrqTimer then
		self.dbrqTimer = self:ScheduleTimer("DatabaseRequest", 10)
	end
	
	dbrq[sender] = msg
end

function RPB:DatabaseRequest()
	self.dbrqTimer = nil
	for k,v in pairs(dbrq) do
		local dataRaid =
		{
			player = {},
			raid   = {},
		}
		for key, val in pairs(v.raid) do
			if db.realm.raid[key] then
				dataRaid.raid[key] = {}
				for player, value in pairs(val) do
					if value == true then
						dataRaid.raid[key][player] = db.realm.raid[key][player]
					end
				end
			end
		end
		for key, val in pairs(v.player) do
			if val == true and db.realm.player[key] then
				dataRaid.player[key] = db.realm.player[key]
			end
		end
		self:Send(cs.dbsend, {dataRaid, db.realm.version.database, db.realm.version.lastaction}, k, true)
	end
	dbrq = {}
end

RPB.syncCommands[cs.dbsend] = function(self, msg, sender)
	if self.syncResync then
		self:Send(cs.logon, db.realm.version)
	else
		for k,v in pairs(msg[1].raid) do
			if not db.realm.raid[k] then db.realm.raid[k] = {} end
			for player, value in pairs(v) do
				db.realm.raid[k][player] = value
			end
		end
		for k,v in pairs(msg[1].player) do
			db.realm.player[k] = v
		end
		db.realm.version.database = msg[2]
		db.realm.version.lastaction = msg[3]
		for i=1,#self.syncQueue do
			RPB:OnCommReceived(unpack(self.syncQueue[i] or {}))
		end
		self.syncQueue = {}
		self.syncHold = false
		self.rpoSettings.dbinfo[sender] = 
		{
			database = db.realm.version.database, -- date and time downloaded from the website,
			lastaction = db.realm.version.lastaction, -- date and time the last action was taken
			lastloot = db.realm.version.lastloot, -- date and time last looted item was taken
		}
		if (self.rpoSettings.master == UnitName("player")) then
			self:Send(cs.dballupdate, "go")
		end
		self:Print("Database has been updated!")
	end
	self.syncResync = false
end

--- syncCommand: cs.settings.
-- Sent when the button to sync is clicked
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param sender Sender
RPB.syncCommands[cs.rpoSettings] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	local settings = self.rpoSettings
	if (settings.syncSettings == "0") then return end
	for k,v in pairs(settings) do
		if (k ~= "syncPassword" and k ~= "dbinfo") then
			if (settings[k] ~= msg[k]) then
				settings[k] = msg[k]
			end
		end
	end
	RPOS.options:refresh()
	RPBS.options:refresh()
end

--- syncCommand: cs.settings.
-- Sent when the button to sync is clicked
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
-- @param sender Sender
RPB.syncCommands[cs.rpbSettings] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	local settings = self.rpbSettings
	if (settings.syncSettings == "0") then return end
	for k,v in pairs(settings) do
		if (k ~= "syncPassword" and k ~= "dbinfo" and k ~= "versioninfo") then
			if (settings[k] ~= msg[k]) then
				settings[k] = msg[k]
			end
		end
	end
	RPOS.options:refresh()
	RPBS.options:refresh()
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

RPB.syncCommands[cs.rolllistclear] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:RollListClear(unpack(msg or {}))
	-- self:RollListUpdate(msg[1], msg[2], msg[3], msg[4])
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

RPB.syncCommands[cs.itemlistclear] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:ItemListClear(unpack(msg or {}))
	-- self:ItemListRemove(msg[1], msg[2])
end

function RPB:PushSettings(value, isGUI, isUpdate)
	self:Send(cs.rpbSettings, self.rpbSettings)
end

function RPB:ViewPoints()
	-- If Master, call data from table
	-- If Client, call sync points
end

function RPB:ViewHistory()
	-- If Master, call data from table
	-- If Client, call sync history
end

function RPB:GuildLib_Update()
	local guildRoster = self:GuildRoster()
	--if not self.rpoSettings.master then
		for key, value in pairs(guildRoster) do
			if self.rpoSettings.master and string.lower(key) == string.lower(self.rpoSettings.master) and not value["online"] then
				self:ScheduleTimer("GetMaster", math.random(1, 15))
			end
		end
	--end
end

function RPB:ChangePassword()
	self.rpoSettings.master = nil
	self:Send(cs.getmaster)
	if not self.masterTimer then
		self.masterTimer = self:ScheduleTimer("GetMaster", 10)
	end
end

RPB.syncCommands[cs.getmaster] = function(self, msg, sender)
	if self.rpoSettings.master == UnitName("player") then
		self:Send(cs.setmaster, UnitName("player"))
	elseif self.rpoSettings.master == sender then
		self:Send(cs.setmaster, sender)
	else
		if not self.masterTimer and not self.rpoSettings.master then
			self.timer = self:ScheduleTimer("DatabaseSync", 10)
		end
	end
end

RPB.syncCommands[cs.setmaster] = function(self, msg, sender)
	if sender == UnitName("player") then self:Send(cs.setraid, self.rpoSettings.raid); return end
	RPB:SetMaster(msg, true)
end

RPB.syncCommands[cs.setraid] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	if not db.realm.raid[msg] then
		RPB:CreateDatabase(msg, true)
	end
	self.rpoSettings.raid = msg
end

function RPB:GetMaster()
	self.masterTimer = nil
	if not self.rpoSettings.master or self.rpoSettings.master == "" then
		RPB:SetMaster(UnitName("player"))
	end
end

function RPB:SetMaster(player, recieved)
	if not player then player = UnitName("player") end
	self.rpoSettings.master = player
	if not recieved then
		self:Send(cs.setmaster, player)
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
