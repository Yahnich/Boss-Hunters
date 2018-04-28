relic_generic_beast_fang = class({})

function relic_generic_beast_fang:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_beast_fang:GetModifierAttackSpeedBonus_Constant()
	return 40
end

function relic_generic_beast_fang:GetModifierPreAttack_BonusDamage()
	return 40
end

function relic_generic_beast_fang:IsHidden()
	return true
end

function relic_generic_beast_fang:IsPurgable()
	return false
end

function relic_generic_beast_fang:RemoveOnDeath()
	return false
end

function relic_generic_beast_fang:IsPermanent()
	return true
end

function relic_generic_beast_fang:AllowIllusionDuplicate()
	return true
end