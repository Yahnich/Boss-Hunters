relic_generic_silver_arrow = class({})

function relic_generic_silver_arrow:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_silver_arrow:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() return 150 end
end

function relic_generic_silver_arrow:GetModifierPreAttack_BonusDamage()
	return 35
end

function relic_generic_silver_arrow:IsHidden()
	return true
end

function relic_generic_silver_arrow:IsPurgable()
	return false
end

function relic_generic_silver_arrow:RemoveOnDeath()
	return false
end

function relic_generic_silver_arrow:IsPermanent()
	return true
end

function relic_generic_silver_arrow:AllowIllusionDuplicate()
	return true
end