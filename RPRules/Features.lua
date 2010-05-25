--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPReature/Features.lua
	* Component: Core
	* Details:
		This file contains the core of the RPBot. Handles start up, database initialization,
			database input and output.
]]

local db
RPR = LibStub("AceAddon-3.0"):NewAddon("Raid Points Feature", "RPLibrary")
local cs

--- Initial start up processes.
-- Register chat commands, minor events and setup AceDB
function RPR:OnInitialize()
	-- Leverage SVN
	--@alpha@
	db = LibStub("AceDB-3.0"):New("rpDEBUGFeatureDB")
	--@end-alpha@. 
	--[===[@non-alpha@
	db = LibStub("AceDB-3.0"):New("RPReatureDB", defaults, "Default")
	--@end-non-alpha@]===]
	self.db = db
	if not db.realm.settings then
		db.realm.settings  = 
		{
			featureSet		= "deus",
			version			= 0,
		}
	end
	if not db.realm.featureSets then
		db.realm.featureSets = {}
		local featureSets = db.realm.featureSets
		featureSets["deus"] = 
		{
			["name"]		= "Deus Invictus",
			["description"] = "Deus Invictus - Default Rule Set",
			["bonus"] = 
			{
				name = "Bonus",
				command = "bonus",
				minclass = 25, -- Only override the value if its required by the feature
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
				minclass = 25, -- Only override the value if its required by the feature
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
				minclass = 0, -- Only override the value if its required by the feature
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
				minclass = nil, -- Only override the value if its required by the feature
				maxclass = nil,
				minnonclass = nil,
				maxnonclass = nil,
				divisor = nil,
				diff = nil,
				color = nil,
				bgcolor = nil,
				nolist = true, -- Only true for special cases such as pass, we don't need them added to the roll list.
			},
		}
		featureSets["nikarma"] = 
		{
			["name"]		= "Ni Karma",
			["description"] = "Ni Karma - Default Rule Set",
			["bonus"] = 
			{
				name = "Bonus",
				command = "bonus",
				minclass = 25, -- Only override the value if its required by the feature
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
				minclass = 0, -- Only override the value if its required by the feature
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
		}
	
	end
end

--- Enable processes
-- Register all events, setup inital state and load featureset
function RPR:OnEnable()
	self.options = self:RegisterPortfolio()
	self:CreateFrame()
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
	self:AddFeatureSet(db.realm.settings.featureSet)
	self.feature = RPR.feature
	cs = RPSConstants.syncCommands["Bot"]
end

function RPR:UpdateSets(msg)
	self.db.realm.featureSets = msg

	local featureDropDown = {}
	for k,v in pairs(self.db.realm.featureSets) do
		featureDropDown[k] = v.name or k
	end	
	RPB.frames["RollWindow"].dropdown["FeatureSet"]:SetList(featureDropDown)
	self:SwitchSet(db.realm.settings.featureSet)
	RPB.feature = self.feature
	RPB.db.realm.version.feature = self.db.realm.settings.version
end

function RPR:SwitchSet(newset, recieved)
	self:RemoveFeatureSet()
	db.realm.settings.featureSet = newset
	self:AddFeatureSet(newset)
	RPB.frames["RollWindow"].dropdown["FeatureSet"]:SetValue(self.db.realm.settings.featureSet)
	if not self.Print then
		if RPB and RPB.Print then
			RPB:Print("Now using feature set:", newset)
		end
	end
	if (not recieved) then
		RPB:Send(cs.setset, newset)
	end
end

function RPR:AddFeatureSet(name)
	--self:Print(name)
	if not db then
		db = self.db
	end
	db.realm.settings.featureSet = name
	for key,value in pairs(db.realm.featureSets[name]) do
		--self:Print(key)
		if (key ~= "name" and key ~= "description") then
			self:AddFeature(value)
		end
	end
end

function RPR:AddFeature(data)
	if not self.feature then
		self.feature = {}
	end
	self.feature[data.command] = data
	
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

function RPR:RemoveFeatureSet()
	for key,value in pairs(self.feature) do
		self:RemoveFeature(key)
	end
	self.cmd1 = nil
	self.cmd2 = nil
	self.cmd3 = nil
	self.cmd4 = nil
	self.cmd5 = nil
end

function RPR:RemoveFeature(data)
	if self.feature[data.command] then
		self.feature[data.command] = nil
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
