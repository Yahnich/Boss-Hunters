local function StartEvent(self)
	self:StartCombatRound()
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	self.eventEnded = true
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss_greymane", context)
	PrecacheUnitByNameSync("npc_dota_boss_wolf", context)
	PrecacheUnitByNameSync("npc_dota_boss_alpha_wolf", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs