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

POSSIBLE_ZONES = POSSIBLE_ZONES or {"Grove", "Sepulcher", "Solitude", "Elysium"}

EVENTS_PER_RAID = EVENTS_PER_RAID or 4
RAIDS_PER_ZONE = RAIDS_PER_ZONE or 2
ZONE_COUNT = ZONE_COUNT or #POSSIBLE_ZONES

COMBAT_CHANCE = 70
ELITE_CHANCE = 20
EVENT_CHANCE = 100 - COMBAT_CHANCE

PREP_TIME = 60


function RoundManager:Initialize(context)
	RoundManager = self
	self.bossPool = LoadKeyValues('scripts/kv/boss_pool.txt')
	self.eventPool = LoadKeyValues('scripts/kv/event_pool.txt')
	self.combatPool = LoadKeyValues('scripts/kv/combat_pool.txt')
	self.specificRoundKV = LoadKeyValues('scripts/kv/combat_data.txt')

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

function RoundManager:VoteSkipPrepTime(userid, info)
	self.votedToSkipPrep = self.votedToSkipPrep or {}
	
	self.votedToSkipPrep[info.eventID] = self.votedToSkipPrep[info.eventID] or {}
	for event, playerVotes in pairs( self.votedToSkipPrep ) do
		playerVotes[info.pID] = nil
	end
	
	self.votedToSkipPrep[info.eventID][info.pID] = true
	local highestChoiceVotes = 0
	for event, playerVotes in pairs( self.votedToSkipPrep ) do
		local eventChoiceVotes = 0
		for playerVote, _ in pairs( playerVotes ) do
			eventChoiceVotes = eventChoiceVotes + 1
		end
		if eventChoiceVotes > highestChoiceVotes then
			highestChoiceVotes = eventChoiceVotes
			self.currentlyActiveEvent = self.zones[self.currentZone][1][1][tonumber(event)]
		end
	end
	if highestChoiceVotes < HeroList:GetActiveHeroCount() then
		self.prepTimer = self.maximumAllotedPrepTime / (highestChoiceVotes + 1)
	else
		self.prepTimer = math.max( (self.freezePreparationTime or 0) + 0.5, 0 )
	end
	CustomGameEventManager:Send_ServerToAllClients("bh_update_votes_prep_time", {votes = self.votedToSkipPrep})
	CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_update_timer", { game_time = GameRules:GetDOTATime( false, true ) + self.prepTimer } )
end

function RoundManager:VoteNewGame(userid, event)
	print( self.ng, "hello?" )
	if self.ng then return end
	self.votedToNG = (self.votedToNG or 0)
	self.votedNoNg = (self.votedNoNg or 0)
	if toboolean(event.vote) then
		self.votedToNG = (self.votedToNG or 0) + 1
	else
		self.votedNoNg = (self.votedNoNg or 0) + 1
	end
	local noVotes = HeroList:GetActiveHeroCount() - self.votedToNG
	local nonVotes = HeroList:GetActiveHeroCount() - self.votedToNG
	CustomGameEventManager:Send_ServerToAllClients("bh_update_votes_newgame", {yes = self.votedToNG, no = noVotes})
	print( self.prepTimer, "hello2?", noVotes, self.votedToNG, self.votedNoNg, math.ceil( HeroList:GetActiveHeroCount() / 2 ) )
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
		self.specificRoundKV = LoadKeyValues('scripts/kv/combat_data.txt')
		POSSIBLE_ZONES = {"Grove", "Sepulcher", "Solitude", "Elysium"}
		self.prepTimer = 5
		CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_update_timer", { game_time = GameRules:GetDOTATime( false, true ) + self.prepTimer } )
		for i = 1, ZONE_COUNT do
			local zoneName = POSSIBLE_ZONES[i]
			RoundManager:ConstructRaids(zoneName)
		end
	elseif self.votedNoNg >= math.ceil( HeroList:GetActiveHeroCount() / 2 ) then
		self.ng = false
		self.prepTimer = 0
		CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_update_timer", { game_time = GameRules:GetDOTATime( false, true ) + self.prepTimer } )
	end
end

BH_MINION_TYPE_WILD = 1
BH_MINION_TYPE_UNDEAD = bit.lshift(BH_MINION_TYPE_WILD, 1)
BH_MINION_TYPE_DEMONIC = bit.lshift(BH_MINION_TYPE_UNDEAD, 1)
BH_MINION_TYPE_CELESTIAL = bit.lshift(BH_MINION_TYPE_DEMONIC, 1)

BH_MINION_TYPE_MINION = bit.lshift(BH_MINION_TYPE_CELESTIAL, 1)
BH_MINION_TYPE_BOSS = bit.lshift(BH_MINION_TYPE_MINION, 1)

function RoundManager:OnNPCSpawned(event)
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit 
	or spawnedUnit:IsPhantom() 
	or spawnedUnit:GetClassname() == "npc_dota_thinker" 
	or spawnedUnit:GetUnitName() == "" 
	or spawnedUnit:IsFakeHero() 
	or ( spawnedUnit:IsOther() and not spawnedUnit:IsCreature() )
	or spawnedUnit:GetUnitName() == "npc_dummy_unit" 
	or spawnedUnit:GetUnitName() == "npc_dummy_blank" 
	or spawnedUnit:GetUnitName() == "wearable_dummy" then
		return
	end
	Timers:CreateTimer(function()
		if spawnedUnit and not spawnedUnit:IsNull() then
			-- set up handlers
			local handler = spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_stats_system_handler", {})
			if spawnedUnit:IsAlive() and spawnedUnit:IsCreature() and spawnedUnit:GetTeam() == DOTA_TEAM_BADGUYS then
				AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnedUnit:GetAbsOrigin(), 516, 3, false) -- show spawns
				if spawnedUnit:IsRoundNecessary() then
					ParticleManager:FireParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_end_nexon_hero_cp_2014.vpcf", PATTACH_POINT_FOLLOW, spawnedUnit)
					EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", spawnedUnit)
				end
				if not spawnedUnit.hasBeenInitialized then
					RoundManager:InitializeUnit(spawnedUnit, not spawnedUnit:IsMinion() and ((RoundManager:GetCurrentEvent() and RoundManager:GetCurrentEvent():IsElite() ) or RoundManager:GetAscensions() > 0))
					GridNav:DestroyTreesAroundPoint(spawnedUnit:GetAbsOrigin(), spawnedUnit:GetHullRadius() + spawnedUnit:GetCollisionPadding() + 350, true)
					FindClearSpaceForUnit(spawnedUnit, spawnedUnit:GetAbsOrigin(), true)
				end
				local typeModifier = spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_typing_tag", {})
				if spawnedUnit:IsWild() then
					typeModifier:SetStackCount( BH_MINION_TYPE_WILD )
				end
				if spawnedUnit:IsUndead() then
					typeModifier:SetStackCount( typeModifier:GetStackCount() + BH_MINION_TYPE_UNDEAD )
				end
				if spawnedUnit:IsDemon() then
					typeModifier:SetStackCount( typeModifier:GetStackCount() + BH_MINION_TYPE_DEMONIC )
				end
				if spawnedUnit:IsCelestial() then
					typeModifier:SetStackCount( typeModifier:GetStackCount() + BH_MINION_TYPE_CELESTIAL )
				end
				if spawnedUnit:IsMinion() then
					typeModifier:SetStackCount( typeModifier:GetStackCount() + BH_MINION_TYPE_MINION )
				end
				if spawnedUnit:IsBoss() then
					typeModifier:SetStackCount( typeModifier:GetStackCount() + BH_MINION_TYPE_BOSS )
				end
				-- 1 april
				-- spawnedUnit:AddAbilityPrecache("elite_tiny")
			elseif spawnedUnit:IsRealHero() then
				Timers:CreateTimer(0.1, function() 
					if not RoundManager:IsTouchingBoundingBox(spawnedUnit) then
						FindClearSpaceForUnit( spawnedUnit, RoundManager:GetHeroSpawnPosition(), true ) 
					end
					spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_tombstone_respawn_immunity", {duration = 3}) 
				end)
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
		castingHero:AddGold( math.max( 10, RoundManager:GetEventsFinished() * 2 ) )
		if GameRules:GetGameDifficulty() >= 3 then
			target:SetHealth( target:GetMaxHealth() * 0.25 )
			target:SetMana( target:GetMaxMana() * 0.25 )
		end
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
		for i = 1, EVENTS_PER_RAID do
			local raidContent
			local raidPackage = {}
			local eventsForPackage = RandomInt( 1, 3 )
			self.eventsCreated = self.eventsCreated + 1
			POSSIBLE_REWARDS = {EVENT_REWARD_GOLD, EVENT_REWARD_LIVES, EVENT_REWARD_RELIC}
			for i = 1, eventsForPackage do 
				-- if self.eventsCreated % 10 == 8 then -- elite round
					-- combatPick = "grove_elite_valgraduth"
					-- if zoneName == "Sepulcher" then
						-- combatPick = "sepulcher_elite_arthromos"
					-- elseif zoneName == "Solitude" then
						-- combatPick = "solitude_elite_durva"
					-- elseif zoneName == "Elysium" then
						-- combatPick = "elysium_elite_ammetot"
					-- end
					-- print("created elite", combatPick)
					-- raidContent = BaseEvent(zoneName, EVENT_TYPE_ELITE, combatPick )
				-- else -- non fixed round
				local rewardKey = RandomInt( 1, math.min( #POSSIBLE_REWARDS, i ) )
				local reward = POSSIBLE_REWARDS[rewardKey]
				if RollPercentage( COMBAT_CHANCE ) or self.eventsCreated < 3 then -- Rolled Combat
					local combatType = EVENT_TYPE_COMBAT
					if self.eventsCreated >= 3 and RollPercentage( ELITE_CHANCE ) then
						combatType = EVENT_TYPE_ELITE
					end
					if zoneCombatPool[1] == nil then
						zoneCombatPool = TableToWeightedArray( self.combatPool[zoneName] )
					end
					
					local combatPick = zoneCombatPool[RandomInt(1, #zoneCombatPool)]
					raidContent = BaseEvent(zoneName, combatType, combatPick, rewardKey )
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
				table.insert( raidPackage, raidContent )
			end
			table.insert( raid, raidPackage )
		end
		
		if zoneBossPool[1] == nil then
			zoneBossPool = TableToWeightedArray( self.bossPool[zoneName] )
		end
		local bossPicks = {}
		local bossPick = zoneBossPool[RandomInt(1, #zoneBossPool)]
		local bossEvent = BaseEvent(zoneName, EVENT_TYPE_BOSS, bossPick )
		table.insert( bossPicks, bossEvent )
		for id = #zoneBossPool, 1, -1 do
			local event = zoneBossPool[id]
			if event == bossPick then
				table.remove( zoneBossPool, id )
			end
		end
		local bossPick2 = zoneBossPool[RandomInt(1, #zoneBossPool)]
		local bossEvent2 = BaseEvent(zoneName, EVENT_TYPE_BOSS, bossPick2 )
		table.insert( bossPicks, bossEvent2 )
		for id = #zoneBossPool, 1, -1 do
			local event = zoneBossPool[id]
			if event == bossPick2 then
				table.remove( zoneBossPool, id )
			end
		end
		self.eventsCreated = self.eventsCreated + 1
		
		table.insert( raid, bossPicks )
		table.insert( self.zones[zoneName], raid )
	end
	-- Final Boss bruh
	if zoneName == "Elysium" then 
		local finalBoss = BaseEvent(zoneName, EVENT_TYPE_BOSS, "elysium_boss_apotheosis" )
		table.insert( self.zones[zoneName][#self.zones[zoneName]], {finalBoss} )
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
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero ~=nil then
					RelicManager:RollBossRelicsForPlayer( nPlayerID )
				end
			end
		end
	end
	self.raidsFinished = (self.raidsFinished or 0) + 1
	if self.prepTimeTimer then 
		Timers:RemoveTimer( self.prepTimeTimer )
		self.prepTimeTimer = nil
	end
	local lastSpawns = RoundManager.boundingBox
	RoundManager:LoadSpawns()
	CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_new_zone_started", { zone = self.currentZone, tier = self:GetCurrentRaidTier() } )
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

function RoundManager:StartPrepTime(fPrep, forceSet)
	local PrepCatch = function( ... )
		self.lastPrepTimeDuration = fPrep
		if forceSet then
			if self.prepTimeTimer then Timers:RemoveTimer( self.prepTimeTimer ) end
			self.prepTimeTimer = nil
			CustomGameEventManager:Send_ServerToAllClients("bh_end_prep_time", {})
		end
		if self.zones[self.currentZone] and self.zones[self.currentZone][1] and self.zones[self.currentZone][1][1] and not self.prepTimeTimer then
			self.currentlyActiveEvent = nil
			local events = {}
			self.votedToSkipPrep = {}
			for id, event in pairs( self.zones[self.currentZone][1][1] ) do
				event._playerChoices = {}
				local foes = {}
				for enemy, data in pairs(event:GetEnemiesToSpawn()) do
					local foe = {}
					foe.name = enemy
					foe.amount = (data.Amount or 0) + (data.RaidBonus or 0) * (RoundManager:GetCurrentRaidTier() - 1) + math.floor( HeroList:GetActiveHeroCount() * (data.HeroBonus or 0) )
					foe.abilities = {}
					local unitKV = GameRules.UnitKV[enemy]
					if unitKV then
						for i = 1, 25 do
							local abilityName = unitKV["Ability"..i]
							if abilityName then
								table.insert( foe.abilities, abilityName )
							end
						end
					end
					table.insert( foes, foe )
				end
				local maskedEventName = event:GetEventName()
				if event:GetEventType() == EVENT_TYPE_EVENT then
					maskedEventName = string.lower(self.currentZone).."_random_event"
				end
				local modifiersToSend = event:ChampionSpawnModifiers()
				self.votedToSkipPrep[id] = {}
				local eventToSend = {foes = foes, modifiers = modifiersToSend, eventName = maskedEventName, eventType = event:GetEventType(), reward = event:GetEventRewardType()}
				table.insert( events, eventToSend )
			end
			CustomGameEventManager:Send_ServerToAllClients("bh_start_prep_time", {events = events})
			for _, hero in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_FRIENDLY}) ) do
				if hero:IsRealHero() then
					PlayerResource:SetCustomBuybackCost(hero:GetPlayerID(), 100 + RoundManager:GetEventsFinished() * 25)
				end
				hero:AddNewModifier( hero, nil, "modifier_restoration_disable", {} )
			end
			ResolveNPCPositions( RoundManager:GetHeroSpawnPosition(), 150 )
			for _, hero in ipairs( HeroList:GetRealHeroes() ) do
				hero:SetRespawnPosition( GetGroundPosition(hero:GetAbsOrigin(), hero) )
			end
			self.prepTimer = fPrep or PREP_TIME
			self.maximumAllotedPrepTime = self.prepTimer
			
			CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_update_timer", { game_time = GameRules:GetDOTATime( false, true ) + self.prepTimer } )
			CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_update_rounds", { rounds = self:GetEventsFinished(), round_name = "interlude", ascensions = RoundManager:GetAscensions() } )
			
			self.prepTimeTimer = Timers:CreateTimer(1, function()
				self.prepTimer = self.prepTimer - 1
				self.maximumAllotedPrepTime = self.maximumAllotedPrepTime - 1
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
		self.votedToSkipPrep = {}
		CustomGameEventManager:Send_ServerToAllClients("bh_end_prep_time", {})
		
		for _, hero in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_FRIENDLY}) ) do
			hero:RemoveModifierByName( "modifier_restoration_disable" )
		end
		if not self:GetCurrentEvent() then
			local eventChoices = self.zones[self.currentZone][1][1]
			self.currentlyActiveEvent = eventChoices[RandomInt(1, #eventChoices)]
		end
		if not bReset then
			RoundManager:StartEvent()
		end
	end
	status, err, ret = xpcall(EndPrepCatch, debug.traceback, self, bReset )
	if not status and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
end

function RoundManager:StartEvent()
	local StartEventCatch = function( ... )
		GameRules:RefreshPlayers( false, self.lastPrepTimeDuration ) 
		EmitGlobalSound("Round.Start")
		
		local playerData = {}
		for _, hero in ipairs ( HeroList:GetAllHeroes() ) do
			if not hero:IsFakeHero() then
				playerData[hero:GetPlayerID()] = {DT = hero.statsDamageTaken or 0, DD = hero.statsDamageDealt or 0, DH = hero.statsDamageHealed or 0}
			end
		end
		CustomGameEventManager:Send_ServerToAllClients( "player_update_stats", playerData )
		if RoundManager:GetCurrentEvent() then
			local event = RoundManager:GetCurrentEvent()
			event.eventHasStarted = true
			event.eventEnded = false
			event:StartEvent()
			
			CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_update_timer", { game_time = GameRules:GetDOTATime( false, true ) + (event.timeRemaining or 0) } )
			CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_update_rounds", { rounds = self:GetEventsFinished(), round_name = event:GetEventName(), ascensions = RoundManager:GetAscensions() } )
			
			EventManager:FireEvent("boss_hunters_event_started", {eventType = event:GetEventType()})
			if event:GetEventType() == EVENT_TYPE_BOSS then
				Notifications:BottomToAll({text="A great foe is nearby.", duration=3.5})
			elseif event:GetEventType() == EVENT_TYPE_ELITE then
				Notifications:BottomToAll({text="You feel uneasy...", duration=3.5})
			end
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
	if not status then -- skip and go next
		RoundManager:EndEvent(true)
	end
end

function RoundManager:EndEvent(bWonRound)
	local EndEventCatch = function(  )
		GameRules:RefreshPlayers( GameRules:GetGameDifficulty() >= 3 and bWonRound ) 
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
		local event = self:GetCurrentEvent()
		if event then
			event.eventEnded = true
			event.eventHasStarted = false
			if event.eventHandler then Timers:RemoveTimer( event.eventHandler ) end
			if bWonRound then
				EventManager:FireEvent("boss_hunters_event_finished", {eventType = event:GetEventType()})
				event:HandoutRewards(true)
				self.zones[self.currentZone][1][1] = false
				table.remove( self.zones[self.currentZone][1], 1 )
				
				self.eventsFinished = self.eventsFinished + 1
				if self.zones[self.currentZone][1][1] == nil then RoundManager:RaidIsFinished() end
				EmitGlobalSound("Round.Won")
			else
				local gold = ( 800 + math.min( 4, RoundManager:GetZonesFinished() + 1 ) ) * ( GameRules.BasePlayers - HeroList:GetActiveHeroCount() )
				for _, hero in ipairs( HeroList:GetRealHeroes() ) do
					hero:AddGold( gold )
				end
				event:HandoutRewards(false)
				EmitGlobalSound("Round.Lost")
				return RoundManager:GameIsFinished(false)
			end
		end
		
		for _, unit in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_FRIENDLY, flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD}) ) do
			unit:Dispel(unit, true)
			unit:SetThreat( 0 )
		end
		
		self.freezePreparationTime = 1
		Timers:CreateTimer(function()
			for _, unit in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_ENEMY, flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD}) ) do
				if unit:GetTeam() == DOTA_TEAM_BADGUYS then
					if unit:IsCreature() and not unit:IsNull() then
						if unit:IsAlive() then
							unit:ForceKill(false)
						end
					end
				else
					if not unit:IsHero() then
						
					end
				end
			end
			self.freezePreparationTime = self.freezePreparationTime - 0.25
			if self.freezePreparationTime > 0 then
				return 0.25
			else
				collectgarbage()
			end
		end)
		local fTime = PREP_TIME
		-- if RoundManager:GetCurrentEvent() and RoundManager:GetCurrentEvent():IsEvent() then
			-- fTime = 5
		-- end
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
		-- if GameRules._lives == 0 then
			-- return RoundManager:GameIsFinished(false)
		-- end
		self:StartPrepTime(fTime)
	end
	status, err, ret = xpcall(EndEventCatch, debug.traceback, self, bWonRound )
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
	if not status then -- go next phase
		local fTime = PREP_TIME
		-- if RoundManager:GetCurrentEvent() and RoundManager:GetCurrentEvent():IsEvent() then
			-- fTime = 5
		-- end
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
		if GameRules._lives == 0 then
			return RoundManager:GameIsFinished(false)
		end
		self:StartPrepTime(fTime)
	end
end

function RoundManager:LoadSpawns()
	RoundManager.spawnPositions = {}
	local zoneName = RoundManager:GetCurrentZone()
	
	RoundManager.raidNumber = (RoundManager.raidNumber or 0) + 1
	RoundManager.boundingBox = string.lower(zoneName).."_raid_"..RoundManager.raidNumber
	RoundManager.boundingBoxEntities = Entities:FindAllByName(RoundManager.boundingBox.."_edge_collider")
	RoundManager.boundingBoxEdges = Entities:FindAllByName(RoundManager.boundingBox.."_edge_finder")
	
	print( RoundManager.boundingBox, zoneName, "loading spawns")
	for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_spawner" ) ) do
		table.insert( RoundManager.spawnPositions, spawnPos:GetAbsOrigin() )
	end
	RoundManager.heroSpawnPosition = RoundManager.heroSpawnPosition or nil
	for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_heroes") ) do
		RoundManager.heroSpawnPosition = spawnPos:GetAbsOrigin()
		break
	end
	for _,spawnEnt in ipairs( Entities:FindAllByClassname("info_player_start_goodguys") ) do
		spawnEnt:SetAbsOrigin( RoundManager.heroSpawnPosition + RandomVector(128) )
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
		
		self.raidsFinished = (self.raidsFinished or 0) + 1
		
		local lastSpawns = RoundManager.boundingBox
		RoundManager:LoadSpawns()
		CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_new_zone_started", { zone = self.currentZone, tier = self:GetCurrentRaidTier() } )
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero.statsDamageTaken = 0
			hero.statsDamageDealt = 0
			hero.statsDamageHealed = 0
			hero:RefreshAllCooldowns(true)
			if RoundManager.boundingBox ~= lastSpawns then
				CustomGameEventManager:Send_ServerToAllClients( "bh_move_camera_position", { position = RoundManager:GetHeroSpawnPosition() } )
				local position = RoundManager:GetHeroSpawnPosition() + RandomVector(64)
				hero:SetRespawnPosition( position )
			end
		end
		
		for _, unit in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_FRIENDLY, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD }) ) do
			local position = RoundManager:GetHeroSpawnPosition() + RandomVector(64)
			FindClearSpaceForUnit(unit, position, true)
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
		-- Register Statistics for all heroes for ascension 0, who cares about that other shit
		if RoundManager:GetAscensions() == 0 and not IsInToolsMode() then
			for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
				RoundManager:RegisterStatsForHero( hero, bWon )
			end
		end
		-- end registering
		if bWon then
			self.prepTimer = 30
			self.ng = false
			self.votedToNG = 0
			self.votedNoNg = 0
			CustomGameEventManager:Send_ServerToAllClients("bh_start_ng_vote", {ascLevel = RoundManager:GetAscensions() + 1})
			CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_update_timer", { game_time = GameRules:GetDOTATime( false, true ) + self.prepTimer } )
			GameRules.Winner = DOTA_TEAM_GOODGUYS
			Timers(1, function()
				if self.prepTimer <= 0 then
					if not self.ng then
						GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
						GameRules._finish = true
						GameRules.EndTime = GameRules:GetGameTime()
						-- statCollection:submitRound(true)
					else
						Timers(3, function()
							RoundManager:StartGame()
						end)
						GameRules._finish = true
						GameRules.EndTime = GameRules:GetGameTime()
						-- statCollection:submitRound(false)
					end
					CustomGameEventManager:Send_ServerToAllClients("bh_end_prep_time", {})
					CustomGameEventManager:Send_ServerToAllClients("bh_end_ng_vote", {})
					self.ng = false
				else
					self.prepTimer = self.prepTimer - 1
					return 1
				end
			end)
		else
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
			GameRules.Winner = DOTA_TEAM_BADGUYS
			GameRules._finish = true
			GameRules.EndTime = GameRules:GetGameTime()
			-- statCollection:submitRound(true)
		end
	end
	status, err, ret = xpcall(GameFinishCatch, debug.traceback, self)
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
end

function RoundManager:RegisterStatsForHero( hero, bWon )
	-----------------------------------------------------------------------
	-----------------------------------------------------------------------
	-- REGISTER NAIVE ASS STATISTICS
	-----------------------------------------------------------------------
	-----------------------------------------------------------------------
	local statSettings = LoadKeyValues("scripts/vscripts/statcollection/settings.kv")
	local AUTH_KEY = statSettings.modID
	local SERVER_LOCATION = statSettings.serverLocation
	local heroName = hero:GetUnitName()
	local matchId = GameRules:GetMatchID()
	if tostring(matchId) == '0' then
		matchId = RandomInt(1, 99999999)
	end
	

	local packageLocation = SERVER_LOCATION..AUTH_KEY.."/heroes/"..heroName..'.json'
	local getRequest = CreateHTTPRequestScriptVM( "GET", packageLocation)

	getRequest:Send( function( result )
		local putData = {}
		putData.heroes = {}
		local wins = 0
		putData.wins = wins
		putData.plays = 1
		
		local decoded = {}
		if tostring(result.Body) ~= 'null' then
			decoded = json.decode(result.Body)
		end
		wins = (decoded.wins or 0)
		decoded.talents = decoded.talents or {}
		if bWon then
			wins = wins + 1
		end
		
		putData.talents = {}
		for i = 0, hero:GetAbilityCount() - 1 do
			local ability = hero:GetAbilityByIndex( i )
			if ability and ability:GetClassname() == "special_bonus_undefined" then
				local talent = ability:GetAbilityName()
				putData.talents[talent] = {}
				local talentData = decoded.talents[talent] or {}
				local talentPlays = (talentData.plays or 0)
				local talentWins = (talentData.wins or 0)
				if ability:GetLevel() > 0 then
					talentPlays = talentPlays + 1
					if bWon then
						talentWins = talentWins + 1
					end
				end
				putData.talents[talent].wins = talentWins
				putData.talents[talent].plays = talentPlays
			end
		end
		
		putData.plays = (decoded.plays or 0) + 1
		putData.wins = wins
		
		local encoded = json.encode(putData)
		local putRequest = CreateHTTPRequestScriptVM( "PUT", packageLocation)
		putRequest:SetHTTPRequestRawPostBody("application/json", encoded)
		putRequest:Send( function( result ) end )
	end )
end

function RoundManager:InitializeUnit(unit, bElite)
	local event = RoundManager:GetCurrentEvent()
	unit.hasBeenInitialized = true
	unit.NPCIsElite = bElite
	if bElite and event then event.eliteHasBeenInitialized = true end
	local expectedHP = unit:GetBaseMaxHealth() * RandomFloat(0.95, 1.05)
	local expectedDamage = ( unit:GetAverageBaseDamage() + (RoundManager:GetEventsFinished() * 1.5) ) * RandomFloat(0.90, 1.10)
	local playerHPMultiplier = 0.5
	local playerDMGMultiplier = 0.15
	local playerArmorMultiplier = 0.075
	if GameRules:GetGameDifficulty() == 4 then 
		expectedHP = expectedHP * 1.4
		expectedDamage = expectedDamage * 1.35
	else
		expectedDamage = expectedDamage * 0.9
	end
	local effective_multiplier = (HeroList:GetActiveHeroCount() - 1)
	
	local HPMultiplierFunc = function( events, raids, zones ) return (0.14 + (events * 0.02)) * ( 1 + raids * (0.8 + HeroList:GetActiveHeroCount()/50) ) * ( 1 + zones * (0.10 + HeroList:GetActiveHeroCount()/100) ) end
	local DMGMultiplierFunc = function( events, raids, zones ) return ( 0.13 + (events * 0.035)) * ( 1 + raids * (0.028 + HeroList:GetActiveHeroCount()/50)) * ( 1 + zones * (0.023 + HeroList:GetActiveHeroCount()/100) ) end
	
	
	
	local effPlayerHPMult =  HPMultiplierFunc( RoundManager:GetEventsFinished(), RoundManager:GetRaidsFinished(), RoundManager:GetZonesFinished() )
	local effPlayerDMGMult = DMGMultiplierFunc( RoundManager:GetEventsFinished(), RoundManager:GetRaidsFinished(), RoundManager:GetZonesFinished() )
	local effPlayerArmorMult = 0.7 + (effective_multiplier * playerArmorMultiplier) 
	
	print( "multiplier:", effPlayerHPMult, effPlayerDMGMult, effPlayerArmorMult )
	
	maxPlayerHPMult = HPMultiplierFunc( ( EVENTS_PER_RAID + 1 ) * RAIDS_PER_ZONE * ZONE_COUNT, RAIDS_PER_ZONE * ZONE_COUNT, ZONE_COUNT)
	
	effPlayerHPMult = math.min( effPlayerHPMult, maxPlayerHPMult )
	effPlayerHPMult = effPlayerHPMult * ( 1.4^RoundManager:GetAscensions() )  * (1 + effective_multiplier * playerHPMultiplier + effective_multiplier / 10 )

	maxPlayerDMGMult = DMGMultiplierFunc( ( EVENTS_PER_RAID + 1 ) * RAIDS_PER_ZONE * ZONE_COUNT, RAIDS_PER_ZONE * ZONE_COUNT, ZONE_COUNT)
	effPlayerDMGMult = math.min( effPlayerDMGMult, maxPlayerDMGMult )
	effPlayerDMGMult = effPlayerDMGMult * ( 2^RoundManager:GetAscensions() )  * (1 + effective_multiplier * playerDMGMultiplier )
	
	
	effPlayerArmorMult = effPlayerArmorMult * ( 1.15^RoundManager:GetAscensions() )
	
	if unit:IsMinion() then
		effPlayerHPMult = effPlayerHPMult / 2
		effPlayerDMGMult = effPlayerDMGMult / 2
		effPlayerArmorMult = effPlayerArmorMult / 2
	end
	
	if bElite and not unit:IsMinion() then
		effPlayerHPMult = effPlayerHPMult * 1.35
		effPlayerDMGMult = effPlayerDMGMult * 1.2
		
		local nParticle = ParticleManager:CreateParticle( "particles/econ/courier/courier_onibi/courier_onibi_yellow_ambient_smoke_lvl21.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
		ParticleManager:ReleaseParticleIndex( nParticle )
		unit:SetModelScale(unit:GetModelScale()*1.15)
		
		local eliteAbilities = event:ChampionSpawnModifiers()
		for _, eliteAbName in pairs( event:ChampionSpawnModifiers() ) do
			local eliteAb = unit:AddAbilityPrecache(eliteAbName)
			eliteAb:UpgradeAbility(true)
		end
	end
	
	
	local msBonus = unit:GetBaseMoveSpeed() * 0.035 * effective_multiplier * (GameRules:GetGameDifficulty() / 2)
	unit:SetBaseMoveSpeed( unit:GetBaseMoveSpeed() + msBonus )
	
	local expectedRegen = RoundManager:GetEventsFinished() * RandomFloat(0.85, 1.15)
	local bonusArmor = math.min( RoundManager:GetRaidsFinished() * 2 + RoundManager:GetZonesFinished() * 4, 50 )
	if unit:IsMinion() then
		bonusArmor =  math.min( RoundManager:GetRaidsFinished(), 20 )
	end
	if unit:IsRangedAttacker() then
		bonusArmor = math.floor( bonusArmor * 0.75 )
	end
	
	local SAMultiplierFunc = function( events, raids, zones ) return 2 * math.floor( (events) * (1 + (raids * 0.2 ) * ( zones * 0.2 ) ) ) end
	local maxSpellAmpScale = SAMultiplierFunc( (EVENTS_PER_RAID + 1) * RAIDS_PER_ZONE * ZONE_COUNT, RAIDS_PER_ZONE * ZONE_COUNT, ZONE_COUNT)
	local spellAmpScale = SAMultiplierFunc( RoundManager:GetEventsFinished(), RoundManager:GetRaidsFinished(), RoundManager:GetZonesFinished() )
	
	if RoundManager:GetAscensions() > 0 then
		expectedRegen = math.min( expectedRegen, 80 ) * (1 + (RoundManager:GetAscensions() * 0.15))
		if unit:IsMinion() then
			expectedHP = expectedHP + RoundManager:GetEventsFinished() * 25
			expectedRegen = expectedRegen / 2
			expectedDamage = expectedDamage + RoundManager:GetEventsFinished() * 0.33
			bonusArmor = bonusArmor + RoundManager:GetRaidsFinished() * 0.5
			spellAmpScale = spellAmpScale + RoundManager:GetEventsFinished() / 2
		else
			expectedHP = expectedHP + RoundManager:GetEventsFinished() * 100
			expectedDamage = expectedDamage + RoundManager:GetEventsFinished() * 0.5
			bonusArmor = bonusArmor + RoundManager:GetRaidsFinished() * 2
			spellAmpScale = spellAmpScale + RoundManager:GetEventsFinished()
		end
	end
	spellAmpScale = math.min( maxSpellAmpScale, spellAmpScale ) * ( (1 +  RoundManager:GetAscensions()) * 3 )
	
	unit:SetPhysicalArmorBaseValue( math.min( 175, (unit:GetPhysicalArmorBaseValue() + bonusArmor ) * effPlayerArmorMult ) )
	
	expectedHP = math.max( 1, expectedHP * effPlayerHPMult )
	unit:SetCoreHealth(expectedHP)
	
	unit:SetAverageBaseDamage( math.max( 20 + HeroList:GetActiveHeroCount(), expectedDamage * effPlayerDMGMult ), 33)
	unit:SetBaseHealthRegen( expectedRegen )
	
	unit:AddNewModifier(unit, nil, "modifier_boss_attackspeed", {})
	local powerScale = unit:AddNewModifier(unit, nil, "modifier_power_scaling", {})
	
	
	if powerScale then powerScale:SetStackCount( spellAmpScale ) end
	if not unit:IsMinion() then
		local evasion = unit:AddNewModifier(unit, nil, "modifier_boss_evasion", {})
		if evasion then evasion:SetStackCount( RoundManager:GetAscensions() * 100 + math.min( RoundManager:GetRaidsFinished(), RAIDS_PER_ZONE * ZONE_COUNT ) ) end
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
			for _, eventChoices in pairs(raid) do
				for _, event in pairs(eventChoices) do
					event:PrecacheUnits(context)
				end
			end
		end
	end
end

--- UTILITY FUNCTIONS

function RoundManager:GetCurrentEvent()
	return self.currentlyActiveEvent
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
	return self:GetCurrentEvent():GetEventName()
end

function RoundManager:GetCurrentZone()
	return self.currentZone
end

function RoundManager:GetBoundingBoxes()
	return RoundManager.boundingBoxEntities
end

function RoundManager:GetBoundingBoxEdges()
	return RoundManager.boundingBoxEdges
end

function RoundManager:BoundingBoxPosition( )
	local position
	if RoundManager:GetBoundingBoxes() then
		for _, boundingBox in ipairs( RoundManager:GetBoundingBoxes() ) do
			position = position or boundingBox:GetAbsOrigin()
			position = position + boundingBox:GetAbsOrigin() / 2
		end
	end
	return position
end

function RoundManager:BoundingBoxPosition( )
	local position
	if RoundManager:GetBoundingBoxes() then
		for _, boundingBox in ipairs( RoundManager:GetBoundingBoxes() ) do
			position = position or boundingBox:GetAbsOrigin()
			position = position + boundingBox:GetAbsOrigin() / 2
		end
	end
	return position
end

function RoundManager:IsTouchingBoundingBox( unit )
	if RoundManager:GetBoundingBoxes() then
		for _, boundingBox in ipairs( RoundManager:GetBoundingBoxes() ) do
			if boundingBox:IsTouching( unit ) then
				return true
			end
		end
	else
		return true
	end
	return false
end

function RoundManager:FindBoundingBoxMinimumRadius( )
	local checkPos = RoundManager:BoundingBoxPosition( )
	local closest
	local distance = 999999999
	if RoundManager:GetBoundingBoxEdges() then
		for _, boundingBox in ipairs( RoundManager:GetBoundingBoxEdges() ) do
			local checkDist = CalculateDistance( boundingBox, checkPos )
			if checkDist < distance then
				distance = checkDist
				closest = boundingBox
			end
		end
	end
	return distance
end

function RoundManager:FindNearestBoundingBoxEdge( unit )
	local closest
	local distance = 999999999
	if RoundManager:GetBoundingBoxEdges() then
		for _, boundingBox in ipairs( RoundManager:GetBoundingBoxEdges() ) do
			if CalculateDistance( boundingBox, unit ) < distance then
				distance = CalculateDistance( boundingBox, unit )
				closest = boundingBox
			end
		end
	end
	return closest, distance
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

function RoundManager:GetStandardGoldReward()
	local EVENT_MAX = ( (EVENTS_PER_RAID + 1) * RAIDS_PER_ZONE * ZONE_COUNT )
	local RAID_MAX = RAIDS_PER_ZONE * ZONE_COUNT
	local eventScaling = math.min( RoundManager:GetEventsFinished(), EVENT_MAX ) * 0.75
	local raidScaling = 1 + math.min( RoundManager:GetRaidsFinished(), RAID_MAX ) * 0.125
	local playerScaling = 1 + ( GameRules.BasePlayers - HeroList:GetActiveHeroCount() ) / 10
	local baseGold = ( ( 200 + ( (25) * eventScaling ) ) + (80 * raidScaling) ) 
	return baseGold * playerScaling
end

function RoundManager:GetStandardXPReward()
	local EVENT_MAX = (EVENTS_PER_RAID + 1 * RAIDS_PER_ZONE * ZONE_COUNT)
	local RAID_MAX = RAIDS_PER_ZONE * ZONE_COUNT
	local eventScaling = math.min( RoundManager:GetEventsFinished(), EVENT_MAX ) * 0.75
	local raidScaling = 1 + math.min( RoundManager:GetRaidsFinished(), RAID_MAX ) * 0.15
	local playerScaling = 1 + ( GameRules.BasePlayers - HeroList:GetActiveHeroCount() ) / 10
	local baseXP = ( ( 150 + ( (40) * eventScaling ) ) + (275 * raidScaling) )
	return baseXP * playerScaling
end