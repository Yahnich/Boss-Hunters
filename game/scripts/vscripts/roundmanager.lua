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

EVENTS_PER_RAID = 5
RAIDS_PER_ZONE = 3
ZONE_COUNT = 2

POSSIBLE_ZONES = {"Sepulcher", "Grove"}

COMBAT_CHANCE = 65
ELITE_CHANCE = 20
EVENT_CHANCE = 100 - COMBAT_CHANCE

PREP_TIME = 3

function RoundManager:Initialize()
	RoundManager = self
	self.bossPool = LoadKeyValues('scripts/kv/boss_pool.txt')
	self.eventPool = LoadKeyValues('scripts/kv/event_pool.txt')
	self.combatPool = LoadKeyValues('scripts/kv/combat_pool.txt')
	
	self.zones = {}
	self.eventsFinished = 0
	local zonesToSpawn = ZONE_COUNT
	for i = 1, ZONE_COUNT do
		local zoneID = RandomInt(1, #POSSIBLE_ZONES)
		local zoneName = POSSIBLE_ZONES[zoneID]
		table.remove(POSSIBLE_ZONES, zoneID)
		RoundManager:ConstructRaids(zoneName)
		if zonesToSpawn <= 0 then
			break
		end
	end
	
	self.spawnPositions = {}
	for _,spawnPos in ipairs(Entities:FindAllByName("boss_spawner")) do
		table.insert( self.spawnPositions, spawnPos:GetAbsOrigin() )
	end
	
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( RoundManager, "OnNPCSpawned" ), self )
	ListenToGameEvent( "dota_holdout_revive_complete", Dynamic_Wrap( RoundManager, 'OnHoldoutReviveComplete' ), self )
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
			if spawnedUnit:IsCreature() then
				AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnedUnit:GetAbsOrigin(), 516, 3, false) -- show spawns
				if spawnedUnit:IsRoundBoss() then
					ParticleManager:FireParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_end_nexon_hero_cp_2014.vpcf", PATTACH_POINT_FOLLOW, spawnedUnit)
					EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", spawnedUnit)
				end
				if not spawnedUnit.hasBeenInitialized then
					spawnedUnit.hasBeenInitialized = true
					local expectedHP = spawnedUnit:GetBaseMaxHealth() * RandomFloat(0.9, 1.15)
					local playerHPMultiplier = 0.35
					local playerDMGMultiplier = 0.05
					if GameRules:GetGameDifficulty() == 4 then 
						expectedHP = expectedHP * 1.35
						playerHPMultiplier = 0.5 
						playerDMGMultiplier = 0.07
					end
					local effective_multiplier = (HeroList:GetActiveHeroCount() - 1) * ( 1 + (self.eventsFinished * 0.1) )
					local effPlayerHPMult = 1 + effective_multiplier * playerHPMultiplier
					local effPlayerDMGMult = 0.9 + effective_multiplier * playerDMGMultiplier

					expectedHP = expectedHP * effPlayerHPMult
					spawnedUnit:SetBaseMaxHealth(expectedHP)
					spawnedUnit:SetMaxHealth(expectedHP)
					spawnedUnit:SetHealth(expectedHP)
					
					spawnedUnit:SetAverageBaseDamage(spawnedUnit:GetAverageBaseDamage() * effPlayerDMGMult * RandomFloat(0.85, 1.15), 30)
					spawnedUnit:SetBaseHealthRegen(self.eventsFinished * RandomFloat(0.85, 1.15) )
					
					spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_boss_attackspeed", {})
					spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_power_scaling", {}):SetStackCount(self.eventsFinished)
					spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_spawn_immunity", {duration = 4/GameRules.gameDifficulty})
					
					if spawnedUnit:GetHullRadius() >= 16 then
						spawnedUnit:SetHullRadius( math.ceil(16 * spawnedUnit:GetModelScale()) )
					end
					
					spawnedUnit:SetMaximumGoldBounty(0)
					spawnedUnit:SetMinimumGoldBounty(0)
					spawnedUnit:SetDeathXP(0)
					GridNav:DestroyTreesAroundPoint(spawnedUnit:GetAbsOrigin(), spawnedUnit:GetHullRadius() + spawnedUnit:GetCollisionPadding() + 350, true)
					FindClearSpaceForUnit(spawnedUnit, spawnedUnit:GetAbsOrigin(), true)
				end
			elseif spawnedUnit:IsRealHero() then
				spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_tombstone_respawn_immunity", {duration = 3})
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


function RoundManager:ConstructRaids(zoneName)
	self.zones[zoneName] = {}
	
	local bossPool = {}
	local eventPool = {}
	local combatPool = {}
	
	for event, weight in pairs( MergeTables(self.bossPool[zoneName], self.bossPool["Generic"]) ) do
		for i = 1, weight do
			table.insert(bossPool, event)
		end
	end
	
	for event, weight in pairs( MergeTables(self.eventPool[zoneName], self.eventPool["Generic"]) ) do
		for i = 1, weight do
			table.insert(eventPool, event)
		end
	end
	
	for event, weight in pairs( MergeTables(self.combatPool[zoneName], self.combatPool["Generic"]) ) do
		for i = 1, weight do
			table.insert(combatPool, event)
		end
	end
	for j = 1, RAIDS_PER_ZONE do
		local raid = {}
		local raidContent
		for i = 1, EVENTS_PER_RAID do
			if RollPercentage(100) then -- Rolled Combat
				local combatType = EVENT_TYPE_COMBAT
				if RollPercentage(ELITE_CHANCE) then
					combatType = EVENT_TYPE_ELITE
				end
				raidContent = BaseEvent(zoneName, combatType, combatPool[RandomInt(1, #combatPool)] )
			else -- Event
				raidContent = BaseEvent(zoneName, EVENT_TYPE_EVENT, eventPool[RandomInt(1, #eventPool)] ) 
			end
			table.insert( raid, raidContent )
		end
		local bossPick = bossPool[RandomInt(1, #bossPool)]
		RoundManager:RemoveEventFromPool(bossPick, "boss")	
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
	local selection = {}
	for zoneName, _ in pairs( self.zones ) do
		table.insert(selection, zoneName)
	end
	self.currentZone = selection[RandomInt(1, #selection)]
	
	RoundManager:StartPrepTime()
end

function RoundManager:StartPrepTime()
	if self.zones[self.currentZone] and self.zones[self.currentZone][1] and not self.prepTimeTimer then
		local event = self.zones[self.currentZone][1][1]
		if event and not event.precacheComplete then
			event.precacheComplete = event:PrecacheUnits()
		end
	
		print( RoundManager:GetCurrentEventName(), "prep time" )
		local timer = PREP_TIME
		self.prepTimeTimer = Timers:CreateTimer(1, function()
			timer = timer - 1
			CustomGameEventManager:Send_ServerToAllClients( "updateQuestPrepTime", { prepTime = math.floor(timer + 0.5) } )
			if timer <= 0 then
				local textFormatting = RAIDS_PER_ZONE - #self.zones[self.currentZone] + 1
				print(textFormatting, #self.zones[self.currentZone] )
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
				CustomGameEventManager:Send_ServerToAllClients( "updateQuestRound", { roundNumber = EVENTS_PER_RAID - #self.zones[self.currentZone][1] + 2, roundText = self.currentZone.." "..romanVersion } )
				RoundManager:EndPrepTime()
			else
				return 1
			end
		end)
	end
end

function RoundManager:EndPrepTime(bReset)
	print("Starting event", self.prepTimeTimer)
	if self.prepTimeTimer then Timers:RemoveTimer( self.prepTimeTimer ) end
	self.prepTimeTimer = nil
	if not bReset then
		RoundManager:StartEvent()
	end
end

function RoundManager:StartEvent()
	GameRules:RefreshPlayers()
	EmitGlobalSound("Round.Start")
	print( "event started: "..RoundManager:GetCurrentEventName() )
	if self.zones[self.currentZone] and self.zones[self.currentZone][1] and self.zones[self.currentZone][1][1] then
		self.zones[self.currentZone][1][1]:StartEvent()
		return true
	else
		RoundManager:GameIsFinished()
		return false
	end
end

function RoundManager:GetCurrentEventName()
	return self.zones[self.currentZone][1][1]:GetEventName()
end

function RoundManager:EndEvent(bWonRound)
	print( "event ended: "..RoundManager:GetCurrentEventName() )
	GameRules:RefreshPlayers()
	if bWonRound then
		local event = self.zones[self.currentZone][1][1]
		event:HandoutRewards()
		UTIL_Remove( event )
		table.remove( self.zones[self.currentZone][1], 1 )
		EventManager:FireEvent("boss_hunters_event_finished")
		self.eventsFinished = self.eventsFinished + 1
		if self.zones[self.currentZone][1][1] == nil then RoundManager:RaidIsFinished() end
		EmitGlobalSound("Round.Won")
	else
		EmitGlobalSound("Round.Lost")
	end
	for _, unit in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_ENEMY}) ) do
		if unit:IsCreature() then
			unit:ForceKill(false)
		end
	end
	self:StartPrepTime()
end

function RoundManager:RaidIsFinished()
	table.remove( self.zones[self.currentZone], 1 )
	EventManager:FireEvent("boss_hunters_raid_finished")
	self.raidsFinished = (self.raidsFinished or 0) + 1
	print("raid is finished")
	if self.zones[self.currentZone][1] == nil then RoundManager:ZoneIsFinished() end
end

function RoundManager:ZoneIsFinished()
	self.zones[self.currentZone] = nil
	self.currentZone = nil
	
	local selection = {}
	for zoneName, _ in pairs( self.zones ) do
		print(zoneName)
		table.insert(selection, zoneName)
	end
	self.currentZone = selection[RandomInt(1, #selection)]
	EventManager:FireEvent("boss_hunters_game_finished")
	self.zonesFinished = (self.zonesFinished or 0) + 1
	print("zone is finished")
	if self.currentZone == nil then
		RoundManager:GameIsFinished()
	end
end

function RoundManager:GameIsFinished()
	EventManager:FireEvent("boss_hunters_event_finished")
	print("game has ended")
end

function RoundManager:GetEvent()
	return self.currentRound
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
	return self.eventsFinished or 0
end

function RoundManager:GetRaidsFinished()
	return self.raidsFinished or 0
end

function RoundManager:GetZonesFinished()
	return self.zonesFinished or 0
end