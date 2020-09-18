local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.eventTypeSpawns= RandomInt( 1, 3 )
	self.tinkerers = 0
	self.rattleTraps = 0
	if self.eventTypeSpawns == 1 then
		self.rattleTraps = 2 + RoundManager:GetCurrentRaidTier()
	elseif self.eventTypeSpawns == 2 then
		self.tinkerers = 1 + RoundManager:GetCurrentRaidTier() * 2
	else
		self.rattleTraps = RoundManager:GetCurrentRaidTier()
		self.tinkerers = RoundManager:GetCurrentRaidTier()
	end
	self.tinkerers = self.tinkerers + (RoundManager:GetCurrentRaidTier() - 1)*(RoundManager:GetAscensions() + 2)
	self.enemiesToSpawn = self.rattleTraps + self.tinkerers
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.tinkerers > 0 then
			local spawn = CreateUnitByName("npc_dota_boss8b", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			self.tinkerers = self.tinkerers - 1
		end
		if self.rattleTraps > 0 then
			local spawn = CreateUnitByName("npc_dota_boss8a", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			self.rattleTraps = self.rattleTraps - 1
		end
		
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