local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.bigCentaur = 1
	self.smallCentaur = RoundManager:GetCurrentRaidTier() + 1 
	self.enemiesToSpawn = self.bigCentaur
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.bigCentaur > 0 then
			local spawn = CreateUnitByName("npc_dota_boss_greater_centaur", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.bigCentaur = self.bigCentaur - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
		end
		for i = 1, self.smallCentaur do
			local spawn = CreateUnitByName("npc_dota_boss_lesser_centaur", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
		end
		if self.bigCentaur > 0 then
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
	PrecacheUnitByNameSync("npc_dota_boss_greater_centaur", context)
	PrecacheUnitByNameSync("npc_dota_boss_lesser_centaur", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs