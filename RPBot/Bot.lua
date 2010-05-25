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

local MDFive = LibStub:GetLibrary("MDFive-1.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local EncodeTable
local recHistory

local function MD5(data)
	return MDFive:MD5(data)
end

local cs = RPSConstants.syncCommands["Bot"]
local csp = RPSConstants.syncCommandsPriority["Bot"]

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
				or strfind(string.lower(arg1), "^"..RPR.cmd1)
				or strfind(string.lower(arg1), "^"..RPR.cmd2)
				or strfind(string.lower(arg1), "^"..RPR.cmd3)
				or strfind(string.lower(arg1), "^"..RPR.cmd4)
				or strfind(string.lower(arg1), "^"..RPR.cmd5)
			)
	then
		return true
	end
	return false
end

function RPB:Debug(...)
	if self.debugOn then
		if _Dev then
			temp = {}
			for i=1,select('#', ...) do
				temp[i] = select(i, ...)
			end
			dump("Debug", temp)
		else
			self:Print(...)
		end
	end
end

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
	local broke = false
	for k,v in pairs(db.realm.raid) do
		for key, value in pairs(v) do
			for key2, value2 in pairs(value.recenthistory) do
				if value2.link == nil or value2.actiontime == nil then
					value2.link = 0
					value2.actiontime = value2.datetime
				else
					broke = true
					break
				end
			end
			if broke then
				break
			end
			for key2, value2 in pairs(value.recentactions) do
				if value2.link == nil or value2.actiontime == nil then
					value2.link = 0
					value2.actiontime = value2.datetime
				else
					broke = true
					break
				end
			end
			if broke then
				break
			end
		end
		if broke then
			break
		end
	end
	self.debugOn = false

	hooksecurefunc("SendAddonMessage", function(...)
		return RPBSendAddonMessage(...)
	end)
end

--- Enable processes
-- Register all events, setup inital state and load rules set
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
	self.RPRSettings = RPR.db.realm.settings
	--self.rules = RPR.rules
	self.options = RPBS.options

	self:RosterScan()
	self:GuildRosterScan()
	syncrequest = nil
	syncowner = nil
	syncdone = false
	--self.activeraid = nil
	
	self:CreateFrameRollWindow()
	self:CreateFramePointsTimer()
	--self:CreateFrameHistoryViewer()
	self.timer = self:ScheduleTimer("DatabaseSync", 10)
	self.masterTimer = self:ScheduleTimer("GetMaster", math.random(15, 25))
	self:Send(cs.getmaster)
	
	if (UnitName("player") == "Sithie" or UnitName("player") == "Sithy") then
		self.debugOn = true
	end
	
	db.realm.version.rules = RPR.db.realm.settings.version
	db.realm.version.item = RPR.db.realm.settings.itemversion
	db.realm.version.bot = RPSsyncVersion
	--self.rules = RPR.rules
end

function RPB:DatabaseSync()
	self:Send(cs.logon, db.realm.version)
	self.timer = nil
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
		self:UpdateUI()
		self.frames["RollWindow"].dropdown["Raid"]:SetValue(self.rpoSettings.raid)
		return true
	else
		self:Print("Database",database,"does not exist!")
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
		self.frames["RollWindow"].dropdown["Raid"]:AddItem(database, database)
		if self.frames["PointsViewer"] then
			self.frames["PointsViewer"].dropdown["Raid"]:AddItem(database, database)
		end

	
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
	if raid and db.realm.raid[raid] and player then
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
	if player and db.realm.player[string.lower(player)] and not db.realm.player[string.lower(player)].delete then
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
	if raid and player then
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
				if (RPSConstants.classList[string.lower(splitlist[i])]) then
					local class = RPSConstants.classList[string.lower(splitlist[i])]
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
							local tier = RPSConstants.tierList[roster[to].class]
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

function RPB:PointsAdd(raid, actiontime, datetime, player, value, ty, itemid, reason, waitlist, whisper, recieved)
	local playerlist
	
	if not actiontime then
		actiontime = datetime
	end
	if type(player) == "table" then
		playerlist = player
	else
		playerlist = self:PlayerToArray(player);
	end
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
		self:Send(cs.pointsadd, {raid, actiontime, datetime, playerlist, value, ty, itemid, reason, waitlist, false, true})
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
			actiontime 	= actiontime,
			datetime 	= datetime,
			link	 	= 0,
			ty			= ty,
			itemid		= tonumber(itemid),
			reason		= reason,
			value		= tonumber(value),
			waitlist	= waitlist or playerlist[i].waitlist,
			action		= "Insert",
		}
		db.realm.version.lastaction = actiontime
		if (whisper and not recieved) then
			if (tonumber(value) >= 0) then
				self:Whisper("Added "..value.." points for "..reason, playerlist[i].name)
			else
				self:Whisper("Deducted "..(-value).." points for "..reason, playerlist[i].name)
			end
		end
		--db.realm.raid[raid][string.lower(playerlist[i].name)].points 	= db.realm.raid[raid][string.lower(playerlist[i].name)].points 	+ tonumber(value)
		--db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	= db.realm.raid[raid][string.lower(playerlist[i].name)].lifetime 	+ tonumber(value)
		self:CalculatePoints(string.lower(playerlist[i].name), raid)
	end
end

local function LastLink(entry, phistory)
	local p = 0
	local myentry = nil
	
	if phistory then
		recHistory = phistory
	end
	
	local datetime = tonumber(entry)
	if datetime and datetime > 0 then
		if recHistory.recentactions[datetime] then
			entry = recHistory.recentactions[datetime]
		else
			entry = recHistory.recenthistory[datetime]
		end
	end
	if entry and entry.link and entry.link > 0 then
		--local obj
		if recHistory.recentactions[entry.link] then
			--obj = recHistory.recentactions[entry.link]
			myentry = LastLink(entry.link)
		elseif recHistory.recenthistory[entry.link] then
			--obj = recHistory.recentactions[entry.link]
			myentry = LastLink(entry.link)
		end
	else
		myentry = entry
	end
	return myentry
end

-- local function LastLinkValue(entry, phistory)
	-- local e = LastLink(entry, phistory)
	-- if e.action == "Delete" then
		-- return (-e.value)
	-- else
		-- return e.value
	-- end
-- end

function RPB:PointsRemove(raid, removetime, actiontime, datetime, player, whisper, recieved)
	local playerlist
	
	-- local link
	-- if not actiontime then
		-- actiontime = datetime
	-- end	
	-- if actiontime ~= datetime then
		-- link = actiontime
	-- else
		-- link = 0
	-- end
	
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
		self:Send(cs.pointsremove, {raid, removetime, actiontime, datetime, player, false, true})
	end
	for i=1, #playerlist do
		if (db.realm.raid[raid][string.lower(playerlist[i].name)]) then
			if db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime] then
				local obj = db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime]
				--local points = LastLinkValue(datetime, db.realm.raid[raid][string.lower(playerlist[i].name)])
				db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[removetime] = {
					actiontime 	= actiontime,
					datetime 	= datetime,
					link	 	= 0,
					ty			= obj.ty,
					itemid		= obj.itemid,
					reason		= obj.reason,
					value		= (0-obj.value),
					waitlist	= obj.waitlist,
					action		= "Delete",
					}
				LastLink(datetime, db.realm.raid[raid][string.lower(playerlist[i].name)]).link = removetime
				db.realm.version.lastaction = removetime
				if (whisper) then
					local value = db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime].value
					if (tonumber(value) >= 0) then
						self:Whisper("Entry Removed: \"Added "..value.." points for "..obj.reason.."\"", name)
					else
						self:Whisper("Entry Removed: \"Deducted "..(-value).." points for "..obj.reason.."\"", name)
					end
				end
			end

			if (db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime]) then
				local obj = db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime]
				--local points = LastLinkValue(datetime, db.realm.raid[raid][string.lower(playerlist[i].name)])
				db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[removetime] = {
					actiontime 	= actiontime,
					datetime 	= datetime,
					link	 	= 0,
					ty			= obj.ty,
					itemid		= obj.itemid,
					reason		= obj.reason,
					value		= (0-obj.value),
					waitlist	= obj.waitlist,
					action		= "Delete",
				}
				LastLink(datetime, db.realm.raid[raid][string.lower(playerlist[i].name)]).link = removetime
				db.realm.version.lastaction = removetime
				if (whisper) then
					local value = db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime].value
					if (tonumber(value) >= 0) then
						self:Whisper("Entry Removed: \"Added "..value.." points for "..obj.reason.."\"", name)
					else
						self:Whisper("Entry Removed: \"Deducted "..(-value).." points for "..obj.reason.."\"", name)
					end
				end
			end
		end
		self:CalculatePoints(string.lower(playerlist[i].name), raid)
	end
end

function FollowLink(entry, phistory)
	local p, l, mylink = 0, 0, nil
	
	if phistory then
		recHistory = phistory
	end
	
	local datetime = tonumber(entry)
	if datetime and datetime >= 0 then
		if recHistory.recentactions[datetime] then
			entry = recHistory.recentactions[datetime]
		else
			entry = recHistory.recenthistory[datetime]
		end
	end	

	if entry and entry.link then
		if entry.link > 0 and recHistory.recentactions[entry.link] then
			--obj = phistory.recentactions[entry.link]
			p, l, mylink = FollowLink(entry.link)
		elseif entry.link > 0 and recHistory.recenthistory[entry.link] then
			--obj = phistory.recentactions[entry.link]
			p, l, mylink = FollowLink(entry.link)
		elseif entry.link == 0 then
			p = p + entry.value
			if (entry.action == "Delete") then
				if (entry.value > 0) then
					l = l - entry.value
				end
			else
				if (entry.value > 0) then
					l = l + entry.value
				end
			end
			mylink = entry
		end
	end
	return p, l, mylink
end

function RPB:PointsUpdate(raid, updatetime, actiontime, datetime, player, value, ty, itemid, reason, waitlist, whisper, recieved)
	local playerlist
	
	-- local link
	-- if not actiontime then
		-- actiontime = datetime
	-- end	
	-- if actiontime ~= datetime then
		-- link = actiontime
	-- else
		-- link = 0
	-- end
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
		self:Send(cs.pointsupdate, {raid, updatetime, actiontime, datetime, player, value, ty, itemid, reason, waitlist, false, true})
	end
	
	RPB:Debug({["raid"]=raid, ["updatetime"]=updatetime, ["actiontime"]=actiontime, ["datetime"]=datetime, ["player"]=player, ["value"]=value, ["ty"]=ty, ["itemid"]=itemid, ["reason"]=reason, ["waitlist"]=waitlist})

	for i=1, #playerlist do
		if (db.realm.raid[raid][string.lower(playerlist[i].name)]) then
			if db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime] then
				local obj = db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[datetime]
				--local points, _ = FollowLink(datetime, db.realm.raid[raid][string.lower(playerlist[i].name)])
				local points = value - obj.value
				db.realm.raid[raid][string.lower(playerlist[i].name)].recentactions[updatetime] = {
					actiontime	= actiontime,
					datetime 	= datetime,
					link		= 0,
					ty			= ty,
					itemid		= itemid,
					reason		= reason,
					value		= points,
					waitlist	= waitlist or playerlist[i].waitlist,
					action		= "Update",
				}
				LastLink(datetime, db.realm.raid[raid][string.lower(playerlist[i].name)]).link = updatetime
				db.realm.version.lastaction = updatetime
				if (whisper) then
					self:Whisper("Updated points for "..reason.." New: "..points, playerlist[i].name)
				end
			end
			if (db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime]) then
				local obj = db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[datetime]
				--local points, _ = FollowLink(datetime, db.realm.raid[raid][string.lower(playerlist[i].name)])
				local points = value - obj.value
				db.realm.raid[raid][string.lower(playerlist[i].name)].recenthistory[updatetime] = {
					actiontime	= actiontime,
					datetime 	= datetime,
					link		= 0,
					ty			= ty,
					itemid		= itemid,
					reason		= reason,
					value		= points,
					waitlist	= waitlist or playerlist[i].waitlist,
					action		= "Update",
				}
				LastLink(datetime, db.realm.raid[raid][string.lower(playerlist[i].name)]).link = updatetime
				db.realm.version.lastaction = updatetime
				if (whisper) then
					self:Whisper("Updated points for "..reason.." New: "..points, playerlist[i].name)
				end
			end
		end
		self:CalculatePoints(string.lower(playerlist[i].name), raid)
	end
end

function RPB:CalculatePoints(player, raid)
	local phistory = self:GetPlayerHistory(player, raid)
	local points = 0
	local lifetime = 0
	
	-- This code is insufficent to deal with Delete and Update entries!
	-- for k,v in pairs(phistory.recenthistory) do
		-- points = points + v.value
		-- if v.value > 0 then
			-- lifetime = lifetime + v.value
		-- end
	-- end
	-- for k,v in pairs(phistory.recentactions) do
		-- points = points + v.value
		-- if v.value > 0 then
			-- lifetime = lifetime + v.value
		-- end
	-- end
	
	-- How to handle delete and update entries
		-- Follow the'link' back to the the base entry.
		-- Find all entries that affect this base entry, or datetime
		-- Calculate the points that entry really grants.
			-- Update changes the point total.
				-- Only the last update counts.
			-- Delete inverts the point total.
				-- Two deletes negate eachother.
	for udtime, entry in pairs(phistory.recenthistory) do
		if entry.actiontime == nil or entry.link == nil then
			entry.actiontime = entry.datetime
			entry.link = 0
		end
		if entry.datetime == entry.actiontime then
			local p, l, flink = FollowLink(udtime, phistory)
			if (flink == entry) then
				points  = points + p
				if (entry.action == "Delete") then
					if (l > 0) then
						lifetime = lifetime - l
					end
				else
					if (l > 0) then
						lifetime = lifetime + l
					end
				end
			else
				points  = points + p + entry.value
				if (entry.action == "Delete") then
					if (entry.value > 0) then
						lifetime = lifetime - entry.value
					end
					if (l > 0) then
						lifetime = lifetime - l
					end
				else
					if (entry.value > 0) then
						lifetime = lifetime + entry.value
					end
					if (l > 0) then
						lifetime = lifetime + l
					end
				end
				self:Debug({["p"]=p, ["l"]=l, ["entry.value"]=entry.value})
			end
			self:Debug(points, lifetime)
		end
	end
	
	for udtime, entry in pairs(phistory.recentactions) do
		if entry.datetime == entry.actiontime then
			local p, l, flink = FollowLink(udtime, phistory)
			if (flink == entry) then
				points  = points + p
				if (entry.action == "Delete") then
					if (l > 0) then
						lifetime = lifetime - l
					end
				else
					if (l > 0) then
						lifetime = lifetime + l
					end
				end
			else
				points  = points + p + entry.value
				if (entry.action == "Delete") then
					if (entry.value > 0) then
						lifetime = lifetime - entry.value
					end
					if (l > 0) then
						lifetime = lifetime - l
					end
				else
					if (entry.value > 0) then
						lifetime = lifetime + entry.value
					end
					if (l > 0) then
						lifetime = lifetime + l
					end
				end
			end
			self:Debug(points, lifetime)
		end
	end
	
	if points ~= phistory.points then
		phistory.points = points
	end
	if lifetime ~= phistory.lifetime then
		phistory.lifetime = lifetime
	end
end

function RPB:CalculateLoss(points, cmd)
	--self:Debug(points, cmd)
	local rules = RPR.rules[string.lower(cmd)]
	-- Make this loaclizable, for generic changes.
	local divisor = tonumber(rules.divisor) or tonumber(self.rpbSettings.divisor)
	-- local minclass = rules.minclass or db.realm.settings.minclass
	-- local maxclass = rules.maxclass or db.realm.settings.maxclass
	local minnonclass = tonumber(rules.minnonclass) or tonumber(self.rpbSettings.minnonclass)
	local maxnonclass = tonumber(rules.maxnonclass) or tonumber(self.rpbSettings.maxnonclass) or nil
	local loss
	local total
	
	total = ceil( ( (points*1.0) / divisor ) / tonumber(self.rpbSettings.rounding) ) * tonumber(self.rpbSettings.rounding)

	-- If I want to continue with class specific item logic, this is where we do it.
	if (total <= minnonclass) then
		loss = minnonclass
	elseif (total > minnonclass and (not maxnonclass or maxnonclass == -1 or total <= maxnonclass)) then
		loss = total
	else
		loss = maxnonclass
	end

	if (total > 0 and loss > total and not tonumber(self.rpbSettings.allownegative)) then
		loss = total
	end
	
	return loss
end

function RPB:CalculateMaxPoints(points, cmd)
	local rules = RPR.rules[string.lower(cmd)]
	-- Make this loaclizable, for generic changes.
	local maxpoints = rules.maxpoints or tonumber(self.rpbSettings.maxpoints) or 0
	local maxclass = rules.maxclass or tonumber(self.rpbSettings.maxclass) or 0
	local maxnonclass = rules.maxnonclass or tonumber(self.rpbSettings.maxnonclass) or 0
	local total = points
	if maxpoints == 0 and (maxclass == 0 and maxnonclass == 0) then
		total = 0
	elseif maxpoints > 0 then
		if total > maxpoints then
			total = maxpoints
		end
	end
	return total
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
	
	if (channel == "history" or history == "history") then
		
	else
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
				self:Print(wait .. msg)
			elseif not to then
				RPB:Message(channel, wait .. msg)
			else
				RPB:Whisper(wait .. msg, to)
			end
		end
	end
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
