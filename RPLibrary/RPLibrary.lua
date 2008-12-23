local MAJOR,MINOR = "RPLibrary", 1
local RPLibrary, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not RPLibrary then return end

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

function RPLibrary:QualityBorderResize(frame, hmult, ymult, hoff, yoff)
	local border = _G[frame:GetName().."QualBorder"]
	local width, height = frame:GetWidth(), frame:GetHeight()
	border:SetHeight(height*(ymult or 1.62))
	border:SetWidth(width*(hmult or 1.72))
	border:SetPoint("CENTER", frame, "CENTER", hoff or 5, yoff or 1)
end

function RPLibrary:BackdropFrame(frame, bgcolor, bordercolor)
	frame:SetBackdrop(	{	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
										edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
										tile = true, tileSize = 32, edgeSize = 15, 
										insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	frame:SetBackdropColor(unpack(bgcolor))
	frame:SetBackdropBorderColor(unpack(bordercolor))
end

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

function RPLibrary:BuildColumn(value, color, args, colorargs, cellupdate)
	local temp = {
		["value"] = value,
		["args"] = args,
		["color"] = color,
		["colorargs"] = colorargs,
		["DoCellUpdate"] = cellupdate,
	}
	return temp
end

function RPLibrary:BuildRow(cols, color, colorargs)
	if not cols then cols = {} end
	local temp = {
		["cols"] = 	cols,
		["color"] = color,
		["colorargs"] = colorargs,
	}
	return temp
end

function RPLibrary:AppendRow(row, color, colorargs)
	row["color"] = color
	row["colorargs"] = colorargs
end

function RPLibrary:StripRow(row)
	local r = {}
	if (row.cols) then
		for i=1,#row.cols do
			r[i] = self:StripColumn(row.cols[i])
		end
	end
	return r;
end

function RPLibrary:StripColumn(col)
	return col.value
end

function RPLibrary:StripTable(tb)
	local t = {}
	for i=1,#tb do
		t[i] = self:StripRow(tb[i])
	end
	return t
end

RPLibrary.classColors = {
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
"death knight",
"druid",
"hunter",
"mage",
"paladin",
"priest",
"rogue",
"shaman",
"warlock",
"warrior",
}

-- String Split function
function RPLibrary:Split (s,t)
	local l = {n=0}
	local f = function (s)
		l.n = l.n + 1
		l[l.n] = s
	end
	local p = "%s*(.-)%s*"..t.."%s*"
	s = string.gsub(s,"^%s+","")
	s = string.gsub(s,"%s+$","")
	s = string.gsub(s,p,f)
	l.n = l.n + 1
	l[l.n] = string.gsub(s,"(%s%s*)$","")
	return l
end

function RPLibrary:ClassColor(class)
	if (class and self.classColors[string.upper(class)]) then
		return self.classColors[string.upper(class)]
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

function RPLibrary:SkinEditBox(editbox)
		editbox:SetFontObject("GameFontHighlightSmall")
		editbox:SetScript("OnEditFocusLost", function(self)
			self:HighlightText(0, 0)
			ChatEdit_InsertLink = self.savedInsertLink
		end)
		editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
		editbox:SetScript("OnEditFocusGained", function(self) 
			self:HighlightText()
			self.savedInsertLink = ChatEdit_InsertLink
			ChatEdit_InsertLink = function (link)
				self:Insert(" "..link)
			end
		end)

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
