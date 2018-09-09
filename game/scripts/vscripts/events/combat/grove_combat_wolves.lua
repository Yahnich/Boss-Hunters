local function StartEvent(self)
	local wolves = 3 + math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) )
	local alpha = 1 + RoundManager:GetAscensions()
	
	self.enemiesToSpawn = wolves + alpha
	
	local delay = 10
	tick = 15 / (GameRules:GetGameDifficulty() + 1)
	self.eventHandler = Timers:CreateTimer(3, function()
		if wolves > 0 then
			local wolf = CreateUnitByName("npc_dota_boss_wolf", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			wolf.unitIsRoundBoss = true
			
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			wolves = wolves - 1
		end
		
		delay = delay - tick
		if delay <= 0 and alpha > 0 then
			local alphaWolf = CreateUnitByName("npc_dota_boss_alpha_wolf", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			alphaWolf.unitIsRoundBoss = true
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			alpha = alpha - 1
		end
		if self.enemiesToSpawn > 0 then
			return tick
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
	PrecacheUnitByNameSync("npc_dota_boss_alpha_wolf", context)
	PrecacheUnitByNameSync("npc_dota_boss_wolf", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs