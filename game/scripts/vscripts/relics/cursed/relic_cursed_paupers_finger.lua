relic_cursed_paupers_finger = class({})

function relic_cursed_paupers_finger:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXP_RATE_BOOST, }
end

function relic_cursed_paupers_finger:GetModifierPercentageExpRateBoost()
	return 50
end

function relic_cursed_paupers_finger:GetBonusGold()
	return -50
end

function relic_cursed_paupers_finger:IsHidden()
	return true
end

function relic_cursed_paupers_finger:IsPurgable()
	return false
end

function relic_cursed_paupers_finger:RemoveOnDeath()
	return false
end

function relic_cursed_paupers_finger:IsPermanent()
	return true
end

function relic_cursed_paupers_finger:AllowIllusionDuplicate()
	return true
end

function relic_cursed_paupers_finger:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end