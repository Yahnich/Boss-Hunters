relic_stick5 = class(relicBaseClass)

function relic_stick5:OnCreated()
	self:SetStackCount(600)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_stick5:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		self:SetStackCount( math.min( 1000, math.ceil(self:GetStackCount() * 1.01) ) )
	end
end

function relic_stick5:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function relic_stick5:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_stick5:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end