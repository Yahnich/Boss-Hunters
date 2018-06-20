BaseEvent = class({})

EVENT_TYPE_COMBAT = 1
EVENT_TYPE_ELITE = 2
EVENT_TYPE_EVENT = 3
EVENT_TYPE_BOSS = 4

ROUND_END_DELAY = 3

function BaseEvent:constructor(zoneName, eventType, eventName)
	self.eventType = tonumber(eventType)
	self.eventName = eventName
	self.zoneName = zoneName
	self.eventID = DoUniqueString(eventName)
	eventFolder = "combat"
	if self.eventType == EVENT_TYPE_EVENT then
		eventFolder = "event"
	elseif self.eventType == EVENT_TYPE_BOSS then
		eventFolder = "boss"
	end
	
	local funcs = require("events/"..eventFolder.."/"..eventName)
	for functionName, functionMethod in pairs( funcs ) do
		self[functionName] = functionMethod
	end
	print( self, self.eventID )
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

function BaseEvent:HandoutRewards()
	if not self:IsEvent() then
		local eventScaling = RoundManager:GetEventsFinished()
		local playerScaling = GameRules.BasePlayers - HeroList:GetActiveHeroCount()
		local baseXP = 500 + eventScaling * (100 + 10 * playerScaling)
		local baseGold = 100 + eventScaling * (25 + 3 * playerScaling)
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddGold( baseGold )
			hero:AddExperience( baseXP, DOTA_ModifyXP_Unspecified, false, false )
			local pID = hero:GetPlayerOwnerID()
			if self:IsElite() then
				RelicManager:RollEliteRelicsForPlayer(pID)
			elseif self:IsBoss() then
				RelicManager:RollBossRelicsForPlayer(pID)
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

function BaseEvent:GetEventType()
	return self.eventType
end