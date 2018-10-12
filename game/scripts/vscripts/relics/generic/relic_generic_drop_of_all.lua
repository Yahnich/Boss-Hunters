relic_generic_drop_of_all = class(relicBaseClass)

function relic_generic_drop_of_all:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			}
end

function relic_generic_drop_of_all:GetModifierBonusStats_Strength()
	return 5
end

function relic_generic_drop_of_all:GetModifierBonusStats_Agility()
	return 5
end

function relic_generic_drop_of_all:GetModifierBonusStats_Intellect()
	return 5
end

function relic_generic_drop_of_all:GetModifierMoveSpeedBonus_Constant()
	return 10
end

function relic_generic_drop_of_all:GetModifierAttackSpeedBonus_Constant()
	return 10
end

function relic_generic_drop_of_all:GetModifierBaseAttack_BonusDamage()
	return 10
end

function relic_generic_drop_of_all:GetModifierHealthBonus()
	return 100
end

function relic_generic_drop_of_all:GetModifierManaBonus()
	return 100
end

function relic_generic_drop_of_all:GetModifierConstantManaRegen()
	return 1
end

function relic_generic_drop_of_all:GetModifierConstantHealthRegen()
	return 1
end