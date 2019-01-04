local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	local roll = RandomInt(1, 3)
	self.noSmash = 0
	self.wizardSmash = 0
	self.smallSmash = 0
	self.bigSmash = 0
	if roll == 1 then	
		self.bigSmash = RoundManager:GetCurrentRaidTier()
		self.wizardSmash = 1 + RoundManager:GetCurrentRaidTier()
		self.noSmash = 1 + RoundManager:GetCurrentRaidTier() * 2
	elseif roll == 2 then
		self.wizardSmash = RoundManager:GetCurrentRaidTier()
		self.smallSmash = RoundManager:GetCurrentRaidTier()
		self.noSmash = 2 + RoundManager:GetCurrentRaidTier() * 3
	else
		self.smallSmash = 1 + RoundManager:GetCurrentRaidTier()
		self.bigSmash = RoundManager:GetCurrentRaidTier()
		self.noSmash = 1 + RoundManager:GetCurrentRaidTier() * 2
	end
	self.enemiesToSpawn = self.noSmash + self.wizardSmash + self.smallSmash + self.bigSmash
	local bigSpawnDelay = 15
	local smallSpawnDelay = 10
	local wizardSpawnDelay = 10
	local noSpawnDelay = 5
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.bigSmash > 0 then
			if bigSpawnDelay <= 0 then
				local spawn = CreateUnitByName("npc_dota_boss16", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				spawn.unitIsRoundNecessary = true
				bigSpawnDelay = 15
			else
				bigSpawnDelay = bigSpawnDelay - 1
			end
		end
		if self.wizardSmash > 0 then
			if wizardSpawnDelay <= 0 then
				local spawn = CreateUnitByName("npc_dota_boss14", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				spawn.unitIsRoundNecessary = true
				wizardSpawnDelay = 10
			else
				wizardSpawnDelay = wizardSpawnDelay - 1
			end
		end
		if self.smallSmash > 0 then
			if smallSpawnDelay <= 0 then
				local spawn = CreateUnitByName("npc_dota_boss15", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				spawn.unitIsRoundNecessary = true
				smallSpawnDelay = 10
			else
				smallSpawnDelay = smallSpawnDelay - 1
			end
		end
		if self.noSmash > 0 then
			if noSpawnDelay <= 0 then
				local spawn = CreateUnitByName("npc_dota_boss13", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				spawn.unitIsRoundNecessary = true
				spawn.unitIsMinion = true
				noSpawnDelay = 5
			else
				noSpawnDelay = noSpawnDelay - 1
			end
		end
		self.enemiesToSpawn = self.enemiesToSpawn - 1
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
	PrecacheUnitByNameSync("npc_dota_boss13", context)
	PrecacheUnitByNameSync("npc_dota_boss14", context)
	PrecacheUnitByNameSync("npc_dota_boss15", context)
	PrecacheUnitByNameSync("npc_dota_boss16", context)
	PrecacheUnitByNameSync("npc_dota_mini_boss2", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs