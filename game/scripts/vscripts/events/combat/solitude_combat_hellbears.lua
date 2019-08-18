local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	local roll = RandomInt( 1, 3 )
	if roll == 1 then
		self.direBear = 1 + RoundManager:GetCurrentRaidTier()
		self.minorBear = 2 + RoundManager:GetCurrentRaidTier() * 2
		self.enemiesToSpawn = self.direBear + self.minorBear
	elseif roll == 2 then
		self.direBear = 2 + RoundManager:GetCurrentRaidTier() * 2
		self.minorBear = 0
		self.enemiesToSpawn = self.direBear + self.minorBear
	else
		self.direBear = 0
		self.minorBear = 2 + RoundManager:GetCurrentRaidTier() * 4
		self.enemiesToSpawn = self.direBear + self.minorBear
	end
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.direBear > 0 then
			local spawn = CreateUnitByName("npc_dota_boss_greater_centaur", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.direBear = self.direBear - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
		end
		if self.minorBear > 0 then
			local spawn = CreateUnitByName("npc_dota_boss_lesser_centaur", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.minorBear = self.minorBear - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
		end
		if self.enemiesToSpawn > 0 then
			return 20 / GameRules:GetGameDifficulty()
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
	PrecacheUnitByNameSync("npc_dota_dire_hellbear", context)
	PrecacheUnitByNameSync("npc_dota_minor_hellbear", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs