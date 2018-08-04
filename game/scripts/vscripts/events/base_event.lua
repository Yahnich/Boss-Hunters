BaseEvent = class({})

EVENT_TYPE_COMBAT = 1
EVENT_TYPE_ELITE = 2
EVENT_TYPE_EVENT = 3
EVENT_TYPE_BOSS = 4

ROUND_END_DELAY = 3

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
	local eventFolder = "combat"
	if self.eventType == EVENT_TYPE_EVENT then
		eventFolder = "event"
	elseif self.eventType == EVENT_TYPE_BOSS then
		eventFolder = "boss"
	end
	
	local funcs = require("events/"..eventFolder.."/"..eventName)
	self["HandoutRewards"] = BaseEvent.HandoutRewards
	for functionName, functionMethod in pairs( funcs ) do
		-- Precaching really doesn't like it when you change context
		if functionName ~= 'PrecacheUnits' then
			self[functionName] = function( self, optArg1, optArg2, optArg3  )
									status, err, ret = xpcall(functionMethod, debug.traceback, self, optArg1, optArg2, optArg3 ) -- optArg1 to 3 should just be nil and ignored if empty
									print(status, self, optArg1, optArg2, optArg3, "status" )
									print(err)
									print(ret)
									if not status  and not self.gameHasBeenBroken then
										SendErrorReport(err)
									end
								end
		else
			self[functionName] = functionMethod
		end
	end
	print(zoneName, eventName, RoundManager.eventsCreated ,"created")
end

function BaseEvent:StartEvent()
	print("Event not initialized")
	return nil
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
	return self.heroSpawnPosition
end

function BaseEvent:HandoutRewards(bWon)
	if not self:IsEvent() then
		local eventScaling = RoundManager:GetEventsFinished()
		local raidScaling = 1 + RoundManager:GetRaidsFinished() * 0.2
		local playerScaling = GameRules.BasePlayers - HeroList:GetActiveHeroCount()
		local baseXP = ( 800 + ( (35 + 10 * playerScaling) * eventScaling ) ) + (300 * raidScaling)
		local baseGold = ( 200 + ( (20 + 5 * playerScaling) * eventScaling ) ) + (80 * raidScaling)
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
				elseif self:IsBoss() then
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

function BaseEvent:HasStarted()
	return self.eventHasStarted or false
end