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
if not RPSConstants.syncCommandsPriority then
	RPSConstants.syncCommandsPriority = {}
end
if not RPSConstants.actionText then
	RPSConstants.actionText = {}
end

RPSConstants.actionText["Bot"] =
{
	dbmd5			= "Calculate...",
	dbrequest		= "Request...",
	dbsend			= "Updating...",
	sendla			= "Updating...",
}

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
	vsreq			= "vsreq",
	vsinfo			= "vsinfo",
	vssend			= "vssend",
	fsupdate		= "fsupdate",
	fsoutdate		= "fsoutdate",
	fssend			= "fssend",
	fsinfo			= "fsinfo",
	iiupdate		= "iiupdate",
	iioutdate		= "iioutdate",
	iisend			= "iisend",
	iiinfo			= "iiinfo",
}

RPSConstants.syncCommandsPriority["Bot"] =
{
	rolllistadd		= "ALERT",
	rolllistremove	= "ALERT",
	rolllistupdateroll	= "ALERT",
	rolllistupdatetype	= "ALERT",
	rolllistdisenchant	= "ALERT",
	rolllistaward	= "ALERT",
	rolllistclear	= "ALERT",
	startbidding	= "ALERT",
	starttimedbidding = "ALERT",
	rolllistclick	= "ALERT",
	itemlistadd		= "ALERT",
	itemlistremove	= "ALERT",
	itemlistclick 	= "ALERT",
	itemlistclear 	= "ALERT",
	getmaster		= "ALERT",
	setmaster		= "ALERT",
	itemlistset		= "ALERT",
	itemlistget		= "ALERT",
	rolllistset		= "ALERT",
	rolllistget		= "ALERT",
	pointsadd		= "ALERT",
	pointsremove	= "ALERT",
	pointsupdate	= "ALERT",
	loot			= "ALERT",
	-- Login Syncing
	logon			= "ALERT",
	alert			= "NORMAL",
	dboutdate		= "NORMAL",
	dbupdate		= "NORMAL",
	dbmd5			= "BULK",
	dbrequest		= "BULK",
	dbsend			= "BULK",
	getla			= "BULK",
	sendla			= "BULK",
	rpoSettings		= "BULK",
	rpbSettings		= "BULK",
	dballupdate		= "NORMAL",
	setraid			= "ALERT",
	setset			= "ALERT",
	automationget	= "BULK",
	automationset	= "BULK",
	automationstart	= "BULK",
	automationstop	= "BULK",
	vsreq			= "ALERT",
	vsinfo			= "ALERT",
	vssend			= "BULK",
	fsupdate		= "BULK",
	fsoutdate		= "BULK",
	fssend			= "BULK",
	fsinfo			= "ALERT",
	iiupdate		= "BULK",
	iioutdate		= "BULK",
	iisend			= "BULK",
	iiinfo			= "ALERT",
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
		["header"] = true,
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
		["header"] = true,
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
		["header"] = true,
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

RPSConstants.columnDefinitons["PointsViewer"] = 
{
	{
	    ["name"] = "Name",
	    ["width"] = 100,
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
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Class",
	    ["width"] = 100,
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Rank",
	    ["width"] = 100,
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Earned",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Spent",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
}

RPSConstants.stConstants["PointsViewer"] = 
{
	player = 1,
	class = 2,
	rank = 3,
	earned = 4,
	spent = 5,
	total = 6,
}

RPSConstants.stArgs["PointsViewer"] = 
{
	[RPSConstants.stConstants["PointsViewer"].player]		= { },
	[RPSConstants.stConstants["PointsViewer"].class]		= { ClassColor },
	[RPSConstants.stConstants["PointsViewer"].rank]		= { },
	[RPSConstants.stConstants["PointsViewer"].earned]		= { },
	[RPSConstants.stConstants["PointsViewer"].spent]		= { },
	[RPSConstants.stConstants["PointsViewer"].total]		= { },
}

RPSConstants.columnDefinitons["PointsViewerPopup"] = 
{
	{
	    ["name"] = "Action Date",
	    ["width"] = 150,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 1.0, 
	        ["g"] = 1.0, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Date",
	    ["width"] = 150,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 1.0, 
	        ["g"] = 1.0, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Type",
	    ["width"] = 30,
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
	    ["defaultsort"] = "asc",
		["sortnext"] = 1,
	},
	{
	    ["name"] = "Value",
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
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Waitlist",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Itemid",
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
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Reason",
	    ["width"] = 200,
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
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Action",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
}

RPSConstants.stConstants["PointsViewerPopup"] = 
{
	datetime = 2,
	ty = 3,
	value = 4,
	waitlist = 5,
	itemid = 6,
	reason = 7,
	action = 8,
	actiontime = 1,
}

RPSConstants.stArgs["PointsViewerPopup"] = 
{
	[RPSConstants.stConstants["PointsViewerPopup"].datetime]	= { nil, nil, DoTimestampUpdate },
	[RPSConstants.stConstants["PointsViewerPopup"].ty]			= { },
	[RPSConstants.stConstants["PointsViewerPopup"].value]		= { },
	[RPSConstants.stConstants["PointsViewerPopup"].waitlist]	= { },
	[RPSConstants.stConstants["PointsViewerPopup"].itemid]		= { },
	[RPSConstants.stConstants["PointsViewerPopup"].reason]		= { },
	[RPSConstants.stConstants["PointsViewerPopup"].action]		= { },
	[RPSConstants.stConstants["PointsViewerPopup"].actiontime]	= { nil, nil, DoTimestampUpdate },
}


RPSConstants.columnDefinitons["HistoryViewer"] = 
{
	{
	    ["name"] = "Name",
	    ["width"] = 100,
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
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Class",
	    ["width"] = 100,
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Rank",
	    ["width"] = 100,
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Earned",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Spent",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
}

RPSConstants.stConstants["HistoryViewer"] = 
{
	player = 1,
	class = 2,
	rank = 3,
	earned = 4,
	spent = 5,
	total = 6,
}

RPSConstants.stArgs["HistoryViewer"] = 
{
	[RPSConstants.stConstants["HistoryViewer"].player]		= { },
	[RPSConstants.stConstants["HistoryViewer"].class]		= { ClassColor },
	[RPSConstants.stConstants["HistoryViewer"].rank]		= { },
	[RPSConstants.stConstants["HistoryViewer"].earned]		= { },
	[RPSConstants.stConstants["HistoryViewer"].spent]		= { },
	[RPSConstants.stConstants["HistoryViewer"].total]		= { },
}

RPSConstants.columnDefinitons["HistoryViewerPopup"] = 
{
	{
	    ["name"] = "Action Date",
	    ["width"] = 150,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 1.0, 
	        ["g"] = 1.0, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Date",
	    ["width"] = 150,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 1.0, 
	        ["g"] = 1.0, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 0.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Type",
	    ["width"] = 30,
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
	    ["defaultsort"] = "asc",
		["sortnext"] = 1,
	},
	{
	    ["name"] = "Value",
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
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Waitlist",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Itemid",
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
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Reason",
	    ["width"] = 200,
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
	    ["defaultsort"] = "asc",
	},
	{
	    ["name"] = "Action",
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
		["sortnext"] = 1,
	    ["defaultsort"] = "asc",
	},
}

RPSConstants.stConstants["HistoryViewerPopup"] = 
{
	datetime = 2,
	ty = 3,
	value = 4,
	waitlist = 5,
	itemid = 6,
	reason = 7,
	action = 8,
	actiontime = 1,
}

RPSConstants.stArgs["HistoryViewerPopup"] = 
{
	[RPSConstants.stConstants["HistoryViewerPopup"].datetime]	= { nil, nil, DoTimestampUpdate },
	[RPSConstants.stConstants["HistoryViewerPopup"].ty]			= { },
	[RPSConstants.stConstants["HistoryViewerPopup"].value]		= { },
	[RPSConstants.stConstants["HistoryViewerPopup"].waitlist]	= { },
	[RPSConstants.stConstants["HistoryViewerPopup"].itemid]		= { },
	[RPSConstants.stConstants["HistoryViewerPopup"].reason]		= { },
	[RPSConstants.stConstants["HistoryViewerPopup"].action]		= { },
	[RPSConstants.stConstants["HistoryViewerPopup"].actiontime]	= { nil, nil, DoTimestampUpdate },
}


