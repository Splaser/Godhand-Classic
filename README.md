# Godhand-Classic
Based on Firehack. Special thanks to l0l1dk, Badboy , Reel , Wowbee , Magiccast and etc. 
一、施法类
1. 单体施法类：castSpell(Unit,SpellID,FacingCheck,MovementCheck,SpamAllowed,KnownSkip)
参数：
Unit                      对象
SpellID                    法术ID
Facing                      面向：设定为true则无视面向施法，设定为false则面对才施法。 一般烟雾弹、陷阱、奥爆这类技能设为true。
MovementCheck      移动状态：设定为true则站立时施法，设定为false则移动时也施法
SpamAllowed         施法延迟：需要延迟释放填true，不需要填false
KnownSkip                 是否学习此法术检测：设定为true忽略检测，设定为false则学习此法术才释放。一般用于天赋点出来的技能，天赋点出来的技能选false。
实例：
    --毁灭打击
    if castSpell("target",20243,false,false) then
        return;
    end
        
    --震荡波
    if castSpell("target",46968,false,false,true,false) then
        return;
    end


2. 范围施法类：
castGround(Unit,SpellID,maxDistance),
castGroundBetween(Unit,SpellID,maxDistance),
castHealGround(Unit,SpellID,maxDistance).
UnitID                      对象
SpellID                    法术ID
maxDistance            对应法术的最大距离
castGround(Unit,SpellID,maxDistance)
在目标脚下丢绿圈技能。一般用于丢暴风雪，下火雨aoe，丢照明弹==情况。
castGroundBetween("target",1234,40)
这个函数是在你与目标之间的中心点位圆心放1234号技能。 1234号技能最大施法距离是40。比如猎人的冰冻陷阱，如果以目标位圆心，战士一冲锋你，就冻不上了，如果用这个函数，会放到你跟战士连线的中间，一冲锋就冻上了。
castHealGround(Unit,SpellID,maxDistance).专门用于丢治疗技能，比如萨满大雨。例子：
if castGround("target",33395,45) then
            return;
        end
这个是法爷水bb丢冰冻术，45码施法距离真亲儿子。
3.自动攻击类：
GDattack(a,b) a,b只能取0和1.
a 0表示有没有当前目标都执行，1表示只有当前有目标才执行。
b 0代表所有状态  1代表非战斗中。
GDattack(0,0)自动攻击最近目标。一般用于开始自动攻击。



二、Buff和Debuff类
2.1 增益Buff类

例子



1.getBuffRemain(Unit,BuffID)
获取Unit身上增益buff持续时间，返回的是持续剩余时间。无buff返回nil。
如果盗贼的养精蓄锐buff不存在就给自己丢养精蓄锐。
if not getBuffRemain("player",73651) then
        if castSpell("player",73651,true,false) then
            return;
        end
    end
2.getBuffStacks(Unit,BuffID)
获取Unit身上增益Buff的层数，返回的是层数。无buff返回nil。3.getBuffDuration(Unit,BuffID)
获取buff第一次丢上去的最长时间

2.2 减益Debuff类
1.getDebuffRemain(Unit,DebuffID)
获取Unit身上减益Debuff持续时间，返回的是持续剩余时间。无buff返回nil。
2.getDebuffStacks(Unit,DebuffID)
获取Unit身上减益Debuff的层数，返回的是层数。无buff返回nil。
例子：
    if  getDebuffRemain("target",112948)<=2 then
        if castSpell("target",112948,false,true,true,false) then
            return;
        end
    end

如果目标身上没有寒冰炸弹或者寒冰炸弹持续时间少于2秒，就对他丢寒冰炸弹。
3.getDebuffDuration(Unit,DebuffID) 
获取debuff第一次丢上去的最长时间。

这个容易弄混注意用对函数。


三、状态判定
1. canAttack(Unit1,Unit2)
U1如果可以攻击U2，返回true否则返回false。
if canAttack("player","target") then
xxxxx
如果玩家可以攻击目标，就执行以下的。


2. canDispel(Unit,spellID)
如果Unit上有可以被对应法术id驱散的法术，就返回true。


3. canHeal(Unit)
Unit可以被治疗，返回true。


4. canInterrupt(Unit,percentint) 参数有2位，第一位填你使用的打断技能ID，第二位为打断的施法进度条百分比，如果不填第二位参数，在随机在读条百分之5-15进度之间打断。例子：


if  canInterrupt ("target") then
    if castSpell("target",6552,true,false) then
        return;
    end
end
4.5 castingUnit(Unit) - 如果Unit在读条，返回true，没有判定可以打断与否的状态，用法类似上例。



5. getPetLineOfSight(Unit)
这个是防止宠物卡视角用的，自动让宠物留在Unit的视野里。一般宝宝丢技能配合cast类函数使用。


6.getNumEnemies(Unit,r)
获取目标周围距离r半径内的敌对玩家目标数量，返回的是大于1的整数。
例子：
    if getNumEnemies("target",8)>=2 and getPetLineOfSight("target") and not UnitBuffID("player",44544)
    then
        if castGround("target",33395,45) then
            return;
        end
    end
如果目标周围8码敌人多于1个并且自身无寒冰指就丢目标水元素的冰冻术。

7.弃用getFacingSight()函数，现在使用getFacing()函数作为判定，返回值为true or false
     增加了getFacing()函数的参数，第三个参数为判定角度。
     范例：getFacing("player","target",100)此语句意思为，当目标在玩家的100°视野内。如果不填第三个参数，默认为90°。


8. isInCombat(Unit)
在战斗状态的判定，在战斗中返回true。


9.getHP(Unit)
这个函数比较特殊，只能返回血量百分比，返回的是不带百分号的0到100的四舍五入整数。如果需要判定具体数值需要换算。

10.getSpellCD(spellID)
获取对应法术的冷却cd时间，返回的是数值。用于具体条件判断。
11.canInterrupt(Unit) 施法状态获取
用于获取当时读条与否的状态，在读条返回true。
丢打断的例子：

if canInterrupt("target") == true then
     if castSpell("target",132409,false,false) then
          return;
     end
end



12.getAllies(Unit,Radius) 获取目标队半径Radius内周围的友好目标数量

13. UnitPower(Unit,A)A整数代表特殊能量的种类：
SPELL_POWER_MANA 0 法力
SPELL_POWER_RAGE 1 怒气 
SPELL_POWER_FOCUS 2 集中
SPELL_POWER_ENERGY 3 能量
SPELL_POWER_RUNES 5 符文
SPELL_POWER_RUNIC_POWER 6 符文能量
SPELL_POWER_SOUL_SHARDS 7 灵魂碎片
SPELL_POWER_ECLIPSE 8 日月蚀
SPELL_POWER_HOLY_POWER 9 圣能
ALTERNATE_POWER_INDEX 10 Cataclysm New power type since Cataclysm. Known uses: sound level on Atramedes, corruption level on Cho'gall, consumption level while in Iso'rath.
SPELL_POWER_ALTERNATE_POWER 10 MoP The new (renamed) variable representing alternate power in Mists of Pandaria
SPELL_POWER_DARK_FORCE 11 MoP Currently unused.
SPELL_POWER_LIGHT_FORCE 12 真气
SPELL_POWER_SHADOW_ORBS 13 暗影宝珠
SPELL_POWER_BURNING_EMBERS 14 爆燃灰烬
SPELL_POWER_DEMONIC_FURY 15 恶魔之怒 

13.5 UnitPowerMax("player")这个是获取能量的最大上限



14.getCharges(spellID)获取技能积累的层数，用于判定ss点过阿克蒙德的黑暗的两层黑魂，武僧的酒等等。




15.getFallTime()
获取自己的掉落时间，用于判定是不是处于下落的空中。


16.IsSwimming()
获取自己是否处于游泳状态。


17. UnitIsDeadOrGhost(Unit)
判定目标的死活状态。死了返回true。


18. useItem(itemID) - 使用物品或药水


其他有用的GET类函数

getAllies(Unit,Radius) - 返回以Unit为圆心Radius为半径的友方目标数组
-Unit - 对象
-Radius - 半径

getCombatTime() - 返回进入战斗的时间

getCombo() - 返回连击点数

getDistance(Unit1,Unit2) - 返回Unit1与Unit2的距离

getEnemies(Unit,Radius) - 返回以Unit为圆心Radius为半径的敌方目标数组
-Unit - 对象
-Radius - 半径

getFacing(Unit1,Unit2,Degrees)        - 如果Unit2在Unit1的Degrees角度内，返回true
-Degrees - 角度 - 缺省为90

getFallTime() - 返回掉落时间

getGround(Unit) - 如果Unit在地面上，返回true

getLineOfSight(Unit1,Unit2) - 如果Unit2在Unit1的视野范围内，返回true

getLowAllies(Value) - 返回团队模块调用后，低于Value生命值的队友数量

getMana(Unit) - 返回Unit的魔法值

getPetLineOfSight(Unit) - 如果Unit在宠物的视野中，返回true

getTimeToDie(unit) - 返回Unit预计死亡时间（根据之前时间对比的掉血量）

getTotemDistance(Unit) - 返回图腾与Unit的距离

其他有用的IS类函数


isAlive(Unit) - 如果Unit没死，返回true


isBoss() - 如果在BOSS战斗中，返回true


isBuffed(UnitID,SpellID,TimeLeft) - 如果Unit身上有SpellId并且剩余时间大于TimeLeft，返回true，TimeLeft缺省为0


isCasting(SpellID,Unit) - 如果Unit在读条SpellID技能，返回true


isCastingSpell(spellID) - 如果玩家在读条SpellID技能，返回true


isDummy(Unit) - 如果Unit是木桩，返回true


isEnemy(Unit) - 如果Unit可以被攻击，返回true


isInCombat(Unit) - 如果Unit在战斗中，返回true


isInMelee(Unit) - 如果Unit在玩家近战范围内，返回true


isInPvP() - 如果玩家在PVP状态，返回true


isKnown(spellID) - 如果学了spellID这个法术，返回true


isLooting() - 如果你在捡东西，返回true


isMoving(Unit) - 如果Unit在移动，返回true


IsMovingTime(time) - 如果你移动的时间超过time，返回true


isSpellInRange(SpellID,Unit) - 如果Unit在你的SpellID技能范围内，返回true


isValidTarget(Unit) - 如果Unit是个存在的目标，返回true






四、模块声明类

1. GroupInfo()
这个声明放在脚本前端，说明启用了团队框架模块，支持循环判定自己团/队各个成员。
之后我们就可以：
用#members代替团队成员个数；用nNova.Dispel==true 获取驱散目标
在for i，#members循环中，用members.Unit代替函数中Unit目标部分，从而实现各种复杂的循环判定。
具体例子，可以参考我的戒律牧填坑方案。大量运用。效率很高，这个循环下来比yj的执行效率高很多倍。
教程

--临时解释分割线暂时引用

2. SuperReader()
这个声明放在脚本前端，说明启用了战斗记录提取模块。以下是放出的四种特定dot专用判定函数
CRKD()
预计的实时斜掠dot伤害
RKD()
当前实际斜略dot伤害

CRPD()
预计当前法伤/ap下的实时割裂伤害
RPD()
实际割裂伤害

getDistance2(Unit1,Unit2)
检测任意目标对你进行的行为你是否有足够的距离进行反制（如果有圣骑走过来制裁你，当快接近制裁距离的时候，你就先用某技能控制他，期间不需要切换目标）。定义
local tarDist = getDistance2("target")
GH就会自动在条件里用tarDist当做距离判定从tarDist的赋值范围内进行目标判定。 

hasNoControl()
判定自己是否处于失控状态（temp）

3.dynamicTarget(Number)
这个声明放在脚本前端，说明启用了动态目标检测模块，同近战范围智能AOE判定。
--容易引起掉线还在测试中
待测试

4. makeEnemiesTable(r) 生成一个40码内的敌对目标数组，会自动检测40码内所有敌对目标。对应的下属判定条件：
1. 用enemiesTable.unit 对应符合条件的目标
2. 用enemiesTable.distance  对应符合条件的目标的距离
3. 用enemiesTable.hp 对应符合条件的目标的血量--203更新
castingUnit(Unit) - 如果Unit在读条，返回true
useItem(itemID) - 使用物品或药水

useAoE(Radius) - 以自身为圆心Radius为半径进行AOE判定，必须有"智能AoE"和"AoE计数"这两个UI选项，且名称必须为这两个

GlobalInterrupt(spellid,radius,percentint) - 使用spellid技能对以自身为圆心Radius为半径的范围内所有敌人进行打断，不用切换目标或者做焦点

