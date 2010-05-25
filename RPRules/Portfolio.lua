--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPClient/Portfolio.lua
	* Component: Core
	* Details:
		This is the rolling interface.  Deals with displaying the proper lists, and awarding items.
]]

local Portfolio = LibStub and LibStub("Portfolio")
if not Portfolio then return end

function RPR:RegisterPortfolio()
	-- local optionTable = {
		-- id="RPClientSettings",
		-- text="Client Settings",
		----addon="RPClientSettings",
		-- parent="Raid Points System",
		-- savedVarTable = RPRSettings,
		-- options = {
		-- }
	-- return Portfolio.RegisterOptionSet(optionTable)
end
