--[[-- 
	@name			Portfolio
	@description	Interface Option Creation Utility
	@release		1.0
	@author			Karl Isenberg (AnduinLothar)
	@revision		$Id: Portfolio.lua 3705 2006-06-26 08:15:29Z karlkfi $
	@usage			local Portfolio = LibStub("Portfolio")<br/>
					<div class="p">
					<b>Dependant Usage:</b><ol>
					<li>Add Portfolio as a Required Dependency.</li>
					<li>Include Portfolio in your download<br/>
					OR link users to <a href="http://www.wowinterface.com/downloads/info11749-Portfolio.html">WoW 
					Interface</a> for downloading.</li></ol>
					<b>Embedded Usage:</b><ol>
					<li>Include Portfolio in the Libs folder of you addon: &lt;addon&gt;\Libs\Portfolio.</li>
					<li>Include  Loader.xml in your xml file with &lt;Include file="Libs\Portfolio\Loader.xml"/&gt;<br/>
					OR load Libs\Portfolio\Loader.xml from your toc file.</li>
					<li>Add Portfolio as an Optional Dependency in your toc, and as an X-Embeds.</li></ol>
					</div>
--]]--
--[[ Change Log

TODO:
- Fix ColorPicker to not callback twice on Okay when opacity is enabled
- Allow for sub categories

v1.0
- Added CONTROLTYPE_EDITBOX
- Removed isTemp  and replaced it with isGUI which is only a passthrough value to the callback; text and saved var are still updated. 
It is now: callback(value, isGUI, isUpdate)
isGUI is now passed as true for all GUI control interactions (but not for the Okay, Cancel and Default blizzard option panel buttons). 
- Added control:Refresh() called when the blizzard options frame is shown
- Added control:Okay(), control:Cancel() and control:Reset() that are called for each control that has them when you click the blizzard interface buttons
- Fixed Cancel to correctly revert values/controls to their previous state. Doesn't pass isGUI.
v0.94
- Added CONTROLTYPE_COLORPICKER
- Added Portfolio.Round (Round-Half-Up)
v0.93
- Refactored some code/files
- Added LuaDocs
- Renamed checkbox.dependentOptions to dependentControlsByID for clarity
v0.92
- option:Enabled() now restores custom font object colors
- Fixed success and result global var leaks
- Added CONTROLTYPE_DROPDOWN
- Added control click sounds
- Fixed tooltipText to be optional
v0.91
- Fixed a bug with text functions
v0.9
- Added CONTROLTYPE_TEXT
- Fixed Text height/wrapping
- Added control:Reset() - Disable() no longer resets.
- dependentOptions will reset after disabling, but dependentControls will not
- UpdateDependentControls renamed UpdateDependents, handles both dependentOptions and dependentControls
- slider:SetMinMaxValues(min, max) now updates the stored min/max and texts if minText/maxText are not set
- Enable/Disable now changes text color
- tooltipText is now as flexible as text
- Headers and Text controls now dynamically resize with text:UpdateTextWrap() called OnShow
- Refactored and abstracted much of the control functionality to Portfolio.Control and renamed files.
- Fixed a bunch of minor bugs
v0.8
- Text can now have %s or %d to be formatted with the option value. control:UpdateText() is called when an option is updated
- Added dependentControls and dependentOptions for CONTROLTYPE_CHECKBOX to Enable/Disable other options
- control:Disable() now resets the value to default
- Cleaned up OnShow code so it doesn't call callbacks excessively
- callback(value, isUpdate) now pass an extra boolean argument when called by control:Update() (used when loading vars)
v0.7
- Working Slider option
v0.6
- Now uses LibStub to handle library versioning
- Removed event handling code and default variable initialization in favor of using LibDefaults
- Upgraded to InterfaceOptionAboutPanel lib
- Removed noAutoDefault. Now always loads vars that have defaults set.
- loadVars is renamed initCallbacks and now defaults to true
- Changed how GetValue/SetValue/Update works on the options
v0.5
- Added control:init() function for custom modification to the config frame
- Added callbacks on vars loaded (or before init if LoD) if loadVars is set
- Added Button
- Added some Dropdown code (incomplete)
- Added AboutPanel generated from toc info
v0.4
- Refactored the code into 3 files
- Added some Slider code (incomplete)
- Changed the registration arguments to match blizzard's format
v0.3
- Only loads once if embedded
- Defaults are now defined on vars loaded (immediately if registered after) if a default is supplied and the saved variables are nil
- Added noAutoDefault param for options and option sets. If defined, option's value overrides set's values.
v0.2
- Added a scroll frame for the main option panel
- Slider in progress
- Code cleanup
v0.1
- Checkboxes work

]]--

local version = 1.0
local Portfolio, oldminor = LibStub:NewLibrary("Portfolio", version)
if not Portfolio then return end

Portfolio.version = version
Portfolio.registered = Portfolio.registered or {}

-- Loading Flags (nil so that other files will load)
Portfolio.RegisterControl = nil
Portfolio.Control = nil

------------------------------------------------------------------------------
--[[ Portfolio External - Option Set Registration ]]--
------------------------------------------------------------------------------

--[[-- Register a new set of options.
	Creates and registers the option set frame and registers all the options with 
	<a href="RegisterControl.html">RegisterControl</a>. 

	@param optionSetTable	(table) option set registration table
	@return					options frame
--]]--
function Portfolio.RegisterOptionSet(optionSetTable)
	
	--Check for duplicate set name (id)
	if (Portfolio.registered[optionSetTable.id]) then
		Portfolio.PrintError("RegisterOptionSet: Option set already exists - "..optionSetTable.id)
		return
	end
	
	--Create Control Panel Frame
	local optionsFrame, frameName = Portfolio.CreateOptionsFrame(optionSetTable)
	
	--Shortcut: Set all unassigned options' novar
	if (optionSetTable.novarDefault) then
		for i, option in next, optionSetTable.options do
			if (option.tvar == nil and option.cvar == nil and option.uvar == nil and option.novar == nil) then
				option.novar = optionSetTable.novarDefault
			end
		end
	end
	
	-- Add Header & Options
	Portfolio.PopulateOptionsFrame(optionsFrame, optionSetTable, frameName)

	--OnLoad
	--optionsFrame.options = optionSetTable
	--optionSetTable.frame = optionsFrame

	optionsFrame.okay = Portfolio.OptionSet_Okay;
	optionsFrame.cancel = Portfolio.OptionSet_Cancel;
	optionsFrame.default = Portfolio.OptionSet_Reset;
	optionsFrame.refresh = Portfolio.OptionSet_Refresh;

	--frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	--frame:SetScript("OnEvent", BlizzardOptionsPanel_OnEvent);
	--BlizzardOptionsPanel_OnLoad(optionsFrame, okay, cancel, default, refresh)
	
	--UIDropDownMenu_SetSelectedValue(InterfaceOptionsControlsPanelAutoLootKeyDropDown, GetModifiedClick("AUTOLOOTTOGGLE"));
	--UIDropDownMenu_EnableDropDown(InterfaceOptionsControlsPanelAutoLootKeyDropDown);
	
	optionsFrame:Hide()
	
	-- Store the newly registered frame
	Portfolio.registered[optionSetTable.id] = optionsFrame
	
	InterfaceOptions_AddCategory(optionsFrame)
	
	-- If the addon name is valid, add an about page
	if (optionsFrame.addon) then
		LibStub("InterfaceOptionAboutPanel").new(optionsFrame.name, optionsFrame.addon)
		LibStub("LibDefaults"):SetScript(optionsFrame.addon, function() 
			optionsFrame:CallCallbacks() 
		end)
	end
	
	return optionsFrame
end

------------------------------------------------------------------------------
--[[ Options Frame Functions ]]--
------------------------------------------------------------------------------

--[[-- Get the options frame by set id.

	@usage			control = optionsFrame:GetControl(optionid)
	@param setid	(string) option set id
	@return			options frame
--]]--
function Portfolio.GetOptionsFrame(setid)
	return Portfolio.registered[setid]
end

--[[-- Get the control frame by option id.

	@usage				control = optionsFrame:GetControl(optionid)
	@param optionsFrame	options frame
	@param optionid		(string) option id
	@return				control frame
--]]--
function Portfolio.GetControl(optionsFrame, optionid)
	for _, control in next, optionsFrame.controls do
		if (control.id == optionid) then
			return control
		end
	end
end

--[[-- Call Update() on all the controls.

	@usage	optionsFrame:CallCallbacks()
	@param optionsFrame	options frame
--]]--
function Portfolio.CallCallbacks(optionsFrame)
	--Portfolio.Print("CallCallbacks: "..optionsFrame.addon)
	for _, control in next, optionsFrame.controls do
		if (control.Update) then
			control:Update()
		end
	end
end

------------------------------------------------------------------------------
--[[ Portfolio Internal - Registration Support Functions ]]--
------------------------------------------------------------------------------

function Portfolio.CreateOptionsFrame(optionTable)
	
	local frameName = optionTable.id.."ControlPanel"
	local parent = InterfaceOptionsFramePanelContainer
	local optionsFrame = CreateFrame("ScrollFrame", frameName, parent, "UIPanelScrollFrameTemplate")
	optionsFrame.scrollChild = CreateFrame("Frame", frameName.."ScrollChildFrame", optionsFrame)
	optionsFrame:SetScrollChild(optionsFrame.scrollChild)
	optionsFrame.scrollChild:SetWidth(parent:GetWidth())
	optionsFrame.scrollChild:SetHeight(parent:GetHeight()-10)
	--optionsFrame.scrollChild:SetBackdrop(GameTooltip:GetBackdrop())
	optionsFrame:SetVerticalScroll(0)
	optionsFrame.scrollBarHideable = true
	
	optionsFrame.savedVarTable = optionTable.savedVarTable
	optionsFrame.id = optionTable.id
	if (optionTable.parent) then
		optionsFrame.parent = optionTable.parent
	end
	
	-- Validate the addon name
	local addon = optionTable.addon or optionTable.id
	if (GetAddOnInfo(addon)) then
		optionsFrame.addon  = addon
	end
	
	-- Defaults to true
	optionsFrame.initCallbacks = optionTable.initCallbacks == nil and true or optionTable.initCallbacks
	
	return optionsFrame, frameName
end

function Portfolio.PopulateOptionsFrame(optionsFrame, optionTable, frameName)
	
	optionsFrame.GetControl = Portfolio.GetControl
	optionsFrame.CallCallbacks = Portfolio.CallCallbacks
	optionsFrame.RegisterControl = Portfolio.RegisterControl
	
	optionsFrame.name = optionTable.text 
		or optionsFrame.addon and GetAddOnMetadata(optionsFrame.addon, "Title") 
		or optionTable.id
	
	--Title w/ SubText
	local header = {}
	header.type = CONTROLTYPE_HEADER
	header.id = frameName.."Title"
	header.text = optionsFrame.name
	header.subText = optionTable.subText 
		or optionsFrame.addon and GetAddOnMetadata(optionsFrame.addon, "Notes")

	optionsFrame:RegisterControl(header)
	
	--Options
	for i, option in next, optionTable.options do
		optionsFrame:RegisterControl(option)
	end

end


------------------------------------------------------------------------------
--[[ Portfolio Internal - Option Set Frame Event Functions ]]--
------------------------------------------------------------------------------

function Portfolio.OptionSet_Refresh(optionsFrame)
	
	optionsFrame:SetVerticalScroll(0)
	-- Override SetAllPoints on the parent to make the scroll frame and bar line up
	optionsFrame:SetPoint("TOPLEFT", 4, -4)
	optionsFrame:SetPoint("BOTTOMRIGHT", -26, 4)
	
	for i, control in next, optionsFrame.controls do
		if control.Refresh then
			control:Refresh()
		end
	end
end

function Portfolio.OptionSet_Okay(optionsFrame)
	for i, control in next, optionsFrame.controls do
		if control.Okay then
			control:Okay()
		end
	end
end

function Portfolio.OptionSet_Cancel(optionsFrame)
	for i, control in next, optionsFrame.controls do
		if control.Cancel then
			control:Cancel()
		end
	end
end

function Portfolio.OptionSet_Reset(optionsFrame)
	for i, control in next, optionsFrame.controls do
		if control.Reset then
			control:Reset()
		end
	end
end


------------------------------------------------------------------------------
--[[ Support Functions ]]--
------------------------------------------------------------------------------

function Portfolio.Print(text)
	(SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME):AddMessage(text)
end

function Portfolio.PrintError(text)
	(SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME):AddMessage(text, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
end

function Portfolio.CopyTableElements(to, from, ...)
	for i=1, select("#", ...) do
		local key = select(i, ...)
		to[key] = from[key]
	end
end

function Portfolio.Round(num, idp)
	local mult = 10^(idp or 0)
	return floor(num * mult + 0.5) / mult
end

