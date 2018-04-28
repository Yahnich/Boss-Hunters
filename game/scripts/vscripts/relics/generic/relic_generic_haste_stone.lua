relic_generic_haste_stone = class({})

function relic_generic_haste_stone:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function relic_generic_haste_stone:GetModifierAttackSpeedBonus_Constant()
	return 80
end

function relic_generic_haste_stone:IsHidden()
	return true
end

function relic_generic_haste_stone:IsPurgable()
	return false
end

function relic_generic_haste_stone:RemoveOnDeath()
	return false
end

function relic_generic_haste_stone:IsPermanent()
	return true
end

function relic_generic_haste_stone:AllowIllusionDuplicate()
	return true
end