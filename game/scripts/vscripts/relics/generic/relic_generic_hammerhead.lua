relic_generic_hammerhead = class({})

function relic_generic_hammerhead:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_hammerhead:GetModifierPreAttack_BonusDamage()
	return 80
end

function relic_generic_hammerhead:IsHidden()
	return true
end

function relic_generic_hammerhead:IsPurgable()
	return false
end

function relic_generic_hammerhead:RemoveOnDeath()
	return false
end

function relic_generic_hammerhead:IsPermanent()
	return true
end

function relic_generic_hammerhead:AllowIllusionDuplicate()
	return true
end