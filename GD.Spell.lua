function GD_Message(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end;

function GD_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
	self:RegisterEvent("PLAYER_ENTER_COMBAT");
	self:RegisterEvent("PLAYER_LEAVE_COMBAT");
	self:RegisterEvent("PLAYER_LOGOUT")	;
	self:RegisterEvent("COMBAT_TEXT_UPDATE")	;
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("CHAT_MSG_WHISPER");
	self:RegisterEvent("COMBAT_LOG_EVENT");
	self:RegisterEvent("LFG_PROPOSAL_SHOW")	
	
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM");
	self:RegisterEvent("CHAT_MSG_ADDON");

	self:RegisterEvent("AUTOFOLLOW_BEGIN");
	self:RegisterEvent("AUTOFOLLOW_END");
	self:RegisterEvent("ACTIONBAR_UPDATE_STATE");
	self:RegisterEvent("ACTIONBAR_UPDATE_USABLE");

	self:RegisterEvent("PET_ATTACK_START");
    self:RegisterEvent("PET_ATTACK_STOP");
	
	self:RegisterEvent("UNIT_HEAL_PREDICTION"); -- 获得治疗目标
	self:RegisterEvent("UNIT_SPELLCAST_SENT"); -- 施放目标技能

	self:RegisterEvent("UNIT_SPELLCAST_STOP");
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	self:RegisterEvent("UNIT_SPELLCAST_FAILED");
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	self:RegisterEvent("UNIT_COMBAT");
	GD_Load();
end

function GD_OnEvent(self, event,...)
	GD_SpellMiss_OnEvent(self,event,...);
	GD_SpellFailed_OnEvent(self,event,...);

	if ( event == "PLAYER_ENTER_COMBAT" )  then
		GD.Spell.Event.Combat=1;
	elseif ( event == "PLAYER_LEAVE_COMBAT" )  then
		GD.Spell.Event.Combat=0;
	elseif ( event == "PET_ATTACK_START" )  then
        GD.Spell.Event.PetCombat=1;
    elseif ( event == "PET_ATTACK_STOP" )  then
        GD.Spell.Event.PetCombat=0;
	elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED")  then--?
	--[[
		if GD.Spell.Miss1 then
			if arg3 == UnitGUID("player") then
				local spellID = arg9
				local timpw = GetSpellInfo(spellID)
				print("技能ID对照",timpw,spellID)
			end
		end
		
		local _, _, prefix, suffix = string.find(arg2, "(.-)_(.+)")
		local src = arg4
		local time=GetTime()
				
		if src==GD.Player.Name then 
			--local spellname=select(10,...) or nil;
			local spellname=arg10
					
			if spellname=="风怒攻击" then
				GD.Spell.Event.Spell.Hot.Times[spellname]=GetTime() + 4;
			end
		end
		
		if (prefix=="SWING") then
			if suffix=="MISSED" then
				if (arg9)=="DODGE"  and arg4==GD.Player.Name then
					GD.Spell.Event.Combat.DODGE.Sleep = GetTime();
					GD.Spell.Event.Combat.DODGE.Start=1
				elseif (arg9)=="PARRY"  and arg7==GD.Player.Name  then
					GD.Spell.Event.Combat.PARRY.Sleep = GetTime();
					GD.Spell.Event.Combat.PARRY.Start=1
				end
			end
		elseif (prefix=="SPELL") then	
		end 
	]]
	end
	
	if (event=="CHAT_MSG_WHISPER" and GD.Spell.Event.PhraseText ~= "") then--GD.Sync.Verify > 0
		if UnitGUID("player")~=UnitGUID(arg2) then
			SendChatMessage(GD.Spell.Event.PhraseText,"WHISPER",nil,arg2)
		end
	end
	
	if (event == "LFG_PROPOSAL_SHOW" and GD.Spell.Event.Proposal) then--GD.Sync.Verify > 0
		GDRun("/run AcceptProposal()");
	end
	
	if (event=="AUTOFOLLOW_BEGIN") then
		GD.Spell.Event.FollowUnit=arg1;
	elseif (event=="AUTOFOLLOW_END") then
		GD.Spell.Event.FollowUnit=nil;
	end
	

end

function GD_OnUpdate(arg1)
	if GetTime() - GD.Spell.Combat_Sleep >1 then
		local temp=UnitAffectingCombat("player");
		
		if  temp and not GD.Spell.Combat then
			GD.Spell.Combat=1;--print("进入战斗")
		elseif not temp and GD.Spell.Combat then
			GD.Spell.Combat=nil;--print("离开战斗")
		end
		GD.Spell.Combat_Sleep=GetTime();
	end
	
	if GetTime() - GD.Spell.Delay_Sleep >1 then
		if(GD.Spell.Delay and type(GD.Spell.Delay) == "table" )then
			for k, v in pairs(GD.Spell.Delay) do
				if type(v) == "table" then
					for k1, v1 in pairs(v) do
						if v1 and type(v1) == "table" and not v1["DelayTime"] and v1["Status"] and v1["Status"] == "End" and (not v1["EndTime"] or GetTime() - v1["EndTime"]>1)then
							GD.Spell.Delay[k][k1]=nil;
						end
					end
				end
				
				local  cc=0;
				table.foreach(GD.Spell.Delay[k], function(i2, v2) cc=cc+1; end);

				if( cc==0) then
					GD.Spell.Delay[k]=nil;
				end
			end
		end
		GD.Spell.Delay_Sleep=GetTime();
	end
end;

function GD_Load()
		
		if not GD.Config.OLDSPELL_STOP_TIME then
			GD.Config.OLDSPELL_STOP_TIME = GD.Config.SPELL_STOP_TIME;
			GD.Config.SPELL_STOP_TIME=0.5;
		end
		
		if not GD.Config.Formats or (GD.Config.Formats and not GD.Config.Formats["判断结果"]) then
			GD.Config.Formats={};
			GD.Config.Formats["判断结果"]="结果:%s";
			GD.Config.Formats["技能类型"]="类型:%s";
			GD.Config.Formats["说明"]="说明:%s";
			GD.Config.Formats["施放目标"]="目标:%s";
			GD.Config.Formats["技能名称"]="技能:%s";
			GD.Config.Formats["冷却时间"]="冷却:%.1f"
			GD.Config.Formats["过滤调试信息"]="";
		end
		
		if not GD.Config.IsShow or (GD.Config.IsShow and not GD.Config.IsShow["显示调试信息"]) then
			GD.Config.IsShow={};
			GD.Config.IsShow["显示调试信息"]=nil;
			GD.Config.IsShow["显示成功的调试信息"]=nil;
			GD.Config.IsShow["显示失败的调试信息"]=nil;
			GD.Config.IsShow["显示判断结果"]=true;
			GD.Config.IsShow["显示技能类型"]=true;
			GD.Config.IsShow["显示说明"]=true;
			GD.Config.IsShow["显示施放目标"]=true;
			GD.Config.IsShow["显示技能名称"]=true;
			GD.Config.IsShow["显示冷却时间"]=true;
			GD.Config.IsShow["过滤调试信息"]=nil;
		end
end


GD.cls={{101,112,100},{98,111,101},{112,110,110}}

function GD_SpellMiss_OnEvent(self, event,...) --//amtob
	--[[local arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16;
	arg1,arg2 = select(1, ...);
	arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16 = select(4, ...);]]
	
	local arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16;

	if tonumber((select(4, GetBuildInfo()))) >= 40200 then	
		arg1,arg2 = select(1, ...);
		arg3,arg4,arg5,_,arg6,arg7,arg8,_,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16 = select(4, ...);
	else
		arg1,arg2 = select(1, ...);
		arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16 = select(4, ...);
	end
	
	if ( event == "COMBAT_LOG_EVENT_UNFILTERED" and arg2)  then
	
		local _, _, prefix, suffix = string.find(arg2, "(.-)_(.+)")
		local playerName = UnitName("player");
		local SMT= GD.Spell.Miss.MissType;
		
		if (playerName == arg4 or playerName == arg7) then
		
			if arg9=="DODGE" or arg9=="RESIST" or arg9=="PARRY" or arg9=="MISS" or arg9=="BLOCK"  or arg9=="REFLECT"  or arg9=="DEFLECT"  or arg9=="IMMUNE"  or arg9=="EVADE" then	
				local T = GetTime();
				SMT[arg9] = SMT[arg9] or {};
				
				if arg3 then
					SMT[arg9]["SourceGUID-" .. arg3] = T;
				end
				
				if arg6 then
					SMT[arg9]["DestGUID-" .. arg6] = T;
				end
				
				if arg3 and arg6 then
					SMT[arg9][arg3 .. "-" .. arg6] = T;
				end
				
				SMT[arg9]["Time"]=T;			
			end
			
			GD.Spell.Miss.Name[tostring(arg10)] = GetTime();
		end
		
		if suffix =="INTERRUPT" or suffix =="MISSED" or suffix =="CAST_SUCCESS" or suffix =="CAST_FAILED" or suffix =="CREATE" or suffix =="SUMMON" or suffix =="INSTAKILL" or suffix =="EXTRA_ATTACKS" or suffix =="ENERGIZE" or suffix =="HEAL" then
			GD.Spell.Miss.Name[arg3 .. "_" .. tostring(arg10)] = GetTime();
		end
	end
end

function GD_SpellFailed_OnEvent(self, event, ...)
	--[[local arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16;
	arg1,arg2 = select(1, ...);
	arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16 = select(4, ...);]]
	
	local arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16;

	if tonumber((select(4, GetBuildInfo()))) >= 40200 then	
		arg1,arg2 = select(1, ...);
		arg3,arg4,arg5,_,arg6,arg7,arg8,_,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16 = select(4, ...);
	else
		arg1,arg2 = select(1, ...);
		arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16 = select(4, ...);
	end
	
	
	--[[if (event == "ACTIONBAR_UPDATE_COOLDOWN")  then
		print("<<",arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16);
		local gcd = GDGCD();
		local spellName, spellSubName,skillType, spellId  ;
		if gcd==0 and GDCastSpell and GDCastUnit and UnitGUID(GDCastUnit) and IsCurrentSpell(GDCastSpell) then
			spellName, spellSubName =GetSpellInfo(GDCastSpell);
			GDCastInfo = GDCastInfo or {};
			GDCastInfo["SpellName"]=spellName;
			GDCastInfo["Macro"]="";
			GDCastInfo["Time"]=GetTime();
			GDCastInfo["Unit"]=GDCastUnit;
			GDCastInfo["SpellId"]=GDCastSpell;
			--print("<<",spellName,GetTime()-GDCastTime)
		elseif gcd==0 and GDCastUnit and GDCastSpell and not IsCurrentSpell(GDCastSpell) then
	
			local ac = GDUnitCastSpellName("player");

			if GDCastInfo and GDCastInfo["SpellName"] and GDCastInfo["Unit"] and not ac and GDCastInfo["Time"] and GetTime() -GDCastInfo["Time"]<1 and GetTime() -GDCastInfo["Time"]>0 then
				GDUnitCastSpellDelay(GDCastInfo["SpellName"],0.5,GDCastInfo["Unit"]);
			else
				GDCastInfo={};
			end
		end
	end]]
	
	--[[if (event == "UNIT_HEAL_PREDICTION")  then
		--print("1>>",event,arg1,arg2,arg3,arg4)
		local guid = UnitGUID(arg1);
		if guid then
			GD.Spell.Cast=GD.Spell.Cast or {};
			GD.Spell.Cast["HEAL_PREDICTION"]=GD.Spell.Cast["HEAL_PREDICTION"] or {};
			GD.Spell.Cast["HEAL_PREDICTION"][guid]=GD.Spell.Cast["HEAL_PREDICTION"][guid] or {};
			GD.Spell.Cast["HEAL_PREDICTION"][guid]["heal"]=UnitGetIncomingHeals(arg1);
			GD.Spell.Cast["HEAL_PREDICTION"][guid]["name"]=arg1;
		end
	end]]
	
	
	--[[if (event == "ACTIONBAR_UPDATE_COOLDOWN")  then
		local gcd = GDGCD();
		if(GD.Spell.Casting["Spell"])then
		print("-->>",gcd,GD.Spell.Casting["Spell"],IsCurrentSpell(GD.Spell.Casting["Spell"]))
		if gcd==0 and  not IsCurrentSpell(GD.Spell.Casting["Spell"]) then
		
			local ac = GDUnitCastSpellName("player");
			print("----",ac,0.5,GD.Spell.Casting["Spell"])

		end
		end
	end
	]]
	if (event == "UNIT_SPELLCAST_SENT") then

		local guid = UnitGUID(arg3);
		local target=arg3;
		--print(">>",UnitGUID(arg3),event,arg1,arg2,arg3,arg4)	
		if not arg3 or arg3=="" or arg3==UnitName("player") then
			guid = UnitGUID("player");
			target ="player";
		elseif not guid and arg3==UnitName("target") then
			guid = UnitGUID("target");
			target ="target";
		elseif not guid and arg3==UnitName("focus") then
			guid = UnitGUID("focus");
			target="focus";
		end

		if guid then
			GD.Spell.Casting=GD.Spell.Casting or {};
			
			local tbl = GD.Spell.Casting;
			
			tbl["Time"] = GetTime();
			tbl["Index"] = arg4;
			tbl["GUID"] = guid;
			tbl["Unit"] = target;
			tbl["Spell"]=arg2;
			tbl["SpellId"]=arg4;
			
			if(GD.Spell.Delay and GD.Spell.Delay[arg2])then
				if(GD.Spell.Delay[arg2][guid])then
					GD.Spell.Delay[arg2][guid]["Status"] = "Star";
				end
				if(GD.Spell.Delay[arg2]["All"])then
					GD.Spell.Delay[arg2]["All"]["Status"] = "Star";
				end
			end
		end
	end
	
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local _, _, prefix, suffix = string.find(arg2, "(.-)_(.+)")
		if (suffix=="CAST_FAILED") and UnitGUID("player") == arg3 and arg11 and arg12 and GD.Spell.Casting and GD.Spell.Casting["Time"] then
			local TEXT = arg12;
			if TEXT==SPELL_FAILED_UNIT_NOT_INFRONT or TEXT==SPELL_FAILED_OUT_OF_RANGE or TEXT==SPELL_FAILED_BAD_IMPLICIT_TARGETS or TEXT==SPELL_FAILED_LINE_OF_SIGHT or TEXT==SPELL_FAILED_TARGETS_DEAD or TEXT==SPELL_FAILED_BAD_TARGETS or TEXT==SPELL_FAILED_NOT_BEHIND then
				if GetTime() - GD.Spell.Casting["Time"]< select(3, GetNetStats())*2 + 0.7 then
					local guid = UnitGUID(GD.Spell.Casting["Unit"]);
					if guid then		
						GD.Spell.Failed = GD.Spell.Failed or {};
						GD.Spell.Failed[guid] = GD.Spell.Failed[guid] or {};
						GD.Spell.Failed[guid]["Time"]=GetTime();
						GD.Spell.Failed[guid]["Text"]=arg12;
						GD.Spell.Failed[guid]["SpellId"]=arg9;
						GD.Spell.Failed[guid]["SpellName"]=arg10;
					end
				end
			end
		end
	end
	
	if arg1 and UnitGUID("player") == UnitGUID(arg1) and ((event=="UNIT_SPELLCAST_STOP") or (event=="UNIT_SPELLCAST_SUCCEEDED") or (event=="UNIT_SPELLCAST_FAILED") or (event=="UNIT_SPELLCAST_INTERRUPTED")) then
		
    	--print("<<",event,arg1,arg2,arg3,arg4)
				
		if GD.Spell.Casting and GD.Spell.Casting["GUID"] then
			local guid = GD.Spell.Casting["GUID"];
			
			if(GD.Spell.Delay and GD.Spell.Delay[arg2])then
				if(GD.Spell.Delay[arg2][guid])then
					if GD.Spell.Delay[arg2][guid]["DelayTime"] then
						GD.Spell.Delay[arg2][guid]["EndTime"] = GD.Spell.Delay[arg2][guid]["DelayTime"] + GetTime();
						GD.Spell.Delay[arg2][guid]["DelayTime"] = nil;
					end
					GD.Spell.Delay[arg2][guid]["Status"] = "End";
				end
				if(GD.Spell.Delay[arg2]["All"])then
					if GD.Spell.Delay[arg2]["All"]["DelayTime"] then
						GD.Spell.Delay[arg2]["All"]["EndTime"] = GD.Spell.Delay[arg2]["All"]["DelayTime"] + GetTime();
						GD.Spell.Delay[arg2]["All"]["DelayTime"] = nil;
					end
					GD.Spell.Delay[arg2]["All"]["Status"] = "End";
				end
			end
		end
		GD.Spell.Casting = {};
	end
end
