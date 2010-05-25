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

local cs = RPSConstants.syncCommands["Bot"]

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
		self.chatCommands["help"](self, msg)
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
	self:UpdateUI()
	self.frames["RollWindow"]:Show()
	self:Send(cs.itemlistget, "")
	self:Send(cs.rolllistget, "")
end

RPB.chatCommands["points"] = function (self, msg)
	self:CreateFramePointsViewer()
	self:UpdatePointsViewerUI()
	self.frames["PointsViewer"]:Show()
end

RPB.chatCommands["history"] = function (self, msg)
	self:UpdateHistoryViewerUI()
	self.frames["HistoryViewer"]:Show()
end

RPB.chatCommands["rules"] = function (self, msg)
	RPR.frames["RulesWindow"]:Show()
end

RPB.chatCommands["ilvl"] = function (self, msg)
	RPR.frames["ItemWindow"]:Show()
end

RPB.chatCommands["add"] = function (self, msg)
	local _, value, player, pos = self:GetArgs(msg, 3, 1)
	if not value then 
		self:Send(cs.automationget, "")
		self.frames["PointsTimer"]:Show()
	else
		local reason = string.sub(msg, pos)
		datetime = time()
		--wl = wl or false
		--function RPB:PointsAdd(raid, actiontime, datetime, player, value, ty, itemid, reason, waitlist, whisper, recieved)
		self:PointsAdd(self.rpoSettings.raid, datetime, datetime, player, value, 'P', 0, reason, false, true)
	end
end

RPB.chatCommands["additem"] = function (self, msg)
	local _, value, player, pos = self:GetArgs(msg, 3, 1)
	--playerlist = RPB:PlayerToArray(player)
	--local itemid = RPB:GetItemid(reason) or 0
	local reason = string.sub(msg, pos)
	datetime = time()
	--wl = wl or false
	self:PointsAdd(self.rpoSettings.raid, datetime, datetime, player, value, 'I', 0, reason, false, true)
end

RPB.chatCommands["show"] = function (self, msg)
	_, player, history, pos = self:GetArgs(msg, 3, 1)
	self:PointsShow(player, history, nil, history)
end

RPB.chatCommands["convert"] = function (self, msg)
	self:ConvertDatabase()
end

RPB.chatCommands["master"] = function (self, msg)
	self:SetMaster()
end

RPB.chatCommands["dbupdate"] = function (self, msg)
	if self.rpoSettings.master ~= UnitName("player") then
		self:Send(cs.dbupdate, "you", self.rpoSettings.master)
	end
end

RPB.chatCommands["dbupdateall"] = function (self, msg)
	if self.rpoSettings.master == UnitName("player") then
		self:Send(cs.dballupdate, "you")
	end
end

RPB.chatCommands["force"] = function (self, msg)
	_, player, cmd, pos = self:GetArgs(msg, 3, 1)
	if player and cmd then
		self:RollListAdd(player, cmd)
	end
end

RPB.chatCommands["clearalldatanow"] = function (self, msg)
	self.db.realm.raid = nil
	self.db.realm.player = nil
	self.db.realm.version = nil
	self.rpoSettings.dbinfo = nil
	self.rpoSettings.versioninfo = nil
	ReloadUI()
end

local helpmsg =
{
	"-- Raid Points System --",
	"  Commands:",
	"wl help - Waitlist help menu.",
	"rp help - This menu.",
	"rp settings - Opens the settings menu.",
	"rp roll - The rolling interface, this is the heart of the mod.",
	"rp points - This is the points editor, allows editing of the database.",
	"rp rules - This is the rules interface, allows costs to be set and valid whisper commands to be defined.",
	"rp ilvl - This is the ilvl editor, this allows certian items to have their ilvl reassigned.  This is more useful for tier tokens that have a generic item level.",
	"rp add <points> <list> <reason> - Adds specific number of points to a list.  List can be special keyword 'all' a speciflc player or a comma list of players 'player1,player2,player3'",
	"rp additem <points> <list> <reason> - Same as add points but specifices the item type instead of points type.",
	"rp show <list> [channel] - Shows raid point informaion, optionally choose a channel such as raid or officer.",
	"rp force <player> <command> - Force add someone to the roll window with the specific command.",
	"rp use - Assigns a new database to use.",
	"rp create - Creates a new database.",
	"rp convert - Convert an existing Ni_Karma saved variables, the Ni_Karma mod must be active.",
	"rp master - Assign yourself as the new master, same as clicking the master button in the roll window.",
	"rp dbupdate - Request an update from the current master.",
	"rp dbupdateall - -- ONLY USE IF YOU KNOW WHAT YOU ARE DOING CAN CAUSE DATA LOSS --",
	"rp clearalldatanow - -- CLEARS ALL DATA USE ONLY IF NEEDED CAUSES UI TO RELOAD AFTERWARDS --",
}
RPB.chatCommands["?"] = function (self, msg)
	for i=1, #helpmsg do
		self:Print(helpmsg[i])
	end
end
RPB.chatCommands["help"] = RPB.chatCommands["?"]

--- chatCommand: Debug.
-- @param self Reference to the mod base, since this is a table of functions.
-- @param msg The message given by the event
RPB.chatCommands["debug"] = function (self, msg)
	if self.debugOn then
		self.debugOn = false
		self:Print("Debug off")
	else
		self.debugOn = true
		self:Print("Debug on")
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
