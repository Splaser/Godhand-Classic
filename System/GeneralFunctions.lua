function IGetLocation(Unit)
	return ObjectPosition(Unit)
end

function amrunecount(runeid) --獲得指定符文數量。 return N

	local runeType,i,n;
	
	n=0;
	
	for i=1, 6 do
		runeType = GetRuneType(i);
		if runeType ==runeid then
		n = n+1;				
		end
			
	end
	return n;
end
function amruneid(rune) -- 獲得指定符文ID,返回其id。return ID

	if "冰霜符文" == rune or "Frost Rune" == rune then
		rune = 3 ;
		
	elseif "邪恶符文" == rune or "穢邪符文" == rune or "Unholy Rune" == rune then
		rune = 2 ;
		
	elseif "鲜血符文" == rune or "血魄符文" == rune or "Blood Rune" == rune then
		rune = 1 ;
		
	elseif "死亡符文" == rune or "Death Rune" == rune then
		rune = 4 ;
		
	else
		rune = -1;
		
	end
	return rune;
end

function amen(rune) --返回某種符文可用數量,及冷卻時間。return N,CD1,CD2
	local id,cd;
	local cd1=-1;
	local cd2=-1;
	
	if type(rune) == "number" or type(rune) == "string" then
		if type(rune) == "string" then
			id = amruneid(rune);
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

function UnitBuffID(unit,spellID,filter)
	if unit==nil then
		return nil
	end

	local spellName = GetSpellInfo(spellID)
	if filter == nil then
		return UnitBuff(unit,spellName)
	else
		local exactSearch = strfind(strupper(filter),"EXACT")
		local playerSearch = strfind(strupper(filter),"PLAYER")
		if exactSearch then
			for i=1,40 do
				local _,_,_,_,_,_,_,buffCaster,_,_,buffSpellID = UnitBuff(unit,i)
				if buffSpellID ~= nil then
					if buffSpellID == spellID then
						if (not playerSearch) or (playerSearch and (buffCaster == "player")) then
							return UnitBuff(unit,i)
						end
					end
				else
					return nil
				end
			end
		else
			return UnitBuff(unit,spellName,nil,filter)
		end
	end
end

function UnitDebuffID(unit,spellID,filter)
	local spellName = GetSpellInfo(spellID)
	if filter == nil then
		return UnitDebuff(unit,spellName)
	else
		local exactSearch = strfind(strupper(filter),"EXACT")
		local playerSearch = strfind(strupper(filter),"PLAYER")
		if exactSearch then
			for i=1,40 do
				local _,_,_,_,_,_,_,buffCaster,_,_,buffSpellID = UnitDebuff(unit,i)
				if buffSpellID ~= nil then
					if buffSpellID == spellID then
						if (not playerSearch) or (playerSearch and (buffCaster == "player")) then
							return UnitDebuff(unit,i)
						end
					end
				else
					return nil
				end
			end
		else
			return UnitDebuff(unit,spellName,nil,filter)
		end
	end
end


-- if canAttack("player","target") then
function canAttack(Unit1,Unit2)
	if Unit1 == nil then Unit1 = "player"; end
	if Unit2 == nil then Unit2 = "target"; end
	-- if UnitCanAttack(Unit1,Unit2) == 1 then
	-- 	return true;
	-- end
	return UnitCanAttack(Unit1,Unit2)
end

-- if canCast(12345,true)
function canCast(SpellID,KnownSkip,MovementCheck)
	local myCooldown = getSpellCD(SpellID)
	local lagTolerance = 60;
  	if (KnownSkip == true or isKnown(SpellID)) and IsUsableSpell(SpellID)
   	  and (MovementCheck == false or myCooldown == 0 or isMoving("player") ~= true or UnitBuffID("player",79206) ~= nil) then
      	return true;
    end
end


-- if canDispel("target",SpellID) == true then
function canDispel(Unit,spellID)
  	local HasValidDispel = false
  	local ClassNum = select(3, UnitClass("player"))
	if ClassNum == 1 then --Warrior
		typesList = { }
	end
	if ClassNum == 2 then --Paladin
		if spellID == 4987 then typesList = { "Poison", "Magic" , "Disease" } end
	end
	if ClassNum == 3 then --Hunter
		typesList = { }
	end
	if ClassNum == 4 then --Rogue
		-- Cloak of Shadows
		if spellID == 31224 then typesList = { "Poison", "Curse", "Disease", "Magic" } end
	end
	if ClassNum == 5 then --Priest
		if spellID == 527 then typesList = { "Disease", "Magic" } end
		if spellID == 32375 then typesList = { "Disease", "Magic" } end
	end
	if ClassNum == 6 then --Death Knight
		typesList = { }
	end
	if ClassNum == 7 then --Shaman
		if spellID == 51886 then typesList = { "Curse" } end -- Cleanse Spirit
	end
	if ClassNum == 8 then --Mage
		if spellID == 475 then typesList = { "Curse" } end 
	end
	if ClassNum == 9 then --Warlock
		typesList = { }
	end
	if ClassNum == 10 then --Monk
		-- Detox
		if spellID == 115450 then typesList = { "Poison", "Disease" } end
		-- Diffuse Magic
		if spellID == 122783 then typesList = { "Magic" } end
	end
	if ClassNum == 11 then --Druid
		-- Remove Corruption
		if spellID == 2782 then typesList = { "Poison", "Curse" } end
		-- Nature's Cure
		if spellID == 88423 then typesList = { "Poison", "Curse", "Magic" } end
		-- Symbiosis: Cleanse
		if spellID == 122288 then typesList = { "Poison", "Disease" } end
	end
	local function ValidType(debuffType)
		if typesList == nil then
			return false
		else
	  		for i = 1, #typesList do
	  			if typesList[i] == debuffType then
	  				return true;
	  			else
	  				return false;
	  			end
	  		end
	  	end
  	end
	local ValidDebuffType = false
	-- UnitDebuff(Unit, i)
  	for i = 1 , 40 do
  		local _, _, _, _, debuffType, _, _, _, _, _, debuffid = UnitDebuff(Unit, i)
  		-- Blackout Debuffs
  		for j =1 ,#typesList do

  			if debuffType and typesList[j] == debuffType then
  				HasValidDispel = true
  				return true;
  				--break;
  			end
  		end
  		
  	end
	return HasValidDispel
end

-- if canHeal("target") then
function canHeal(Unit)
	if UnitExists(Unit) and UnitInRange(Unit) == true and UnitCanCooperate("player",Unit)
		and not UnitIsEnemy("player",Unit) and not UnitIsCharmed(Unit) and not UnitIsDeadOrGhost(Unit)
		and getLineOfSight(Unit) == true and not UnitDebuffID(Unit,33786) then
		return true;
	end
	return false;
end

-- canInterrupt("target",20) or canInterrupt("target")
function canInterrupt(unit, percentint)
    local unit = unit or "target"
    local castDuration = 0
    local castTimeRemain = 0
    local castPercent = 0 
    local channelDelay = 0.4 
    local interruptable = false
    local castType = "spellcast" 
    if UnitExists(unit)
        --and UnitCanAttack("player", unit)
        and not UnitIsDeadOrGhost(unit)
    then
        if select(6,UnitCastingInfo(unit)) and not select(9,UnitCastingInfo(unit)) then 
            castStartTime = select(5,UnitCastingInfo(unit))
            castEndTime = select(6,UnitCastingInfo(unit))
            interruptable = true
            castType = "spellcast"
        elseif select(6,UnitChannelInfo(unit)) and not select(8,UnitChannelInfo(unit)) then 
            castStartTime = select(5,UnitChannelInfo(unit))
            castEndTime = select(6,UnitChannelInfo(unit))
            interruptable = true
            castType = "spellchannel"
        else
            castStartTime = 0
            castEndTime = 0
            interruptable = false
        end
        if castEndTime > 0 and castStartTime > 0 then
            castDuration = (castEndTime - castStartTime)/1000
            castTimeRemain = ((castEndTime/1000) - GetTime())
            if percentint == nil and castPercent == 0 then
                castPercent = math.random(75,95)
            elseif percentint == 0 and castPercent == 0 then
                castPercent = math.random(75,95)
            elseif percentint > 0 then
                castPercent = percentint
            end
        else
            castDuration = 0
            castTimeRemain = 0
            castPercent = 0
        end
        if castType == "spellcast" then
        	if math.ceil((castTimeRemain/castDuration)*100) <= castPercent and interruptable == true then
            	return true
        	end
        	else return false;
        end
        if castType == "spellchannel" then
        	if (GetTime() - castStartTime/1000) > 0.6 and interruptable == true then	
        		return true 
        	end
        	else return false;
        end
        return false
    end
end



-- if canPrepare() then
function canPrepare()
	if UnitBuffID("player",104934) -- Eating (Feast)
	  or UnitBuffID("player",80169) -- Eating
	  or UnitBuffID("player",87959) -- Drinking
	  or UnitBuffID("player",11392) -- 18 sec Invis Pot
	  or UnitBuffID("player",3680) -- 15 sec Invis pot
	  or UnitBuffID("player",5384) -- Feign Death
	  or IsMounted() then
	  	return false;
	else
	  	return true;
	end
end


-- if canUse(1710) then
function canUse(itemID)
	local goOn = true;
	local DPSPotionsSet = {
		[1] = {Buff = 105702, Item = 76093}, -- Intel
		[2] = {Buff = 105697, Item = 76089}, -- Agi
		[3] = {Buff = 105706, Item = 76095}, -- Str
	}
	for i = 1, #DPSPotionsSet do
		if DPSPotionsSet[i].Item == itemID then
			if potionUsed then
				if potionUsed <= GetTime() - 60000 then
					goOn = false;
				else
					if potionUsed > GetTime() - 60000 and potionReuse == true then
						goOn = true;
					end
					if potionReuse == false then
						goOn = false;
					end
				end
			end
		end
	end
	if goOn == true and GetItemCount(itemID,false,false) > 0 then
		if select(2,GetItemCooldown(itemID))==0 then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

-- castGround("target",12345,40);
function castGround(Unit,SpellID,maxDistance)
	if UnitExists(Unit) and getSpellCD(SpellID) == 0 and getLineOfSight("player", Unit) and getDistance("player", Unit) <= maxDistance then
 		CastSpellByName(GetSpellInfo(SpellID),"player");
		if IsAoEPending() then
		local X, Y, Z = ObjectPosition(Unit);
			ClickPosition(X,Y,Z,true);
			return true;
		end
 	end
 	return false;
end

-- castGroundBetween("target",12345,40);
function castGroundBetween(Unit,SpellID,maxDistance)
	if UnitExists(Unit) and getSpellCD(SpellID) <= 0.4 and getLineOfSight("player", Unit) and getDistance("player", Unit) <= 5 then
 		CastSpellByName(GetSpellInfo(SpellID),"player");
		if IsAoEPending() then
		local X, Y, Z = ObjectPosition(Unit);
			ClickPosition(X,Y,Z,true);
			return true;
		end
 	end
 	return false;
end

-- if shouldNotOverheal(spellCastTarget) > 80 then
function shouldNotOverheal(Unit)
	local myIncomingHeal, allIncomingHeal = 0, 0
	if UnitGetIncomingHeals(Unit, "player") ~= nil then myIncomingHeal = UnitGetIncomingHeals(Unit, "player"); end
	if UnitGetIncomingHeals(Unit) ~= nil then allIncomingHeal = UnitGetIncomingHeals(Unit); end
	local allIncomingHeal = UnitGetIncomingHeals(Unit) or 0;
	local overheal = 0;
	if myIncomingHeal >= allIncomingHeal then
		overheal = myIncomingHeal;
	else
		overheal = allIncomingHeal;
	end
	local CurShield = UnitHealth(Unit);
	if UnitDebuffID("player",142861) then --Ancient Miasma
		CurShield = select(15,UnitDebuffID(Unit, 142863)) or select(15,UnitDebuffID(Unit, 142864)) or select(15,UnitDebuffID(Unit, 142865)) or (UnitHealthMax(Unit) / 2);
		overheal = 0;
	end
	local overhealth = 100 * (CurShield+ overheal ) / UnitHealthMax(Unit);
	if overhealth and overheal then
		return overhealth, overheal;
	else
		return 0, 0;
	end
end

-- if castHealGround(_HealingRain,18,80,3) then
function castHealGround(SpellID,Radius,Health,NumberOfPlayers)
	if shouldStopCasting(SpellID) ~= true then
		local lowHPTargets, foundTargets = { }, { };
		for i = 1, #nNova do
			if nNova[i].hp <= Health then
				if UnitIsVisible(nNova[i].unit) and ObjectPosition(nNova[i].unit) ~= nil then
					local X, Y, Z = ObjectPosition(nNova[i].unit);
					tinsert(lowHPTargets, { unit = nNova[i].unit, x = X, y = Y, z = Z });
		end end end
		if #lowHPTargets >= NumberOfPlayers then
			for i = 1, #lowHPTargets do
				for j = 1, #lowHPTargets do
					if lowHPTargets[i].unit ~= lowHPTargets[j].unit then
						if math.sqrt(((lowHPTargets[j].x-lowHPTargets[i].x)^2)+((lowHPTargets[j].y-lowHPTargets[i].y)^2)) < Radius then
							for k = 1, #lowHPTargets do
								if lowHPTargets[i].unit ~= lowHPTargets[k].unit and lowHPTargets[j].unit ~= lowHPTargets[k].unit then
									if math.sqrt(((lowHPTargets[k].x-lowHPTargets[i].x)^2)+((lowHPTargets[k].y-lowHPTargets[i].y)^2)) < Radius and math.sqrt(((lowHPTargets[k].x-lowHPTargets[j].x)^2)+((lowHPTargets[k].y-lowHPTargets[j].y)^2)) < Radius then
										tinsert(foundTargets, { unit = lowHPTargets[i].unit, x = lowHPTargets[i].x, y = lowHPTargets[i].y, z = lowHPTargets[i].z });
										tinsert(foundTargets, { unit = lowHPTargets[j].unit, x = lowHPTargets[j].x, y = lowHPTargets[j].y, z = lowHPTargets[i].z });
										tinsert(foundTargets, { unit = lowHPTargets[k].unit, x = lowHPTargets[k].x, y = lowHPTargets[k].y, z = lowHPTargets[i].z });
			end end end end end end end
			local medX,medY,medZ = 0,0,0;
			if foundTargets ~= nil and #foundTargets >= NumberOfPlayers then
				for i = 1, 3 do
					medX = medX + foundTargets[i].x;
					medY = medY + foundTargets[i].y;
					medZ = medZ + foundTargets[i].z;
				end
				medX,medY,medZ = medX/3,medY/3,medZ/3
				local myX, myY = ObjectPosition("player");
				if math.sqrt(((medX-myX)^2)+((medY-myY)^2)) < 40 then
			 		CastSpellByName(GetSpellInfo(SpellID),"player");
					if IsAoEPending() then
						CastAtPosition(medX,medY,medZ);
						if SpellID == 145205 then shroomsTable[1] = { x = medX, y = medY, z = medZ}; end
						return true;
	end end end end end
	return false;
end







-- getLatency()
function getLatency()
	local lag = ((select(3,GetNetStats()) + select(4,GetNetStats())) / 1000)
	if lag < .05 then
		lag = .05
	elseif lag > .4 then
		lag = .4
	end
	return lag
end

function GetObjectFacing(Unit)
	if ObjectExists(Unit) then
		return select(2,pcall(ObjectFacing,Unit))
	else
		return false
	end
end
function GetObjectPosition(Unit)
	if ObjectExists(Unit) then
		return select(2,pcall(ObjectPosition,Unit))
	else
		return false
	end
end
function GetObjectType(Unit)
	if ObjectExists(Unit) then
		return select(2,pcall(ObjectType,Unit))
	else
		return false
	end
end
function GetObjectIndex(Index)
	if ObjectExists(select(2,pcall(ObjectWithIndex,Index))) then
		return select(2,pcall(ObjectWithIndex,Index))
	else
		return false
	end
end
function GetObjectCount()
	return select(2,pcall(ObjectCount))
end

--[[castSpell(Unit,SpellID,FacingCheck,MovementCheck,SpamAllowed,KnownSkip)
Parameter 	Value
First 	 	UnitID 			Enter valid UnitID
Second 		SpellID 		Enter ID of spell to use
Third 		Facing 			True to allow 360 degrees, false to use facing check
Fourth 		MovementCheck	True to make sure player is standing to cast, false to allow cast while moving
Fifth 		SpamAllowed 	True to skip that check, false to prevent spells that we dont want to spam from beign recast for 1 second
Sixth 		KnownSkip 		True to skip isKnown check for some spells that are not managed correctly in wow's spell book.
]]
-- castSpell("target",12345,true);
function castSpell(Unit,SpellID,FacingCheck,MovementCheck,SpamAllowed,KnownSkip,DeadCheck,DistanceSkip,usableSkip)
	if ObjectExists(Unit) 
		and (not UnitIsDeadOrGhost(Unit) or DeadCheck) then
		-- we create an usableSkip for some specific spells like hammer of wrath aoe mode
		if usableSkip == nil then
			usableSkip = false
		end
		-- stop if not enough power for that spell
		if usableSkip ~= true and IsUsableSpell(SpellID) ~= true then
			return false
		end
		-- Table used to prevent refiring too quick
		if timersTable == nil then
			timersTable = {}
		end
		-- make sure it is a known spell
		if not (KnownSkip == true or isKnown(SpellID)) then return false end
		-- gather our spell range information
		local spellRange = select(6,GetSpellInfo(SpellID))
		if DistanceSkip == nil then DistanceSkip = false end
		if spellRange == nil or (spellRange < 4 and DistanceSkip==false) then spellRange = 4 end
		if DistanceSkip == true then spellRange = 40 end
		-- Check unit,if it's player then we can skip facing
		if (Unit == nil or UnitIsUnit("player",Unit)) or -- Player
			(Unit ~= nil and UnitIsFriend("player",Unit)) then  -- Ally
			FacingCheck = true
		--elseif isSafeToAttack(Unit) ~= true then -- enemy
	--		return false
		end
		-- if MovementCheck is nil or false then we dont check it
		if MovementCheck == false or isMoving("player") ~= true
			-- skip movement check during spiritwalkers grace and aspect of the fox
			or UnitBuffID("player",79206) ~= nil  then
			-- if ability is ready and in range
			if getSpellCD(SpellID) == 0 and (getDistance("player",Unit) <= spellRange or DistanceSkip == true) then
				-- if spam is not allowed
				if SpamAllowed == false then
					-- get our last/current cast
					if timersTable == nil or (timersTable ~= nil and (timersTable[SpellID] == nil or timersTable[SpellID] <= GetTime() -1.5)) then
						if (FacingCheck == true or getFacing("player",Unit) == true) and (UnitIsUnit("player",Unit) or getLineOfSight("player",Unit) == true) then
							timersTable[SpellID] = GetTime()
							currentTarget = UnitGUID(Unit)
							CastSpellByName(GetSpellInfo(SpellID),Unit)
							lastSpellCast = SpellID
														
							return true
						end
					end
				elseif (FacingCheck == true or getFacing("player",Unit) == true) and (UnitIsUnit("player",Unit) or getLineOfSight("player",Unit) == true) then
					currentTarget = UnitGUID(Unit)
					CastSpellByName(GetSpellInfo(SpellID),Unit)
					return true
				end
			end
		end
	end
	return false
end

function castMouseoverHealing(Class)
	if UnitAffectingCombat("player") then
		local spellTable = {
			["Druid"] = { heal = 8936, dispel = 88423 },
		}
		local npcTable = {
			71604, -- Contaminated Puddle- Immerseus - SoO
			71995, -- Norushen
			71996, -- Norushen
			72000, -- Norushen
			71357, -- Wrathion
		}
		local SpecialTargets = { "mouseover", "target", "focus" }
		local dispelid = spellTable[Class].dispel
		for i = 1, #SpecialTargets do
			local target = SpecialTargets[i]
			if UnitExists(target) and not UnitIsPlayer(target) then
				local npcID = tonumber(string.match(UnitGUID(target), "-(%d+)-%x+$"))
				for i = 1, #npcTable do
					if npcID == npcTable[i] then
						-- Dispel
						for n = 1,40 do
					      	local buff,_,_,count,bufftype,duration = UnitDebuff(target, n)
				      		if buff then
				        		if bufftype == "Magic" or bufftype == "Curse" or bufftype == "Poison" then
				        			if castSpell(target,88423, true,false) then return; end
				        		end
				      		else
				        		break;
				      		end
					  	end
					  	-- Heal
						local npcHP = getHP(target)
						if npcHP < 100 then
							if castSpell(target,spellTable[Class].heal,true) then return; end
						end
					end
				end
			end
		end
	end
end



--Calculate Agility
function getAgility()
    local AgiBase, AgiStat, AgiPos, AgiNeg = UnitStat("player",2)
    local Agi = AgiBase + AgiPos + AgiNeg
    return Agi
end

-- if getAllies("player",40) > 5 then
function getAllies(Unit,Radius)
	local alliesTable = {};
 	for i=1, #nNova do
		if not UnitIsDeadOrGhost(nNova[i].unit) then
			if getDistance(Unit,nNova[i].unit) <= Radius then
				tinsert(alliesTable,nNova[i].unit);
			end
		end
 	end
 	return alliesTable;
end

function getNumAllies(Unit,Radius) --目标附近友方玩家数量
    local Units = 0;
    for i=1,ObjectCount() do
        if UnitExists(ObjectWithIndex(i)) == true and bit.band(ObjectType(ObjectWithIndex(i)), ObjectTypes.Unit) == 8 then
            local thisUnit = ObjectWithIndex(i);
            if getCreatureType(thisUnit) == true then
                if UnitIsVisible(thisUnit) and not UnitCanAttack("player",thisUnit) and not UnitIsDeadOrGhost(thisUnit) and UnitIsPlayer(thisUnit) then
                    if getDistance(Unit,thisUnit) <= Radius then
                        Units = Units+1;
                    end
                end
            end
        end
    end
    return Units;
end

function getLessHPAllies(Unit,hp,Radius) --目标附近低于hp%友方玩家数量 by LTG
    if hp == nil then hp=100 end
    if Radius == nil then Radius = 10 end
    local Units = 0;
    for i=1,ObjectCount() do
        if UnitExists(ObjectWithIndex(i)) == true and bit.band(ObjectType(ObjectWithIndex(i)), ObjectTypes.Unit) == 8 then
            local thisUnit = ObjectWithIndex(i);
            if getCreatureType(thisUnit) == true then
                if UnitIsVisible(thisUnit) and not UnitCanAttack("player",thisUnit) and not UnitIsDeadOrGhost(thisUnit) and UnitIsPlayer(thisUnit) then
                    if getDistance(Unit,thisUnit) <= Radius and getHP(thisUnit)<=hp then
                        Units = Units+1;
                    end
                end
            end
        end
    end
    return Units;
end

function getMaxAllies(hp,Radius) --团队目标附近Radius内小于hp最密集友方玩家数量 by LTG
    local max = 1;
    local arec =0
    local thisone = nil
    
    for i=1,#members do
        
        local thisUnit = members[i].Unit;
        if getHP(thisUnit)<=hp  then
            arec= getLessHPAllies(thisUnit,hp,Radius)
            if arec>max then
                thisone = thisUnit;
                max = arec
            end
        end
        
    end
    
    return thisone,max;
end


-- if getAlliesInLocation("player",X,Y,Z) > 5 then
function getAlliesInLocation(myX,myY,myZ,Radius)
	local alliesTable = {};
 	for i=1, #nNova do
		if not UnitIsDeadOrGhost(nNova[i].unit) then
			if getDistanceToObject(nNova[i].unit,myX,myY,myZ) <= Radius then
				tinsert(alliesTable,nNova[i].unit);
			end
		end
 	end
 	return alliesTable;
end

-- if getBuffDuration("target",12345) < 3 then
function getBuffDuration(Unit,BuffID,Source)
	if UnitBuffID(Unit,BuffID,Source) ~= nil then
		return select(6,UnitBuffID(Unit,BuffID,Source))*1;
	end
	return 0;
end

-- if getBuffRemain("target",12345) < 3 then
function getBuffRemain(Unit,BuffID,Source)
	if UnitBuffID(Unit,BuffID,Source) ~= nil then
		return (select(7,UnitBuffID(Unit,BuffID,Source)) - GetTime());
	end
	return 0;
end

-- if getBuffStacks(138756) > 0 then
function getBuffStacks(unit,BuffID,Source)
	if UnitBuffID(unit, BuffID,Source) then
		return (select(4, UnitBuffID(unit, BuffID,Source)))
	else
		return 0
	end
end

-- if getCharges(115399) > 0 then
function getCharges(spellID)
	return select(1, GetSpellCharges(spellID))
end

-- if getCreatureType(Unit) == true then
function getCreatureType(Unit)
	local CreatureTypeList = {"Critter", "Totem", "Non-combat Pet", "Wild Pet"}
	for i=1, #CreatureTypeList do
		if UnitCreatureType(Unit) == CreatureTypeList[i] then return false; end
	end
	if not UnitIsBattlePet(Unit) and not UnitIsWildBattlePet(Unit) then return true; else return false; end
end

-- if getCombo() >= 1 then
function getCombo()
	return GetComboPoints("player");
end

-- if getDebuffDuration("target",12345) < 3 then
function getDebuffDuration(Unit,DebuffID,Source)
	if UnitDebuffID(Unit,DebuffID,Source) ~= nil then
		return select(6,UnitDebuffID(Unit,DebuffID,Source))*1;
	end
	return 0;
end

-- if getDebuffRemain("target",12345) < 3 then
function getDebuffRemain(Unit,DebuffID,Source)
	if UnitDebuffID(Unit,DebuffID,Source) ~= nil then
		return (select(7,UnitDebuffID(Unit,DebuffID,Source)) - GetTime());
	end
	return 0;
end

-- if getDebuffStacks("target",138756) > 0 then
function getDebuffStacks(Unit,DebuffID,Source)
	if UnitDebuffID(Unit, DebuffID, Source) then
		return (select(4, UnitDebuffID(Unit, DebuffID, Source)));
	else
		return 0;
	end
end


-- at 5 yard i get 2 so i have to remove 3 yard and in the end i have too much so i remove unitsizes




-- /dump UnitCombatReach("target")
-- if getDistance("player","target") <= 40 then
function getDistance(Unit1,Unit2)
	if Unit2 == nil then Unit2 = "player"; end
	if UnitIsVisible(Unit1) and UnitIsVisible(Unit2) then
		local X1,Y1,Z1 = ObjectPosition(Unit1);
		local X2,Y2,Z2 = ObjectPosition(Unit2);
		local unitSize = 0;
		if UnitGUID(Unit1) ~= UnitGUID("player") and UnitCanAttack(Unit1,"player") then
			unitSize = UnitCombatReach(Unit1);
		elseif UnitGUID(Unit2) ~= UnitGUID("player") and UnitCanAttack(Unit2,"player") then
			unitSize = UnitCombatReach(Unit2);
		end
		return math.sqrt(((X2-X1)^2)+((Y2-Y1)^2)+((Z2-Z1)^2))-unitSize;
	else
		return 1000;
	end
end

-- if getDistance("player","target") <= 40 then
function getDistanceToObject(Unit1,X2,Y2,Z2)
	if Unit1 == nil then Unit1 = "player"; end
	if UnitIsVisible(Unit1) then
		local X1,Y1 = ObjectPosition(Unit1);
		return math.sqrt(((X2-X1)^2)+((Y2-Y1)^2));
	else
		return 1000;
	end
end

--if getFallTime() > 2 then
function getFallTime()
	if fallStarted==nil then fallStarted = 0 end
	if fallTime==nil then fallTime = 0 end
	if IsFalling() then
		if fallStarted == 0 then
			fallStarted = GetTime()
		end
		if fallStarted ~= 0 then
			fallTime = (math.floor((GetTime() - fallStarted)*1000)/1000);
		end
	end
	if not IsFalling() then
		fallStarted = 0
		fallTime = 0
	end
	return fallTime
end

-- if getFacing("target","player") == false then
function getFacing(Unit1,Unit2,Degrees)
	if Degrees == nil then Degrees = 90; end
	if Unit2 == nil then Unit2 = "player"; end
	if UnitIsVisible(Unit1) and UnitIsVisible(Unit2) then
		local Angle1,Angle2,Angle3;
		local Angle1 = ObjectFacing(Unit1)
		local Angle2 = ObjectFacing(Unit2)
		local Y1,X1,Z1 = ObjectPosition(Unit1);
        local Y2,X2,Z2 = ObjectPosition(Unit2);
	    if Y1 and X1 and Z1 and Angle1 and Y2 and X2 and Z2 and Angle2 then
	        local deltaY = Y2 - Y1
	        local deltaX = X2 - X1
	        Angle1 = math.deg(math.abs(Angle1-math.pi*2))
	        if deltaX > 0 then
	            Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2)+math.pi)
	        elseif deltaX <0 then
	            Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2))
	        end
	        if Angle2-Angle1 > 180 then
	        	Angle3 = math.abs(Angle2-Angle1-360)
	        else
	        	Angle3 = math.abs(Angle2-Angle1)
	        end
	        if Angle3 < Degrees then return true; else return false; end
	    end
	end

end


function faceLocation(X, Y)
 	local PlayerX, PlayerY = ObjectPosition("player");
 	if rad(atan2(Y - PlayerY, X - PlayerX)) < 0 then
  		FaceDirection(rad(atan2(Y - PlayerY, X - PlayerX) + 360));
 	else
  		FaceDirection(rad(atan2(Y - PlayerY, X - PlayerX)));
 	end
 	return;
end
function face(unit)
	faceLocation(ObjectPosition(unit));
 	return;
end
-- if getFacingSight("player","target") == true then
function getFacingSight(Unit1,Unit2,Degrees)
	if Degrees == nil then Degrees = 90; end
	if Unit2 == nil then Unit2 = "player"; end
	if UnitIsVisible(Unit1) and UnitIsVisible(Unit2) then
		local Angle1,Angle2,Angle3;
		local Y1,X1,Z1,Angle1 = ObjectPosition(Unit1);
        local Y2,X2,Z2,Angle2 = ObjectPosition(Unit2);
        if Y1 and X1 and Z1 and Angle1 and Y2 and X2 and Z2 and Angle2 then
	        local deltaY = Y2 - Y1
	        local deltaX = X2 - X1
	        Angle1 = math.deg(math.abs(Angle1-math.pi*2))
	        if deltaX > 0 then
	            Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2)+math.pi)
	        elseif deltaX <0 then
	            Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2))
	        end
	        if Angle2-Angle1 > 180 then
	        	Angle3 = math.abs(Angle2-Angle1-360)
	        else
	        	Angle3 = math.abs(Angle2-Angle1)
	        end
	        if Angle3 < Degrees then
	        	if TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10) == nil then
					return true;
				end
			end
		end
	end
	return false;
end

function getLowAllies(Value)
 local lowAllies = 0;
 for i = 1, #nNova do
  if nNova[i].hp < Value then
   lowAllies = lowAllies + 1
  end
 end
 return lowAllies
end

-- if getFacingSightDistance("player","target",45) < 30 then
function getFacingSightDistance(Unit1,Unit2,Degrees)
	if Degrees == nil then Degrees = 90; end
	if Unit2 == nil then Unit2 = "player"; end
	if UnitIsVisible(Unit1) and UnitIsVisible(Unit2) then
		local Angle1,Angle2,Angle3;
		local Y1,X1,Z1,Angle1 = ObjectPosition(Unit1);
        local Y2,X2,Z2,Angle2 = ObjectPosition(Unit2);
        if Y1 and X1 and Z1 and Angle1 and Y2 and X2 and Z2 and Angle2 then
	        local deltaY = Y2 - Y1
	        local deltaX = X2 - X1
	        local unit2Size = IGetFloatDescriptor(UnitGUID(Unit2),0x110);
	        Angle1 = math.deg(math.abs(Angle1-math.pi*2))
	        if deltaX > 0 then
	            Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2)+math.pi)
	        elseif deltaX < 0 then
	            Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2))
	        end
	        if Angle2-Angle1 > 180 then
	        	Angle3 = math.abs(Angle2-Angle1-360)
	        else
	        	Angle3 = math.abs(Angle2-Angle1)
	        end
	        if Angle3 < Degrees then
	        	if TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10) == nil then
					return math.sqrt(((X2-X1)^2)+((Y2-Y1)^2)+((Z2-Z1)^2))-unit2Size
				end
			end
		end
	end
	return 1000;
end

function getGUID(unit)
	local nShortHand = ""
	if UnitExists(unit) then
		if UnitIsPlayer(unit) then
			targetGUID = UnitGUID(unit)
			nShortHand = string.sub(UnitGUID(unit),-5)
  		else
		    targetGUID = string.match(UnitGUID(unit), "-(%d+)-%x+$")
  	        nShortHand = string.sub(UnitGUID(unit),-5)
		end
	end
	return targetGUID, nShortHand
end

-- if getHP("player") then
function getHP(Unit)
	if Unit == nil then
		return 0;
	end

	if UnitIsDeadOrGhost(Unit) or not UnitIsVisible(Unit) then
		return 0;
	end
	for i = 1, #nNova do
		if nNova[i].guidsh == string.sub(UnitGUID(Unit),-5) then
			return nNova[i].hp;
		end
	end
	if UnitGetIncomingHeals(Unit,"player") ~= nil then
		return 100*(UnitHealth(Unit)+UnitGetIncomingHeals(Unit,"player"))/UnitHealthMax(Unit)
	else
		return 100*UnitHealth(Unit)/UnitHealthMax(Unit)
	end
end

-- if getMana("target") <= 15 then
function getMana(Unit)
	return 100 * UnitPower(Unit,0) / UnitPowerMax(Unit,0);
end

-- if getPower("target") <= 15 then
function getPower(Unit)
	local value = 100 * UnitPower(Unit) / UnitPowerMax(Unit)
	if _MyClass == 11 and UnitBuffID("player",106951) then value = value*2 end
	return value;
end

function getRecharge(spellID)
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
	if charges < maxCharges then
		chargeEnd = chargeStart + chargeDuration
		return chargeEnd - GetTime()
	else
		return 0
	end
end

function getChi(Unit)
	return UnitPower(Unit,12)
end

function getChiMax(Unit)
	return UnitPowerMax(Unit,12)
end

--/dump TraceLine()
-- /dump getTotemDistance("target")
function getTotemDistance(Unit1)
	if Unit1 == nil then Unit1 = "player"; end
	if activeTotem ~= nil and UnitIsVisible(Unit1) then
		for i = 1, ObjectCount() do
            --print(UnitGUID(ObjectWithIndex(i)))
            if activeTotem == UnitGUID(ObjectWithIndex(i)) then
                X2, Y2, Z2 = ObjectPosition(ObjectWithIndex(i));
            end
		end
		local X1,Y1,Z1 = ObjectPosition(Unit1);

		TotemDistance = math.sqrt(((X2-X1)^2)+((Y2-Y1)^2)+((Z2-Z1)^2))

		--print(TotemDistance)
		return TotemDistance

		--if TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10) == nil then
		--	local unitSize = IGetFloatDescriptor(UnitGUID(Unit1),0x110);
		--	return math.sqrt(((X2-X1)^2)+((Y2-Y1)^2)+((Z2-Z1)^2))-unitSize;
		--else
		--	return 1000;
		--end
	else
		return 1000;
	end
end

function makeEnemiesTable(maxDistance)
    local  maxDistance = maxDistance or 50
    if enemiesTable == nil or enemiesTableTimer == nil or enemiesTableTimer <= GetTime() - 1 then
        enemiesTableTimer = GetTime()
        -- create/empty table
        enemiesTable = { }
        -- use objectmanager to build up table
        for i = 1, ObjectCount() do
            -- define our unit
            local thisUnit = ObjectWithIndex(i)
            -- sanity checks
            --if getSanity(thisUnit) == true then
                -- get the unit distance
                local unitDistance = getDistance("player",thisUnit)
                -- distance check according to profile needs
                if unitDistance <= maxDistance then
                    -- get unit Infos
                    --local safeUnit = isSafeToAttack(thisUnit)
                    --local burnValue = isBurnTarget(thisUnit)
                    local unitName = UnitName(thisUnit)
                    local unitID = getUnitID(thisUnit)
                    --local shouldCC = isCrowdControlCandidates(thisUnit)
                    --local unitThreat = UnitThreatSituation("player",thisUnit) or -1
                    local X1,Y1,Z1 = ObjectPosition(thisUnit)
                    --local unitCoeficient = getUnitCoeficient(thisUnit,unitDistance,unitThreat,burnValue,safeUnit) or 0
                    local unitHP = getHP(thisUnit)
                    local inCombat = UnitAffectingCombat(thisUnit)
                    local longTimeCC = isLongTimeCCed(thisUnit)
                    --if getOptionCheck("不攻击被控敌人") then
                       -- longTimeCC = isLongTimeCCed(thisUnit)
                    --end
                    -- insert unit as a sub-array holding unit informations
                    tinsert(enemiesTable,
                        {
                            name = unitName,
                            guid = UnitGUID(thisUnit),
                            id = unitID,
                            --coeficient = unitCoeficient,
                            --cc = shouldCC,
                            isCC = longTimeCC,
                            facing = getFacing("player",thisUnit),
                            --threat = unitThreat,
                            unit = thisUnit,
                            distance = unitDistance,
                            hp = unitHP,
                            --safe = safeUnit,
                            --burn = burnUnit,
                            -- Here should track inc damage / healing as well in order to get a timetodie value
                            -- we would need a more static design
                            x = X1,
                            y = Y1,
                            z = Z1,
                        }
                    )
                end
            --end
        end
        -- sort them by coeficient
        --table.sort(enemiesTable, function(x,y)
               -- return x.coeficient and y.coeficient and x.coeficient > y.coeficient or false
        --end)
    end
end

-- /dump UnitGUID("target")
-- /dump getEnemies("target",10)
-- if #getEnemies("target",10) >= 3 then
function getEnemies(Unit,Radius)

	local enemiesTable = {};

	if UnitExists("target") == true
	  and getCreatureType("target") == true
	  and UnitCanAttack("player","target") == true
	  and getDistance("player","target") <= Radius then
	    tinsert(enemiesTable,"target");
	end

 	for i=1,ObjectCount() do
 		if bit.band(ObjectType(ObjectWithIndex(i)), ObjectTypes.Unit) == 8 then
	  		local thisUnit = ObjectWithIndex(i);
	  		if UnitGUID(thisUnit) ~= UnitGUID("target") and getCreatureType(thisUnit) == true then
	  			if UnitCanAttack("player",thisUnit) == true and UnitIsDeadOrGhost(thisUnit) == false then
	  				if getDistance(Unit,thisUnit) <= Radius then
	   					tinsert(enemiesTable,thisUnit);
	   				end
	  			end
	  		end
	  	end
 	end
 	return enemiesTable;
end


-- if getBossID("boss1") == 71734 then
function getBossID(BossUnitID)
	local UnitConvert = 0;
	if UnitIsVisible(BossUnitID) then
		UnitConvert = tonumber(string.match(UnitGUID(BossUnitID), "-(%d+)-%x+$"))
	end
	return UnitConvert;
end


function getUnitID(Unit)
	local UnitConvert = 0;
	if UnitIsVisible(BossUnitID) then
		UnitConvert = tonumber(strmatch(UnitGUID(Unit) or "", "-(%d+)-%x+$"), 10)
	end
	return UnitConvert;
end

-- if getNumEnemies("target",10) >= 3 then
function getNumEnemies(Unit,Radius)
  	local Units = 0;
 	for i=1,ObjectCount() do
		if UnitExists(ObjectWithIndex(i)) == true and bit.band(ObjectType(ObjectWithIndex(i)), ObjectTypes.Unit) == 8 then
	  		local thisUnit = ObjectWithIndex(i);
	  		if getCreatureType(thisUnit) then
	  			if UnitIsVisible(thisUnit) and canAttack("player",thisUnit) and not UnitIsDeadOrGhost(thisUnit) then
	  				if getDistance(Unit,thisUnit) <= Radius then
	  					Units = Units+1;
	   				end
		 		end
		 	end
		end
 	end
 	return Units;
end
 	--获取一个Radius内可以战复/复活的目标
function getDeadAllies(Unit,Radius)
  	local Units = nil
 	for i=1,ObjectCount() do
		if UnitExists(ObjectWithIndex(i)) == true and bit.band(ObjectType(ObjectWithIndex(i)),ObjectTypes.Unit) == 8 then
	  		local thisUnit = ObjectWithIndex(i)
	  		if getCreatureType(thisUnit) == true then
	  			if UnitIsVisible(thisUnit) and UnitCanCooperate("player",Unit)
		and not UnitIsEnemy("player",Unit) and UnitIsDeadOrGhost(thisUnit) and UnitIsPlayer(thisUnit) then
	  				if getDistance(Unit,thisUnit) <= Radius then
                        Unit = thisUnit
	  					return Units
	   				end
		 		end
		 	end
		end
 	end
 	
end


-- if getLineOfSight("target"[,"target"]) then
function getLineOfSight(Unit1,Unit2)
	if Unit2 == nil then if Unit1 == "player" then Unit2 = "target"; else Unit2 = "player"; end end
	if UnitIsVisible(Unit1) and UnitIsVisible(Unit2) then
		local X1,Y1,Z1 = ObjectPosition(Unit1);
		local X2,Y2,Z2 = ObjectPosition(Unit2);
		if TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10) == nil then return true; else return false; end
	else
		return true;
	end
end

-- if getGround("target"[,"target"]) then
function getGround(Unit)
	if UnitIsVisible(Unit) then
		local X1,Y1,Z1 = ObjectPosition(Unit);
		if TraceLine(X1,Y1,Z1+2,X1,Y1,Z1-2, 0x10) == nil and TraceLine(X1,Y1,Z1+2,X1,Y1,Z1-4, 0x100) == nil then return nil; else return true; end
	end
end

-- if getPetLineOfSight("target"[,"target"]) then
function getPetLineOfSight(Unit)
	if UnitIsVisible("pet") and UnitIsVisible(Unit) then
		local X1,Y1,Z1 = ObjectPosition("pet");
		local X2,Y2,Z2 = ObjectPosition(Unit);
		if TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10) == nil then return true; else return false; end
	else return true;
	end
end

-- if getSpellCD(12345) <= 0.4 then
function getSpellCD(SpellID)
	if GetSpellCooldown(SpellID) == 0 then
		return 0
	else
		local Start ,CD = GetSpellCooldown(SpellID);
		local MyCD = Start + CD - GetTime();
		return MyCD;
	end
end

--- Round
function round2(num, idp)
  mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- if getTalent(8) == true then
function getTalent(Row,Column)
	return select(4, GetTalentInfo(Row,Column,GetActiveSpecGroup())) or false
end

-- if getTimeToDie("target") >= 6 then
function getTimeToDie(unit)
	
	unit = unit or "target";
	if thpcurr == nil then thpcurr = 0; end
	if thpstart == nil then thpstart = 0; end
	if timestart == nil then timestart = 0; end
	if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
		if currtar ~= UnitGUID(unit) then
			priortar = currtar;
			currtar = UnitGUID(unit);
		end
		if thpstart == 0 and timestart == 0 then
			thpstart = UnitHealth(unit);
			timestart = GetTime();
		else
			thpcurr = UnitHealth(unit);
			timecurr = GetTime();
			if thpcurr >= thpstart then
				thpstart = thpcurr;
				timeToDie = 999;
			else
				if ((timecurr - timestart)==0) or ((thpstart - thpcurr)==0) then
					timeToDie = 999;
				else
					timeToDie = round2(thpcurr/((thpstart - thpcurr) / (timecurr - timestart)),2);
				end
			end
		end
	elseif not UnitIsVisible(unit) or currtar ~= UnitGUID(unit) then
		currtar = 0;
		priortar = 0;
		thpstart = 0;
		timestart = 0;
		timeToDie = 0;
	end
	if timeToDie==nil then
		return 999
	else
		return timeToDie
	end
end

-- if getTimeToMax("player") < 3 then
function getTimeToMax(Unit)
  	local max = UnitPowerMax(Unit);
  	local curr = UnitPower(Unit);
  	local regen = select(2, GetPowerRegen(Unit));
  	if select(3, UnitClass("player")) == 11 and GetSpecialization() == 2 and isKnown(114107) then
   		curr2 = curr + 4*getCombo()
  	else
   		curr2 = curr
  	end
  	return (max - curr2) * (1.0 / regen);
end

-- if getRegen("player") > 15 then
function getRegen(Unit)
	local regen = select(2, GetPowerRegen(Unit));
	return 1.0 / regen;
end

-- if getVengeance() >= 50000 then
function getVengeance()
	local VengeanceID = 0
	if select(3,UnitClass("player")) == 1 then VengeanceID = 93098 -- Warrior
	elseif select(3,UnitClass("player")) == 2 then VengeanceID = 84839 -- Paladin
	elseif select(3,UnitClass("player")) == 6 then VengeanceID = 93099 -- DK
	elseif select(3,UnitClass("player")) == 10 then VengeanceID = 120267 -- Monk
	elseif select(3,UnitClass("player")) == 11 then VengeanceID = 84840 -- Druid
	end
	if UnitBuff("player",VengeanceID) then
		return select(15,UnitAura("player", GetSpellInfo(VengeanceID)))
	end
	return 0
end


-- if hasGlyph(1234) == true then
function hasGlyph(glyphid)
 	for i=1, 6 do
  		if select(4, GetGlyphSocketInfo(i)) == glyphid or select(6, GetGlyphSocketInfo(i)) == glyphid then return true; end
 	end
 	return false;
end

-- if hasNoControl(12345) == true then
function hasNoControl(spellID)
	local eventIndex = C_LossOfControl.GetNumEvents()
	while (eventIndex > 0) do
		local _, _, text = C_LossOfControl.GetEventInfo(eventIndex)

		if select(3, UnitClass("player")) == 1 then

		end

		if select(3, UnitClass("player")) == 2 then

		end

		if select(3, UnitClass("player")) == 3 then
			if text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_SNARE then
				return true
			end
		end

		if select(3, UnitClass("player")) == 4 then

		end

		if select(3, UnitClass("player")) == 5 then

		end

		if select(3, UnitClass("player")) == 6 then

		end
	
		if select(3, UnitClass("player")) == 7 then
			if spellID == 8143 --Tremor Totem
				and	(text == LOSS_OF_CONTROL_DISPLAY_STUN
					or text == LOSS_OF_CONTROL_DISPLAY_FEAR
					or text == LOSS_OF_CONTROL_DISPLAY_SLEEP)
			then
				return true
			end
			if spellID == 108273 --Windwalk Totem
				and (text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_SNARE)
			then
				return true
			end
		end
	
		if select(3, UnitClass("player")) == 8 then

		end
	
		if select(3, UnitClass("player")) == 9 then

		end
	
		if select(3, UnitClass("player")) == 10 then
			if text == LOSS_OF_CONTROL_DISPLAY_STUN or text == LOSS_OF_CONTROL_DISPLAY_FEAR or text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_HORROR then
				return true
			end
		end
	
		if select(3, UnitClass("player")) == 11 then
			if text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_SNARE then
				return true
			end
		end
		eventIndex = eventIndex - 1
	end
	return false
end

-- if isAlive([Unit]) == true then
function isAlive(Unit)
	local Unit = Unit or "target";
	if UnitIsDeadOrGhost(Unit) == false then
		return true;
	else
		return false;
	end
end

-- isBoss()
function isBoss()
	------Boss Check------
	for x=1,5 do
	    if UnitExists("boss1") then
	        boss1 = tonumber(string.match(UnitGUID("boss1"), "-(%d+)-%x+$"))
	    else
	        boss1 = 0
	    end
	    if UnitExists("boss2") then
	        boss2 = tonumber(string.match(UnitGUID("boss2"), "-(%d+)-%x+$"))
	    else
	        boss2 = 0
	    end
	    if UnitExists("boss3") then
	        boss3 = tonumber(string.match(UnitGUID("boss3"), "-(%d+)-%x+$"))
	    else
	        boss3 = 0
	    end
	    if UnitExists("boss4") then
	        boss4 = tonumber(string.match(UnitGUID("boss4"), "-(%d+)-%x+$"))
	    else
	        boss4 = 0
	    end
	    if UnitExists("boss5") then
	        boss5 = tonumber(string.match(UnitGUID("boss5"), "-(%d+)-%x+$"))
	    else
	        boss5 = 0
	    end
	end
	BossUnits = {
	    -- Cataclysm Dungeons --
	    -- Abyssal Maw: Throne of the Tides
	    40586,      -- Lady Naz'jar
	    40765,      -- Commander Ulthok
	    40825,      -- Erunak Stonespeaker
	    40788,      -- Mindbender Ghur'sha
	    42172,      -- Ozumat
	    -- Blackrock Caverns
	    39665,      -- Rom'ogg Bonecrusher
	    39679,      -- Corla, Herald of Twilight
	    39698,      -- Karsh Steelbender
	    39700,      -- Beauty
	    39705,      -- Ascendant Lord Obsidius
	    -- The Stonecore
	    43438,      -- Corborus
	    43214,      -- Slabhide
	    42188,      -- Ozruk
	    42333,      -- High Priestess Azil
	    -- The Vortex Pinnacle
	    43878,      -- Grand Vizier Ertan
	    43873,      -- Altairus
	    43875,      -- Asaad
	    -- Grim Batol
	    39625,      -- General Umbriss
	    40177,      -- Forgemaster Throngus
	    40319,      -- Drahga Shadowburner
	    40484,      -- Erudax
	    -- Halls of Origination
	    39425,      -- Temple Guardian Anhuur
	    39428,      -- Earthrager Ptah
	    39788,      -- Anraphet
	    39587,      -- Isiset
	    39731,      -- Ammunae
	    39732,      -- Setesh
	    39378,      -- Rajh
	    -- Lost City of the Tol'vir
	    44577,      -- General Husam
	    43612,      -- High Prophet Barim
	    43614,      -- Lockmaw
	    49045,      -- Augh
	    44819,      -- Siamat
	    -- Zul'Aman
	    23574,      -- Akil'zon
	    23576,      -- Nalorakk
	    23578,      -- Jan'alai
	    23577,      -- Halazzi
	    24239,      -- Hex Lord Malacrass
	    23863,      -- Daakara
	    -- Zul'Gurub
	    52155,      -- High Priest Venoxis
	    52151,      -- Bloodlord Mandokir
	    52271,      -- Edge of Madness
	    52059,      -- High Priestess Kilnara
	    52053,      -- Zanzil
	    52148,      -- Jin'do the Godbreaker
	    -- End Time
	    54431,      -- Echo of Baine
	    54445,      -- Echo of Jaina
	    54123,      -- Echo of Sylvanas
	    54544,      -- Echo of Tyrande
	    54432,      -- Murozond
	    -- Hour of Twilight
	    54590,      -- Arcurion
	    54968,      -- Asira Dawnslayer
	    54938,      -- Archbishop Benedictus
	    -- Well of Eternity
	    55085,      -- Peroth'arn
	    54853,      -- Queen Azshara
	    54969,      -- Mannoroth
	    55419,      -- Captain Varo'then

	    -- Mists of Pandaria Dungeons --
	    -- Scarlet Halls
	    59303,      -- Houndmaster Braun
	    58632,      -- Armsmaster Harlan
	    59150,      -- Flameweaver Koegler
	    -- Scarlet Monastery
	    59789,      -- Thalnos the Soulrender
	    59223,      -- Brother Korloff
	    3977,       -- High Inquisitor Whitemane
	    60040,      -- Commander Durand
	    -- Scholomance
	    58633,      -- Instructor Chillheart
	    59184,      -- Jandice Barov
	    59153,      -- Rattlegore
	    58722,      -- Lilian Voss
	    58791,      -- Lilian's Soul
	    59080,      -- Darkmaster Gandling
	    -- Stormstout Brewery
	    56637,      -- Ook-Ook
	    56717,      -- Hoptallus
	    59479,      -- Yan-Zhu the Uncasked
	    -- Tempe of the Jade Serpent
	    56448,      -- Wise Mari
	    56843,      -- Lorewalker Stonestep
	    59051,      -- Strife
	    59726,      -- Peril
	    58826,      -- Zao Sunseeker
	    56732,      -- Liu Flameheart
	    56762,      -- Yu'lon
	    56439,      -- Sha of Doubt
	    -- Mogu'shan Palace
	    61444,      -- Ming the Cunning
	    61442,      -- Kuai the Brute
	    61445,      -- Haiyan the Unstoppable
	    61243,      -- Gekkan
	    61398,      -- Xin the Weaponmaster
	    -- Shado-Pan Monastery
	    56747,      -- Gu Cloudstrike
	    56541,      -- Master Snowdrift
	    56719,      -- Sha of Violence
	    56884,      -- Taran Zhu
	    -- Gate of the Setting Sun
	    56906,      -- Saboteur Kip'tilak
	    56589,      -- Striker Ga'dok
	    56636,      -- Commander Ri'mok
	    56877,      -- Raigonn
	    -- Siege of Niuzao Temple
	    61567,      -- Vizier Jin'bak
	    61634,      -- Commander Vo'jak
	    61485,      -- General Pa'valak
	    62205,      -- Wing Leader Ner'onok

	    -- Training Dummies --
	    46647,      -- Level 85 Training Dummy
	    67127,      -- Level 90 Training Dummy

	    -- Instance Bosses --
	    boss1,  --Boss 1
	    boss2,  --Boss 2
	    boss3,  --Boss 3
	    boss4,  --Boss 4
	    boss5,  --Boss 5
	}
    local BossUnits = BossUnits

    if UnitExists("target") then
        local npcID = tonumber(string.match(UnitGUID("target"), "-(%d+)-%x+$"))--tonumber(UnitGUID("target"):sub(6,10), 16)

        if (UnitClassification("target") == "rare" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "worldboss" or (UnitClassification("target") == "elite" and UnitLevel("target") >= UnitLevel("player")+3) or UnitLevel("target") < 0)
            --and select(2,IsInInstance())=="none"
            and not UnitIsTrivial("target")
        then
            return true
        else
            for i=1,#BossUnits do
                if BossUnits[i] == npcID then
                    return true
                end
            end
            return false
        end
    else
        return false
    end
end

--- if isBuffed()
function isBuffed(UnitID,SpellID,TimeLeft,Filter)
  	if not TimeLeft then TimeLeft = 0 end
  	if type(SpellID) == "number" then 
  		SpellID = { SpellID } 
  	end
	for i=1,#SpellID do
		local spell, rank = GetSpellInfo(SpellID[i])
		if spell then
			local buff = select(7,UnitBuff(UnitID,spell,rank,Filter))
			if buff and ( buff == 0 or buff - GetTime() > TimeLeft ) then 
				return true; 
			end
		end
	end
end

function isCastingTime(lagTolerance)
	local lagTolerance = 0;
	if UnitCastingInfo("player") ~= nil then
		if select(6,UnitCastingInfo("player")) - GetTime() <= lagTolerance then
			return true;
		end
	elseif UnitChannelInfo("player") ~= nil then
		if select(6,UnitChannelInfo("player")) - GetTime() <= lagTolerance then
			return true;
		end
	elseif (GetSpellCooldown(GetSpellInfo(61304)) ~= nil and GetSpellCooldown(GetSpellInfo(61304)) <= lagTolerance) then
	  	return true;
	else
		return false;
	end
end

-- if isCasting() == true then
function castingUnit(Unit)
	if Unit == nil then Unit = "player" end
	if UnitCastingInfo(Unit) ~= nil
	  or UnitChannelInfo(Unit) ~= nil
	  or (GetSpellCooldown(61304) ~= nil and GetSpellCooldown(61304) > 0.001) then
	  	return true;
	end
end

function isCastingDruid(Unit)
	if Unit == nil then Unit = "player" end
	if UnitCastingInfo(Unit) ~= nil
	  or UnitChannelInfo(Unit) ~= nil
	  or (GetSpellCooldown(61304) ~= nil and GetSpellCooldown(61304) > 0.001) then
	  	return true; else return false;
	end
end
-- if isCastingSpell(12345,Unit) == true then
function isCastingSpell(spellID,unit)
	if unit == nil then unit = "player" end
	local spellName = GetSpellInfo(spellID)
	local spellCasting = UnitCastingInfo(unit)
	if spellCasting == nil then
		spellCasting = UnitChannelInfo(unit)
	end
	if spellCasting == spellName then
		return true
	else
		return false
	end
end

-- UnitGUID("target"):sub(-15, -10)
-- Dummy Check
function isDummy(Unit)
	if Unit == nil then Unit = "target"; else Unit = tostring(Unit) end
    dummies = {
        31144, --Training Dummy - Lvl 80
        --31146, --Raider's Training Dummy - Lvl ??
        32541, --Initiate's Training Dummy - Lvl 55 (Scarlet Enclave)
        32542, --Disciple's Training Dummy - Lvl 65
        32545, --Initiate's Training Dummy - Lvl 55
        32546, --Ebon Knight's Training Dummy - Lvl 80
        32666, --Training Dummy - Lvl 60
        32667, --Training Dummy - Lvl 70
        46647, --Training Dummy - Lvl 85
        60197, --Scarlet Monastery Dummy
        67127, --Training Dummy - Lvl 90
    }
    for i=1, #dummies do
        if UnitExists(Unit) and UnitGUID(Unit) then
            dummyID = tonumber(string.match(UnitGUID(Unit), "-(%d+)-%x+$"))
        else
            dummyID = 0
        end
        if dummyID == dummies[i] then
            return true
        end
    end
end

function isDummyByName(unitName)
	if Unit == nil then Unit = UnitName("target"); else Unit = tostring(Unit) end
    dummies = {
        "Training Dummy", -- 31144 - Lvl 80
        --"Raider's Training Dummy", -- 31146 - Lvl ??
        "Initiate's Training Dummy", -- 32541 - Lvl 55 (Scarlet Enclave)
        "Disciple's Training Dummy", -- 32542 - Lvl 65
        "Initiate's Training Dummy", -- 32545 - Lvl 55
        "Ebon Knight's Training Dummy",  -- 32546 - Lvl 80
        "Training Dummy", -- 32666 - Lvl 60
        "Training Dummy", -- 32667 - Lvl 70
        "Training Dummy", -- 46647 - Lvl 85
        "Scarlet Monastery Dummy", -- 60197 -- Lvl 1
        "Training Dummy" -- 67127 - Lvl 90
    }
    for i=1, #dummies do
        if dummies[i] == unitName then
        	return true;
        end
    end
end

-- if isEnnemy([Unit])
function isEnnemy(Unit)
	local Unit = Unit or "target";
	if UnitCanAttack(Unit,"player") then
		return true;
	else
		return false;
	end
end

--if isGarrMCd() then
function isGarrMCd(Unit)
	if Unit == nil then Unit = "target"; end
	if UnitExists(Unit)
	  and (UnitDebuffID(Unit,145832)
      or UnitDebuffID(Unit,145171)
      or UnitDebuffID(Unit,145065)
      or UnitDebuffID(Unit,145071)) then
		return true;
	else
		return false;
	end
end

-- if isInCombat("target") then
function isInCombat(Unit)
	if UnitAffectingCombat(Unit) then return true; else return false; end
end

-- if isInMelee() then
function isInMelee(Unit)
	if Unit == nil then Unit = "target"; end
	if getDistance(Unit) < 4 then return true; else return false; end
end

-- if IsInPvP() then
function isInPvP()
	local inpvp = GetPVPTimer()
	if inpvp ~= 301000 and inpvp ~= -1 then
		return true;
	else
		return false;
	end
end

-- if isKnown(106832) then
function isKnown(spellID)
  	local spellName = GetSpellInfo(spellID)
	if GetSpellBookItemInfo(tostring(spellName)) ~= nil then
    	return true;
  	end
	if IsPlayerSpell(tonumber(spellID)) == true then
		return true
	end
  	return false;
end

-- if isLooting() then
function isLooting()
	if GetNumLootItems() > 0 then
		return true;
	else
		return false;
	end
end

-- if not isMoving("target") then
function isMoving(Unit)
	if GetUnitSpeed(Unit) > 0 then return true; else return false; end
end

-- if IsMovingTime(5) then
function IsMovingTime(time)
	if time == nil then time = 1 end
	if GetUnitSpeed("player") > 0 then
		if IsRunning == nil then
			IsRunning = GetTime();
			IsStanding = nil;
		end
		if GetTime() - IsRunning > time then
			return true;
		end
	else
		if IsStanding == nil then
			IsStanding = GetTime();
			IsRunning = nil;
		end
		if GetTime() - IsStanding > time then
			return false;
		end
	end
end

function isPlayer(Unit)
	if UnitExists(Unit) ~= true then return false; end
	if UnitIsPlayer(Unit) == true then
		return true;
	elseif UnitIsPlayer(Unit) ~= true then
		local playerNPC = {
			[72218] = "Oto the Protector",
			[72219] = "Ki the Asssassin",
			[72220] = "Sooli the Survivalist",
			[72221] = "Kavan the Arcanist",
		}
		if playerNPC[tonumber(string.match(UnitGUID(Unit), "-(%d+)-%x+$"))] ~= nil then
			return true;
		end
	else
		return false;
	end
end

function getStandingTime()
	return DontMoveStartTime and GetTime() - DontMoveStartTime or nil;
end

--
function isStanding(Seconds)
	return IsFalling() == false and DontMoveStartTime and getStandingTime() >= Seconds or false;
end

-- if IsStandingTime(5) then
function IsStandingTime(time)
	if time == nil then time = 1 end
	if not IsFalling() and GetUnitSpeed("player") == 0 then
		if IsStanding == nil then
			IsStanding = GetTime();
			IsRunning = nil;
		end
		if GetTime() - IsStanding > time then
			return true;
		end
	else
		if IsRunning == nil then
			IsRunning = GetTime();
			IsStanding = nil;
		end
		if GetTime() - IsRunning > time then
			return false;
		end
	end
end

-- if isSpellInRange(12345,"target") then
function isCasting(SpellID,Unit)
	if ObjectExists(Unit) and UnitIsVisible(Unit) then
		if isCasting(tostring(GetSpellInfo(SpellID)),Unit) == 1 then
			return true
		end
	else
		return false
	end
end

-- if isValidTarget("target") then
function isValidTarget(Unit)
	if UnitIsEnemy("player",Unit) then
		if UnitExists(Unit) and not UnitIsDeadOrGhost(Unit) then return true; else return false; end
	else
		if UnitExists(Unit) then return true; else return false; end
	end
end

function Interrupts()
	if RandomInterrupt == nil then RandomInterrupt = math.random(45,75); end
	function InterruptSpell()
		local MyClass = UnitClass("player");
		--Warrior
		if MyClass == 1 and GetSpellInfo(6552) ~= nil and getSpellCD(6552) == 0 then return 6552;
		-- Paladin
		elseif MyClass == 2 and GetSpellInfo(96231) ~= nil and getSpellCD(96231) == 0 then return 96231;
		-- Hunter
		elseif MyClass == 3 and GetSpellInfo(147362) ~= nil and getSpellCD(147362) == 0 then return 147362;
		-- Rogue
		elseif MyClass == 4 and GetSpellInfo(1766) ~= nil and getSpellCD(1766) == 0 then return 1766;
		-- Priest
		elseif MyClass == 5 and GetSpecialization("player") == 3 and GetSpellInfo(15487) ~= nil and getSpellCD(15487) == 0 then return 15487;
		-- DeathKnight
		elseif MyClass == 6 and GetSpellInfo(80965) ~= nil and getSpellCD(80965) == 0 then return 47528;
		-- Shaman
		elseif MyClass == 7 and GetSpellInfo(57994) ~= nil and getSpellCD(57994) == 0 then return 57994;
		-- Mage
		elseif MyClass == 8 and GetSpellInfo(2139) ~= nil and getSpellCD(2139) == 0 then return 2139;
		-- Warlock
		elseif MyClass == 9 and IsSpellKnown(19647) ~= nil and getSpellCD(19647) == 0 then return 19647;
		-- Monk
		elseif MyClass == 10 and GetSpellInfo(116705) ~= nil and getSpellCD(116705) == 0 then return 116705;
		-- Druid
		elseif MyClass == 11 and UnitBuffID("player", 768) ~= nil and IsPlayerSpell(80965) ~= nil and getSpellCD(80965) == 0 then return 80965;
		elseif MyClass == 11 and UnitBuffID("player", 5487) ~= nil and IsPlayerSpell(80964) ~= nil and getSpellCD(80964) == 0 then return 80964;
		elseif MyClass == 11 and GetSpecialization("player") == 1 then return 78675;
		else return 0; end
	end
	local interruptSpell = InterruptSpell();
	local interruptName = GetSpellInfo(interruptSpell);
	-- Interrupt Casts and Channels on Target and Focus.
	if interruptSpell ~= 0 then
		if UnitExists("target") == true then
			local customTarget = "target";
			local castName, _, _, _, castStartTime, castEndTime, _, _, castInterruptable = UnitCastingInfo(customTarget);
			local channelName, _, _, _, channelStartTime, channelEndTime, _, channelInterruptable = UnitChannelInfo(customTarget);
			if channelName ~= nil then
				--target is channeling a spell that is interruptable
				--load the channel variables into the cast variables to make logic a little easier.
				castName = channelName;
				castStartTime = channelStartTime;
				castEndTime = channelEndTime;
				castInterruptable = channelInterruptable;
				PQR_InterruptPercent = 0;
				IsChannel = true;
			end
			if castInterruptable == false then castInterruptable = true; else castInterruptable = false; end
			if castInterruptable then
			  	local timeSinceStart = (GetTime() * 1000 - castStartTime) / 1000;
				local timeLeft = ((GetTime() * 1000 - castEndTime) * -1) / 1000;
				local castTime = castEndTime - castStartTime;
				local currentPercent = timeSinceStart / castTime * 100000;
			  	if IsSpellInRange(GetSpellInfo(interruptSpell), customTarget) == 1
			  	  and UnitCanAttack("player", customTarget) ~= nil then
					if currentPercent and RandomInterrupt and currentPercent < RandomInterrupt and not IsChannel then return false; end
					-- print("INTERRUPT");
					-- InteruptTimer = GetTime();
					-- RandomInterrupt = nil;
					--FHprint("OK")
				end
			end
		end
	end
end


-- if pause() then
function pause() --Pause
	if (IsLeftAltKeyDown() and GetCurrentKeyBoardFocus() == nil)
		or (IsMounted() and getUnitID("target") ~= 56877)
		or SpellIsTargeting()
		or (not UnitCanAttack("player", "target") and not UnitIsPlayer("target") and UnitExists("target"))
		or UnitCastingInfo("player")
		or UnitChannelInfo("player")
		or UnitIsDeadOrGhost("player")
		or (UnitIsDeadOrGhost("target") and not UnitIsPlayer("target"))
		or UnitBuffID("player",80169) -- Eating
		or UnitBuffID("player",87959) -- Drinking
		or UnitBuffID("target",117961) --Impervious Shield - Qiang the Merciless
		or UnitDebuffID("player",135147) --Dead Zone - Iron Qon: Dam'ren
		or (((UnitHealth("target")/UnitHealthMax("target"))*100) > 10 and UnitBuffID("target",143593)) --Defensive Stance - General Nagrazim
		or UnitBuffID("target",140296) --Conductive Shield - Thunder Lord / Lightning Guardian
	then
		return true;
	else
		return false;
	end
end

-- useItem(12345)
function useItem(itemID)
	if GetItemCount(itemID) > 0 then
		if select(2,GetItemCooldown(itemID))==0 then
			local itemName = GetItemInfo(itemID)
			RunMacroText("/use "..itemName)
			return true
		end
	end
	return false
end


-- if shouldStopCasting(12345) then
function shouldStopCasting(Spell)
	-- if we are on a boss fight
	if UnitExists("boss1") then
		-- Locally  casting informations
		local Boss1Cast, Boss1CastEnd, PlayerCastEnd, StopCasting = Boss1Cast, Boss1CastEnd, PlayerCastEnd, false
		local MySpellCastTime;
		-- Set Spell Cast Time
		if GetSpellInfo(Spell) ~= nil then
			MySpellCastTime = (GetTime()*1000) + select(7,GetSpellInfo(Spell));
		else
			return false;
		end
		-- Spells wich make us immune (buff)
		local ShouldContinue = {
			1022, -- Hand of Protection
			31821, -- Devotion
			104773, -- Unending Resolve
		}
		-- Spells that are dangerous (boss cast)
		local ShouldStop = {
			137457, -- Piercing Roar(Oondasta)
			138763, -- Interrupting Jolt(Dark Animus)
			143343, -- Deafening Screech(Thok)
		}

		if UnitCastingInfo("boss1") then Boss1Cast,_,_,_,_,Boss1CastEnd = UnitCastingInfo("boss1") elseif UnitChannelInfo("boss1") then Boss1Cast,_,_,_,_,Boss1CastEnd = UnitChannelInfo("boss1") else return false; end
		if UnitCastingInfo("player") then PlayerCastEnd = select(6,UnitCastingInfo("player")) elseif UnitChannelInfo("player") then PlayerCastEnd = select(6,UnitChannelInfo("player")) else PlayerCastEnd = MySpellCastTime; end
		for i = 1, #ShouldContinue do
			if UnitBuffID("player", ShouldContinue[i]) and (select(7,UnitBuffID("player", ShouldContinue[i]))*1000)+50 > Boss1CastEnd then  return false; end  --print("Stopper Safety Found")
		end
		if not UnitCastingInfo("player") and not UnitChannelInfo("player") and MySpellCastTime and SetStopTime and MySpellCastTime > Boss1CastEnd then return true; end

		for j = 1, #ShouldStop do
			if Boss1Cast == select(1,GetSpellInfo(ShouldStop[j])) then
				SetStopTime = Boss1CastEnd
				if PlayerCastEnd ~= nil then
					if Boss1CastEnd < PlayerCastEnd then
						StopCasting = true;
					end
				end
			end
		end
		return StopCasting
	end
end



--[[Taunts Table!! load once]]
tauntsTable = {
	{ spell = 143436, stacks = 1 }, --Immerseus/71543               143436 - Corrosive Blast                             == 1x
	{ spell = 146124, stacks = 3 }, --Norushen/72276                146124 - Self Doubt                                  >= 3x
	{ spell = 144358, stacks = 1 }, --Sha of Pride/71734            144358 - Wounded Pride                               == 1x
	{ spell = 147029, stacks = 3 }, --Galakras/72249                147029 - Flames of Galakrond                         == 3x
	{ spell = 144467, stacks = 2 }, --Iron Juggernaut/71466         144467 - Ignite Armor                                >= 2x
	{ spell = 144215, stacks = 6 }, --Kor'Kron Dark Shaman/71859    144215 - Froststorm Strike (Earthbreaker Haromm)     >= 6x
	{ spell = 143494, stacks = 3 }, --General Nazgrim/71515         143494 - Sundering Blow                              >= 3x
	{ spell = 142990, stacks = 12 }, --Malkorok/71454                142990 - Fatal Strike                                == 12x
	{ spell = 143426, stacks = 2 }, --Thok the Bloodthirsty/71529   143426 - Fearsome Roar                               == 2x
	{ spell = 143780, stacks = 2 }, --Thok (Saurok eaten)           143780 - Acid Breath                                 == 2x
	{ spell = 143773, stacks = 3 }, --Thok (Jinyu eaten)            143773 - Freezing Breath                             == 3x
	{ spell = 143767, stacks = 2 }, --Thok (Yaungol eaten)          143767 - Scorching Breath                            == 2x
	{ spell = 145183, stacks = 3 } --Garrosh/71865                 145183 - Gripping Despair                            >= 3x
};

--[[Taunt function!! load once]]
function ShouldTaunt()

	--[[Normal boss1 taunt method]]
	if not UnitIsUnit("player","boss1target") then
	  	for i = 1, #tauntsTable do
	  		if not UnitDebuffID("player",tauntsTable[i].spell) and UnitDebuffID("boss1target",tauntsTable[i].spell) and getDebuffStacks("boss1target",tauntsTable[i].spell) >= tauntsTable[i].stacks then
	  			TargetUnit("boss1");
	  			return true;
	  		end
	  	end
	end

  	--[[Swap back to Wavebinder Kardris]]
  	if getBossID("target") ~= 71858 then
  		if UnitDebuffID("player", 144215) and getDebuffStacks("player",144215) >= 6 then
  			if getBossID("boss1") == 71858 then
  				TargetUnit("boss1");
  				return true;
  			else
  				TargetUnit("boss2");
  				return true;
  			end
  		end
  	end
end

function GroupInfo()
    members, group = { { Unit = "player", HP = CalculateHP("player") } }, { low = 0, tanks = { } }
    group.type = IsInRaid() and "raid" or "party"
    group.number = GetNumGroupMembers()
    if group.number > 0 then
        for i=1,group.number do
            if canHeal(group.type..i) then
                local unit, hp = group.type..i, CalculateHP(group.type..i)
                table.insert( members,{ Unit = unit, HP = hp } )
                if hp < 90 then group.low = group.low + 1 end
                if UnitGroupRolesAssigned(unit) == "TANK" then table.insert(group.tanks,unit) end
            end
        end
        if group.type == "raid" and #members > 1 then table.remove(members,1) end
        table.sort(members, function(x,y) return x.HP < y.HP end)
        --local customtarget = canHeal("target") and "target" -- or CanHeal("mouseover") and GetMouseFocus() ~= WorldFrame and "mouseover"
        --if customtarget then table.sort(members, function(x) return UnitIsUnit(customtarget,x.Unit) end) end
    end
end

function CalculateHP(unit)
  incomingheals = UnitGetIncomingHeals(unit) or 0
  return 100 * ( UnitHealth(unit) + incomingheals ) / UnitHealthMax(unit)
end

--Calculated Rake Dot Damage
function CRKD()
    WA_calcStats_feral()
    local calcRake = WA_stats_RakeTick
    return calcRake
end

--Applied Rake Dot Damage
function RKD()
    local rakeDot = 1
    if UnitExists("target") then
        if Rake_sDamage[UnitGUID("target")]~=nil then rakeDot = Rake_sDamage[UnitGUID("target")]; end
    end
    return rakeDot
end

--Rake Dot Damage Percent
function RKP()
    local RatioPercent = floor(CRKD()/RKD()*100+0.5)
    return RatioPercent
end

--Calculated Rip Dot Damage
function CRPD()
    WA_calcStats_feral()
    local calcRip = WA_stats_RipTick5
    return calcRip
end

--Applied Rip Dot Damage
function RPD()
    local ripDot = 1
    if UnitExists("target") then
        if Rip_sDamage[UnitGUID("target")]~=nil then ripDot = Rip_sDamage[UnitGUID("target")]; end
    end
    return ripDot
end

--Rip Dot Damage Percent
function RPP()
    local RatioPercent = floor(CRPD()/RPD()*100+0.5)
    return RatioPercent
end

function getDistance2(Unit1,Unit2)
    if Unit2 == nil then Unit2 = "player"; end
    if UnitExists(Unit1) and UnitExists(Unit2) then
        local X1,Y1,Z1 = ObjectPosition(Unit1);
        local X2,Y2,Z2 = ObjectPosition(Unit2);
        local unitSize = 0;
        if UnitGUID(Unit1) ~= UnitGUID("player") and UnitCanAttack(Unit1,"player") then
            unitSize = UnitCombatReach(Unit1);
        elseif UnitGUID(Unit2) ~= UnitGUID("player") and UnitCanAttack(Unit2,"player") then
            unitSize = UnitCombatReach(Unit2);
        end
        local distance = math.sqrt(((X2-X1)^2)+((Y2-Y1)^2))
        if distance < max(5, UnitCombatReach(Unit1) + UnitCombatReach(Unit2) + 4/3) then
            return 4.9999
        elseif distance < max(8, UnitCombatReach(Unit1) + UnitCombatReach(Unit2) + 6.5) then
            if distance-unitSize <= 5 then
                return 5
            else
                return distance-unitSize
            end
        elseif distance-(unitSize+UnitCombatReach("player")) <= 8 then
            return 8
        else
            return distance-(unitSize+UnitCombatReach("player"))
        end
    else
        return 1000;
    end
end

function dynamicTarget(range)
    if myEnemies==nil then myEnemies = 0 end
    if myMultiTimer == nil or myMultiTimer <= GetTime() - 1 then
        myEnemies, myMultiTimer = getEnemies("player",range), GetTime()
    end
    for i = 1, #myEnemies do
        if getCreatureType(myEnemies[i]) == true then
            local thisUnit = myEnemies[i]
            if UnitCanAttack(thisUnit,"player")
                and (UnitAffectingCombat(thisUnit) or isDummy(thisUnit))
                and not UnitIsDeadOrGhost(thisUnit)
                and getFacing("player",thisUnit)
            then
                return thisUnit
            end
        end
    end
end

function isDeBuffed(UnitID,DebuffID,TimeLeft,Filter)
	if not TimeLeft then 
		TimeLeft = 0 
	end
	if type(DebuffID) == "number" then 
		DebuffID = { DebuffID } 
	end
	for i=1,#DebuffID do
		local spell, rank = GetSpellInfo(DebuffID[i])
		if spell then
			local debuff = select(7,UnitDebuff(UnitID,spell,rank,Filter))
			if debuff and ( debuff == 0 or debuff - GetTime() > TimeLeft ) then 
				return true 
			end
		end
	end
end
isDebuffed = isDeBuffed

function amac_bak(Unit,Interrupt) --获得指定目标正在施放的法术名称,Interrupt 为非0 只返回可以打断的技能
	local c,i;
		if not Unit then
			Unit = "target";
		end
		c,_,_,_,_,_,_,_,i = UnitCastingInfo(Unit);
		
		if c then
			
			if not Interrupt then
				return c;
			else
				if not i then
					return c;
				end
			end
			
		else
			c,_,_,_,_,_,_,i = UnitChannelInfo(Unit);
			
			if c then
				if not Interrupt then
					return c;
				else
					if not i then
						return c;
					end
				end
			end
		end
		
	return false;

	
	
	
end	


function amac(Unit,Interrupt,Time) --获得指定目标正在施放的法术名称,Interrupt 为非0 只返回可以打断的技能
	if Time == nil then
		Time = 0.4
	end
	if isHealer(Unit) and ((amac_bak(Unit,Interrupt) == "熔岩爆裂" or amac_bak(Unit,Interrupt) == "精神灼烧" )) then
		return false; 
	end
	local c,i;
		if not Unit then
			Unit = "target";
		end
		
		
		c,_,_,_,startTime,_,_,_,i = UnitCastingInfo(Unit);
		
		
		if c then
		--print(GetTime() - startTime/1000,wowam_config.amac_time)
			--if wowam_config.amac_arena and amisarena() then
				if not Time then
					Time = 0.4;
				end
						
				if GetTime() - (startTime/1000) > Time then
			
					if not Interrupt then
							return c;
					else
						if not i then
							return c;
						end
					end
				end
						
			--else
				
				--if not Interrupt then
					--invreturn c;
				--else
				--	if not i then
				--		return c;
				--	end
				--end
				
				
			--end
			
			
			
		else
			c,_,_,_,startTime,_,_,i = UnitChannelInfo(Unit);
			
			if c then
				--print(GetTime() - startTime/1000,wowam_config.amac_time)
				--if wowam_config.amac_arena and amisarena() then
				
					if not Time then
						Time = 0.4;
					end
					
					if GetTime() - (startTime/1000) > Time then
			
						if not Interrupt then
							return c;
						else
							if not i then
								return c;
							end
						end
					end
						
				--else
					
					--if not Interrupt then
					--return c;
					--else
					--	if not i then
						--return c;
						--end
					--end
					
					
				--end
			end
		end
		
	return false;

	
	
	
end	

function ambc(Unit,Interrupt,Time) --获得指定目标正在施放的法术名称,Interrupt 为非0只判定可打断 time为剩余时间 
    local c,i;
    if not Unit then
        Unit = "target";
    end
    
    
    c,_,_,_,_,endTime,_,_,i = UnitCastingInfo(Unit);
    
    
    if c then
        if not Time then
            Time = 0.4;
        end
        
        if   (endTime/1000) - GetTime() <  Time then
            
            if not Interrupt then
                return c;
            else
                if not i then
                    return c;
                end
            end
        end
        
        
        
        
    else
        c,_,_,_,_,endTime,_,i = UnitChannelInfo(Unit);
        
        if c then
            
            if not Time then
                Time = 0.4;
            end
            
            if  (endTime/1000) - GetTime() < Time then
                
                if not Interrupt then
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



function useInmileeAoE()
    if numEnemies == nil then numEnemies = 0 end
    if not enemiesTimer or enemiesTimer <= GetTime() - 1 then
        numEnemies, enemiesTimer = getNumEnemies("player",8), GetTime()
    end
    if numEnemies >= 3 then
        return true
    else
        return false
    end
end

function WA_calcStats_feral()
    local DamageMult = 1 --select(7, UnitDamage("player"))

    local CP = GetComboPoints("player", "target")
    if CP == 0 then CP = 5 end

    if UnitBuffID("player",5217) then
        DamageMult = DamageMult * 1.15
    end

    if UnitBuffID("player",174544) then
        DamageMult = DamageMult * 1.4
    end

    WA_stats_BTactive = WA_stats_BTactive or  0
    if UnitBuffID("player",155672) then
        WA_stats_BTactive = GetTime()
        DamageMult = DamageMult * 1.3
    elseif GetTime() - WA_stats_BTactive < .2 then
        DamageMult = DamageMult * 1.3
    end

    local RakeMult = 1
    WA_stats_prowlactive = WA_stats_prowlactive or  0
    if UnitBuffID("player",102543) then
        RakeMult = 2
    elseif UnitBuffID("player",5215) then
        WA_stats_prowlactive = GetTime()
        RakeMult = 2
    elseif GetTime() - WA_stats_prowlactive < .2 then
        RakeMult = 2
    end

    WA_stats_RipTick = CP*DamageMult
    WA_stats_RipTick5 = 5*DamageMult
    WA_stats_RakeTick = DamageMult*RakeMult
    WA_stats_ThrashTick = DamageMult
end


function canTrinket(trinketSlot)
	if trinketSlot == 13 or trinketSlot == 14 then
		if trinketSlot == 13 and GetInventoryItemCooldown("player",13)==0 then
			return true
		end
		if trinketSlot == 14 and GetInventoryItemCooldown("player",14)==0 then
			return true
		end
	else
		return false
	end
end


function isLongTimeCCed(Unit)
	if Unit == nil then
		return false
	end
	local longTimeCC = {
		339,	-- Druid - Entangling Roots
		102359,	-- Druid - Mass Entanglement
		1499,	-- Hunter - Freezing Trap
		19386,	-- Hunter - Wyvern Sting
		118,	-- Mage - Polymorph
		115078,	-- Monk - Paralysis
		20066,	-- Paladin - Repentance
		10326,	-- Paladin - Turn Evil
		9484,	-- Priest - Shackle Undead
		605,	-- Priest - Dominate Mind
		6770,	-- Rogue - Sap
		2094,	-- Rogue - Blind
		51514,	-- Shaman - Hex
		710,	-- Warlock - Banish
		5782,	-- Warlock - Fear
		5484,	-- Warlock - Howl of Terror
		115268,	-- Warlock - Mesmerize
		6358,	-- Warlock - Seduction
	}
	for i=1,#longTimeCC do
		if UnitDebuffID(Unit,longTimeCC[i])~=nil  then
			return true
		end
	end
	return false
end

function isCastingCCSpell(Unit,time)
	if Unit == nil then
		return false
	end
	if time == nil then
		time = 0;
	end
	local longTimeCCstr = {
		"旋风",	-- Druid 
		"变形术",	-- Mage - Polymorph
		"忏悔",	-- Paladin - Repentance
		"超度邪恶",	-- Paladin - Turn Evil
		"统御意志",	-- Priest - Dominate Mind
		"妖术",	-- Shaman - Hex
		"恐惧",	-- Warlock - Fear
		"混乱之箭",
		
	}
	for i=1,#longTimeCCstr do
		if amac(Unit,1,time) == longTimeCCstr[i] then
			return true
		end
	end
	return false
end

function amCCSpell(Unit,t)
	if Unit == nil then
		return false
	end
	if t == nil then
		t = 0.4
	end

	local longTimeCCstr = {
		"旋风",	-- Druid 
		"变形术",	-- Mage - Polymorph
		"忏悔",	-- Paladin - Repentance
		"超度邪恶",	-- Paladin - Turn Evil
		"荣耀圣令",
		"圣光术",
		"圣光闪现",
		"纠缠根须",
		"愈合",
		"苦修",
		"快速治疗",
		"治疗术",
		"治疗祷言",
		"治疗之涌",
		"治疗之触",
		"治疗波",
		"治疗链",
		"吸血鬼之触",
		"鬼影缠身",
		"痛苦无常",
		"冰霜之颌",
		"冰霜之环",
		"复活宠物",
		"群体驱散",
		"恶魔传送门",
		"抚慰之雾",
		"召唤地狱猎犬",
		"统御意志",	-- Priest - Dominate Mind
		"妖术",	-- Shaman - Hex
		"恐惧",	-- Warlock - Fear
		"混乱之箭",
		
	}
	for i=1,#longTimeCCstr do
		if amac(Unit,1,t) == longTimeCCstr[i] then
			return true
		end
	end
	return false
end

function isCastingCCSpellLast(Unit)
	if Unit == nil then
		return false
	end
	local longTimeCCstr = {
		"旋风",	-- Druid 
		"变形术",	-- Mage - Polymorph
		"忏悔",	-- Paladin - Repentance
		"超度邪恶",	-- Paladin - Turn Evil
		"统御意志",	-- Priest - Dominate Mind
		"妖术",	-- Shaman - Hex
		"恐惧",	-- Warlock - Fear
		"混乱之箭",
		
	}
	for i=1,#longTimeCCstr do
		if ambc(Unit,0,0.2) == longTimeCCstr[i] then
			return true
		end
	end
	return false
end

function GlobalIntCC(spellid,radius,face,latancy)
	if face == nil then
		face = false
	end
    if latancy == nil then
    	latancy = 0.6
    end

    if canCast(spellid) then
        for i = 1, #enemiesTable do
        	local thisUnit = enemiesTable[i].unit
            if UnitCanAttack(thisUnit,"player") == true and enemiesTable[i].distance <= radius and  isCastingCCSpell(thisUnit,latancy) then
                if castSpell(thisUnit,spellid,face,false,false,false) then
                print("强行打断",UnitName(thisUnit),"的控制法术") 
               		return true
               	end
               	
            end
        end
    end
    return false
end
--撕裂id 772 周围目标 撕裂
function GlobalRend()
	if canCast(772) then
		for i = 1, #enemiesTable do
			local thisUnit = enemiesTable[i].unit
			if UnitCanAttack(thisUnit,"player") == true and enemiesTable[i].distance <= 5 and  UnitIsPlayer(thisUnit) and isInvincible(thisUnit) == false and isLongTimeCCed(thisUnit) == false  then
				if getDebuffRemain(thisUnit,772,"player") < 2 then
					if castSpell(thisUnit,772,false,false) then
						print("补撕裂于",UnitName(thisUnit))
						return true;
					end
				end
			end

		end
	end
	return false;
end


function isInvincible(Unit)
	if Unit == nil then
		return false
	end
	local invpvp = {
		19263,	-- Hunter 威慑
		45438,	-- Mage 冰箱 
		642,   --sq无敌
		122470,	--业报
		1022, --保护之手
		
	}
	for i=1,#invpvp do
		if UnitBuffID(Unit,invpvp[i])~=nil or UnitDebuffID(Unit,33786)~=nil then
			return true
		end
	end
	

	if isEvade(Unit) == true then
		if getFacing(Unit,"player",100)==false then  --在unit背后
		 return false
		else return true;
		end
	else 
		return false
	end
return false
end
--魔法无敌判定 小写i
function isMagicinv(Unit)
	if Unit == nil then
		return false
	end
	local invpvpm = {
		19263,	-- Hunter 威慑
		45438,	-- Mage 冰箱 
		642,	-- Paladin 无敌
		31224, --斗篷
		48707, --绿坝
		122470, --业报
		710,
  -- 19263,	--Deterrence
  --8178,	--Grounding Totem Effect

-- 114028	Mass Spell Reflection
 --23920	Spell Reflection
 --108201 Desecrated Ground	 
		
	}
	for i=1,#invpvpm do
		if UnitBuffID(Unit,invpvpm[i])~=nil or UnitDebuffID(Unit,33786)~=nil then
			return true
		end
	end
	return false
end

function isStun(Unit)
	if Unit == nil then
		return false
	end
	local invpvps = {
		46968,	-- 震荡波
		107570,	-- 锤子 
		1833,	-- 盗贼偷袭
		408, --肾 
		108194, --揪脖子
		853, --制裁之锤
		105593, --制裁之拳
		19577, --lr 胁迫
		22570, --野德割碎
		163505, --斜略昏迷
		118905, --sm电能
		89766,--	ss bb 丢斧头 Axe Toss	
 		113801,--	dly 猛击Bash
 		117526,--	束缚射击 Binding Shot
 		119392,--	蛮牛冲 Charging Ox Wave
 		117418,--	王八拳 Fists of Fury
 		120086,--Fists of Fury
 		47481,--	dk bb 撕扯 Gnaw
 		19577,-- 胁迫	Intimidation
 		24394,--	Intimidation
 		119381,--	扫堂腿 Leg Sweep
 		5211,--	蛮力猛击Mighty Bash
 		91797,--	dk 大bb Monstrous Blow
 		64044,--	am 惊骇 Psychic Horror
 		118345,--粉碎	Pulverize
 		115001,--	Remorseless Winter
 		30283,--	Shadowfury
 		132168,--	Shockwave
 		46968,--	Shockwave
 		118905,--Static Charge
 		132169,--	Storm Bolt
 		34510,--	Stun
 		131402,--	Stunning Strike
 		123420,--	Stunning Strike
 		20549,--	War Stomp
 		103828,--	Warbringer


		
	}
	--phase1
	for i=1,#invpvps do
		if UnitDebuffID(Unit,invpvps[i])~=nil  then
			return true
		end
	end
	--phase2 imu
	if getBuffRemain(Unit,48792)~=0 or getBuffRemain(Unit,46924)~=0  then
		return true
	end
	return false
end

function canMaxStun(Unit)
	if Unit == nil then
		return false;
	end

	
	if isStun(Unit)  then StunTime = GetTime() end
	if StunTime ~= nil and GetTime()-18.6 > StunTime then StunTime = nil end
	if StunTime == nil then return true; --不会递减
	else 
	    return false ; --会递减
	end


end



function isEvade(Unit)  --能躲闪返回true
	if Unit == nil or isStun(Unit)==true then
		return false
	end
	local invpvpe = {
		118038,	-- 剑在人在
		5277,	--闪避  
		
		
	}
	for i=1,#invpvpe do
		if UnitBuffID(Unit,invpvpe[i])~=nil then
			--if getFacing(Unit,"player",100)==false then
				return true
		    --end
		    else return false;
		end
	end
	return false;
end


function isSlow(Unit)
	if Unit == nil then  
		return false
	end
	local pvpSlow = {
		1715,	-- zs断茎
		116,	-- Mage 冰箭
		120,	-- 冰锥
		5116, --震荡
		116095, --金刚震
		45524,	--dk冰链
		50041,  --冻疮
		20164, --公正
		12323, --刺耳
		6343, --雷霆
		3408, --减速毒药
		48484, --野德减速
		147531, --大姨妈减速


	}
	for i=1,#pvpSlow do
		if (getDebuffRemain(Unit,pvpSlow[i])>1.5 or getBuffRemain(Unit,1044)>1 or getBuffRemain(Unit,53271)>1 or getBuffRemain(Unit,46924)>1) then  -- or 有自由之手
			return true

		end
	end
	return false
end

function isLock(Unit)
	if Unit == nil then  
		return false
	end
	local pvpLock = {
		339,
		102359,
		128405,
		33395,
		122,
		116706,
		114404,
		64695,
		63685,
	}
	for i=1, #pvpLock do
		if getDebuffRemain(Unit,pvpLock[i]) > 2 or (getBuffRemain(Unit,1044)>1 or getBuffRemain(Unit,53271)>1 or getBuffRemain(Unit,46924)>1) then  
			return true
		end
	end
	return false
end


function Burst()
--初始属性
if ha==nil then 
    ha=GetHaste()
end
if ma==nil then
    ma=GetMastery()
end
if  mu==nil then 
    mu=GetMultistrike()
end
if cri==nil then
    cri=GetCritChance()
end

local str2 = UnitStat("player",1)
if not str0 or str2<str0 then
    str0 = str2
end

if ag0==nil then
   ag0=UnitStat("player",2)
end

if m0==nil then
   m0=UnitStat("player",4)
end


--当前属性
ha1=GetHaste()
ma1=GetMastery()
mu1=GetMultistrike()
cri1=GetCritChance()

--主属性
local str1=UnitStat("player",1)
local ag1=UnitStat("player",2)
local m1=UnitStat("player",4)

--panding
--[[local base=2*ma+1.5*cri+1.5*mu+1.4*ha+3*m0/1000+3*str0/1000+3*ag0/1000
local baofa=2*ma1+1.5*cri1+1.5*mu1+1.4*ha1+3*m1/1000+3*str1/1000+3*ag1/1000]]
local baofap=ma1/ma+cri1/cri+mu1/mu+ha1/ha+m1/m0+str1/str0+ag1/ag0

if baofap>7.25 then
    
        return true;
    else
    	return false;

    end
 
    

end

function Keyins(keynum,lagtime)
	if lagtime == nil then lagtime = 3 end
	if GetKeyState(keynum) then
    	if fztime==nil  then 
        	fztime = GetTime()
    	end
	else
    	if fztime~=nil and  fztime + lagtime < GetTime() then
        	fztime = nil;
    	end
	end
	if fztime~=nil and fztime + lagtime > GetTime() then
    	return true;    
	end
return false

end

--闭包双括号版本 Keyin0(52,3)()
function Keyin0(keynum,lagtime)
    local presstime

    if type(keynum) == "string" then
    	keynum = string.upper(keynum)
    	keynum = string.byte(keynum)
    end

    return function()
        if lagtime == nil then lagtime = 3 end
        if GetKeyState(keynum) then
            presstime = GetTime()
        end
        if presstime~=nil then
            
            if  presstime + lagtime > GetTime() then
                return true
            end
        else
            presstime=nil
        end
        return false
    end

    
end

function PalDispel(spellid)  --单体(sq驱散模型)驱散法术 疾病中毒魔法
	for i = 1, #nNova do
        if nNova[i].hp < 249 and getDebuffRemain(nNova[i].unit,30108)==0 and getDebuffRemain(nNova[i].unit,34914) == 0  then --除去痛苦无常和吸血鬼
            for n = 1,40 do
                local buff,_,_,count,bufftype,duration = UnitDebuff(nNova[i].unit, n)
                if buff then
                    if bufftype == "Magic" or bufftype == "Disease" or bufftype == "Poison" then
                        if castSpell(nNova[i].unit,spellid, true,false) then return; end
                    end
                else
                    break;
                    
                end
            end
        end
    end
    return false;
end

function MagicDispel(spellid)  --单体驱散有害魔法 直接调用
	for i = 1, #nNova do
        if nNova[i].hp < 249 and getDebuffRemain(nNova[i].unit,30108)==0 and getDebuffRemain(nNova[i].unit,34914) == 0  then --除去痛苦无常和吸血鬼
            for n = 1,40 do
                local buff,_,_,count,bufftype,duration = UnitDebuff(nNova[i].unit, n)
                if buff then
                    if bufftype == "Magic"  then
                        if castSpell(nNova[i].unit,spellid, true,false) then 
                        	return true; 
                        end
                    end
                else
                    break;
                    
                end
            end
        end
    end
    return false
end

function CurseDispel(spellid)  --单体驱散有害魔法 直接调用
	for i = 1, #nNova do
        if nNova[i].hp < 249  then 
            for n = 1,40 do
                local buff,_,_,count,bufftype,duration = UnitDebuff(nNova[i].unit, n)
                if buff then
                    if bufftype == "Curse"  then
                        if castSpell(nNova[i].unit,spellid, true,false) then return; end
                    end
                else
                    break;
                    
                end
            end
        end
    end
    return false
end


--返回表ta中第二小的元素和小标 奶骑道标
function Secondmin(ta)
    local temp1,temp2--,temp3;
    if (ta[1]<ta[2]) then
        temp1=1
        temp2=2
        
    else
        temp2=1
        temp1=2
    end
    if #ta<=2 then
        return ta[temp2],temp2
              
    else
        
        for i=3,#ta do
        	if ta[i] < ta[temp2] then

            	if ta[i] < ta[temp1] then
                	temp2=temp1
                	temp1=i
            	else
                	temp2=i
              
            	
            	end
            end
            
        end
        return ta[temp2],temp2;
        
    end
end

function Tta(radius,spellid,face) --图腾杀手
	if face == nil then face = false end
    if canCast(spellid) then
        for i = 1, #enemiesTable do
            local thisUnit = enemiesTable[i].unit
            if UnitCanAttack(thisUnit,"player") == true  and getLineOfSight("player", thisUnit) and getDistance("player",thisUnit) <= radius and ( UnitName(thisUnit) == "联盟军旗" or UnitName(thisUnit) == "部落军旗" or UnitName(thisUnit) == "灵魂链接图腾" or  UnitName(thisUnit) == "治疗之泉图腾" or UnitName(thisUnit) == "电能图腾" or   UnitName(thisUnit) == "陷地图腾" or UnitName(thisUnit) == "风行图腾" or UnitName(thisUnit) == "地缚图腾" or UnitName(thisUnit) == "暴雨图腾")  then
                if castSpell(thisUnit,spellid,face,false) then 
                	print("攻击", tostring(UnitName(thisUnit), "用" ,select(1,GetSpellInfo(spellid))))
                    return true
                end
            end
        end
    end
    return false 
        
end

function GlobalRef()
        for i = 1 , #enemiesTable do 
            local thisUnit = enemiesTable[i].unit
            if isCastingCCSpellLast(thisUnit) and  UnitCanAttack(thisUnit,"player") == true and enemiesTable[i].distance <= 30 then
            	print("探测到CC法术")
                return true;
            end

        end
    return false; 
end

function KillNear(spellid,percent,jl,face)
	if face == nil then
		face = false
	end
	local lasttar = nil;
	for i = 1 , #enemiesTable do
	local thisUnit = enemiesTable[i].unit
		if canAttack("player",thisUnit) and UnitHealth(thisUnit) > 1 and enemiesTable[i].distance <= jl and getHP(thisUnit) < percent and isInvincible(thisUnit) == false and UnitIsPlayer(thisUnit)  and UnitIsDeadOrGhost(thisUnit) == false and UnitHealth(thisUnit) > 2 then
			if castSpell(thisUnit,spellid,face,false,false,false,_,_,true) then
				print("用",tostring(select(1,GetSpellInfo(spellid))),"斩杀2.0于",UnitName(thisUnit))
				return true;
			end
		end
	end
return false
end

function KillNearm(spellid,percent,jl,face)
	if face == nil then
		face = false
	end
	local lasttar = nil;
	for i = 1 , #enemiesTable do
	local thisUnit = enemiesTable[i].unit
		if canAttack("player",thisUnit) and UnitHealth(thisUnit) > 1 and enemiesTable[i].distance <= jl and getHP(thisUnit) < percent and isMagicinv(thisUnit) == false and UnitIsPlayer(thisUnit)  and UnitIsDeadOrGhost(thisUnit) == false and UnitHealth(thisUnit) > 2 then
			if castSpell(thisUnit,spellid,face,false,false,false,_,_,true) then
				print("用",tostring(select(1,GetSpellInfo(spellid))),"斩杀2.0于",UnitName(thisUnit))
				return true;
			end
		end
	end
return false
end



function FHAutoLoot(checked)
 local looted = 0;
     
        for i=1,ObjectCount() do
            if ObjectType(ObjectWithIndex(i)) == 9 then
                local thisUnit = ObjectWithIndex(i)
                local hasLoot,canLoot = CanLootUnit(UnitGUID(thisUnit))
                local inRange = FHObjectDistance("player",thisUnit) < 2
                if UnitIsDeadOrGhost(thisUnit) then
		    
                     if hasLoot and canLoot then   
                           if checked == 1 then
			       UseItemByName(GetItemInfo(60854),thisUnit)  ---工程拾取器
                               if GetNumLootItems() > 0 then
                                   return true
                               end
                               looted = 1
			   else
			       if inRange then
			           InteractUnit(thisUnit)
				   if GetNumLootItems() > 0 then
                                        return true
                                   end
                                   looted = 1
			       else 
			           local X, Y, Z = PositionBetweenObjects(2,thisUnit,"player");
			           FaceDirection(AnglesBetweenObjects("player",thisUnit));
				   MoveTo(X, Y, Z);
                                   InteractUnit(thisUnit);
				   if GetNumLootItems() > 0 then
                                        return true
                                   end
                                  
                                   looted = 1
			       end
			   end
   
                    end
	     
                end
		
            end
       end
        if looted==1 and GetNumLootItems() == 0 then
            ClearTarget()
            looted=0
        end

	return false;

end

--自动嘲讽
function AutoTaunt(spellid,radius) 
    for i=1 , #enemiesTable do
        local thisUnit = enemiesTable[i].unit
        threatpct = select(3,UnitDetailedThreatSituation("player",thisUnit))
        if isLongTimeCCed(thisUnit)==false and isInCombat(thisUnit) and isBoss(thisUnit) ==false and UnitIsPlayer(thisUnit)==false and enemiesTable[i].distance <= radius and (threatpct == nil  or  threatpct < 100) then
            if castSpell(thisUnit,spellid,false,false,false,false) then
                return true
            end
        end
    end
    return false
end
--自动调整aoedps法术
function WiseAoe(unit,spellid,radius,nearbyradius)
	if nearbyradius == nil then
		nearbyradius = 8;
	end
	local maxnearbycount = 0;
	local maxunitnum = 1;
	for i = 1 , ObjectCount() do
		if bit.band(ObjectType(ObjectWithIndex(i)),0x8) > 0 and UnitExists(ObjectWithIndex(i)) == true  then --是一个有血量的Unit
			local  thisUnit = ObjectWithIndex(i);
			if getDistance("player",thisUnit) <= nearbyradius then

				local  nearbycount = getNumEnemies(thisUnit,nearbyradius) - 1 --附近数量减1
				if nearbycount >= maxnearbycount then
					maxnearbycount = nearbycount;
					maxunitnum = i;
				end
			end
		end

	end
	if maxnearbycount <1 then
		return false,nil;
	end
	--施法 返回第二个值为unit 
	if castGround(ObjectWithIndex(maxunitnum),spellid,radius) then
		return true,ObjectWithIndex(maxunitnum);
	end

	return false,nil;
end

--自动进攻驱散 保护和反恐结界
function GlobalDispel(spellid)
	if canCast(spellid) then
		for i = 1, #enemiesTable do
			local thisUnit = enemiesTable[i].unit
			if UnitCanAttack(thisUnit,"player") == true and enemiesTable[i].distance <= 40 and  UnitIsPlayer(thisUnit) and isMagicinv(thisUnit) == false and isLongTimeCCed(thisUnit) == false  then
				if getBuffRemain(thisUnit, 6346) > 2  or getBuffRemain(thisUnit, 1022) > 2 then
					if castSpell(thisUnit,spellid,false,false) then
						print("进攻驱散",UnitName(thisUnit))
						return true;
					end
				end
			end

		end
	end
	return false;
end
--pvp SS 3dot
function AffDots (unit)
	if  isLongTimeCCed(unit) == false and isMagicinv(unit) ==false  then
    --wc
    if getDebuffRemain(unit,30108,"player") < 5 then
        if castSpell(unit,30108,true,true,false) then
            return;
        end
    end
    --fs
    if getDebuffRemain(unit,172,"player") < 5.4 then
        if castSpell(unit,172,true,false,false) then
            return;
        end
    end
    --tc
    if getDebuffRemain(unit,980,"player") < 7.2 then
        if castSpell(unit,980,true,false,false) then
            return;
        end
    end
	end
	return false;
end
function MaxDoted(unit)
	if 	getDebuffRemain(unit,30108,"player") > 15 and getDebuffRemain(unit,172,"player") > 16 and getDebuffRemain(unit,980,"player") > 18 then
		return true;
	else 
		return false;
	end
end
function FullDoted(unit)
	if 	getDebuffRemain(unit,30108,"player") > 5 and getDebuffRemain(unit,172,"player") > 6 and getDebuffRemain(unit,980,"player") > 8 then
		return true;
	else 
		return false;
	end
end

function DotAround()
	for i = 1 , #enemiesTable do 
		local thisUnit = enemiesTable[i].unit
		--必须要有canattack
		if UnitCanAttack(thisUnit,"player") == true and UnitIsPlayer(thisUnit) and getDistance(thisUnit,"player") <= 40 and FullDoted(thisUnit) ==false then
			AffDots(thisUnit)
			--print("给",UnitName(thisUnit),"3Dot...ing")
			return true
		end
	end
	return false;
end
--治疗判定
function isHealer(unit)
local ClassNum = select(3, UnitClass(unit))
	if ClassNum == 2 then --Paladin
		if UnitManaMax(unit)>=100000 then
			return true;
		end
	end
	
	if ClassNum == 5 then --Priest
		if getBuffRemain(unit,15473)==0 then
			return true;
		end
	end
	
	if ClassNum == 7 then --Shaman
		if (getBuffRemain(unit,974,unit)>0 or getBuffRemain(unit,52127)>0) and getBuffRemain(unit,324,unit) == 0 then
			return true;
		end
	end
	
	if ClassNum == 10 then --Monk
		if UnitManaMax(unit)>=100000 then
			return true;
		end
	end
	if ClassNum == 11 then --Druid
		if UnitManaMax(unit)>=100000 and getBuffRemain(unit,24858) == 0 then
			return true;
		end
	end
return false;
end
--返回一个身边的敌对治疗
function HealerNearby(radius)
	for i=1,#enemiesTable do
	local thisUnit=enemiesTable[i].unit
		if canAttack("player",thisUnit) and getDistance("player",thisUnit)<=radius and isHealer(thisUnit) and isLongTimeCCed(thisUnit)==false then
			return thisUnit;
		end
	end
	return false;
end
--可以进攻驱散
function canPD(unit)
	if unit==nil then
		unit="target"
	end
-- UnitBuff(Unit, i)
  	for i = 1 , 40 do
  		local _, _, _, _, buffType, _, _, _, stl, _, buffid = UnitBuff(unit, i)
  		-- Blackout Debuffs
  		

  			if buffType == "Magic" and stl then
  				return true;
  				
  			end  				
  	end
  	return false;
end
--
function CDBetween(spellid,u1,u2)
	if u1 == nil then
		u1 = 1.5 
	end
	if u2 == nil then
		u2 = 30
	end
	if u1>u2 then
		u1,u2 = u2, u1
	end
	if getSpellCD(spellid) >= u1 and getSpellCD(spellid) <= u2 then
		return true;
	end

	return false;
end

function hasPet()-- 宠物状态按钮
    for i=1, 10 do
        local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i);
        if name then
            return true;
        end
    end
    return false;
end

-- ttdp 优化自bb
function getTimeTo(unit,percent)
	unit = unit or "target"
	perchp = (UnitHealthMax(unit) / 100 * percent)
	if ttpthpcurr == nil then
		ttpthpcurr = 0
	end
	if ttpthpstart == nil then
		ttpthpstart = 0
	end
	if ttptimestart == nil then
		ttptimestart = 0
	end
	if ObjectExists(unit) and UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
		if ttpcurrtar ~= UnitGUID(unit) then
			ttppriortar = currtar
			ttpcurrtar = UnitGUID(unit)
		end
		if ttpthpstart == 0 and ttptimestart == 0 then
			ttpthpstart = UnitHealth(unit)
			ttptimestart = GetTime()
		else
			ttpthpcurr = UnitHealth(unit)
			ttptimecurr = GetTime()
			if ttpthpcurr >= ttpthpstart then
				ttpthpstart = ttpthpcurr
				timeToPercent = 999
			else
				if ((GetTime() - ttptimestart) == 0) or ((ttpthpstart - ttpthpcurr) == 0) then
					timeToPercent = 999
				elseif ttpthpcurr < perchp then
					timeToPercent = 0
				else
					timeToPercent = round2((ttpthpcurr - perchp)/((ttpthpstart - ttpthpcurr) / (ttptimecurr - ttptimestart)),2)
				end
			end
		end
	elseif not ObjectExists(unit) or not UnitIsVisible(unit) or ttpcurrtar ~= UnitGUID(unit) then
		ttpcurrtar = 0
		ttppriortar = 0
		ttpthpstart = 0
		ttptimestart = 0
		ttptimeToPercent = 0
	end
	if timeToPercent==nil then
		return 999
	else
		return timeToPercent
	end
end

function getEnemiesAngel(radius,angel)
    local enum=0;
    for i = 1,#enemiesTable do
        local thisunit = enemiesTable[i].unit;
        if getDistance(thisunit,"player") <= radius and canAttack(thisunit,"player") and getFacing("player",thisunit,angel) == true then
            enum = enum + 1;
        end
    end
    return enum;
end
--angeled pvp unit count
function getEnemiesAngelp(radius,angel)
    local enum=0;
    for i = 1, #enemiesTable do
        local thisunit = enemiesTable[i].unit;
        if getDistance(thisunit,"player") <= radius and canAttack(thisunit,"player") and getFacing("player",thisunit,angel) == true and UnitIsPlayer(thisunit) then
            enum = enum+ 1;
        end
        
    end
    return enum
end
--pvp how many rivals are targeting me   tested**
function getNumTargeting(unit,radius)
	local hitcount = 0;
	if unit == nil then
		unit = "player"
	end
	if radius == nil then
		radius = 40;
	end
	for i = 1, #enemiesTable do
	
		local thisunit = enemiesTable[i].unit;
		if getDistance(thisunit,unit) <= radius and canAttack(thisunit,unit) and UnitGUID(thisunit.."target") ~= UnitGUID(unit) 
 and UnitIsPlayer(thisunit) and UnitIsDeadOrGhost(thisunit) == false and isLongTimeCCed(thisunit) == false and isHealer(thisunit) == false then
			hitcount = hitcount + 1;
		end
	end
	return hitcount;
end

--castcursor
function castCursor(spellid)
	if getSpellCD(spellid) <= 0.5  then 
		CastSpellByName(GetSpellInfo(spellid));
		if SpellIsTargeting() then 
			CameraOrSelectOrMoveStart();
			CameraOrSelectOrMoveStop();
			return true
		end
		
	end
	return false;
end
