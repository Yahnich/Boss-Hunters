local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.waveType = self.waveType or RandomInt(1, 3)
	if self.waveType == 1 then
		self.slarks = 1 + RoundManager:GetCurrentRaidTier()
		self.bloodseekers = 0
	elseif self.waveType == 2 then
		self.bloodseekers = 1 + RoundManager:GetCurrentRaidTier()
		self.slarks = 0
	else
		self.bloodseekers = RoundManager:GetCurrentRaidTier()
		self.slarks = 1
	end
	self.enemiesToSpawn = self.slarks + self.bloodseekers
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.slarks >= 0 then
			local spawn = CreateUnitByName("npc_dota_boss6", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.slarks = self.slarks - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
		end
		if self.bloodseekers >= 0 then
			local spawn = CreateUnitByName("npc_dota_boss6_b", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.bloodseekers = self.bloodseekers - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
		end
		
		if self.enemiesToSpawn > 0 then
			return 4
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
	PrecacheUnitByNameSync("npc_dota_boss6", context)
	PrecacheUnitByNameSync("npc_dota_boss6_b", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs