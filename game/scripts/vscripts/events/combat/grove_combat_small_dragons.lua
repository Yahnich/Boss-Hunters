local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = math.min( 12, 3 + math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) ) )
	self.eventHandler = Timers:CreateTimer(3, function()
		local enemyName = "npc_dota_boss23_m"
		if RollPercentage(20) then	
			enemyName = "npc_dota_boss18"
		end
		local spawn = CreateUnitByName(enemyName, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		if enemyName == "npc_dota_boss18" then
			spawn.armor = spawn:FindAbilityByName("boss_living_armor")
			if spawn.armor then spawn.armor:SetLevel( math.max(5, RoundManager:GetRaidsFinished() ) ) end
		else
			spawn.conflag = spawn:AddAbility("boss16_conflagration")
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				spawn.conflag:SetLevel(1)
			else
				spawn.conflag:SetLevel(2)
			end
		end
		spawn.unitIsRoundNecessary = true
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 5
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
	PrecacheUnitByNameSync("npc_dota_boss23_m", context)
	PrecacheUnitByNameSync("npc_dota_boss18", context)
	PrecacheUnitByNameSync("npc_dota_minion_greater_treant", context)
	PrecacheUnitByNameSync("npc_dota_minion_minor_treant", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs