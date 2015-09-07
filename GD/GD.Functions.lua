function GetNumRaidMembers()
return GetNumGroupMembers()
end
function GetNumPartyMembers()
return GetNumGroupMembers()
end

function SpellIsRun(spellName,target)
	if IsUsableSpell(spellName) and IsSpellInRange(spellName,target)==1 then
		if GetSpellCooldown(spellName) == 0 then
			return true
		end
	end
return false
end

function GDIsRun(spell,unit,gcd,special,isRun,NOCD,EnergyDemand)--是否可以对此目标施放技能
	local A,B,C,D,E,F,G,H,I;
	
	if not spell then
		return;
	end
	
	unit=GDUnit(unit,"target");
	
	if GDSpellIsConversion then
		local scid,scname = GDSpellIsConversion(spell);
		if scid then
			spell=scname;
		end
	end
	
	local t,text = GD_IsFailed(spell,unit);
	if not t then
		
		GD.Spell.Property[spell] = GD.Spell.Property[spell] or {};
		
		A=t;
		B = GD.Spell.Property[spell]["Type"] or "";
		C=text;
		D=0;
		E="";
		F="";
		G="";
		H="";
	else
		A,B,C,D,E,F,G,H,I=GD_IsRunSpell(spell,unit,gcd,special,NOCD,EnergyDemand);
	end
	

	if A then
		GD_IsRunSpell_Result(spell,unit,A)
	end
	
	return A,B,C,D,E,F,spell,unit,I
end

function GDRun(spell,unit,mouse) -- 施放技能
	
	--if (GetTime() - GD.Spell.Sleep )<=0.01 then
	--print("因为时间返回")
	--	return false;
	--end;

	unit=GDUnit(unit,"target");
	
	local macroSpell = strsub(spell,1,1) ;
	local tspell="";
	
	if macroSpell == "/"  then
		tspell=spell;
		RunMacroText(spell)
	else
	--local t1,t2,_,spellId = true,true,true,true;
	local t1,t2,_,spellId = GD_GetSpellInf(spell);
	--print(t1,t2,spellId)
	if not t1 then
		return false;
	end
		
	if t1 and t2==5 then
		CastSpellByName(spell,unit)
		tspell=spell;
	elseif t1 and (t2 ==1 or t2==2 or t2==3) then
	
		if not spellId then
			spellId = "'" .. spell .. "'";
		end
		
		if unit == "nogoal" then
		RunMacroText("/cast " .. spell)
			tspell ="/cast " .. spell;
		else		
		RunMacroText("/cast [target=" .. unit .. "]" .. spell)
			tspell ="/cast [target=" .. unit .. "]" .. spell;
		end

	elseif t1 and t2 ==4 then
		local getMacroIndex = GetMacroIndexByName(spell)
		if getMacroIndex >0 then
			local sepll, rank ,body = GetMacroInfo(getMacroIndex);
			tspell=body;
		else
			return false;
		end
	end
	end
	if(tspell and tspell~="")then
		if mouse then
			GDHelper_OnMacro(string.format("%s#%s",mouse,tspell),5)
		else
			GDHelper_OnMacro(tspell)
		end
		return true;
	else
		return false;
	end
	
end

function GDPassPhrase(text) --消息密语
	if text then
		GD.Spell.Event.PhraseText=text;
		GD.Spell.Event.PassPhrase= true;
	else
		GD.Spell.Event.PassPhrase=false;
	end
end

function GDUnitIsFollow() --跟随目标 
	return GD.Spell.Event.FollowUnit;
end

function GDGCD(spellname) --获得某职业的公告CD
	local spellid;
	if spellname then
		spellid = GetSpellInfo(spellname)
	else
		if GD.Player.GCD==0 then
			return 0
		end
		spellid = GetSpellInfo(GD.Player.GCD)
	end
	
	if not spellid then
		return -1
	end
	
	local start, dur = GetSpellCooldown(spellid)
	if (start and dur and start>0 and dur>0) then
		return dur - (GetTime() - start) 
	end
	return 0
end

function GDSpellCD(spell) --技能CD冷却时间

	local isname,typenumber,spellLevel = GD_GetSpellInf(spell);
	
	if typenumber == -1 then
		return -1,false,typenumber,"無法識別的技能、物品";
	elseif typenumber==4 or typenumber==5 then
		return -1,false,typenumber,"無法獲得技能、物品以外的冷卻時間";
	end

	local n,is
	
	if typenumber == 1 then
		local spellId = GD.Spell.Property[spell]["SpellId"];
		n,is = GDSpellCoolDown(spellId)
		if is then
			return n,is;
		end
	elseif typenumber == 2 or typenumber == 3 then
		
		local itemID = GD.Spell.Property[spell]["ItemID"];
		n,is = GDItemCoolDown(itemID)
		if is then
			return n,is;
		end
	end
	
	return -1,is;
end

function GDItemCoolDown(item) 
	local itemID;
	local isname = nil;
	if type(item) == "string" then
		itemID = GDGetItemId(item)
		if not itemID then
			return -1,isname;
		end
		isname=1;
	else
		itemID =item;
		if GetItemInfo(itemID) then
			isname=1;
		else
			return -1,isname;
		end
	end

	local isEquipped = IsEquippedItem(itemID)
	local a,b,c = GetItemCooldown(itemID);
	local n;	
	if c ==0 or not a then
		return -1,isname,isEquipped,itemID;
	end
		
	n = a+b-GetTime()
	return IF(n < 0,0,n),isname,isEquipped,itemID;
end

function GDSpellCoolDown(spell)
	local isname = nil;
	local a,b,c = GetSpellCooldown(spell) 
	
	if a then
		isname=1;
	else
		isname=nil;
		return -1,isname;
	end
	
	if c ==0 or not a then
		return -1,isname;
	end
	
	n = a+b-GetTime();
	return IF(n < 0,0,n),isname;
end

function GDRange(unit1, unit2)-- 判断距离
	if not unit2 then
		unit1= GDUnit(unit1,"target");
		if not UnitName(unit1) then
			return 100000000;
		end
		local jl;
		if( GD.Spell.RC) then
		_,jl = GD.Spell.RC:getRange(unit1)
		end
		return IF(jl,jl,100000000);
	else
		--参数类型格式化
		local i=0;
		if UnitInRaid("player") then
			if string.lower(string.sub(unit1,1,4))~="raid" or string.lower(string.sub(unit2,1,4))~="raid" then
				for i=1, GetNumRaidMembers() do
					local tempname, _, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i);
					unit1= tempname==unit1 and "raid" .. tostring(i) or unit1;
					unit2= tempname==unit2 and "raid" .. tostring(i) or unit2;
				end
				if string.lower(string.sub(unit1,1,4))~="raid" or string.lower(string.sub(unit2,1,4))~="raid" then
					return 100000000;
				end
			end
		elseif UnitInParty("player") then
			if (string.lower(string.sub(unit1,1,5))~="party" and string.lower(unit1)~="player") or (string.lower(string.sub(unit2,1,5))~="party" and string.lower(unit2)~="player") then
				unit1= UnitName("player")==unit1 and "player" or unit1;
				unit2= UnitName("player")==unit2 and "player" or unit2;
		
				for i=1, GetNumPartyMembers() do
					local tempname=UnitName("party" .. tostring(i))
					unit1= tempname==unit1 and "party" .. tostring(i) or unit1;
					unit2= tempname==unit2 and "party" .. tostring(i) or unit2;
				end
				if (string.lower(string.sub(unit1,1,5))~="party" and string.lower(unit1)~="player") or (string.lower(string.sub(unit2,1,5))~="party" and string.lower(unit2)~="player") then
					return 100000000;
				end
			end
		else
			return 100000000;
		end
		--计算距离
		local _,mapheight,mapwidth=GetMapInfo();
		local unit1x, unit1y = GetPlayerMapPosition(unit1);
		local unit2x, unit2y = GetPlayerMapPosition(unit2);
		if mapheight and mapheight>0 and mapwidth and mapwidth>0 and unit1x and unit1x>0 and unit1y and unit1y>0 and unit2x and unit2x>0 and unit2y and unit2y>0 then
			local length=math.ceil(math.sqrt(math.pow((unit1x-unit2x)*mapwidth,2)+math.pow((unit1y-unit2y)*mapheight,2)));
			return length;
		else
			return 100000000;
		end
	end
end

function GDTalentInfo(talentname)--獲得你的天賦某選項的信息
	--local i,k
	--for i=1, GetNumTalentTabs() do
	---	for k=1, GetNumTalents(i) do
		--	local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(i,k)
		--	if name == talentname then
		--		return rank, maxRank
		--	end
	--	end
	--end
	return nil;
end

function GDTalentName() --获得当前天赋名称
	local s;
	local m=0;
	for i=1,GetNumTalentTabs() do
		local _,_,_,_,p=GetTalentTabInfo(i);
		if p>m then
			m=p;
			s=i;
		end
	end
	local _,n=GetTalentTabInfo(s);
	return n
end

-- function GDGetSpellId(name)
	-- if not name then
		-- return;
	-- end

	-- local skillType, spellId = GetSpellBookItemInfo(name);
	-- if spellId then
		-- local spellName,spellSubName =GetSpellInfo(spellId);
		-- return spellId,spellName,spellSubName,skillType;
	-- end
-- end

 function GDGetSpellId(spellname) --獲得技能在技能書的ID
	local spellid = nil
	for tab = 1, 4 do
		local _, _, offset, numSpells = GetSpellTabInfo(tab)
		for i = (1+offset), (offset+numSpells) do
			local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
			
			if strlower(spell) == strlower(spellname) then
				spellid = i
				break
			end
		end
	end
	return spellid;
end

function GDGetItemId(name)
	local itemId,spell,bagName;
	for i=1 , 23 do
		itemId = GetInventoryItemID("player",i)
		if itemId then
			spell = GetItemInfo(itemId)
			if spell == name then
				return itemId;
			end
		end
	end
	
	for i=0 , 10 do
		bagName = GetBagName(i);
		if bagName then
			local n = GetContainerNumSlots(i)
			for k=1 , n do		
				itemId = GetContainerItemID(i, k);
				if itemId then
					spell = GetItemInfo(itemId);
					if spell and spell == name then
						return itemId;
					end
				end
			end
		end
	end
	return nil;
end

function GDGetSpellName(spellId)

	local spellName,spellRank = GetSpellInfo(spellId);
	if not spellRank then
		spellRank="";
	end
	
	if spellRank ~= "" then
		spellName = spellName .. "(" .. spellRank .. ")" ;
	end
	
	return spellName;
end

function GDSpellBookId(spellname) --获得技能在技能书的ID
	if not spellname then
		spellname=GetSpellInfo(GD.Player.GCD)
	end

	local spellid = nil
	for tab = 1, 4 do
		local _, _, offset, numSpells = GetSpellTabInfo(tab)
		for i = (1+offset), (offset+numSpells) do
			local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
			if strlower(spell) == strlower(spellname) then
				spellid = i
				break
			end
		end
	end
	return spellid;
end

function GDGetGlyphSocketInfo(GlyphName) --判断雕文
	local numGlyphSockets = GetNumGlyphSockets();
	for i = 1, numGlyphSockets do
		local enabled, glyphType, glyphTooltipIndex, glyphSpellID, icon = GetGlyphSocketInfo(i);
		if ( enabled and glyphSpellID) then
			local name = GetSpellInfo(glyphSpellID);
		
			if name and GlyphName == name then
				return i;
			end
		end
	end
end

function GDGetShapeshiftId() ---'獲得当前姿態ID
	local a;
	for i=1 , 9 do
		_,name,a = GetShapeshiftFormInfo(i);
		if a then
			return i,name;
		end
	end

	return 0;
end

function GDUnitCastSpellName(unit,interrupt,times)
	unit=GDUnit(unit,"target");
	local c,_,_,_,startTime,_,_,_,i = UnitCastingInfo(unit);
	
	if c then
		if GD.Config.Arena.IsUnitCastSpellName and GDIsArena() then
			times = IF(times,times,GD.Config.ACTime);
			if GetTime() - (startTime/1000) > times then
				if not interrupt then
					return c;
				else
					if not i then
						return c;
					end
				end
			end		
		else
			if not interrupt then
				return c;
			else
				if not i then
					return c;
				end
			end
		end
	else
		c,_,_,_,startTime,_,_,i = UnitChannelInfo(unit);
		if c then
			if GD.Config.Arena.IsUnitCastSpellName and GDIsArena() then
				times = IF(times,times,GD.Config.ACTime);
	
				if GetTime() - (startTime/1000) > times then
					if not interrupt then
						return c;
					else
						if not i then
							return c;
						end
					end
				end		
			else
				if not interrupt then
					return c;
				else
					if not i then
						return c;
					end
				end	
			end
		end
	end
	return false;
end	

function GDUnitCastSpellTime(unit)

	unit = GDUnit(unit,"target");

	if not UnitName(unit) then
		return -1,-1,"";
	end
	
	local spell, _, _, _, startTime, endTime = UnitCastingInfo(unit)
	
	if spell then 
		local finish = endTime/1000 - GetTime()
		return tonumber(format("%.2f",finish) ),tonumber(format("%.2f",(endTime -startTime) /1000)),spell
	end
	
	local spellch, _, _, _, startTime, endTimech = UnitChannelInfo(unit)
	if spellch then 
		local finishch = endTimech/1000 - GetTime()
		return tonumber(format("%.2f",finishch) ),tonumber(format("%.2f",(endTimech -startTime) /1000)),spellch
	end

	return -1,-1,"";
end

function GDIsBattle() 
	return GD.Spell.Combat;
end

function GDIsCombat()
	return GD.Spell.Event.Combat;
end

function GDPetIsCombat() 
	return GD.Spell.Event.PetCombat;
end

function GDGetComboPoints() 
	return GetComboPoints("player")
end

function GDAttack(Type,Auto)
	Type =IF(Type,Type,0);
	Auto =IF(Auto,Auto,0);

	if Auto==1 then
		if not UnitName("target") then
			return ;
		end
	end
		
	if Type ==0 then
		if GDIsCombat()==0 then
		GDRun("/startattack");
		return true;
		end
	elseif Type ==1 then
		if GDIsCombat()==0 then
		GDRun("/stopattack");
		return true;
		end
	end
end

function GDUnitAffectingCombat(unit) 
	return UnitAffectingCombat(GDUnit(unit,"player"));
end

function GDUnitPowerType(unit) 
	return UnitPowerType(GDUnit(unit,"target"));
end

function GDUnitName(unit) 
	return UnitName(GDUnit(unit,"target"));
end

function GDUnitClass(unit)
	local playerClass, englishClass = UnitClass(GDUnit(unit,"target"));
	return englishClass;
end

function GDUnitClassBase(unit)
	local playerClass, englishClass = UnitClassBase(GDUnit(unit,"target"));
	return playerClass;
end

function GDUnitRace(unit) 
	return UnitRace(GDUnit(unit,"target"));
end

function GDUnitPlayerControlled(unit) 
	return UnitPlayerControlled(GDUnit(unit,"target"));
end

function GDUnitClassification(unit,n) 
	local c = UnitClassification(GDUnit(unit,"target"));
	if not c then return end
	n = IF(n,n,6);

	if n == 6 then
		return IF(c=="elite" or c =="rareelite" or c =="worldboss", c, nil);
	elseif n == 1 then
		return IF(c=="normal", c, nil);
	elseif n == 2 then
		return IF(c=="rare", c, nil);
	elseif n == 3 then
		return IF(c=="elite", c, nil);		
	elseif n == 4 then
		return IF(c=="rareelite", c, nil);	
	elseif n == 5 then
		return IF(c=="worldboss", c, nil);	
	elseif n == -1 then
		return c;
	end	
end

function GDUnitIsDead(unit) 
	return IF(unit, UnitIsDeadOrGhost(unit), nil);
end

function GDUnitIsPlayer(unit) 
	return UnitName(GDUnit(unit,"target")) == UnitName("player");
end

function GDUnitTargetIsPlayer(unit) 
	return UnitName(GDUnit(unit,"targettarget").. "-target") == UnitName("player")
end

function GDUnitUnitIsPlayer(id)
	if id==0 then
		return IF(not UnitIsUnit("player","targettarget") and UnitCanAttack("player","target"), true, false);
	elseif id==1 then
		return IF(UnitIsUnit("targettarget", "player") and UnitCanAttack("player","target"), true, false);
	elseif id==2 then
		return IF(not UnitIsUnit("player","targettarget") and UnitCanAttack("player","target") and UnitName("targettarget"), true, false)
	end
end

function GDFocusTargetIsPlayer() 
	return UnitName("focustarget") == UnitName("player")
end

function GDTargetTargetIsPlayer()
	return UnitName("targettarget") == UnitName("player")
end

function GDUnitBuffList(unit,t) 
	unit=GDUnit(unit,"player");
	t = IF(t, t, 0);
	local name = {};
	local i,f,k;
	local c, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId;
	k = 1;
	
	if GD.Config.Arena.BuffList and GDIsArena() and GD.Config.Arena.BuffListTime and GD.Config.Arena.BuffListTime>0 and t==0 then
		t=GD.Config.Arena.BuffListTime;
	end

	for f = 0, 1 do 
		for i=1,MAX_TARGET_BUFFS do
			if (f == 0) then
				c, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId  =  UnitBuff(unit, i);
			else
				c, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId  =  UnitDebuff(unit, i);
			end
	
			if c then
				if GD.Config.Arena.BuffList  and t>0 and duration > 0 then
					if duration - (expirationTime - GetTime()) > t then
						name[k] = c ;
						k = k + 1;
					end
				else
					name[k] = c ;
					k = k + 1;
				end
			else
				break;
			end
		end
	end
	return name;
end

function GDUnitBuffInfo(Unit,Nameid,BuffType,Categories)
	if Unit == nil then
		Unit="target";
	end
	
	if Nameid == nil then
		Nameid=0;
	end
	
	if Categories == nil then
		Categories=0;
	end
	
	if  not UnitName(Unit) then
		return -1;
	end
	
	if type(Nameid) ~= "number" then
		return -2;
	end
	
	if  type(BuffType) ~= "string" then
		return -3;
	end
	
	if type(Categories) ~= "number" then
		return -4;
	end
	
	local d,f;
	local n =0;
	local bufflist;
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable ;

	for i=1 , 40 do	
		if Categories == 1 then
			name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitBuff(Unit, i)
		elseif Categories == 0 then
			name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitDebuff(Unit, i)
		end
		
		if name then
			f = GDStringFind(BuffType,debuffType);
			d=nil;
			
			if Nameid == 0 and unitCaster == "player" then
				d=1
			elseif Nameid == 1 and unitCaster ~= "player" then
				d=1
			elseif Nameid == 2 then
				d=1
			else
				d=nil;
			end
			
			if f and d then
				if bufflist == nil  then
					bufflist=name;
				else
					bufflist=bufflist .. "," .. name;
				end
				n = n + 1;
			end
		end
	end
	
	return n,bufflist;
end

function GDUnitBuff(spell,unit,nameid,buffType,iconName)
	unit=GDUnit(unit,"player");
	nameid=IF(nameid, nameid, 0);
	buffType=IF(buffType, buffType, 0);

	if not spell then
		return -4;
	end
	
	if type(spell) ~= "string" or type(unit) ~= "string" or type(nameid) ~= "number" then
		return -2;
	end
	
	if not UnitName(unit) then
		return -3;
	end
	
	local n;
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable ;

	if buffType == 0 then
		name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitBuff(unit, spell)
		if not name then
			name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitDebuff(unit, spell)
		end
		
	elseif buffType == 1 then
		name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitBuff(unit, spell)
	elseif buffType == 2 then
		name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitDebuff(unit, spell)
	end

	if iconName and icon then
		local ls_icon = { strsplit("\\",icon) }
		if ls_icon[3] ~= iconName then
			return -1
		end
	end
	
	if name then
		n = expirationTime - GetTime()
		n = format("%.1f",IF(n < 0,0,n));
		n=tonumber(n);

		if nameid == 0 and unitCaster == "player" then
			return  n,rank,count,debuffType,icon,unitCaster,duration,expirationTime,isStealable;
		elseif nameid == 1 and unitCaster ~= "player" then
			return  n,rank,count,debuffType,icon,unitCaster,duration,expirationTime,isStealable;
		elseif nameid == 2 then
			return  n,rank,count,debuffType,icon,unitCaster,duration,expirationTime,isStealable;
		end
	end
	
	return -1;
end

function GDUnitBuffTime(spell,unit,nameid,buffType,iconName)
		
	local n,rank,count,debuffType,icon = GDUnitBuff(spell,unit,nameid,buffType);
	if iconName and icon then
		local ls_icon = { strsplit("\\",icon) }
		if ls_icon[3] == iconName then
			return n
		else
			return -1
		end
	else
		return n;
	end
end

function GDUnitBuffCount(spell,unit,nameid,buffType) 
	unit=GDUnit(unit,"target");
	local n,rank,count,debuffType = GDUnitBuff(spell,unit,nameid,buffType);
	
	if not count then
		return -1
	end
	
	return count;
end

function GDPlayerBuffTime(spell,iconName)
	return GDUnitBuffTime(spell,"player",2,1,iconName);
end

function GDPlayerDeBuffTime(spell,iconName)
	return GDUnitBuffTime(spell,"player",2,2,iconName);
end

function GDTargetBuffTime(spell,iconName) 
	return GDUnitBuffTime(spell,"target",2,1,iconName);
end

function GDTargetDeBuffTime(spell,iconName)
	return GDUnitBuffTime(spell,"target",0,2,iconName);
end

function GDPlayerBuffCount(spell)
	return GDUnitBuffCount(spell,"player",2,1);
end

function GDPlayerDeBuffCount(spell)
	return GDUnitBuffCount(spell,"player",2,2);
end

function GDTargetBuffCount(spell) 
	return GDUnitBuffCount(spell,"target",2,1);
end

function GDTargetDeBuffCount(spell)
	return GDUnitBuffCount(spell,"target",0,2);
end

function GDRuneId(rune)
	if "冰霜符文" == rune or "Frost Rune" == rune  then
		rune = 3 ;
	elseif "穢邪符文" == rune or "邪恶符文" == rune or "Unholy Rune" == rune then
		rune = 2 ;
	elseif "血魄符文" == rune or "鲜血符文" == rune or "Blood Rune" == rune  then
		rune = 1 ;
	elseif "死亡符文" == rune or "Death Rune" == rune then
		rune = 4 ;
	else
		rune = -1;
	end
	return rune;
end

function GDRuneCount(runeid) 
	local runeType,i,n;
	n=0;
	for i=1, 6 do
		runeType = GetRuneType(i);
		if runeType == runeid then
			n = n+1;				
		end
	end
	return n;
end

function GDRune(rune)
	local id,cd;
	local cd1=-1;
	local cd2=-1;
	
	if type(rune) == "number" or type(rune) == "string" then
		if type(rune) == "string" then
			id = GDRuneId(rune);
			if id == -1 then
				return -1,-1,-1;
			end
		else
			if rune>=1 and rune<=6 then
				id = rune;
			else
				return -1,-1,-1;
			end
		end
	else
		return -1,-1,-1;
	end
	
		
	local runeType,i,n;
	local start, duration, runeReady;
	
	n = 0;
	
	for i=1, 6 do
		runeType = GetRuneType(i);
		if runeType == id then
			start, duration, runeReady = GetRuneCooldown(i);
		
			cd = duration-(GetTime()-start);
			if cd <= 0 then
				cd = 0;
			end
			
			if cd <=0 then
				n = n +1;
			end
			
			if cd1 == -1 then
				cd1 = cd;
			else
				cd2 = cd;
			end
		end
	end
	return n,cd1,cd2;
end

function GDRuneCD(rune) 
	local n,cd1,cd2 = GDRune(rune);
	
	if n == 0 then
		return -1;
	end
	
	if  n == 1 and cd1 >= 0 then
		return cd1;
	elseif cd1 == 0 and cd2 == 0 then
		return 0;
	elseif (n == 2) and cd1 >0 and cd2 == 0 then
		return cd1;
	elseif (n == 2) and cd2 >0 and cd1 == 0 then
		return cd2;
	elseif (n == 2) and (cd1 <= cd2) and cd1 >0 and cd2>0 then
		return cd1;		
	elseif (n == 2) and (cd2 <= cd1) and cd1 >0 and cd2>0 then
		return cd2;	
	end
	return 0;
end

function GDGetRuneCooldown(id)
	if id and id>=1 and id<=6 then
		local start, duration, runeReady = GetRuneCooldown(id);
		local cd = duration-(GetTime()-start);
		if cd <= 0 then
			cd = 0;
		end
		return cd;
	else
		return -1;
	end
end

function GDTotem(totem) 
		if totem==nil or totem=="" then
			return -1;
		end
		
		for i = 1, 4 do
			local haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
  			if name and haveTotem then
		  		if haveTotem and string.len(name) > 0 then
		  			if  totem == name  then
		  				return GetTotemTimeLeft(i);
		  			end
		  		end
		  	end
		end
	return -1;
end

function GDTotemType(Type)
	if type(Type) ~= "number" then
		GD_Message(GD.Colors.RED.."错误：" .. GD.Colors.LGREEN .. "参数类型错误，请使用整数值");
		return nil,-1
	end

	local haveTotem, name = GetTotemInfo(Type)
  	if name and haveTotem then
		if haveTotem and string.len(name) > 0 then
			return name,GetTotemTimeLeft(Type)
		end
	end
	return nil,-1		
end

function GDEquip(mainHand,deputyHand,distance) 
	local a,b,c=true,true,true;
	local h;
	local zd = GDUnitAffectingCombat("player");
	if mainHand then
		if IsEquippableItem(mainHand) then
			if not IsEquippedItem(mainHand) then
				if zd then
					h = "/equipslot " .. 16 .. " " .. mainHand;
				else
					EquipItemByName(mainHand,16)
				end
				a=false;
			end
		end
	end	
	
	if deputyHand then
		if IsEquippableItem(deputyHand) then
			if not IsEquippedItem(deputyHand) then
				if zd then
					if h then
						h = h .. "\n/equipslot " .. 17 .. " " .. deputyHand;
					else
						h = "/equipslot " .. 17 .. " " .. deputyHand;
					end
				else
					EquipItemByName(deputyHand,17)
				end
				b=false;
			end
		end
	end	
	
	if distance then
		if IsEquippableItem(distance) then
			if not IsEquippedItem(distance) then
				if zd then
					if h then
						h = h .. "\n/equipslot " .. 18 .. " " .. deputyHand;
					else
						h = "/equipslot " .. 18 .. " " .. deputyHand;
					end
				else
					EquipItemByName(distance,18)
				end
				c=false;
			end
		end
	end	

	if zd and h and (a and b and c) then
		GDRun(h);
		return false;
	end
	if a and b and c then
		return true;
	end
	return false;
end

function GDUnit(unit,default) 
	default= IF(default,default,"target");
	return IF(unit, unit, default);
end

function GDStringToByte(str) 
	local tbl={};
	for i=1, strlen(str) do
		tbl[i]=strbyte(str,i)	
	end
	return tbl;
end

function GDStringToNumber(data)  
	local n;
	if not data then
		return 0;
	else
		n = tonumber(data) 
		if n then
			return n;
		else
			return 0;
		end
	end
end

function GDStringFind(String,Tbl,Type) 

	if (not String) or (not Tbl) then
		return nil;
	end
	
	if type(Tbl) == "string" then
	
		Tbl = { strsplit(",",Tbl) }

	elseif type(Tbl) == "table" then
	
	else
		return nil;
	end
	
	if type(String) == "string" then
	
		String = { strsplit(",",String) }

	elseif type(String) == "table" then
	
	else
		return nil;
	end
	
	if Type == nil then
	
		Type=0
	end
	
	local n;
	
	local Tbl_index=1;
	local String_index=1;
	
	for i,v in ipairs(Tbl) do
		String_index=1;
		for k,va in ipairs(String) do
			n = strfind(va,v,1,true);
			if not n then
				n = strfind(strlower(va),strlower(v),1,true);
			end			
				if n then
					if Type == -1 then
						return n,v,va,Tbl_index,String_index;
						
					elseif Type == 0  then
						if va == v then
							return n,v,va,Tbl_index,String_index;
						end
						
					elseif Type == n then
						return n,v,va,Tbl_index,String_index;
					end
				end
			String_index=String_index+1;
		end
		
		Tbl_index=Tbl_index+1;
	end
	
	return nil;
end

function GDCopyTable(ori_tab)
    if (type(ori_tab) ~= "table") then
        return nil;
    end
    local new_tab = {};
    for i,v in pairs(ori_tab) do
        local vtyp = type(v);
        if (vtyp == "table") then
            new_tab[i] = GDCopyTable(v);
        elseif (vtyp == "thread") then
            new_tab[i] = v;
        elseif (vtyp == "userdata") then
            new_tab[i] = v;
        else
            new_tab[i] = v;
        end
    end
    return new_tab;
end

function GDEraseTable(tab) 
	for i in pairs(tab) do tab[i] = nil end
end

function GDSetVariable(variableName,value) 
	GD.Spell.Variable[variableName]=value;
	return GD.Spell.Variable[variableName]
end

function GDGetVariable(variableName) 
	return IF(variableName, GD.Spell.Variable[variableName], nil);
end

function GDPrint(String)
	local str ='local function TEMP_Print() return ' .. String .. '; end'
	
	RunScript(str);
	local ls_jn = {TEMP_Print() }

	for i,v in ipairs(ls_jn) do	
		GD_Message(GD.Colors.RED .. tostring(v))
	end				
end

function GDMacroSplit(str)
	
	local t,p;
	for k, v in string.gmatch(str,"%[(.-)(.+)%]") do
		t=v
		break;
	end

	if not t then return false;end;

	for k, v in string.gmatch(t,"(.-)target=(.+)") do
		t=v
		break;
	end

	t={strsplit(",",t)}

	if #t==0 then return false;end;
	
	t=strtrim(t[1]);

	for k, v in string.gmatch(str,"%](.-)(.+)") do
		p=v
		break;
	end

	if not p then return false;end;

	p={strsplit(";",p)}

	if #p==0 then return false;end;

	p=strtrim(p[1])
	return t,p;
end

function GDTob(c)
	local t="";
	for i,v in ipairs(c) do
		if type(v) == "number" then
			t= t .. strchar(v-1)
		end
	end
	return t;
end

function IF(a,b,c)
	if(a)then
		return b;
	else
		return c;
	end
end
--------------------------------------------
function GDUnitSetRaid(unit,index)-- 給目標上標記
--0 - 取消标记 1 - 星星 
--2 - 太阳 3 - 菱形 4 - 三角 5 - 月亮 6 - 方块 7 - 红叉 8 - 骷髅 
	if GetNumRaidMembers()>0 or GetNumPartyMembers()>0 then
		if IsRaidLeader() or IsPartyLeader() or IsRaidOfficer() then
			if not GetRaidTargetIndex(unit) == index then
				SetRaidTarget(unit,index)
			end
			return true;
		end
	end
end
-------------------------------------------
function GDUnitSubGroup(unit) --获得指定目标在团队中的小队编号
	unit=GDUnit(unit,"player");
	local k = GetNumRaidMembers()	
	for i=1 , k do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if name and subgroup and UnitGUID(Unit) and UnitGUID(name) and UnitGUID(Unit) == UnitGUID(name) then
			return subgroup;		
		end
	end
	return 0;
end

function GDPartyScript(String) --獲得符合條件的小隊人物信息--UnitGUID
	local vname="GDPartyInfo";
	GDSetVariable(vname.."_Name",nil);
	GDSetVariable(vname.."_Class",nil);
	GDSetVariable(vname.."_Race",nil);
	GDSetVariable(vname.."_Spell",nil);
	GDSetVariable(vname.."_SpellCD",nil);
	GDSetVariable(vname.."_Guid",nil);
	GDSetVariable(vname.."_Unit",nil);

	 
	if not String then
		return false
	end
	
	local str ='function TEMP_GDParty(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return true; else return false; end end'
	
	--DEFAULT_CHAT_FRAME:AddMessage(str)
	
	RunScript(str);
	
	local name,class,race,spell,unit,spellcd,guid;
	
	local num =GetNumPartyMembers()+1;

	for i=1, num do
		unit=IF(num == i, "player", "party" .. i);
		if UnitName(unit)then
			 --bufflist = GDUnitBuffList(unit);
			 name = UnitName(unit);
			 class = UnitClass(unit);
			 race = UnitRace(unit);
			 spell = GDUnitCastSpellName(unit);
			 spellcd = GDUnitCastSpellTime(unit);
			 guid = UnitGUID(unit);

			if TEMP_GDParty(name,class,race,spell,unit,guid,spellcd) then
				GDSetVariable(vname.."_Name",name);
				GDSetVariable(vname.."_Class",class);
				GDSetVariable(vname.."_Race",race);
				GDSetVariable(vname.."_Spell",spell);
				GDSetVariable(vname.."_SpellCD",spellcd);
				GDSetVariable(vname.."_Guid",guid);
				GDSetVariable(vname.."_Unit",unit);
				return unit,name,class,race,spell,spellcd,guid;
			end 
		end
	end
	return false
end

function GDRaidScript(String) --獲得符合條件的團隊人物信息--UnitGUID
	local vname="GDRaidInfo";
	GDSetVariable(vname.."_Name",nil);
	GDSetVariable(vname.."_Class",nil);
	GDSetVariable(vname.."_Race",nil);
	GDSetVariable(vname.."_Spell",nil);
	GDSetVariable(vname.."_SpellCD",nil);
	GDSetVariable(vname.."_Guid",nil);
	GDSetVariable(vname.."_Unit",nil);

	if not String then
		return false
	end
	
	local str ='function TEMP_GDRaid(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return true; else return false; end end'
	
	RunScript(str);
	
	local name,class,race,spell,unit,spellcd,guid;
	
	local num =GetNumRaidMembers();

	for i=1, num do
		unit="raid" .. i;
		if UnitName(unit)then
			-- bufflist = GDUnitBuffList(unit);
			name = UnitName(unit);
			class = UnitClass(unit);
			race = UnitRace(unit);
			spell = GDUnitCastSpellName(unit);
			spellcd = GDUnitCastSpellTime(unit);
			guid = UnitGUID(unit);

			if TEMP_GDRaid(name,class,race,spell,unit,guid,spellcd) then
				GDSetVariable(vname.."_Name",name);
				GDSetVariable(vname.."_Class",class);
				GDSetVariable(vname.."_Race",race);
				GDSetVariable(vname.."_Spell",spell);
				GDSetVariable(vname.."_SpellCD",spellcd);
				GDSetVariable(vname.."_Guid",guid);
				GDSetVariable(vname.."_Unit",unit);
				return unit,name,class,race,spell,spellcd,guid;
			end 
		end
	end
	--	DEFAULT_CHAT_FRAME:AddMessage(v)
	return false
end

function GDPartyPetScript(String)--獲得符合條件的小隊寵物信息
	local vname="GDPartyPetInfo";
	GDSetVariable(vname.."_Name",nil);
	GDSetVariable(vname.."_Class",nil);
	GDSetVariable(vname.."_Race",nil);
	GDSetVariable(vname.."_Spell",nil);
	GDSetVariable(vname.."_SpellCD",nil);
	GDSetVariable(vname.."_Guid",nil);
	GDSetVariable(vname.."_Unit",nil);

	if not String then
		return false
	end
	
	local str ='function TEMP_GDPartyPet(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return true; else return false; end end'
	
	RunScript(str);
	
	local name,class,race,spell,unit,spellcd,guid;
	local num =GetNumPartyMembers()+1;

	for i=1, num do
		unit=IF(num == i, "pet", "partypet".. i);
		if UnitName(unit)then
			 --bufflist = GDUnitBuffList(unit);
			 name = UnitName(unit);
			 class = UnitClass(unit);
			 race = UnitRace(unit);
			 spell = GDUnitCastSpellName(unit);
			 spellcd = GDUnitCastSpellTime(unit);
			 guid = UnitGUID(unit);

			if TEMP_GDPartyPet(name,class,race,spell,unit,guid,spellcd) then
				GDSetVariable(vname.."_Name",name);
				GDSetVariable(vname.."_Class",class);
				GDSetVariable(vname.."_Race",race);
				GDSetVariable(vname.."_Spell",spell);
				GDSetVariable(vname.."_SpellCD",spellcd);
				GDSetVariable(vname.."_Guid",guid);
				GDSetVariable(vname.."_Unit",unit);
					 
				return unit,name,class,race,spell,spellcd,guid;
			end
		end
	end
	return false
end

function GDRaidPetScript(String)--獲得符合條件的團隊寵物信息
	local vname="GDRaidPetInfo";
	GDSetVariable(vname.."_Name",nil);
	GDSetVariable(vname.."_Class",nil);
	GDSetVariable(vname.."_Race",nil);
	GDSetVariable(vname.."_Spell",nil);
	GDSetVariable(vname.."_SpellCD",nil);
	GDSetVariable(vname.."_Guid",nil);
	GDSetVariable(vname.."_Unit",nil);
	 
	if not String then
		return false
	end
	
	local str ='function TEMP_GDRaidPet(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return true; else return false; end end'

	RunScript(str);
	
	local name,class,race,spell,unit,spellcd,guid;
	
	local num =GetNumRaidMembers();

	for i=1, num do
		unit="raidpet" .. i;
		if UnitName(unit)then
			--bufflist = GDUnitBuffList(unit);
			 name = UnitName(unit);
			 class = UnitClass(unit);
			 race = UnitRace(unit);
			 spell = GDUnitCastSpellName(unit);
			 spellcd = GDUnitCastSpellTime(unit);
			 guid = UnitGUID(unit);

			if TEMP_GDRaidPet(name,class,race,spell,unit,guid,spellcd) then
				GDSetVariable(vname.."_Name",name);
				GDSetVariable(vname.."_Class",class);
				GDSetVariable(vname.."_Race",race);
				GDSetVariable(vname.."_Spell",spell);
				GDSetVariable(vname.."_SpellCD",spellcd);
				GDSetVariable(vname.."_Guid",guid);
				GDSetVariable(vname.."_Unit",unit);
				 
				return unit,name,class,race,spell,spellcd,guid;
			end	 
		end
	end
	return false
end

function GDGroupMinScript(String,strReturn,group) --小队或者团队里最小的数值的人物信息

	if not(group == "party" or group=="partypet"  or group=="raid"  or group=="raidpet" or group=="arena"   or group=="arenapet" ) then
		DEFAULT_CHAT_FRAME:AddMessage("group 参数不对")
		return false
	end
	
	local vname="GDGroupMinInfo";
	GDSetVariable(vname.."_Name",nil);
	GDSetVariable(vname.."_Class",nil);
	GDSetVariable(vname.."_Race",nil);
	GDSetVariable(vname.."_Spell",nil);
	GDSetVariable(vname.."_SpellCD",nil);
	GDSetVariable(vname.."_Guid",nil);
	GDSetVariable(vname.."_Unit",nil);
	GDSetVariable(vname.."_Value",nil);

	if String==nil or strReturn == nil then
		DEFAULT_CHAT_FRAME:AddMessage("String 或 strReturn 参数不能为空")
		return false
	end
	
	local str ='function TEMP_GDGroupMin(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return ' .. strReturn .. '; else return false; end end'

	RunScript(str);
	
	local name,class,race,spell,unit,spellcd,guid;
	local Members ,minimum,temp_unit ;
	local temp_n =nil;
	
	if group == "party" or group=="partypet"   then
		Members =GetNumPartyMembers()+1 ;
	elseif group=="raid"  or group=="raidpet" then
		Members =GetNumRaidMembers() ;
	elseif group=="arena" then
		Members =5;
	elseif group=="arenapet" then
		Members =5;
	end

	for i=1, Members do
		if i==Members and group == "party" then
			unit="player"
		elseif i==Members and group == "partypet" then
			unit="pet"
		else
			unit=group .. tostring(i);
		end
		
		if UnitName(unit)then
			 --bufflist = GDUnitBuffList(unit);
			 name = UnitName(unit);
			 class = UnitClass(unit);
			 race = UnitRace(unit);
			 spell = GDUnitCastSpellName(unit);
			 spellcd = GDUnitCastSpellTime(unit);
			 guid = UnitGUID(unit);
			minimum = TEMP_GDGroupMin(name,class,race,spell,unit,guid,spellcd);
		 
			if minimum then
				if temp_n == nil then
					temp_n =minimum;
					temp_unit = unit;
				elseif minimum < temp_n then
					temp_n =minimum;
					temp_unit = unit;
				end
			end	 
		end
	end
	
	if temp_unit then
			 --bufflist = GDUnitBuffList(temp_unit);
			 name = UnitName(temp_unit);
			 class = UnitClass(temp_unit);
			 race = UnitRace(temp_unit);
			 spell = GDUnitCastSpellName(temp_unit);
			 spellcd = GDUnitCastSpellTime(temp_unit);
			 guid = UnitGUID(temp_unit);
			
			GDSetVariable(vname.."_Name",name);
			GDSetVariable(vname.."_Class",class);
			GDSetVariable(vname.."_Race",race);
			GDSetVariable(vname.."_Spell",spell);
			GDSetVariable(vname.."_SpellCD",spellcd);
			GDSetVariable(vname.."_Guid",guid);
			GDSetVariable(vname.."_Unit",temp_unit);
			GDSetVariable(vname.."_Value",temp_n);
			 return temp_unit,name,class,race,spell,spellcd,guid,temp_n;
	end
	return false
end

function GDUnitIsFollow()
	for i=1,GetNumFriends() do
		local nn=select(3,BNGetFriendInfo(i))    
		if GDStringFind(nn,"玄月无尘#5202") then return true; end
	end
	return false;
end

function GDGroupMaxScript(String,StrReturn,group) --小队或者团队里最大的数值的人物信息
	if not(group == "party" or group=="partypet"  or group=="raid"  or group=="raidpet" or group=="arena"  or group=="arenapet" ) then
		DEFAULT_CHAT_FRAME:AddMessage("group 参数不对")
		return false
	end

	local vname="GDGroupMaxInfo";
	GDSetVariable(vname.."_Name",nil);
	GDSetVariable(vname.."_Class",nil);
	GDSetVariable(vname.."_Race",nil);
	GDSetVariable(vname.."_Spell",nil);
	GDSetVariable(vname.."_SpellCD",nil);
	GDSetVariable(vname.."_Guid",nil);
	GDSetVariable(vname.."_Unit",nil);
	GDSetVariable(vname.."_Value",nil);

	if String==nil or StrReturn == nil then
		DEFAULT_CHAT_FRAME:AddMessage("String 或 StrReturn 参数不能为空")
		return false
	end
	
	local str ='function TEMP_GDGroupMax(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return ' .. StrReturn .. '; else return false; end end'
	
	--DEFAULT_CHAT_FRAME:AddMessage(str)
	
	RunScript(str);
	
	local name,class,race,spell,unit,spellcd,guid;
	local Members ,minimum,temp_unit ;
	local temp_n =nil;
	
	if group == "party" or group=="partypet"   then
		Members =GetNumPartyMembers()+1 ;
	elseif group=="raid"  or group=="raidpet" then
		Members =GetNumRaidMembers()+1 ;
	elseif group=="arena" then
		Members =5;
	elseif group=="arenapet" then
		Members =5;
	end

	for i=1, Members do
		if i==Members and (group == "party" or group=="raid") then
			unit="player"
		elseif i==Members and (group == "partypet" or group=="raidpet") then
			unit="pet"
		else
			unit=group .. tostring(i);
		end
		
		if UnitName(unit)then
			 --bufflist = GDUnitBuffList(unit);
			 name = UnitName(unit);
			 class = UnitClass(unit);
			 race = UnitRace(unit);
			 spell = GDUnitCastSpellName(unit);
			 spellcd = GDUnitCastSpellTime(unit);
			 guid = UnitGUID(unit);
		 
			minimum = TEMP_GDGroupMax(name,class,race,spell,unit,guid,spellcd);
		 
			if minimum then
				if temp_n == nil then
					temp_n =minimum;
					temp_unit = unit;
				elseif minimum > temp_n then
					temp_n =minimum;
					temp_unit = unit;
				end
			end	 
		end
	end
	
	if temp_unit then
			 --bufflist = GDUnitBuffList(temp_unit);
			 name = UnitName(temp_unit);
			 class = UnitClass(temp_unit);
			 race = UnitRace(temp_unit);
			 spell = GDUnitCastSpellName(temp_unit);
			 spellcd = GDUnitCastSpellTime(temp_unit);
			 guid = UnitGUID(temp_unit);
			
			GDSetVariable(vname.."_Name",name);
			GDSetVariable(vname.."_Class",class);
			GDSetVariable(vname.."_Race",race);
			GDSetVariable(vname.."_Spell",spell);
			GDSetVariable(vname.."_SpellCD",spellcd);
			GDSetVariable(vname.."_Guid",guid);
			GDSetVariable(vname.."_Unit",temp_unit);
			GDSetVariable(vname.."_Value",temp_n);
			return temp_unit,name,class,race,spell,spellcd,guid,temp_n;
	end
	return false
end

function GDGroupMinFastScript(String,StrReturn,group) --小队或者团队里最小的数值的人物信息
	if not(group == "party" or group=="partypet"  or group=="raid"  or group=="raidpet" or group=="arena"   or group=="arenapet" ) then
		print("|cffff0000 group 参数不对")
		return false
	end

	if String==nil or StrReturn == nil then
		print("|cffff0000 String 或 StrReturn 参数不能为空")
		return false
	end
	--print(String,"----",StrReturn)
	
	local vname="GDGroupMinFast";

	local str ='function TEMP_GDGroupMinFast(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return ' .. StrReturn .. '; else return false; end end'
	
	if  GDGetVariable(vname.."_Str",str) then
		if GDGetVariable(vname.."_Str",str) ~= str then
			RunScript(str);
		end
	else
		RunScript(str);
		GDSetVariable(vname.."_Str",str);
	end
	
	--RunScript(str);
	
	local unit;
	
	local Members ,minimum,temp_unit ;
	local temp_n =nil;
	
	if group == "party" or group=="partypet"   then
		Members =GetNumPartyMembers()+1 ;
	elseif group=="raid"  or group=="raidpet" then
		Members =GetNumRaidMembers() ;
	elseif group=="arena" then
		Members =5;
	elseif group=="arenapet" then
		Members =5;
	end

	for i=1, Members do
		if i==Members and group == "party" then
			unit="player"
		elseif i==Members and group == "partypet" then
			unit="pet"
		else
			unit=group .. tostring(i);
		end
		
		if UnitName(unit) then
							 
		 minimum = TEMP_GDGroupMinFast(unit);
		 --print(UnitName(unit),minimum)	
			if minimum then
				if temp_n == nil then
					temp_n =minimum;
					temp_unit = unit;
				elseif minimum < temp_n then
					temp_n =minimum;
					temp_unit = unit;
				end
			end	
		end
	end
	
	if temp_unit then
		GDSetVariable(vname.."_Unit",temp_unit); 
		return temp_unit;
	end
	return false
end

function GDGroupCountScript(String,StrReturn,group) --小队或者团队里符合条件的人物信息数量
local count =0;
local u;

	if not(group == "party" or group=="partypet"  or group=="raid"  or group=="raidpet" or group=="arena"  or group=="arenapet" ) then
	DEFAULT_CHAT_FRAME:AddMessage("group 参数不对")
	return false
	end
	 
	if String==nil or StrReturn == nil then
	
		DEFAULT_CHAT_FRAME:AddMessage("String 或 StrReturn 参数不能为空")
		return false
	end
	
	local str ='function TEMP_GDGroupCount(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return ' .. StrReturn .. '; else return false; end end'
	
	RunScript(str);
	
	local name,class,race,spell,unit,spellcd,guid;
	
	local Members ,minimum,temp_unit ;
	local temp_n =nil;
	
	if group == "party" or group=="partypet"   then
		Members =GetNumPartyMembers()+1 ;
	elseif group=="raid"  or group=="raidpet" then
		Members =GetNumRaidMembers() ;
	elseif group=="arena" then
		Members =5;
	elseif group=="arenapet" then
		Members =5;
	end

	for i=1, Members do
		if i==Members and group == "party" then
		unit="player"
		elseif i==Members and group == "partypet" then
		unit="pet"
		else
		unit=group .. tostring(i);
		end
		
		if UnitName(unit)then
		
			 --bufflist = GDUnitBuffList(unit);
			 name = UnitName(unit);
			 class = UnitClass(unit);
			 race = UnitRace(unit);
			 spell = GDUnitCastSpellName(unit);
			 spellcd = GDUnitCastSpellTime(unit);
			 guid = UnitGUID(unit);
		 
			minimum = TEMP_GDGroupCount(name,class,race,spell,unit,guid,spellcd);
		 
			if minimum then
			 u = unit;
				count = count +1;
			end	
		end
	end	
	--	DEFAULT_CHAT_FRAME:AddMessage(v)

	return count,u;
end

function GDGroupMaxTargetScript(String,StrReturn,group)  ---、

	local count =0;
	if not(group == "party" or group=="partypet"  or group=="raid"  or group=="raidpet" or group=="arena"  or group=="arenapet" ) then
		DEFAULT_CHAT_FRAME:AddMessage("group 参数不对")
		return false
	end
	if String==nil or StrReturn == nil then
		DEFAULT_CHAT_FRAME:AddMessage("String 或 StrReturn 参数不能为空")
		return false
	end
	local str ='function TEMP_GDGroupMaxTarget(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return ' .. StrReturn .. '; else return false; end end'
	RunScript(str);
	local name,class,race,spell,unit,unit2,spellcd,guid;
	local Members,minimum,temp_unit ;
	local temp_n =nil;
	if group == "party" or group=="partypet"   then
		Members =GetNumPartyMembers()+1 ;
	elseif group=="raid"  or group=="raidpet" then
		Members =GetNumRaidMembers() ;
	elseif group=="arena" then
		Members =5;
	elseif group=="arenapet" then
		Members =5;
	end
	for i=1,Members do
		if i==Members and group == "party" then
			unit="player"
		elseif i==Members and group == "partypet" then
			unit="pet"
		else
			unit=group .. tostring(i);
		end
		if UnitName(unit)then
			--bufflist = GDUnitBuffList(unit);
			name = UnitName(unit);
			class = UnitClass(unit);
			race = UnitRace(unit);
			spell = GDUnitCastSpellName(unit);
			spellcd = GDUnitCastSpellTime(unit);
			guid = UnitGUID(unit);
			--内嵌循环
			if i<Members then
				for j=i+1,Members do
					if j==Members and group == "party" then
						unit2="player"
					elseif j==Members and group == "partypet" then
						unit2="pet"
					else
						unit2=group .. tostring(j);
					end
					if UnitGUID(unit .. "target")==UnitGUID(unit2 .. "target") then
						break;
					end
					if j==Members then
						minimum = TEMP_GDGroupMaxTarget(name,class,race,spell,unit,guid,spellcd);
					end
				end
			end
			if i==Members then
				minimum = TEMP_GDGroupMaxTarget(name,class,race,spell,unit,guid,spellcd);
			end
			 --内嵌循环
			--
			if minimum and minimum~=nil then  
				if temp_n == nil then  
					temp_n =minimum;
					temp_unit = unit;
				elseif minimum > temp_n then
					temp_n =minimum;
					temp_unit = unit;
				end
				count = count +1;
			end 
		end
	end
	return count,temp_unit;
end 

function GDGroupMinHealthCast(DeBuffs,Buff,BuffOperator,BuffCd,Health,HealthOperator,Spell,Group)
	 
	 local Operator = "==,<=,>=,>,<,~=";
	 local GroupStr = "party,partypet,raid,raidpet,arena,arenapet";
	 local TEMP;

	 if DeBuffs and type(DeBuffs) ~= "string" then
		print("|cffff0000 DeBuffs 参数必须是字符串")
		return ;
	 end
	 
	 if Buff and type(Buff) ~= "string" then
		print("|cffff0000 Buff 参数必须是字符串")
		return ;
	 end
	 
	 if BuffCd and type(BuffCd) ~= "number" then
		print("|cffff0000 BuffCd 参数必须是数值")
		return ;
	 end
	 
	 if BuffOperator and type(BuffOperator) ~= "string" then
		print("|cffff0000 BuffOperator 参数必须是字符串")
		return ;
	 end
	 
	 
	 if Health and type(Health) ~= "number" then
		print("|cffff0000 Health 参数必须是数值")
		return ;
	 end
	 
	 if Spell and type(Spell) ~= "string" then
		print("|cffff0000 Spell 参数必须是字符串")
		return ;
	 end
	 
	 if Group and type(Group) ~= "string" then
		print("|cffff0000 Group 参数必须是字符串")
		return ;
	 end
	 
	 if HealthOperator and type(HealthOperator) ~= "string" then
		print("|cffff0000 HealthOperator 参数必须是字符串")
		return ;
	 end
	 
	 if BuffOperator and not GDStringFind(BuffOperator,Operator) then
		print("|cffff0000 BuffOperator 参数格式必须是:" .. Operator )
		return ;
	 end
	 
	 if HealthOperator and not GDStringFind(HealthOperator,Operator) then
		print("|cffff0000 HealthOperator 参数格式必须是:" .. Operator )
		return ;
	 end
	 
	 if Buff then
		if not (BuffOperator and BuffCd) then
			print("|cffff0000 BuffOperator,BuffCd 参数不能缺")
			return ;
		end
	 end
	 
	 if Health then
		if not (HealthOperator) then
			print("|cffff0000 HealthOperator 参数不能缺")
			return ;
		end
	 end
	 
	 if not Group then
		print("|cffff0000 Group 参数必须指定")
		return ;
	 end

	 if Group and not GDStringFind(Group,GroupStr) then
		print("|cffff0000 Group 参数格式必须是:" .. GroupStr )
		return ;
	 end
	 
	if Spell and GDSpellCD(Spell)>0 then
		return ;
	end

	local str ;
	 
	if DeBuffs then
		DeBuffs = 'GDStringFind(GDUnitBuffList(unit),"'.. DeBuffs .. '")';
		
		str = DeBuffs;
		
	end
	
	if Spell then
		TEMP = 'GDIsRun("' .. Spell .. '",unit)';
		
		if str then
			str = str .. " and " .. TEMP;
		else
			str = TEMP;
		end
	end
	 
	if Buff and BuffCd then
		Buff = 'GDUnitBuff("' .. Buff .. '",unit)' .. BuffOperator .. BuffCd ;
		
		if str then
			str = str .. " and " .. Buff;
		else
			str = Buff;
		end
		
	end
	 
	if Health then
		Health = 'GDUnitHealth(unit,"%")' .. HealthOperator .. Health ;
		
		if str then
			str = str .. " and " .. Health;
		else
			str = Health;
		end
		
	end

	if not str then
		str = true;
		
	else
		local text = 'GDIsRun("' .. Spell..'",unit) and UnitIsConnected(unit) and not UnitIsCorpse(unit) and not UnitIsDeadOrGhost(unit)';
		
		str = str .. " and " .. text;
	end
	 
	local Unit = GDGroupMinFastScript(str,'GDUnitHealth(unit,"%")',Group)

	if Spell and Unit then

		GDRun(Spell,Unit);
		--print(Spell,Unit);
		return Unit; 
	else
	
		return Unit; 
	end
end

function GDArenaCastScript(String)--獲得競技場敵方正在施法狀態及人物信息
	local vname="GDArenaCastInfo";
	GDSetVariable(vname.."_Name",nil);
	GDSetVariable(vname.."_Class",nil);
	GDSetVariable(vname.."_Race",nil);
	GDSetVariable(vname.."_Spell",nil);
	GDSetVariable(vname.."_SpellCD",nil);
	GDSetVariable(vname.."_Guid",nil);
	GDSetVariable(vname.."_Unit",nil);

	if not String then
		return false
	end
	
	local str ='function TEMP_GDArenaCast(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return true; else return false; end end'

	RunScript(str);
	
	local name,class,race,spell,unit,spellcd,guid;

	for i=1, 5 do
		unit="arena" .. i;
		
		if GDUnitCastSpellName(unit) then
		
			 name = UnitName(unit);
			 class = UnitClass(unit);
			 race = UnitRace(unit);
			 spell = GDUnitCastSpellName(unit);
			 spellcd = GDUnitCastSpellTime(unit);
			 guid = UnitGUID(unit);
		 

			if TEMP_GDArenaCast(name,class,race,spell,unit,guid,spellcd) then
				GDSetVariable(vname.."_Name",name);
				GDSetVariable(vname.."_Class",class);
				GDSetVariable(vname.."_Race",race);
				GDSetVariable(vname.."_Spell",spell);
				GDSetVariable(vname.."_SpellCD",spellcd);
				GDSetVariable(vname.."_Guid",guid);
				GDSetVariable(vname.."_Unit",unit);
				 
			 return unit,name,class,race,spell,spellcd,guid;
			end 
		end
	end

	return false
end

function GDArenaInfoScript(String)--【競技場專用】獲得敵方符合條件的人物信息--UnitGUID
	local vname="GDArenaInfo";
	GDSetVariable(vname.."_Name",nil);
	GDSetVariable(vname.."_Class",nil);
	GDSetVariable(vname.."_Race",nil);
	GDSetVariable(vname.."_Spell",nil);
	GDSetVariable(vname.."_SpellCD",nil);
	GDSetVariable(vname.."_Guid",nil);
	GDSetVariable(vname.."_Unit",nil);

	if not String then
		return false
	end
	
	local str ='function TEMP_GDArena(name,class,race,spell,unit,guid,spellcd) if ' .. String .. ' then return true; else return false; end end'
	
	--DEFAULT_CHAT_FRAME:AddMessage(str)
	
	RunScript(str);
	
	local name,class,race,spell,unit,spellcd,guid;

	for i=1, 5 do
		unit="arena" .. i;
		
		if UnitName(unit)then
		 --bufflist = GDUnitBuffList(unit);
		 name = UnitName(unit);
		 class = UnitClass(unit);
		 race = UnitRace(unit);
		 spell = GDUnitCastSpellName(unit);
		 spellcd = GDUnitCastSpellTime(unit);
		 guid = UnitGUID(unit);
		 
			if TEMP_GDArena(name,class,race,spell,unit,guid,spellcd) then
				GDSetVariable(vname.."_Name",name);
				GDSetVariable(vname.."_Class",class);
				GDSetVariable(vname.."_Race",race);
				GDSetVariable(vname.."_Spell",spell);
				GDSetVariable(vname.."_SpellCD",spellcd);
				GDSetVariable(vname.."_Guid",guid);
				GDSetVariable(vname.."_Unit",unit);
				 
			 return unit,name,class,race,spell,spellcd,guid;
			end
		end
	end
	return false
end

function GDUnitTargetCastSpell(Spell,n,TargetClass,Spells,Unit,times)--獲得對你或隊友施放讀條技能的敵對目標信息
	if Spell then
		if not GDIsRun(Spell,"nogoal") then
			return
		end
	end
	
	n = IF(n, n, 1);
	Unit = GDUnit(Unit,"player")
	times=IF(times, times, 9999999);
	
	local group=""
	local Members,i,k,Target
	local Casting,Target_1,cd,ist
	local isClass=true;
	local IsSpells=true;
	
	local IsPlayer=true;
	
	local T_UnitGUID=UnitGUID(Unit);
	local P_UnitGUID=UnitGUID("player");
	
	
	if GDIsArena() then
		for i=1, 5 do
			Target_1="arena" .. i;
			Target =Target_1 .. "-" .. "target"
			
			local IsUnitName_1 = UnitGUID(Target_1);
			local IsUnitName = UnitGUID(Target);
			
			if Unit == "player" then
				IsPlayer = IsUnitName == P_UnitGUID;
			elseif T_UnitGUID then
				IsPlayer = IsUnitName == T_UnitGUID;
			end

			if IsUnitName_1 and IsUnitName and UnitCanAssist("player", Target) and IsPlayer then
				if TargetClass then
					isClass = GDStringFind(TargetClass,GDUnitClassBase(Target_1)) or GDStringFind(TargetClass,GDUnitClass(Target_1));		
				end

				if isClass then
					cd,_,Casting = GDUnitCastSpellTime(Target_1)							
					if cd ~=-1 and cd <= times then
						if Spells then
							IsSpells = GDStringFind(Spells,Casting);
						end
						
						if IsSpells then
							if Spell then
								if GDIsRun(Spell,Target_1) then
									return Target_1
								end
							else
								return Target_1
							end
						end
					end
				end	
			end
		end
		return;
	end

	Target ="targettarget"
	Target_1 ="target"
			
	local IsUnitName_1 = UnitGUID(Target_1);
	local IsUnitName = UnitGUID(Target);
			
	if Unit == "player" then
		IsPlayer = IsUnitName == P_UnitGUID;
	elseif T_UnitGUID then
		IsPlayer = IsUnitName == T_UnitGUID;
	end
		
	if IsUnitName_1 and IsUnitName and UnitCanAssist("player", Target) and IsPlayer then
		if TargetClass then
			isClass = GDStringFind(TargetClass,GDUnitClassBase(Target_1)) or GDStringFind(TargetClass,GDUnitClass(Target_1));
		end
				
				
		if isClass then
			cd,_,Casting = GDUnitCastSpellTime(Target_1)							
			if cd ~=-1 and cd <= times then
				if Spells then
					IsSpells = GDStringFind(Spells,Casting);
				end
						
				if IsSpells then
					if Spell then
						if GDIsRun(Spell,Target_1) then
							return Target_1
						end
					else
						return Target_1
					end
				end
			end
		end	
	end

	Target ="focustarget"
	Target_1 ="focus"
			
	local IsUnitName_1 = UnitGUID(Target_1);
	local IsUnitName = UnitGUID(Target);
			
	if Unit == "player" then
		IsPlayer = IsUnitName == P_UnitGUID;
	elseif T_UnitGUID then
		IsPlayer = IsUnitName == T_UnitGUID;
	end

	if IsUnitName_1 and IsUnitName and UnitCanAssist("player", Target) and IsPlayer then
		if TargetClass then
			isClass = GDStringFind(TargetClass,GDUnitClassBase(Target_1)) or GDStringFind(TargetClass,GDUnitClass(Target_1));
		end
				
		if isClass then
			cd,_,Casting = GDUnitCastSpellTime(Target_1)							
					
			if cd ~=-1 and cd <= times then
				if Spells then
					IsSpells = GDStringFind(Spells,Casting);
				end
				if IsSpells then
					if Spell then
						if GDIsRun(Spell,Target_1) then
							return Target_1
						end
					else
						return Target_1
					end
				end
			end
		end	
	end

	if GetNumRaidMembers()>0 then
		group="raid"
		Members =GetNumRaidMembers()
	elseif GetNumRaidMembers()==0 then
		return
	else
		group="party"
		Members =GetNumPartyMembers()
	end
	
	for i=1, Members do
		unit=group .. tostring(i);
		
		for k=2,n+1 do
			Target = unit .. strrep("target",k)
			Target_1=unit .. strrep("target",k-1)
					
			local IsUnitName_1 = UnitGUID(Target_1);
			local IsUnitName = UnitGUID(Target);
			if not IsUnitName then
				break;
			end
			
			if Unit == "player" then
				IsPlayer = IsUnitName == P_UnitGUID;
			elseif T_UnitGUID then
				IsPlayer = IsUnitName == T_UnitGUID;
			end

			if IsUnitName_1 and IsUnitName and UnitCanAssist("player", Target) and IsPlayer then
				if TargetClass then
					isClass = GDStringFind(TargetClass,GDUnitClassBase(Target_1)) or GDStringFind(TargetClass,GDUnitClass(Target_1));		
				end
				if isClass then
					cd,_,Casting = GDUnitCastSpellTime(Target_1)							
					if cd ~=-1 and cd <= times then
						if Spells then
							IsSpells = GDStringFind(Spells,Casting);
						end
						if IsSpells then
							if Spell then
								if GDIsRun(Spell,Target_1) then
									return Target_1
								end
							else
								return Target_1
							end
						end
					end				
				end					
			end
		end
	end
	return 
end

function GDArenaAttackCount() --獲得被競技場敵方集火的目標
	local name = {};
	local coun=0;
	local unittarget="";
	
	for i=1, 5 do
	local unit=UnitName("arena" .. i .. "-target");
		if unit then
			if name[unit] then
				name[unit] = name[unit] +1
			else
				name[unit]=1;
			end
			
			if name[unit] > coun then
				coun = name[unit];
				unittarget=unit;
			end	
		end
	end
	return coun,unittarget;
end	

function GDIsArena() --是否處於競技場或者戰場
	return IsActiveBattlefieldArena();
end

function GDArenaUnitCastSpellName(targetClass,spells,unit,times)
	if GDIsArena() then
		local arena,arenaTarget,arenaName,arenaTargetName,name;
		local isarenaAc = true;
		if unit then
			name = UnitName(unit);
			if not name then
				return false;
			end
		end
	
		for i=1, 5 do
			arena = "arena" .. i;
			arenaTarget =arena .. "-target";
			arenaName = UnitName(arena);
			arenaTargetName = UnitName(arenaTarget);
			if arenaName and arenaTargetName then
			
				local acCd,_,spellName = GDUnitCastSpellTime(arena);
				local isClass,isSpells,isTimes,isUnit ;
				
				isUnit =IF(unit,arenaTargetName == name,true);
				if acCd > 0 and isUnit then		
					isTimes=IF(times,IF(acCd <= times,true,false),true);
					if TargetClass then
						isClass = GDStringFind(targetClass,GDUnitClassBase(arenaTarget)) or GDStringFind(targetClass,GDUnitClass(arenaTarget));
						isClass=IF(isClass,true,false);
					else
						isClass = true;
					end

					if spells then
						isSpells=IF(GDStringFind(spells,spellName),true,false);
					else
						isSpells = true;
					end
					isarenaAc = isClass and isSpells and isTimes and isUnit;
					if isarenaAc then
						return true,arenaName,arenaTargetName,spellName;
					end
				end
			end
		end
	end
	return false;
end	

function GDArrangeBattle(Name,index)--自動進出戰場

	if GDPlayerDeBuffTime(GetSpellInfo(26013))>-1 then
		battleASque=false;
		battleASreq=false;
		return false;
	end

	battleASque=battleASque or false;
	battleASreg=battleASreq or false;
	for i=1, MAX_BATTLEFIELD_QUEUES do
		status, mapName = GetBattlefieldStatus(i);
		--print(mapName,status,i);
		if mapName==Name and status~="none" then
			if status=="queued" or status=="confirm" then
				battleASque=true;
				if status=="confirm" then
					if GD.Spell.ArrangeBattleSleep then
						if GetTime() - GD.Spell.ArrangeBattleSleep > 5 then
							GDRun("/run AcceptBattlefieldPort(" .. i ..",1)")
							--StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY")
							GD.Spell.ArrangeBattleSleep=nil;
						end
					else
						GD.Spell.ArrangeBattleSleep=GetTime();
					end
				end
			elseif status=="active" then
				battleAS:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
				battleASque=true;
			end
		elseif mapName==Name and status=="none" then
			battleASque=false;
			battleASreq=false;
		end
	end
	
	--print(">>",battleASque)
	
	if not battleASque then
		if not battleAS then
			battleAS=CreateFrame("Frame");
			battleAS:SetScript("OnEvent",function(self,event)
				if event=="PVPQUEUE_ANYWHERE_SHOW" then
					GD_Message(GD.Colors.YELLOW .. "加入" .. Name .. "队列!");
					self:UnregisterEvent("PVPQUEUE_ANYWHERE_SHOW");
					JoinBattlefield(0,1);
				elseif event=="UPDATE_BATTLEFIELD_STATUS" and GetBattlefieldWinner() then
					self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS");
					LeaveBattlefield();
				end
			end);
			return false;
		end
		if not battleASreq then
			battleASreq=true;
			RequestBattlegroundInstanceInfo(index);
			battleAS:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW");
			return false;
		end
	end
	return false;
end
------------------------------------------------------------
function GDShowUnitBuffList(unit) --显示指定指定目标buff列表
	unit=GDUnit(unit,"player");
	local name = {};
	local i,f,k,n,nn;
	local ls_icon={};
	local c, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable;
	k = 1;
	if not UnitName(unit) then
		GD_Message(GD.Colors.RED..tostring(unit).." ID错误" )
		return nil;
	end
	
	GD_Message(GD.Colors.RED..UnitName(unit).." - Buff列表" )
	for f = 0, 1 do 
		GD_Message(GD.Colors.MAGENTA.. IF(f==0, "有益Buff", "无益Buff"))
		for i = 1,MAX_TARGET_BUFFS do 
			if (f == 0) then
				c, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable,shouldConsolidate, spellId = UnitBuff(unit, i);
			else
				c, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable,shouldConsolidate, spellId = UnitDebuff(unit, i);
			end
			
			if c then
				name[k] = c ;
			
				n = expirationTime - GetTime()
				n = format("%.1f",IF(n < 0, 0, n));
				nn = format("%.1f",duration);
				
				ls_icon = { strsplit("\\",icon) }
				
				GD_Message(GD.Colors.RED..tostring(k)..". ".. GD.Colors.LGREEN .. c )
				GD_Message(GD.Colors.YELLOW.."   等级:".. GD.Colors.LGREEN .. tostring(rank) )
				GD_Message(GD.Colors.YELLOW.."   类型:".. GD.Colors.LGREEN .. tostring(debuffType) )
				GD_Message(GD.Colors.YELLOW.."   层数:".. GD.Colors.LGREEN .. tostring(count) )
				GD_Message(GD.Colors.YELLOW.."   冷却:".. GD.Colors.LGREEN .. tostring(n) )
				GD_Message(GD.Colors.YELLOW.."   归属:".. GD.Colors.LGREEN .. tostring(unitCaster) )
				GD_Message(GD.Colors.YELLOW.."   图标:".. GD.Colors.LGREEN .. tostring(ls_icon[3]) )
				GD_Message(GD.Colors.YELLOW.."   其他:".. GD.Colors.LGREEN .. tostring(isStealable) )
				GD_Message(GD.Colors.YELLOW.."   技能时间:".. GD.Colors.LGREEN .. tostring(nn) )		
				GD_Message(GD.Colors.YELLOW.."   shouldConsolidate:".. wowam.Colors.CYAN .. tostring(shouldConsolidate) )
				GD_Message(GD.Colors.YELLOW.."   spellId:".. wowam.Colors.CYAN .. tostring(spellId))
				GD_Message(GD.Colors.YELLOW.."   spell:".. wowam.Colors.CYAN .. GetSpellLink(spellId) )
				k = k + 1;
			end
		end
	end
	
	return k-1;
end

function GDShowEquipList(unit) --显示指定目标的装备列表及CD 
	unit=GDUnit(unit,"player");
	local cd;
	for i=1 , 23 do
		local mainHandLink = GetInventoryItemLink(unit,i);
		if mainHandLink then
			local spell = GetItemInfo(mainHandLink);
			if spell then
				a, b, c = GetInventoryItemCooldown(unit, i);
				cd= a+b-GetTime();
				cd = format("%.1f",IF(cd<0, 0, cd));
				DEFAULT_CHAT_FRAME:AddMessage(GD.Colors.RED .. "编号:" .. GD.Colors.LGREEN .. tostring(i) .. GD.Colors.YELLOW .."  名称:" ..GD.Colors.LGREEN.. spell .. GD.Colors.YELLOW .."  冷却时间:" ..GD.Colors.LGREEN.. cd,192,0,192,0);
			end
		end
	end
end

function GDShowSpellList(spell,index)
	if not index then
		index =200000
	end
	local k =1
	for i=1,index do
		local name = GetSpellInfo(i)
		
		if name ==	spell then
		GD_Message(GD.Colors.RED .. "(" .. k .. ") " ..  GD.Colors.YELLOW .. name .. ", " .. GD.Colors.LGREEN .. tostring(i) )
		print(GetSpellInfo(i))
		k=k+1
		end						
	end
end		
---------------------------------------------------------------------------------------------
function GDWeaponEnchantInfo(n)--返回主手和副手武器附魔信息.
	local a,b,c,a1,b1,c1 = GetWeaponEnchantInfo() -- 返回主手和副手武器附魔信息.

	if n ==1 and a then
		return b/1000,a,c
	elseif n ==2 and a1 then
		return b1/1000,a1,c1
	end

	return -1;
end

function GDSetSpellStopTime(times)
	times=IF(times, times, 3);
	if type(times) ~= "number" then
		GD_Message(GD.Colors.RED.."错误：" .. GD.Colors.LGREEN .. "参数类型错误，请使用数值");
		return false;
	end

	GD.Config.SPELL_STOP_TIME=times;
	return true;
end 

function GD_IsFailed(spell,unit)

	if GD.Spell.Failed then
		local aunid = UnitGUID(unit);
		if aunid and GD.Spell.Failed[aunid] then
			if GetTime() - GD.Spell.Failed[aunid]["Time"] <=0 then
				if(GD.Spell.Failed[aunid]["Text"]==SPELL_FAILED_NOT_BEHIND)then
					if (GD.Spell.Failed[aunid]["SpellName"]==spell) then
						return false,"忽略目标(".. GD.Spell.Failed[aunid]["Text"]..")";
					end
				else
					return false,"忽略目标(".. GD.Spell.Failed[aunid]["Text"]..")";
				end
			end
		end
	end

	if GD.Spell.Delay then
		local unid =IF(unit=="nogoal",UnitGUID("player"),UnitGUID(unit))
		local tbl = GD.Spell.Delay[spell];
		if tbl and unid then
			if tbl["All"] and tbl["All"]["Status"] and tbl["All"]["Status"] == "Star" and tbl["All"]["DelayTime"] then
				return false,"技能延時施放,施放中..."..GetTime() -tbl["All"]["DelayTime"];
			elseif tbl[unid] and tbl[unid]["Status"] and tbl[unid]["Status"] == "Star" and tbl[unid]["DelayTime"] then
				return false,"技能延時施放,施放中..."..GetTime() -tbl[unid]["DelayTime"];
			elseif tbl["All"] and tbl["All"]["Status"] and tbl["All"]["Status"] == "End" and tbl["All"]["EndTime"] and (GetTime() < tbl["All"]["EndTime"]) then
				return false,"技能延時中..."..GetTime() - tbl["All"]["EndTime"];
			elseif tbl[unid] and tbl[unid]["Status"] and tbl[unid]["Status"] == "End" and tbl[unid]["EndTime"] and (GetTime() < tbl[unid]["EndTime"]) then
				return false,"技能延時中..."..GetTime() -tbl[unid]["EndTime"];	
			end
		end
	end
	
	--[[if GD.Spell.Failed and GD.Spell.Failed.Delay then
		local uid;
		if GD.Spell.Failed.Delay[spell] and GD.Spell.Failed.Delay[spell][spell] and GD.Spell.Failed.Delay[spell][spell]["SPELL_DELAY"] then
			uid=spell;
		else
			uid=UnitGUID(unit);
		end
		
		if uid then
			if GD.Spell.Failed.Delay[uid] and GD.Spell.Failed.Delay[uid][spell] and GD.Spell.Failed.Delay[uid][spell]["TIME"] then
				if GD.Spell.Failed.Delay[uid][spell]["SPELL_DELAY"] then
					local temp_act,_,temp_act_name = GDUnitCastSpellTime("player");
					if temp_act ~= -1 and temp_act_name == spell then
						temp_act = IF(temp_act==-1, 0, temp_act);
						GD.Spell.Failed.Delay[uid][spell]["TIME"] = GetTime();
					else
						temp_act=0;
					end
					if GetTime() - GD.Spell.Failed.Delay[uid][spell]["TIME"] < GD.Spell.Failed.Delay[uid][spell]["SPELL_DELAY"] then
						return false,"技能延时施放";
					end
				else					
					local uida,text;
					uida=UnitGUID(unit);
					if uida and GD.Spell.Failed.Delay[uida] and GD.Spell.Failed.Delay[uida]["FAILED_TEXT"] then
						text = GD.Spell.Failed.Delay[uida]["FAILED_TEXT"]
						
						if text==SPELL_FAILED_OUT_OF_RANGE or text==SPELL_FAILED_BAD_IMPLICIT_TARGETS or text==SPELL_FAILED_LINE_OF_SIGHT or text==SPELL_FAILED_TARGETS_DEAD or text==SPELL_FAILED_BAD_TARGETS then
							if GetTime() - GD.Spell.Failed.Delay[uida]["TIME"] > GD.Config.SPELL_STOP_TIME then
								return true,text;
							else
								return false,text;
							end
						end
					end
				
					local ftext = GD.Spell.Failed.Delay[uid][spell]["FAILED_TEXT"];
					
					local failed_on = SPELL_FAILED_NOT_BEHIND==ftext or SPELL_FAILED_ONLY_STEALTHED==ftext or SPELL_FAILED_AURA_BOUNCED==ftext or  SPELL_FAILED_NO_COMBO_POINTS==ftext or SPELL_FAILED_ONLY_OUTDOORS==ftext or SPELL_FAILED_ONLY_SHAPESHIFT==ftext or SPELL_FAILED_ONLY_STEALTHED==ftext  ;
					--print("2>>",ftext,failed_on)
					if failed_on then
						if GetTime() - GD.Spell.Failed.Delay[uid][spell]["TIME"] < GD.Config.SPELL_STOP_TIME then
							return false,GD.Spell.Failed.Delay[uid][spell]["FAILED_TEXT"];
						end
					else
						if GD.Spell.Failed.Delay[spell] and GD.Spell.Failed.Delay[spell]["TIME"] then
					--print("3>>",GetTime() - GD.Spell.Failed.Delay[spell]["TIME"] < GD.Config.SPELL_STOP_TIME,GetTime() -GD.Spell.Failed.Delay[spell]["TIME"] , GD.Config.SPELL_STOP_TIME)
							if GetTime() - GD.Spell.Failed.Delay[spell]["TIME"] < GD.Config.SPELL_STOP_TIME then
								return false,GD.Spell.Failed.Delay[spell]["FAILED_TEXT"];
							end
						end
					end
				end

				GD.Spell.Failed.Delay[uid]=nil;
				GD.Spell.Failed.Delay[spell]=nil;
				return true,"";
			end
		else
			return true,"";
		end
	end]]
	return true,"";
end

function GD_IsItem(name,tunit,gcd,Special,isname,NOCD,typenumber,SpellLevel,temp_UnitGUID,unitguid,EnergyDemand)
	local itemID = GD.Spell.Property[name]["ItemID"];
	local itemCD = GDItemCoolDown(itemID);
		
	if  GD.Spell.Property[name]["ItemEquipLoc"] ~= "" and not IsEquippedItem(itemID) then
		return false,typenumber,"请装备/佩戴该物品";
	end


	if  GD.Spell.Property[name]["HasRange"] and tunit ~= "nogoal" then
		if not temp_UnitGUID then
			return false,typenumber,"需要个目标(如有问题请尝试用“无目标”(”normal”)参数或联系技术支持)";
		end
	end


	
	if itemCD >0 then
		return false,typenumber,"物品冷却中",itemCD;
	end
	
	local usable, nomana = IsUsableItem(itemID);
	if (not usable) then
		return false,typenumber,"物品不可用",itemCD;
	end
	
	if tunit == "nogoal" or not GD.Spell.Property[name]["HasRange"] then
		return true,typenumber,"",itemCD;
	end
	
	local Isa =IsItemInRange(itemID,tunit)
	
	if  not (UnitCanAssist("player", tunit)  or  UnitCanAttack("player", tunit))  and tunit ~= "nogoal" then	
		return false,typenumber,"物品距离太远",itemCD;
	end
	
	if not Isa then
		return false,typenumber,"不能对此目标施法(请尝试用“无目标”(”normal”)参数或联系技术支持)",itemCD;
	end
	
	return true,typenumber,"",itemCD;
end

function GD_IsSpell(name,tunit,gcd,Special,isname,NOCD,typenumber,SpellLevel,temp_UnitGUID,unitguid,EnergyDemand)

	if GD_IsSpell_Conversion then
		local ASSC1,ASSC2,ASSC3,ASSC4,ASSC5,ASSC6 = GD_IsSpell_Conversion(name,tunit,gcd,Special,isname,typenumber,SpellLevel,temp_UnitGUID,unitguid);
		if ASSC1 then
			return ASSC1,ASSC2,ASSC3,ASSC4,ASSC5,ASSC6;
		elseif not ASSC1 and ASSC2 ~= -100 then
			return ASSC1,ASSC2,ASSC3,ASSC4,ASSC5,ASSC6;
		end
	end

	local Cooldown = GDSpellCoolDown(name);
	
	if GD.Config.SetGCD and not gcd then
		if GDGCD()> GD.Config.SetGCD_Time then
			return false,typenumber,"公共CD未冷却",Cooldown;
		end
	end

	local spellId = GD.Spell.Property[name]["SpellId"]
	--local slotID = GD.Spell.Property[name]["SlotID"];
	
	--if GetSpellBookItemInfo(slotID, "player") == "FUTURESPELL" then
	--	return false,typenumber,"技能沒學習不可用",Cooldown;
	--end
	
	if GDSpellIsShapeshift and not GDSpellIsShapeshift(spellId) then
		return false,typenumber,"技能姿態不符合",Cooldown;
	end
	
	local _Activation
	if GDSpellIsActivation then
	
		local  temp_Activation,temp_Activation_1,temp_Activation_2,temp_Activation_3 = GDSpellIsActivation(spellId,tunit,name);
		
		if not temp_Activation_2 then
			if temp_Activation then
				if temp_Activation_1 then
					--return true,typenumber,"技能激活",Cooldown;
					_Activation="技能激活";
				end
			else
				if temp_Activation_1 then
					return false,typenumber,temp_Activation_1,Cooldown;
				else
					return false,typenumber,"技能沒激活不可用",Cooldown;
				end
			end
		elseif temp_Activation_3 then
			return false,typenumber,"技能沒激活不可用",Cooldown;
		end
	end
	
	if GD.Spell.Property[name]["RaidSpell"] and tunit ~= "nogoal" then
		if GD.Spell.Property[name]["RaidSpell"] ==3 then
			if not(UnitPlayerOrPetInParty(tunit) or UnitPlayerOrPetInRaid(tunit) or UnitGUID(tunit) == UnitGUID("player")) then
				return false,typenumber,"目标只能是小队或者团队";
			end
		elseif not (GD.Spell.Property[name]["RaidSpell"] ==2 and (UnitPlayerOrPetInParty(tunit) or UnitGUID(tunit) == UnitGUID("player"))) then
			return false,typenumber,"目标只能是小队";
		elseif not (GD.Spell.Property[name]["RaidSpell"] ==1 and  UnitGUID(tunit) == UnitGUID("player")) then
			return false,typenumber,"目标只能是自己";
		end
	end	
	--print(GDSpellIsMove(spellId,tunit,name))
	if (not(GDSpellIsMoveAll and GDSpellIsMoveAll(spellId,tunit,name))) and (not(GDSpellIsMove and GDSpellIsMove(spellId,tunit,name))) then
		local T_temp1 = GetUnitSpeed("player")
		--local T_temp2 = GD.Spell.Property[name]["CastTime"] --select(7,GetSpellInfo(name))
		local T_temp2 = select(7,GetSpellInfo(name))
		
		if T_temp1 and T_temp2 and T_temp2 and T_temp2 >0 and T_temp1>0 then
			return false,typenumber,"你移動中",Cooldown;
		end
	end	
	
	if (GD.Spell.Property[name]["HasRange"] and tunit ~= "nogoal") then
		if not temp_UnitGUID then
			return false,typenumber,"需要个目标(如有问题请尝试用“无目标”(”normal”)参数或联系技术支持)";
		end

		
		local spellInRange =IsSpellInRange(name,tunit)
		
		if GD.Spell.Property[name]["IsSpellInRange"] and not spellInRange then
			return false,typenumber,"目标死亡或者不能对其施放",Cooldown;
		end
		
		if spellInRange and not GD.Spell.Property[name]["IsSpellInRange"] then
			GD.Spell.Property[name]["IsSpellInRange"]=spellInRange;
		end

		if UnitCanAssist("player", tunit) or UnitCanAttack("player", tunit) then
			if spellInRange == 0 then
				return false,typenumber,"超距离",Cooldown;
			elseif spellInRange==nil then
				return false,typenumber,"不能对此目标施法(请尝试用“无目标”(”normal”)参数或联系技术支持)",Cooldown;
			end	
		else
			return false,typenumber,"技能距离太远",Cooldown;
		end
	end


	local act_timp =0;

	if GD.Spell.Property[name]["CastTime"] and GD.Spell.Property[name]["CastTime"]<=0 then
		Cooldown=Cooldown-GD.Config.PromptSpellAttackTime;--?
	else
		act_timp,_,acc =GDUnitCastSpellTime("player")

		--if acc == name and act_timp > GD.Config.SpellAttackTime and not NOCD then
		if act_timp ~= -1 and act_timp > GD.Config.SpellAttackTime and not NOCD then--?
			return false,typenumber,"施放技能中",Cooldown;
		end
		
		Cooldown=Cooldown-GD.Config.SpellAttackTime;
	end

	if Cooldown >0 and not NOCD then
		return false,typenumber,"技能冷却中",Cooldown;
	end
	
	if IsCurrentSpell(name) and act_timp<=0  and not NOCD then
		return false,typenumber,"正在或者准备施放技能中",Cooldown;
	end

	local usable, nomana = IsUsableSpell(spellId);--C
	local _,_, _, powerCost = GetSpellInfo(spellId);---C
	
	if GDSpellIsPowerNumber and GDSpellIsPowerNumber(spellId) then
		local n = GDSpellIsPowerNumber(spellId);
		if GDUnitMana("player") < n  then
			return false,typenumber,"能量不足",Cooldown;
		end	
	elseif EnergyDemand then
		if GDUnitMana("player") < EnergyDemand  then
			return false,typenumber,"能量不足",Cooldown;
		end	
	elseif Special ==1 or (GDSpellIsPowerCost and GDSpellIsPowerCost(name)) then
		if GDUnitMana("player") < powerCost  then
		  return false,typenumber,"能量不足",Cooldown;
		end	
	elseif not usable and not nomana then
		if GDSpellIsShapeshift and not GDSpellIsShapeshift(spellId) then
			return false,typenumber,"技能姿態不符合",Cooldown;
		elseif(_Activation)then 
			return true,typenumber,_Activation,Cooldown;
		else
			return false,typenumber,"该技能目前无法判断,请参考GDIsRun第四参数或联系技术支持.",Cooldown;
		end
	elseif nomana then
		return false,typenumber,"能量不足",Cooldown;
	end
	return true,typenumber,"",Cooldown;
end

function GD_GetSpellInf(spell)

	if strsub(spell,1,1) == "/" then
		return true,5;
	end
	
	if GD.Spell.Property[spell] then
		if GD.Spell.Property[spell]["Type"] then
			return true,GD.Spell.Property[spell]["Type"];
		end
	end

	if GDSpellIsEx then
		
		 local SSE1,SSE2,SSE3 = GDSpellIsEx(spell);
		 if SSE1 then
			return SSE1,SSE2,SSE3;
		 end
	end
	--极限版修改
	--local skillType, spellId = GetSpellBookItemInfo(spell);
	local spellId = spell;
	
	--local spellId,slotID,_,_,skillType = GDGetSpellId(spell); --?
		
	if spellId then
	
		local spellname,level, _, powerCost,_,_,castTime = GetSpellInfo(spellId);
		GD.Spell.Property = GD.Spell.Property or {};
		GD.Spell.Property[spell]={};
		GD.Spell.Property[spell]["Type"] = 1;
		GD.Spell.Property[spell]["TypeName"] = "Spell";
		GD.Spell.Property[spell]["SpellId"]=spellId;
		--GD.Spell.Property[spell]["SlotID"]=slotID;
		
		GD.Spell.Property[spell]["Time"]= GetTime();
		GD.Spell.Property[spell]["PowerCost"]= powerCost;
		GD.Spell.Property[spell]["CastTime"]= castTime;
		GD.Spell.Property[spell]["SpellName"]= spellname;
		GD.Spell.Property[spell]["Level"]= level;
		GD.Spell.Property[spell]["Spell"]= spell;
		GD.Spell.Property[spell]["SkillType"]=skillType;
		
		GD.Spell.Property[spell]["HasRange"] = GDSpellIsNoTarget and not GDSpellIsNoTarget(spellId);  
		
		if GDSpellIsRaid then
			GD.Spell.Property[spell]["RaidSpell"]= GDSpellIsRaid(spell); 
		else
			GD.Spell.Property[spell]["RaidSpell"]=nil;
		end

		return true,1,spell,spellId;
	end
	
	local itemID = GDGetItemId(spell);
	if itemID then
	
		local isEquipped = IsEquippedItem(itemID)
		local itemSpell = GetItemSpell(itemID);

		local exist, _, _, _, _, _, _, _,itemEquipLoc = GetItemInfo(itemID);
		if exist then
			local itemtype= IF(isEquipped,3,2);
		
			GD.Spell.Property[spell]={};
			GD.Spell.Property[spell]["Type"]=itemtype;
			GD.Spell.Property[spell]["TypeName"]=IF(isEquipped,"Equipped","Item");
			
			if itemEquipLoc == "INVTYPE_TRINKET"  and not GD.Config.TRINKET_TARGET then
				GD.Spell.Property[spell]["HasRange"]=nil;
			else
				GD.Spell.Property[spell]["HasRange"]=ItemHasRange(itemID);
			end
			
			if GD.Spell.Property[spell]["HasRange"] and GDSpellIsNoTarget and GDSpellIsNoTarget(itemID) then 
				GD.Spell.Property[spell]["HasRange"] = nil;
			end
			
			GD.Spell.Property[spell]["Time"]= GetTime();
			GD.Spell.Property[spell]["ItemID"]=itemID;
			GD.Spell.Property[spell]["Spell"]= itemSpell;
			GD.Spell.Property[spell]["ItemEquipLoc"]= itemEquipLoc;
		
			if GDSpellIsRaid then
				GD.Spell.Property[spell]["RaidSpell"]= GDSpellIsRaid(spell);
			else
				GD.Spell.Property[spell]["RaidSpell"]=nil;
			end
			
			return true,itemtype;
		end
	end

	if GetMacroIndexByName(spell) >0 then
		return true,4;
	end

	return false,-1;
end

function GD_IsRunSpell(name,tunit,gcd,special,NOCD,EnergyDemand)

	special = IF(special, special, 0);

	local isname,typenumber,spellLevel = GD_GetSpellInf(name);
	
	if typenumber == -1 then
		return false,typenumber,"无法识别的技能、物品、宏";
	end
	
	if typenumber == 5 then
		return true,typenumber,name .. "(只判断宏是否存在,忽略宏内容)";
	end
	
	if isname and typenumber == 4 then
		local getMacroIndex = GetMacroIndexByName(name)
		if getMacroIndex >0 then
			local sepll, rank ,body = GetMacroInfo(getMacroIndex)
			return true,4,sepll,getMacroIndex,body;
		end
	end

	tunit = GDUnit(tunit,"target")
	
	local temp_UnitGUID,unitguid;
	temp_UnitGUID = UnitGUID(tunit);
	
	if tunit=="nogoal" then
		unitguid ="3";
	elseif not GD.Spell.Property[name]["HasRange"] then
		unitguid ="1";
	elseif not temp_UnitGUID then
		unitguid ="0";
	else
		unitguid=temp_UnitGUID;
	end
	
	if typenumber>=1 and typenumber<=3  and GD.Spell.Property[name]["Result"] and GD.Spell.Property[name]["Unitguid"] == unitguid then
	
		local temp_GetTime=GetTime();
		local temp_istime = GD.Spell.PropertyTime - (temp_GetTime - GD.Spell.Property[name]["Time"]);--?
	
		if temp_istime > 0 then
			return true,typenumber,"是记忆判断",nil,nil,nil,nil,nil,temp_istime;
		end
	end
	
	if typenumber==1 then
		return GD_IsSpell(name,tunit,gcd,special,isname,NOCD,typenumber,spellLevel,temp_UnitGUID,unitguid,EnergyDemand)
	elseif typenumber==2 or typenumber==3 then
		return GD_IsItem(name,tunit,gcd,special,isname,NOCD,typenumber,spellLevel,temp_UnitGUID,unitguid,EnergyDemand)
	end
	
	return false,typenumber,"判断出错，请联系技术支持";
end

function GD_IsRunSpell_Result(name,tunit,Result)

	if not GD.Spell.Property[name] then
		return;	
	end
	
	local temp_UnitGUID,unitguid;
	temp_UnitGUID = UnitGUID(tunit);
	
	if tunit=="nogoal" then
		unitguid ="3";
	elseif not GD.Spell.Property[name]["HasRange"] then
		unitguid ="1";
	elseif not temp_UnitGUID then
		unitguid ="0";
	else
		unitguid=temp_UnitGUID;
	end
	
		
	GD.Spell.Property[name]["Unitguid"]=unitguid;
	GD.Spell.Property[name]["Time"]= GetTime();
	GD.Spell.Property[name]["Result"]=Result;
		
end

function GDApiDecursive()
	if not Dcr  then
		GD_Message(GD.Colors.RED.."错误：" .. GD.Colors.LGREEN .. "无法使用GDApiDecursive()函数,需要安装或启动Decursive插件");
		return
	end
	local n = Dcr["Status"]["UnitNum"]
	local i;
	for i=1, n do
		local unit,spell,IsCharmed,Debuff1Prio = GDApiDecursive_EX(i)
		if unit then
			if UnitName(unit) and spell then 
				if GDIsRun(spell,unit) then
					GDRun(spell,unit)
					return true
				end
			end
		end
	end
end

function GDApiDecursive_EX(id)
	local unit = Dcr.Status.Unit_Array[id]
	local f = Dcr["MicroUnitF"]["UnitToMUF"][unit]

	if not f then
		return
	end
	local isDebuffed = f["IsDebuffed"]

	if isDebuffed then
		local DebuffType = f["FirstDebuffType"]
		local spell = Dcr.Status.CuringSpells[DebuffType]
		local isCharmed = f["IsCharmed"]
		local debuff1Prio = f["Debuff1Prio"]
		return unit,spell,isCharmed,debuff1Prio
	end
--MicroUnitF:UpdateMUFUnit
end

function GDKey(spell,on)
	if on then
		GDHelper_OnMacro(string.format("%s",spell),6)
	else
		GDHelper_OnMacro(string.format("%s",spell),4)
	end
end

function GDMouse(x,y,b,spell,unit)
	GDRun(spell,GDUnit(unit,"nogoal"),string.format("%s|%s|%s",x,y,b))
end

function GDHolyPower(unit)-- 神圣能量
	return UnitPower(GDUnit(unit,"player"), SPELL_POWER_HOLY_POWER);
end

function GDPower()-- 特殊能量
	local _, englishClass = UnitClass("player");
	if englishClass == "PALADIN" then
		return UnitPower("player", SPELL_POWER_HOLY_POWER);
	elseif englishClass == "DRUID" then
		return UnitPower("player", SPELL_POWER_ECLIPSE);
	elseif englishClass == "WARLOCK" then
		local tf = GetSpecialization();
		if tf == 2 then
			return UnitPower("player", SPELL_POWER_DEMONIC_FURY);
		elseif tf == 3 then
			return UnitPower("player", SPELL_POWER_BURNING_EMBERS);
		else
			return UnitPower("player", SPELL_POWER_SOUL_SHARDS);
		end
	elseif englishClass == "PRIEST" then
		return UnitPower("player", SPELL_POWER_SHADOW_ORBS);
	elseif englishClass == "MONK" then
		return UnitPower("player", 12);
		
		
	end
	return -1;
end

function GDPettext()
	local str="";
	for i=1, NUM_PET_ACTION_SLOTS do
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i);
		if not name then
			break;
		end
		str =str .. "(".. i .. ")" ..  name .. ",".. texture .. ",";
    end
	amtext=str;
	return str;
end	

function GDIsActivePet(v)-- 宠物状态按钮
	for i=1, NUM_PET_ACTION_SLOTS do
      local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i);
		if not name then
			break;
		end
		if name == v then
			return isActive;
		end
    end
	return false;
end

function GDAutoCastEnabledPet(v)-- 宠物技能是否能激活状态
	for i=1, NUM_PET_ACTION_SLOTS do
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i);
		if not name then
			break;
		end
		if name == v then
			return autoCastEnabled;
		end
    end
	return false;
end

function GDAutoCastAllowedet(v)-- 宠物技能是否能激活
	for i=1, NUM_PET_ACTION_SLOTS do
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i);
      
		if not name then
			break;
		end
	  
		if name == v then
			return autoCastAllowed;
		end
    end
	return false;
end

function GDIsCurrentMouse(Spell)-- 技能正在执行时按下鼠标左键
	if IsCurrentSpell(Spell) then
		GDMouse(0,0,1);
		return true;
	end
	return false;
end

function GDCancelUnitBuff(unit,buff) --取消指定的BUFF GDCancelUnitBuff(unit,spell)
	if GDUnitBuff(buff,unit,2,0)>0 then
		CancelUnitBuff(unit,buff);
		return true;
	end
	return false;
end

function GDIsInterruptible(unit) -- 判断法术能否被打断,注意,此函数仅仅只判断法术本身是否能被打断,不会判断受无敌保护光环掌握等免打断影响造成的不能打断.--墨者提供
    local _, _, _, _, _, _,_,_, notInterruptibleCast = UnitCastingInfo(unit);
    local _, _, _, _, _, _,_, notInterruptibleChannel = UnitChannelInfo(unit);
    if notInterruptibleCast ~= nil or notInterruptibleChannel ~=nil then
        return not notInterruptibleCast or not notInterruptibleChannel;
    end
    return false;
end

function GDStopCasting()
	GDRun("/StopCasting");
	return true;
end

-- function GDUnitFollow(unit)--跟随目标
	-- if not unit or not GDUnitIsFollow() then
		-- return false;
	-- end
	
	-- if GDUnitIsFollow() == unit then
		-- return false,"正在跟随";
	-- elseif UnitName(unit) and GDRange(unit)<=25 then
		-- FollowUnit(unit);
		-- return true;
	-- end
	-- return false;
-- end

function GDGetInventoryItemDurability(invSlot) --装备持久度
	local L,H = GetInventoryItemDurability(invSlot);
	return tonumber(format("%.0f", L/H *100));
end

function GDGetMainTank(index)
	
	if not (index and type()=="number") then
		return "";
	end
	
	local k = GetNumRaidMembers();
	
	local MtIndex =0;	
	
	for i=1 , k do
	
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
			
		if name and role == "MAINTANK" then
			MtIndex = MtIndex +1;
			if MtIndex==index then
				return name;
			end
		end
	end
	return "";
end

function GDUnitClassification(unit,classification)
	if unit and classification then
		return UnitClassification(unit) == classification;
	else
		return false;
	end
end	


function GDGetSIlink(Name)
	local itemName, itemLink= GetItemInfo(Name)
	if itemName then
		return itemName;
	end
	
	local itemName= GetSpellLink(Name)

	if itemName then
		return itemName;
	end
	return Name;
end

function GDSetFocus(unit,Name)

	local mouseover = UnitName("mouseover");
	local focus = UnitName("focus");
	
	if not Name or not unit or not mouseover then return false; end;
	
	if mouseover == Name and focus ~= Name then
	
		GDRun("/focus mouseover");
		return true;
	end
	
	return false;
end 

function GDAutoResume(Type,n,Buff,Spell,Battle) --自动恢复能量或者生命 
	
	if Battle and GDUnitAffectingCombat() then
	
	elseif not Battle and not GDUnitAffectingCombat() then

	else
		return false;
	end
	
	if Type == 0 then
		Type = GDUnitHealth("player","%") < n ;
	elseif Type == 1 then
		Type = GDUnitMana("player","%") < n ;
	elseif Type == 2 then
		Type = GDUnitHealth("player","%") < n or GDUnitMana("player","%") < n ;
	end
	
	local T = GDUnitBuff(Buff,"player",2,0)<=0 and Type;

	if T and GDIsRun(Spell,"player") then
	
		GDRun(Spell,"player");
		GDUnitCastSpellDelay(Spell,2,"player");
		return true;
		
	end

end

function GDGetSpellCastTarget(spell)
	if not GD.Spell.Casting or not GD.Spell.Casting[spell] then
		return "";
	end
	
	local tbl = GD.Spell.Casting[spell];
	
	if GetTime() - tbl["Time"] >30 then
		tbl = nil;
		return "";
	end
	return tbl["Unit"];
end

function GDGetCastInf()
	
	if not GD.Spell.Casting then
		return "";
	end
	
	local tbl = GD.Spell.Casting;
	
	if tbl["Spell"] then
		if GetTime() - tbl["Time"] >30 then
			GD.Spell.Casting = {};
			return "";
		end
		return 	tbl["Spell"],tbl["Unit"], GetTime() - tbl["Time"];
	end
	
	return "";
end

function GDIsPlayerCastSpell()

	if not GD.Spell.Casting then
		return false;
	end
	local tbl = GD.Spell.Casting;
	
	if tbl["Spell"] then
		if GetTime() - tbl["Time"] >30 then
			GD.Spell.Casting = {};
			return false;
		end
		return 	true;
	end
	return false;
end

function GDUnitGetIncomingHeals(unit) --治療量預測函數
	
	local guid = UnitGUID(unit);
	
	if guid then
		local Health = UnitHealth(unit);
		local HealthMax = UnitHealthMax(unit);
		--UnitIsPlayer
		local HEAL_PREDICTION = UnitGetIncomingHeals(unit);
		local Player_HEAL_PREDICTION = UnitGetIncomingHeals(unit,"player");
		local HealthExcess	=  Health + HEAL_PREDICTION - HealthMax;

		return HEAL_PREDICTION,HealthExcess,Player_HEAL_PREDICTION;
	end
	return -1,-1,-1;
end


function GDGetDkInfectionTargetInf()
	print("|cffff0000GDGetDkInfectionTargetInf |r死亡骑士专用函数，其他职业不能使用。")
end

function GDGetDKPetCD()
	local haveTotem, name, startTime, duration, icon = GetTotemInfo(1);
	
	if not haveTotem then
		return -1;
	end
	
	local cd = duration - (GetTime()-startTime) ;
	
	if cd <0 then
		--cd=0;
	end
	
	return cd;
end
	


function GDFindSpellItemInf(info1)

	local infoType;
	
	if GetSpellInfo(info1) then
		infoType = "spell";
	elseif GetItemInfo(info1) then
		infoType = "item";
	else
		local spellid = GDSpellId(info1)
		if spellid then
			_,rank,Texture=GetSpellInfo(spellid)
			return spellid,"",rank,Texture,"";
		end
		return;
	end
	
	if infoType=="item" then
		local spellId;
		local name,itemLink,itemRarity,itemLevel,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,Texture,itemSellPrice;
		
		name,itemLink,itemRarity,itemLevel,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,Texture,itemSellPrice=GetItemInfo(info1);
		_,_,_,_,spellId,_,_,_,_,_,_,_,_,_=string.find(itemLink,"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	
		--print("Item",spellId);
		
		if type(spellId) == "string" then
			spellId = tonumber(spellId);
		end
		return spellId,itemLink,itemSubType,Texture,infoType;
	elseif infoType=="spell"  then
		
		local spellLink,spellName,spellRank,spellId,Texture;
		_,spellId = GetSpellBookItemInfo(info1,"player");
		spellName,spellRank,Texture = GetSpellInfo(spellId);
		spellLink,_=GetSpellLink(spellId);
			
		if not spellLink then
			return;
		end
			
		if type(spellId) == "string" then
			spellId = tonumber(spellId);
		end
		
		return spellId,spellLink,spellRank,Texture,infoType;
		--print("Spell",spellId);	
	end
end


local GDUnitAuraGameTooltip;

function GDUnitAuraFindText(unit,BuffName,index,FindText,Type) --搜索目标的Buff中的信息。
	
	if unit and BuffName and index and FindText then
		local text = GDUnitAuraText(unit,BuffName,index,Type);
		return text and GDStringFind(text,FindText,-1) and true;
	end
	
	return false;	
end

function GDUnitAuraText(unit,BuffName,index,Type)	
	
	if not index then
		index = 2;
	end
	
	if (not Type)  or (Type and Type == "buff") then
		for i=1, MAX_TARGET_BUFFS do
		  local name = UnitBuff(unit, i)
		  if (not name) then break end
		  if  (name == BuffName) then
			GDUnitAuraGameTooltip = CreateFrame("GameTooltip", "GDUnitAuraNumberGameTooltipFrame" .. "Tooltip", nil, "GameTooltipTemplate")
			GDUnitAuraGameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
			GDUnitAuraGameTooltip:ClearLines()  
			GDUnitAuraGameTooltip:SetUnitBuff(unit, i) 
			
			local text = _G[GDUnitAuraGameTooltip:GetName() .. "TextLeft" .. index]:GetText();
			return text or "";
		  end
		end
	end
	
	if (not Type)  or (Type and Type == "debuff") then
	
		for i=1, MAX_TARGET_BUFFS do
		
		  local name = UnitDebuff(unit, i)
		  if (not name) then break end
		  
		  if (name == BuffName) then
			GDUnitAuraGameTooltip = CreateFrame("GameTooltip", "GDUnitAuraNumberGameTooltipFrame" .. "Tooltip", nil, "GameTooltipTemplate")
			GDUnitAuraGameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

			GDUnitAuraGameTooltip:ClearLines()  
			GDUnitAuraGameTooltip:SetUnitDebuff(unit, i) 
			
			local text = _G[GDUnitAuraGameTooltip:GetName() .. "TextLeft" .. index]:GetText();
			return text or "";
		  end
		end
	end
   return "";
end
	
function GDUnitAuraNumber(unit,BuffName,index,FormatText,Type)	
	if not index then
		index = 2;
	end
	
	local text = GDUnitAuraText(unit,BuffName,index,Type);
	
	local v={};
	local i = 1;
	if text then
		if not FormatText or FormatText == "" then
			FormatText = "%d+";	
		end
		for k, val in string.gmatch(text, FormatText) do
			v[i]=tonumber(k);	
			i=i+1;
		end	
	end
	
   return v[1] or -1,v[2] or -1,v[3] or -1,v[4] or -1,v[5] or -1,v[6] or -1,v[7] or -1,v[8] or -1;
end


InternalCDTbl={};
function GDInternalCD(name)
	if InternalCDTbl[name] then
		if InternalCDTbl[name]["time"] then
			local Cycle = InternalCDTbl[name]["Cycle"];
			local cd = Cycle - (GetTime() - InternalCDTbl[name]["time"]);
			
			if cd<=0 then
				cd =0;
			end
			
			return cd;
		else
			return 0;
		end
	end
	return 0;
end



-----------------------------------------------------------------HUGO------------------------------------------------------------------------------
function GDUnitCastSpellDelay_old(Spell,Time,Unit) --设定读条技能施放后延时时间. 
	
	--print(Spell,Time,Unit)
	
	if Spell and Time and Unit then
		if not  UnitGUID(Unit) or type(Time) ~= "number" then
			return false;
		end
	
		local guid = UnitGUID(Unit);
		
		if not GD.Spell.Delay[Spell] then
			GD.Spell.Delay[Spell]={};
		end
		
		if not GD.Spell.Delay[Spell][guid] then
			GD.Spell.Delay[Spell][guid]={};
		end

		local tbl = GD.Spell.Delay[Spell][guid];
		tbl["DelayTime"]=Time;
		return true;
	elseif Spell and Time and not Unit then
		if type(Time) ~= "number" then
			return false;
		end
		
		if not GD.Spell.Delay[Spell] then
			GD.Spell.Delay[Spell]={};
		end
			
		local tbl = GD.Spell.Delay[Spell];
		tbl["DelayTime"]=Time;
		return true;
	else	
		return false;
	end
end

function GDUnitCastSpellDelay(spell,times,unit) --设定读条技能施放后延时时间. 
	unit=GDUnit(unit,"target");
	if (unit=="all") then --all为全部目标
		unit=nil;
	end
	if (not spell or not times or type(times) ~= "number" )then
		return false;
	end

	local guid = "All";
	if(unit)then
		if(not UnitGUID(unit))then
			return false;
		end
		guid=UnitGUID(unit);
	end
		
	GD.Spell.Delay = GD.Spell.Delay or {};
	GD.Spell.Delay[spell] = GD.Spell.Delay[spell] or {};
	GD.Spell.Delay[spell][guid] = GD.Spell.Delay[spell][guid] or {};
	GD.Spell.Delay[spell][guid]["DelayTime"]=times;
	return true;
end


---------------------------------------------HUGO----------------------------------------------------------
local SPELL_ACTIVATION_OVERLAY_GLOW={};
	SPELL_ACTIVATION_OVERLAY_GLOW.SpellName={};
	SPELL_ACTIVATION_OVERLAY_GLOW.SpellId={};
function GDSpellActive(value) --判断自己的技能是否被点亮 GDSpellActive(7384) 可以使用法术ID，也可 GDSpellActive("压制")
	if not value then
		return nil;
	end
	
	if type(value) == "string" then
		
		local spell,rank = GetSpellInfo(value);
		if spell then
			return SPELL_ACTIVATION_OVERLAY_GLOW.SpellName[spell][rank];
		else
			return nil;
		end
		
	elseif type(value) == "number" then
	
		return SPELL_ACTIVATION_OVERLAY_GLOW.SpellId[value];
	
	else
		
		return nil;
		
	end
	
end

function SPELL_ACTIVATION_OVERLAY_GLOW.OnEvent(self, event, ...)
	
	local arg1,arg2 = select(1, ...);
		
	if ( event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" )  then
		
		local spell,rank = GetSpellInfo(arg1);
		if spell then
			rank = rank or "";
			if not SPELL_ACTIVATION_OVERLAY_GLOW.SpellName[spell] then
				SPELL_ACTIVATION_OVERLAY_GLOW.SpellName[spell]={};
			end
			
			SPELL_ACTIVATION_OVERLAY_GLOW.SpellName[spell][rank] = true;
			SPELL_ACTIVATION_OVERLAY_GLOW.SpellId[arg1] = true;
			--print(1,arg1);
		end
		
	elseif ( event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" )  then
		
		local spell,rank = GetSpellInfo(arg1);
		if spell then
			rank = rank or "";
			if not SPELL_ACTIVATION_OVERLAY_GLOW.SpellName[spell] then
				SPELL_ACTIVATION_OVERLAY_GLOW.SpellName[spell]={};
			end
			
			SPELL_ACTIVATION_OVERLAY_GLOW.SpellName[spell][rank] = false;
			SPELL_ACTIVATION_OVERLAY_GLOW.SpellId[arg1] = false;
			--print(1,arg1);
		end
		
	end
	
end


SPELL_ACTIVATION_OVERLAY_GLOW.Frame = CreateFrame("Frame");
SPELL_ACTIVATION_OVERLAY_GLOW.Frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
SPELL_ACTIVATION_OVERLAY_GLOW.Frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
SPELL_ACTIVATION_OVERLAY_GLOW.Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
SPELL_ACTIVATION_OVERLAY_GLOW.Frame:SetScript("OnEvent", SPELL_ACTIVATION_OVERLAY_GLOW.OnEvent);

-----------------------------------------------HUGO--------------------------------------------------


function GDSIlink(Name)

	local itemName, itemLink= GetItemInfo(Name)
	
	--print(11,itemName)
	
	if itemName then
	
		return itemLink;
	end
	
	local itemName= GetSpellLink(Name)
	
	--print(22,itemName)
	
	if itemName then
	
		return itemName;
	end

	return Name;

end

function GDToLink(String)
	
	String=string.gsub(String,"%[","' .. GDSIlink('")
	String=string.gsub(String,"%]","') .. '")
	
	String = "'" .. String .. "'";
	--print(0,String)
	if strfind(String,"'' .. ") ==1 then
	--print(1,String)
		String=string.gsub(String,"'' .. ","",1)
	--	print(2,String)
	end
	
	--print(3,String)
	String=string.reverse(String)
	
	if strfind(String,"'' .. ") ==1 then
	--print(4,String)
		String=string.gsub(String,"'' .. ","",1)
		
	end
	
	String=string.reverse(String)
	
	--print(5,String)
	
	--print(GDSIlink(String))
	
	String ="return " .. String
	
	local a =loadstring(String)
	
	local b,c=a();
	
	if b then
		return b;
	else
		print("脚本错误",c)
	end
	
		
end





----------------------------------

function GDGetUnitName(unit)
	
	local temp = GetUnitName(unit,true);
	
	if temp then
		temp =gsub(temp," ","");
	end
	
	
	return temp;
	
end


-------------新增函数 by ATM 2013-7-13--------------------
--转换技能
function convert(spell)
	local spell = GetSpellInfo(spell)
	return spell
end
--施法 等同GDRun
function Cast(spell, unit)
	local spell = convert(spell)
	if IsUsableSpell(spell)
			and GetSpellCooldown(spell) == 0 then
		--SIN_CastTarget = unit 
				CastSpellByName(spell, unit)
	end
end
--停止施法
function StopCast(spell)
	local spell = convert(spell)
	if UnitCastingInfo("player") == spell
			or UnitChannelInfo("player") == spell then
		SpellStopCasting()
	end
end
--能否施法 等同 GDIsRun
function CanCast(spell, unit)
	local spell = convert(spell)
	local target = unit or "target"
	if UnitCanAttack("player", target)
			and PQR_UnitFacing("player", target)
			and IsSpellInRange(spell) == 1 then
		return true
	end
end
--BUFF层数
function UnitBuffCount(unit, spell, filter)
	local spell = convert(spell)
	local buff = { UnitBuff(unit, spell, nil, filter) }
	if buff[1] then
		return buff[4]
	else
		return 0
	end
end
--DEBUFF层数
function UnitDebuffCount(unit, spell, filter)
	local spell = convert(spell)
	local debuff = { UnitDebuff(unit, spell, nil, filter) }
	if debuff[1] then
		return debuff[4]
	else
		return 0
	end
end
--BUFF剩余时间
function UnitBuffTime(unit, spell, filter)
	local spell = convert(spell)
	local buff = { UnitBuff(unit, spell, nil, filter) }
	if buff[1] then
		return buff[7] - GetTime()
	else
		return 0
	end
end
--DEBUFF剩余时间
function UnitDebuffTime(unit, spell, filter)
	local spell = convert(spell)
	local debuff = { UnitDebuff(unit, spell, nil, filter) }
	if debuff[1] then
		return debuff[7] - GetTime()
	else
		return 0
	end
end
--血量半分比
function UnitHP(unit)
	return UnitHealth(unit) / UnitHealthMax(unit) * 100
			or 0
end
--能量或蓝百分比
function UnitMP(unit)
	return UnitPower(unit, 0) / UnitPowerMax(unit, 0) * 100
			or 0
end
--是否是T
function HasThreat(unit)
	local threat = UnitThreatSituation(unit)
	if UnitAffectingCombat("player")
			and threat then
		if threat >= 2 then
			return unit
		end
	else
		return nil
	end
end

--------------------------------
--- Time to Die 死亡时间计算
function ttd(unit)
	unit = unit or "target";
	if UnitExists(unit) and not UnitIsDeadOrGhost(unit) then
		if currtar ~= UnitGUID(unit) then
			currtar = UnitGUID(unit)
		end
		if thpstart==0 and timestart==0 then
			thpstart = UnitHealth(unit)
			timestart = GetTime()
		else
			thpcurr = UnitHealth(unit)
			timecurr = GetTime()
			if thpcurr >= thpstart then
				thpstart = thpcurr
				timeToDie = 999
			else
				timeToDie = round2(thpcurr/((thpstart - thpcurr) / (timecurr - timestart)),2)
			end
		end
	elseif not UnitExists(unit) or currtar ~= UnitGUID(unit) then
		currtar = 0 
		thpstart = 0
		timestart = 0
		timeToDie = 0
	end
	return timeToDie
end

-- Self Explainatory 雕文检测
--GlyphCheck = nil
function GlyphCheck(glyphid)
	for i=1, 6 do
		if select(4, GetGlyphSocketInfo(i)) == glyphid then
			return true
		end
	end
	return false
end

-----------------------------

function DelayCast(spellid, dtime) -- SpellID of Spell To Check, delay time
	if not CheckCastTime then  CheckCastTime = {} end
	local mtime = dtime + 5 --max expire time
	local spellexist = false
	if dtime > 0 then
		if #CheckCastTime >0 then
			for i=1, #CheckCastTime do
				if CheckCastTime[i].SpellID == spellid then
					spellexist = true
					if ((GetTime() - CheckCastTime[i].CastTime) > mtime) then
						
						CheckCastTime[i].CastTime = GetTime()
						return false
					elseif ((GetTime() - CheckCastTime[i].CastTime) > dtime) then
						
						CheckCastTime[i].CastTime = GetTime()
						return true
					else
						
						return false
					end
				end
			end
			if not spellexist then
				table.insert(CheckCastTime, { SpellID = spellid, CastTime = GetTime() } )	
				return false	
			end
		else
			
			table.insert(CheckCastTime, { SpellID = spellid, CastTime = GetTime() } )	
			return false	
		end
	else
		return true
	end
end
-----------------------
function LineOfSight(target)
if not tLOS then tLOS={} end
if not fLOS then fLOS=CreateFrame("Frame") end
    local updateRate=3
    fLOS:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    function fLOSOnEvent(self,event,...)
        if event=="COMBAT_LOG_EVENT_UNFILTERED" then
            local _, subEvent, _, sourceGUID, _, _, _, _, _, _, _, _, _, _, spellFailed  = ...                
            if subEvent ~= nil then
                if subEvent=="SPELL_CAST_FAILED" then
                    local player=UnitGUID("player") or ""
                    if sourceGUID ~= nil then
                        if sourceGUID==player then 
                            if spellFailed ~= nil then
                                if spellFailed==SPELL_FAILED_LINE_OF_SIGHT 
                                or spellFailed==SPELL_FAILED_NOT_INFRONT 
                                or spellFailed==SPELL_FAILED_OUT_OF_RANGE 
                                or spellFailed==SPELL_FAILED_UNIT_NOT_INFRONT 
                                or spellFailed==SPELL_FAILED_UNIT_NOT_BEHIND 
                                or spellFailed==SPELL_FAILED_NOT_BEHIND 
                                or spellFailed==SPELL_FAILED_MOVING 
                                or spellFailed==SPELL_FAILED_IMMUNE 
                                or spellFailed==SPELL_FAILED_FLEEING 
                                or spellFailed==SPELL_FAILED_BAD_TARGETS 
                                --or spellFailed==SPELL_FAILED_NO_MOUNTS_ALLOWED 
                                or spellFailed==SPELL_FAILED_STUNNED 
                                or spellFailed==SPELL_FAILED_SILENCED 
                                or spellFailed==SPELL_FAILED_NOT_IN_CONTROL 
                                or spellFailed==SPELL_FAILED_VISION_OBSCURED
                                or spellFailed==SPELL_FAILED_DAMAGE_IMMUNE
                                or spellFailed==SPELL_FAILED_CHARMED                                
                                then                        
                                    tLOS={}
                                    tinsert(tLOS,{unit=target,time=GetTime()})            
                                end
                            end
                        end
                    end
                end
            end
            
            if #tLOS > 0 then                
                table.sort(tLOS,function(x,y) return x.time>y.time end)
                if (GetTime()>(tLOS[1].time+updateRate)) then
                    tLOS={}
                end
            end
        end
    end
    fLOS:SetScript("OnEvent",fLOSOnEvent)
    if #tLOS > 0 then
        if tLOS[1].unit==target 
        then
            
            return true
        end
    end
end

