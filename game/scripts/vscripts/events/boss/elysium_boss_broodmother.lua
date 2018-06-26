local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 1 + math.floor( math.log(RoundManager:GetRaidsFinished() + 1) )
	self.eventHandler = Timers:CreateTimer(3, function()
		local spawn = CreateUnitByName("npc_dota_boss37", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundBoss = true
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		
		spawn.egg = spawn:FindAbilityByName("boss_broodmother_egg_sack")
		spawn.egg:SetLevel( math.min( math.floor( GameRules:GetGameDifficulty() / 2) + math.floor(RoundManager:GetRaidsFinished() / 2), 6 ) )
		spawn.egg:StartCooldown(6)
		
		spawn.web = spawn:FindAbilityByName("boss_broodmother_fates_web")
		spawn.web:SetLevel( math.min( math.floor( GameRules:GetGameDifficulty() / 2) + math.floor(RoundManager:GetRaidsFinished() / 2), 6 ) )
		
		spawn.infest = spawn:FindAbilityByName("boss_broodmother_infest")
		spawn.infest:SetLevel( math.min( math.floor( GameRules:GetGameDifficulty() / 2) + math.floor(RoundManager:GetRaidsFinished() / 2), 6 ) )
		if self.enemiesToSpawn > 0 then
			return 25
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
	PrecacheUnitByNameSync("npc_dota_boss37", context)
	PrecacheUnitByNameSync("npc_dota_creature_broodmother", context)
	PrecacheUnitByNameSync("npc_dota_creature_broodmother_egg", context)
	PrecacheUnitByNameSync("npc_dota_creature_spiderling", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs