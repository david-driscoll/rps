--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/SyncCommands.lua
	* Component: Core
	* Details:
		Sync functions and responces.
]]


local cs =
{
	rolllistadd		= "rolllistadd",
	rolllistremove	= "rolllistremove",
	rolllistupdateroll	= "rolllistupdateroll",
	rolllistupdatetype	= "rolllistupdatetype",
	rolllistdisenchant	= "rolllistdisenchant",
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

local dbup = {}
local dbrq = {}

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
	self:Debug("RPB:Send", comm, sendpassword,senttime,version,cmd,compress)
	
	self:SendCommMessage(comm, senddata, channel, player)
end

function RPB:OnCommReceived(pre, message, distribution, sender)
	if self.rpoSettings.syncIn == "0" then return end

	if (not db.realm.raid[self.rpoSettings.raid]) then
		self:CreateDatabase(self.rpoSettings.raid)
	end
	--self:Debug("RPB:OnCommReceived", pre, CommCmd.."LC", distribution, sender)
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
	self.rpoSettings.versioninfo[sender] = ver
	if ver < compversion then
		self:Send(cs.alert, "Your bot version is out of date.  Version: "..version.." Your Version: "..ver.." Compatible Version: "..compversion..".", sender);
		return
	end
	
	self:Debug("RPB:OnCommReceived", cmd, msg, distribution, sender)
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
		md5Raid.player[k] = MD5(self:Serialize(v))
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

RPB.syncCommands[cs.rolllistupdatetype] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:RollListUpdateType(msg[1], msg[2], true)
	-- self:RollListUpdate(msg[1], msg[2], msg[3], msg[4])
end

RPB.syncCommands[cs.rolllistupdateroll] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	--self:Print("cs.rolllistupdateroll fired!", sender)
	self:RollListUpdateRoll(msg[1], msg[2], true)
	-- self:RollListUpdate(msg[1], msg[2], msg[3], msg[4])
end

RPB.syncCommands[cs.rolllistdisenchant] = function(self, msg, sender)
	if sender == UnitName("player") then return end
	self:RollListDisenchant(true)
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

function RPB:ChangePassword(password)
	if not password then
		password = self.rpoSettings.syncPassword
	end
	if not self.passwordTimer then
		self.passwordTimer = self:ScheduleTimer("ChangePassword", 3, self.rpoSettings.syncPassword)
	else
		self.passwordTimer = nil
		if password == self.rpoSettings.syncPassword then
			self:Send(cs.logon, "me")
		else
			self.passwordTimer = self:ScheduleTimer("ChangePassword", 3, self.rpoSettings.syncPassword)
		end
	end
end

function RPB:GetMaster()
	self.masterTimer = nil
	if not self.rpoSettings.master or self.rpoSettings.master == "" then
		RPB:SetMaster(UnitName("player"))
	end
end

function RPB:SetMaster(player, recieved)
	local f = self.frames["RollWindow"]
	if not player then player = UnitName("player") end
	self.rpoSettings.master = player
	if not recieved then
		self:Send(cs.setmaster, player)
	end
	self:UpdateUI()
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
