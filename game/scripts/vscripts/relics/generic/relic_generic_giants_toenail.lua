relic_generic_giants_toenail = class({})

function relic_generic_giants_toenail:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE}
end

function relic_generic_giants_toenail:GetModifierStatusResistance()
	return 25
end

function relic_generic_giants_toenail:IsHidden()
	return true
end

function relic_generic_giants_toenail:IsPurgable()
	return false
end

function relic_generic_giants_toenail:RemoveOnDeath()
	return false
end

function relic_generic_giants_toenail:IsPermanent()
	return true
end

function relic_generic_giants_toenail:AllowIllusionDuplicate()
	return true
end

function relic_generic_giants_toenail:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end