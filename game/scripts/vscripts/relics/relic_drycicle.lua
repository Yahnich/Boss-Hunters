relic_drycicle = class(relicBaseClass)

function relic_drycicle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_drycicle:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		params.target:AddChill(self:GetAbility(), params.attacker, 10, 10)
	end
end