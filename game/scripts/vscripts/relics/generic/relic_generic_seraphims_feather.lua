relic_generic_seraphims_feather = class({})

function relic_generic_seraphims_feather:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function relic_generic_seraphims_feather:GetModifierMoveSpeedBonus_Constant()
	return 60
end

function relic_generic_seraphims_feather:IsHidden()
	return true
end

function relic_generic_seraphims_feather:IsPurgable()
	return false
end

function relic_generic_seraphims_feather:RemoveOnDeath()
	return false
end

function relic_generic_seraphims_feather:IsPermanent()
	return true
end

function relic_generic_seraphims_feather:AllowIllusionDuplicate()
	return true
end

function relic_generic_seraphims_feather:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end