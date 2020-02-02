local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.eventType = RandomInt( 1, 3 )
	if self.eventType == 1 then
		self.rattleTraps = 1 + RoundManager:GetCurrentRaidTier()
	elseif self.eventType == 2 then
		self.tinkerers = RoundManager:GetCurrentRaidTier() * 2
	else
		self.rattleTraps = RoundManager:GetCurrentRaidTier()
		self.tinkerers = RoundManager:GetCurrentRaidTier()
	end
	self.tinkerers = self.tinkerers + math.floor( math.min( math.sqrt( RoundManager:GetEventsFinished()), 5  ) + 0.5 )
	self.enemiesToSpawn = self.rattleTraps + self.tinkerers
	self.eventHandler = Timers:CreateTimer(3, function()
		local enemyName = "npc_dota_boss8a"
		if RollPercentage(50) then
			enemyName = "npc_dota_boss8b"
		end
		local spawn = CreateUnitByName(enemyName, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundNecessary = true
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 15 / (GameRules:GetGameDifficulty() + 1)
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
	PrecacheUnitByNameSync("npc_dota_boss8a", context)
	PrecacheUnitByNameSync("npc_dota_boss8b", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs