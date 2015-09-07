local L=GDLocale;
local lib=GDHelperFrame;
function GDHelper_LoadDB(self)
	local i,j;
	if(GDHelper and GDHelper.List)then
		for i=1, table.getn(GDHelper.List) do
			table.insert(GD.Helper.List,GDHelper.List[i]);
		end
	end
	GD.Helper.Current=GDHelperPer.Current
	if(GDHelperPer and GDHelperPer.List)then
		for i=1, table.getn(GDHelperPer.List) do
			local istrue=nil;
			for j=1, table.getn(GD.Helper.List) do
				if(GDHelperPer.List[i].Name==GD.Helper.List[j].Name)then
					istrue=true;
					break;
				end
			end
			if(not istrue)then
				table.insert(GD.Helper.List,GDHelperPer.List[i]);
			end
		end
	end
	if(GD.LazyScript and GD.LazyScript.List)then
		for i=1, table.getn(GD.LazyScript.List) do
			local istrue=nil;
			for j=1, table.getn(GD.Helper.List) do
				if(GD.LazyScript.List[i].Name==GD.Helper.List[j].Name)then
					if(GD.Helper.List[j].Base and GD.LazyScript.List[i].Version and (not GD.Helper.List[j].Version or GD.LazyScript.List[i].Version > GD.Helper.List[j].Version))then
						StaticPopupDialogs["Show_MessageBox_"..GD.LazyScript.List[i].Name] = {
							text = string.format(L["SCHEME_UPDATA_TITLE"],GD.LazyScript.List[i].Name),
							button1 = OKAY,
							button2 = CANCEL,
							OnAccept = function()
								local k;
								for k=1, table.getn(GD.Helper.List) do
									if(GD.Helper.List[k].Name==GD.LazyScript.List[i].Name)then
										GD.LazyScript.List[i].Base=true;
										GD.Helper.List[k]=GD.LazyScript.List[i];
									end
								end
								lib.Scheme:Update();
							end,
							timeout = 0,
							whileDead = true,
							hideOnEscape = true,
						};
						StaticPopup_Show("Show_MessageBox_"..GD.LazyScript.List[i].Name);
					end
					
					istrue=true;
					break;
				end
			end
			if(not istrue)then
				GD.LazyScript.List[i].Base=true;
				GD.LazyScript.List[i].Title=GD.LazyScript.List[i].Title or string.format(L["CLASS_COLOR_"..GD.Player.EClass],GD.LazyScript.List[i].Name);
				table.insert(GD.Helper.List,GD.LazyScript.List[i]);
				GD.Helper.Current=GD.LazyScript.List[i].Name;
			end
		end
	end
	lib.Scheme:Update();
end

function GDHelper_SaveDB(self)
	local i,j;
	local savetemp={};
	local savetempper={};
	for i=1, table.getn(GD.Helper.List) do
		if(GD.Helper.List[i].Base)then
			table.insert(savetempper,GD.Helper.List[i]);
		else
			table.insert(savetemp,GD.Helper.List[i]);
		end
	end
	if table.getn(savetemp)>0 then
		GDHelper={};
		GDHelper.List=savetemp;
	end
	
	if table.getn(savetempper)>0 then
		GDHelperPer={};
		GDHelperPer.List=savetempper;
		GDHelperPer.Current=GD.Helper.Current;
	end
end

function GDHelper_OnLoad(self)
	GD=GD or {};
	GD.Event=lib.Event or {};
	GD.Script=GD.Script or {};
	GD.Helper=GD.Helper or {};
	GD.Helper.List=GD.Helper.List or {};
	GD.LazyScript=GD.LazyScript or {};
	GDHelper=GDHelper or {};
	GDHelperPer=GDHelperPer or {};
	GD.Event.Index =0;
	GD.Event.Verify =0;
	GD.Event.Retry = 0;
	GD.Event.VerifyRetry = 0;
	GD.Event.Action=0;
	GD.Event.Sleep=GetTime();
	GD.Event.SetSleep = GetTime()
	GD.Event.Message="";
	GD.AutoHelper=GD.AutoHelper or {};
	GD.AutoHelper.Start=nil;
	GD.AutoHelper.Sleep=GetTime()
	GD.AutoHelper.RunTiem=0.1;
	BINDING_HEADER_GD = L["GD_TITLE"]
	BINDING_NAME_Show = L["GD_BINDING_SHOW"];
	BINDING_NAME_StartStop = L["GD_BINDING_STARTSTOP"];
	BINDING_NAME_Stop = L["GD_BINDING_STOP"];
	print(L["GD_ABOUT"]);
end

function GDHelper_SlashHandler(command)
	command=SecureCmdOptionParse(command);
	if command=="" then
		if GDHelperFrame:IsShown() then
			GDHelperFrame:Hide()
		else
			GDHelperFrame:Show()
		end
	elseif command:sub(1,5):lower()=="start" then
		if(GD.AutoHelper.Start)then
			GDHelper_SetAutoScript(nil);
		else
			GD.AutoHelper.Start=true;
		end
	elseif command:sub(1,6):lower()=="helper" then
		if GDHelperFrame:IsShown() then
			GDHelperFrame:Hide()
		else
			GDHelperFrame:Show()
		end
	elseif command:sub(1,4):lower()=="run " then
		local str=command:sub(5);
		local comm={};
		local ii=0;
		local k;
		for k in string.gmatch(str, "([^\ ]+)") do
			ii=ii+1;
		   comm[ii]=k;
		end
		GDHelper_RunScript(comm[1],comm[2])
	elseif command:sub(1,4):lower()=="stop" then
		GDHelper_SetAutoScript(nil);
	elseif command:sub(1,8):lower()=="message " then
		GD.Event.Message=command:sub(9);
	elseif command:sub(1,5):lower()=="auto " then
		local str=command:sub(6);
		local comm={};
		local ii=0;
		local k;
		for k in string.gmatch(str, "([^\ ]+)") do
			ii=ii+1;
		   comm[ii]=k;
		end
		GDHelper_SetAutoScript(comm[1],comm[2],tonumber(comm[3]) or 1);
	else
		print(L["GD_HELP"]);
	end
end

function GDHelper_SchemeUpdate(self)
	local i;
	self.TextList={};
	if table.getn(GD.Helper.List)<1 then
		table.insert(GD.Helper.List,{
			Name=L["SCHEME_NAME_EXAMPLE"],
			Items={}
		});
	end

	for i=1, table.getn(GD.Helper.List) do
		table.insert(self.TextList,{["Title"]=GD.Helper.List[i].Title or GD.Helper.List[i].Name ,["Name"]=GD.Helper.List[i].Name,["Icon"]=GD.Helper.List[i].Icon});
		if(not GD.Helper.Current)then
			GD.Helper.Current=GD.Helper.List[i].Name;
		end
	end

	self.DDList:Update();
	self.DDEdit:SetText(GD.Helper.Current or "");
	lib.List:Update();
end

function GDHelper_ProjectUpdateName(self,text,icon,del)
	local i;
	if table.getn(self.TextList)<1 then
	end
	if(not del)then
		if text and type(text)=="string" and text~="" then
			for i=1, table.getn(GD.Helper.List) do
				if GD.Helper.List[i].Name==text then
					if(icon)then
						if(icon=="Interface\\Icons\\INV_Misc_QuestionMark")then
							icon=nil;
						end
					GD.Helper.List[i].Icon=icon;
					end
					GD.Helper.Current=GD.Helper.List[i].Name;
					lib.Scheme:Update();
					GDHelper_SetStatus(string.format(L["SCHEME_STATUS_CHANGE"],text));
					return;
				end
			end
			if(icon=="Interface\\Icons\\INV_Misc_QuestionMark")then
				icon=nil;
			end
			table.insert(GD.Helper.List,{Name=text,Icon=icon,Items={}});
			GD.Helper.Current=text;
			lib.Scheme:Update();
			GDHelper_SetStatus(string.format(L["SCHEME_STATUS_NEW"],text));
			return;
		elseif text=="" then
			GD.Helper.Current=nil;
			return;
		end
	end
	if text and type(text)=="string" and text~="" then
		for i=1, table.getn(GD.Helper.List) do
			if GD.Helper.List[i].Name==text then
				table.remove(GD.Helper.List,i);
				GD.Helper.Current=nil;
				lib.Scheme:Update();
				GDHelper_SetStatus(string.format(L["SCHEME_STATUS_DELETE_FINISH"],text));
				return;
			end
		end
	end
end

function GDHelper_ListUpdate(self)
	local i,name,v;
	self.Items=self.Items or {};
	self.Selected=-1;
	self.SchemeInfo={};
	if GD.Helper.Current and table.getn(GD.Helper.List)>0 then
		for i=1, table.getn(GD.Helper.List) do
			if(GD.Helper.List[i].Name==GD.Helper.Current)then
				self.SchemeInfo=GD.Helper.List[i];
				break;
			end
		end
	end
	self.SchemeInfo=self.SchemeInfo or {};
	self.SchemeInfo.Items=self.SchemeInfo.Items or {};
	self.SchemeInfo.Variable=self.SchemeInfo.Variable or {};

    for i=1,table.getn(self.SchemeInfo.Items) do
		if(table.getn(self.Items)<i)then
			self.Items[i] = GDFrame.CreateCheckBox("Check"..i, self.ScrollChild,self,self:GetParent());
			if i==1 then
				self.Items[i]:SetPoint("TOPLEFT",self.ScrollChild,"TOPLEFT",5,0);
				self.Items[i]:SetPoint("TOPRIGHT",self.ScrollChild,"TOPRIGHT",-20,0);
			else
				self.Items[i]:SetPoint("TOPLEFT",self.Items[i-1],"BOTTOMLEFT",0,3);
				self.Items[i]:SetPoint("TOPRIGHT",self.Items[i-1],"BOTTOMRIGHT",0,3);
			end

			self.Items[i].Number:SetText(tostring(i));
			self.Items[i].Number:SetWidth((string.len(i)-1)*11+15)
			self.Items[i].Check:SetScript("OnClick" , function(c)
			
				self.SchemeInfo.Items[i].Enabled=c:GetChecked();
				if c:GetChecked() then
					GDHelper_SetStatus(string.format(L["LISTITEM_CHECK_STATUS_ENABLED"],self.SchemeInfo.Items[i].Name));
				else
					GDHelper_SetStatus(string.format(L["LISTITEM_CHECK_STATUS_DISABLED"],self.SchemeInfo.Items[i].Name));
				end
			end);
			self.Items[i].Check:SetScript("OnEnter",function(c)
				GameTooltip:SetOwner(lib,"ANCHOR_TOPLEFT");
				GameTooltip:ClearLines();
				GameTooltip:SetText(string.format(L["LISTITEM_CHECK_TOOLTIP_TITLE"],self.SchemeInfo.Items[i].Name),0.9,0.9,0.5);

				GameTooltip:AddLine(L["LISTITEM_CHECK_TOOLTIP_LINE1"],0.5,0.5,0.5);
				GameTooltip:AddLine(L["LISTITEM_CHECK_TOOLTIP_LINE2"],0.5,0.5,0.5);
				GameTooltip:Show();
			end);
			self.Items[i].Check:SetScript("OnLeave",function()
				GameTooltip:Hide();
			end);

			self.Items[i]:SetScript("OnReceiveDrag", function(c)
				if(GD.AutoHelper.RunList)then
					return
				end;
				--self:AddItemOnCursor(i);
			end);
			self.Items[i]:SetScript("OnMouseDown",function(c,btn)
				if(GD.AutoHelper.RunList)then
					return
				end;
				if btn=="LeftButton" and IsControlKeyDown() then
					if(table.getn(self.SchemeInfo.Items)>1)then
						self.Cursor=i
						self.TCursor=true;
						SetCursor(self.SchemeInfo.Items[i].Icon)
						return;
					end
				end
			end);
			self.Items[i]:SetScript("OnMouseUp",function(c,btn)
				if(GD.AutoHelper.RunList)then
					return
				end;
				if btn=="LeftButton" then
					CloseDropDownMenus(1);
					if(self.TCursor)then
						self:AddItemOnCursor(self.Cursor,i);
						self.TCursor=nil;
						self.Selection=self.Cursor;
					else
						self:AddItemOnCursor(i);
						if self.Selection==i then
							self.Selection=-1;
						else
							self.Selection=i;
						end
					end
					ResetCursor();
					self.TCursor=nil;
					return;
				elseif btn=="RightButton" then
					self.Selection=i;
					CloseDropDownMenus(1);
					ToggleDropDownMenu(1,nil,self.Items[i].ItemsMenu,"cursor",0,0);
				end
			end);
			self.Items[i]:SetScript("OnUpdate",function()
				if(self.Items[i]:IsVisible())then
					if self.Selection==i and (not self.Items[i].Mask_MouseDown:IsVisible()) then
						self.Items[i].Mask_MouseOver:Hide();
						self.Items[i].Mask_MouseDown:Show();
					end
					if self.Selection~=i and self.Items[i].Mask_MouseDown:IsVisible() then
						self.Items[i].Mask_MouseDown:Hide();
					end
				end
				if(self.Items[i].Tooltip)then
				GameTooltip:SetOwner(lib,"ANCHOR_TOPLEFT");
				GameTooltip:ClearLines();
				GameTooltip:SetText(string.format(L["LISTITEM_TOOLTIP_TITLE"],self.Items[i].Name:GetText(),self.SchemeInfo.Items[i].GUID),0.9,0.9,0.7)
				GameTooltip:AddLine(L["LISTITEM_TOOLTIP_LINE1"],0.5,0.5,0.5);
				GameTooltip:AddLine(self.SchemeInfo.Items[i].Description or L["LISTITEM_DESCRIPTION"],0.9,0.9,0.1);
				local iscd,stime=GDHelper_GetScriptCD(GD.Helper.Current,self.SchemeInfo.Items[i].GUID,self.SchemeInfo.Items[i].CD);
				if(iscd)then
					GameTooltip:AddLine(string.format(L["LISTITEM_TOOLTIP_CD"], stime),0.5,0.5,0.5);
				end
				GameTooltip:Show();
				end
				
				local iscd,stime=GDHelper_GetScriptCD(GD.Helper.Current,self.SchemeInfo.Items[i].GUID);
				
				if(stime and GetTime()-stime<=0.1)then
				self.Items[i].Play:Show();
				else
				self.Items[i].Play:Hide();
				end
			end);
			self.Items[i]:SetScript("OnEnter",function()
				self.Items[i].Tooltip=true;
				if not self.Items[i].Mask_MouseDown:IsVisible() then
					self.Items[i].Mask_MouseOver:Show();
				end
				if(self.TCursor)then
					self.Cursor=i;
				end
			end);
			self.Items[i]:SetScript("OnLeave",function()
				self.Items[i].Mask_MouseOver:Hide();
				self.Items[i].Tooltip=nil;
				GameTooltip:Hide();
			end);

			UIDropDownMenu_Initialize(self.Items[i].ItemsMenu, function(frm,level)
				if(GD.AutoHelper and GD.AutoHelper.Start)then
					return;
				end
				local index=i;
				if level==1 then
					--Title
					local info=UIDropDownMenu_CreateInfo();
					info.notCheckable=true;
					info.notClickable=true;
					--info.colorCode=string.format(L["CLASS_COLOR_"..GD.Player.EClass],"");--CLASSCOLOR[currentclass];
					info.text=string.format(L["CLASS_COLOR_"..GD.Player.EClass],string.format(L["LISTITEM_RIGHTCLICK_TITLE"],self.Items[index].Name:GetText()));
					info.justifyH="CENTER";
					if not self.SchemeInfo.Items[index].Type then
						info.notClickable=false;
						info.func=function(c)
							GDFrame.ShowCustomAction(L["CUSTOM_EDIT_TITLE"],self.SchemeInfo.Items[index].Name,self.SchemeInfo.Items[index].Icon,function(c,name,icon)
								if(c.args)then
									c.args.Name=name;
									c.args.Icon=icon;
									c.args.Title=nil;
									self:Update()
								end
							end,self.SchemeInfo.Items[index]);
						end;
					end
					UIDropDownMenu_AddButton(info,level);
					
					--"GUID"
					local info = UIDropDownMenu_CreateInfo();
					info.notCheckable=true;
					info.notClickable=true;
					if index and self.SchemeInfo.Items[index] and self.SchemeInfo.Items[index].GUID then
						info.text=string.format(L["LISTITEM_RIGHTCLICK_GUID_TITLE"], self.SchemeInfo.Items[index].GUID or "");
					end
					info.justifyH="CENTER";
					UIDropDownMenu_AddButton(info,level);
					
					local info=UIDropDownMenu_CreateInfo();
					info.notCheckable=true;
					info.notClickable=true;
					UIDropDownMenu_AddButton(info,level);
					
					local info=UIDropDownMenu_CreateInfo();
					info.notCheckable=true;
					info.justifyH="CENTER";
					if not self.SchemeInfo.Items[index].Type then
						info.text=L["LISTITEM_RIGHTCLICK_EDITACTION_TITLE"];
						info.value = {
							["Level1_Key"]="LISTITEM_RIGHTCLICK_EDITACTION_TITLE";
						};
						info.func=function(c)
							GDScriptEditerFrame:Bind(self.SchemeInfo,self.SchemeInfo.Items[index])
							CloseDropDownMenus(1);
						end;
					else
						info.hasArrow=true;
						info.text=L["LISTITEM_RIGHTCLICK_TARGET_TITLE"];
						info.value = {
							["Level1_Key"]="LISTITEM_RIGHTCLICK_TARGET_TITLE";
						};
					end
					UIDropDownMenu_AddButton(info,level);
					
					--"Config"
					local info = UIDropDownMenu_CreateInfo();
					info.hasArrow=true;
					info.notCheckable=true;
					info.text=L["LISTITEM_RIGHTCLICK_CONFIG_TITLE"];
					info.justifyH="CENTER";
					info.value = {
						["Level1_Key"]="LISTITEM_RIGHTCLICK_CONFIG_TITLE";
					};
					UIDropDownMenu_AddButton(info,level);
					
					--"ADVANCED"
					local info = UIDropDownMenu_CreateInfo();
					info.hasArrow=true;
					info.notCheckable=true;
					info.text=L["LISTITEM_RIGHTCLICK_ADVANCED_TITLE"];
					info.justifyH="CENTER";
					info.value = {
						["Level1_Key"]="LISTITEM_RIGHTCLICK_ADVANCED_TITLE";
					};
					UIDropDownMenu_AddButton(info,level);
					
					--"Delete"
					local info = UIDropDownMenu_CreateInfo();
					info.notCheckable=true;
					info.text=L["LISTITEM_RIGHTCLICK_DELETE_TITLE"];
					info.justifyH="CENTER";
					info.value = {
						["Level1_Key"]="LISTITEM_RIGHTCLICK_DELETE_TITLE";
					};
					info.func=function(c)
						StaticPopupDialogs["List_Delete_MessageBox"] = {
								text = string.format(L["LISTITEM_DELETE_CONFIRM"],self.SchemeInfo.Items[index].Name),
								button1 = OKAY,
								button2 = CANCEL,
								OnAccept = function(c,arg1)
									table.remove(self.SchemeInfo.Items,index);
									self:Update()
								end,
								timeout = 0,
								whileDead = true,
								hideOnEscape = true,
						};
						StaticPopup_Show("List_Delete_MessageBox");
					end;
					UIDropDownMenu_AddButton(info,level);
				elseif level==2 then
					local Level1_Key=UIDROPDOWNMENU_MENU_VALUE["Level1_Key"];
					--[[if Level1_Key=="LISTITEM_RIGHTCLICK_TARGET_TITLE" then
						local info = UIDropDownMenu_CreateInfo();
						info.hasArrow=false;
						if self.SchemeInfo.Items[index].Target=="default" then
							info.checked=1;
						else
							info.checked=nil;
						end
						info.colorCode="|cff00ffff";
						info.text=L["default"];
						info.justifyH="CENTER";
						info.value = {
							["Level1_Key"] = Level1_Key;
							["Sublevel_Key"] = L["default"];
						};
						info.func=function()
							self.SchemeInfo.Items[index].Target="default";
							self:Update()
							GDHelper_SetStatus(string.format(L["LISTklITEM_RIGHTCLICK_STATUS_TARGET"],self.SchemeInfo.Items[index].Name,L[self.SchemeInfo.Items[index].Target]));
							CloseDropDownMenus(1);
						end;
						UIDropDownMenu_AddButton(info,level);
						for _,key in pairs(TargetList) do
							local info = UIDropDownMenu_CreateInfo();
							info.hasArrow=false; -- no submenues this time
							if self.SchemeInfo.Items[index].Target==key then
								info.checked=1;
							else
								info.checked=nil;
							end
							info.text=L[key];
							info.justifyH="CENTER";
							info.value = {
								["Level1_Key"] = Level1_Key;
								["Sublevel_Key"] = key;
							};
							info.func=function()
								self.SchemeInfo.Items[index].Target=key;
								self:Update()
								GDHelper_SetStatus(string.format(L["LISTITEM_RIGHTCLICK_STATUS_TARGET"],self.SchemeInfo.Items[index].Name,L[self.SchemeInfo.Items[index].Target]));
								CloseDropDownMenus(1);
							end;
							UIDropDownMenu_AddButton(info,level);	
						end
					end	--end of "Casting Target"
					]]
					--"Config"
					if Level1_Key=="LISTITEM_RIGHTCLICK_CONFIG_TITLE" then
						local info = UIDropDownMenu_CreateInfo();
						info.hasArrow=true;
						info.notCheckable=true;
						info.text=string.format(L["LISTITEM_RIGHTCLICK_CD_TITLE"],self.SchemeInfo.Items[index].CD or 0);
						info.justifyH="CENTER";
						info.value = {
							["Level1_Key"] = Level1_Key;
							["Sublevel_Key"]="LISTITEM_RIGHTCLICK_CD_TITLE";
						};
						UIDropDownMenu_AddButton(info,level);
					
						local info = UIDropDownMenu_CreateInfo();
						info.hasArrow=true;
						info.notCheckable=true;
						info.text=L["LISTITEM_RIGHTCLICK_DESCRIPTION_TITLE"];
						info.justifyH="CENTER";
						info.value = {
							["Level1_Key"] = Level1_Key;
							["Sublevel_Key"]="LISTITEM_RIGHTCLICK_DESCRIPTION_TITLE";
						};
						UIDropDownMenu_AddButton(info,level);
						return;
					end
					
					if Level1_Key=="LISTITEM_RIGHTCLICK_ADVANCED_TITLE" then					
						local info = UIDropDownMenu_CreateInfo();
						---info.hasArrow=true;
						info.notCheckable=true;
						info.text=L["LISTITEM_RIGHTCLICK_ADVANCED_RUN_TITLE"];
						info.justifyH="CENTER";
						info.value = {
							["Level1_Key"] = Level1_Key;
							["Sublevel_Key"]="LISTITEM_RIGHTCLICK_ADVANCED_RUN_TITLE";
						};
						info.func=function(c)
							local icon=gsub(self.SchemeInfo.Items[index].Icon, "[%l%u]+\\", "");
						
							GDHelper_OnScript(string.format("DeleteMacro(\"Run_%s_%s\");",self.SchemeInfo.Name,self.SchemeInfo.Items[index].GUID));
							GDHelper_OnScript(string.format("PickupMacro(CreateMacro(\"Run_%s_%s\",\"%s\",\"/GD Run %s %s\",1));",self.SchemeInfo.Name,self.SchemeInfo.Items[index].GUID,icon or 1,self.SchemeInfo.Name,self.SchemeInfo.Items[index].GUID))
						end;
						
						UIDropDownMenu_AddButton(info,level);
						local info = UIDropDownMenu_CreateInfo();
						--info.hasArrow=true;
						info.notCheckable=true;
						info.text=L["LISTITEM_RIGHTCLICK_ADVANCED_AUTO_TITLE"];
						info.justifyH="CENTER";
						info.value = {
							["Level1_Key"] = Level1_Key;
							["Sublevel_Key"]="LISTITEM_RIGHTCLICK_ADVANCED_AUTO_TITLE";
						};
						info.func=function(c)
							local icon=gsub(self.SchemeInfo.Items[index].Icon, "[%l%u]+\\", "");
						
							GDHelper_OnScript(string.format("DeleteMacro(\"Auto_%s_%s\");",self.SchemeInfo.Name,self.SchemeInfo.Items[index].GUID));
							GDHelper_OnScript(string.format("PickupMacro(CreateMacro(\"Auto_%s_%s\",\"%s\",\"/GD [mod:alt]Stop;[btn:2]Stop;Auto %s %s\",1));",self.SchemeInfo.Name,self.SchemeInfo.Items[index].GUID,icon or 1,self.SchemeInfo.Name,self.SchemeInfo.Items[index].GUID))
						end;
						UIDropDownMenu_AddButton(info,level);
						
						local info = UIDropDownMenu_CreateInfo();
						--info.hasArrow=true;
						info.notCheckable=true;
						info.text=L["LISTITEM_RIGHTCLICK_ADVANCED_STOP_TITLE"];
						info.justifyH="CENTER";
						info.value = {
							["Level1_Key"] = Level1_Key;
							["Sublevel_Key"]="LISTITEM_RIGHTCLICK_ADVANCED_STOP_TITLE";
						};
						info.func=function(c)
							GDHelper_OnScript(string.format("DeleteMacro(\"STOP\");"));
							GDHelper_OnScript(string.format("PickupMacro(CreateMacro(\"STOP\",\"Ability_Hunter_BeastCall\",\"/GD Stop\",1));"))
						end;
						UIDropDownMenu_AddButton(info,level);
						return;
					end
				elseif level==3 then
					local Level2_Key=UIDROPDOWNMENU_MENU_VALUE["Sublevel_Key"];
					
					if Level2_Key=="LISTITEM_RIGHTCLICK_CD_TITLE" then
						local info = UIDropDownMenu_CreateInfo();
						info.hasArrow=false;
						info.notCheckable=true;
						info.text="12345";
						info.justifyH="CENTER";
						info.func=function(self)
							CloseDropDownMenus(1);
						end;
						UIDropDownMenu_AddButton(info,level);
						local f=getglobal("DropDownList3");
						local b=getglobal("DropDownList3Button1");
						f.DDEdit=f.DDEdit or GDFrame.CreateSingleEditBox("DropDownList3Button1Edit",f);
						f.DDEdit:Show();
						f.DDEdit.parent=self:GetParent();
						f.DDEdit:SetAllPoints();
						f.DDEdit:SetText(self.SchemeInfo.Items[index].CD or "0");
						f.DDEdit.EditBox:SetMaxLetters(4);
						f.DDEdit.EditBox:SetFrameStrata(b:GetFrameStrata());
						f.DDEdit:SetScript("OnShow",function(self)
							self.EditBox:HighlightText();
							self.EditBox:SetFocus();
						end);
						f.DDEdit:SetScript("OnHide",function(self)
							self.EditBox:HighlightText();
							self.EditBox:ClearFocus();
							self:Hide();
						end);
						f.DDEdit.OnText=function(c,text)
							self.SchemeInfo.Items[index].CD=tonumber(text) or self.SchemeInfo.Items[index].CD or 0;
							GDHelper_SetStatus(string.format(L["LISTITEM_RIGHTCLICK_CD_STATUS"],self.SchemeInfo.Items[index].Name,self.SchemeInfo.Items[index].CD));
							CloseDropDownMenus(1);
							f.DDEdit:Hide();
						end;
						f.DDEdit.OnMouseEnter=function(self)
							UIDropDownMenu_StopCounting(self:GetParent());
						end
						f.DDEdit.OnMouseLeave=function(self)
							UIDropDownMenu_StartCounting(self:GetParent());
						end
						b:Hide();
						return;
					end
					
					--"Description"
					if Level2_Key=="LISTITEM_RIGHTCLICK_DESCRIPTION_TITLE" then
						local info = UIDropDownMenu_CreateInfo();
						info.hasArrow=false;
						info.notCheckable=true;
						info.text="12345123451234512345123451234512345";
						info.justifyH="CENTER";
						info.func=function(self)
							CloseDropDownMenus(1);
						end;
						UIDropDownMenu_AddButton(info,level);
						local f=getglobal("DropDownList3");
						local b=getglobal("DropDownList3Button1");
						f.DDEdit=f.DDEdit or GDFrame.CreateSingleEditBox("DropDownList3Button1Edit",f);
						f.DDEdit:Show();
						f.DDEdit.Parent=self:GetParent();
						f.DDEdit:SetAllPoints();
						f.DDEdit:SetText(self.SchemeInfo.Items[index].Description or "");
						f.DDEdit.EditBox:SetMaxLetters(32);
						f.DDEdit.EditBox:SetFrameStrata(b:GetFrameStrata());
						f.DDEdit:SetScript("OnShow",function(self)
							self.EditBox:HighlightText();
							self.EditBox:SetFocus();
						end);
						f.DDEdit:SetScript("OnHide",function(self)
							self.EditBox:HighlightText();
							self.EditBox:ClearFocus();
							self:Hide();
						end);
						f.DDEdit.OnText=function(c,text)
							self.SchemeInfo.Items[index].Description=text or self.SchemeInfo.Items[index].Description or "";
							GDHelper_SetStatus(string.format(L["LISTITEM_RIGHTCLICK_DESCRIPTION_STATUS"],self.SchemeInfo.Items[index].Name));
							self:Update()
							CloseDropDownMenus(1);
							f.DDEdit:Hide();
						end;
						f.DDEdit.OnMouseEnter=function(self)
							UIDropDownMenu_StopCounting(self:GetParent());
						end
						f.DDEdit.OnMouseLeave=function(self)
							UIDropDownMenu_StartCounting(self:GetParent());
						end
						b:Hide();
						return;
					end
				end
			end,"MENU");
		end
		--[[if(self.SchemeInfo.Items[i].Enabled)then
			self.Items[i].Check:SetNormalTexture()
		else
			self.Items[i].Check:SetNormalTexture(self.SchemeInfo.Items[i].Icon)
		end]]
		self.Items[i].Icon:SetTexture(self.SchemeInfo.Items[i].Icon);
		self.Items[i].Check:SetChecked(self.SchemeInfo.Items[i].Enabled)
		if self.SchemeInfo.Items[i].Type=="item" then
			local itemName,itemLink,itemRarity,itemLevel,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,itemTexture,itemSellPrice=GetItemInfo(self.SchemeInfo.Items[i].Id);
			self.Items[i].Name:SetText(itemName);
			self.SchemeInfo.Items[i].Name=itemName;
		elseif self.SchemeInfo.Items[i].Type=="spell" then
			local spellName,spellLevel,_,_,_,_,_,_,_=GetSpellInfo(self.SchemeInfo.Items[i].Id);
			self.Items[i].Name:SetText(spellName);
			if spellLevel and spellLevel~="" then
				self.Items[i].Name:SetText(spellName .. "(" .. spellLevel .. ")");
			end
			self.SchemeInfo.Items[i].Name=spellName;
		else
			self.Items[i].Name:SetText(self.SchemeInfo.Items[i].Title or self.SchemeInfo.Items[i].Name);
		end
		
		if(GD.AutoHelper.RunList)then
			self.Items[i].Check:Hide();
			self.Items[i].Run:Hide();
			local j;
			for j=1,table.getn(GD.AutoHelper.RunList) do
				if(GD.AutoHelper.RunList[j]==i)then
					self.Items[i].Run:Show();
					break;
				end
			end
		else
			self.Items[i].Run:Hide();
			self.Items[i].Check:Show();
		end
		self.Items[i]:Show();
    end
	for i=table.getn(self.SchemeInfo.Items)+1,table.getn(self.Items) do
		self.Items[i]:Hide();
	end
	if(not self.ItemEnd)then
		self.ItemEnd = CreateFrame("Frame","$parent_ItemEnd",self.ScrollChild);
		self.ItemEnd:SetHeight(30);
	end
	if(table.getn(self.SchemeInfo.Items)>0)then
		self.ItemEnd:SetPoint("TOPLEFT",self.Items[table.getn(self.SchemeInfo.Items)],"BOTTOMLEFT",0,3);
		self.ItemEnd:SetPoint("TOPRIGHT",self.Items[table.getn(self.SchemeInfo.Items)],"BOTTOMRIGHT",0,3);
		self.ItemEnd:Show();
	else
		self.ItemEnd:Hide();
	end
end

function GDHelper_AddItemOnCursor(self,index,cur)

	local tempinfo={};
	local infoType,info1,info2=GetCursorInfo();
	index= index or-1;
	
	if infoType=="item" then
		local itemName,itemLink,itemRarity,itemLevel,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,itemTexture,itemSellPrice=GetItemInfo(info2);
		
		self.SchemeInfo.Items[index].Icon=itemTexture;
		self:Update()
		ClearCursor();
	elseif infoType=="spell" then
		local spellTexture=GetSpellTexture(info1,"BOOKTYPE_SPELL");

		self.SchemeInfo.Items[index].Icon=spellTexture;
		self:Update()
		ClearCursor();
	elseif cur and cur>0 and cur~=index then
		tempinfo=self.SchemeInfo.Items[cur];
		table.remove(self.SchemeInfo.Items,cur);
		if index<0 then
			table.insert(self.SchemeInfo.Items,tempinfo);
		else
			table.insert(self.SchemeInfo.Items,index,tempinfo);
		end
		self:Update()
		--GDHelper_SetStatus(string.format(L["LISTITEM_STATUS_ADD"],L["LISTITEM_STATUS_ADD_SPELL"],spellName));
		ResetCursor();
	end
end

function GDHelper_AddItemCustomed(self,name,icon,action)
	local tempinfo={};
	tempinfo.Name=name;
	tempinfo.Icon=icon;
	tempinfo.Enabled=true;
	tempinfo.Description=L["LISTITEM_DESCRIPTION"];
	tempinfo.GUID=self:GetGUID();
	table.insert(self.SchemeInfo.Items,tempinfo);
	self:Update()
	GDHelper_SetStatus(string.format(L["LISTITEM_STATUS_ADD"],L["LISTITEM_STATUS_ADD_CUSTOM"],name));
end

function GDHelper_GetGUID(self)
	local guid={};
	local i;
	for i=1,table.getn(self.SchemeInfo.Items) do
		local g=self.SchemeInfo.Items[i].GUID;
		if g then
			guid[g]=true;
		end
	end
	i=1;
	while guid[i] do
		i=i+1;
	end
	return i;
end

function GDHelper_IsScript(scheme,name)
	local i,j,k;
	local n,p,s,v;
	local errlist={};
	for i=1, table.getn(GD.Helper.List) do
		if(not scheme or GD.Helper.List[i].Name==scheme)then
			n=i;
			
			if(GD.Helper.List[i].Variable)then
				s=GDHelper_GetVariable(GD.Helper.List[i].Variable);
					
				local _, line = string.gsub(s, "\n", "\n")
				for k=1, line do
					table.insert(errlist,{Scheme=GD.Helper.List[i].Name,Name=L["VARIABLE"],Line=k});
				end
			end
			
			
			for j=1, table.getn(GD.Helper.List[i].Items) do
				if(name)then
					v=tonumber(name)-- or list[l];
					if(not v)then
						local _,_,nn=string.find(name, "['\"](.-)['\"]");
						v = nn or name;
					end
				
					if (type(v) == "number" and GD.Helper.List[i].Items[j].GUID==v) or GD.Helper.List[i].Items[j].Name==v then
						p=j;
						if(GD.Helper.List[i].Items[j].Script)then
							local status=string.format("GDHelper_SetScriptCD(\"%s\",%s,\"%s\")\n",GD.Helper.List[i].Name,GD.Helper.List[i].Items[j].GUID,GD.Helper.List[i].Items[j].Name);
							local code=status..GD.Helper.List[i].Items[j].Script.."\n"
							s=string.format("%s%s",s or "",code);
								
							local _, line = string.gsub(code, "\n", "\n")
							for k=0, line-1 do
								table.insert(errlist,{Scheme=GD.Helper.List[i].Name,Name=GD.Helper.List[i].Items[j].Name,Line=k});
							end
						end
						break;
					end
				else
					if GD.Helper.List[i].Items[j].Enabled then
						local iscd,stime=GDHelper_GetScriptCD(GD.Helper.List[i].Name,GD.Helper.List[i].Items[j].GUID,GD.Helper.List[i].Items[j].CD);
						if(not iscd)then
							if(GD.Helper.List[i].Items[j].Script)then
								local status=string.format("GDHelper_SetScriptCD(\"%s\",%s,\"%s\")\n",GD.Helper.List[i].Name,GD.Helper.List[i].Items[j].GUID,GD.Helper.List[i].Items[j].Name);
								local code=status..GD.Helper.List[i].Items[j].Script.."\n"
								s=string.format("%s%s",s or "",code);
								
								local _, line = string.gsub(code, "\n", "\n")
								for k=0, line-1 do
									table.insert(errlist,{Scheme=GD.Helper.List[i].Name,Name=GD.Helper.List[i].Items[j].Name,Line=k});
								end
							end
						end
					end
				end
			end
			break;
		end
	end
	
	
	if (not n) then
		print(string.format(L["SCRIPT_SCHEME_ERROER"],tostring(scheme)));
		return nil;
	elseif (name and not p)then
		print(string.format(L["SCRIPT_NAME_ERROER"],tostring(name)));
		return nil;
	elseif (not s)then
		print(string.format(L["SCRIPT_BODY_ERROER"],tostring(scheme)));
		return nil;
	else
		return true,n,p,s,errlist;
	end
end

function GDHelper_RunScript(scheme,name,stop)
	local r,n,p,s,err=GDHelper_IsScript(scheme,name)
	if not r then
		return;
	end
	GDHelper_OnScript(s,err,stop)
end

function GDHelper_OnScript(script,errlist,stop)
	local func, err, status, msg;
	if(script)then
		func, err = loadstring(script)
		if func then
			func, err = loadstring(script.." return;")
			if func then
				status, err = pcall(func)
				if not status then
					msg=err;
				end
			else
				msg=err;
			end
		else
			msg=err;
		end
	end	
	if(msg)then
		if(not GDScriptBoxFrame:IsShown()) then
			GDScriptBoxFrame:ClearAllPoints();
			GDScriptBoxFrame:SetPoint("TOPLEFT", GDScriptEditerFrame, "TOPRIGHT");
			GDScriptBoxFrame:SetTitle(L["GUI_BOXFRAME_TITLE"]);
		end
		if(errlist)then
			local a,b,line= string.find(msg,"[^:]:(%d+):");
			line=tonumber(line);
			if(line and errlist[line])then
				local strs= string.format("['%s'-'%s']:%s%s",errlist[line].Scheme,errlist[line].Name,errlist[line].Line,string.sub(msg, b))
				msg=strs;
			end
			if(stop and GD.AutoHelper.Start)then
				GDHelper_SetAutoScript(nil);
			end
		end
		
		GDScriptBoxFrame:Insert(msg.."\n"..string.rep("=", 20).."\n"..date().."\n"..string.rep("=", 20).."\n\n");
		GDScriptBoxFrame:Show();
		return false;
	else
		--GDScriptBoxFrame:Hide();
		return true;
	end
end

function GDHelper_OnMacro(script,name)
	local length = string.len(script)
	local t, i, k, e;
	name = name or 3;
	
	if length>200 then
		DEFAULT_CHAT_FRAME:AddMessage(L["MACRO_LENGTH_LONG"],192,0,192,0)
		return;
	end

	GD.Event.Sleep=GetTime();
	GD.Event.Index = GD.Event.Index+1 or 0;
	
	if GD.Event.Index > 999 then
		GD.Event.Index =0 ;		
	end
	----------------------------------
	t = "";	k = 0;	e = 3;
	
	for i=1, length do
		t = string.format("%s%03d", t, string.byte(script, i));
		k=k+1;
		if k == 5 then
			GD.Event.Encode(e,tonumber(t));
			e = e +1;
			k = 0;
			t = "" ;
		end	
	end
	
	if k>0 and k<5 then
		t = t .. string.rep("0", (5 - k) * 3 )
		GD.Event.Encode(e,tonumber(t));
	end
	
	if k==0 and length>0 then
		GD.Event.Encode(e,0);
	end

	t = string.format("1%09d%03d%03d", 0, name, GD.Event.Index);
	GD.Event.Encode(2,tonumber(t));
	GD.Spell.Sleep=GetTime();
	return k;
end

function GDHelper_OnVerify()
	GD.Event.Verify = GD.Event.Verify+1;
end

function GDHelper_SetStatus(text)
	lib:SetMessage(text);
end

function GDHelper_SetScriptCD(scheme,guid,name)
	GD.Helper.ScriptCD=GD.Helper.ScriptCD or {};
	GD.Helper.ScriptCD[scheme]=GD.Helper.ScriptCD[scheme] or {};
	GD.Helper.ScriptCD[scheme][guid]=GD.Helper.ScriptCD[scheme][guid] or {};
	GD.Helper.ScriptCD[scheme][guid].StartTime=GetTime();
	
	--[[if GD.Helper.Current==scheme then
		GDHelper_SetStatus(string.format(L["ENVIRONMENT_CASTING_CURRENT"],name));
	else
		GDHelper_SetStatus(string.format(L["ENVIRONMENT_CASTING"],scheme,name));
	end]]
end

function GDHelper_GetScriptCD(scheme,guid,cd)
	if(not GD.Helper.ScriptCD or not GD.Helper.ScriptCD[scheme] or not GD.Helper.ScriptCD[scheme][guid] or not GD.Helper.ScriptCD[scheme][guid].StartTime)then
		return nil;
	end
	local stime=GD.Helper.ScriptCD[scheme][guid].StartTime;

	if(cd and cd >0 and GetTime()-stime<cd)then
		return true,cd-(GetTime()-stime);
	else
		return false,stime;
	end
end

function GDHelper_GetVariable(var)
	local scriptlist="local V={};local C={};\n";
	for i=1,table.getn(var) do
		local v=var[i];
		if(v.Enabled)then
			if(v.Type==1)then
				scriptlist =string.format("%sV[\"%s\"]=true;\n",scriptlist, v.Name,v.Value);
			else
				if(v.ValueType==2)then
					if(v.Type==3)then
						scriptlist =string.format("%sC[\"%s\"]=\"%s\";",scriptlist, v.Name,v.ViceValue);
					end				
					scriptlist =string.format("%sV[\"%s\"]=\"%s\";\n",scriptlist, v.Name,v.Value);
				else
					if(v.Type==3)then
						scriptlist =string.format("%sC[\"%s\"]=%s;",scriptlist, v.Name,IF(v.ViceValue~="",v.ViceValue, 0));
					end				
					scriptlist =string.format("%sV[\"%s\"]=%s;\n",scriptlist, v.Name,IF(v.Value~="",v.Value, 0));
				end
			end
		end
	end

	return scriptlist;
end

function GDHelper_OnAutoScript()
	if(not GD.AutoHelper.Start)then
		return;
	end
	lib.Var:Hide();
	lib.Var.Edit:Hide();
	GD.AutoHelper.RunTiem=GD.AutoHelper.RunTiem or 0.01;
	if GD.AutoHelper.RunTiem >=0 and GetTime() - GD.AutoHelper.Sleep < GD.AutoHelper.RunTiem then
		return;
	end
	
	local i,j,k;
	local scriptlist;
	local errlist={};
	if GD.Helper.Current and table.getn(GD.Helper.List)>0 then
		for i=1, table.getn(GD.Helper.List) do
			if(GD.Helper.List[i].Name==GD.Helper.Current)then
				GD.AutoHelper.RunTiem=GD.Helper.List[i].CD;
				if(GD.Helper.List[i].Variable)then
					scriptlist=GDHelper_GetVariable(GD.Helper.List[i].Variable);
					
					local _, line = string.gsub(scriptlist, "\n", "\n")
					for k=1, line do
						table.insert(errlist,{Scheme=GD.Helper.List[i].Name,Name=L["VARIABLE"],Line=k});
					end
				end
				
				if(GD.AutoHelper.RunList)then
					local jj;
					for jj=1, table.getn(GD.AutoHelper.RunList) do
						j=GD.AutoHelper.RunList[jj];
						
							local iscd,stime=GDHelper_GetScriptCD(GD.Helper.List[i].Name,GD.Helper.List[i].Items[j].GUID,GD.Helper.List[i].Items[j].CD);
							if(not iscd)then
								if(GD.Helper.List[i].Items[j].Script)then
									local status=string.format("GDHelper_SetScriptCD(\"%s\",%s,\"%s\")\n",GD.Helper.List[i].Name,GD.Helper.List[i].Items[j].GUID,GD.Helper.List[i].Items[j].Name);
									local code=status..GD.Helper.List[i].Items[j].Script.."\n"
									scriptlist=string.format("%s%s",scriptlist or "",code);
									local _, line = string.gsub(code, "\n", "\n")
									for k=0, line-1 do
										table.insert(errlist,{Scheme=GD.Helper.List[i].Name,Name=GD.Helper.List[i].Items[j].Name,Line=k});
									end
								end
							end
						
					end
				else
					for j=1, table.getn(GD.Helper.List[i].Items) do
						if(GD.Helper.List[i].Items[j].Enabled)then
							local iscd,stime=GDHelper_GetScriptCD(GD.Helper.List[i].Name,GD.Helper.List[i].Items[j].GUID,GD.Helper.List[i].Items[j].CD);
							if(not iscd)then
								if(GD.Helper.List[i].Items[j].Script)then
									local status=string.format("GDHelper_SetScriptCD(\"%s\",%s,\"%s\")\n",GD.Helper.List[i].Name,GD.Helper.List[i].Items[j].GUID,GD.Helper.List[i].Items[j].Name);
									local code=status..GD.Helper.List[i].Items[j].Script.."\n"
									scriptlist=string.format("%s%s",scriptlist or "",code);
									local _, line = string.gsub(code, "\n", "\n")
									for k=0, line-1 do
										table.insert(errlist,{Scheme=GD.Helper.List[i].Name,Name=GD.Helper.List[i].Items[j].Name,Line=k});
									end
								end
							end
						end
					end
				end
				break;
			end
		end
	else
		return
	end

	GDHelper_OnScript(scriptlist,errlist,true);
	GD.AutoHelper.Sleep = GetTime();
end

function GDHelper_SetAutoScript(scheme,list,tip)
	tip = IF(tip,tip,0);
	GD.AutoHelper.Current=nil;
	GD.AutoHelper.Start=nil;
	GD.AutoHelper.RunList=nil;
	local lists;
	if type(tip) ~= "number" then
		tip=0;
	end
	
	if not scheme then
		if tip ~=2 then
			lib.Scheme.Disable=nil;
			lib.Scheme:Update();
			print(L["SCRIPT_STOP"]);
		end
		return true;
	elseif(scheme==true)then
		if tip ~=2 then
			print(L["SCRIPT_STRART"]);
		end
		GD.AutoHelper.Start=true;
		return true;
	end
	
	if list then
		if type(list) == "string" then
			lists = { strsplit(",",list) }
		elseif type(list) == "table" then
		
		else
			print(string.format(L["SCRIPT_LIST_ERROER"],tostring(list)));
			return false;
		end
	end
	
	local i,j,l,v,m;
	local temp,runidlist;
	for i=1, table.getn(GD.Helper.List) do
		if(GD.Helper.List[i].Name==scheme)then
			GD.AutoHelper.Current=i;
			temp=GD.Helper.List[i];
	
			break;
		end
	end

	if temp then
		GD.AutoHelper.RunTiem=temp.CD;
		if list then
			GD.AutoHelper.RunList={};
			runidlist={};
			for l=1, table.getn(lists) do
				v=tonumber(lists[l])-- or list[l];
				if(not v)then
					local _,_,n=string.find(lists[l], "['\"](.-)['\"]");
					v = n or lists[l];
				end
				for j=1, table.getn(temp.Items) do
					if((type(v) == "number" and temp.Items[j].GUID==v) or temp.Items[j].Name==v)then
						m=j;
						break;
					end
				end
				if(m)then
					table.insert(GD.AutoHelper.RunList,m);
					runidlist[m]=m;
				else
					if(type(v) == "number")then
						print(string.format(L["SCRIPT_GUID_ERROER"],tostring(v)));
						return false
					else
						print(string.format(L["SCRIPT_NAME_ERROER"],tostring(v)));
						return false
					end
				end
				m=nil;
			end
		end
	else
		print(string.format(L["SCRIPT_SCHEME_ERROER"],tostring(scheme)));
		return false
	end
	
	GD.AutoMacro.Tips=tip;
	GD.AutoHelper.Start=true;
	
	GD.Helper.Current=scheme;
	lib.Scheme.Disable=GD.AutoHelper.RunList;
	lib.Scheme:Update();
	
	if tip ~=2 then
		print(string.format(L["SCRIPT_STRART_LIST"],scheme,list or L["SCRIPT_STRART_DEFAULT"]));
	end
	return true;
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:SetScript("OnEvent", function(self, event,...)
    if (event == "PLAYER_ENTERING_WORLD") then
		SlashCmdList["SUPERDUPERMACRO"] = GDHelper_SlashHandler;
		SLASH_SUPERDUPERMACRO1 = "/GD";

		GD.Addons["SHelper"]={};
		GD.Addons["SHelper"]["AddonsName"]=L["GUI_MAINFRAME_TITLE"];
		GD.Addons["SHelper"]["name"]=L["GUI_MAINFRAME_TOOLTIP"];
		GD.Addons["SHelper"]["run"]="GDHelperFrame:Show()";
		GD.Addons["SHelper"]["inf"]=L["GUI_MAINFRAME_TOOLTIP"];
		GD.Addons["SHelper"]["is"]=GDHelperFrame;
		GD.Addons["SHelper"]["icon"]="Interface\\Addons\\GD\\GD.tga"
	--[[	GD.Addons["SChannelDB"]={};
		GD.Addons["SChannelDB"]["AddonsName"]=L["GUI_MAINFRAME_TITLEC"];
		GD.Addons["SChannelDB"]["name"]=L["GUI_MAINFRAME_TOOLTIPC"];
		GD.Addons["SChannelDB"]["run"]="InterfaceOptionsFrame_OpenToCategory('神手频道')";
		GD.Addons["SChannelDB"]["inf"]=L["GUI_MAINFRAME_TOOLTIPC"];
		GD.Addons["SChannelDB"]["is"]=GDHelperFrame;
		GD.Addons["SChannelDB"]["icon"]="Interface\\Addons\\GD\\GD.tga"]]
	elseif (event == "PLAYER_LOGOUT") then
		GDHelper_SaveDB();
		GD.Event.Remove(event);
    elseif (event == "VARIABLES_LOADED") then
		GDHelper_LoadDB();
		GDHelperFrame:Show();
    end
end);



frame:SetScript("OnUpdate",function(arg1)
	if (GetTime() - GD.Event.SetSleep >3) then
		GD.Event.SetSleep = GetTime()
		if GD.Event.GetMode() then
			GD.Event.Verify =0;
			GDHelper_OnMacro("/run GDHelper_OnVerify()");
			GD.Event.VerifyTime = GetTime();
			GD.Event.VerifyRetry = 0;
			GD.Event.Action=1;
		elseif GD.Event.Action==1 then
			if GD.Event.Verify > 0 then
				GD.Event.Action=2;
			else
				if(GD.Event.VerifyRetry<100) then
					GD.Event.VerifyRetry=GD.Event.VerifyRetry+1;
					GDHelper_OnMacro("/run GDHelper_OnVerify()");
				else
					DEFAULT_CHAT_FRAME:AddMessage(L["GD_COMERROR"]);
				end
			end
		elseif GD.Event.Action==2 and GD.Event.Verify>0 then
			local mode=GD.Event.GetMode(1);
			if(GD.Event.Mode~=mode)then
				if(mode)then
					GDMinimapButton:SetDesaturated(true);
					GDZoneText:SetText(L["GD_DISCONNECT"],GD.Event.Message);
					GDZoneText.FadeInTime = 1;
					GDZoneText.HoldTime = 15;
					GDZoneText.FadeOutTime = 5;
					GDZoneText:Show();
					GD.Event.Message="";
				else
					GDMinimapButton:SetDesaturated(false);
					GDZoneText:SetText(L["GD_CONNECTION"],GD.Event.Message);
					GDZoneText.FadeInTime = 1;
					GDZoneText.HoldTime = 5;
					GDZoneText.FadeOutTime = 1;
					GDZoneText:Show();
					GD.Event.Message="";
				end
				GD.Event.Mode=mode;
			end
		end
	end
	
	if (GetTime() - GD.Event.Sleep) >0.1 then
		GD.Event.Sleep=GetTime();		
		GD.Event.Remove();
	end
	
	if (GD.Event.Verify == 1) then
		GD.Event.Verify =2;
		GD.Event.Message=string.format(L["GD_DELAY"], GetTime() - GD.Event.VerifyTime);
	end
	GDHelper_OnAutoScript();
end);





lib.List.AddItemCustomed=GDHelper_AddItemCustomed;
lib.List.AddItemOnCursor=GDHelper_AddItemOnCursor;
lib.List.Update=GDHelper_ListUpdate;
lib.List.GetGUID=GDHelper_GetGUID;

lib.Var.List:SetScript("OnMouseUp",function(self,btn)
		if btn=="LeftButton" then
			CloseDropDownMenus(1);
		elseif btn=="RightButton" then
			CloseDropDownMenus(1);
			ToggleDropDownMenu(1,nil,self.RightClickMenu,"cursor",0,0);
		end
end);

lib.Var.List.Update=function(self)
	self.Items=self.Items or {};
	self.Variable=self.Variable or {};
    for i=1,table.getn(self.Variable) do
		if(table.getn(self.Items)<i)then
			self.Items[i] = GDFrame.CreateVarBox("Var"..i, self.ScrollChild);
			if i==1 then
				self.Items[i]:SetPoint("TOPLEFT",self.ScrollChild,"TOPLEFT",5,0);
				self.Items[i]:SetPoint("TOPRIGHT",self.ScrollChild,"TOPRIGHT",-20,0);
			else
				self.Items[i]:SetPoint("TOPLEFT",self.Items[i-1],"BOTTOMLEFT",0,3);
				self.Items[i]:SetPoint("TOPRIGHT",self.Items[i-1],"BOTTOMRIGHT",0,3);
			end

			self.Items[i].Check:SetScript("OnClick" , function(c)
				self.Variable[i].Enabled=c:GetChecked();
			end);
			self.Items[i].Check:SetScript("OnEnter",function(c)
				GameTooltip:SetOwner(lib.Var,"ANCHOR_TOPLEFT");
				GameTooltip:ClearLines();
				GameTooltip:SetText(string.format(L["LISTITEM_CHECK_TOOLTIP_TITLE"],self.Variable[i].Name),0.9,0.9,0.5);

				GameTooltip:AddLine(L["LISTITEM_CHECK_TOOLTIP_LINE1"],0.5,0.5,0.5);
				GameTooltip:AddLine(L["LISTITEM_CHECK_TOOLTIP_LINE2"],0.5,0.5,0.5);
				GameTooltip:Show();
			end);
			self.Items[i].Check:SetScript("OnLeave",function()
				GameTooltip:Hide();
			end);
			self.Items[i].Value:SetScript("OnLeave" , function(c)
				self.Variable[i].Value=c:GetText();
			end);
			self.Items[i].Vice:SetScript("OnLeave" , function(c)
				self.Variable[i].ViceValue=c:GetText();
			end);
			

			self.Items[i]:SetScript("OnMouseUp",function(c,btn)
				if(GD.AutoHelper.RunList)then
					return
				end;
				if btn=="LeftButton" then
					CloseDropDownMenus(1);
					return;
				elseif btn=="RightButton" then
					self.Selection=i;
					CloseDropDownMenus(1);
					ToggleDropDownMenu(1,nil,self.Items[i].ItemsMenu,"cursor",0,0);
				end
			end);

			UIDropDownMenu_Initialize(self.Items[i].ItemsMenu, function(frm,level)
				local index=i;
				if level==1 then
					--Title
					local info=UIDropDownMenu_CreateInfo();
					info.notCheckable=true;
					info.notClickable=true;

					info.text=string.format(L["VARIABLE_RIGHTCLICK_EDIT_TITLE"],self.Items[index].Name:GetText());
					info.justifyH="CENTER";
					info.notClickable=false;
					info.func=function(c)
						lib.Var.Edit:Hide();
						lib.Var.Edit:SetTitle(string.format(L["VARIABLE_RIGHTCLICK_EDIT_TITLE"],self.Items[index].Name:GetText()));
						lib.Var.Edit.Data=self.Variable[index];
						lib.Var.Edit:Show();
					end
					UIDropDownMenu_AddButton(info,level);
					
					--"Delete"
					local info = UIDropDownMenu_CreateInfo();
					info.notCheckable=true;
					info.text=L["VARIABLE_RIGHTCLICK_DELETE_TITLE"];
					info.justifyH="CENTER";
					info.value = {
						["Level1_Key"]="VARIABLE_RIGHTCLICK_DELETE_TITLE";
					};
					info.func=function(c)
						StaticPopupDialogs["List_Delete_MessageBox"] = {
								text = string.format(L["VARIABLE_RIGHTCLICK_DELETE_CONFIRM"],self.Variable[index].Name),
								button1 = OKAY,
								button2 = CANCEL,
								OnAccept = function(c,arg1)
									table.remove(self.Variable,index);
									self:Update()
								end,
								timeout = 0,
								whileDead = true,
								hideOnEscape = true,
						};
						StaticPopup_Show("List_Delete_MessageBox");
					end;
					UIDropDownMenu_AddButton(info,level);
				end
			end,"MENU");
		end
		
		self.Items[i].Check:SetChecked(self.Variable[i].Enabled)
		self.Items[i].Name:SetText(self.Variable[i].Name or "");
		self.Items[i].Description:SetText(self.Variable[i].Description or "");
		self.Items[i].Value:SetText(self.Variable[i].Value or "");
		self.Items[i].Value:SetWidth(self.Variable[i].Size or 50);
		self.Items[i].Join:SetText(self.Variable[i].Join or "-");
		self.Items[i].Vice:SetText(self.Variable[i].ViceValue or "");
		self.Items[i].Vice:SetWidth(self.Variable[i].Size or 50);
		self.Items[i].Value:SetNumeric(self.Variable[i].Numeric==1);
		self.Items[i].Vice:SetNumeric(self.Variable[i].Numeric==1);
		
		if(self.Variable[i].Type==1)then
			self.Items[i].Value:Hide();
			self.Items[i].Vice:Hide();
			self.Items[i].Join:Hide();
			self.Items[i].Description:SetPoint("LEFT",self.Items[i].Name,"RIGHT",10,0);
		elseif(self.Variable[i].Type==2)then
			self.Items[i].Value:Show();
			self.Items[i].Vice:Hide();
			self.Items[i].Join:Hide();
			self.Items[i].Description:SetPoint("LEFT",self.Items[i].Value,"RIGHT",10,0);
		elseif(self.Variable[i].Type==3)then
			self.Items[i].Value:Show();
			self.Items[i].Vice:Show();
			self.Items[i].Description:SetPoint("LEFT",self.Items[i].Vice,"RIGHT",10,0);
		end

		self.Items[i]:Show();
    end

	for i=table.getn(self.Variable)+1,table.getn(self.Items) do
		self.Items[i]:Hide();
	end
	if(not self.ItemEnd)then
		self.ItemEnd = CreateFrame("Frame","$parent_ItemEnd",self.ScrollChild);
		self.ItemEnd:SetHeight(30);
	end
	if(table.getn(self.Variable)>0)then
		self.ItemEnd:SetPoint("TOPLEFT",self.Items[table.getn(self.Variable)],"BOTTOMLEFT",0,3);
		self.ItemEnd:SetPoint("TOPRIGHT",self.Items[table.getn(self.Variable)],"BOTTOMRIGHT",0,3);
		self.ItemEnd:Show();
	else
		self.ItemEnd:Hide();
	end
end

lib.Var.Edit.Save:SetScript("OnClick",function(self)
	local v=lib.Var.Edit;
	local data={};
	data.Enabled=true;
	data.Name=v.Name:GetText();
	data.Description=v.Description:GetText();
	data.Size=tonumber(v.Size:GetText());
	data.Value=v.Value:GetText();
	data.ViceValue=v.Vice:GetText();
	data.Join=v.Join:GetText();
	data.Type=v.Type;
	data.ValueType=v.ValueType;
	local i,m,n;
	if(v.Data and v.Data.Name)then
		for i=1,table.getn(lib.Var.List.Variable) do
			if(lib.Var.List.Variable[i].Name==v.Data.Name)then
				m=i;
				break;
			end
		end
	end
	
	for i=1,table.getn(lib.Var.List.Variable) do
		if(lib.Var.List.Variable[i].Name==v.Name:GetText())then
			n=i;
			break;
		end
	end
	
	
	if(m and (not n or m==n))then
		lib.Var.List.Variable[m]=data;
	elseif(n)then
		StaticPopupDialogs["GDHelper_Var_Save_MessageBox"] = {
			text = string.format(L["VARIABLE_RIGHTCLICK_SAME_CONFIRM"],v.Name:GetText()),
			button1 = OKAY,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			};
		StaticPopup_Show("GDHelper_Var_Save_MessageBox");
		return;
	else
		table.insert(lib.Var.List.Variable,data);
	end
	lib.Var.List:Update();
	lib.Var.Edit:Hide();
end);

lib.Scheme.Update=GDHelper_SchemeUpdate;
lib.Scheme.Func=GDHelper_ProjectUpdateName;

lib.Scheme.AddFunc=function(self)
	GDFrame.ShowCustomAction(L["SCHEME_NEW_TITLE"],"",1,function(self,name,icon,args)
		lib.Scheme:Func(name,icon)
	end);
end
lib.Scheme:SetScript("OnEnter",function(self)
	GameTooltip:SetOwner(lib,"ANCHOR_TOPLEFT");
	GameTooltip:ClearLines();
	GameTooltip:SetText(L["SCHEME_TOOLTIP_TITLE"],0.9,0.9,0.5);
	GameTooltip:AddLine(L["SCHEME_TOOLTIP_LINE1"],0.5,0.5,0.5);
	GameTooltip:AddLine(L["SCHEME_TOOLTIP_LINE2"],0.5,0.5,0.5);
	GameTooltip:Show();
end);
lib.Scheme:SetScript("OnLeave",function(self)
	GameTooltip:Hide();
end);
lib.ProjectTitle.Delete:SetScript("OnClick",function(self, button)
		if GD.Helper.Current and GD.Helper.Current==lib.Scheme:GetText() then
			StaticPopupDialogs["GDHelperFrame_SchemeDropDown_MessageBox"] = {
				text = string.format(L["SCHEME_STATUS_DELETE_CONFIRM"],GD.Helper.Current),
				button1 = OKAY,
				button2 = CANCEL,
				OnAccept = function()
					if(GD.AutoHelper.Start)then
						GDHelper_SetAutoScript(nil);
					end
					local body;
					local id,mun=GetNumMacros();
					id=mun+36;
					while id>0 do
						body=GetMacroBody(id);
						if(body and string.find(body,"/GD [^\ ]+ "..GD.Helper.Current))then
							GDHelper_OnScript(string.format("DeleteMacro(%s);",id));
						end
						id=id-1;
					end
					lib.Scheme:Func(GD.Helper.Current,nil,true);
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
			};
			StaticPopup_Show("GDHelperFrame_SchemeDropDown_MessageBox");
		end
	end);
lib.List:SetScript("OnMouseUp",function(self,btn)
		if btn=="LeftButton" then
			--self:AddItemOnCursor();
			CloseDropDownMenus(1);
		elseif btn=="RightButton" then
			CloseDropDownMenus(1);
			ToggleDropDownMenu(1,nil,self.RightClickMenu,"cursor",0,0);
		end
	end);
lib.List:SetScript("OnReceiveDrag", function(self)
		--self:AddItemOnCursor();
	end);
lib.List:SetScript("OnEnter",function(self)
	GameTooltip:SetOwner(lib,"ANCHOR_TOPLEFT");
	GameTooltip:ClearLines();
	GameTooltip:SetText(string.format(L["LIST_TOOLTIP_TITLE"]),0.9,0.9,0.5);

	GameTooltip:AddLine(L["LIST_TOOLTIP_LINE1"],0.5,0.5,0.5);
	GameTooltip:Show();
end);
lib.List:SetScript("OnLeave",function()
	GameTooltip:Hide();
end);
lib.Input:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(lib,"ANCHOR_TOPLEFT");
		GameTooltip:ClearLines();
		GameTooltip:SetText(L["SCHEMECONTROL_INPUT_TOOLTIP_TITLE"],0.9,0.9,0.5);
		GameTooltip:AddLine(L["SCHEMECONTROL_INPUT_TOOLTIP_LINE1"],0.5,0.5,0.5);
		GameTooltip:Show();
	end);
lib.Input:SetScript("OnLeave",function(self)
		GameTooltip:Hide();
	end);
lib.Input:SetScript("OnClick",function(self)
	StaticPopupDialogs["GDHelper_Input_MessageBox"] = {
		text = L["SCHEMECONTROL_INPUT_MESSAGE"],
		hasEditBox = true,
		button1 = OKAY,
		button2 = CANCEL,
		OnShow = function(self)
			self.editBox:SetText("");
		end,
		OnAccept = function(self)
			local succ,tbl=SerializerLib:Deserialize(self.editBox:GetText());
			if succ then
				if tbl.Name and tbl.Items then
				
					StaticPopupDialogs["GDHelper_Input_MessageBox2"] = {
						text = L["SCHEMECONTROL_INPUT_MESSAGE2"],
						hasEditBox = true,
						button1 = OKAY,
						button2 = CANCEL,
						OnShow = function(self)
							self.editBox:SetText(tbl.Name);
						end,
						OnAccept = function(self)
							local temptxt=strtrim(self.editBox:GetText());
							if temptxt and temptxt~="" and string.len(temptxt)<=16 then
								local i,old;
								for i=1, table.getn(GD.Helper.List) do
									if(GD.Helper.List[i].Name==temptxt)then
										old=i;
										break;
									end
								end
							
								tbl.Name=temptxt;
								if(old)then
									--[[GD.Helper.List[old]=tbl;
									GD.Helper.Current=temptxt;
									lib.Scheme:Update();]]
									GDHelper_SetStatus(string.format(L["SCHEMECONTROL_INPUT_STATUS1"],temptxt));
								else
									table.insert(GD.Helper.List,tbl);
									GD.Helper.Current=temptxt;
									lib.Scheme:Update();
								end
							else
								StaticPopup_Hide("GDHelper_Input_MessageBox2");
								StaticPopup_Show("GDHelper_Input_MessageBox3");
							end
						end,
						timeout = 0,
						whileDead = true,
						hideOnEscape = true,
					};

					StaticPopupDialogs["GDHelper_Input_MessageBox3"] = {
						text = L["SCHEMECONTROL_INPUT_MESSAGE2"],
						hasEditBox = true,
						button1 = OKAY,
						button2 = CANCEL,
						OnShow = function(self)
							self.editBox:SetText(tbl.Name);
						end,
						OnAccept = function(self)
							local temptxt=strtrim(self.editBox:GetText());
							if temptxt and temptxt~="" and string.len(temptxt)<=16 then
								local i,old;
								for i=1, table.getn(GD.Helper.List) do
									if(GD.Helper.List[i].Name==temptxt)then
										old=i;
										break;
									end
								end
								
								tbl.Name=temptxt;
								if(old)then
									--[[GD.Helper.List[old]=tbl;
									GD.Helper.Current=temptxt;
									lib.Scheme:Update();]]
									GDHelper_SetStatus(string.format(L["SCHEMECONTROL_INPUT_STATUS1"],temptxt));
								else
									table.insert(GD.Helper.List,tbl);
									GD.Helper.Current=temptxt;
									lib.Scheme:Update();
								end
							else
								StaticPopup_Hide("GDHelper_Input_MessageBox3");
								StaticPopup_Show("GDHelper_Input_MessageBox2");
							end
						end,
						timeout = 0,
						whileDead = true,
						hideOnEscape = true,
					};

					StaticPopup_Hide("GDHelper_Input_MessageBox");
					StaticPopup_Show("GDHelper_Input_MessageBox2");
				end
			else
				GDHelper_SetStatus(L["SCHEMECONTROL_INPUT_STATUS2"]);
			end
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	};
	StaticPopup_Show("GDHelper_Input_MessageBox");
end);
lib.Output:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(lib,"ANCHOR_TOPLEFT");
		GameTooltip:ClearLines();
		GameTooltip:SetText(L["SCHEMECONTROL_INPUT_TOOLTIP_TITLE"],0.9,0.9,0.5);
		GameTooltip:AddLine(L["SCHEMECONTROL_OUTPUT_TOOLTIP_LINE1"],0.5,0.5,0.5);
		GameTooltip:Show();
	end);
lib.Output:SetScript("OnLeave",function(self)
		GameTooltip:Hide();
	end);
lib.Output:SetScript("OnClick",function(self)
	StaticPopupDialogs["GDHelper_Output_MessageBox"] = {
		text = L["SCHEMECONTROL_OUTPUT_MESSAGE"],
		hasEditBox = true,
		button1 = OKAY,
		button2 = CANCEL,
		OnShow=function(self)
			local temp=GDCopyTable(lib.List.SchemeInfo);
			self.editBox:SetText(SerializerLib:Serialize(temp));
			self.editBox:HighlightText();
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	};
	StaticPopup_Show("GDHelper_Output_MessageBox");
end);
lib.StartStop:SetScript("OnEnter",function(self)
		self.Tooltip=true;
	end);
lib.StartStop:SetScript("OnLeave",function(self)
		self.Tooltip=nil;
		GameTooltip:Hide();
end);
lib.StartStop:SetScript("OnClick",function(self)
		if GD.AutoHelper.Start then
			GDHelper_SetAutoScript(nil);
		else
			GDHelper_SetAutoScript(true);
		end
end);
lib.StartStop:SetScript("OnUpdate",function(self)
	if GD.AutoHelper.Start then
		self:SetText(L["SCHEMECONTROL_STOP_TITLE"]);
		self.HoverTexture:SetTexture("Interface\\OPTIONSFRAME\\VoiceChat-Record");
		self.HoverTexture:SetGradient("Horizontal", 1,0,0,1,0,0);
	else
		self:SetText(L["SCHEMECONTROL_START_TITLE"]);
		self.HoverTexture:SetTexture("Interface\\OPTIONSFRAME\\VoiceChat-Play");
		self.HoverTexture:SetGradient("Horizontal", 0,1,0,0,1,0);
	end
	if self.Tooltip then
		if GD.AutoHelper.Start then
			GameTooltip:SetOwner(lib,"ANCHOR_TOPLEFT");
			GameTooltip:ClearLines();
			GameTooltip:SetText(L["SCHEMECONTROL_STOP_TOOLTIP_TITLE"],0.9,0.9,0.5);
			GameTooltip:AddLine(L["SCHEMECONTROL_STOP_TOOLTIP_LINE1"],0.5,0.5,0.5);
			GameTooltip:AddLine(L["SCHEMECONTROL_STOP_TOOLTIP_LINE2"],0.5,0.5,0.5);
			GameTooltip:Show();
		else
			GameTooltip:SetOwner(lib,"ANCHOR_TOPLEFT");
			GameTooltip:ClearLines();
			GameTooltip:SetText(L["SCHEMECONTROL_START_TOOLTIP_TITLE"],0.9,0.9,0.5);
			GameTooltip:AddLine(L["SCHEMECONTROL_START_TOOLTIP_LINE1"],0.5,0.5,0.5);
			GameTooltip:AddLine(L["SCHEMECONTROL_START_TOOLTIP_LINE2"],0.5,0.5,0.5);
			GameTooltip:Show();
		end
	end
end);

UIDropDownMenu_Initialize(lib.List.RightClickMenu, function(frm,level)
		if(GD.AutoHelper and GD.AutoHelper.Start)then
			return;
		end
		if level==1 then
			--CloseDropDownMenus(1);
			local info={};
			info.text=L["LIST_RIGHTCLICK_ADD"];
			--tempinfo.hasArrow=true;
			info.notCheckable=true;
			info.colorCode="|cff00ffff";
			info.value={
				["Level1_Key"]="LIST_RIGHTCLICK_ADD",
			};
			info.func=function(self)
					CloseDropDownMenus(1);
					GDFrame.ShowCustomAction(L["CUSTOM_NEW_TITLE"],"",1,function(self,name,icon,args)
						lib.List:AddItemCustomed(name,icon,"");
					end);
			end
			UIDropDownMenu_AddButton(info,level);
			
			local info={};
			info.text=L["LIST_RIGHTCLICK_CONFIG_TITLE"];
			info.hasArrow=true;
			info.notCheckable=true;
			info.value={
				["Level1_Key"]="LIST_RIGHTCLICK_CONFIG_TITLE",
			};
			UIDropDownMenu_AddButton(info,level);
			
			--"ADVANCED"
			local info = UIDropDownMenu_CreateInfo();
			info.hasArrow=true;
			info.notCheckable=true;
			info.text=L["LIST_RIGHTCLICK_MACRO_TITLE"];
			info.justifyH="CENTER";
			info.value = {
				["Level1_Key"]="LIST_RIGHTCLICK_MACRO_TITLE";
			};
			UIDropDownMenu_AddButton(info,level);
			
			--"VARIABLE"
			local info = UIDropDownMenu_CreateInfo();
			--info.hasArrow=true;
			info.notCheckable=true;
			info.colorCode="|cffff0000";
			info.text=L["LIST_RIGHTCLICK_VARIABLE_TITLE"];
			info.justifyH="CENTER";
			info.value = {
				["Level1_Key"]="LIST_RIGHTCLICK_VARIABLE_TITLE";
			};
			info.func=function(self)
					CloseDropDownMenus(1);
					lib.Var:SetTitle(string.format(L["VARIABLE_TITLE"],lib.List.SchemeInfo.Name))
					lib.Var.List.Variable = lib.List.SchemeInfo.Variable;
					lib.Var.List:Update();
					lib.Var:Show();
			end
			UIDropDownMenu_AddButton(info,level);
			
			--"ADVANCED"
			local info = UIDropDownMenu_CreateInfo();
			info.hasArrow=true;
			info.notCheckable=true;
			info.text=L["LIST_RIGHTCLICK_ADVANCED_TITLE"];
			info.justifyH="CENTER";
			info.value = {
				["Level1_Key"]="LIST_RIGHTCLICK_ADVANCED_TITLE";
			};
			--UIDropDownMenu_AddButton(info,level);
		end
		if level==2 then
			local Level1_Key=UIDROPDOWNMENU_MENU_VALUE["Level1_Key"];
			if Level1_Key=="LIST_RIGHTCLICK_ADD" then
				local tempinfo={};
				tempinfo.text=L["LIST_RIGHTCLICK_ADD_BLANK"];
				tempinfo.notCheckable=true;
				tempinfo.colorCode="|cff00ffff";
				--tempinfo.value={
				--	["Level1_Key"]="LIST_RIGHTCLICK_ADD",
				--};
				tempinfo.func=function(self)
					CloseDropDownMenus(1);
					GDFrame.ShowCustomAction(L["CUSTOM_NEW_TITLE"],"",1,function(self,name,icon,args)
						lib.List:AddItemCustomed(name,icon,"");
					end);
				end
				UIDropDownMenu_AddButton(tempinfo,level);
				return;
			end
			if Level1_Key=="LIST_RIGHTCLICK_CONFIG_TITLE" then
				local info = UIDropDownMenu_CreateInfo();
				info.hasArrow=true;
				info.notCheckable=true;
				info.text=string.format(L["LIST_RIGHTCLICK_CONFIG_CD_TITLE"],lib.List.SchemeInfo.CD or 0);
				info.justifyH="CENTER";
				info.value = {
					["Level1_Key"] = Level1_Key;
					["Sublevel_Key"]="LIST_RIGHTCLICK_CONFIG_CD_TITLE";
				};
				UIDropDownMenu_AddButton(info,level);
				return;
			end
			if Level1_Key=="LIST_RIGHTCLICK_MACRO_TITLE" then
				local info = UIDropDownMenu_CreateInfo();
				---info.hasArrow=true;
				info.notCheckable=true;
				info.text=L["LIST_RIGHTCLICK_MACRO_RUN_TITLE"];
				info.justifyH="CENTER";
				info.value = {
					["Level1_Key"] = Level1_Key;
					["Sublevel_Key"]="LIST_RIGHTCLICK_ADVANCED_RUN_TITLE";
				};
				info.func=function(c)
					local icon=gsub(lib.List.SchemeInfo.Icon, "[%l%u]+\\", "");
				
					GDHelper_OnScript(string.format("DeleteMacro(\"Run_%s\");",lib.List.SchemeInfo.Name));
					GDHelper_OnScript(string.format("PickupMacro(CreateMacro(\"Run_%s\",\"%s\",\"/GD Run %s\",1));",lib.List.SchemeInfo.Name,icon or 1,lib.List.SchemeInfo.Name))
				end;
				UIDropDownMenu_AddButton(info,level);
			
				local info = UIDropDownMenu_CreateInfo();
				---info.hasArrow=true;
				info.notCheckable=true;
				info.text=L["LIST_RIGHTCLICK_MACRO_AUTO_TITLE"];
				info.justifyH="CENTER";
				info.value = {
					["Level1_Key"] = Level1_Key;
					["Sublevel_Key"]="LIST_RIGHTCLICK_ADVANCED_AUTO_TITLE";
				};
				info.func=function(c)
					local icon=gsub(lib.List.SchemeInfo.Icon, "[%l%u]+\\", "");
				
					GDHelper_OnScript(string.format("DeleteMacro(\"Auto_%s\");",lib.List.SchemeInfo.Name));
					GDHelper_OnScript(string.format("PickupMacro(CreateMacro(\"Auto_%s\",\"%s\",\"/GD [mod:alt]Stop;[btn:2]Stop;Auto %s\",1));",lib.List.SchemeInfo.Name,icon or 1,lib.List.SchemeInfo.Name))
				end;
				UIDropDownMenu_AddButton(info,level);
				
				local info = UIDropDownMenu_CreateInfo();
				---info.hasArrow=true;
				info.notCheckable=true;
				info.text=L["LIST_RIGHTCLICK_MACRO_AUTOITEM_TITLE"];
				info.justifyH="CENTER";
				info.value = {
					["Level1_Key"] = Level1_Key;
					["Sublevel_Key"]="LIST_RIGHTCLICK_ADVANCED_AUTOITEM_TITLE";
				};
				info.func=function(c)
					local i,j;
					local list,icon;
					for i=1, table.getn(lib.List.SchemeInfo.Items) do
						if(lib.List.SchemeInfo.Items[i].Enabled)then
							if(not list)then
								list=string.format("%s",lib.List.SchemeInfo.Items[i].GUID);
							else
								list=string.format("%s,%s",list,lib.List.SchemeInfo.Items[i].GUID);
							end
							
							icon=gsub(lib.List.SchemeInfo.Items[i].Icon, "[%l%u]+\\", "");
						end
					end
					if(list)then
						GDHelper_OnScript(string.format("DeleteMacro(\"Auto_%s_%s\");",lib.List.SchemeInfo.Name,list));
						GDHelper_OnScript(string.format("PickupMacro(CreateMacro(\"Auto_%s_%s\",\"%s\",\"/GD [mod:alt]Stop;[btn:2]Stop;Auto %s %s\",1));",lib.List.SchemeInfo.Name,list,icon or 1,lib.List.SchemeInfo.Name,list))
					end
				end;
				UIDropDownMenu_AddButton(info,level);
				
				local info = UIDropDownMenu_CreateInfo();
				---info.hasArrow=true;
				info.notCheckable=true;
				info.text=L["LIST_RIGHTCLICK_MACRO_STOP_TITLE"];
				info.justifyH="CENTER";
				info.value = {
					["Level1_Key"] = Level1_Key;
					["Sublevel_Key"]="LIST_RIGHTCLICK_ADVANCED_STOP_TITLE";
				};
				info.func=function(c)
					GDHelper_OnScript(string.format("DeleteMacro(\"STOP\");"));
					GDHelper_OnScript(string.format("PickupMacro(CreateMacro(\"STOP\",\"Ability_Hunter_BeastCall\",\"/GD Stop\",1));"))	
				end;
				UIDropDownMenu_AddButton(info,level);
				return;
			end
			return;
		end
		if level==3 then
			local Level2_Key=UIDROPDOWNMENU_MENU_VALUE["Sublevel_Key"];
				if Level2_Key=="LIST_RIGHTCLICK_CONFIG_CD_TITLE" then
						local info = UIDropDownMenu_CreateInfo();
						info.hasArrow=false;
						info.notCheckable=true;
						info.text="12345";
						info.justifyH="CENTER";
						info.func=function(self)
							CloseDropDownMenus(1);
						end;
						UIDropDownMenu_AddButton(info,level);
						local f=getglobal("DropDownList3");
						local b=getglobal("DropDownList3Button1");
						f.DDEdit=f.DDEdit or GDFrame.CreateSingleEditBox("DropDownList3Button1Edit",f);
						f.DDEdit:Show();
						--f.DDEdit.parent=self:GetParent();
						f.DDEdit:SetAllPoints();
						f.DDEdit:SetText(lib.List.SchemeInfo.CD or "0.01");
						f.DDEdit.EditBox:SetMaxLetters(4);
						f.DDEdit.EditBox:SetFrameStrata(b:GetFrameStrata());
						f.DDEdit:SetScript("OnShow",function(self)
							self.EditBox:HighlightText();
							self.EditBox:SetFocus();
						end);
						f.DDEdit:SetScript("OnHide",function(self)
							self.EditBox:HighlightText();
							self.EditBox:ClearFocus();
							self:Hide();
						end);
						f.DDEdit.OnText=function(c,text)
							lib.List.SchemeInfo.CD=tonumber(text) or lib.List.SchemeInfo.CD;
							GDHelper_SetStatus(string.format(L["LIST_RIGHTCLICK_CONFIG_CD_STATUS"],lib.List.SchemeInfo.Name,lib.List.SchemeInfo.CD));
							CloseDropDownMenus(1);
							f.DDEdit:Hide();
						end;
						f.DDEdit.OnMouseEnter=function(self)
							UIDropDownMenu_StopCounting(self:GetParent());
						end
						f.DDEdit.OnMouseLeave=function(self)
							UIDropDownMenu_StartCounting(self:GetParent());
						end
						b:Hide();
						return;
					end
			return;
		end
	end,"MENU");
UIDropDownMenu_Initialize(lib.Var.List.RightClickMenu, function(frm,level)
		if(GD.AutoHelper and GD.AutoHelper.Start)then
			return;
		end
		if level==1 then
			local info={};
			info.text=L["VARIABLE_RIGHTCLICK_ADD_TITLE"];
			--tempinfo.hasArrow=true;
			info.notCheckable=true;
			info.colorCode="|cff00ffff";
			info.value={
				["Level1_Key"]="VARIABLE_RIGHTCLICK_ADD_TITLE",
			};
			info.func=function(self)
				lib.Var.Edit:Hide();
				lib.Var.Edit:SetTitle(L["VARIABLE_RIGHTCLICK_ADD_TITLE"]);
				lib.Var.Edit.Data=nil;
				lib.Var.Edit:Show();
			end
			UIDropDownMenu_AddButton(info,level);
		end
	end,"MENU");
GDScriptEditerFrame.Edit:SetScript("OnEscapePressed",  function(self)
	GDScriptEditerFrame.Close:Click();
end);
GDScriptEditerFrame.Edit:SetScript("OnCursorChanged", function(self)
	if(not self.Debug)then
		local _, line = string.gsub(string.sub(self:GetText(1), 1, self:GetCursorPosition()), "\n", "\n")
		GDScriptEditerFrame:SetMessage(string.format(L["EDITER_LINE_TITLE"],line+1))
	else
		self.Debug=nil;
	end
end);
GDScriptEditerFrame.Exit:SetScript("OnClick",function(self, button)
	if(GDScriptEditerFrame.Value.Script~=GDScriptEditerFrame.Edit:GetText())then
		StaticPopupDialogs["Show_MessageBox_Save"] = {
			text = string.format(L["EDITER_EXIT_SAVE_CONFIRM"]),
			button1 = OKAY,
			button2 = CANCEL,
			button3 = NO,
			OnAccept = function()
				local k;
				local scriptlist;
				local errlist={};
				local code;
				
				if(GDScriptEditerFrame.Scheme.Variable)then
					scriptlist=GDHelper_GetVariable(GDScriptEditerFrame.Scheme.Variable);
					
					local _, line = string.gsub(scriptlist, "\n", "\n")
					for k=1, line do
						table.insert(errlist,{Scheme=GDScriptEditerFrame.Scheme.Name,Name=L["VARIABLE"],Line=k});
					end
				end
				
				code=GDScriptEditerFrame.Edit:GetText();
				scriptlist=string.format("%s%s",scriptlist or "",code);
				local _, line = string.gsub(code, "\n", "\n")
				
				for k=1, line+1 do
					table.insert(errlist,{Scheme=GDScriptEditerFrame.Scheme.Name,Name=GDScriptEditerFrame.Title,Line=k});
				end

				if(GDHelper_OnScript(scriptlist,errlist))then
					GDScriptEditerFrame.Value.Script=GDScriptEditerFrame.Edit:GetText();
					GDScriptEditerFrame.Value.Title=nil;
					GDScriptEditerFrame:Hide();
					lib.List:Update()
					GDHelper_SetStatus(string.format(L["EDITER_SAVE_FINISH"],GDScriptEditerFrame.Title))
				end
			end,
			OnAlt = function()
				GDScriptEditerFrame:Hide();
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		};
		StaticPopup_Show("Show_MessageBox_Save");
	else
		GDScriptEditerFrame:Hide();
	end
end);
GDScriptEditerFrame.Menu:AddItem("item1",L["EDITER_MENU_SAVE_TITLE"],function(self,edit)
	edit.Debug=true;
	edit:SetFocus();
	edit:ClearFocus();
	local k;
	local scriptlist;
	local errlist={};
	local code;
	
	if(GDScriptEditerFrame.Scheme.Variable)then
		scriptlist=GDHelper_GetVariable(GDScriptEditerFrame.Scheme.Variable);
		
		local _, line = string.gsub(scriptlist, "\n", "\n")
		for k=1, line do
			table.insert(errlist,{Scheme=GDScriptEditerFrame.Scheme.Name,Name=L["VARIABLE"],Line=k});
		end
	end
	
	code=edit:GetText();
	scriptlist=string.format("%s%s",scriptlist or "",code);
	local _, line = string.gsub(code, "\n", "\n")
	
	for k=1, line+1 do
		table.insert(errlist,{Scheme=GDScriptEditerFrame.Scheme.Name,Name=GDScriptEditerFrame.Title,Line=k});
	end

	if(GDHelper_OnScript(scriptlist,errlist))then
		GDScriptBoxFrame:Hide();
		GDScriptEditerFrame.Value.Script=edit:GetText();
		GDScriptEditerFrame.Value.Title=nil;
		GDScriptEditerFrame:SetMessage(string.format(L["EDITER_SAVE_FINISH"],GDScriptEditerFrame.Title));
		lib.List:Update();
		GDHelper_SaveDB();
	end
end);
GDScriptEditerFrame.Menu:AddItem("item2",L["EDITER_MENU_DEBUG_TITLE"],function(self,edit)
	edit.Debug=true;
	edit:SetFocus();
	edit:ClearFocus();
	
	local k;
	local scriptlist;
	local errlist={};
	local code;
	
	if(GDScriptEditerFrame.Scheme.Variable)then
		scriptlist=GDHelper_GetVariable(GDScriptEditerFrame.Scheme.Variable);
		
		local _, line = string.gsub(scriptlist, "\n", "\n")
		for k=0, line-1 do
			table.insert(errlist,{Scheme=GDScriptEditerFrame.Scheme.Name,Name=L["VARIABLE"],Line=k});
		end
	end
	
	code=edit:GetText();
	scriptlist=string.format("%s%s",scriptlist or "",code);
	local _, line = string.gsub(code, "\n", "\n")
	
	for k=1, line+1 do
		table.insert(errlist,{Scheme=GDScriptEditerFrame.Scheme.Name,Name=GDScriptEditerFrame.Title,Line=k});
	end

	if(GDHelper_OnScript(scriptlist,errlist))then
		GDScriptBoxFrame:Hide();
		GDScriptEditerFrame:SetMessage(string.format(L["EDITER_DEBUG_FINISH"],GDScriptEditerFrame.Title))
	end
end);
GDScriptEditerFrame.Bind=function(self,scheme,arg1)
	self.Value=arg1;
	self.Scheme=scheme;
	self.Title=arg1.Name;
	self:SetTitle(string.format(L["EDITER_TITLE"],self.Title))
	self.Edit:SetText(arg1.Script or "")
	self:Show();
end

GDMinimapButton:SetScript("OnClick",function(self, button)

	local addon={};
	function addon:GDMenu_OnClick(a)
		RunScript(a);
		GDMenu:Close(1);
	end

	function addon:OnMenuRequest(level, value, menu)
		if level == 1 then 
			menu:AddLine()
			for i,v in pairs(GD.Addons) do
				if v["is"] then
					menu:AddLine("text", v["name"], "checked",nil,"func","GDMenu_OnClick", "arg1", self, "arg2", v["run"],"icon",v["icon"])
				else
					menu:AddLine("text", v["name"], "hasConfirm", 1, "confirmText", v["AddonsName"] .. L["GD_ADDONS_NOINSTALL"],"confirmButton1",_G["OKAY"],"icon",v["icon"])
				end
			end
			menu:AddLine() 
			menu:AddLine("text", "|cffffff00" .. CLOSE, "closeWhenClicked", 1)
		end
	end

	function addon:GDMenu_OnClick(a)
		RunScript(a);
		GDMenu:Close(1);
	end

	GDMenu:SetMenuRequestFunc(addon,"OnMenuRequest")

	if button  then
		GDMenu:Toggle(self)
		GameTooltip:Hide()
	end
end);

GDHelper_OnLoad();

