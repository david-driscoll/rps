--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/ChatCommands.lua
	* Component: Core
	* Details:
		Chat functions and responces.
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

function RPB:ChatCommand(msg)
	if (not self.db.realm.raid[self.rpoSettings.raid]) then
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
	self:UpdateUI()
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
		self:Send(self.db.dboutdate, "you", self.rpoSettings.master)
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

--- chatCommand: Debug.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPB.chatCommands["debug"] = function (self, msg)
	if self.debugOn then
		self.debugOn = false
		self:Print("Debug on")
	else
		self.debugOn = true
		self:Print("Debug off")
	end
end

--- chatCommand: Settings.
-- Opens the settings frame.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPB.chatCommands["settings"] = function (self, msg)
	InterfaceOptionsFrame_OpenToCategory(self.options)
end
RPB.chatCommands["options"] = RPB.chatCommands["settings"]
