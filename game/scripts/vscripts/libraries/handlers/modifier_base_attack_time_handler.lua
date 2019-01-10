modifier_base_attack_time_handler = class({})

function modifier_base_attack_time_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end

function modifier_base_attack_time_handler:GetModifierBaseAttackTimeConstant()
	return self:GetStackCount() / 100
end

function modifier_base_attack_time_handler:IsHidden()
	return true
end

function modifier_base_attack_time_handler:IsPurgable()
	return false
end

function modifier_base_attack_time_handler:RemoveOnDeath()
	return false
end

function modifier_base_attack_time_handler:IsPermanent()
	return true
end

function modifier_base_attack_time_handler:AllowIllusionDuplicate()
	return true
end

function modifier_base_attack_time_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end