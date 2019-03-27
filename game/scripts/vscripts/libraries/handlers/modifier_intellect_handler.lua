modifier_intellect_handler = class({})
	
function modifier_intellect_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_intellect_handler:GetModifierBonusStats_Intellect()
	return self:GetStackCount()
end

function modifier_intellect_handler:IsHidden()
	return true
end

function modifier_intellect_handler:IsPurgable()
	return false
end

function modifier_intellect_handler:RemoveOnDeath()
	return false
end

function modifier_intellect_handler:IsPermanent()
	return true
end

function modifier_intellect_handler:AllowIllusionDuplicate()
	return true
end

function modifier_intellect_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end