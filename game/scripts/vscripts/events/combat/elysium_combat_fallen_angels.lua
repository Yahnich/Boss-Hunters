local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 1 + RoundManager:GetCurrentRaidTier() * 2
	self.eventEnded = false
	self.eventHandler = Timers:CreateTimer(3, function()
		local spawn = CreateUnitByName("npc_dota_boss_fallen_one", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundBoss = true
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 8 / GameRules:GetGameDifficulty()
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
	self.eventEnded = true
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss_fallen_one", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs