-- /run EngineFrameCreation()
function EngineFrameCreation()
	if engineFrameLoaded ~= true then

		-- Vars
		if GodHand_data.engineWidth == nil then
			GodHand_data.engineWidth = 200;
			GodHand_data.engineanchor = "Center"
			GodHand_data.enginex = -200;
			GodHand_data.enginey = 100;
			GodHand_data.engineActualRow = 0;
			GodHand_data.engineAlpha = 95;
			GodHand_data.engineRows = 5;
		end

		GodHand_data.successCasts = 0;
		GodHand_data.failCasts = 0;
		GodHand_data.engineActualRow = 0;
		if GodHand_data.engineRows == nil then  end
		-- CreateRow
		if engineHeight == nil then engineHeight = 26; end
		function CreateEngineDebugRow(value,textString)
			if value > 0 then
				_G["engine"..value.."Frame"] = CreateFrame("Frame", "MyButton", engineFrame);
				_G["engine"..value.."Frame"]:SetWidth(GodHand_data.engineWidth);
				_G["engine"..value.."Frame"]:SetHeight(20);
				_G["engine"..value.."Frame"]:SetPoint("TOPLEFT",0,-((value*20)));
				_G["engine"..value.."Frame"]:SetAlpha(GodHand_data.engineAlpha/100);
				_G["engine"..value.."Frame"]:SetScript("OnEnter", function(self)
					local MyValue = value;
					if nNova ~= nil and nNova[MyValue+GodHand_data.engineActualRow] ~= nil then
						GameTooltip:SetOwner(self, "BOTTOMLEFT", 250, 5);
						GameTooltip:SetText("|cffFF0000Role: |cffFFDD11"..nNova[MyValue+GodHand_data.engineActualRow].role..
							"\n|cffFF0000Name: |cffFFDD11"..nNova[MyValue+GodHand_data.engineActualRow].name..
							"\n|cffFF0000Health: |cffFFDD11"..nNova[MyValue+GodHand_data.engineActualRow].hp..
							"\n|cffFF0000Absorb: |cffFFDD11"..nNova[MyValue+GodHand_data.engineActualRow].absorb..
							"\n|cffFF0000GUID: |cffFFDD11"..nNova[MyValue+GodHand_data.engineActualRow].guid, nil, nil, nil, nil, false);
						GameTooltip:Show();
					end
				end)
				_G["engine"..value.."Frame"]:SetScript("OnLeave", function(self)
					if tooltipLock ~= true then
						GameTooltip:Hide();
					end
					tooltipLock = false;
				end)

				_G["engine"..value.."Frame"]:SetScript("OnMouseWheel", function(self, delta)
					local Go = false;
					if delta < 0 and GodHand_data.engineActualRow < 100 and engineTable ~= nil and engineTable[GodHand_data.engineActualRow+GodHand_data.engineRows] ~= nil then
						Go = true;
					elseif delta > 0 and GodHand_data.engineActualRow > 0 then
						Go = true;
					end
					if Go == true then
						GodHand_data.engineActualRow = GodHand_data.engineActualRow - delta
						engineRefresh()
					end
				end)

				--_G["engine"..value.."Frame"]:Hide();
				_G["engine"..value.."Text"] = _G["engine"..value.."Frame"]:CreateFontString(_G["engine"..value.."Frame"], "OVERLAY");
				_G["engine"..value.."Text"]:SetWidth(GodHand_data.engineWidth);
				_G["engine"..value.."Text"]:SetHeight(20);
				_G["engine"..value.."Text"]:SetPoint("TOPLEFT",0,0);
				_G["engine"..value.."Text"]:SetAlpha(1)
				_G["engine"..value.."Text"]:SetJustifyH("LEFT")
				_G["engine"..value.."Text"]:SetFont("Fonts/FRIZQT__.ttf",16,"THICKOUTLINE");
				_G["engine"..value.."Text"]:SetText(textString, 1, 1, 1, 0.7);
			end
		end

		engineFrame = CreateFrame("Frame", nil, UIParent);
		engineFrame:SetWidth(GodHand_data.engineWidth);
		engineFrame:SetHeight((GodHand_data.engineRows*20)+20)
		engineFrame.texture = engineFrame:CreateTexture(engineFrame, "ARTWORK");
		engineFrame.texture:SetAllPoints();
		engineFrame.texture:SetWidth(GodHand_data.engineWidth);
		engineFrame.texture:SetHeight(30);
		engineFrame.texture:SetAlpha(GodHand_data.engineAlpha/100);
		engineFrame.texture:SetTexture([[Interface\DialogFrame\UI-DialogBox-Background-Dark]]);
		CreateBorder(engineFrame, 8, 0.6, 0.6, 0.6, 3, 3, 3, 3, 3, 3, 3, 3 );

		function SetDebugWidth(Width)
			GodHand_data.engineWidth = Width;
			engineFrame:SetWidth(Width);
		end

		engineFrame:SetPoint(GodHand_data.engineanchor,GodHand_data.enginex,GodHand_data.enginey);
		engineFrame:SetClampedToScreen(true);
		engineFrame:SetScript("OnUpdate", engineFrame_OnUpdate);
		engineFrame:EnableMouse(true);
		engineFrame:SetMovable(true);
		engineFrame:SetClampedToScreen(true);
		engineFrame:RegisterForDrag("LeftButton");
		engineFrame:SetScript("OnDragStart", engineFrame.StartMoving);
		engineFrame:SetScript("OnDragStop", engineFrame.StopMovingOrSizing);
		engineFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "BOTTOMLEFT", 250, 5);
			GameTooltip:SetText("|cffD60000滚轮调整框架宽度 \n|cffFFFFFF左键按住移动框架 \n|cffFFDD11Alt+滚轮调整透明度 ", nil, nil, nil, nil, true);
			GameTooltip:Show();
		end)
		engineFrame:SetScript("OnLeave", function(self)
			GameTooltip:Hide();
		end)
		engineFrame:SetScript("OnMouseWheel", function(self, delta)
			if IsAltKeyDown() then
				local Go = false;
				if delta < 0 and GodHand_data.engineAlpha >= 0 then
					Go = true;
				elseif delta > 0 and GodHand_data.engineAlpha <= 100 then
					Go = true;
				end
				if Go == true then
					GodHand_data.engineAlpha = GodHand_data.engineAlpha + (delta*5)
					engineFrame.texture:SetAlpha(GodHand_data.engineAlpha/100);
					for i = 1, 25 do
						if _G["engine"..i.."Frame"]:GetAlpha() ~= GodHand_data.engineAlpha/100 then
							_G["engine"..i.."Frame"]:SetAlpha(GodHand_data.engineAlpha/100);
							engineFrameText:SetAlpha(GodHand_data.engineAlpha/100);
						end
					end
				end
			else
				local Go = false;
				if delta < 0 and GodHand_data.engineWidth < 500 then
					Go = true;
				elseif delta > 0 and GodHand_data.engineWidth > 0 then
					Go = true;
				end
				if Go == true then
					GodHand_data.engineWidth = GodHand_data.engineWidth + (delta*5)
					engineFrame:SetWidth(GodHand_data.engineWidth);
					for i = 1, 25 do
						if _G["engine"..i.."Frame"]:GetWidth() ~= GodHand_data.engineWidth then
							_G["engine"..i.."Frame"]:SetWidth(GodHand_data.engineWidth);
						end
						if _G["engine"..i.."Text"]:GetWidth() ~= GodHand_data.engineWidth then
							_G["engine"..i.."Text"]:SetWidth(GodHand_data.engineWidth);
						end
					end
					engineFrameText:SetWidth(GodHand_data.engineWidth);
				end
			end
		end)
		engineFrameRowsButton = CreateFrame("CheckButton", "MyButton", engineFrame, "UIPanelButtonTemplate");
		engineFrameRowsButton:SetAlpha(0.80);
		engineFrameRowsButton:SetWidth(30);
		engineFrameRowsButton:SetHeight(18);
		engineFrameRowsButton:SetPoint("TOPRIGHT", -1, -1);
		engineFrameRowsButton:SetNormalTexture([[Interface\BUTTONS\ButtonHilight-SquareQuickslot]]);
		engineFrameRowsButton:RegisterForClicks("AnyUp");
		engineFrameRowsButton:SetText(GodHand_data.engineRows);
		engineFrameRowsButton:SetScript("OnMouseWheel", function(self, delta)
			local Go = false;
			if delta < 0 and GodHand_data.engineRows > 1 then
				Go = true;
			elseif delta > 0 and GodHand_data.engineRows < 25 then
				Go = true;
			end
			if Go == true then
				GodHand_data.engineRows = GodHand_data.engineRows + delta
				engineFrameRowsButton:SetText(GodHand_data.engineRows);
				engineRefresh()
				engineFrame:SetHeight((GodHand_data.engineRows*20)+20);
			end
		end)
		engineFrameRowsButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "BOTTOMRIGHT", 0, 5);
			GameTooltip:SetText("|cffD60000滚轮调整显示数量.", nil, nil, nil, nil, true);
			GameTooltip:Show();
		end)
		engineFrameRowsButton:SetScript("OnLeave", function(self)
			GameTooltip:Hide();
		end)




		engineFrameTopButton = CreateFrame("CheckButton", "MyButton", engineFrame, "UIPanelButtonTemplate");
		engineFrameTopButton:SetAlpha(0.80);
		engineFrameTopButton:SetWidth(30);
		engineFrameTopButton:SetHeight(18);
		engineFrameTopButton:SetPoint("TOPRIGHT", -31, -1);
		engineFrameTopButton:SetNormalTexture([[Interface\BUTTONS\ButtonHilight-SquareQuickslot]]);
		engineFrameTopButton:RegisterForClicks("AnyUp");
		engineFrameTopButton:SetText("Top");
		engineFrameTopButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "BOTTOMRIGHT", 0, 5);
			GameTooltip:SetText("|cffD60000返回顶层.", nil, nil, nil, nil, true);
			GameTooltip:Show();
		end)
		engineFrameTopButton:SetScript("OnLeave", function(self)
			GameTooltip:Hide();
		end)
		engineFrameTopButton:SetScript("OnClick", function()
			GodHand_data.engineActualRow = 0;
			engineRefresh();
		end)

		engineFrameText = engineFrame:CreateFontString(engineFrame, "ARTWORK");
		engineFrameText:SetFont("Fonts/FRIZQT__.ttf",17,"THICKOUTLINE");
		engineFrameText:SetTextHeight(16);
		engineFrameText:SetPoint("TOPLEFT",5, -4);
		engineFrameText:SetJustifyH("LEFT")
		engineFrameText:SetTextColor(225/255, 225/255, 225/255,1);
		engineFrameText:SetText("|cffFF001En|cff00F2FFNova |cffFFFFFF治疗引擎")

		if GodHand_data.engineShown == false then engineFrame:Hide(); else engineFrame:Show(); end

		SetDebugWidth(GodHand_data.engineWidth);

		for i = 1, 25 do
			CreateEngineDebugRow(i,"")
		end

		function engineRefresh()
			if nNova == nil then
				for i = 1, GodHand_data.engineRows do
					local engineName, engineTip = "", ""
					if _G["engine"..i.."Frame"]:IsShown() ~= 1 then
						_G["engine"..i.."Text"]:Show();
						_G["engine"..i.."Frame"]:Show();
					end
					_G["engine"..i.."Text"]:SetText(engineName, 1, 1, 1, 0.7);
				end
				for i = GodHand_data.engineRows+1, 25 do
					if _G["engine"..i.."Frame"]:IsShown() == 1 then
						_G["engine"..i.."Text"]:Hide();
						_G["engine"..i.."Frame"]:Hide();
					end
				end
			else
				for i = 1, GodHand_data.engineRows do
					local engineName;
					if nNova[GodHand_data.engineActualRow+i] ~= nil then
						local healthDisplay = "|cffFF0000"..math.floor(nNova[GodHand_data.engineActualRow+i].hp) or 0;
						local roleDisplay = "|cffFFBB00 "..nNova[GodHand_data.engineActualRow+i].role or " |cffFFBB00NONE";
						local nameDisplay = nameDisplay;
						if select(3,UnitClass(nNova[GodHand_data.engineActualRow+i].unit)) ~= nil and nNova[GodHand_data.engineActualRow+i].name ~= nil then
							nameDisplay = classColors[select(3,UnitClass(nNova[GodHand_data.engineActualRow+i].unit))].hex.." "..nNova[GodHand_data.engineActualRow+i].name;
						else
							nameDisplay = " No Name";
						end

						local targetDisplay;
						local hisTarget = tostring(nNova[GodHand_data.engineActualRow+i].target) or " |cff00F2FF未找到目标";
						if UnitName(hisTarget) ~= nil then targetDisplay = "|cff00F2FF "..UnitName(hisTarget) else targetDisplay = " |cff00F2FF未找到目标" end
						engineName = healthDisplay..nameDisplay..targetDisplay
					else
						engineName = "";
					end

					if _G["engine"..i.."Frame"]:IsShown() ~= 1 then
						_G["engine"..i.."Text"]:Show();
						_G["engine"..i.."Frame"]:Show();
					end

					_G["engine"..i.."Text"]:SetText(engineName, 1, 1, 1, 0.7);

				end
				for i = GodHand_data.engineRows+1, 25 do
					if _G["engine"..i.."Frame"]:IsShown() == 1 then
						_G["engine"..i.."Text"]:Hide();
						_G["engine"..i.."Frame"]:Hide();
					end
				end
			end

			engineFrame:SetHeight((GodHand_data.engineRows*20)+20);
		end
		engineFrame.texture:SetAlpha(GodHand_data.engineAlpha/100);
		for i = 1, 25 do
			if _G["engine"..i.."Frame"]:GetAlpha() ~= GodHand_data.engineAlpha/100 then
				_G["engine"..i.."Frame"]:SetAlpha(GodHand_data.engineAlpha/100);
				engineFrameText:SetAlpha(GodHand_data.engineAlpha/100);
			end
		end
		engineFrameText:SetWidth(GodHand_data.engineWidth);
		engineFrame:SetWidth(GodHand_data.engineWidth);
		for i = 1, 25 do
			if _G["engine"..i.."Frame"]:GetWidth() ~= GodHand_data.engineWidth then
				_G["engine"..i.."Frame"]:SetWidth(GodHand_data.engineWidth);
			end
			if _G["engine"..i.."Text"]:GetWidth() ~= GodHand_data.engineWidth then
				_G["engine"..i.."Text"]:SetWidth(GodHand_data.engineWidth);
			end
		end
    	engineFrameLoaded = true;
    	engineRefresh();
	end
end
