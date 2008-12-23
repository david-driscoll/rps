local db = RPB.db
local RPLibrary = LibStub:GetLibrary("RPLibrary")
RPB.columnDefinitons = {}

RPB.columnDefinitons["PointsViewWindow"] = 
{
	{
	    ["name"] = "Name",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Class",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Rank",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Total",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Lifetime",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Spent",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
}

RPB.columnDefinitons["PointsAwardWindow1"] = 
{
	{
	    ["name"] = "Raid",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
}

RPB.columnDefinitons["PointsAwardWindow2"] = 
{
	{
	    ["name"] = "Waitlist",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
}

RPB.columnDefinitons["PointsHistoryWindow"] = 
{
	{
	    ["name"] = "Value",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Type",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Item",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
	{
	    ["name"] = "Reason",
	    ["width"] = 50,
	    ["align"] = "CENTER",
	    ["color"] = { 
	        ["r"] = 0.5, 
	        ["g"] = 0.5, 
	        ["b"] = 1.0, 
	        ["a"] = 1.0 
	    },
	    ["colorargs"] = nil,
	    ["bgcolor"] = {
	        ["r"] = 1.0, 
	        ["g"] = 0.0, 
	        ["b"] = 0.0, 
	        ["a"] = 1.0 
	    },
	    ["defaultsort"] = "asc",
	    
	},
}





