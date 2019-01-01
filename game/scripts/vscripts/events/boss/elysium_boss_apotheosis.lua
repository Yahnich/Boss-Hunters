local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 1
	
	Timers:CreateTimer(1, function()
		Notifications:BottomToAll({text="It comes.", duration=5.0})
	end)
	
	local position
	if Entities:FindByName(nil, RoundManager.boundingBox.."_edge_collider") then
		position = Entities:FindByName(nil, RoundManager.boundingBox.."_edge_collider"):GetAbsOrigin()
	end
	
	self.eventHandler = Timers:CreateTimer(10, function()
		local spawn = CreateUnitByName("npc_dota_boss_apotheosis", position or RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundNecessary = true
		spawn.unitIsBoss = true
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
	RoundManager:EndEvent(bWon)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss38", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs