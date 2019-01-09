modifier_evasion_handler = class({})

function modifier_evasion_handler:OnCreated()
	self.evasion = -self:GetStackCount()
end

function modifier_evasion_handler:OnStackCountChanged()
	self.evasion = -self:GetStackCount()
end

function modifier_evasion_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_evasion_handler:GetModifierEvasion_Constant(params)
	return self.evasion
end

function modifier_evasion_handler:IsHidden()
	return true
end

function modifier_evasion_handler:IsPurgable()
	return false
end

function modifier_evasion_handler:RemoveOnDeath()
	return false
end

function modifier_evasion_handler:IsPermanent()
	return true
end

function modifier_evasion_handler:AllowIllusionDuplicate()
	return true
end

function modifier_evasion_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end