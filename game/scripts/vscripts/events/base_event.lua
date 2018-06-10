BaseEvent = class({})

EVENT_TYPE_COMBAT = 1
EVENT_TYPE_ELITE = 2
EVENT_TYPE_EVENT = 3
EVENT_TYPE_BOSS = 4

function BaseEvent:constructor(zoneName, eventType, eventName)
	self.eventType = eventType
	self.eventName = eventName
	self.zoneName = zoneName
	eventFolder = "combat"
	if eventType == EVENT_TYPE_EVENT then
		eventFolder = "event"
	elseif eventType == EVENT_TYPE_BOSS then
		eventFolder = "boss"
	end
	local funcs = require("events/"..eventFolder.."/"..eventName)
	for functionName, functionMethod in pairs( funcs ) do
		self[functionName] = functionMethod
	end
end

function BaseEvent:StartEvent()
	print("Event not initialized")
	return nil
end

function BaseEvent:PrecacheUnits()
	print("Precache not initialized")
end

function BaseEvent:EndEvent()
	RoundManager:EndEvent()
end

function BaseEvent:GetZone()
	return self.zoneName
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