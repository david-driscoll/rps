--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPWaitlist/Portfolio.lua
	* Component: Waitlist
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

local rpwlSettings

local function settingUpdate(name, value, isGUI, isUpdate)
	if not rpwlSettings then
		rpwlSettings = RPWL.db.realm.settings
	end
	--RPWL:Print(name, value, isGUI, isUpdate)
	local rvalue = nil
	if (rpwlSettings[name]) then
		rpwlSettings[name] = value
	end
end

local function settingInit(frame)
	frame:Refresh()
end

local Portfolio = LibStub and LibStub("Portfolio")
if not Portfolio then return end

function RPWL:RegisterPortfolio()
	if not rpwlSettings then
		rpwlSettings = RPWL.db.realm.settings
	end
	local optionTable = {
		id="RPWaitlist",
		text="Waitlist Settings",
		addon="RPWaitlist",
		parent="Raid Points System",
		savedVarTable = rpwlSettings,
		options = {
		},
	}
	return Portfolio.RegisterOptionSet(optionTable)
end
