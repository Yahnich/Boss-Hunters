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

POSSIBLE_ZONES = {"Grove", "Sepulcher", "Solitude", "Elysium"}

EVENTS_PER_RAID = 3
RAIDS_PER_ZONE = 2
ZONE_COUNT = #POSSIBLE_ZONES

COMBAT_CHANCE = 70
ELITE_CHANCE = 25
EVENT_CHANCE = 100 - COMBAT_CHANCE

PREP_TIME = 60

ELITE_ABILITIES_TO_GIVE = 1

function RoundManager:Initialize(context)
	RoundManager = self
	self.bossPool = LoadKeyValues('scripts/kv/boss_pool.txt')
	self.eventPool = LoadKeyValues('scripts/kv/event_pool.txt')
	self.combatPool = LoadKeyValues('scripts/kv/combat_pool.txt')

	self.zones = {}
	self.eventsFinished = 0
	
	for i = 1, ZONE_COUNT do
		local zoneName = POSSIBLE_ZONES[i]
		RoundManager:ConstructRaids(zoneName)
	end
	
	self.eventsCreated = nil
	
	CustomGameEventManager:RegisterListener('bh_player_voted_to_skip', Context_Wrap( RoundManager, 'VoteSkipPrepTime'))
	CustomGameEventManager:RegisterListener('bh_player_voted_to_ng', Context_Wrap( RoundManager, 'VoteNewGame'))
	self:PrecacheRounds(context)
end

function RoundManager:VoteSkipPrepTime(userid, event)
	self.votedToSkipPrep = self.votedToSkipPrep or 0
	self.votedToSkipPrep = self.votedToSkipPrep + 1
	local noVotes = HeroList:GetActiveHeroCount() - self.votedToSkipPrep
	CustomGameEventManager:Send_ServerToAllClients("bh_update_votes_prep_time", {yes = self.votedToSkipPrep, no = noVotes})
	if noVotes <= 0 then
		self.prepTimer = 0
	end
end

function RoundManager:VoteNewGame(userid, event)
	self.votedToNG = (self.votedToNG or 0)
	self.votedNoNg = (self.votedNoNg or 0)
	if toboolean(event.vote) then
		self.votedToNG = (self.votedToNG or 0) + 1
	else
		self.votedNoNg = (self.votedNoNg or 0) + 1
	end
	local noVotes = HeroList:GetActiveHeroCount() - self.votedToNG
	local nonVotes = HeroList:GetActiveHeroCount() - self.votedToNG
	CustomGameEventManager:Send_ServerToAllClients("bh_update_votes_prep_time", {yes = self.votedToNG, no = noVotes, ascension = true})
	if self.prepTimer <= 0 then return end
	if noVotes <= self.votedToNG and not self.ng then	
		self.ng = true
		self.votedToNG = 0
		self.votedNoNg = 0
		self.ascensionLevel = (self.ascensionLevel or 0) + 1
		self.zones = {}
		self.bossPool = LoadKeyValues('scripts/kv/boss_pool.txt')
		self.eventPool = LoadKeyValues('scripts/kv/event_pool.txt')
		self.combatPool = LoadKeyValues('scripts/kv/combat_pool.txt')
		POSSIBLE_ZONES = {"Grove", "Sepulcher", "Solitude", "Elysium"}
		self.prepTimer = 0
		for i = 1, ZONE_COUNT do
			local zoneName = POSSIBLE_ZONES[i]
			RoundManager:ConstructRaids(zoneName)
		end
	elseif self.votedNoNg >= math.ceil( HeroList:GetActiveHeroCount() / 2 ) then
		self.ng = false
		self.prepTimer = 0
	end
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
			if spawnedUnit:IsAlive() and spawnedUnit:IsCreature() and spawnedUnit:GetTeam() == DOTA_TEAM_BADGUYS then
				AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnedUnit:GetAbsOrigin(), 516, 3, false) -- show spawns
				if spawnedUnit:IsRoundBoss() then
					ParticleManager:FireParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_end_nexon_hero_cp_2014.vpcf", PATTACH_POINT_FOLLOW, spawnedUnit)
					EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", spawnedUnit)
				end
				if not spawnedUnit.hasBeenInitialized then
					RoundManager:InitializeUnit(spawnedUnit, spawnedUnit:IsRoundBoss() and ( (RoundManager:GetCurrentEvent() and RoundManager:GetCurrentEvent():IsElite()) or RoundManager:GetAscensions() > 0) )
					GridNav:DestroyTreesAroundPoint(spawnedUnit:GetAbsOrigin(), spawnedUnit:GetHullRadius() + spawnedUnit:GetCollisionPadding() + 350, true)
					FindClearSpaceForUnit(spawnedUnit, spawnedUnit:GetAbsOrigin(), true)
				end
			elseif spawnedUnit:IsRealHero() then
				Timers:CreateTimer(0.1, function() spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_tombstone_respawn_immunity", {duration = 2.9}) end)
			elseif spawnedUnit:IsIllusion() and spawnedUnit:GetPlayerOwnerID() and PlayerResource:GetSelectedHeroEntity( spawnedUnit:GetPlayerOwnerID() ) and spawnedUnit:FindModifierByName("modifier_stats_system_handler") then
				spawnedUnit:FindModifierByName("modifier_stats_system_handler"):SetStackCount( PlayerResource:GetSelectedHeroEntity( spawnedUnit:GetPlayerOwnerID() ):entindex() )
			end
			if spawnedUnit:GetTeam() == DOTA_TEAM_GOODGUYS then
				if not spawnedUnit:HasModifier("modifier_cooldown_reduction_handler") then
					spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_cooldown_reduction_handler", {})
				end
				if not spawnedUnit:HasModifier("modifier_base_attack_time_handler") then
					spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_base_attack_time_handler", {})
				end
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
		local position = target:GetAbsOrigin()
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
	local zoneEventPool = TableToWeightedArray( self.eventPool[zoneName] )
	local zoneCombatPool = TableToWeightedArray( self.combatPool[zoneName] )
	local zoneBossPool = TableToWeightedArray( self.bossPool[zoneName] )
	self.eventsCreated = self.eventsCreated or 0
	
	for j = 1, RAIDS_PER_ZONE do
		
		local raid = {}
		local raidContent
		
		for i = 1, EVENTS_PER_RAID do
			self.eventsCreated = self.eventsCreated + 1
			if RollPercentage(COMBAT_CHANCE) or self.eventsCreated < 3 then -- Rolled Combat
				local combatType = EVENT_TYPE_COMBAT
				if (RollPercentage(ELITE_CHANCE) and self.eventsCreated > 3) or self:GetAscensions() > 0 then
					combatType = EVENT_TYPE_ELITE
				end
				
				if zoneCombatPool[1] == nil then
					zoneCombatPool = TableToWeightedArray( self.combatPool[zoneName] )
				end
				
				local combatPick = zoneCombatPool[RandomInt(1, #zoneCombatPool)]
				raidContent = BaseEvent(zoneName, combatType, combatPick )
				for id = #zoneCombatPool, 1, -1 do
					local event = zoneCombatPool[id]
					if event == combatPick then
						table.remove( zoneCombatPool, id )
					end
				end
			else -- Event
				if zoneEventPool[1] == nil then
					zoneEventPool = TableToWeightedArray( self.eventPool[zoneName] )
				end
				local pickedEvent = zoneEventPool[RandomInt(1, #zoneEventPool)]
				raidContent = BaseEvent(zoneName, EVENT_TYPE_EVENT, pickedEvent)
				for id = #zoneEventPool, 1, -1 do
					local event = zoneEventPool[id]
					if event == pickedEvent then
						table.remove( zoneEventPool, id )
					end
				end
			end
			table.insert( raid, raidContent )
		end
		
		if zoneBossPool[1] == nil then
			zoneBossPool = TableToWeightedArray( self.bossPool[zoneName] )
		end
		local bossPick = zoneBossPool[RandomInt(1, #zoneBossPool)]
		RoundManager:RemoveEventFromPool(bossPick, "boss")
		for id = #zoneBossPool, 1, -1 do
			local event = zoneBossPool[id]
			if event == bossPick then
				table.remove( zoneBossPool, id )
			end
		end
		self.eventsCreated = self.eventsCreated + 1
		
		table.insert( raid, BaseEvent(zoneName, EVENT_TYPE_BOSS, bossPick ) )
		table.insert( self.zones[zoneName], raid )
	end
	-- Final Boss bruh
	if zoneName == "Elysium" then 
		local finalBoss = BaseEvent(zoneName, EVENT_TYPE_BOSS, "elysium_boss_apotheosis" )
		table.insert( self.zones[zoneName][#self.zones[zoneName]], finalBoss )
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
	self.currentZone = POSSIBLE_ZONES[1]
	table.remove(POSSIBLE_ZONES, 1)
	if self.zones[self.currentZone][1] then
		local boss = self.zones[self.currentZone][1][#self.zones[self.currentZone][1]]
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestBoss", { bossName = boss:GetEventName() } ) 
	end
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero ~=nil then
					RelicManager:RollEliteRelicsForPlayer( nPlayerID )
				end
			end
		end
	end
	self.raidsFinished = (self.raidsFinished or 0) + 1
		
	local lastSpawns = RoundManager.boundingBox
	RoundManager:LoadSpawns()
	for _, hero in ipairs(HeroList:GetRealHeroes() ) do
		hero.statsDamageTaken = 0
		hero.statsDamageDealt = 0
		hero.statsDamageHealed = 0
		if RoundManager.boundingBox ~= lastSpawns then
			
			local position = RoundManager:GetHeroSpawnPosition() + RandomVector(64)
			CustomGameEventManager:Send_ServerToAllClients( "bh_move_camera_position", { position = position } )
			FindClearSpaceForUnit(hero, position, true)
		end
	end
	RoundManager:StartPrepTime()
end

function RoundManager:StartPrepTime(fPrep)
	local PrepCatch = function( ... )
		if self.zones[self.currentZone] and self.zones[self.currentZone][1] and not self.prepTimeTimer then
			local event = RoundManager:GetCurrentEvent()
			event._playerChoices = {}
			CustomGameEventManager:Send_ServerToAllClients("bh_start_prep_time", {})
			
			for _, hero in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_FRIENDLY}) ) do
				if hero:IsRealHero() then
					PlayerResource:SetCustomBuybackCost(hero:GetPlayerID(), 100 + RoundManager:GetEventsFinished() * 25)
				end
				hero:AddNewModifier( hero, nil, "modifier_restoration_disable", {} )
			end
			ResolveNPCPositions( event:GetHeroSpawnPosition(), 150 )
			for _, hero in ipairs( HeroList:GetRealHeroes() ) do
				hero:SetRespawnPosition( GetGroundPosition(hero:GetAbsOrigin(), hero) )
			end
			self.prepTimer = fPrep or PREP_TIME
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
			local ascensionText
			if RoundManager:GetAscensions() > 0 then
				ascensionText = "A" .. RoundManager:GetAscensions()
			end
			CustomGameEventManager:Send_ServerToAllClients( "updateQuestRound", { eventName = RoundManager:GetCurrentEventName(), roundText = self.currentZone.." "..romanVersion, ascensionText = ascensionText} )
			self.prepTimeTimer = Timers:CreateTimer(1, function()
				self.prepTimer = self.prepTimer - 1
				CustomGameEventManager:Send_ServerToAllClients( "updateQuestPrepTime", { prepTime = math.floor(self.prepTimer + 0.5) } )
				if self.prepTimer <= 0 then
					RoundManager:EndPrepTime()
				else
					return 1
				end
			end)
		end
	end
	status, err, ret = xpcall(PrepCatch, debug.traceback, self, fPrep )
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
end

function RoundManager:EndPrepTime(bReset)
	local EndPrepCatch = function( ... )
		if self.prepTimeTimer then Timers:RemoveTimer( self.prepTimeTimer ) end
		self.prepTimeTimer = nil
		
		self.votedToSkipPrep = 0
		CustomGameEventManager:Send_ServerToAllClients("bh_end_prep_time", {})
		
		for _, hero in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_FRIENDLY}) ) do
			hero:RemoveModifierByName( "modifier_restoration_disable" )
		end
		
		if not bReset then
			RoundManager:StartEvent()
		end
	end
	status, err, ret = xpcall(EndPrepCatch, debug.traceback, self, bReset )
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
end

function RoundManager:StartEvent()
	local StartEventCatch = function( ... )
		GameRules:RefreshPlayers( GameRules:GetGameDifficulty() >= 3 ) 
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
	status, err, ret = xpcall(StartEventCatch, debug.traceback, self )
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
end

function RoundManager:EndEvent(bWonRound)
	local EndEventCatch = function(  )
		GameRules:RefreshPlayers( GameRules:GetGameDifficulty() >= 3 ) 
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
		local fTime = (PREP_TIME or 30) / math.ceil( (GameRules:GetGameDifficulty() - 1) / 2 )
		if RoundManager:GetCurrentEvent() and RoundManager:GetCurrentEvent():IsEvent() then
			fTime = 5
		end
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
		if GameRules._lives == 0 then
			return RoundManager:GameIsFinished(false)
		end
		self:StartPrepTime(fTime)
	end
	status, err, ret = xpcall(EndEventCatch, debug.traceback, self, bWonRound )
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
end

function RoundManager:LoadSpawns()
	RoundManager.spawnPositions = {}
	local zoneName = RoundManager:GetCurrentZone()
	
	RoundManager.raidNumber = (RoundManager.raidNumber or 0) + 1
	RoundManager.boundingBox = string.lower(zoneName).."_raid_"..RoundManager.raidNumber
	for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_spawner" ) ) do
		table.insert( RoundManager.spawnPositions, spawnPos:GetAbsOrigin() )
	end
	RoundManager.heroSpawnPosition = RoundManager.heroSpawnPosition or nil
	for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_heroes") ) do
		RoundManager.heroSpawnPosition = spawnPos:GetAbsOrigin()
		break
	end
end

function RoundManager:GetHeroSpawnPosition()
	return RoundManager.heroSpawnPosition
end

function RoundManager:RaidIsFinished()
	local RaidFinishCatch = function()
		table.remove( self.zones[self.currentZone], 1 )
		EventManager:FireEvent("boss_hunters_raid_finished")
		
		if self.zones[self.currentZone][1] == nil then RoundManager:ZoneIsFinished() end
		if self.currentZone == nil then
			return
		end
		if self.zones[self.currentZone] and self.zones[self.currentZone][1] then
			local boss = self.zones[self.currentZone][1][#self.zones[self.currentZone][1]]
			CustomGameEventManager:Send_ServerToAllClients( "updateQuestBoss", { bossName = boss:GetEventName() } )
		end
		
		self.raidsFinished = (self.raidsFinished or 0) + 1
		
		local lastSpawns = RoundManager.boundingBox
		RoundManager:LoadSpawns()
		for _, hero in ipairs(HeroList:GetRealHeroes() ) do
			hero.statsDamageTaken = 0
			hero.statsDamageDealt = 0
			hero.statsDamageHealed = 0
			if RoundManager.boundingBox ~= lastSpawns then
				CustomGameEventManager:Send_ServerToAllClients( "bh_move_camera_position", { position = RoundManager:GetHeroSpawnPosition() } )
				local position = RoundManager:GetHeroSpawnPosition() + RandomVector(64)
				FindClearSpaceForUnit(hero, position, true)
			end
		end
		
		
	end
	status, err, ret = xpcall(RaidFinishCatch, debug.traceback, self)
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
end

function RoundManager:ZoneIsFinished()
	local ZoneFinishCatch = function()
		self.zones[self.currentZone] = nil
		self.currentZone = nil
		
		self.raidNumber = 0
		
		self.currentZone = POSSIBLE_ZONES[1]
		if not self.zones[self.currentZone] and POSSIBLE_ZONES[2] then
			table.remove(POSSIBLE_ZONES, 1)
			self.currentZone = POSSIBLE_ZONES[1]
		end

		EventManager:FireEvent("boss_hunters_zone_finished")
		self.zonesFinished = (self.zonesFinished or 0) + 1

		if self.currentZone == nil or self.zones[self.currentZone] == nil then
			RoundManager:GameIsFinished(true)
		else
			table.remove(POSSIBLE_ZONES, 1)
		end
	end
	status, err, ret = xpcall(ZoneFinishCatch, debug.traceback, self)
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
end

function RoundManager:GameIsFinished(bWon)
	local GameFinishCatch = function()
		EventManager:FireEvent("boss_hunters_game_finished")
		if bWon then
			self.prepTimer = 30
			self.ng = false
			self.votedToNG = 0
			self.votedNoNg = 0
			CustomGameEventManager:Send_ServerToAllClients("bh_start_ng_vote", {ascLevel = RoundManager:GetAscensions() + 1})
			GameRules.Winner = DOTA_TEAM_GOODGUYS
			Timers(1, function()
				CustomGameEventManager:Send_ServerToAllClients( "updateQuestPrepTime", { prepTime = math.floor(self.prepTimer + 0.5) } )
				if self.prepTimer <= 0 then
					if not self.ng then
						GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
					else
						RoundManager:StartGame()
					end
					CustomGameEventManager:Send_ServerToAllClients("bh_end_prep_time", {})
					self.ng = false
				else
					self.prepTimer = self.prepTimer - 1
					return 1
				end
			end)
		else
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
			GameRules.Winner = DOTA_TEAM_BADGUYS
		end
		GameRules._finish = true
		GameRules.EndTime = GameRules:GetGameTime()
		statCollection:submitRound(true)
	end
	status, err, ret = xpcall(GameFinishCatch, debug.traceback, self)
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
end

function RoundManager:InitializeUnit(unit, bElite)
	unit.hasBeenInitialized = true
	local expectedHP = unit:GetBaseMaxHealth() * RandomFloat(0.9, 1.1)
	local expectedDamage = ( unit:GetAverageBaseDamage() + (RoundManager:GetEventsFinished() * 2) ) * RandomFloat(0.85, 1.15)
	local playerHPMultiplier = 0.25
	local playerDMGMultiplier = 0.075
	local playerArmorMultiplier = 0.05
	if GameRules:GetGameDifficulty() == 4 then 
		expectedHP = expectedHP * 1.5
		expectedDamage = expectedDamage * 1.2
		playerHPMultiplier = 0.33
		playerDMGMultiplier = 0.1
		playerArmorMultiplier = 0.12
	end
	local effective_multiplier = (HeroList:GetActiveHeroCount() - 1)
	
	local HPMultiplierFunc = function( events, raids, zones ) return (0.8 + (events * 0.08)) * ( 1 + raids * 0.33 ) * ( 1 + zones * 0.12 ) end
	local DMGMultiplierFunc = function( events, raids, zones ) return ( 0.5 + (events * 0.05)) * ( 1 + raids * 0.075) * ( 1 + zones * 0.03 ) end
	
	local effPlayerHPMult =  HPMultiplierFunc( RoundManager:GetEventsFinished(), RoundManager:GetRaidsFinished(), RoundManager:GetZonesFinished() )
	local effPlayerDMGMult = DMGMultiplierFunc( RoundManager:GetEventsFinished(), RoundManager:GetRaidsFinished(), RoundManager:GetZonesFinished() )
	local effPlayerArmorMult = 0.7 + (effective_multiplier * playerArmorMultiplier) 
	
	maxPlayerHPMult = HPMultiplierFunc( EVENTS_PER_RAID * RAIDS_PER_ZONE * ZONE_COUNT, RAIDS_PER_ZONE * ZONE_COUNT, ZONE_COUNT)
	effPlayerHPMult = math.min( effPlayerHPMult, maxPlayerHPMult )
	effPlayerHPMult = effPlayerHPMult * ( 1 + RoundManager:GetAscensions() * 0.25 )  * (1 + effective_multiplier * playerHPMultiplier )
	
	maxPlayerDMGMult = DMGMultiplierFunc( EVENTS_PER_RAID * RAIDS_PER_ZONE * ZONE_COUNT, RAIDS_PER_ZONE * ZONE_COUNT, ZONE_COUNT)
	effPlayerDMGMult = math.min( effPlayerDMGMult, maxPlayerDMGMult )
	effPlayerDMGMult = effPlayerDMGMult * ( 1 + RoundManager:GetAscensions() * 1 )  * (1 + effective_multiplier * playerDMGMultiplier )
	
	effPlayerArmorMult = effPlayerArmorMult * ( 1 + RoundManager:GetAscensions() * 0.5 )
	
	if not unit:IsRoundBoss() then
		effPlayerHPMult = effPlayerHPMult / 2
		effPlayerDMGMult = effPlayerDMGMult / 2
		effPlayerArmorMult = effPlayerArmorMult / 2
	end
	
	
	if bElite then
		effPlayerHPMult = effPlayerHPMult * 1.35
		effPlayerDMGMult = effPlayerDMGMult * 1.2
		
		local nParticle = ParticleManager:CreateParticle( "particles/econ/courier/courier_onibi/courier_onibi_yellow_ambient_smoke_lvl21.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
		ParticleManager:ReleaseParticleIndex( nParticle )
		unit:SetModelScale(unit:GetModelScale()*1.15)
		
		local eliteTypes = {}
		for eliteType, weight in pairs(GameRules._Elites) do
			if tonumber(weight) > 0 then
				for i = 1, tonumber(weight) do
					table.insert(eliteTypes, eliteType)
				end
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
	
	expectedHP = math.max( 1, expectedHP * effPlayerHPMult )
	unit:SetCoreHealth(expectedHP)
	
	unit:SetAverageBaseDamage( expectedDamage * effPlayerDMGMult, 33)
	unit:SetBaseHealthRegen(RoundManager:GetEventsFinished() * RandomFloat(0.85, 1.15) )
	
	local msBonus = unit:GetBaseMoveSpeed() * 0.035 * effective_multiplier * (GameRules:GetGameDifficulty() / 2)
	unit:SetBaseMoveSpeed( unit:GetBaseMoveSpeed() + msBonus )
	
	local bonusArmor = math.min( RoundManager:GetRaidsFinished() + RoundManager:GetZonesFinished() * 2.5, 60 )
	if not unit:IsRoundBoss() then
		bonusArmor =  math.min( RoundManager:GetRaidsFinished(), 20 )
	end
	if unit:IsRangedAttacker() then
		bonusArmor = math.floor( bonusArmor * 0.6 )
	end
	
	unit:SetPhysicalArmorBaseValue( (unit:GetPhysicalArmorBaseValue() + bonusArmor ) * effPlayerArmorMult )
	
	unit:AddNewModifier(unit, nil, "modifier_boss_attackspeed", {})
	local powerScale = unit:AddNewModifier(unit, nil, "modifier_power_scaling", {})
	
	local SAMultiplierFunc = function( events, raids, zones ) return 2 * math.floor( (events) * (1 + (raids * 0.25 ) * ( zones * 0.25 ) ) ) end
	local maxSpellAmpScale = SAMultiplierFunc( (EVENTS_PER_RAID + 1) * RAIDS_PER_ZONE * ZONE_COUNT, RAIDS_PER_ZONE * ZONE_COUNT, ZONE_COUNT)
	local spellAmpScale = SAMultiplierFunc( RoundManager:GetEventsFinished(), RoundManager:GetRaidsFinished(), RoundManager:GetZonesFinished() )
	spellAmpScale = math.min( maxSpellAmpScale, spellAmpScale ) * ( (1 +  RoundManager:GetAscensions()) * 3 )
	
	if powerScale then powerScale:SetStackCount( spellAmpScale ) end
	unit:AddNewModifier(unit, nil, "modifier_spawn_immunity", {duration = 4/GameRules.gameDifficulty})
	if unit:IsRoundBoss() then
		local evasion = unit:AddNewModifier(unit, nil, "modifier_boss_evasion", {})
		if evasion then evasion:SetStackCount( 2.5 * RoundManager:GetRaidsFinished() ) end
		if RoundManager:GetAscensions() > 0 then unit:AddNewModifier(unit, nil, "modifier_boss_ascension", {}) end
	end
	
	
	if unit:GetHullRadius() <= 16 then
		unit:SetHullRadius( math.ceil(16 * unit:GetModelScale() ) )
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

--- UTILITY FUNCTIONS

function RoundManager:GetCurrentEvent()
	if self.currentZone and self.zones and self.zones[self.currentZone] and self.zones[self.currentZone][1] and self.zones[self.currentZone][1][1] then
		return self.zones[self.currentZone][1][1]
	end
end

function RoundManager:PickRandomSpawn()
	return RoundManager.spawnPositions[RandomInt(1, #RoundManager.spawnPositions)]
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

function RoundManager:GetAscensions()
	self.ascensionLevel = self.ascensionLevel or 0
	return self.ascensionLevel or 0
end

function RoundManager:GetCurrentEventName()
	return self.zones[self.currentZone][1][1]:GetEventName()
end

function RoundManager:GetCurrentZone()
	return self.currentZone
end

function RoundManager:GetCurrentRaidTier()
	return RoundManager.raidNumber or 1
end

function RoundManager:IsRoundGoing()
	if self:GetCurrentEvent() then
		return self:GetCurrentEvent():HasStarted()
	else
		return false
	end
end