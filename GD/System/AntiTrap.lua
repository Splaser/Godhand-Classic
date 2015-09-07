cachedTriggers = {}
GSSR = {}
updateTimeTrap = tonumber(ReadFile(""..GetFireHackDirectory().."\\Scripts\\SpellReflectTrap\\updatetime.ini"))
updateTimerTrap = updateTimeTrap
local alreadyElapsed = 0
local function existingCheck(self, elapsed)
	alreadyElapsed = alreadyElapsed+elapsed
	-- print(alreadyElapsed)
	if alreadyElapsed > updateTimerTrap then
		alreadyElapsed = 0
		for i = 1, ObjectCount() do
			local obj = ObjectWithIndex(i)
			if bit.band(ObjectType(obj), 0x100) > 0 and not tContains(cachedTriggers, obj) then
				cachedTriggers[#cachedTriggers+1] = obj
			end
		end
	elseif updateTimerTrap == 9999 --[[and GSSR.SIR(781)]] then
		for i = 1, ObjectCount() do
			local obj = ObjectWithIndex(i)
			if bit.band(ObjectType(obj), 0x100) > 0 and not tContains(cachedTriggers, obj) then
				if GSSR.Distance(obj, nil) <= 8 then
					GSSR.Cast(781)
					updateTimerTrap = updateTimeTrap
					return
				end
			end
		end
	end
end

local function hunterCheck(self, registeredevent, ...)
	local timestamp, event, hidecaster, sourceguid, sourcename, sourceflags, sourceraidflags, destguid, destname, destflags, destraidflags, spellid, spellname, spellschool, failedtype = ...
	if spellid == 60192 then
		updateTimerTrap = 9999
	end
end

function GSSR.Distance(target, base) -- compares distance between two objects if base == nil than base = player
	if not tonumber(target) then target = "player" end
	if not base or type(base) == "string" and string.len(base) >= 6 and string.sub(base, 1, 6) == "Player" then base = "player" end
	local X1, Y1, Z1 = ObjectPosition(target)
	local X2, Y2, Z2 = nil, nil, nil
	if not base then X2, Y2, Z2 = ObjectPosition("player") else X2, Y2, Z2 = ObjectPosition(base) end

	return math.sqrt(((X2 - X1) ^ 2) + ((Y2 - Y1) ^ 2) + ((Z2 - Z1) ^ 2))
end

function GSSR.Cast(Name) -- guid = unit, name = spellid or name, x,y,z = custom location if you want it (for aoe selection) else it'll cast at guid's position, interrupt is a string or table of strings of spells or channels you want to interrupt
	if type(Name) == "number" then Name = GetSpellInfo(Name) end
	CastSpellByName(Name)
end

SRTrap = CreateFrame("Frame", "SRTrap")
SRTrap:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
SRTrap:SetScript("OnEvent", hunterCheck)
SRTrap:SetScript("OnUpdate", existingCheck)
