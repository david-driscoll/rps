local MAJOR, MINOR = "ScrollingTable", tonumber("@project-version@") or 9999;
local ScrollingTable, oldminor = LibStub:NewLibrary(MAJOR, MINOR);
if not ScrollingTable then 
	return; -- No Upgrade needed. 
end 

do 
	local defaultcolor = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 };
	local defaulthighlight = { ["r"] = 1.0, ["g"] = 0.9, ["b"] = 0.0, ["a"] = 0.5 };
	local defaulthighlightblank = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.0 };
	local lrpadding = 2.5;
	
	local ScrollPaneBackdrop  = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 5, bottom = 3 }
	};
	
	local framecount = 1; 
		
	local SetHeight = function(self)
		if #self.cols == self.displayCols then
			self.frame:SetHeight( (self.displayRows * self.rowHeight) + 10);
		else
			self.frame:SetHeight( (self.displayRows * self.rowHeight) + 10 + 17);
		end
		self:Refresh();
	end
	
	local SetWidth = function(self)
		local count = 0;
		local width = 13;
		local widthHigh = width;
		for col=1,#self.cols do
			if self.cols[col].header then
				count = count + 1
				width = width + self.cols[col].width
			end
		end
		if #self.cols == self.displayCols then
			for col=1,(self.displayCols) do
				widthHigh = widthHigh + self.cols[col].width
			end
		else
			for i=count,(#self.cols-self.displayCols) do
				local widthNew = width
				for col=1,(self.displayCols-count) do
					widthNew = widthNew + self.cols[i+col].width
				end
				if widthNew > widthHigh then
					widthHigh = widthNew
				end
			end
		end
		self.frame:SetWidth(widthHigh+20);
		self:Refresh();
	end
	
	--- API for a ScrollingTable table
	-- @name SetHighLightColor
	-- @description Set the row highlight color of a frame ( cell or row )
	-- @usage st:SetHighLightColor(rowFrame, color)	
	-- @see http://www.wowace.com/addons/lib-st/pages/colors/
	local function SetHighLightColor (self, frame, color)
		if not frame.highlight then 
			frame.highlight = frame:CreateTexture(nil, "OVERLAY");
			frame.highlight:SetAllPoints(frame);
		end
		frame.highlight:SetTexture(color.r, color.g, color.b, color.a);
	end
	
	local SetBackgroundColor = function(self, frame, color)
		if not frame.background then 
			frame.background = frame:CreateTexture(nil, "BACKGROUND");
			frame.background:SetAllPoints(frame);
		end
		frame.background:SetTexture(color.r, color.g, color.b, color.a);
	end
	
	local FireUserEvent = function (self, frame, event, handler, ...)
		if not handler( ...) then
			if self.DefaultEvents[event] then 
				self.DefaultEvents[event]( ...);
			end
		end
	end
	
	--- API for a ScrollingTable table
	-- @name RegisterEvents
	-- @description Set the event handlers for various ui events for each cell.
	-- @usage st:RegisterEvents(events, true)	
	-- @see http://www.wowace.com/addons/lib-st/pages/ui-events/
	local function RegisterEvents (self, events, fRemoveOldEvents) 
		local table = self; -- save for closure later
		
		for i, row in ipairs(self.rows) do 
			for j, col in ipairs(row.cols) do
				-- unregister old events.
				if fRemoveOldEvents and self.events then 
					for event, handler in pairs(self.events) do 
						col:SetScript(event, nil);
					end
				end
				
				-- register new ones.
				for event, handler in pairs(events) do 
					col:SetScript(event, function(cellFrame, ...)
						local realindex = table.filtered[i+table.offset];
						table:FireUserEvent(col, event, handler, row, cellFrame, table.data, table.cols, i, realindex, j, table, ... );
					end);
				end
			end
		end
		
		for j, col in ipairs(self.head.cols) do
			-- unregister old events.
			if fRemoveOldEvents and self.events then 
				for event, handler in pairs(self.events) do 
					col:SetScript(event, nil);
				end
			end
			
			-- register new ones.
			for event, handler in pairs(events) do 
				col:SetScript(event, function(cellFrame, ...)
					table:FireUserEvent(col, event, handler, self.head, cellFrame, table.data, table.cols, nil, nil, j, table, ...);
				end);
			end
		end
		self.events = events;
	end
	
	--- API for a ScrollingTable table
	-- @name SetDisplayRows
	-- @description Set the number and height of displayed rows
	-- @usage st:SetDisplayRows(10, 15)	
	local function SetDisplayRows (self, num, rowHeight)
		local table = self; -- reference saved for closure
		-- should always set columns first
		self.displayRows = num;
		self.rowHeight = rowHeight;
		if not self.rows then 
			self.rows = {};
		end
		for i = 1, num do 
			local row = self.rows[i];
			if not row then 
				row = CreateFrame("Button", self.frame:GetName().."Row"..i, self.frame);
				self.rows[i] = row;
				if i > 1 then 
					row:SetPoint("TOPLEFT", self.rows[i-1], "BOTTOMLEFT", 0, 0);
					row:SetPoint("TOPRIGHT", self.rows[i-1], "BOTTOMRIGHT", 0, 0);
				else
					row:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 4, -5);
					row:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -4, -5);
				end
				row:SetHeight(rowHeight);
			end
			
			if not row.cols then 
				row.cols = {};
			end
			for j, colj in pairs(self.colList) do
				local col = row.cols[j];
				if not col then 
					col = CreateFrame("Button", row:GetName().."col"..j, row);
					col.text = row:CreateFontString(col:GetName().."text", "OVERLAY", "GameFontHighlightSmall");
					row.cols[j] = col;
					col:EnableMouse(true);
					col:RegisterForClicks("AnyUp");
					
					if self.events then 
						for event, handler in pairs(self.events) do 
							col:SetScript(event, function(cellFrame, ...)
								local realindex = table.filtered[i+table.offset];
								table:FireUserEvent(col, event, handler, row, cellFrame, table.data, table.cols, i, realindex, colj, table, ... );
							end);
						end
					end
				end
								
				if j > 1 then 
					col:SetPoint("LEFT", row.cols[j-1], "RIGHT", 0, 0);
				else
					col:SetPoint("LEFT", row, "LEFT", 2, 0);
				end
				col:SetHeight(rowHeight);
				col:SetWidth(self.cols[colj].width);
				col.text:SetPoint("TOP", col, "TOP", 0, 0);
				col.text:SetPoint("BOTTOM", col, "BOTTOM", 0, 0);
				local align = self.cols[colj].align or "LEFT";
				col.text:SetJustifyH(align); 
				col.text:SetWidth(self.cols[colj].width - 2*lrpadding);
			end
			j = self.displayCols + 1;
			col = row.cols[j];
			while col do
				col:Hide();
				j = j + 1;
				col = row.cols[j];
			end
		end
		
		for i = num + 1, #self.rows do
			self.rows[i]:Hide();
		end
		
		self:SetHeight();
	end
	
	--- API for a ScrollingTable table
	-- @name SetDisplayCols
	-- @description Set the column info for the scrolling table
	-- @usage st:SetDisplayCols(cols)	
	-- @see http://www.wowace.com/addons/lib-st/pages/create-st/#w-cols
	local function SetDisplayCols (self, cols)
		local table = self; -- reference saved for closure
		self.cols = cols;
		self.colList = {}
		for col=1,#self.cols do
			if self.cols[col].header then
				self.colList[#self.colList+1] = col
			end
		end
		for i = #self.colList+1, self.displayCols do 
			self.colList[#self.colList+1] = self.colOffset+i
		end
		
		local row = self.head
		if not row then 
			row = CreateFrame("Frame", self.frame:GetName().."Head", self.frame);
			row:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 4, 0);
			row:SetPoint("BOTTOMRIGHT", self.frame, "TOPRIGHT", -4, 0);
			row:SetHeight(self.rowHeight);
			row.cols = {};
			self.head = row;
		end
		for index, i in pairs(self.colList) do
			local colFrameName =  row:GetName().."Col"..index;
			local col = getglobal(colFrameName);
			if not col then 
				col = CreateFrame("Button", colFrameName, row);					
				col:RegisterForClicks("AnyUp");	 -- LS: right clicking on header
				
				if self.events then 	
					if col.setEvents then
						for event, v in pairs(col.setEvents) do
							if v == 1 then
								col:SetScript(event, nil)
								col.setEvents[event] = 0
							end
						end
					end
					for event, handler in pairs(self.events) do 
						col:SetScript(event, function(cellFrame, ...)
							table:FireUserEvent(col, event, handler, row, cellFrame, table.data, table.cols, nil, nil, index, table, ...);
						end);
						if not col.setEvents then
							col.setEvents = {}
						end
						col.setEvents[event] = 1
					end
				end
			end
			row.cols[index] = col;

			local fs = col:GetFontString() or col:CreateFontString(col:GetName().."fs", "OVERLAY", "GameFontHighlightSmall");
			fs:SetAllPoints(col);
			fs:SetPoint("LEFT", col, "LEFT", lrpadding, 0);
			fs:SetPoint("RIGHT", col, "RIGHT", -lrpadding, 0);
			local align = cols[i].align or "LEFT";
			fs:SetJustifyH(align); 
			
			col:SetFontString(fs);
			fs:SetText(cols[i].name);
			fs:SetTextColor(1.0, 1.0, 1.0, 1.0);
			col:SetPushedTextOffset(0,0);
			
			if index > 1 then 
				col:SetPoint("LEFT", row.cols[index-1], "RIGHT", 0, 0);
			else
				col:SetPoint("LEFT", row, "LEFT", 2, 0);
			end
			col:SetHeight(self.rowHeight);
			col:SetWidth(cols[i].width);
			
			local color = cols[index].bgcolor;
			if (color) then 
				local colibg = "col"..index.."bg";
				local bg = self.frame[colibg]; 
				if not bg then 
					bg = self.frame:CreateTexture(nil, "OVERLAY");
					self.frame[colibg] = bg;
				end 
				bg:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 4);
				bg:SetPoint("TOPLEFT", col, "BOTTOMLEFT", 0, -4);
				bg:SetPoint("TOPRIGHT", col, "BOTTOMRIGHT", 0, -4);
				bg:SetTexture(color.r, color.g, color.b, color.a);
			end
		end
		
		self:SetWidth();
	end
	
	--- API for a ScrollingTable table
	-- @name Show
	-- @description Used to show the scrolling table when hidden.
	-- @usage st:Show()
	local function Show (self)
		self.frame:Show();
		self.scrollframe:Show();
		self.showing = true;
	end
	
	--- API for a ScrollingTable table
	-- @name Hide
	-- @description Used to hide the scrolling table when shown.
	-- @usage st:Hide()
	local function Hide (self)
		self.frame:Hide();
		self.showing = false;
	end
		
	--- API for a ScrollingTable table
	-- @name SortData
	-- @description Resorts the table using the rules specified in the table column info.
	-- @usage st:SortData()	
	-- @see http://www.wowace.com/addons/lib-st/pages/create-st/#w-defaultsort
	local function SortData (self)
		-- sanity check
		if not(self.sorttable) or (#self.sorttable ~= #self.data)then 
			self.sorttable = {};
		end
		if #self.sorttable ~= #self.data then
			for i = 1, #self.data do 
				self.sorttable[i] = i;
			end
		end 
		
		-- go on sorting
		local i, sortby = 1, nil;
		while i <= #self.cols and not sortby do
			if self.cols[i].sort then 
				sortby = i;
			end
			i = i + 1;
		end
		if sortby then 
			table.sort(self.sorttable, function(rowa, rowb)
				local column = self.cols[sortby];
				if column.comparesort then 
					return column.comparesort(self, rowa, rowb, sortby);
				else
					return self:CompareSort(rowa, rowb, sortby);
				end
			end);
		end
		self.filtered = self:DoFilter();
		self:Refresh();
	end
	
	local StringToNumber = function(str)
		if str == "" then 
			return 0;
		else
			return tonumber(str)
		end
	end
	
	--- API for a ScrollingTable table
	-- @name CompareSort
	-- @description CompareSort function used to determine how to sort column values.  Can be overridden in column data or table data.
	-- @usage used internally.
	-- @see Core.lua
	local function CompareSort (self, rowa, rowb, sortbycol)
		local cella, cellb = self:GetCell(rowa, sortbycol), self:GetCell(rowb, sortbycol);
		local a1, b1 = cella, cellb;
		if type(a1) == 'table' then  
			a1 = a1.value; 
		end
		if type(b1) == 'table' then 
			b1 = b1.value;
		end 
		local column = self.cols[sortbycol];
		
		if type(a1) == "function" then 
			if (cella.args) then 
				a1 = a1(unpack(cella.args))
			else
				a1 = a1(self.data, self.cols, rowa, sortbycol, self);
			end
		end
		if type(b1) == "function" then 
			if (cellb.args) then 
				b1 = b1(unpack(cellb.args))
			else	
				b1 = b1(self.data, self.cols, rowb, sortbycol, self);
			end
		end
		
		if type(a1) ~= type(b1) then
			local typea, typeb = type(a1), type(b1);
			if typea == "number" and typeb == "string" then 
				if tonumber(b1) then -- is it a number in a string?
					b1 = StringToNumber(b1); -- "" = 0
				else
					a1 = tostring(a1);
				end
			elseif typea == "string" and typeb == "number" then 
				if tonumber(a1) then -- is it a number in a string?
					a1 = StringToNumber(a1); -- "" = 0
				else
					b1 = tostring(b1);
				end
			end
		end
		
		if a1 == b1 then 
			if column.sortnext then
				local nextcol = self.cols[column.sortnext];
				if not(nextcol.sort) then 
					if nextcol.comparesort then 
						return nextcol.comparesort(self, rowa, rowb, column.sortnext);
					else
						return self:CompareSort(rowa, rowb, column.sortnext);
					end
				else
					return false;
				end
			else
				return false; 
			end 
		else
			local direction = column.sort or column.defaultsort or "asc";
			if direction:lower() == "asc" then 		
				return a1 > b1;
			else
				return a1 < b1;
			end
		end
	end
	
	local Filter = function(self, rowdata)
		return true;
	end
	
	--- API for a ScrollingTable table
	-- @name SetFilter
	-- @description Set a display filter for the table.
	-- @usage st:SetFilter( function (self, ...) return true end )
	-- @see http://www.wowace.com/addons/lib-st/pages/filtering-the-scrolling-table/
	local function SetFilter (self, Filter)
		self.Filter = Filter;
		self:SortData();
	end
	
	local DoFilter = function(self)
		local result = {};
		for row = 1, #self.data do 
			local realrow = self.sorttable[row];
			local rowData = self:GetRow(realrow);
			if self:Filter(rowData) then
				table.insert(result, realrow);
			end
		end
		return result;
	end
	
	function GetDefaultHighlightBlank(self)
		return self.defaulthighlightblank;
	end
	
	function SetDefaultHighlightBlank(self, red, green, blue, alpha)
		if not self.defaulthighlightblank then 
			self.defaulthighlightblank = defaulthighlightblank;
		end
		
		if red then self.defaulthighlightblank["r"] = red; end
		if green then self.defaulthighlightblank["g"] = green; end
		if blue then self.defaulthighlightblank["b"] = blue; end
		if alpha then self.defaulthighlightblank["a"] = alpha; end
	end
	
	function GetDefaultHighlight(self)
		return self.defaulthighlight;
	end
	
	function SetDefaultHighlight(self, red, green, blue, alpha)
		if not self.defaulthighlight then 
			self.defaulthighlight = defaulthighlight;
		end
		
		if red then self.defaulthighlight["r"] = red; end
		if green then self.defaulthighlight["g"] = green; end
		if blue then self.defaulthighlight["b"] = blue; end
		if alpha then self.defaulthighlight["a"] = alpha; end
	end
	
	--- API for a ScrollingTable table
	-- @name EnableSelection
	-- @description Turn on or off selection on a table according to flag.  Will not refresh the table display.
	-- @usage st:EnableSelection(true)
	local function EnableSelection(self, flag)
		self.fSelect = flag;
	end
	
	--- API for a ScrollingTable table
	-- @name ClearSelection
	-- @description Clear the currently selected row.  You should not need to refresh the table.
	-- @usage st:ClearSelection()
	local function ClearSelection(self)
		self:SetSelection(nil);
	end

	--- API for a ScrollingTable table
	-- @name SetSelection
	-- @description Sets the currently selected row to 'realrow'.  Realrow is the unaltered index of the data row in your table. You should not need to refresh the table.
	-- @usage st:SetSelection(12)	
	local function SetSelection(self, realrow)
		self.selected = realrow;
		self:Refresh();
	end
	
	--- API for a ScrollingTable table
	-- @name GetSelection
	-- @description Gets the currently selected to row.  Return will be the unaltered index of the data row that is selected.
	-- @usage st:GetSelection()	
	local function GetSelection(self)
		return self.selected;
	end
	
	--- API for a ScrollingTable table
	-- @name DoCellUpdate
	-- @description Cell update function used to paint each cell.  Can be overridden in column data or table data.
	-- @usage used internally.
	-- @see http://www.wowace.com/addons/lib-st/pages/docell-update/
	local function DoCellUpdate (rowFrame, cellFrame, data, cols, row, realrow, column, fShow, table, ...)
		if fShow then
			local rowdata = table:GetRow(realrow);
			local celldata = table:GetCell(rowdata, column);
			
			local cellvalue = celldata;
			if type(celldata) == "table" then
				cellvalue = celldata.value;
			end
			if type(cellvalue) == "function" then 
				if celldata.args then 
					cellFrame.text:SetText(cellvalue(unpack(celldata.args)));
				else
					cellFrame.text:SetText(cellvalue(data, cols, realrow, column, table));
				end
			else
				cellFrame.text:SetText(cellvalue);
			end
			
			local color = nil;
			if type(celldata) == "table" then
				color = celldata.color;
			end
						
			local colorargs = nil;
			if not color then 
			 	color = cols[column].color;
			 	if not color then 
			 		color = rowdata.color;
			 		if not color then 
			 			color = defaultcolor;
			 		else
			 			colorargs = rowdata.colorargs;
			 		end
			 	else
			 		colorargs = cols[column].colorargs;
			 	end
			else
				colorargs = celldata.colorargs;
			end	
			if type(color) == "function" then 
				if colorargs then 
					color = color(unpack(colorargs));
				else 
					color = color(data, cols, realrow, column, table);
				end
			end
			cellFrame.text:SetTextColor(color.r, color.g, color.b, color.a);
			
			local highlight = nil;
			if type(celldata) == "table" then
				highlight = celldata.highlight;
			end
			
			if table.fSelect then 
				if table.selected == realrow or table.selected == rowdata or rowdata.selected == true then 
					if type(celldata) == "table" then
						highlight = celldata.highlight;
					end
					table:SetHighLightColor(rowFrame, highlight or cols[column].highlight or rowdata.highlight or table:GetDefaultHighlight());
				else
					table:SetHighLightColor(rowFrame, table:GetDefaultHighlightBlank());
				end
			end
		else	
			cellFrame.text:SetText("");
		end
	end

	--- API for a ScrollingTable table
	-- @name SetData
	-- @description Sets the data for the scrolling table
	-- @usage st:SetData(datatable)
	-- @see http://www.wowace.com/addons/lib-st/pages/set-data/
	local function SetData (self, data, isMinimalDataformat)
		self.isMinimalDataformat = isMinimalDataformat;
		self.data = data;
		self:SortData();
	end
		
	--- API for a ScrollingTable table
	-- @name GetRow
	-- @description Returns the data row of the table from the given data row index 
	-- @usage used internally.
	local function GetRow(self, realrow)
		return self.data[realrow];
	end
	
	--- API for a ScrollingTable table
	-- @name GetCell
	-- @description Returns the cell data of the given row from the given row and column index 
	-- @usage used internally.
	local function GetCell(self, row, col)
		local rowdata = row;
		if type(row) == "number" then 
			rowdata = self:GetRow(row);
		end
		
		if self.isMinimalDataformat then 
			return rowdata[col];
		else
			return rowdata.cols[col];
		end
	end
	
	
	function ScrollingTable:CreateST(cols, numRows, rowHeight, highlight, parent, displayCols)
		local st = {};
		self.framecount = self.framecount or 1; 
		local f = CreateFrame("Frame", "ScrollTable" .. self.framecount, parent or UIParent);
		self.framecount = self.framecount + 1;
		st.showing = true;
		st.frame = f;
		
		st.Show = Show;
		st.Hide = Hide;
		st.SetDisplayRows = SetDisplayRows;
		st.SetRowHeight = SetRowHeight;
		st.SetHeight = SetHeight;
		st.SetWidth = SetWidth;
		st.SetDisplayCols = SetDisplayCols;
		st.SetData = SetData;
		st.SortData = SortData;
		st.CompareSort = CompareSort;
		st.RegisterEvents = RegisterEvents;
		st.FireUserEvent = FireUserEvent;
		st.SetDefaultHighlightBlank = SetDefaultHighlightBlank;
		st.SetDefaultHighlight = SetDefaultHighlight;
		st.GetDefaultHighlightBlank = GetDefaultHighlightBlank;
		st.GetDefaultHighlight = GetDefaultHighlight;
		st.EnableSelection = EnableSelection;
		st.SetHighLightColor = SetHighLightColor;
		st.ClearSelection = ClearSelection;
		st.SetSelection = SetSelection;
		st.GetSelection = GetSelection;
		st.GetCell = GetCell;
		st.GetRow = GetRow;
		st.DoCellUpdate = DoCellUpdate;
		
		st.SetFilter = SetFilter;
		st.DoFilter = DoFilter;
		
		highlight = highlight or {};
		st:SetDefaultHighlight(highlight["r"], highlight["g"], highlight["b"], highlight["a"]); -- highlight color
		st:SetDefaultHighlightBlank(); -- non highlight color
				
		st.displayRows = numRows or 12;
		st.displayCols = displayCols or #cols;
		st.colOffset = 0
		st.rowHeight = rowHeight or 15;
		st.cols = cols;
		st.DefaultEvents = {
			["OnEnter"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
				if row and realrow then 
					local rowdata = table:GetRow(realrow);
					local celldata = table:GetCell(rowdata, column);
					local highlight = nil;
					if type(celldata) == "table" then
						highlight = celldata.highlight;
					end
					table:SetHighLightColor(rowFrame, highlight or cols[column].highlight or rowdata.highlight or table:GetDefaultHighlight());
				end
				return true;
			end, 
			["OnLeave"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, ...)
				if row and realrow then 
					local rowdata = table:GetRow(realrow);
					local celldata = table:GetCell(rowdata, column);
					if ( table.fSelect and rowdata.selected ) then
						if type(celldata) == "table" then
							highlight = celldata.highlight;
						end
						table:SetHighLightColor(rowFrame, highlight or cols[column].highlight or rowdata.highlight or table:GetDefaultHighlight());
					elseif realrow ~= table.selected or not table.fSelect then 
						table:SetHighLightColor(rowFrame, table:GetDefaultHighlightBlank());
					end
				end
				return true;
			end,
			["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)		-- LS: added "button" argument
				if button == "LeftButton" then	-- LS: only handle on LeftButton click (right passes thru)
					if not (row or realrow) then
						for i, col in ipairs(st.cols) do 
							if i ~= column then -- clear out all other sort marks
								cols[i].sort = nil;
							end
						end
						local sortorder = "asc";
						if not cols[column].sort and cols[column].defaultsort then
							sortorder = cols[column].defaultsort; -- sort by columns default sort first;
						elseif cols[column].sort and cols[column].sort:lower() == "asc" then 
							sortorder = "dsc";
						end
						cols[column].sort = sortorder;
						table:SortData();
				
					else
						if table:GetSelection() == realrow then 
							table:ClearSelection();
						else
							table:SetSelection(realrow);
						end
					end
					return true;
				end
			end,
		};
		st.data = {};
	
		f:SetBackdrop(ScrollPaneBackdrop);
		f:SetBackdropColor(0.1,0.1,0.1);
		f:SetPoint("CENTER",UIParent,"CENTER",0,0);
		
		-- build scroll frame		
		local scrollframe = CreateFrame("ScrollFrame", f:GetName().."ScrollFrame", f, "FauxScrollFrameTemplate");
		st.scrollframe = scrollframe;
		scrollframe:Show();
		scrollframe:SetScript("OnHide", function(self, ...)
			self:Show();
		end);
		
		scrollframe:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -4);
		scrollframe:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -26, 3);
		
		local scrolltrough = CreateFrame("Frame", f:GetName().."ScrollTrough", scrollframe);
		scrolltrough:SetWidth(17);
		scrolltrough:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -3);
		scrolltrough:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4);
		scrolltrough.background = scrolltrough:CreateTexture(nil, "BACKGROUND");
		scrolltrough.background:SetAllPoints(scrolltrough);
		scrolltrough.background:SetTexture(0.05, 0.05, 0.05, 1.0);
		local scrolltroughborder = CreateFrame("Frame", f:GetName().."ScrollTroughBorder", scrollframe);
		scrolltroughborder:SetWidth(1);
		scrolltroughborder:SetPoint("TOPRIGHT", scrolltrough, "TOPLEFT");
		scrolltroughborder:SetPoint("BOTTOMRIGHT", scrolltrough, "BOTTOMLEFT");
		scrolltroughborder.background = scrolltrough:CreateTexture(nil, "BACKGROUND");
		scrolltroughborder.background:SetAllPoints(scrolltroughborder);
		scrolltroughborder.background:SetTexture(0.5, 0.5, 0.5, 1.0);
		
		-- Build Horizontal ScrollFrame
		local scrollhframe = CreateFrame("ScrollFrame", f:GetName().."ScrollHFrame", f, "FauxScrollFrameTemplate")
		scrollhframe:Show()

		local scrollhbar = getglobal(f:GetName().."ScrollHFrame".."ScrollBar")
		scrollhframe:SetScript("OnHide", function(self, ...)
			 self:Show();
		end);

		-- local scrolltrough = CreateFrame("Frame", f:GetName().."ScrollTrough", scrollhframe);
		-- scrolltrough:SetHeight(17);
		-- scrolltrough:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3, 4);
		-- scrolltrough:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 4, -4);
		-- scrolltrough.background = scrolltrough:CreateTexture(nil, "BACKGROUND");
		-- scrolltrough.background:SetAllPoints(scrolltrough);
		-- scrolltrough.background:SetTexture(0.05, 0.05, 0.05, 1.0);
		-- local scrolltroughborder = CreateFrame("Frame", f:GetName().."ScrollTroughBorder", scrollhframe);
		-- scrolltroughborder:SetHeight(1);
		-- scrolltroughborder:SetPoint("TOPRIGHT", scrolltrough, "TOPLEFT");
		-- scrolltroughborder:SetPoint("BOTTOMRIGHT", scrolltrough, "BOTTOMLEFT");
		-- scrolltroughborder.background = scrolltrough:CreateTexture(nil, "BACKGROUND");
		-- scrolltroughborder.background:SetAllPoints(scrolltroughborder);
		-- scrolltroughborder.background:SetTexture(0.5, 0.5, 0.5, 1.0);
		scrollhframe:Show()

		scrollhframe:ClearAllPoints()
		scrollhframe:SetPoint("TOPLEFT", f, "BOTTOMRIGHT", -45, 22)
		scrollhframe:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 24, 5)
		scrollhframe:SetHeight(8)
		scrollhbar:SetOrientation("HORIZONTAL")
		scrollhbar:SetWidth(0)
		scrollhbar:SetHeight(24)
		scrollhbar:ClearAllPoints()
		scrollhbar:SetPoint("LEFT", scrollhframe, "RIGHT", 0, 0)
		scrollhbar:SetPoint("RIGHT", scrollhframe, "LEFT", 0, 0)
		local texCoords = { 0.75,0.25, 0.25,0.25, 0.75,0.75, 0.25,0.75 }
		local up = getglobal(scrollhbar:GetName().."ScrollUpButton")
		up:ClearAllPoints()
		up:SetPoint("RIGHT", scrollhbar, "LEFT", 0, 0)
		up:SetScript("OnClick", function(self, ...)
				local parent = self:GetParent();
				parent:SetValue(parent:GetValue() - 1);
				PlaySound("UChatScrollButton");
			end
		)
		local down = getglobal(scrollhbar:GetName().."ScrollDownButton")
		down:ClearAllPoints()
		down:SetPoint("LEFT", scrollhbar, "RIGHT", 0, 0)
		down:SetScript("OnClick", function(self, ...)
				local parent = self:GetParent();
				parent:SetValue(parent:GetValue() + 1);
				PlaySound("UChatScrollButton");
			end
		)
		
		local function HorizontalScrollFrame_Update(frame, numItems, numToDisplay, valueStep)
			-- If more than one screen full of skills then show the scrollbar
			local frameName = frame:GetName();
			local scrollBar = getglobal( frameName.."ScrollBar" );
			local showScrollBar;
			if ( numItems > numToDisplay ) then
				frame:Show();
				showScrollBar = 1;
			else
				scrollBar:SetValue(0);
				frame:Hide();
			end
			if ( frame:IsShown() ) then
				local scrollChildFrame = getglobal( frameName.."ScrollChildFrame" );
				local scrollUpButton = getglobal( frameName.."ScrollBarScrollUpButton" );
				local scrollDownButton = getglobal( frameName.."ScrollBarScrollDownButton" );
				local scrollFrameWidth = 0;
				local scrollChildWidth = 0;
				scrollChildFrame:Hide()

				if ( numItems > 0 ) then
					scrollFrameWidth = (numItems - numToDisplay) * valueStep;
					scrollChildWidth = numItems * valueStep;
					if ( scrollFrameWidth < 0 ) then
						scrollFrameWidth = 0;
					end
					scrollChildFrame:Show();
				else
					scrollChildFrame:Hide();
				end
				scrollBar:SetMinMaxValues(0, (numItems - numToDisplay)); 
				scrollBar:SetValueStep(valueStep);
				--scrollChildFrame:SetWidth(scrollChildWidth);
				
				-- Arrow button handling
				if ( scrollBar:GetValue() == 0 ) then
					scrollUpButton:Disable();
				else
					scrollUpButton:Enable();
				end
				if ((scrollBar:GetValue() - (numItems - numToDisplay)) == 0) then
					scrollDownButton:Disable();
				else
					scrollDownButton:Enable();
				end
			end
			return showScrollBar;
		end
	
		scrollhbar:SetScript("OnValueChanged", function(self, value)
				self:GetParent():SetHorizontalScroll(value);
			end
		)

		local tex
		tex = up:GetDisabledTexture()
		tex:SetTexCoord(unpack(texCoords))
		tex = down:GetDisabledTexture()
		tex:SetTexCoord(unpack(texCoords))
		tex = up:GetNormalTexture()
		tex:SetTexCoord(unpack(texCoords))
		tex = down:GetNormalTexture()
		tex:SetTexCoord(unpack(texCoords))
		tex = up:GetHighlightTexture()
		tex:SetTexCoord(unpack(texCoords))
		tex = down:GetHighlightTexture()
		tex:SetTexCoord(unpack(texCoords))
		tex = up:GetPushedTexture()
		tex:SetTexCoord(unpack(texCoords))
		tex = down:GetPushedTexture()
		tex:SetTexCoord(unpack(texCoords))

		st.Refresh = function(self)	
			FauxScrollFrame_Update(scrollframe, #st.filtered, st.displayRows, st.rowHeight);
			HorizontalScrollFrame_Update(scrollhframe, #st.cols, st.displayCols, 1);
			if #st.cols == st.displayCols then 
				scrollhbar:Hide()
			end
			local o = FauxScrollFrame_GetOffset(scrollframe);
			st.offset = o;
			local co = FauxScrollFrame_GetOffset(scrollhframe);
			if (co ~= st.colOffset)
			then
				st.colOffset = co;
				st:SetDisplayCols(st.cols);
				st:SetDisplayRows(st.displayRows, st.rowHeight);
			end
			
			for i = 1, st.displayRows do
				local row = i + o;	
				if st.rows then
					local rowFrame = st.rows[i];
					local realrow = st.filtered[row];
					local rowData = st:GetRow(realrow);
					local fShow = true;
					for col = 1, #st.cols do
						local cellFrame = rowFrame.cols[col];
						local fnDoCellUpdate = st.DoCellUpdate;
						if rowData then
							st.rows[i]:Show();
							local cellData = st:GetCell(rowData, col);
							if type(cellData) == "table" and cellData.DoCellUpdate then 
								fnDoCellUpdate = cellData.DoCellUpdate;
							elseif st.cols[col].DoCellUpdate then 
								fnDoCellUpdate = st.cols[col].DoCellUpdate;
							elseif rowData.DoCellUpdate then
								fnDoCellUpdate = rowData.DoCellUpdate;
							end
						else
							st.rows[i]:Hide();
							fShow = false;
						end
						fnDoCellUpdate(rowFrame, cellFrame, st.data, st.cols, row, st.filtered[row], col, fShow, st);
					end
					-- Update the highlight
					-- if ( st.selection and st.selected and st.selected == rowData ) then
					-- if ( st.selection and rowData and rowData.selected ) then
						-- if type(celldata) == "table" then
							-- highlight = celldata.highlight;
						-- end
						-- self:SetHighLightColor(rowFrame, highlight or cols[column].highlight or rowData.highlight or table:GetDefaultHighlight());
						----table:SetHighLightColor(rowFrame, rowData.highlight or table:GetDefaultHighlight());
					-- else
						-- self:SetHighLightColor(rowFrame, defaulthighlightblank);
					-- end
				end
			end
		end
		
		scrollhframe:SetScript("OnHorizontalScroll", function(self, offset)
			local scrollbar = getglobal(self:GetName().."ScrollBar");
			scrollbar:SetValue(offset);
			local min;
			local max;
			min, max = scrollbar:GetMinMaxValues();
			if ( offset == 0 ) then
				getglobal(scrollbar:GetName().."ScrollUpButton"):Disable();
			else
				getglobal(scrollbar:GetName().."ScrollUpButton"):Enable();
			end
			if ((scrollbar:GetValue() - max) == 0) then
				getglobal(scrollbar:GetName().."ScrollDownButton"):Disable();
			else
				getglobal(scrollbar:GetName().."ScrollDownButton"):Enable();
			end
			FauxScrollFrame_OnVerticalScroll(self, offset, 1, st.Refresh);
		end);
		
		scrollframe:SetScript("OnVerticalScroll", function(self, offset)
			FauxScrollFrame_OnVerticalScroll(self, offset, st.rowHeight, function() st:Refresh() end);					-- LS: putting st:Refresh() in a function call passes the st as the 1st arg which lets you reference the st if you decide to hook the refresh
		end);
	
		st:SetFilter(Filter);
		st:SetDisplayCols(st.cols);
		st:SetDisplayRows(st.displayRows, st.rowHeight);
		st:RegisterEvents(st.DefaultEvents);
		
		return st;
	end
end
