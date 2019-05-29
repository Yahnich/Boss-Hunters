relic_silver_arrow = class(relicBaseClass)

function relic_silver_arrow:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function relic_silver_arrow:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return 100
	else
		return 50 
	end
end

function relic_silver_arrow:GetModifierPreAttack_BonusDamage()
	return 35
end