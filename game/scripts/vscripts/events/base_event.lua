BaseEvent = class({})

function BaseEvent:constructor(zoneName, eventType, eventName)
	self.eventType = eventType
	self.zoneName = zoneName
	require("events/"..eventType.."/"..eventName)
	self:StartEvent()
end

function BaseEvent:StartEvent()
	return nil
end

function BaseEvent:GetZone()
	return self.zoneName
end

function BaseEvent:IsEvent()
	return self.eventType == "event"
end

function BaseEvent:IsCombat()
	return self.eventType == "combat"
end

function BaseEvent:IsBoss()
	return self.eventType == "boss"
end

function BaseEvent:IsElite()
	return self.eventType == "elite"
end

function BaseEvent:GetEventType()
	return self.eventType
end