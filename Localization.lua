GD = {};
GD.Addons={};
GD.Player={};
GD.Player.Name=UnitName("player");
GD.Player.Class,GD.Player.EClass  = UnitClass("player")
GD.Player.GCD=0
GD.Config={};
GD.Config.SetGCD = false;
GD.Config.SetGCD_Time=0;
GD.Config.SpellAttackTime=0;
GD.Config.PromptSpellAttackTime=0;
GD.Config.SPELL_STOP_TIME=3;
GD.Config.Arena={};
GD.Colors={};
GD.Colors.RED = "|cffff0000";
GD.Colors.GREEN = "|cff00ff00";
GD.Colors.BLUE = "|cff0000ff";
GD.Colors.MAGENTA = "|cffff00ff";
GD.Colors.YELLOW = "|cffffff00";
GD.Colors.LGREEN = "|cffEEAA22";
GD.Colors.WHITE = "|cffffffff";
GD.AutoMacro={};
GD.Spell={}
GD.Spell.Sleep=GetTime(); 
GD.Spell.Variable={};
GD.Spell.Event={}
GD.Spell.Event.FollowUnit=false;
GD.Spell.Event.Combat=0;
GD.Spell.Event.PetCombat=0;
GD.Spell.Event.Proposal=false;
GD.Spell.Event.PhraseText="";
GD.Spell.Combat=nil;
GD.Spell.Combat_Sleep=GetTime();
GD.Spell.Property={};
GD.Spell.PropertyTime=0.003;
GD.Spell.Failed={};
GD.Spell.Casting={};
GD.Spell.Delay ={};
GD.Spell.Delay_Sleep=GetTime();
GD.Spell.Miss={};
GD.Spell.Miss.MissType={};
GD.Spell.Miss.Name={};
GD.Spell.ArrangeBattleSleep=GetTime();
GD.Spell.Class={};
GD.Spell.Class["WARLOCK"] = "术士" ;	
GD.Spell.Class["WARRIOR"] = "战士" ;	
GD.Spell.Class["HUNTER"] = "猎人" ;	
GD.Spell.Class["MAGE"] = "法师" ;	
GD.Spell.Class["PRIEST"] = "牧师" ;	
GD.Spell.Class["DRUID"] = "德鲁伊" ;	
GD.Spell.Class["PALADIN"] = "圣骑士" ;	
GD.Spell.Class["SHAMAN"] = "萨满祭司" ;	
GD.Spell.Class["ROGUE"] = "盗贼" ;	
GD.Spell.Class["DEATHKNIGHT"] = "死亡骑士" ;	
GD.Spell.Class["MONK"] = "武僧" ;
if(GD.Player.EClass=="WARRIOR") then 
	GD.Player.GCD=25208 --撕裂
elseif(GD.Player.EClass=="PRIEST") then 
	GD.Player.GCD=585  --恢复
elseif(GD.Player.EClass=="PALADIN") then 
	GD.Player.GCD=20154 --正义圣印
elseif(GD.Player.EClass=="MAGE" ) then 
	GD.Player.GCD=168 --霜甲术
elseif(GD.Player.EClass=="ROGUE") then 
	GD.Player.GCD=1752 --影袭
elseif(GD.Player.EClass=="DRUID") then 
	GD.Player.GCD=5176 --愤怒
elseif(GD.Player.EClass=="SHAMAN") then 
	GD.Player.GCD=403 --闪电箭
elseif(GD.Player.EClass=="WARLOCK") then 
	GD.Player.GCD=687 --恶魔皮肤
elseif(GD.Player.EClass=="HUNTER") then 
	GD.Player.GCD=14318 --雄鹰守护
elseif(GD.Player.EClass=="DEATHKNIGHT") then
	GD.Player.GCD=49896 --冰结之触
elseif(GD.Player.EClass=="MONK") then
	GD.Player.GCD=100780 --贯日击
else
	GD.Player.GCD=0
end 
GD.Spell.RC = RC;
