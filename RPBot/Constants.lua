--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/Constants.lua
	* Component: Core
	* Details:
		Constants for RPBot.
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

RPSConstants.syncCommands["Bot"] =
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
	setset			= "setset",
	automationget	= "automationget",
	automationset	= "automationset",
	automationstart	= "automationstart",
	automationstop	= "automationstop",
	fsupdate		= "fsupdate",
	fsoutdate		= "fsoutdate",
	fssend			= "fssend",
	vsreq			= "vsreq",
	vsinfo			= "vsinfo",
	vssend			= "vssend",
}

--  Constants Roll List
RPSConstants.stConstants["RollWindow"] = 
{
	player = 1,
	class = 2,
	rank = 3,
	ty = 4,
	points = 5,
	roll = 6,
	total = 7,
	loss = 8,
}

RPSConstants.stArgs["RollWindow"] = 
{
	[RPSConstants.stConstants["RollWindow"].player]		= { },
	[RPSConstants.stConstants["RollWindow"].class]		= { ClassColor },
	[RPSConstants.stConstants["RollWindow"].rank]		= { },
	[RPSConstants.stConstants["RollWindow"].ty]			= { },
	[RPSConstants.stConstants["RollWindow"].points]		= { },
	[RPSConstants.stConstants["RollWindow"].roll]		= { },
	[RPSConstants.stConstants["RollWindow"].total]		= { },
	[RPSConstants.stConstants["RollWindow"].loss]		= { },
}

-- Constants Loot List
RPSConstants.stConstants["RollWindowLootList"] = 
{
	link = 1,
	item = 2,
	count = 3,
	quality = 4,
}

RPSConstants.stArgs["RollWindowLootList"] =
{
	[RPSConstants.stConstants["RollWindowLootList"].link]		= { },
	[RPSConstants.stConstants["RollWindowLootList"].item]		= { },
	[RPSConstants.stConstants["RollWindowLootList"].count]		= { },
	[RPSConstants.stConstants["RollWindowLootList"].quality]	= { },
}

-- Constants  Officer Names
RPSConstants.stConstants["RollWindowNameList"] = 
{
	name = 1,
}

RPSConstants.stArgs["RollWindowNameList"] = 
{
	[RPSConstants.stConstants["RollWindowNameList"].name]		= { GetColor },
}


RPSConstants.columnDefinitons["RollWindow"] = 
{
	{
	    ["name"] = "Name",
	    ["width"] = 80,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Class",
	    ["width"] = 70,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Rank",
	    ["width"] = 80,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Type",
	    ["width"] = 70,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Points",
	    ["width"] = 60,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Roll",
	    ["width"] = 60,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Total",
	    ["width"] = 60,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Loss",
	    ["width"] = 60,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
}
RPSConstants.columnDefinitons["RollWindowLootList"] = 
{
	{
	    ["name"] = "Items",
	    ["width"] = 200,
	    ["align"] = "LEFT",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
}
RPSConstants.columnDefinitons["RollWindowNameList"] = 
{
	{
	    ["name"] = "Officers",
	    ["width"] = 120,
	    ["align"] = "CENTER",
	    -- ["color"] = { 
	        -- ["r"] = 0.5, 
	        -- ["g"] = 0.5, 
	        -- ["b"] = 1.0, 
	        -- ["a"] = 1.0 
	    -- },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    --["defaultsort"] = "asc",
	},
}
