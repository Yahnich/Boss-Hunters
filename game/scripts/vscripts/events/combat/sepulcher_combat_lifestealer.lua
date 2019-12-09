local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.lifestealersToSpawn = RoundManager:GetCurrentRaidTier()
	self.wormsToSpawn = 2 + RoundManager:GetCurrentRaidTier() * 6
	self.enemiesToSpawn = self.lifestealersToSpawn + self.wormsToSpawn
	self.lifestealerSpawnDelay = 12
	self.wormSpawnDelay = 1
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.lifestealersToSpawn > 0 and self.lifestealerSpawnTicker >= self.lifestealerSpawnDelay then
			local spawn = CreateUnitByName("npc_dota_boss7", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			self.lifestealersToSpawn = self.lifestealersToSpawn - 1
			self.lifestealerSpawnTicker = 0
		end
		if self.wormsToSpawn > 0 and self.wormSpawnTicker >= self.wormSpawnDelay then
			local spawn = CreateUnitByName("npc_dota_minion_carrion_worm", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			self.wormsToSpawn = self.wormsToSpawn - 1
			self.wormSpawnTicker = 0
		end
		if self.enemiesToSpawn > 0 then
			return 1
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
	PrecacheUnitByNameSync("npc_dota_boss7", context)
	PrecacheUnitByNameSync("npc_dota_minion_carrion_worm", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs