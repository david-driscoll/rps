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

if not RPSConstants.itemlvlDB then
	RPSConstants.itemlvlDB = {}
end

local classColors = {
["DEATH KNIGHT"]	= {["r"] = 0.77, 	["g"] = 0.12, 	["b"] = 0.23, 	["a"] = 1.0,},
["DRUID"] 			= {["r"] = 1.00, 	["g"] = 0.49, 	["b"] = 0.04, 	["a"] = 1.0,},
["HUNTER"] 			= {["r"] = 0.67, 	["g"] = 0.83, 	["b"] = 0.45, 	["a"] = 1.0,},
["MAGE"] 			= {["r"] = 0.41, 	["g"] = 0.80, 	["b"] = 0.94, 	["a"] = 1.0,},
["PALADIN"] 		= {["r"] = 0.96, 	["g"] = 0.55, 	["b"] = 0.73, 	["a"] = 1.0,},
["PRIEST"] 			= {["r"] = 1.00, 	["g"] = 1.00, 	["b"] = 1.00, 	["a"] = 1.0,},
["ROGUE"] 			= {["r"] = 1.00, 	["g"] = 0.96, 	["b"] = 0.41, 	["a"] = 1.0,},
["SHAMAN"] 			= {["r"] = 0.14, 	["g"] = 0.35, 	["b"] = 1.00, 	["a"] = 1.0,},
["WARLOCK"] 		= {["r"] = 0.58, 	["g"] = 0.51, 	["b"] = 0.79, 	["a"] = 1.0,},
["WARRIOR"] 		= {["r"] = 0.78, 	["g"] = 0.61, 	["b"] = 0.43, 	["a"] = 1.0,},
}

RPSConstants.classList = 
{
["deathknight"]	= "DEATH KNIGHT",
["druid"] 		= "DRUID",
["hunter"] 		= "HUNTER",
["mage"] 		= "MAGE",
["paladin"] 	= "PALADIN",
["priest"] 		= "PRIEST",
["rogue"] 		= "ROGUE",
["shaman"] 		= "SHAMAN",
["warlock"]		= "WARLOCK",
["warrior"]		= "WARRIOR",
}

RPSConstants.tierList = 
{
["DEATH KNIGHT"] = {"ROGUE", "DEATH KNIGHT", "MAGE", "DRUID"},
["DRUID"] 		 = {"ROGUE", "DEATH KNIGHT", "MAGE", "DRUID"},
["HUNTER"] 		 = {"WARRIOR", "HUNTER", "SHAMAN"},
["MAGE"] 		 = {"ROGUE", "DEATH KNIGHT", "MAGE", "DRUID"},
["PALADIN"] 	 = {"PALADIN", "PRIEST", "WARLOCK"},
["PRIEST"] 		 = {"PALADIN", "PRIEST", "WARLOCK"},
["ROGUE"] 		 = {"ROGUE", "DEATH KNIGHT", "MAGE", "DRUID"},
["SHAMAN"] 		 = {"WARRIOR", "HUNTER", "SHAMAN"},
["WARLOCK"] 	 = {"PALADIN", "PRIEST", "WARLOCK"},
["WARRIOR"] 	 = {"WARRIOR", "HUNTER", "SHAMAN"},
}

RPSConstants.talentList =
{
["DEATH KNIGHT"] = {"Blood","Frost","Unholy","Unknown"},
["DRUID"] = {"Balance","Feral","Restoration","Unknown"},
["HUNTER"] = {"Beast Mastery","Marksmanship","Survival","Unknown"},
["MAGE"] = {"Arcane","Fire","Frost","Unknown"},
["PALADIN"] = {"Holy","Protection","Retribution","Unknown"},
["PRIEST"] = {"Discipline","Holy","Shadow","Unknown"},
["ROGUE"] = {"Assassination","Combat","Subtlety","Unknown"},
["SHAMAN"] = {"Elemental","Enchancement","Restoration","Unknown"},
["WARLOCK"] = {"Affliction","Demonology","Destruction","Unknown"},
["WARRIOR"] = {"Arms","Fury","Protection","Unknown"},
["UNKNOWN"] = {"Unknown","Unknown","Unknown","Unknown"},
}

RPSConstants.filterList = 
{
	["Cloth"] = true,
	["Leather"] = true,
	["Mail"] = true,
	["Plate"] = true,
	["Shields"] = true,
	["Librams"] = true,
	["Idols"] = true,
	["Totems"] = true,
	["Sigils"] = true,
	["Miscellaneous"] = true,
	["Bows"] = true,
	["Crossbows"] = true,
	["Daggers"] = true,
	["Guns"] = true,
	["Fist Weapons"] = true,
	["One-Handed Axes"] = true,
	["One-Handed Maces"] = true,
	["One-Handed Swords"] = true,
	["Polearms"] = true,
	["Staves"] = true,
	["Thrown"] = true,
	["Two-Handed Axes"] = true,
	["Two-Handed Maces"] = true,
	["Two-Handed Swords"] = true,
	["Wands"] = true,
}

RPSConstants.filterClassList = {
	["DEATH KNIGHT"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Leather"] = true,
		["Mail"] = true,
		["Plate"] = true,
		["Sigils"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["One-Handed Swords"] = true,
		["Polearms"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
		["Two-Handed Swords"] = true,
	},
	["DRUID"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Leather"] = true,
		["Idols"] = true,
		["Daggers"] = true,
		["Fist Weapons"] = true,
		["One-Handed Maces"] = true,
		["Polearms"] = true,
		["Staves"] = true,
		["Two-Handed Maces"] = true,
	},
	["HUNTER"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Leather"] = true,
		["Mail"] = true,
		["Bows"] = true,
		["Crossbows"] = true,
		["Daggers"] = true,
		["Guns"] = true,
		["Fist Weapons"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Swords"] = true,
		["Polearms"] = true,
		["Staves"] = true,
		["Thrown"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Swords"] = true,
	},
	["MAGE"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Daggers"] = true,
		["One-Handed Swords"] = true,
		["Staves"] = true,
		["Wands"] = true,
	},
	["PALADIN"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Leather"] = true,
		["Mail"] = true,
		["Plate"] = true,
		["Shields"] = true,
		["Librams"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["One-Handed Swords"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
		["Two-Handed Swords"] = true,
		["Polearms"] = true,
	},
	["PRIEST"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Daggers"] = true,
		["One-Handed Maces"] = true,
		["Staves"] = true,
		["Wands"] = true,
	},
	["ROGUE"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Leather"] = true,
		["Bows"] = true,
		["Crossbows"] = true,
		["Daggers"] = true,
		["Guns"] = true,
		["Fist Weapons"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["One-Handed Swords"] = true,
		["Thrown"] = true,
	},
	["SHAMAN"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Leather"] = true,
		["Mail"] = true,
		["Shields"] = true,
		["Totems"] = true,
		["Daggers"] = true,
		["Fist Weapons"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["Staves"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
	},
	["WARLOCK"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Daggers"] = true,
		["Fist Weapons"] = true,
		["One-Handed Swords"] = true,
		["Staves"] = true,
		["Wands"] = true,
	},
	["WARRIOR"] = {
		["Miscellaneous"] = true,
		["Cloth"] = true,
		["Leather"] = true,
		["Mail"] = true,
		["Plate"] = true,
		["Shields"] = true,
		["Bows"] = true,
		["Crossbows"] = true,
		["Daggers"] = true,
		["Guns"] = true,
		["Fist Weapons"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["One-Handed Swords"] = true,
		["Polearms"] = true,
		["Staves"] = true,
		["Thrown"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
		["Two-Handed Swords"] = true,
	},
}

function ClassColor(class)
	if (class and classColors[string.upper(class)]) then
		return classColors[string.upper(class)]
	else
		return {["r"] = 1.00, 	["g"] = 1.00, 	["b"] = 1.00, 	["a"] = 1.0,}
	end
end


RPSConstants.itemlvlDB = {
	["40610"] = 200, -- Chestguard of the Lost Conqueror
	["40611"] = 200, -- Chestguard of the Lost Protector
	["40612"] = 200, -- Chestguard of the Lost Vanquisher
	["40613"] = 200, -- Gloves of the Lost Conqueror
	["40614"] = 200, -- Gloves of the Lost Protector
	["40615"] = 200, -- Gloves of the Lost Vanquisher
	["40616"] = 200, -- Helm of the Lost Conqueror
	["40617"] = 200, -- Helm of the Lost Protector
	["40618"] = 200, -- Helm of the Lost Vanquisher
	["40619"] = 200, -- Leggings of the Lost Conqueror
	["40620"] = 200, -- Leggings of the Lost Protector
	["40621"] = 200, -- Leggings of the Lost Vanquisher
	["40622"] = 200, -- Spaulders of the Lost Conqueror
	["40623"] = 200, -- Spaulders of the Lost Protector
	["40624"] = 200, -- Spaulders of the Lost Vanquisher
	["40625"] = 213, -- Breastplate of the Lost Conqueror
	["40626"] = 213, -- Breastplate of the Lost Protector
	["40627"] = 213, -- Breastplate of the Lost Vanquisher
	["40628"] = 213, -- Gauntlets of the Lost Conqueror
	["40629"] = 213, -- Gauntlets of the Lost Protector
	["40630"] = 213, -- Gauntlets of the Lost Vanquisher
	["40631"] = 213, -- Crown of the Lost Conqueror
	["40632"] = 213, -- Crown of the Lost Protector
	["40633"] = 213, -- Crown of the Lost Vanquisher
	["40634"] = 213, -- Legplates of the Lost Conqueror
	["40635"] = 213, -- Legplates of the Lost Protector
	["40636"] = 213, -- Legplates of the Lost Vanquisher
	["40637"] = 213, -- Mantle of the Lost Conqueror
	["40638"] = 213, -- Mantle of the Lost Protector
	["40639"] = 213, -- Mantle of the Lost Vanquisher
	["45632"] = 226, -- Breastplate of the Wayward Conqueror
	["45633"] = 226, -- Breastplate of the Wayward Protector
	["45634"] = 226, -- Breastplate of the Wayward Vanquisher
	["45635"] = 219, -- Chestguard of the Wayward Conqueror
	["45636"] = 219, -- Chestguard of the Wayward Protector
	["45637"] = 219, -- Chestguard of the Wayward Vanquisher
	["45638"] = 226, -- Crown of the Wayward Conqueror
	["45639"] = 226, -- Crown of the Wayward Protector
	["45640"] = 226, -- Crown of the Wayward Vanquisher
	["45641"] = 226, -- Gauntlets of the Wayward Conqueror
	["45642"] = 226, -- Gauntlets of the Wayward Protector
	["45643"] = 226, -- Gauntlets of the Wayward Vanquisher
	["45644"] = 219, -- Gloves of the Wayward Conqueror
	["45645"] = 219, -- Gloves of the Wayward Protector
	["45646"] = 219, -- Gloves of the Wayward Vanquisher
	["45647"] = 219, -- Helm of the Wayward Conqueror
	["45648"] = 219, -- Helm of the Wayward Protector
	["45649"] = 219, -- Helm of the Wayward Vanquisher
	["45650"] = 219, -- Leggings of the Wayward Conqueror
	["45651"] = 219, -- Leggings of the Wayward Protector
	["45652"] = 219, -- Leggings of the Wayward Vanquisher
	["45653"] = 226, -- Legplates of the Wayward Conqueror
	["45654"] = 226, -- Legplates of the Wayward Protector
	["45655"] = 226, -- Legplates of the Wayward Vanquisher
	["45656"] = 226, -- Mantle of the Wayward Conqueror
	["45657"] = 226, -- Mantle of the Wayward Protector
	["45658"] = 226, -- Mantle of the Wayward Vanquisher
	["45659"] = 219, -- Spaulders of the Wayward Conqueror
	["45660"] = 219, -- Spaulders of the Wayward Protector
	["45661"] = 219, -- Spaulders of the Wayward Vanquisher
	["47242"] = 245, -- Trophy of the Crusade
	["47557"] = 258, -- Regalia of the Grand Conqueror
	["47558"] = 258, -- Regalia of the Grand Protector
	["47559"] = 258, -- Regalia of the Grand Vanquisher
	["52025"] = 264, -- Vanquisher's Mark of Sanctification
	["52026"] = 264, -- Protector's Mark of Sanctification
	["52027"] = 264, -- Conqueror's Mark of Sanctification
	["52028"] = 277, -- Vanquisher's Mark of Sanctification
	["52029"] = 277, -- Protector's Mark of Sanctification
	["52030"] = 277, -- Conqueror's Mark of Sanctification
}

