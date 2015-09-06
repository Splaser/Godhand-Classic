-- /run interruptsFrameCreation()
function InterruptsFrameCreation()
	if interruptsFrameLoaded ~= true then
		
		-- Vars Load once
		if GodHand_data.interruptsWidth == nil then 
			GodHand_data.interruptsWidth = 200;
			GodHand_data.interruptsanchor = "Center"
			GodHand_data.interruptsx = -200;
			GodHand_data.interruptsy = 100;
			GodHand_data.interruptsActualRow = 0;
			GodHand_data.interruptsAlpha = 95;
			GodHand_data.interruptsRows = 5;
			GodHand_data.interruptsHeight = 26;
		end
		-- Resets every time
		GodHand_data.interruptsActualRow = 0;

		if GodHand_data.interruptsRows == nil then  end
		-- CreateRow
		if interruptsHeight == nil then  end
		function CreateinterruptsRow(value,textString)
			if value > 0 then
				_G["interrupts"..value.."Frame"] = CreateFrame("Frame", "MyButton", interruptsFrame);
				_G["interrupts"..value.."Frame"]:SetWidth(GodHand_data.interruptsWidth);
				_G["interrupts"..value.."Frame"]:SetHeight(20);
				--_G["interrupts"..value.."Frame"]:SetNormalTexture([[Interface\DialogFrame\UI-DialogBox-Background-Dark]]); 
				_G["interrupts"..value.."Frame"]:SetPoint("TOPLEFT",0,-((value*20)));
				_G["interrupts"..value.."Frame"]:SetAlpha(GodHand_data.interruptsAlpha/100);
				_G["interrupts"..value.."Frame"]:SetScript("OnEnter", function(self)
					local MyValue = value;
					if spellCastingUnits ~= nil and spellCastingUnits[MyValue+GodHand_data.interruptsActualRow] ~= nil then
						GameTooltip:SetOwner(self, "BOTTOMLEFT", 250, 5);
						GameTooltip:SetText("|cffFF0000Role: |cffFFDD11"..spellCastingUnits[MyValue+GodHand_data.interruptsActualRow].class..
							"\n|cffFF0000Name: |cffFFDD11"..spellCastingUnits[MyValue+GodHand_data.interruptsActualRow].sourceName..
							"\n|cffFF0000GUID: |cffFFDD11"..spellCastingUnits[MyValue+GodHand_data.interruptsActualRow].targetGUID..
							"\n|cffFF0000Target: |cffFFDD11", nil, nil, nil, nil, false);
						GameTooltip:Show();
					end
				end)
				_G["interrupts"..value.."Frame"]:SetScript("OnLeave", function(self)
					if tooltipLock ~= true then
						GameTooltip:Hide();
					end
					tooltipLock = false;
				end)

				_G["interrupts"..value.."Frame"]:SetScript("OnMouseUp", function()
					RunMacroText("/target "..spellCastingUnits[value+GodHand_data.interruptsActualRow].sourceName)
				end)			

				_G["interrupts"..value.."Frame"]:SetScript("OnMouseWheel", function(self, delta)
					local Go = false;
					if delta < 0 and GodHand_data.interruptsActualRow < 100 and interruptsTable ~= nil and interruptsTable[GodHand_data.interruptsActualRow+GodHand_data.interruptsRows] ~= nil then
						Go = true;
					elseif delta > 0 and GodHand_data.interruptsActualRow > 0 then
						Go = true;
					end
					if Go == true then
						GodHand_data.interruptsActualRow = GodHand_data.interruptsActualRow - delta
						interruptsRefresh()
					end
				end)

				--_G["interrupts"..value.."Frame"]:Hide();
				_G["interrupts"..value.."Text"] = _G["interrupts"..value.."Frame"]:CreateFontString(_G["interrupts"..value.."Frame"], "OVERLAY");
				_G["interrupts"..value.."Text"]:SetWidth(GodHand_data.interruptsWidth);
				_G["interrupts"..value.."Text"]:SetHeight(20);
				_G["interrupts"..value.."Text"]:SetPoint("TOPLEFT",0,0);
				_G["interrupts"..value.."Text"]:SetAlpha(1)
				_G["interrupts"..value.."Text"]:SetJustifyH("LEFT")
				_G["interrupts"..value.."Text"]:SetFont("Fonts/FRIZQT__.ttf",16,"THICKOUTLINE");
				_G["interrupts"..value.."Text"]:SetText(textString, 1, 1, 1, 0.7);
			end
		end

		interruptsFrame = CreateFrame("Frame", nil, UIParent);
		interruptsFrame:SetWidth(GodHand_data.interruptsWidth);
		interruptsFrame:SetHeight((GodHand_data.interruptsRows*20)+20)
		interruptsFrame.texture = interruptsFrame:CreateTexture(interruptsFrame, "ARTWORK");
		interruptsFrame.texture:SetAllPoints();
		interruptsFrame.texture:SetWidth(GodHand_data.interruptsWidth);
		interruptsFrame.texture:SetHeight(30);
		interruptsFrame.texture:SetAlpha(GodHand_data.interruptsAlpha/100);
		interruptsFrame.texture:SetTexture([[Interface\DialogFrame\UI-DialogBox-Background-Dark]]);
		CreateBorder(interruptsFrame, 8, 0.6, 0.6, 0.6, 3, 3, 3, 3, 3, 3, 3, 3 );

		function SetInterruptsWidth(Width)
			GodHand_data.interruptsWidth = Width;
			interruptsFrame:SetWidth(Width);
		end

		interruptsFrame:SetPoint(GodHand_data.interruptsanchor,GodHand_data.interruptsx,GodHand_data.interruptsy);
		interruptsFrame:SetClampedToScreen(true);
		interruptsFrame:SetScript("OnUpdate", interruptsFrame_OnUpdate);
		interruptsFrame:EnableMouse(true);
		interruptsFrame:SetMovable(true);
		interruptsFrame:SetClampedToScreen(true);
		interruptsFrame:RegisterForDrag("LeftButton");
		interruptsFrame:SetScript("OnDragStart", interruptsFrame.StartMoving);
		interruptsFrame:SetScript("OnDragStop", interruptsFrame.StopMovingOrSizing);
		interruptsFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "BOTTOMLEFT", 250, 5);
			GameTooltip:SetText("|cffD60000滚轮调整框架宽度 \n|cffFFFFFF左键按住移动框架 \n|cffFFDD11AltAlt+滚轮调整透明度 ", nil, nil, nil, nil, true);
			GameTooltip:Show();
		end)
		interruptsFrame:SetScript("OnLeave", function(self)
			GameTooltip:Hide();
		end)
		interruptsFrame:SetScript("OnMouseWheel", function(self, delta)
			if IsAltKeyDown() then
				local Go = false;
				if delta < 0 and GodHand_data.interruptsAlpha >= 0 then
					Go = true;
				elseif delta > 0 and GodHand_data.interruptsAlpha <= 100 then
					Go = true;
				end
				if Go == true then
					GodHand_data.interruptsAlpha = GodHand_data.interruptsAlpha + (delta*5)
					interruptsFrame.texture:SetAlpha(GodHand_data.interruptsAlpha/100);
					for i = 1, 25 do 
						if _G["interrupts"..i.."Frame"]:GetAlpha() ~= GodHand_data.interruptsAlpha/100 then
							_G["interrupts"..i.."Frame"]:SetAlpha(GodHand_data.interruptsAlpha/100);
							interruptsFrameText:SetAlpha(GodHand_data.interruptsAlpha/100);
						end
					end
				end
			else	
				local Go = false;
				if delta > 0 and GodHand_data.interruptsWidth < 500 then
					Go = true;
				elseif delta < 0 and GodHand_data.interruptsWidth > 0 then
					Go = true;
				end
				if Go == true then
					GodHand_data.interruptsWidth = GodHand_data.interruptsWidth + (delta*5)
					interruptsFrame:SetWidth(GodHand_data.interruptsWidth);
					for i = 1, 25 do 
						if _G["interrupts"..i.."Frame"]:GetWidth() ~= GodHand_data.interruptsWidth then
							_G["interrupts"..i.."Frame"]:SetWidth(GodHand_data.interruptsWidth);
						end
						if _G["interrupts"..i.."Text"]:GetWidth() ~= GodHand_data.interruptsWidth then
							_G["interrupts"..i.."Text"]:SetWidth(GodHand_data.interruptsWidth);
						end
					end
					interruptsFrameText:SetWidth(GodHand_data.interruptsWidth);
				end
			end
		end)
		interruptsFrameRowsButton = CreateFrame("CheckButton", "MyButton", interruptsFrame, "UIPanelButtonTemplate");
		interruptsFrameRowsButton:SetAlpha(0.80);
		interruptsFrameRowsButton:SetWidth(30);
		interruptsFrameRowsButton:SetHeight(18);
		interruptsFrameRowsButton:SetPoint("TOPRIGHT", -1, -1);
		interruptsFrameRowsButton:SetNormalTexture([[Interface\BUTTONS\ButtonHilight-SquareQuickslot]]);
		interruptsFrameRowsButton:RegisterForClicks("AnyUp");
		interruptsFrameRowsButton:SetText(GodHand_data.interruptsRows);
		interruptsFrameRowsButton:SetScript("OnMouseWheel", function(self, delta)
			local Go = false;
			if delta < 0 and GodHand_data.interruptsRows > 1 then
				Go = true;
			elseif delta > 0 and GodHand_data.interruptsRows < 25 then
				Go = true;
			end
			if Go == true then
				GodHand_data.interruptsRows = GodHand_data.interruptsRows + delta
				interruptsFrameRowsButton:SetText(GodHand_data.interruptsRows);
				interruptsRefresh()
				interruptsFrame:SetHeight((GodHand_data.interruptsRows*20)+20);
			end
		end)
		interruptsFrameRowsButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "BOTTOMRIGHT", 0, 5);
			GameTooltip:SetText("|cffD60000滚轮调整显示数量.", nil, nil, nil, nil, true);
			GameTooltip:Show();
		end)
		interruptsFrameRowsButton:SetScript("OnLeave", function(self)
			GameTooltip:Hide();
		end)




		interruptsFrameTopButton = CreateFrame("CheckButton", "MyButton", interruptsFrame, "UIPanelButtonTemplate");
		interruptsFrameTopButton:SetAlpha(0.80);
		interruptsFrameTopButton:SetWidth(30);
		interruptsFrameTopButton:SetHeight(18);
		interruptsFrameTopButton:SetPoint("TOPRIGHT", -31, -1);
		interruptsFrameTopButton:SetNormalTexture([[Interface\BUTTONS\ButtonHilight-SquareQuickslot]]);
		interruptsFrameTopButton:RegisterForClicks("AnyUp");
		interruptsFrameTopButton:SetText("Top");
		interruptsFrameTopButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "BOTTOMRIGHT", 0, 5);
			GameTooltip:SetText("|cffD60000返回顶层.", nil, nil, nil, nil, true);
			GameTooltip:Show();
		end)
		interruptsFrameTopButton:SetScript("OnLeave", function(self)
			GameTooltip:Hide();
		end)
		interruptsFrameTopButton:SetScript("OnClick", function()
			GodHand_data.interruptsActualRow = 0;
			interruptsRefresh();
		end)

		interruptsFrameText = interruptsFrame:CreateFontString(interruptsFrame, "ARTWORK");
		interruptsFrameText:SetFont("Fonts/FRIZQT__.ttf",17,"THICKOUTLINE");
		interruptsFrameText:SetTextHeight(16);
		interruptsFrameText:SetPoint("TOPLEFT",5, -4);
		interruptsFrameText:SetJustifyH("LEFT")
		interruptsFrameText:SetTextColor(225/255, 225/255, 225/255,1);
		interruptsFrameText:SetText("|cffFF001EGodHand |cffFFFFFFInterrupts")

		if GodHand_data.interruptsShown == false then interruptsFrame:Hide(); else interruptsFrame:Show(); end

		SetInterruptsWidth(GodHand_data.interruptsWidth);

		--CreateinterruptsRow(0,"|cff12C8FFTime|cffFF001E/|cffFFFFFFSpell Name")

		for i = 1, 25 do
			CreateinterruptsRow(i,"")
		end

		function interruptsRefresh()
			if spellCastingUnits == nil then 			
				for i = 1, GodHand_data.interruptsRows do
					local interruptsName, interruptsTip = "", ""
					if _G["interrupts"..i.."Frame"]:IsShown() ~= 1 then
						_G["interrupts"..i.."Text"]:Show();
						_G["interrupts"..i.."Frame"]:Show();
					end
					_G["interrupts"..i.."Text"]:SetText(interruptsName, 1, 1, 1, 0.7);
				end 
				for i = GodHand_data.interruptsRows+1, 25 do
					if _G["interrupts"..i.."Frame"]:IsShown() == 1 then
						_G["interrupts"..i.."Text"]:Hide();
						_G["interrupts"..i.."Frame"]:Hide();
					end
				end
			else
				for i = 1, GodHand_data.interruptsRows do
					local interruptsName;
					if spellCastingUnits[GodHand_data.interruptsActualRow+i] ~= nil then
						local endDisplay = "|cffFF0000"..math.floor(spellCastingUnits[GodHand_data.interruptsActualRow+i].endTime) or 0;
						local sourceGUIDDisplay = "|cffFFBB00 "..spellCastingUnits[GodHand_data.interruptsActualRow+i].guid or " |cffFFBB00NONE";
						local sourceNameDisplay;
						if spellCastingUnits[GodHand_data.interruptsActualRow+i].class ~= nil and spellCastingUnits[GodHand_data.interruptsActualRow+i].sourceName ~= nil then
							sourceNameDisplay = classColors[spellCastingUnits[GodHand_data.interruptsActualRow+i].class].hex.." "..spellCastingUnits[GodHand_data.interruptsActualRow+i].sourceName;
						else 
							sourceNameDisplay = " No Name";
						end

						local targetDisplay;
						local hisTarget = tostring(spellCastingUnits[GodHand_data.interruptsActualRow+i].target) or " |cff00F2FF未找到目标";
						if UnitName(hisTarget) ~= nil then targetDisplay = "|cff00F2FF "..UnitName(hisTarget) else targetDisplay = " |cff00F2FF未找到目标" end
						interruptsName = endDisplay..sourceGUIDDisplay..sourceNameDisplay
					else
						interruptsName = "";
					end

					if _G["interrupts"..i.."Frame"]:IsShown() ~= 1 then
						_G["interrupts"..i.."Text"]:Show();
						_G["interrupts"..i.."Frame"]:Show();
					end

					_G["interrupts"..i.."Text"]:SetText(interruptsName, 1, 1, 1, 0.7);

				end
				for i = GodHand_data.interruptsRows+1, 25 do
					if _G["interrupts"..i.."Frame"]:IsShown() == 1 then
						_G["interrupts"..i.."Text"]:Hide();
						_G["interrupts"..i.."Frame"]:Hide();
					end
				end
			end
			
			interruptsFrame:SetHeight((GodHand_data.interruptsRows*20)+20);
		end
		interruptsFrame.texture:SetAlpha(GodHand_data.interruptsAlpha/100);
		for i = 1, 25 do 
			if _G["interrupts"..i.."Frame"]:GetAlpha() ~= GodHand_data.interruptsAlpha/100 then
				_G["interrupts"..i.."Frame"]:SetAlpha(GodHand_data.interruptsAlpha/100);
				interruptsFrameText:SetAlpha(GodHand_data.interruptsAlpha/100);
			end
		end
		interruptsFrameText:SetWidth(GodHand_data.interruptsWidth);
		interruptsFrame:SetWidth(GodHand_data.interruptsWidth);
		for i = 1, 25 do 
			if _G["interrupts"..i.."Frame"]:GetWidth() ~= GodHand_data.interruptsWidth then
				_G["interrupts"..i.."Frame"]:SetWidth(GodHand_data.interruptsWidth);
			end
			if _G["interrupts"..i.."Text"]:GetWidth() ~= GodHand_data.interruptsWidth then
				_G["interrupts"..i.."Text"]:SetWidth(GodHand_data.interruptsWidth);
			end
		end
    	interruptsFrameLoaded = true;
    	interruptsRefresh();
	end
end
