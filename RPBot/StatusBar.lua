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
RPB.ip.incon = {}
RPB.ip.inc = {}
RPB.ip.incactive = {}
RPB.ip.incl = {}
RPB.ip.incwho = {}
RPB.ip.outon = {}
RPB.ip.out = {}
RPB.ip.outactive = {}
RPB.ip.outl = {}
RPB.ip.outwho = {}

local AceCommOldOnEvent = AceComm30Frame:GetScript("OnEvent")
local function RPBStausOnEvent(this, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix,message,distribution,sender = ...
		--RPB:Debug(prefix)
		if prefix == CommCmd.."SB" then
			success, cmd, length = RPB:Deserialize(message)
			--RPB:Debug(length, message)
			if not RPB.ip.incl[sender] then
				RPB.ip.incl[sender] = {}
			end
			RPB.ip.incl[sender][cmd] = length
			RPB.ip.inc[sender] = 0
			RPB.ip.incactive[sender] = cmd
			RPB.ip.incon[sender] = true
			RPB.ip.incwho[sender] = sender
		elseif string.sub(prefix, 1, string.len(CommCmd.."LC")) == CommCmd.."LC" then
			if RPB.ip.incon[sender] then
				RPB.ip.inc[sender] = RPB.ip.inc[sender] + 1
			end
			if (prefix == CommCmd.."LC".."\003") then
				RPB.ip.incon[sender] = nil
				RPB.ip.incwho[sender] = nil
				RPB.ip.inc[sender] = nil
				RPB.ip.incactive[sender] = nil
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
		if not RPB.ip.outl[destination] then
			RPB.ip.outl[destination] = {}
		end
		RPB.ip.outl[destination][cmd] = length
		RPB.ip.out[destination] = 0
		RPB.ip.outactive[destination] = cmd
		RPB.ip.outon[destination] = true
		RPB.ip.outwho[destination] = destination
	elseif string.sub(prefix, 1, string.len(CommCmd.."LC")) == CommCmd.."LC" then
		if RPB.ip.outon[destination] then
			RPB.ip.out[destination] = RPB.ip.out[destination] + 1
		end
		if (prefix == CommCmd.."LC".."\003") then
			RPB.ip.outon[destination] = nil
			RPB.ip.outwho[destination] = nil
			RPB.ip.out[destination] = nil
			RPB.ip.outactive[destination] = nil
		end
	end
end
