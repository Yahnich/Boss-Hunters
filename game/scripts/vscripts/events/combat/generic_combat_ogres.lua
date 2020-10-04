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
	PrecacheUnitByNameSync("npc_dota_boss13", context)
	PrecacheUnitByNameSync("npc_dota_boss14", context)
	PrecacheUnitByNameSync("npc_dota_boss15", context)
	PrecacheUnitByNameSync("npc_dota_boss16", context)
	PrecacheUnitByNameSync("npc_dota_mini_boss2", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs