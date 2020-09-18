relic_beast_fang = class(relicBaseClass)

function relic_beast_fang:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function relic_beast_fang:GetModifierAttackSpeedBonus_Constant()
	return 25
end

function relic_beast_fang:GetModifierPreAttack_BonusDamage()
	return 40
end