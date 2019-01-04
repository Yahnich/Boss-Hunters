local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.bigBears = 0
	self.smallBears = 0
	local bigBearsGuaranteed = RollPercentage( 50 )
	if bigBearsGuaranteed then
		self.bigBears = RoundManager:GetCurrentRaidTier()
		self.smallBears = 1 + RoundManager:GetCurrentRaidTier() + HeroList:GetActiveHeroCount()
	else
		self.bigBears = RoundManager:GetCurrentRaidTier() - 1
		self.smallBears = 1 + RoundManager:GetCurrentRaidTier() * 2 + HeroList:GetActiveHeroCount()
	end
	self.enemiesToSpawn = self.bigBears + self.smallBears
	local bigSpawn = 0
	local smallSpawn = 0
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.bigBears > 0 then
			bigSpawn = bigSpawn + 1
			if bigSpawn >= 10 then
				local spawn = CreateUnitByName("npc_dota_boss26", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				spawn:SetCoreHealth(2200)
				spawn.unitIsRoundNecessary = true
				self.enemiesToSpawn = self.enemiesToSpawn - 1
			end
		end
		if self.smallBears > 0 then
			smallSpawn = smallSpawn + 1
			if smallSpawn >= 6 then
				local spawn = CreateUnitByName("npc_dota_boss26_mini", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				spawn:SetCoreHealth(1350)
				spawn.unitIsMinion = not bigBearsGuaranteed
				spawn.unitIsRoundNecessary = true
				self.enemiesToSpawn = self.enemiesToSpawn - 1
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
	PrecacheUnitByNameSync("npc_dota_boss26", context)
	PrecacheUnitByNameSync("npc_dota_boss26_mini", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs