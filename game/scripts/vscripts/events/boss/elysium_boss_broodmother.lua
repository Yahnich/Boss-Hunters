local function StartEvent(self)
	self:StartCombatRound()
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss37", context)
	PrecacheUnitByNameSync("npc_dota_creature_broodmother", context)
	PrecacheUnitByNameSync("npc_dota_creature_broodmother_egg", context)
	PrecacheUnitByNameSync("npc_dota_creature_spiderling", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs