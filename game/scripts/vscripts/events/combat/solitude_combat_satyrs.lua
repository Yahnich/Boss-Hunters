local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.type = self.type or RandomInt(1, 3)
	if self.type == 1 then
		self.enemiesToSpawn = 6
	elseif self.type == 2 then
		self.enemiesToSpawn = 4
	else
		self.enemiesToSpawn = 9
	end
	self.eventHandler = Timers:CreateTimer(3, function()
		if self.type == 1 then
			if self.enemiesToSpawn == 6 then
				local champion = CreateUnitByName("npc_dota_boss_satyr_champion", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				champion.unitIsRoundNecessary = true
				
				local mage = CreateUnitByName("npc_dota_boss_satyr_mage", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				mage.unitIsRoundNecessary = true
				
				self.enemiesToSpawn = self.enemiesToSpawn - 2
			else
				local follower = CreateUnitByName("npc_dota_boss_satyr_follower", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				follower.unitIsRoundNecessary = true
				self.enemiesToSpawn = self.enemiesToSpawn - 1
			end
		elseif self.type == 2 then
			if self.enemiesToSpawn == 4 then
				local champion = CreateUnitByName("npc_dota_boss_satyr_champion", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				champion.unitIsRoundNecessary = true
			else
				local mage = CreateUnitByName("npc_dota_boss_satyr_mage", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				mage.unitIsRoundNecessary = true
			end
			self.enemiesToSpawn = self.enemiesToSpawn - 1
		else
			if self.enemiesToSpawn == 5 then
				self.enemiesToSpawn = self.enemiesToSpawn - 1
			else
				local number = 2
				for i = 1, number do
					local follower = CreateUnitByName("npc_dota_boss_satyr_follower", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
					follower.unitIsRoundNecessary = true
					self.enemiesToSpawn = self.enemiesToSpawn - 1
				end
				self.enemiesToSpawn = self.enemiesToSpawn - number
			end
		end
		if self.enemiesToSpawn > 0 then
			return 6
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
	PrecacheUnitByNameSync("npc_dota_boss_satyr_champion", context)
	PrecacheUnitByNameSync("npc_dota_boss_satyr_mage", context)
	PrecacheUnitByNameSync("npc_dota_boss_satyr_follower", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs