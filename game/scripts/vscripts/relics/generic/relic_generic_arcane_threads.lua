relic_generic_arcane_threads = class({})

function relic_generic_arcane_threads:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function relic_generic_arcane_threads:GetModifierMagicalResistanceBonus()
	return 15
end

function relic_generic_arcane_threads:IsHidden()
	return true
end

function relic_generic_arcane_threads:IsPurgable()
	return false
end

function relic_generic_arcane_threads:RemoveOnDeath()
	return false
end

function relic_generic_arcane_threads:IsPermanent()
	return true
end

function relic_generic_arcane_threads:AllowIllusionDuplicate()
	return true
end