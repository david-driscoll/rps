--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPClient/Features.lua
	* Component: Features
	* Details:
		Features is an odd name, this file defines how the bot will respond to certian tells, what
			buttons will be on the client window and the rules of that "feature".
		Ideally this file will be modified by a guild that is looking for a specific set of rules, then
			that will get shipped around, the format here should not change signficantly once a release hits.
]]

local db = RPOS.db
--local RPLibrary = LibStub:GetLibrary("RPLibrary")

-- Currently wont fuction correctly, would require a rewrite of GetArgs, that is something that is planned in the future.
--featureSets["nikarma"]["nobonus"] = featureSets["nikarma"]["no bonus"]

function RPOS:AddFeatureSet(name)
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

function RPOS:AddFeature(data)
	if not self.feature then
		self.feature = {}
	end
	self.feature[data.command] = data

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

function RPOS:RemoveFeatureSet()
	for key,value in ipairs(self.feature) do
		self:RemoveFeature(key)
	end
end

function RPOS:RemoveFeature(data)
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
