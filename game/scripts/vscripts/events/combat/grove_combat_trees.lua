local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 1 + RoundManager:GetCurrentRaidTier()
	self.eventHandler = Timers:CreateTimer(3, function()
		local enemyName = "npc_dota_boss18"
		local roll = RandomInt(1, 11)
		if RollPercentage(33) then
			enemyName = "npc_dota_boss19"
		end
		local spawn = CreateUnitByName(enemyName, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		
		if enemyName == "npc_dota_boss19" or enemyName == "npc_dota_boss18" then
			spawn.armor = spawn:FindAbilityByName("boss_living_armor")
			if spawn.armor then spawn.armor:SetLevel( math.max(5, RoundManager:GetRaidsFinished() ) ) end
		end
		spawn.unitIsRoundNecessary = true
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
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
	PrecacheUnitByNameSync("npc_dota_boss18", context)
	PrecacheUnitByNameSync("npc_dota_boss19", context)
	PrecacheUnitByNameSync("npc_dota_mini_tree", context)
	PrecacheUnitByNameSync("npc_dota_mini_tree2", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs