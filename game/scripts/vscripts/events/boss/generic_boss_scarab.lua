local function OnEntityKilled(self, event)
	if self.enemyTable[event.entindex_killed] then
		self.enemiesToSpawn = self.enemiesToSpawn - 1
	end
	if self.enemiesToSpawn <= 0 then self:EndEvent() end
end

local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemyTable = {}
	self.enemiesToSpawn = 1
	local spawn = CreateUnitByName("npc_dota_boss30", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
	
	
	if spawn then
		entUnit.unitIsRoundBoss = true
	end
	
	table.insert( self.enemyTable, spawn:entindex() )
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", OnEntityKilled, self ),
	}
end

local function EndEvent(self)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	RoundManager:EndEvent()
end

local function PrecacheUnits(self)
	PrecacheUnitByNameAsync("npc_dota_boss30", function() end)
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs