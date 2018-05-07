relic_unique_kashas_wheelbarrow = class({})

function relic_unique_kashas_wheelbarrow:DeclareFunctions()	
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function relic_unique_kashas_wheelbarrow:GetModifierAttackSpeedBonus_Constant()
	return 10 * self:GetStackCount()
end

function relic_unique_kashas_wheelbarrow:GetModifierMoveSpeedBonus_Percentage()
	return 5 * self:GetStackCount()
end

function relic_unique_kashas_wheelbarrow:IsHidden()
	return true
end

function relic_unique_kashas_wheelbarrow:IsPurgable()
	return false
end

function relic_unique_kashas_wheelbarrow:RemoveOnDeath()
	return false
end

function relic_unique_kashas_wheelbarrow:IsPermanent()
	return true
end

function relic_unique_kashas_wheelbarrow:AllowIllusionDuplicate()
	return true
end

function relic_unique_kashas_wheelbarrow:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end