--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPLibrary/Library.lua
	* Component: Library
	* Details:
		This file deals with various functions that are shared between the RPBot and RPWaitlist.
		Skining, lib-st building primarily.
]]

-- Leverage SVN
--@alpha@
local MAJOR,MINOR = "RPLibrary", 1
--@end-alpha@. 
--[===[@non-alpha@
local MAJOR,MINOR = "RPLibrary", @file-revision@
--@end-non-alpha@]===]
local RPLibrary = LibStub:NewLibrary(MAJOR, MINOR)
if not RPLibrary then return end

RPLibrary.embeds = RPLibrary.embeds or {} -- what objects embed this lib

--- embedding and embed handling
local mixins = {
	"Skin",
	"SkinEditBox",
	"ScriptEditBox",
	"QualityBorder",
	"QualityBorderResize",
	"BackdropFrame",
	"ItemButtonWrapper",
	"BuildTable",
	"BuildRow",
	"BuildColumn",
	"StripTable",
	"StripRow",
	"StripColumn",
	"STBuild",
	"STStrip",
	"Split",
	"classList",
	"tierList",
	"GetItemID",
	"GetColor",
} 

-- Copied from XLoot, makes my life that much easier.
local _G = getfenv(0)

local backdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}

local gradientOn = {"VERTICAL", .1, .1, .1, 0, .25, .25, .25, 1}
local gradientOff = {"VERTICAL", 0, 0, 0, 1, 0, 0, 0, 1}

-- Pickup settings from installed mods
local sdb = (oSkin and oSkin.db.profile or nil) or (Skinner and Skinner.db.profile or nil) or {
	BackdropBorder = {r = 0.5, g = 0.5, b = 0.5, a = 1},
	Backdrop = {r = 0, g = 0, b = 0, a = 0.9},
	FadeHeight = {enable = false, value = 500, force = false},
	Gradient = true,
}

--- Skins the given frame.
-- This code is from XLoot, currently in use without
-- permission I am contacting the developers to see if
-- I can use it or not.
-- @param frame The frame to be skinned.
-- @param header The frame header.
-- @param bba BackdropBorder Alpha
-- @param ba Backdrop Alpha
-- @param fh FadeHeight
-- @param Backdrop
function RPLibrary:Skin(frame, header, bba, ba, fh, bd)
	if not frame then return end
	
	frame:SetBackdrop(bd or backdrop)
	frame:SetBackdropBorderColor(sdb.BackdropBorder.r or .5, sdb.BackdropBorder.g or .5, sdb.BackdropBorder.b or .5, bba or sdb.BackdropBorder.a or 1)
	frame:SetBackdropColor(sdb.Backdrop.r or 0, sdb.Backdrop.g or 0, sdb.Backdrop.b or 0, ba or sdb.Backdrop.a or .9)

	if not frame.tfade then frame.tfade = frame:CreateTexture(nil, "BORDER") end
	frame.tfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")

	if sdb.FadeHeight.enable and (sdb.FadeHeight.force or not fh) then 
		fh = sdb.FadeHeight.value <= math.ceil(frame:GetHeight()) and sdb.FadeHeight.value or math.ceil(frame:GetHeight())
	end 

	frame.tfade:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
	if fh then frame.tfade:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -4, -fh)
	else frame.tfade:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4) end

	frame.tfade:SetBlendMode("ADD")
	frame.tfade:SetGradientAlpha(unpack(sdb.Gradient and gradientOn or gradientOff)) 
	
	if header and _G[frame:GetName().."Header"] then
		_G[frame:GetName().."Header"]:Hide()
		_G[frame:GetName().."Header"]:SetPoint("TOP", frame, "TOP", 0, 7)
	end
	
end

function RPLibrary:SkinEditBox(editbox)
	editbox:SetFontObject("GameFontHighlightSmall")
	local left = editbox:CreateTexture(nil, "BACKGROUND")
	left:SetWidth(8)
	left:SetHeight(20)
	left:SetPoint("LEFT", -5, 0)
	left:SetTexture("Interface\\Common\\Common-Input-Border")
	left:SetTexCoord(0, 0.0625, 0, 0.625)

	local right = editbox:CreateTexture(nil, "BACKGROUND")
	right:SetWidth(8)
	right:SetHeight(20)
	right:SetPoint("RIGHT", 0, 0)
	right:SetTexture("Interface\\Common\\Common-Input-Border")
	right:SetTexCoord(0.9375, 1, 0, 0.625)

	local center = editbox:CreateTexture(nil, "BACKGROUND")
	center:SetHeight(20)
	center:SetPoint("RIGHT", right, "LEFT", 0, 0)
	center:SetPoint("LEFT", left, "RIGHT", 0, 0)
	center:SetTexture("Interface\\Common\\Common-Input-Border")
	center:SetTexCoord(0.0625, 0.9375, 0, 0.625)
end

function RPLibrary:ScriptEditBox(editbox, insert)
	if insert then
		editbox:SetScript("OnEditFocusLost", function(self)
			self:HighlightText(0, 0)
			ChatEdit_InsertLink = self.savedInsertLink
		end)
		editbox:SetScript("OnEditFocusGained", function(self) 
			self:HighlightText()
			self.savedInsertLink = ChatEdit_InsertLink
			ChatEdit_InsertLink = function (link)
				self:Insert(" "..link)
			end
		end)
	else
		editbox:SetScript("OnEditFocusLost", function(self)
			self:HighlightText(0, 0)
		end)
		editbox:SetScript("OnEditFocusGained", function(self) 
			self:HighlightText()
		end)
	end
	editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
end

--- Create a quality colored border on the given button.
-- This code is from XLoot, currently in use without
-- permission I am contacting the developers to see if
-- I can use it or not.
-- @param button The button
function RPLibrary:QualityBorder(button)
	local frame = button.wrapper or button
	local border = frame:CreateTexture(button:GetName() .. "QualBorder", "OVERLAY")
	border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	border:SetBlendMode("ADD")
	border:SetAlpha(0.5)
	border:SetHeight(button:GetHeight()*1.8)
	border:SetWidth(button:GetWidth()*1.8)
	border:SetPoint("CENTER", frame, "CENTER", 0, 1)
	border:Hide()
	return border
end

--- Resize the quality colored border on the given frame.
-- This code is from XLoot, currently in use without
-- permission I am contacting the developers to see if
-- I can use it or not.
-- @param frame The frame
-- @param hmult Height Multiplyier
-- @param ymult Width Multiplyier
-- @param hoff Height Offset
-- @param yoff Width Offset
function RPLibrary:QualityBorderResize(frame, hmult, ymult, hoff, yoff)
	local border = _G[frame:GetName().."QualBorder"]
	local width, height = frame:GetWidth(), frame:GetHeight()
	border:SetHeight(height*(ymult or 1.62))
	border:SetWidth(width*(hmult or 1.72))
	border:SetPoint("CENTER", frame, "CENTER", hoff or 5, yoff or 1)
end

--- Give a backdrop to the given frame.
-- This code is from XLoot, currently in use without
-- permission I am contacting the developers to see if
-- I can use it or not.
-- @param frame The frame
-- @param bgcolor Background color
-- @param bordercolor Border color
function RPLibrary:BackdropFrame(frame, bgcolor, bordercolor)
	frame:SetBackdrop(	{	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
										edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
										tile = true, tileSize = 32, edgeSize = 15, 
										insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	frame:SetBackdropColor(unpack(bgcolor))
	frame:SetBackdropBorderColor(unpack(bordercolor))
end

--- Wrap the button in a backdrop.
-- This code is from XLoot, currently in use without
-- permission I am contacting the developers to see if
-- I can use it or not.
-- @param button The button
-- @param woff Width Offset
-- @param hoff Height Offset
-- @param edgesize Edge Size
-- @param borderinset Border Inset
function RPLibrary:ItemButtonWrapper(button, woff, hoff, edgesize, borderinset)
	local wrapper = button.wrapper or CreateFrame("Frame", button:GetName().."Wrapper", button)
	wrapper:SetWidth(button:GetWidth()+(woff or 10))
	wrapper:SetHeight(button:GetHeight()+(hoff or 10))
	wrapper:ClearAllPoints()
	wrapper:SetPoint("CENTER", button, "CENTER")
	self:Skin(wrapper)
	if edgesize then
		local backdrop = wrapper:GetBackdrop()
		backdrop.edgeSize = edgesize
		wrapper:SetBackdrop(backdrop)
	end
	wrapper:SetBackdropColor(1, 1, 1, 0)
	wrapper:SetBackdropBorderColor(.7, .7, .7, 1)
	wrapper:Show()
	return wrapper
end
--- Build a lib-st table, row or column intelegently.
-- If given a table of tables of values then we create a table
-- If given a table of values then create a row
-- Otherwise create a column
-- @param tb The object to convert
-- @param argList Table of special arguements to pass to BuildColumn <code>{args, color, colorargs, dce}</code>
-- @param color Color object for lib-st
-- @param colorargs Arguments for the color object if it is a function
-- @param dce DoCellUpdate, allows a custom display function to be used for that row or cell
function RPLibrary:STBuild(value, argList, color, colorargs, dce)
	local temp = false
	if (type(value) == "table") then
		-- Bad table, we want tables numbered only
		if (not value[1]) then
			return nil
		end
		
		if (type(value[1]) == "table") then
			temp = self:BuildTable(value, argList, color, colorargs, dce)
		else 
			temp = self:BuildRow(value, argList, color, colorargs, dce)
		end
	else
		temp = self:BuildColumn(value, argList, color, colorargs, dce)
	end
	return temp
end

--- Build a table in the format required for lib-st.
-- This function will take the given the data table and return it into lib-st format.
-- If color is given as a function and no colorargs are supplied the entire row will be passed as colorargs.
-- @param tb The table to convert
-- @param argList Table of special arguements to pass to BuildColumn <code>{args, color, colorargs, dce}</code>
-- @param color Color object for lib-st
-- @param colorargs Arguments for the color object if it is a function
-- @param dce DoCellUpdate, allows a custom display function to be used for that row or cell
function RPLibrary:BuildTable(tb, argList, color, colorargs, dce)
	local newtb = {}
	for i=1,#tb do
		newtb[i] = self:BuildRow(tb[i], argList, color, colorargs, dce)
	end
	return newtb
end

--- Build a row in the format required for lib-st.
-- This function will take the given the data row and return it into lib-st format.
-- If color is given as a function and no colorargs are supplied the entire row will be passed as colorargs.
-- @param row The row to convert
-- @param argList Table of special arguements to pass to BuildColumn <code>{args, color, colorargs, dce}</code>
-- @param color Color object for lib-st
-- @param colorargs Arguments for the color object if it is a function
-- @param dce DoCellUpdate, allows a custom display function to be used for that row or cell
function RPLibrary:BuildRow(row, argList, color, colorargs, dce)
	local newrow = {["cols"] = {}}
	for i=1,#row do
		--RPB:Print(row[i], unpack(argList[i] or {}))
		newrow["cols"][i] = self:BuildColumn(row[i], unpack(argList[i] or {}))
	end
	if color then
		newrow["color"] = color
	end
	if colorargs then
		newrow["colorargs"] = { colorargs }
	end
	if dce then
		newrow["DoCellUpdate"] = dce
	end
	if (colorargs == nil and type(color) == "function") then
		newrow["colorargs"] = { newrow }
	end
	return newrow
end

--- Build a column in the format required for lib-st.
-- This function will take the given the data column and return it into lib-st format.
-- If color is given as a function and no colorargs are supplied the entire row will be passed as colorargs.
-- @param value The column value to return
-- @param args Args for value if value is a function
-- @param color Color object for lib-st
-- @param colorargs Arguments for the color object if it is a function
-- @param dce DoCellUpdate, allows a custom display function to be used for that row or cell
function RPLibrary:BuildColumn(value, args, color, colorargs, dce)
	if (colorargs == nil and type(color) == "function") then colorargs = value end
	local temp = {["value"] = value}
	if args then
		temp["args"] = args
	end
	if color then
		temp["color"] = color
	end
	if colorargs then
		temp["colorargs"] = { colorargs }
	end
	if dce then
		temp["DoCellUpdate"] = dce
	end
	return temp
end
--- Strip the extra information required for lib-st from the given object.
-- If given a table of tables of values then we strip a table
-- If given a table of values then strip a row
-- Otherwise strip a column
-- @param tb The object to convert
-- @param argList Table of special arguements to pass to BuildColumn <code>{args, color, colorargs, dce}</code>
-- @param color Color object for lib-st
-- @param colorargs Arguments for the color object if it is a function
-- @param dce DoCellUpdate, allows a custom display function to be used for that row or cell
function RPLibrary:STStrip(value)
	local temp = false
	if (type(value) == "table") then
		-- Bad table, we want tables numbered only
		if not value[1] then return nil end
		
		if (type(value[1]) == "table") then
			temp = self:StripTable(value)
		else
			temp = self:StripRow(value)
		end
	else
		temp = self:StripColumn(value)
	end
	return temp
end

--- Strip the extra information required for lib-st from the given table.
-- This function will take the given the lib-st table and return a simple data table
-- @param tb The table to strip
function RPLibrary:StripTable(tb)
	local t = {}
	for i=1,#tb do
		t[i] = self:StripRow(tb[i])
	end
	return t
end

--- Strip the extra information required for lib-st from the given row.
-- This function will take the given the lib-st row and return a simple data row
-- @param tb The row to strip
function RPLibrary:StripRow(row)
	local r = {}
	if (row.cols) then
		for i=1,#row.cols do
			r[i] = self:StripColumn(row.cols[i])
		end
	end
	return r;
end

--- Strip the extra information required for lib-st from the given column.
-- This function will take the given the lib-st column and return a simple data column
-- @param tb The column to strip
function RPLibrary:StripColumn(col)
	return col.value
end

local classColors = {
["DEATH KNIGHT"]	= {["r"] = 0.77, 	["g"] = 0.12, 	["b"] = 0.23, 	["a"] = 1.0,},
["DRUID"] 			= {["r"] = 1.00, 	["g"] = 0.49, 	["b"] = 0.04, 	["a"] = 1.0,},
["HUNTER"] 			= {["r"] = 0.67, 	["g"] = 0.83, 	["b"] = 0.45, 	["a"] = 1.0,},
["MAGE"] 			= {["r"] = 0.41, 	["g"] = 0.80, 	["b"] = 0.94, 	["a"] = 1.0,},
["PALADIN"] 		= {["r"] = 0.96, 	["g"] = 0.55, 	["b"] = 0.73, 	["a"] = 1.0,},
["PRIEST"] 			= {["r"] = 1.00, 	["g"] = 1.00, 	["b"] = 1.00, 	["a"] = 1.0,},
["ROGUE"] 			= {["r"] = 1.00, 	["g"] = 0.96, 	["b"] = 0.41, 	["a"] = 1.0,},
["SHAMAN"] 			= {["r"] = 0.14, 	["g"] = 0.35, 	["b"] = 1.00, 	["a"] = 1.0,},
["WARLOCK"] 		= {["r"] = 0.58, 	["g"] = 0.51, 	["b"] = 0.79, 	["a"] = 1.0,},
["WARRIOR"] 		= {["r"] = 0.78, 	["g"] = 0.61, 	["b"] = 0.43, 	["a"] = 1.0,},
}

RPLibrary.classList = 
{
["deathknight"]	= "DEATH KNIGHT",
["druid"] 		= "DRUID",
["hunter"] 		= "HUNTER",
["mage"] 		= "MAGE",
["paladin"] 	= "PALADIN",
["priest"] 		= "PRIEST",
["rogue"] 		= "ROGUE",
["shaman"] 		= "SHAMAN",
["warlock"]		= "WARLOCK",
["warrior"]		= "WARRIOR",
}

RPLibrary.tierList = 
{
["DEATH KNIGHT"] = {"ROGUE", "DEATH KNIGHT", "MAGE", "DRUID"},
["DRUID"] 		 = {"ROGUE", "DEATH KNIGHT", "MAGE", "DRUID"},
["HUNTER"] 		 = {"WARRIOR", "HUNTER", "SHAMAN"},
["MAGE"] 		 = {"ROGUE", "DEATH KNIGHT", "MAGE", "DRUID"},
["PALADIN"] 	 = {"PALADIN", "PRIEST", "WARLOCK"},
["PRIEST"] 		 = {"PALADIN", "PRIEST", "WARLOCK"},
["ROGUE"] 		 = {"ROGUE", "DEATH KNIGHT", "MAGE", "DRUID"},
["SHAMAN"] 		 = {"WARRIOR", "HUNTER", "SHAMAN"},
["WARLOCK"] 	 = {"PALADIN", "PRIEST", "WARLOCK"},
["WARRIOR"] 	 = {"WARRIOR", "HUNTER", "SHAMAN"},
}

function ClassColor(class)
	if (class and classColors[string.upper(class)]) then
		return classColors[string.upper(class)]
	else
		return {["r"] = 1.00, 	["g"] = 1.00, 	["b"] = 1.00, 	["a"] = 1.0,}
	end
end

DoTimestampUpdate = function(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, ...)
	if fShow then
		local cellData = data[realrow].cols[column];

		cellFrame.text:SetText(date("%A %b %d %I:%M%p",cellData.value));
		
		local color = cellData.color;
		local colorargs = nil;
		if not color then 
			color = cols[column].color;
			if not color then 
				color = data[realrow].color;
				if not color then 
					color = defaultcolor;
				else
					colorargs = data[realrow].colorargs;
				end
			else
				colorargs = cols[column].colorargs;
			end
		else
			colorargs = cellData.colorargs;
		end	
		if type(color) == "function" then 
			color = color(unpack(colorargs or {cellFrame}));
		end
		cellFrame.text:SetTextColor(color.r, color.g, color.b, color.a);
	else
		cellFrame.text:SetText("");
	end
end

function ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	
	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end


function RPLibrary:GetItemID(link)
	local _, _, itemid  = string.find(link, "item:(%d+)")
	return itemid
end

-- Taken from Prat 3.0, credits to Sylvanaar and the entire Prat Team
function GetColor(Name)
	local hash = 17
	for i=1,string.len(Name) do
		hash = hash * 37 * string.byte(Name, i);
	end

	local r = math.floor(math.fmod(hash / string.byte(Name, 1), 255));
	local g = math.floor(math.fmod(hash / string.byte(Name, 2), 255));
	local b = math.floor(math.fmod(hash / string.byte(Name, 3), 255));

    if ((r * 299 + g * 587 + b * 114) / 1000) < 105 then
    	r = math.abs(r - 255);
        g = math.abs(g - 255);
        b = math.abs(b - 255);
    end
	--RPB:Print(r,g,b)
	return {["r"] = r / 255.0, ["g"] = g / 255.0, ["b"] = b / 255.0, ["a"] = 0.7}
end

function RPLibrary:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

--- Finally: upgrade our old embeds
for target, v in pairs(RPLibrary.embeds) do
	RPLibrary:Embed(target)
end


local optionTable = {
	id="RPS",
	text="Raid Points System",
	addon="Raid Points System",
	options={}
}

local Portfolio = LibStub and LibStub("Portfolio")
if Portfolio then
	Portfolio.RegisterOptionSet(optionTable)
end