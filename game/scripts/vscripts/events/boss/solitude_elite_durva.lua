local function StartEvent(self)
	self:StartCombatRound()
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	self.eventEnded = true
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss_durva", context)
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