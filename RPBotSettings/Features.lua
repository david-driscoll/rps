--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/Features.lua
	* Component: Features
	* Details:
		Features is an odd name, this file defines how the bot will respond to certian tells, what
			buttons will be on the client window and the rules of that "feature".
		Ideally this file will be modified by a guild that is looking for a specific set of rules, then
			that will get shipped around, the format here should not change signficantly once a release hits.
]]

local db = RPBS.db
--local RPLibrary = LibStub:GetLibrary("RPLibrary")
local featureSets = {}
--local featureSets = db.featureSets
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
		minclass = nil, -- Only override the value if its required by the feature
		maxclass = nil,
		minnonclass = nil,
		maxnonclass = nil,
		maxpoints = 50,
		divisor = nil,
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
		minclass = 50, -- Only override the value if its required by the feature
		maxclass = 50,
		minnonclass = 50,
		maxnonclass = 50,
		maxpoints = 50,
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
		minclass = 20, -- Only override the value if its required by the feature
		maxclass = 20,
		minnonclass = 20,
		maxnonclass = 20,
		maxpoints = 20,
		divisor = 2,
		diff = 50,
		color = nil,
		bgcolor = nil,
		nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
	},
}
featureSets["deus"]["rot"] = featureSets["deus"]["sidegrade"]

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

-- Currently wont fuction correctly, would require a rewrite of GetArgs, that is something that is planned in the future.
--featureSets["nikarma"]["nobonus"] = featureSets["nikarma"]["no bonus"]

function RPBS:AddFeatureSet(name)
	--self:Print(name)
	if not db then
		db = self.db
	end
	db.realm.settings.featureSet = name
	for key,value in pairs(db.featureSets[name]) do
		--self:Print(key)
		if (key ~= "name" and key ~= "description") then
			self:AddFeature(value)
		end
	end
end

function RPBS:AddFeature(data)
	if not self.feature then
		self.feature = {}
	end
	self.feature[data.command] = data

	RPB.whisperCommands[data.command] = function(self, msg, name)
		if self.frames["RollWindow"] and self.frames["RollWindow"].inProgress then
			if not self:RollListAdd(name, data.command) then
				self:Whisper("You are already bidding on that item.", name)
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

function RPBS:RemoveFeatureSet(data)
	for key,value in ipairs(self.feature) do
		self:RemoveFeature(key)
	end
end

function RPBS:RemoveFeature(data)
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
