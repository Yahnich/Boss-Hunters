local function OnEntityKilled(self, event)
	local killedTarget = EntIndexToHScript(event.entindex_killed)
	if killedTarget:GetUnitName() == "npc_dota_mini_boss2" then
		self.minionsAlive = math.max( 0, self.minionsAlive - 1 )
	end
	require("events/base_combat")(self, event)
end

local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 1 + math.floor( math.log( RoundManager:GetRaidsFinished() + 1 ) )
	self.eventEnded = false
	self.eventHandler = Timers:CreateTimer(3, function()
		local spawn = CreateUnitByName("npc_dota_boss17", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundBoss = true
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 10
		end
	end)
	self.minionsAlive = 0
	self.minionHandler = Timers:CreateTimer(5, function()
		if not self.eventEnded then
			if self.minionsAlive < ( math.floor( math.log( RoundManager:GetRaidsFinished() + 1) + 2 ) ) * GameRules.gameDifficulty then
				local spawn = CreateUnitByName("npc_dota_mini_boss2", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				self.minionsAlive = self.minionsAlive + 1
			end
			return 5
		end
	end)
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", OnEntityKilled, self ),
	}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	Timers:RemoveTimer( self.minionHandler )
	self.eventEnded = true
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self)
	PrecacheUnitByNameAsync("npc_dota_mini_boss2", function() end)
	Timers:CreateTimer(1, function() PrecacheUnitByNameAsync("npc_dota_boss17", function() end) end)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs