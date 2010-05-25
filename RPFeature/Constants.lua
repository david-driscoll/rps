--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPFeature/Constants.lua
	* Filename: RPRules/Constants.lua
	* Component: Core
	* Details:
		Constants for RPRules.
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

RPSConstants.columnDefinitons["RulesSet"] = 
{
	{
	    ["name"] = "Rules Set",
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
	    --["defaultsort"] = "asc",
	},
}

RPSConstants.columnDefinitons["RulesCommand"] = 
{
	{
	    ["name"] = "Command",
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
	    --["defaultsort"] = "asc",
	},
}

RPSConstants.stConstants["RulesSet"] =  
{
	set = 1,
}
RPSConstants.stArgs["RulesSet"] = 
{
	[RPSConstants.stConstants["RulesSet"].set]	= { },
}

RPSConstants.stConstants["RulesCommand"] = 
{
	command = 1,
}

RPSConstants.stArgs["RulesCommand"] =
{
	[RPSConstants.stConstants["RulesCommand"].command]	= { },
}

RPSConstants.columnDefinitons["ItemList"] = 
{
	{
	    ["name"] = "Item",
	    ["width"] = 300,
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
	{
	    ["name"] = "iLlvl",
	    ["width"] = 100,
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


RPSConstants.stConstants["ItemList"] =  
{
	itemid = 1,
	ilvl = 2,
}
RPSConstants.stArgs["ItemList"] = 
{
	[RPSConstants.stConstants["ItemList"].itemid]	= { },
	[RPSConstants.stConstants["ItemList"].ilvl]		= { },
}