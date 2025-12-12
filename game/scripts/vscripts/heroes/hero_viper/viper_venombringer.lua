viper_venombringer = class({})

function viper_venombringer:GetIntrinsicModifierName()
	return "modifier_viper_viper_venombringer"
end

modifier_viper_viper_venombringer = class({})
LinkLuaModifier("modifier_viper_viper_venombringer", "heroes/hero_viper/viper_venombringer", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_viper_venombringer:OnCreated()
	self.amp = self:GetSpecialValueFor("bonus_damage")
end

function modifier_viper_viper_venombringer:OnRefresh()
	self.amp = self:GetSpecialValueFor("bonus_damage")
end

function modifier_viper_viper_venombringer:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_viper_viper_venombringer:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.inflictor and self:GetParent():HasAbility( params.inflictor:GetAbilityName() ) then
		local debuffs = 0
		for _, modifier in ipairs( params.target:FindAllModifiers() ) do
			if modifier:GetCaster() == self:GetParent() 
			and modifier:GetAbility() 
			and modifier:GetAbility():GetCaster() == self:GetParent() 
			and self:GetParent():HasAbility( modifier:GetAbility():GetAbilityName() )
			and modifier:GetAbility() ~= params.inflictor then
				debuffs = debuffs + 1
			end
		end
		return self.amp * debuffs
	end
end

function modifier_viper_viper_venombringer:IsHidden()
	return true
end