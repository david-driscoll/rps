--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit by: @project-author@ on @project-date-iso@ 
	* Filename: RPClientSettings/ClientSettings.lua
	* Component: Core
	* Details:
		This file contains the core of the RPBot. Handles start up, database initialization,
			database input and output.
]]

local db
RPF = LibStub("AceAddon-3.0"):NewAddon("Raid Points Feature", "RPLibrary")

--- Initial start up processes.
-- Register chat commands, minor events and setup AceDB
function RPF:OnInitialize()
	-- Leverage SVN
	--@alpha@
	db = LibStub("AceDB-3.0"):New("rpDEBUGFeatureDB")
	--@end-alpha@. 
	--[===[@non-alpha@
	db = LibStub("AceDB-3.0"):New("rpFeatureDB", defaults, "Default")
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
				button = 
				{
					name = "Bonus",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Bonus",
				},
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
				button = 
				{
					name = "Upgrade",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Upgrade",
				},
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
				button = 
				{
					name = "Offspec",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Offspec",
				},
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
			["sidegrade"] = 
			{
				name = "Sidegrade",
				command = "sidegrade",
				button = 
				{
					name = "Sidegrade",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Sidegrade",
				},
				minclass = 10, -- Only override the value if its required by the feature
				maxclass = 10,
				minnonclass = 10,
				maxnonclass = 10,
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
				button = 
				{
					name = "Pass",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Pass",
				},
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
		--featureSets["deus"]["rot"] = featureSets["deus"]["sidegrade"]

		featureSets["nikarma"] = 
		{
			["name"]		= "Ni Karma",
			["description"] = "Ni Karma - Default Rule Set",
			["bonus"] = 
			{
				name = "Bonus",
				button = 
				{
					name = "Bonus",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Bonus",
				},
				command = "bonus",
				minclass = nil, -- Only override the value if its required by the feature
				maxclass = nil,
				minnonclass = nil,
				maxnonclass = nil,
				maxpoints = nil,
				divisor = nil,
				diff = nil,
				totalpoints = nil,
				color = nil,
				bgcolor = nil,
				nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
			},
			["nobonus"] = 
			{
				name = "Upgrade",
				command = "upgrade",
				button = 
				{
					name = "Upgrade",
					template = "UIPanelButtonTemplate",
					width = 91,
					height = 21,
					setpoint =
					{
						anchor = "TOPLEFT",
						frameanchor = "TOPLEFT",
						x = 10,
						y = -60
					},
					text = "Upgrade",
				},
				minclass = 50, -- Only override the value if its required by the feature
				maxclass = 50,
				minnonclass = 50,
				maxnonclass = 50,
				maxpoints = 50,
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
function RPF:OnEnable()
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
	if RPB then
		RPB.featureTimer = RPB:ScheduleTimer("FeatureSync", 10)
	end
end

function RPF:UpdateSets(msg)
	self.db.realm.settings.version = time()
	self.db.realm.featureSets = msg
end

function RPF:AddFeatureSet(name)
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

function RPF:AddFeature(data)
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
			if not self:RollListAdd(name, data.command) then
				self:Whisper("You are already bidding on that item.", name)
			else
				self:Whisper(data.name .. " recieved.", name)
			end
		else
			self:Whisper("No item is up for bidding.", name)
		end
	end

	RPB.syncCommands[data.command] = function (self, msg, from)
		-- Sync command should not be needed.
		-- Whisper command hits, sends rollistadd command, which contains the same command.
		self:RollListAdd()
	end
	if RPB.frames["ClientWindow"] then
		for i=1,#RPB.frames["ClientWindow"] do
			local f = RPB.frames["ClientWindow"][i]
			local button = CreateFrame("Button", f:GetName() .. "_Button" .. data.button.name, f, data.button.template)
			button:SetWidth(data.button.width)
			button:SetHeight(data.button.height)
			button:SetPoint(data.button.setpoint.anchor, f, data.button.setpoint.frameanchor, data.button.setpoint.x, data.button.setpoint.y)
			button:SetText(data.button.text)
			button:SetScript("OnClick", 
				function(self)
					RPB:Send(data.command)  
				end
			)
			f.button[data.button.name] = button
		end
	end
end

function RPF:RemoveFeatureSet()
	for key,value in ipairs(self.feature) do
		self:RemoveFeature(key)
	end
	self.cmd1 = nil
	self.cmd2 = nil
	self.cmd3 = nil
	self.cmd4 = nil
	self.cmd5 = nil
end

function RPF:RemoveFeature(data)
	if self.feature[data.command] then
		self.feature[data.command] = nil
	end
	
	if RPB.whisperCommands[data.command] then
		RPB.whisperCommands[data.command] = nil
	end

	for i=1,#RPB.frames["ClientWindow"] do
		local f = RPB.frames["ClientWindow"][i]
		local button = f.button[data.button.name]
		if button then
			button:Hide()
		end
	end
end
