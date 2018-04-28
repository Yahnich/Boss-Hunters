relic_generic_draculine_tooth = class({})

function relic_generic_draculine_tooth:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_generic_draculine_tooth:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		params.attacker:HealEvent(20, nil, params.attacker)
	end
end

function relic_generic_draculine_tooth:IsHidden()
	return true
end

function relic_generic_draculine_tooth:IsPurgable()
	return false
end

function relic_generic_draculine_tooth:RemoveOnDeath()
	return false
end

function relic_generic_draculine_tooth:IsPermanent()
	return true
end

function relic_generic_draculine_tooth:AllowIllusionDuplicate()
	return true
end