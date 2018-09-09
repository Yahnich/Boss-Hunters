local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.greymane = 1
	self.alpha = 1 + math.floor( math.log( RoundManager:GetRaidsFinished() + 1 ) + 0.5 )
	self.wolf = 2 + math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) + 0.5 )
	self.enemiesToSpawn = self.greymane + self.alpha + self.wolf
	self.eventEnded = false
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.alpha > 0 then
			local alpha = CreateUnitByName("npc_dota_boss_alpha_wolf", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			alpha:SetCoreHealth(850)
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			self.alpha = self.alpha - 1
		end
		if self.wolf > 0 then
			local wolf = CreateUnitByName("npc_dota_boss_wolf", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			wolf:SetCoreHealth(500)
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			self.wolf = self.wolf - 1
		end
		if self.greymane > 0 then
			local spawn = CreateUnitByName("npc_dota_boss_greymane", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundBoss = true
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			self.greymane = self.greymane - 1
		end
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

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss_greymane", context)
	PrecacheUnitByNameSync("npc_dota_boss_wolf", context)
	PrecacheUnitByNameSync("npc_dota_boss_alpha_wolf", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs