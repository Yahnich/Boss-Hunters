modifier_cooldown_reduction_handler = class({})

function modifier_cooldown_reduction_handler:OnStackCountChanged()
	local cdr = self:GetStackCount()
	self.cdr = (cdr) / 100
end
	
function modifier_cooldown_reduction_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING}
end

function modifier_cooldown_reduction_handler:GetModifierPercentageCooldownStacking()
	return self.cdr or 0
end

function modifier_cooldown_reduction_handler:IsHidden()
	return true
end

function modifier_cooldown_reduction_handler:IsPurgable()
	return false
end

function modifier_cooldown_reduction_handler:RemoveOnDeath()
	return false
end

function modifier_cooldown_reduction_handler:IsPermanent()
	return true
end

function modifier_cooldown_reduction_handler:AllowIllusionDuplicate()
	return true
end

function modifier_cooldown_reduction_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end