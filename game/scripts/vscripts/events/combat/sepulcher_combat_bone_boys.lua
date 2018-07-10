local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 3 + math.floor( RoundManager:GetRaidsFinished() + 0.5 )
	self.eventHandler = Timers:CreateTimer(3, function()
		local enemyName = "npc_dota_boss24_archer"
		local roll = RandomInt(1, 11)
		if RollPercentage(50) then
			enemyName = "npc_dota_boss24_stomper"
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