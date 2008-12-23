local db = RPB.db
local RPLibrary = LibStub:GetLibrary("RPLibrary")
local featureSets = {}
featureSets["deus"] = 
{
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
		color = nil,
		bgcolor = nil,
		nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
	},
}
featureSets["deus"]["rot"] = featureSets["deus"]["sidegrade"]

featureSets["nikarma"] = 
{
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
		color = nil,
		bgcolor = nil,
		nolist = false, -- Only true for special cases such as pass, we don't need them added to the roll list.
	},
}
-- Currently wont fuction correctly, would require a rewrite of GetArgs, that is something that is planned in the future.
--featureSets["nikarma"]["nobonus"] = featureSets["nikarma"]["no bonus"]

function RPB:AddFeatureSet(name)
	self:Print(name)
	for key,value in pairs(featureSets[name]) do
		self:Print(key)
		self:AddFeature(value)
	end
end

function RPB:AddFeature(data)
	self.feature[data.command] = data

	self.whisperCommands[data.command] = function(self, msg, name)
		if self.frames["RollWindow"] and self.frames["RollWindow"].inProgress then
			if not self:RollListAdd(name, data.command) then
				self:Whisper(name, "You are already bidding on that item.")
			end
		else
			self:Whisper(name, "No item is up for bidding.")
		end
	end

	RPB.syncCommands[data.command] = function (self, msg, from)
		-- Sync command should not be needed.
		-- Whisper command hits, sends rollistadd command, which contains the same command.
		self:RollListAdd()
	end
	if self.frames["ClientWindow"] then
		for i=1,#self.frames["ClientWindow"] do
			local f = self.frames["ClientWindow"][i]
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

function RPB:RemoveFeatureSet(data)
	for key,value in ipairs(self.feature) do
		self:RemoveFeature(key)
	end
end

function RPB:RemoveFeature(data)
	if self.feature[data.command] then
		self.feature[data.command] = nil
	end
	
	if self.whisperCommands[data.command] then
		self.whisperCommands[data.command] = nil
	end

	for i=1,#self.frames["ClientWindow"] do
		local f = self.frames["ClientWindow"][i]
		local button = f.button[data.button.name]
		if button then
			button:Hide()
		end
	end
end
