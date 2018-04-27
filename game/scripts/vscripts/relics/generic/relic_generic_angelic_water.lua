relic_generic_angelic_water = class({})

function relic_generic_angelic_water:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function relic_generic_angelic_water:GetModifierConstantManaRegen()
	return 10
end

function relic_generic_angelic_water:IsHidden()
	return true
end

function relic_generic_angelic_water:IsPurgable()
	return false
end

function relic_generic_angelic_water:RemoveOnDeath()
	return false
end

function relic_generic_angelic_water:IsPermanent()
	return true
end

function relic_generic_angelic_water:AllowIllusionDuplicate()
	return true
end