relic_unique_kashas_wheelbarrow = class(relicBaseClass)

function relic_unique_kashas_wheelbarrow:DeclareFunctions()	
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function relic_unique_kashas_wheelbarrow:GetModifierAttackSpeedBonus_Constant()
	return 10 * self:GetStackCount()
end

function relic_unique_kashas_wheelbarrow:GetModifierMoveSpeedBonus_Percentage()
	return 5 * self:GetStackCount()
end