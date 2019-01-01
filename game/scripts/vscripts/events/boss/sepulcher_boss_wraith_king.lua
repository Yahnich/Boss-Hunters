local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 1 + RoundManager:GetAscensions()
	self.mobsToSpawn = 3
	self.eventEnded = false
	self.eventHandler = Timers:CreateTimer(3, function()
		local position = RoundManager:PickRandomSpawn()
		local spawn = CreateUnitByName("npc_dota_boss25", position, true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsBoss = true
		spawn.unitIsRoundNecessary = true
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		
		for i = 1, self.mobsToSpawn do
			local mobName = "npc_dota_boss24_stomper"
			if RollPercentage(50) then
				mobName = "npc_dota_boss24_archer"
			end
			CreateUnitByName(mobName, position + RandomVector(600), true, nil, nil, DOTA_TEAM_BADGUYS)
		end
		
		if self.enemiesToSpawn > 0 then
			return 30
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
	PrecacheUnitByNameSync("npc_dota_boss25", context)
	PrecacheUnitByNameSync("npc_dota_boss24_stomper", context)
	PrecacheUnitByNameSync("npc_dota_boss24_archer", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs