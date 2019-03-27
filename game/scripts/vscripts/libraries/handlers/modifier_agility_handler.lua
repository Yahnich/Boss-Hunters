modifier_agility_handler = class({})

function modifier_agility_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_agility_handler:GetModifierBonusStats_Agility()
	return self:GetStackCount()
end

function modifier_agility_handler:IsHidden()
	return true
end

function modifier_agility_handler:IsPurgable()
	return false
end

function modifier_agility_handler:RemoveOnDeath()
	return false
end

function modifier_agility_handler:IsPermanent()
	return true
end

function modifier_agility_handler:AllowIllusionDuplicate()
	return true
end

function modifier_agility_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end