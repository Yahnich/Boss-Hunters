local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = math.min(4 , 1 + RoundManager:GetAscensions() )
	self.eventEnded = false
	self.eventHandler = Timers:CreateTimer(3, function()
		local spawn = CreateUnitByName("npc_dota_boss33_a", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundNecessary = true
		local spawn2 = CreateUnitByName("npc_dota_boss33_b", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn2.unitIsRoundNecessary = true
		
		spawn.twinDemon = spawn2
		spawn2.twinDemon = spawn
		
		spawn.IsTwinAlive = function(spawn)
			return spawn.twinDemon and not spawn.twinDemon:IsNull() and spawn.twinDemon:IsAlive()
		end
		
		spawn2.IsTwinAlive = function(spawn2)
			return spawn2.twinDemon and not spawn2.twinDemon:IsNull() and spawn2.twinDemon:IsAlive()
		end
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
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
	PrecacheUnitByNameSync("npc_dota_boss33_a", context)
	PrecacheUnitByNameSync("npc_dota_boss33_b", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs