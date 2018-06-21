local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 1
	self.eventEnded = false
	self.eventHandler = Timers:CreateTimer(3, function()
		local spawn = CreateUnitByName("npc_dota_boss36", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundBoss = true
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
	self.eventEnded = true
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self)
	PrecacheUnitByNameAsync("npc_dota_boss36", function() end)
	Timers:CreateTimer(1, function() PrecacheUnitByNameAsync("npc_dota_boss35", function() end) end)
	Timers:CreateTimer(2, function() PrecacheUnitByNameAsync("npc_dota_boss34", function() end) end)
	Timers:CreateTimer(3, function() PrecacheUnitByNameAsync("npc_dota_boss33_a", function() end) end)
	Timers:CreateTimer(4, function() PrecacheUnitByNameAsync("npc_dota_boss33_b", function() end) end)
	Timers:CreateTimer(5, function() PrecacheUnitByNameAsync("npc_dota_boss32_trueform", function() end) end)
	Timers:CreateTimer(5, function() PrecacheUnitByNameAsync("npc_dota_boss31", function() end) end)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs