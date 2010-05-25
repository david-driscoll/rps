--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPReature/Constants.lua
	* Component: Core
	* Details:
		Constants for RPReatures.
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

RPSConstants.columnDefinitons["FeatureSet"] = 
{
	{
	    ["name"] = "Feature Set",
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

RPSConstants.columnDefinitons["FeatureCommand"] = 
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

RPSConstants.stConstants["FeatureSet"] =  
{
	set = 1,
}
RPSConstants.stArgs["FeatureSet"] = 
{
	[RPSConstants.stConstants["FeatureSet"].set]	= { },
}

RPSConstants.stConstants["FeatureCommand"] = 
{
	command = 1,
}

RPSConstants.stArgs["FeatureCommand"] =
{
	[RPSConstants.stConstants["FeatureCommand"].command]	= { },
}