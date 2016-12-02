modifier_neutral_power_passive = class({})
 
function modifier_neutral_power_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
	}
	return funcs
end

if IsServer() then
	function modifier_neutral_power_passive:OnCreated()
		self.hp_scaling = self:GetParent():GetMaxHealth()*self:GetParent():GetOwnerEntity():GetLevel()^0.8 - self:GetParent():GetMaxHealth()
	end

	function modifier_neutral_power_passive:GetModifierExtraHealthBonus(params)
		return self.hp_scaling
	end
end

function modifier_neutral_power_passive:IsHidden()
    return true
end

