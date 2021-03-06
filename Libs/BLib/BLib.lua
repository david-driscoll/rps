--[[
Name: Roster-2.1
Revision: $Revision: 93 $
X-ReleaseDate: $Date: 2008-11-22 23:06:16 +0000 (Sat, 22 Nov 2008) $
Author: Maia (maia.proudmoore@gmail.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/wiki/Roster-2.1
SVN: http://svn.wowace.com/wowace/trunk/BLib/
Description: Party/raid roster management
Dependencies: AceLibrary, AceOO-2.0, AceEvent-2.0

Originally develped for Ace2 by Maia, I've updated the code for my uses. I claim no
rights to the code, and when I get near to beta, I'll see about getting it placed in its
own project if needed.

]]


-- Leverage SVN
--@alpha@
local MAJOR,MINOR = "BLib", 1
--@end-alpha@. 
--[===[@non-alpha@
local MAJOR,MINOR = "BLib", @file-revision@
--@end-non-alpha@]===]
local BLib = LibStub:NewLibrary(MAJOR, MINOR)
if not BLib then return end

BLib.embeds = BLib.embeds or {} -- what objects embed this lib

local lib = LibStub:GetLibrary("AceTimer-3.0")
lib:Embed(BLib)
lib = LibStub:GetLibrary("AceBucket-3.0")
lib:Embed(BLib)
lib = LibStub:GetLibrary("AceEvent-3.0")
lib:Embed(BLib)

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
function BLib:ScanFullRoster()
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
		self:SendMessage("BLib_RosterUpdated")
	end
end

function BLib:RosterScan()
	BLib:ScanFullRoster()
end

function BLib:ScanPet(owner_list)
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
		self:SendMessage("BLib_RosterUpdated")
	end
end


function BLib:GetPetFromOwner(id)
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


function BLib:ScanUnknownUnits()
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
		self:SendMessage("BLib_RosterUpdated")
	end
end

local timerHandle = nil
function BLib:ProcessRoster()
	if next(unknownUnits, nil) then
		if timerHandle then
			--self:CancelTimer(timerHandle)
			timerHandle = nil
		end
		timerHandle = self:ScheduleTimer("ScanUnknownUnits", 1)
	end
end


function BLib:CreateOrUpdateUnit(unitid, isInRaid)
	if not LegitimateUnits[unitid] then
		--BLib:error("Bad argument #2 to `CreateOrUpdateUnit'. %q is not a legitimate UnitID.", unitid)
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
			new_class = select(1, UnitClass(unitid))
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
			self:SendMessage("BLib_UnitChanged",
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


function BLib:RemoveUnit(name)
	local r = roster[name]
	roster[name] = nil
	self:SendMessage("BLib_UnitChanged",
		nil, nil, nil, nil, nil,
		r.name, r.unitid, r.class, r.subgroup, r.rank,
		nil, nil,
		r.role, r.ML)
	r = del(r)
end


------------------------------------------------
-- API
------------------------------------------------

function BLib:RosterUnitIDByName(name)
	if roster[name] then
		return roster[name].unitid
	else
		return nil
	end
end

function BLib:RosterUnitIDByUnit(unit)
	if not LegitimateUnits[unit] then
		--BLib:error("Bad argument #2 to `GetUnitIDFromUnit'. %q is not a legitimate UnitID.", unit)
	end
	local name = UnitName(unit)
	if name and roster[name] then
		return roster[name].unitid
	else
		return nil
	end
end

function BLib:RosterByName(name)
	return roster[name]
end

function BLib:RosterByUnit(unit)
	if not LegitimateUnits[unit] then
		--BLib:error("Bad argument #2 to `GetUnitObjectFromUnit'. %q is not a legitimate UnitID.", unit)
	end
	local name = UnitName(unit)
	return roster[name]
end

function BLib:RosterCount()
	return #roster
end

function BLib:Roster()
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

function BLib:IterateRoster(pets)
	local t = new()
	t.pets = pets
	return iter, t
end

BLib:RegisterBucketEvent({"RAID_ROSTER_UPDATE","PARTY_MEMBERS_CHANGED"}, 1, "ScanFullRoster")
BLib:RegisterBucketEvent("UNIT_PET", 1, "ScanPet")

function BLib:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

--- Finally: upgrade our old embeds
for target, v in pairs(BLib.embeds) do
	BLib:Embed(target)
end


