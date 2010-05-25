--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/StatusBar.lua
	* Component: Core
	* Details:
		Hooks AceComm30Frame on update event and tracks RPB commands to follow the flow of packets.
]]

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

local function MD5(data)
	return MDFive:MD5(data)
end

RPB.ip = {}
RPB.ip.incon = false
RPB.ip.inc = nil
RPB.ip.incactive = nil
RPB.ip.incl = {}
RPB.ip.incwho = nil
RPB.ip.outon = false
RPB.ip.out = nil
RPB.ip.outactive = nil
RPB.ip.outl = {}
RPB.ip.outwho = nil

local AceCommOldOnEvent = AceComm30Frame:GetScript("OnEvent")
local function RPBStausOnEvent(this, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix,message,distribution,sender = ...
		--RPB:Debug(prefix)
		if prefix == CommCmd.."SB" then
			success, cmd, length = RPB:Deserialize(message)
			--RPB:Debug(length, message)
			RPB.ip.incl[cmd] = length
			RPB.ip.inc = 0
			RPB.ip.incactive = cmd
			RPB.ip.incon = true
			RPB.ip.incwho = sender
		elseif string.sub(prefix, 1, string.len(CommCmd.."LC")) == CommCmd.."LC" then
			if RPB.ip.incon then
				RPB.ip.inc = RPB.ip.inc + 1
			end
			if (prefix == CommCmd.."LC".."\003") then
				RPB.ip.incon = false
				RPB.ip.incwho = nil
			end
		end
	end
	AceCommOldOnEvent(this, event, ...)
end
AceComm30Frame:SetScript("OnEvent", RPBStausOnEvent)

function RPBSendAddonMessage(prefix, text, chattype, destination, ...)
	if prefix == CommCmd.."SB" then
		success, cmd, length = RPB:Deserialize(text)
		--RPB:Debug(length, message)
		RPB.ip.outl[cmd] = length
		RPB.ip.out = 0
		RPB.ip.outactive = cmd
		RPB.ip.outon = true
		RPB.ip.outwho = destination
	elseif string.sub(prefix, 1, string.len(CommCmd.."LC")) == CommCmd.."LC" then
		if RPB.ip.outon then
			RPB.ip.out = RPB.ip.out + 1
		end
		if (prefix == CommCmd.."LC".."\003") then
			RPB.ip.outon = false
			RPB.ip.outwho = nil
		end
	end
end
