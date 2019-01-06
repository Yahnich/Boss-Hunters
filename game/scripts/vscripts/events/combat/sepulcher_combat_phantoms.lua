local function StartEvent(self)
	local bansheeSpawn = 20 / GameRules:GetGameDifficulty()
	local ghostSpawn = 10 / GameRules:GetGameDifficulty()
	local bTimer = 0
	local gTimer = 0
	self.bToSpawn = 2 + RoundManager:GetCurrentRaidTier() * 2
	self.gToSpawn = 4 + RoundManager:GetCurrentRaidTier() * 4
	self.enemiesToSpawn = self.bToSpawn + self.gToSpawn
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.bToSpawn > 0 then
			bTimer = bTimer + 1
			if bTimer >= bansheeSpawn then
				local spawn = CreateUnitByName("npc_dota_boss_phantom", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				spawn.unitIsRoundNecessary = true
				self.bToSpawn = self.bToSpawn - 1
				self.enemiesToSpawn = self.enemiesToSpawn - 1
				bTimer = 0
			end
		end
		if self.gToSpawn > 0 then
			gTimer = gTimer + 1
			if gTimer >= ghostSpawn then
				local spawn = CreateUnitByName("npc_dota_boss22b", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				spawn:SetCoreHealth(1250)
				spawn:SetBaseAverageDamage( 100, 25 )
				spawn.unitIsMinion = true
				spawn.unitIsRoundNecessary = true
				self.gToSpawn = self.gToSpawn - 1
				self.enemiesToSpawn = self.enemiesToSpawn - 1
				gTimer = 0
			end
		end
		if self.enemiesToSpawn > 0 then
			return 1
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
	PrecacheUnitByNameSync("npc_dota_boss_phantom", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs