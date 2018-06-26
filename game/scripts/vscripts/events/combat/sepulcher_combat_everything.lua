local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 4 + math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) )
	self.eventHandler = Timers:CreateTimer(3, function()
		local enemyName = ""
		local roll = RandomInt(1, 11)
		if roll <= 3 then
			enemyName = "npc_dota_boss1"
		elseif roll <= 6 then
			enemyName = "npc_dota_boss2"
		elseif roll <= 8 then
			enemyName = "npc_dota_boss3a"
		elseif roll <= 10 then
			enemyName = "npc_dota_boss3b"
		elseif roll == 11 then
			enemyName = "npc_dota_boss7"
		end
		local spawn = CreateUnitByName(enemyName, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundBoss = true
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 12
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
	PrecacheUnitByNameSync("npc_dota_boss3a", context)
	PrecacheUnitByNameSync("npc_dota_boss3a_b", context)
	PrecacheUnitByNameSync("npc_dota_boss3b", context)
	PrecacheUnitByNameSync("npc_dota_boss7", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs