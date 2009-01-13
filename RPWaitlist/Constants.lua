--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPWaitlist/Constants.lua
	* Component: Core
	* Details:
		Constants for RPWaitlist.
]]

if not RPSConstants then
	RPSConstants = {}
end
if not RPSConstants.columnDefinitons then
	RPSConstants.columnDefinitons = {}
end
if not RPSConstants.stConstants then
	RPSConstants.stConstants = {}
end
if not RPSConstants.stArgs then
	RPSConstants.stArgs = {}
end
if not RPSConstants.syncCommands then
	RPSConstants.syncCommands = {}
end

RPSConstants.columnDefinitons["Waitlist"] =
{
	{
		["name"] = "Name",
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	},
	{ 
		["name"] = "Alt", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	},
	{ 
		["name"] = "Class", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 1,
	},
	{
		["name"] = "Status",
		["index"] = "i",
		["width"] = 120, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	},
	{ 
		["name"] = "Time", 
		["width"] = 150, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	},
}

RPSConstants.columnDefinitons["Roster"] =
{
	{ 
		["name"] = "Name", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	}, -- [2]
	{ 
		["name"] = "Rank", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 3,
	},
	{ 
		["name"] = "Level", 
		["width"] = 40, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 1,
		["defaultsort"] = "asc",
	}, -- [2]
	{ 
		["name"] = "Class", 
		["width"] = 80, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 3,
	}, -- [2]
	{ 
		["name"] = "Zone", 
		["width"] = 160, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 3,
	}, -- [2]
	{ 
		["name"] = "Status", 
		["width"] = 50, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
	}, -- [2]
	{
		["name"] = "O", 
		["width"] = 20, 
		["align"] = "CENTER",
		--["color"] = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 },
		["bgcolor"] = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.5 },
		["sortnext"] = 1,
		["defaultsort"] = "asc",
	}, -- [2]
}

-- Watilist table constents
RPSConstants.stConstants["Waitlist"] = 
{
	name		= 1,
	alt			= 2,
	class		= 3,
	status		= 4,
	--datetime	= 5,
	timestamp	= 5,
}

RPSConstants.stArgs["Waitlist"] = 
{
	[RPSConstants.stConstants["Waitlist"].name] 		= { },
	[RPSConstants.stConstants["Waitlist"].alt] 			= { }, 
	[RPSConstants.stConstants["Waitlist"].class] 		= { nil, ClassColor },
	[RPSConstants.stConstants["Waitlist"].status] 		= { },
	[RPSConstants.stConstants["Waitlist"].timestamp] 	= { nil, nil, nil, DoTimestampUpdate },
}

-- Guild Roster table contents
RPSConstants.stConstants["Roster"] = 
{
	name		= 1,
	rank		= 2,
	level		= 3,
	class		= 4,
	zone		= 5,
	status		= 6,
	online		= 7,
	officernote	= 8,
	rankindex	= 9,
}

RPSConstants.stArgs["Roster"] = 
{
	[RPSConstants.stConstants["Roster"].name]			= { },
	[RPSConstants.stConstants["Roster"].rank]			= { },
	[RPSConstants.stConstants["Roster"].level]			= { },
	[RPSConstants.stConstants["Roster"].class]			= { nil, ClassColor },
	[RPSConstants.stConstants["Roster"].zone]			= { },
	[RPSConstants.stConstants["Roster"].status]			= { },
	[RPSConstants.stConstants["Roster"].online]			= { },
	[RPSConstants.stConstants["Roster"].officernote]	= { },
	[RPSConstants.stConstants["Roster"].rankindex]		= { },
}

-- Sync commands, lets save some overhead
RPSConstants.syncCommands["Waitlist"] = 
{
	["add"]			= "a",
	["remove"]		= "r",
	["syncrequest"]	= "sr",
	["syncowner"]	= "so",
	["sync"]		= "s",
	["rpoSettings"]	= "set",
}