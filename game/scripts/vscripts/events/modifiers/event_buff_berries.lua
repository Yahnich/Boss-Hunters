event_buff_berries_curse = class({})

function event_buff_berries_curse:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(3)
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function event_buff_berries_curse:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		self:DecrementStackCount()
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

function event_buff_berries_curse:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
		if self:GetParent():IsAlive() then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "event_buff_berries_blessing", {})
		end
	end
end

function event_buff_berries_curse:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function event_buff_berries_curse:GetModifierExtraHealthBonus()
	return -800
end

function event_buff_berries_curse:IsDebuff()
	return true
end

event_buff_berries_curse_2 = class(relicBaseClass)

function event_buff_berries_curse_2:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function event_buff_berries_curse_2:GetModifierExtraHealthBonus()
	return -400
end

function event_buff_berries_curse_2:IsDebuff()
	return true
end

event_buff_berries_blessing = class(relicBaseClass)

function event_buff_berries_blessing:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function event_buff_berries_blessing:GetModifierExtraHealthBonus()
	return 400
end