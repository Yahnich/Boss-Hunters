if RoundManager == nil then
	print ( 'creating round manager' )
	RoundManager = {}
	RoundManager.__index = RoundManager
end

function RoundManager:new( o )
	o = o or {}
	setmetatable( o, RoundManager )
	return o
end

require("events/base_event")

EVENTS_PER_RAID = 4
RAIDS_PER_ZONE = 4
ZONE_COUNT = 2

POSSIBLE_ZONES = {"Grove", "Elysium"}

COMBAT_CHANCE = 60
ELITE_CHANCE = 20
EVENT_CHANCE = 100 - COMBAT_CHANCE

PREP_TIME = 15

ELITE_ABILITIES_TO_GIVE = 1

function RoundManager:Initialize(context)
	RoundManager = self
	self.bossPool = LoadKeyValues('scripts/kv/boss_pool.txt')
	self.eventPool = LoadKeyValues('scripts/kv/event_pool.txt')
	self.combatPool = LoadKeyValues('scripts/kv/combat_pool.txt')

	self.zones = {}
	self.eventsFinished = 0
	local zonesToSpawn = ZONE_COUNT
	for i = 1, ZONE_COUNT do
		local zoneName = POSSIBLE_ZONES[i]
		RoundManager:ConstructRaids(zoneName)
		if zonesToSpawn <= 0 then
			break
		end
	end
	
	self.eventsCreated = nil
	
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( RoundManager, "OnNPCSpawned" ), self )
	ListenToGameEvent( "dota_holdout_revive_complete", Dynamic_Wrap( RoundManager, 'OnHoldoutReviveComplete' ), self )
	
	self:PrecacheRounds(context)
end

function RoundManager:OnNPCSpawned(event)
	Timers:CreateTimer(function()
		local spawnedUnit = EntIndexToHScript( event.entindex )
		
		if not spawnedUnit 
		or spawnedUnit:IsPhantom() 
		or spawnedUnit:GetClassname() == "npc_dota_thinker" 
		or spawnedUnit:GetUnitName() == "" 
		or spawnedUnit:IsFakeHero() 
		or spawnedUnit:GetUnitName() == "npc_dummy_unit" 
		or spawnedUnit:GetUnitName() == "npc_dummy_blank" then
			return
		end
		if spawnedUnit then
			print( spawnedUnit:IsIllusion() )
			if spawnedUnit:IsAlive() and spawnedUnit:IsCreature() and spawnedUnit:GetTeam() == DOTA_TEAM_BADGUYS then
				AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnedUnit:GetAbsOrigin(), 516, 3, false) -- show spawns
				if spawnedUnit:IsRoundBoss() then
					ParticleManager:FireParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_end_nexon_hero_cp_2014.vpcf", PATTACH_POINT_FOLLOW, spawnedUnit)
					EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", spawnedUnit)
				end
				if not spawnedUnit.hasBeenInitialized then
					RoundManager:InitializeUnit(spawnedUnit, spawnedUnit:IsRoundBoss() and RoundManager:GetCurrentEvent():IsElite() )
					GridNav:DestroyTreesAroundPoint(spawnedUnit:GetAbsOrigin(), spawnedUnit:GetHullRadius() + spawnedUnit:GetCollisionPadding() + 350, true)
					FindClearSpaceForUnit(spawnedUnit, spawnedUnit:GetAbsOrigin(), true)
				end
			elseif spawnedUnit:IsRealHero() then
				spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_tombstone_respawn_immunity", {duration = 3})
			elseif spawnedUnit:IsIllusion() then
				spawnedUnit:FindModifierByName("modifier_stats_system_handler"):SetStackCount( PlayerResource:GetSelectedHeroEntity( spawnedUnit:GetPlayerOwnerID() ):entindex() )
			end
		end
	end)
end

function RoundManager:OnHoldoutReviveComplete( event )
	local castingHero = EntIndexToHScript( event.caster )
	local target = EntIndexToHScript( event.target )
	
	if castingHero then
		castingHero.Resurrections = (castingHero.Resurrections or 0) + 1
		target:AddNewModifier(target, nil, "modifier_tombstone_respawn_immunity", {duration = 3})
		castingHero:AddGold(self._nRoundNumber)
	end
	target.tombstoneEntity = nil
end

function RoundManager:RollRandomEvent(zoneName, eventType)
	local eventPool = {}
	local eventTypeName = ""
	if eventType == EVENT_TYPE_COMBAT or eventType == EVENT_TYPE_ELITE then
		eventTypeName = "combat"
	elseif eventType == EVENT_TYPE_EVENT then
		eventTypeName = "event"
	else
		eventTypeName = "boss"
	end
	for event, weight in pairs( self[eventTypeName.."Pool"][zoneName] ) do
		if weight > 0 then
			for i = 1, weight do
				table.insert(eventPool, event)
			end
		end
	end
	
	return BaseEvent(zoneName, eventType, eventPool[RandomInt(1, #eventPool)] )
end

function RoundManager:ConstructRaids(zoneName)
	self.zones[zoneName] = {}
	
	local zoneEventPool = {}
	local zoneCombatPool = self.combatPool[zoneName]
	local zoneBossPool = {}
	
	self.eventsCreated = self.eventsCreated or 0
	
	for event, weight in pairs( self.bossPool[zoneName] ) do
		if weight > 0 then
			for i = 1, weight do
				table.insert(zoneBossPool, event)
			end
		end
	end
	
	for event, weight in pairs( self.eventPool[zoneName] ) do
		if weight > 0 then
			for i = 1, weight do
				table.insert(zoneEventPool, event)
			end
		end
	end
	for j = 1, RAIDS_PER_ZONE do
		local raid = {}
		local raidCombatPool = {}
		local raidContent
		for event, weight in pairs( zoneCombatPool ) do
			if weight > 0 then
				for i = 1, weight do
					table.insert(raidCombatPool, event)
				end
			end
		end
		for i = 1, EVENTS_PER_RAID do
			if RollPercentage(COMBAT_CHANCE) or not zoneEventPool[1] then -- Rolled Combat
				local combatType = EVENT_TYPE_COMBAT
				if RollPercentage(ELITE_CHANCE) and self.eventsCreated > 3 then
					combatType = EVENT_TYPE_ELITE
				end
				local combatPick = RandomInt(1, #raidCombatPool)
				raidContent = BaseEvent(zoneName, combatType, raidCombatPool[combatPick] )
				table.remove( raidCombatPool, combatPick )
			else -- Event
				local eventPick = RandomInt(1, #zoneEventPool)
				raidContent = BaseEvent(zoneName, EVENT_TYPE_EVENT, zoneEventPool[eventPick])
				table.remove( zoneEventPool, eventPick )
			end
			table.insert( raid, raidContent )
			self.eventsCreated = self.eventsCreated + 1
		end
		local bossRoll = RandomInt(1, #zoneBossPool)
		local bossPick = zoneBossPool[bossRoll]
		RoundManager:RemoveEventFromPool(bossPick, "boss")
		table.remove(zoneBossPool, bossRoll)
		table.insert( raid, BaseEvent(zoneName, EVENT_TYPE_BOSS, bossPick ) )
		
		table.insert( self.zones[zoneName], raid )
	end
end

function RoundManager:RemoveEventFromPool(eventToRemove, pool)	
	for zone, zoneEvents in pairs( self[pool.."Pool"] ) do
		for event, weight in pairs( zoneEvents ) do
			if event == eventToRemove then
				zoneEvents[eventToRemove] = nil
			end
		end
	end
end

function RoundManager:StartGame()
	
	self.spawnPositions = {}
	for _,spawnPos in ipairs(Entities:FindAllByName("boss_spawner")) do
		table.insert( self.spawnPositions, spawnPos:GetAbsOrigin() )
	end
	
	self.currentZone = POSSIBLE_ZONES[1]
	table.remove(POSSIBLE_ZONES, 1)
	
	RoundManager:StartPrepTime()
end

function RoundManager:StartPrepTime(fPrep)
	if self.zones[self.currentZone] and self.zones[self.currentZone][1] and not self.prepTimeTimer then
		local event = RoundManager:GetCurrentEvent()
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			PlayerResource:SetCustomBuybackCost(hero:GetPlayerID(), 100 + self.eventsFinished * 25)
		end
		
		local timer = fPrep or PREP_TIME
		local textFormatting = RAIDS_PER_ZONE - #self.zones[self.currentZone] + 1
		local romanVersion = ""
		if textFormatting < 4 then
			for i = 1, textFormatting do
				romanVersion = romanVersion.."I"
			end
		elseif textFormatting == 4 then
			romanVersion = "IV"
		else
			textFormatting = textFormatting - 5
			romanVersion = "V"
			if textFormatting > 0 then
				for i = textFormatting, 3 do
					romanVersion = romanVersion.."I"
				end
			end
		end
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestRound", { eventName = RoundManager:GetCurrentEventName(), roundText = self.currentZone.." "..romanVersion } )
		self.prepTimeTimer = Timers:CreateTimer(1, function()
			timer = timer - 1
			CustomGameEventManager:Send_ServerToAllClients( "updateQuestPrepTime", { prepTime = math.floor(timer + 0.5) } )
			if timer <= 0 then
				
				RoundManager:EndPrepTime()
			else
				return 1
			end
		end)
	end
end

function RoundManager:EndPrepTime(bReset)
	print("Starting event", self:GetCurrentEvent():GetEventName(), self:GetCurrentEvent():IsElite() )
	if self.prepTimeTimer then Timers:RemoveTimer( self.prepTimeTimer ) end
	self.prepTimeTimer = nil
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_prep_time_has_ended", {})
	if not bReset then
		RoundManager:StartEvent()
	end
end

function RoundManager:StartEvent()
	GameRules:RefreshPlayers()
	EmitGlobalSound("Round.Start")
	
	local playerData = {}
	for _, hero in ipairs ( HeroList:GetAllHeroes() ) do
		if not hero:IsFakeHero() then
			playerData[hero:GetPlayerID()] = {DT = hero.statsDamageTaken or 0, DD = hero.statsDamageDealt or 0, DH = hero.statsDamageHealed or 0}
		end
	end
	CustomGameEventManager:Send_ServerToAllClients( "player_update_stats", playerData )
	
	if self.zones[self.currentZone] and self.zones[self.currentZone][1] and self.zones[self.currentZone][1][1] then
		local event = RoundManager:GetCurrentEvent()
		event.eventHasStarted = true
		event.eventEnded = false
		event:StartEvent()
		return true
	else
		RoundManager:GameIsFinished(true)
		return false
	end
end

function RoundManager:EndEvent(bWonRound)
	GameRules:RefreshPlayers()
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	local event = self.zones[self.currentZone][1][1]
	event.eventEnded = true
	event.eventHasStarted = false
	if event.eventHandler then Timers:RemoveTimer( event.eventHandler ) end
	if event then
		if bWonRound then
			EventManager:FireEvent("boss_hunters_event_finished", {eventType = event:GetEventType()})
			event:HandoutRewards(true)
			self.zones[self.currentZone][1][1] = false
			table.remove( self.zones[self.currentZone][1], 1 )
			
			self.eventsFinished = self.eventsFinished + 1
			if self.zones[self.currentZone][1][1] == nil then RoundManager:RaidIsFinished() end
			EmitGlobalSound("Round.Won")
		else
			GameRules._lives = GameRules._lives - 1
			event:HandoutRewards(false)
			EmitGlobalSound("Round.Lost")
		end
	end
	
	local clearPeriod = 3
	Timers:CreateTimer(function()
		for _, unit in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_ENEMY, flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD}) ) do
			if unit:IsCreature() and not unit:IsNull() then 
				if unit:IsAlive() then
					unit:ForceKill(false)
				end
			end
		end
		clearPeriod = clearPeriod - 0.25
		if clearPeriod > 0 then
			return 0.25
		end
	end)
	local fTime = PREP_TIME
	if RoundManager:GetCurrentEvent():IsEvent() then
		fTime = 5
	end
	CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
	if GameRules._lives == 0 then
		return RoundManager:GameIsFinished(false)
	end
	self:StartPrepTime(fTime)
end

function RoundManager:RaidIsFinished()
	table.remove( self.zones[self.currentZone], 1 )
	EventManager:FireEvent("boss_hunters_raid_finished")
	self.raidsFinished = (self.raidsFinished or 0) + 1
	if self.zones[self.currentZone][1] == nil then RoundManager:ZoneIsFinished() end
end

function RoundManager:ZoneIsFinished()
	self.zones[self.currentZone] = nil
	self.currentZone = nil
	
	self.currentZone = POSSIBLE_ZONES[1]

	EventManager:FireEvent("boss_hunters_zone_finished")
	self.zonesFinished = (self.zonesFinished or 0) + 1
	if self.currentZone == nil then
		RoundManager:GameIsFinished(true)
	else
		table.remove(POSSIBLE_ZONES, 1)
	end
end

function RoundManager:GameIsFinished(bWon)
	EventManager:FireEvent("boss_hunters_game_finished")
	if bWon then
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		GameRules.Winner = DOTA_TEAM_GOODGUYS
	else
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		GameRules.Winner = DOTA_TEAM_BADGUYS
	end
	GameRules._finish = true
	GameRules.EndTime = GameRules:GetGameTime()
	statCollection:submitRound(true)
end

function RoundManager:GetCurrentEvent()
	return self.zones[self.currentZone][1][1]
end

function RoundManager:PickRandomSpawn()
	return self.spawnPositions[RandomInt(1, #self.spawnPositions)]
end

function RoundManager:EvaluateLoss()
	for _, hero in ipairs( HeroList:GetRealHeroes() ) do
		if hero:NotDead() then return false end
	end
	return true
end

function RoundManager:GetEventsFinished()
	self.eventsFinished = self.eventsFinished or 0
	return self.eventsFinished or 0
end

function RoundManager:GetRaidsFinished()
	self.raidsFinished = self.raidsFinished or 0
	return self.raidsFinished or 0
end

function RoundManager:GetZonesFinished()
	self.zonesFinished = self.zonesFinished or 0
	return self.zonesFinished or 0
end

function RoundManager:GetCurrentEventName()
	return self.zones[self.currentZone][1][1]:GetEventName()
end

function RoundManager:GetCurrentZone()
	return self.currentZone
end

function RoundManager:IsRoundGoing()
	return self:GetCurrentEvent():HasStarted()
end

function RoundManager:InitializeUnit(unit, bElite)
	unit.hasBeenInitialized = true
	local expectedHP = unit:GetBaseMaxHealth() * RandomFloat(0.9, 1.1)
	local expectedDamage = ( unit:GetAverageBaseDamage() + RoundManager:GetEventsFinished() ) * RandomFloat(0.9, 1.1)
	local playerHPMultiplier = 0.4
	local playerDMGMultiplier = 0.1
	if GameRules:GetGameDifficulty() == 4 then 
		expectedHP = expectedHP * 1.5
		expectedDamage = expectedDamage * 1.2
		playerHPMultiplier = 0.6 
		playerDMGMultiplier = 0.15
		playerArmorMultiplier = 0.06
	end
	local effective_multiplier = (HeroList:GetActiveHeroCount() - 1) 
	
	local effPlayerHPMult =  0.7 + ( (RoundManager:GetEventsFinished() * 0.1) + (RoundManager:GetRaidsFinished() * 0.5) + ( RoundManager:GetZonesFinished() * 1.5 )  ) + ( effective_multiplier * playerHPMultiplier )
	local effPlayerDMGMult = ( 0.6 + (RoundManager:GetEventsFinished() * 0.05) + (RoundManager:GetRaidsFinished() * 0.60) + ( RoundManager:GetZonesFinished() ) ) + effective_multiplier * playerDMGMultiplier
	local effPlayerArmorMult = ( 0.85 + (RoundManager:GetRaidsFinished() * 0.15) + ( RoundManager:GetZonesFinished() ) ) + effective_multiplier * playerArmorMultiplier
	
	if bElite then
		effPlayerHPMult = effPlayerHPMult * 1.35
		effPlayerDMGMult = effPlayerDMGMult * 1.2
		
		
		local nParticle = ParticleManager:CreateParticle( "particles/econ/courier/courier_onibi/courier_onibi_yellow_ambient_smoke_lvl21.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
		ParticleManager:ReleaseParticleIndex( nParticle )
		unit:SetModelScale(unit:GetModelScale()*1.15)
		
		local eliteTypes = {}
		for eliteType, activated in pairs(GameRules._Elites) do
			if activated ~= "0" then
				table.insert(eliteTypes, eliteType)
			end
		end
		
		for i = 1, ELITE_ABILITIES_TO_GIVE do
			local roll = RandomInt(1, #eliteTypes)
			local eliteAbName = eliteTypes[roll]
			table.remove(eliteTypes, roll)
			local eliteAb = unit:AddAbilityPrecache(eliteAbName)
			eliteAb:SetLevel(eliteAb:GetMaxLevel())
		end
	end
	
	expectedHP = ( 20 * RoundManager:GetRaidsFinished() + expectedHP ) * effPlayerHPMult
	unit:SetBaseMaxHealth(expectedHP)
	unit:SetMaxHealth(expectedHP)
	unit:SetHealth(expectedHP)
	
	unit:SetAverageBaseDamage( expectedDamage * RandomFloat(0.85, 1.15) , 35)
	unit:SetBaseHealthRegen(RoundManager:GetEventsFinished() * RandomFloat(0.85, 1.15) )
	unit:SetPhysicalArmorBaseValue( (unit:GetPhysicalArmorBaseValue() + RoundManager:GetRaidsFinished() ) * effPlayerArmorMult )
	
	unit:AddNewModifier(unit, nil, "modifier_boss_attackspeed", {})
	unit:AddNewModifier(unit, nil, "modifier_power_scaling", {}):SetStackCount( math.floor( (self:GetEventsFinished() / 3) * (1 + self:GetRaidsFinished() * 1.5 ) * ( RoundManager:GetZonesFinished() * 3 ) ))
	unit:AddNewModifier(unit, nil, "modifier_spawn_immunity", {duration = 4/GameRules.gameDifficulty})
	
	if unit:GetHullRadius() >= 16 then
		unit:SetHullRadius( math.ceil(16 * unit:GetModelScale()) )
	end
	
	unit:SetMaximumGoldBounty(0)
	unit:SetMinimumGoldBounty(0)
	unit:SetDeathXP(0)
end

function RoundManager:PrecacheRounds(context)
	for zone, raids in pairs( self.zones ) do
		for _, raid in pairs( raids ) do
			for _, event in pairs(raid) do
				event:PrecacheUnits(context)
			end
		end
	end
end