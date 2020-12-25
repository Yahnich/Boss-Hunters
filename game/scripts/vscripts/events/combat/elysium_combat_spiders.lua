local function StartEvent(self)
	local spawnPos = RoundManager:PickRandomSpawn()
	self.enemiesToSpawn = 2 + RoundManager:GetCurrentRaidTier() * 2
	self.eventHandler = Timers:CreateTimer(3, function()
		local position = RoundManager:PickRandomSpawn()
		local bigSpider = CreateUnitByName("npc_dota_creature_broodmother", position, true, nil, nil, DOTA_TEAM_BADGUYS)
		bigSpider.unitIsRoundNecessary = true
		bigSpider:SetCoreHealth( 1150 )
		bigSpider:SetBaseMagicalResistanceValue( 10 )
		bigSpider:SetPhysicalArmorBaseValue( -3 )
		bigSpider:SetAverageBaseDamage(100, 30)
		bigSpider:SetBaseMoveSpeed(350)
		
		self.enemiesToSpawn = self.enemiesToSpawn - 1
		if self.enemiesToSpawn > 0 then
			return 8 / (RoundManager:GetRaidsFinished() + 1)
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
	PrecacheUnitByNameSync("npc_dota_creature_broodmother", context)
	PrecacheUnitByNameSync("npc_dota_creature_spiderling", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["EndEvent"] = EndEvent
}

return funcs