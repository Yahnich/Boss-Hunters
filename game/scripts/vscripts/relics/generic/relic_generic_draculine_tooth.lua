relic_generic_draculine_tooth = class(relicBaseClass)

function relic_generic_draculine_tooth:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_generic_draculine_tooth:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		params.attacker:HealEvent(20, nil, params.attacker)
	end
end