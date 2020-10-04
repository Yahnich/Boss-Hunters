BaseEvent = class({})

EVENT_TYPE_COMBAT = 1
EVENT_TYPE_ELITE = 2
EVENT_TYPE_EVENT = 3
EVENT_TYPE_BOSS = 4

EVENT_REWARD_GOLD = 1
EVENT_REWARD_LIVES = 2
EVENT_REWARD_RELIC = 3

ROUND_END_DELAY = 3

ELITE_ABILITIES_TO_GIVE = 1

function SendErrorReport(err, context)
	Notifications:BottomToAll({text="An error has occurred! Please screenshot this: "..err, duration=15.0})
	print(err)
	if context then context.gameHasBeenBroken = true end
end

function BaseEvent:constructor(zoneName, eventType, eventName)
	self.eventType = tonumber(eventType)
	self.eventName = eventName
	self.zoneName = zoneName
	self.eventID = DoUniqueString(eventName)
	self.eventHasStarted = false
	self.eventChampionModifiers = {}
	self.eventEnemiesToSpawn = {}
	
	local eliteTypes = {}
	for eliteType, weight in pairs(GameRules._Elites) do
		if tonumber(weight) > 0 then
			for i = 1, tonumber(weight) do
				table.insert(eliteTypes, eliteType)
			end
		end
	end
	
	if self.eventType == EVENT_TYPE_COMBAT then
		for i = 1, ELITE_ABILITIES_TO_GIVE + math.max(0, RoundManager:GetAscensions() - 1) do
			local roll = RandomInt(1, #eliteTypes)
			local eliteAbName = eliteTypes[roll]
			for i = #eliteTypes, 1, -1 do
				if eliteTypes[i] == eliteAbName then
					table.remove(eliteTypes, i)
				end
			end
			table.insert( self.eventChampionModifiers, eliteAbName )
		end
	end
	
	local potentialEnemiesToSpawn = RoundManager.specificRoundKV[eventName]
	if potentialEnemiesToSpawn then
		local randomTable = {}
		for id, content in pairs( potentialEnemiesToSpawn ) do
			table.insert( randomTable, table.copy( content ) )
		end
		if #randomTable > 0 then
			local pick = RandomInt(1, #randomTable)
			self.eventEnemiesToSpawn = randomTable[pick]
		end
	end
	
	local eventFolder = "combat"
	if self.eventType == EVENT_TYPE_EVENT then
		eventFolder = "event"
	elseif self.eventType == EVENT_TYPE_BOSS or self.eventType == EVENT_TYPE_ELITE then
		eventFolder = "boss"
	end
	
	local funcs = require("events/"..eventFolder.."/"..eventName)
	self["HandoutRewards"] = BaseEvent.HandoutRewards
	for functionName, functionMethod in pairs( funcs ) do
		-- Precaching really doesn't like it when you change context
		if functionName ~= 'PrecacheUnits' then
			self[functionName] = function( self, optArg1, optArg2, optArg3  )
									status, err, ret = xpcall(functionMethod, debug.traceback, self, optArg1, optArg2, optArg3 ) -- optArg1 to 3 should just be nil and ignored if empty
									if not status  and not self.gameHasBeenBroken then
										SendErrorReport(err)
									end
								end
		else
			self[functionName] = functionMethod
		end
	end
end

function BaseEvent:StartEvent()
	print("Event not initialized")
	return nil
end

function BaseEvent:StartCombatRound()
	self.enemiesToSpawn = 0
	self.enemiesToSpawn = 0
	self.activeRoundSpawns = table.copy(self.eventEnemiesToSpawn)
	for enemy, data in pairs( self.activeRoundSpawns ) do
		data.SpawnDelay = data.SpawnDelay or 1
		data.currentTimer = data.SpawnDelay
		data.activeEnemies = 0
		data.totalSpawns = (data.Amount or 0) + ( data.RaidBonus or 0 ) * (RoundManager:GetCurrentRaidTier() - 1) + math.floor( HeroList:GetActiveHeroCount() * (data.HeroBonus or 0) )
		data.SpawnAmount = self.SpawnAmount or 1
		self.enemiesToSpawn = self.enemiesToSpawn + data.totalSpawns
	end
	
	self.eventHandler = Timers:CreateTimer(0.5, function()
		for enemy, data in pairs( self.activeRoundSpawns ) do
			data.currentTimer = data.currentTimer - 0.5
			if data.currentTimer <= 0 or data.activeEnemies == 0 and data.totalSpawns > 0 then
				data.currentTimer = data.SpawnDelay
				data.activeEnemies = data.activeEnemies + 1
				local toSpawn = math.min( data.SpawnAmount, data.totalSpawns )
				for i = 1, toSpawn do
					local spawn = CreateUnitByName(enemy, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
					if spawn then
						if data.CoreHealth then
							spawn:SetCoreHealth(data.CoreHealth)
						end
						if data.DelayAbilities then
							for ability, cd in pairs( data.DelayAbilities ) do
								local abilityFound = spawn:FindAbilityByName(ability)
								if abilityFound then
									abilityFound:SetCooldown( cd )
								end
							end
						end
						if data.BaseDamage then
							spawn:SetAverageBaseDamage( data.BaseDamage, 40 )
						end
						spawn.unitIsRoundNecessary = true
						if data.IsMinion and data.IsMinion == "1" then
							spawn.unitIsMinion = true
						end
						if data.IsBoss and data.IsBoss == "1" then
							spawn.unitIsBoss = true
						end
					end
				end
				data.totalSpawns = data.totalSpawns - toSpawn
				self.enemiesToSpawn = self.enemiesToSpawn - toSpawn
			end
		end
		return 0.5
	end)
	
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
	}
end

function BaseEvent:PrecacheUnits()
	print("Precache not initialized")
end

function BaseEvent:EndEvent()
	print("EndEvent not initialized")
end

function BaseEvent:GetZone()
	return self.zoneName
end

function BaseEvent:LoadSpawns()
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		local zoneName = self:GetZone()
		local eventType = "combat"
		local choices = 4
		if self:GetEventType() == EVENT_TYPE_BOSS then
			eventType = "boss"
			choices = 2
		end
		local roll = RandomInt(1,choices)
		RoundManager.boundingBox = string.lower(zoneName).."_"..eventType.."_"..roll
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

function BaseEvent:GetHeroSpawnPosition()
	return RoundManager.heroSpawnPosition
end

function BaseEvent:GetStandardGoldReward()
	return RoundManager:GetStandardGoldReward()
end

function BaseEvent:GetStandardXPReward()
	return RoundManager:GetStandardXPReward()
end

function BaseEvent:HandoutRewards(bWon)
	if not self:IsEvent() then
		local baseXP = self:GetStandardXPReward()
		local baseGold = self:GetStandardGoldReward()
		if not bWon then
			baseXP = baseXP / 4
			baseGold = baseGold / 4
		end
		if self:IsBoss() then
			baseXP = baseXP * 1.5
			baseGold = baseGold * 1.5
		end
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddGold( baseGold )
			hero:AddXP( baseXP )
			local pID = hero:GetPlayerOwnerID()
			if bWon then
				if self:IsElite() and RoundManager:GetAscensions() < 1 then
					RelicManager:RollEliteRelicsForPlayer(pID)
				elseif self:IsBoss() and RoundManager:GetAscensions() < 2 then
					RelicManager:RollBossRelicsForPlayer(pID)
				end
			end
		end
	end
end

function BaseEvent:IsEvent()
	return self.eventType == EVENT_TYPE_EVENT
end

function BaseEvent:IsCombat()
	return self.eventType == EVENT_TYPE_COMBAT
end

function BaseEvent:IsBoss()
	return self.eventType == EVENT_TYPE_BOSS
end

function BaseEvent:IsElite()
	return self.eventType == EVENT_TYPE_ELITE
end

function BaseEvent:GetEventName()
	return self.eventName
end

function BaseEvent:GetEventID()
	return self.eventID
end

function BaseEvent:GetEventType()
	return self.eventType
end

function BaseEvent:GetEventRewardType()
	if self:GetEventType() == EVENT_TYPE_BOSS or self:GetEventType() == EVENT_TYPE_ELITE then
		return EVENT_REWARD_RELIC
	else	
		return EVENT_REWARD_GOLD
	end
end

function BaseEvent:ChampionSpawnModifiers()
	return self.eventChampionModifiers
end

function BaseEvent:GetEnemiesToSpawn()
	return self.eventEnemiesToSpawn
end

function BaseEvent:HasStarted()
	return self.eventHasStarted or false
end