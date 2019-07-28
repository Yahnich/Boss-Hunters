modifier_power_scaling = class({})

function modifier_power_scaling:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }

    return funcs
end

function modifier_power_scaling:GetModifierSpellAmplify_Percentage()
  return self:GetStackCount()
end

function modifier_power_scaling:IsHidden()
    return true
end

function modifier_power_scaling:IsPurgable()
	return false
end

function modifier_power_scaling:AllowIllusionDuplicate()
	return true
end