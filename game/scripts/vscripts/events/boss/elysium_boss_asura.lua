local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.eventEnded = false
	self.enemiesToSpawn = 1
	self.eventHandler = Timers:CreateTimer(3, function()
		local spawn = CreateUnitByName("npc_dota_boss36_guardian", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundNecessary = true
		spawn.unitIsBoss = true
		spawn.shield = spawn:FindAbilityByName("boss_evil_guardian_fire_shield")
		spawn.purge = spawn:FindAbilityByName("boss_evil_guardian_purge_their_sin")
		spawn.pool = spawn:FindAbilityByName("boss_evil_guardian_hell_on_earth")
	
		spawn.raze1 = spawn:FindAbilityByName("boss_evil_guardian_annihilation")
		spawn.raze2 = spawn:FindAbilityByName("boss_evil_guardian_destruction")
		spawn.raze3 = spawn:FindAbilityByName("boss_evil_guardian_apocalypse")
		spawn.fist = spawn:FindAbilityByName("boss_evil_guardian_rise_of_hell")
		spawn.stun = spawn:FindAbilityByName("boss_evil_guardian_end_of_days")
	
		if math.floor(GameRules:GetGameDifficulty() + 0.5) == 2 then 
			spawn.shield:SetLevel(1)
			spawn.purge:SetLevel(1)
			spawn.pool:SetLevel(1)
			spawn.raze1:SetLevel(1)
			spawn.raze2:SetLevel(1)
			spawn.raze3:SetLevel(1)
			spawn.fist:SetLevel(1)
			spawn.stun:SetLevel(1)
		else
			spawn.shield:SetLevel(2)
			spawn.purge:SetLevel(2)
			spawn.pool:SetLevel(2)
			spawn.raze1:SetLevel(2)
			spawn.raze2:SetLevel(2)
			spawn.raze3:SetLevel(2)
			spawn.fist:SetLevel(2)
			spawn.stun:SetLevel(2)
		end
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
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
	PrecacheUnitByNameSync("npc_dota_boss36_guardian", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "solitude_asura_boss"
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_spawner" ) ) do
			table.insert( RoundManager.spawnPositions, spawnPos:GetAbsOrigin() )
		end
		self.heroSpawnPosition = self.heroSpawnPosition or nil
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_heroes") ) do
			self.heroSpawnPosition = spawnPos:GetAbsOrigin()
			break
		end
		
		self.spawnLoadCompleted = true
	end
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["LoadSpawns"] = LoadSpawns,
}

return funcs