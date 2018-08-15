relic_unique_kashas_wheelbarrow = class(relicBaseClass)

function relic_unique_kashas_wheelbarrow:OnCreated()
	if IsServer() then
		self:SetStackCount(0)
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_unique_kashas_wheelbarrow:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		self:IncrementStackCount()
	end
end

function relic_unique_kashas_wheelbarrow:OnRemoved()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end


function relic_unique_kashas_wheelbarrow:DeclareFunctions()	
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function relic_unique_kashas_wheelbarrow:GetModifierAttackSpeedBonus_Constant()
	return 10 * self:GetStackCount()
end

function relic_unique_kashas_wheelbarrow:GetModifierMoveSpeedBonus_Percentage()
	return 5 * self:GetStackCount()
end

function relic_unique_kashas_wheelbarrow:IsHidden()
	return false
end