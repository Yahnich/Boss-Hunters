modifier_neutral_power_passive = class({})
 
function modifier_neutral_power_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
	}
	return funcs
end

function modifier_neutral_power_passive:OnCreated()
	self.hp_scaling = self.level * ability:GetSpecialValueFor("health_per_level")
end
 
function modifier_neutral_power_passive:IsHidden()
    return true
end

function modifier_neutral_power_passive:GetModifierExtraHealthBonus(params)
	return self.hp_scaling
end
