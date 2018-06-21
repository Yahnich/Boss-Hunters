local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = RoundManager:GetEventsFinished()
	self.eventHandler = Timers:CreateTimer(3, function()
		local bigSpider = CreateUnitByName("npc_dota_creature_broodmother", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		bigSpider.unitIsRoundBoss = true
		
		for i = 1, 4 do
			local smallSpider = CreateUnitByName("npc_dota_creature_spiderling", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			smallSpider.unitIsRoundBoss = true
		end
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 10
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

local function PrecacheUnits(self)
	PrecacheUnitByNameAsync("npc_dota_creature_broodmother", function() end)
	Timers:CreateTimer(1, function() PrecacheUnitByNameAsync("npc_dota_creature_spiderling", function() end) end)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs