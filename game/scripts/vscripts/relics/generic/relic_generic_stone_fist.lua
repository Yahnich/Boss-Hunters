relic_generic_stone_fist = class({})

function relic_generic_stone_fist:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_generic_stone_fist:Bonus_ThreatGain()
	return 20
end

function relic_generic_stone_fist:IsHidden()
	return true
end

function relic_generic_stone_fist:IsPurgable()
	return false
end

function relic_generic_stone_fist:RemoveOnDeath()
	return false
end

function relic_generic_stone_fist:IsPermanent()
	return true
end

function relic_generic_stone_fist:AllowIllusionDuplicate()
	return true
end

function relic_generic_stone_fist:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end