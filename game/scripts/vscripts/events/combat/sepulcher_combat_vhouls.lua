local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = math.min(15, 3 + math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) ) )
	self.eventHandler = Timers:CreateTimer(3, function()
		local vhoulName = "npc_dota_boss1"
		if RollPercentage(50) then
			vhoulName = "npc_dota_boss2"
		end
		local spawn = CreateUnitByName(vhoulName, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundNecessary = true
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 7
		end
	end)
	
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
	}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss1", context)
	PrecacheUnitByNameSync("npc_dota_boss2", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs