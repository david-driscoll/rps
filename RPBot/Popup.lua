--[[
	*******************
	* Raid Points System *
	*******************
	* File-Revision: @file-revision@
	* Project-Version: @project-version@
	* Last edited by: @file-author@ on @file-date-iso@ 
	* Last commit: @project-author@ on @project-date-iso@ 
	* Filename: RPBot/Popup.lua
	* Component: Roll Interface
	* Details:
		Notificiation Popup
]]

local popupFrame
local popupFuncNo
local popupFuncYes

local function CreatePopup()
	popupFrame = CreateFrame("Frame", "RPBPointsViewer", UIParent)
	popupFrame:SetClampedToScreen(true)
	popupFrame:SetFrameStrata("DIALOG")
	f:SetFrameLevel(120)
	popupFrame:SetHeight(60)
	popupFrame:SetWidth(200)
	popupFrame:SetPoint("CENTER",0,0)
	popupFrame:Hide()

	local font = popupFrame:CreateFontString("Class","OVERLAY","GameTooltipText")
	font:SetText("Class:")
	font:SetPoint("TOP", dropdown.frame, "TOP", 0, -15)
	popupFrame.label = font
	
	local button = CreateFrame("Button", popupFrame:GetName() .. "_Yes", popupFrame, "UIPanelButtonTemplate")
	button:SetWidth(90)
	button:SetHeight(21)
	button:SetPoint("TOPRIGHT", popupFrame, "TOP", 4, -35)
	button:SetText("Yes")
	button:SetScript("OnClick", 
		function(self)
			if popupFuncYes then
				popupFuncYes()
			end
			popupFrame:Hide()
		end
	)
	popupFrame.yesButton = button
	
	local button = CreateFrame("Button", popupFrame:GetName() .. "_No", popupFrame, "UIPanelButtonTemplate")
	button:SetWidth(90)
	button:SetHeight(21)
	button:SetPoint("TOPLEFT", popupFrame, "TOP", -4, -35)
	button:SetText("No")
	button:SetScript("OnClick", 
		function(self)
			if popupFuncNo then
				popupFuncNo()
			end
			popupFrame:Hide()
		end
	)
	popupFrame.noButton = button
end

function myPopup(self, frame, question, funcYes, funcNo)
	if not popupFrame then
		CreatePopup()
		self:Skin(popupFrame)
	end
	popupFrame.label:SetText(question)
	popupFuncYes = funcYes
	popupFuncNo = funcNo
	popupFrame:SetPoint("CENTER", frame, "CENTER", 0, 0)
	popupFrame:Show()
end
