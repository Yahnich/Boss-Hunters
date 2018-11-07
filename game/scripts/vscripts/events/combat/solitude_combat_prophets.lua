local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = RoundManager:GetZonesFinished() + RoundManager:GetCurrentRaidTier() * 2
	self.eventHandler = Timers:CreateTimer(3, function()
		local spawn = CreateUnitByName("npc_dota_boss22", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn.unitIsRoundBoss = true
		
		spawn:FindAbilityByName("boss15_exorcise"):SetActivated(false)
		spawn:SetCoreHealth(1800)
		
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
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
	PrecacheUnitByNameSync("npc_dota_boss22", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs