--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPRules/Rules.lua
	* Component: Core
	* Details:
		This file contains the core of the RPBot. Handles start up, database initialization,
			database input and output.
]]

local db
RPR = LibStub("AceAddon-3.0"):NewAddon("Raid Points Rules", "RPLibrary")
local cs

--- Initial start up processes.
-- Register chat commands, minor events and setup AceDB
function RPR:OnInitialize()
	-- Leverage SVN
	--@alpha@
	db = LibStub("AceDB-3.0"):New("rpDEBUGRulesDB")
	--@end-alpha@. 
	--[===[@non-alpha@
	db = LibStub("AceDB-3.0"):New("rpRulesDB", defaults, "Default")
	--@end-non-alpha@]===]
	self.db = db
	if not db.realm.settings then
		db.realm.settings  = 
		{
			rulesSet		= "deus",
			version			= 0,
			itemversion		= 0,
		}
	end
	if not db.realm.settings.itemversion then
		db.realm.settings.itemversion = 0
	end
	if not db.realm.rulesSets then
		db.realm.rulesSets = {}
		local rulesSets = db.realm.rulesSets
		rulesSets["deus"] = 
		{
			["name"]		= "Deus Invictus",
			["description"] = "Deus Invictus - Default Rule Set",
			["ilvlmin"]		= 0,
			["ilvlmax"]		= 0,
			["commands"] =
			{
				["bonus"] = 
				{
					name = "Bonus",
					command = "bonus",
					minclass = 25, -- Only override the value if its required by the rules
					maxclass = 50,
					minnonclass = 25,
					maxnonclass = 50,
					maxpoints = 0,
					divisor = 2,
					diff = 50,
					totalpoints = nil,
					color = nil,
					bgcolor = nil,
					nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
				},
				["upgrade"] = 
				{
					name = "Upgrade",
					command = "upgrade",
					minclass = 25, -- Only override the value if its required by the rules
					maxclass = 25,
					minnonclass = 25,
					maxnonclass = 25,
					maxpoints = 25,
					divisor = 2,
					diff = 50,
					color = nil,
					bgcolor = nil,
					nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
				},
				["offspec"] = 
				{
					name = "Offspec",
					command = "offspec",
					minclass = 0, -- Only override the value if its required by the rules
					maxclass = 0,
					minnonclass = 0,
					maxnonclass = 0,
					maxpoints = 0,
					divisor = 2,
					diff = 50,
					color = nil,
					bgcolor = nil,
					nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
				},
				["pass"] = 
				{
					name = "Pass",
					command = "pass",
					minclass = nil, -- Only override the value if its required by the rules
					maxclass = nil,
					minnonclass = nil,
					maxnonclass = nil,
					divisor = nil,
					diff = nil,
					color = nil,
					bgcolor = nil,
					nolist = true, -- Only true for special cases such as pass, we don't need them added to the roll list.
				},
			},
		}
		rulesSets["nikarma"] = 
		{
			["name"]		= "Ni Karma",
			["description"] = "Ni Karma - Default Rule Set",
			["ilvlmin"]		= 0,
			["ilvlmax"]		= 0,
			["commands"] =
			{
				["bonus"] = 
				{
					name = "Bonus",
					command = "bonus",
					minclass = 25, -- Only override the value if its required by the rules
					maxclass = 100,
					minnonclass = 0,
					maxnonclass = -1,
					maxpoints = 0,
					divisor = 2,
					diff = 50,
					color = nil,
					bgcolor = nil,
					nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
				},
				["nobonus"] = 
				{
					name = "Nobonus",
					command = "nobonus",
					minclass = 0, -- Only override the value if its required by the rules
					maxclass = 0,
					minnonclass = 0,
					maxnonclass = 0,
					maxpoints = 0,
					divisor = 2,
					diff = nil,
					color = nil,
					bgcolor = nil,
					nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
				},
			},
		}
	
	end
	local found = false
	for k,v in pairs(db.realm.rulesSets) do
		for key,value in pairs(v) do
			if (key == "commands") then
				found = true
				break
			end
		end
	end
	if not found then
		for k,v in pairs(db.realm.rulesSets) do
			for key,value in pairs(v) do
				if (key ~= "name" and key ~= "description" and key ~= "ilvlmin" and key ~= "ilvlmax") then
					if not db.realm.rulesSets[k]["commands"] then
						db.realm.rulesSets[k]["commands"] = {}
					end
					db.realm.rulesSets[k]["commands"][key] = value
					db.realm.rulesSets[k][key] = nil
				end
			end
		end
	end
	if not db.realm.itemilvlDB then
		db.realm.itemilvlDB = {}
	end

	RPRoldWhipserHelp = RPB.whisperCommands["?"]
end

RPRoldWhipserHelp = nil
local whisperHelp = function (self, msg, name)
	RPRoldWhipserHelp(self, msg, name)
	local wL = {}	
	for key,value in pairs(db.realm.rulesSets[db.realm.settings.rulesSet]["commands"]) do
		local m = value.command.."/rp "..value.command
		if value.desc and value.desc ~= "" then
			if string.sub(value.desc, 1, 1) then
				m = m .. " - " .. string.sub(value.desc,2)
				wL[tonumber(string.sub(value.desc, 1, 1))] = {["m"]=m, ["name"]=name}
			else
				m = m .. " - " .. value.desc
				wL[#wL+1] = {["m"]=m, ["name"]=name}
			end
		else
			wL[#wL+1] = {["m"]=m, ["name"]=name}
		end
	end
	for i=1,#wL do
		self:Whisper(wL[i]["m"], wL[i]["name"])
	end
end

--- Enable processes
-- Register all events, setup inital state and load rulesset
function RPR:OnEnable()
	RPB.whisperCommands["?"] = whisperHelp
	RPB.whisperCommands["help"] = whisperHelp

	self.options = self:RegisterPortfolio()
	self:CreateFrame()
	self:CreateItemFrame()
	--self.options:refresh()
	--SetGuildRosterShowOffline(true)
	--self:Send("syncrequest", "to me")
	--enablecomm = false
	--AceComm:RegisterComm("wlupdate")
	self.cmd1 = nil
	self.cmd2 = nil
	self.cmd3 = nil
	self.cmd4 = nil
	self.cmd5 = nil
	self:AddRulesSet(db.realm.settings.rulesSet)
	self.rules = RPR.rules
	cs = RPSConstants.syncCommands["Bot"]
	for k,v in pairs(RPSConstants.itemlvlDB) do
		if not db.realm.itemilvlDB[tonumber(k)] then
			db.realm.itemilvlDB[tonumber(k)] = v
		end
	end
end

function RPR:UpdateSets(msg)
	self.db.realm.rulesSets = msg

	local rulesDropDown = {}
	for k,v in pairs(self.db.realm.rulesSets) do
		rulesDropDown[k] = v.name or k
	end	
	RPB.frames["RollWindow"].dropdown["RulesSet"]:SetList(rulesDropDown)
	self:SwitchSet(db.realm.settings.rulesSet)
	RPB.rules = self.rules
	RPB.db.realm.version.rules = self.db.realm.settings.version
end

function RPR:UpdateItems(msg)
	self.db.realm.itemilvlDB = msg
	RPB.db.realm.version.items = self.db.realm.settings.itemversion
end

function RPR:FindIlvlSet(ilvl, recieved)
	for k,v in pairs(self.db.realm.rulesSets) do
		if tonumber(ilvl) >= v.ilvlmin and tonumber(ilvl) <= v.ilvlmax
		or tonumber(ilvl) >= v.ilvlmin and v.ilvlmax == 0
		or tonumber(ilvl) <= v.ilvlmax and v.ilvlmin == 0
		 then
			self:SwitchSet(k)
			break
		end
	end	
end

function RPR:SwitchSet(newset, recieved)
	self:RemoveRulesSet()
	db.realm.settings.rulesSet = newset
	self:AddRulesSet(newset)
	RPB.frames["RollWindow"].dropdown["RulesSet"]:SetValue(self.db.realm.settings.rulesSet)
	if not self.Print then
		if RPB and RPB.Print then
			RPB:Print("Now using rules set:", newset)
		end
	end
	if (not recieved) then
		RPB:Send(cs.setset, newset)
	end
end

function RPR:AddRulesSet(name)
	--self:Print(name)
	if not db then
		db = self.db
	end
	db.realm.settings.rulesSet = name
	if db.realm.rulesSets and db.realm.rulesSets[name] and db.realm.rulesSets[name]["commands"] then
		for key,value in pairs(db.realm.rulesSets[name]["commands"]) do
			--self:Print(key)
			self:AddRules(value)
		end
	end
end

function RPR:AddRules(data)
	if not self.rules then
		self.rules = {}
	end
	self.rules[data.command] = data
	
	if not self.cmd1 then
		self.cmd1 = data.command
	elseif not self.cmd2 then
		self.cmd2 = data.command
	elseif not self.cmd3 then
		self.cmd3 = data.command
	elseif not self.cmd4 then
		self.cmd4 = data.command
	elseif not self.cmd5 then
		self.cmd5 = data.command
	end

	RPB.whisperCommands[data.command] = function(self, msg, name)
		if self.frames["RollWindow"] and self.frames["RollWindow"].inProgress then
			local rlaStatus, points_or_type, newty = self:RollListAdd(name, data.command)
			if rlaStatus == "alreadybidding" then
				self:Whisper("You are already bidding on that item. (" .. points_or_type .. ")", name)
			elseif rlaStatus == "newtype" then
				self:Whisper("Bid changed from " .. points_or_type .. " to " .. newty .. ".", name)
			elseif rlaStatus == "nolist" then
				self:Whisper(data.name .. " recieved, removing bid.", name)
			elseif rlaStatus == "added" then
				self:Whisper(data.name .. " recieved.", name)
			elseif rlaStatus == "noclass" then
				self:Whisper("You are not allowed to bid on that item. (Classes: " .. points_or_type .. ")", name)
			elseif rlaStatus == "noarmor" then
				self:Whisper("You are not allowed to bid on that item. (Armor: " .. points_or_type .. ")", name)
			else
				self:Whisper("Something bad might have happened.".." "..rlaStatus.." "..points_or_type, name)
			end
		else
			self:Whisper("No item is up for bidding.", name)
		end
	end

	--RPB.syncCommands[data.command] = function (self, msg, from)
		-- Sync command should not be needed.
		-- Whisper command hits, sends rollistadd command, which contains the same command.
		--self:RollListAdd()
	--end
	-- if RPB.frames["ClientWindow"] then
		-- for i=1,#RPB.frames["ClientWindow"] do
			-- local f = RPB.frames["ClientWindow"][i]
			-- local button = CreateFrame("Button", f:GetName() .. "_Button" .. data.button.name, f, data.button.template)
			-- button:SetWidth(data.button.width)
			-- button:SetHeight(data.button.height)
			-- button:SetPoint(data.button.setpoint.anchor, f, data.button.setpoint.frameanchor, data.button.setpoint.x, data.button.setpoint.y)
			-- button:SetText(data.button.text)
			-- button:SetScript("OnClick", 
				-- function(self)
					-- RPB:Send(data.command)  
				-- end
			-- )
			-- f.button[data.button.name] = button
		-- end
	-- end
end

function RPR:RemoveRulesSet()
	for key,value in pairs(self.rules) do
		self:RemoveRules(key)
	end
	self.cmd1 = nil
	self.cmd2 = nil
	self.cmd3 = nil
	self.cmd4 = nil
	self.cmd5 = nil
end

function RPR:RemoveRules(data)
	if self.rules[data.command] then
		self.rules[data.command] = nil
	end
	
	if RPB.whisperCommands[data.command] then
		RPB.whisperCommands[data.command] = nil
	end

	-- for i=1,#RPB.frames["ClientWindow"] do
		-- local f = RPB.frames["ClientWindow"][i]
		-- local button = f.button[data.button.name]
		-- if button then
			-- button:Hide()
		-- end
	-- end
end
