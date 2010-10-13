--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/WhisperCommands.lua
	* Component: Core
	* Details:
		Whisper functions and responces.
]]

--- Event: CHAT_MSG_WHISPER.
-- Fires when any whisper has been recieved
-- param arg1 = Message received 
-- param arg2 = Author 
-- param arg3 = Language (or nil if universal, like messages from GM) (always seems to be an empty string; argument may have been kicked because whispering in non-standard language doesn't seem to be possible [any more?]) 
-- param arg6 = status (like "DND" or "GM") 
-- param arg7 = (number) message id (for reporting spam purposes?) (default: 0) 
-- param arg8 = (number) unknown (default: 0)
function RPB:CHAT_MSG_WHISPER(event, ...)
	-- Fire our event off to our handler
	local arg1, arg2 = ...
	-- TODO: Hide or Show whispers depending on the state that whisper command comes back as.
	--		This will let us hide the whisper if settings tell us to.
	self:WhisperCommand(arg1, arg2)
end

function RPB:WhisperCommand(msg, name)
	wcmd, pos = self:GetArgs(msg, 2, 1)
	-- Check to make sure the first line was "wl", otherwise this message isnt for us and we need to ignore it.
	if (string.lower(wcmd) == RPR.cmd1 or
		string.lower(wcmd) == RPR.cmd2 or
		string.lower(wcmd) == RPR.cmd3 or
		string.lower(wcmd) == RPR.cmd4 or
		string.lower(wcmd) == RPR.cmd5)
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

local helpmsg =
{
	"-- Raid Points Waitlist --",
	"  List can be special keyword 'all', a class, 'tier', a speciflc player or a comma list of players 'player1,player2,player3'",
	"  Commands:",
	"rp help - This menu.",
	"rp show <list> - Shows raid informaion, optionally choose a channel such as raid or officer.",
}
RPB.whisperCommands["?"] = function (self, msg, name)
	for i=1, #helpmsg do
		self:Whisper(helpmsg[i], name)
	end
end
RPB.whisperCommands["help"] = RPB.whisperCommands["?"]
