relic_generic_stick = class(relicBaseClass)

function relic_generic_stick:OnCreated()
	self:SetStackCount(1)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_generic_stick:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT and RoundManager:GetEventsFinished() % 2 == 0 then
		self:SetStackCount( math.ceil(self:GetStackCount() * 0.6) )
	end
end


function relic_generic_stick:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_stick:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end