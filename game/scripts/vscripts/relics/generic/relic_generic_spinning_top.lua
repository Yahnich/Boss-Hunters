relic_generic_spinning_top = class({})

function relic_generic_spinning_top:GetBaseAttackTime_Bonus()
	return -0.1
end

function relic_generic_spinning_top:IsHidden()
	return true
end

function relic_generic_spinning_top:IsPurgable()
	return false
end

function relic_generic_spinning_top:RemoveOnDeath()
	return false
end

function relic_generic_spinning_top:IsPermanent()
	return true
end

function relic_generic_spinning_top:AllowIllusionDuplicate()
	return true
end

function relic_generic_spinning_top:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end