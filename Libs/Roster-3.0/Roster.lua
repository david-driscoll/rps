--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision:  22
	* Project-Version:  r22
	* Last edited by:  sithy on  2008-12-24T05:51:45Z 
	* Last commit:  sithy on   2008-12-24T05:51:45Z 
	* Filename: RPLibrary/RPLibrary.lua
	* Component: Library
	* Details:
		This file deals with various functions that are shared between the RPBot and RPWaitlist.
		Skining, lib-st building primarily.
]]

-- Leverage SVN
--@alpha@
local MAJOR,MINOR = "Roster-3.0", 1
--@end-alpha@. 
--[===[@non-alpha@
local MAJOR,MINOR = "Roster-3.0", @file-revision@
--@end-non-alpha@]===]
local RosterLib = LibStub:NewLibrary(MAJOR, MINOR)
if not RosterLib then return end

RosterLib.embeds = RosterLib.embeds or {} -- what objects embed this lib

local lib = LibStub:GetLibrary("AceTimer-3.0")
lib:Embed(RosterLib)
lib = LibStub:GetLibrary("AceBucket-3.0")
lib:Embed(RosterLib)
lib = LibStub:GetLibrary("AceEvent-3.0")
lib:Embed(RosterLib)

local mixins = {
	"RosterUnitIDByName",
	"RosterUnitIDByUnit",
	"RosterByName",
	"RosterByUnit",
	"RosterCount",
	"Roster",
	"RosterScan",
}

local unknownUnits = {}
local Lib    = {}
local roster = {}
local new, del
do
	local cache = setmetatable({}, {__mode='k'})
	function new()
		local t = next(cache)
		if t then
			cache[t] = nil
			return t
		else
			return {}
		end
	end
	
	function del(t)
		for k in pairs(t) do
			t[k] = nil
		end
		cache[t] = true
		return nil
	end
end

local LegitimateUnits = {player = true, pet = true, playerpet = true, target = true, focus = true, mouseover = true, npc = true, NPC = true, vehicle = true}
for i = 1, 4 do
	LegitimateUnits["party" .. i] = true
	LegitimateUnits["partypet" .. i] = true
	LegitimateUnits["party" .. i .. "pet"] = true
end
for i = 1, 40 do
	LegitimateUnits["raid" .. i] = true
	LegitimateUnits["raidpet" .. i] = true
	LegitimateUnits["raid" .. i .. "pet"] = true
end
for i = 1, 5 do
	LegitimateUnits["arena" .. i] = true
	LegitimateUnits["arena" .. i .. "pet"] = true
end
setmetatable(LegitimateUnits, {__index=function(self, key)
	if type(key) ~= "string" then
		return false
	end
	if key:find("target$") and not key:find("^npc") then
		local value = self[key:sub(1, -7)]
		self[key] = value
		return value
	end
	self[key] = false
	return false
end})

------------------------------------------------
-- Unit iterator
------------------------------------------------

local UnitIterator
do
	local rmem, pmem, step, count
	local function SelfIterator()
		while step do
			local unit
			if step == 1 then
				-- STEP 1: player
				unit = "player"
				step = 2
			elseif step == 2 then
				-- STEP 2: pet
				unit = "pet"
				step = nil
			end
			if unit and UnitExists(unit) then return unit end
		end
	end

	local function SelfAndPartyIterator()
		while step do
			local unit
			if step <= 2 then
				unit = SelfIterator()
				if not step then step = 3 end
			elseif step == 3 then
				-- STEP 3: party units
				unit = string.format("party%d", count)
				step = 4
			elseif step == 4 then
				-- STEP 4: party pets
				unit = string.format("partypet%d", count)
				count = count + 1
				step = count <= pmem and 3 or nil
			end
			if unit and UnitExists(unit) then return unit end
		end
	end

	local function RaidIterator()
		while step do
			local unit
			if step == 1 then
				-- STEP 1: raid units
				unit = string.format("raid%d", count)
				step = 2
			elseif step == 2 then
				-- STEP 2: raid pets
				unit = string.format("raidpet%d", count)
				count = count + 1
				step = count <= rmem and 1 or nil
			end
			if unit and UnitExists(unit) then return unit end
		end
	end

	function UnitIterator()
		rmem = GetNumRaidMembers()
		step = 1
		if rmem == 0 then
			pmem = GetNumPartyMembers()
			if pmem == 0 then
				return SelfIterator, false
			else
				count = 1
				return SelfAndPartyIterator, false
			end
		else
			count = 1
			return RaidIterator, true
		end
	end
end

------------------------------------------------
-- Roster code
------------------------------------------------

local rosterScanCache = {}
function RosterLib:ScanFullRoster()
	local changed
	local it, isInRaid = UnitIterator()
	-- save all units we currently have, this way we can check who to remove from roster later.
	for name in pairs(roster) do
		rosterScanCache[name] = true
	end
	-- update data
	for unitid in it do
		local name, unitchanged = self:CreateOrUpdateUnit(unitid, isInRaid)
		-- we successfully added a unit, so we don't need to remove it next step
		if name then
			rosterScanCache[name] = nil
			if unitchanged then
				changed = true
			end
		end
	end
	-- clear units we had in roster that either left the raid or are unknown for some reason.
	for name in pairs(rosterScanCache) do
		self:RemoveUnit(name)
		rosterScanCache[name] = nil
		changed = true
	end
	self:ProcessRoster()
	if changed then
		self:SendMessage("RosterLib_RosterUpdated")
	end
end

function RosterLib:RosterScan()
	RosterLib:ScanFullRoster()
end

function RosterLib:ScanPet(owner_list)
	local changed
	for owner in pairs(owner_list) do
		local unitid = self:GetPetFromOwner(owner)
		if not unitid then return end

		if not UnitExists(unitid) then
			unknownUnits[unitid] = nil
			-- find the pet in the roster we need to delete
			for _,u in pairs(roster) do
				if u.unitid == unitid then
					self:RemoveUnit(u.name)
					changed = true
				end
			end
		else
			changed = select(2, self:CreateOrUpdateUnit(unitid))
		end
		self:ProcessRoster()
	end
	if changed then
		self:SendMessage("RosterLib_RosterUpdated")
	end
end


function RosterLib:GetPetFromOwner(id)
	-- convert party3 crap to raid IDs when in raid.
	local owner = self:RosterUnitIDByUnit(id)
	if not owner then return end

	-- get ID
	if owner:find("raid") then
		return owner:gsub("raid", "raidpet")
	elseif owner:find("party") then
		return owner:gsub("party", "partypet")
	elseif owner == "player" then
		return "pet"
	else
		return nil
	end
end


function RosterLib:ScanUnknownUnits()
	local changed
	for unitid in pairs(unknownUnits) do
		local name, c
		if UnitExists(unitid) then
			name, c = self:CreateOrUpdateUnit(unitid)
		else
			unknownUnits[unitid] = nil
		end
		-- some pets never have a name. too bad for them, farewell!
		if not name and unitid:find("pet") then
			unknownUnits[unitid] = nil
		else
			changed = changed or c
		end
	end
	self:ProcessRoster()
	if changed then
		self:SendMessage("RosterLib_RosterUpdated")
	end
end

local timerHandle = nil
function RosterLib:ProcessRoster()
	if next(unknownUnits, nil) then
		if timerHandle then
			self:CancelTimer(timerHandle)
		end
		timerHandle = self:ScheduleTimer("ScanUnknownUnits", 1)
	end
end


function RosterLib:CreateOrUpdateUnit(unitid, isInRaid)
	if not LegitimateUnits[unitid] then
		--RosterLib:error("Bad argument #2 to `CreateOrUpdateUnit'. %q is not a legitimate UnitID.", unitid)
	end
	-- check for name
	local name = UnitName(unitid)
	if name and name ~= UNKNOWNOBJECT and name ~= UKNOWNBEING then
		local unit = roster[name]
		local isPet = unitid:find("pet")

		-- clear stuff
		unknownUnits[unitid] = nil
		-- return if a pet attempts to replace a player name
		-- this doesnt fix the problem with 2 pets overwriting each other FIXME
		if isPet and unit and unit.class ~= "PET" then
			return name
		end
		-- save old data if existing
		local old_name, old_unitid, old_class, old_rank, old_subgroup, old_online, old_role, old_ML
		if unit then
			old_name     = unit.name
			old_unitid   = unit.unitid
			old_class    = unit.class
			old_rank     = unit.rank
			old_subgroup = unit.subgroup
			old_online   = unit.online
			old_role     = unit.role
			old_ML       = unit.ML
		else
			-- object
			unit = new()
			roster[name] = unit
		end

		local new_name, new_unitid, new_class, new_rank, new_subgroup, new_online, new_role, new_ML

		-- name
		new_name = name
		-- unitid
		new_unitid = unitid
		-- class
		if isPet then
			new_class = "PET"
		else
			new_class = select(2, UnitClass(unitid))
		end
		if isInRaid == nil and GetNumRaidMembers() > 0 then
			isInRaid = true
		end

		-- subgroup and rank
		new_subgroup = 1
		new_rank = 0
		if isInRaid then
			local num = select(3, unitid:find("(%d+)"))
			if num then
				local _
				new_rank, new_subgroup, _, _, _, _, _, _, new_role, new_ML = select(2, GetRaidRosterInfo(num))
			end
		else
			new_rank = UnitIsPartyLeader(new_unitid) and 2 or 0
		end
		-- online/offline status
		new_online = UnitIsConnected(unitid)

		-- compare data
		if not old_name
		or new_name     ~= old_name
		or new_unitid   ~= old_unitid
		or new_class    ~= old_class
		or new_subgroup ~= old_subgroup
		or new_rank     ~= old_rank
		or new_online   ~= old_online
		or new_role     ~= old_role
		or new_ML       ~= old_ML
		then
			unit.name = new_name
			unit.unitid = new_unitid
			unit.class = new_class
			unit.subgroup = new_subgroup
			unit.rank = new_rank
			unit.online = new_online
			unit.role = new_role
			unit.ML = new_ML
			self:SendMessage("RosterLib_UnitChanged",
				new_unitid, new_name, new_class, new_subgroup, new_rank,
				old_name, old_unitid, old_class, old_subgroup, old_rank,
				new_role, new_ML,
				old_role, old_ML)
			return name, true
		end
		return name
	else
		unknownUnits[unitid] = true
		return false
	end
end


function RosterLib:RemoveUnit(name)
	local r = roster[name]
	roster[name] = nil
	self:SendMessage("RosterLib_UnitChanged",
		nil, nil, nil, nil, nil,
		r.name, r.unitid, r.class, r.subgroup, r.rank,
		nil, nil,
		r.role, r.ML)
	r = del(r)
end


------------------------------------------------
-- API
------------------------------------------------

function RosterLib:RosterUnitIDByName(name)
	if roster[name] then
		return roster[name].unitid
	else
		return nil
	end
end

function RosterLib:RosterUnitIDByUnit(unit)
	if not LegitimateUnits[unit] then
		--RosterLib:error("Bad argument #2 to `GetUnitIDFromUnit'. %q is not a legitimate UnitID.", unit)
	end
	local name = UnitName(unit)
	if name and roster[name] then
		return roster[name].unitid
	else
		return nil
	end
end

function RosterLib:RosterByName(name)
	return roster[name]
end

function RosterLib:RosterByUnit(unit)
	if not LegitimateUnits[unit] then
		--RosterLib:error("Bad argument #2 to `GetUnitObjectFromUnit'. %q is not a legitimate UnitID.", unit)
	end
	local name = UnitName(unit)
	return roster[name]
end

function RosterLib:RosterCount()
	return #roster
end

function RosterLib:Roster()
	return roster
end

local function iter(t)
	local key = t.key
	local pets = t.pets
	repeat
		key = next(roster, key)
		if not key then
			t = del(t)
			return nil
		end
	until (pets or roster[key].class ~= "PET")
	t.key = key
	return roster[key]
end

function RosterLib:IterateRoster(pets)
	local t = new()
	t.pets = pets
	return iter, t
end

RosterLib:RegisterBucketEvent({"RAID_ROSTER_UPDATE","PARTY_MEMBERS_CHANGED"}, 1, "ScanFullRoster")
RosterLib:RegisterBucketEvent("UNIT_PET", 1, "ScanPet")

function RosterLib:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

--- Finally: upgrade our old embeds
for target, v in pairs(RosterLib.embeds) do
	RosterLib:Embed(target)
end


