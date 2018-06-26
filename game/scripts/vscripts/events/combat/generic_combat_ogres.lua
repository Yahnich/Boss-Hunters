local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 6 + math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) ) * 2
	self.eventHandler = Timers:CreateTimer(3, function()
		local enemyName = ""
		local roll = RandomInt(1, 8)
		if roll <= 3 then
			enemyName = "npc_dota_boss13"
		elseif roll <= 6 then
			enemyName = "npc_dota_boss14"
		elseif roll == 7 then
			enemyName = "npc_dota_boss15"
		else
			enemyName = "npc_dota_boss16"
		end
		local spawn = CreateUnitByName(enemyName, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundBoss = true
		
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