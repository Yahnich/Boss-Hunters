local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 1
	self.eventEnded = false
	self.eventHandler = Timers:CreateTimer(3, function()
		local spawn = CreateUnitByName("npc_dota_green_dragon", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		local greenPool = spawn:FindAbilityByName("green_dragon_toxic_pool")
		if greenPool then greenPool:StartCooldown(10) end
		spawn.unitIsRoundNecessary = true
		spawn:SetCoreHealth(1750)
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
	PrecacheUnitByNameSync("npc_dota_green_dragon", context)
	PrecacheUnitByNameSync("npc_dota_green_dragon_bug", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "grove_boss_green_dragon"
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