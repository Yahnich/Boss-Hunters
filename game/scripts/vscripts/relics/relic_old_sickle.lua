relic_old_sickle = class(relicBaseClass)

function relic_old_sickle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_old_sickle:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		DoCleaveAttack( params.attacker, params.target, nil, 0.25 * params.damage, 150, 350, 500, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
	end
end