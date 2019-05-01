local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.set = self.set or RandomInt(1,2)
	if self.set == 1 then
		self.reapersToSpawn = 2 + RoundManager:GetCurrentRaidTier()
		self.vanguardToSpawn = 3
	else
		self.reapersToSpawn = 2
		self.vanguardToSpawn = 3 + RoundManager:GetCurrentRaidTier()
	end
	self.enemiesToSpawn = self.reapersToSpawn + self.vanguardToSpawn
	local maxEnemies = self.enemiesToSpawn
	self.eventHandler = Timers:CreateTimer(3, function()
		local enemyName = "npc_dota_boss24_archer"
		if RollPercentage(self.vanguardToSpawn/maxEnemies) or self.reapersToSpawn == 0 then
			enemyName = "npc_dota_boss24_stomper"
		else
			self.reapersToSpawn = self.reapersToSpawn - 1
		end
		local spawn = CreateUnitByName(enemyName, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundNecessary = true
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 3
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
	PrecacheUnitByNameSync("npc_dota_boss24_archer", context)
	PrecacheUnitByNameSync("npc_dota_boss24_stomper", context)
	PrecacheUnitByNameSync("npc_dota_boss24_m", context)
	return true
end


local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs