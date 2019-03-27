modifier_strength_handler = class({})

function modifier_strength_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_strength_handler:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

function modifier_strength_handler:IsHidden()
	return true
end

function modifier_strength_handler:IsPurgable()
	return false
end

function modifier_strength_handler:RemoveOnDeath()
	return false
end

function modifier_strength_handler:IsPermanent()
	return true
end

function modifier_strength_handler:AllowIllusionDuplicate()
	return true
end

function modifier_strength_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end