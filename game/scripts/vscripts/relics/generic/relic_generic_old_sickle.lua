relic_generic_old_sickle = class({})

function relic_generic_old_sickle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_generic_old_sickle:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		DoCleaveAttack( params.attacker, params.target, nil, 0.25 * params.attacker:GetAttackDamage(), 150, 350, 500, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
	end
end

function relic_generic_old_sickle:IsHidden()
	return true
end

function relic_generic_old_sickle:IsPurgable()
	return false
end

function relic_generic_old_sickle:RemoveOnDeath()
	return false
end

function relic_generic_old_sickle:IsPermanent()
	return true
end

function relic_generic_old_sickle:AllowIllusionDuplicate()
	return true
end

function relic_generic_old_sickle:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end