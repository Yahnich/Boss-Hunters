elite_tiny = class({})

function elite_tiny:GetIntrinsicModifierName()
	return "modifier_elite_tiny"
end

modifier_elite_tiny = class({})
LinkLuaModifier("modifier_elite_tiny", "elites/elite_tiny", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_tiny:OnCreated()
	self:OnRefresh()
end

function modifier_elite_tiny:OnRefresh()
	self.size = self:GetSpecialValueFor("model_scale")
	self.cdr = self:GetSpecialValueFor("cooldown_reduction")
	self.dmg = self:GetSpecialValueFor("damage_reduction")
	self.as = self:GetSpecialValueFor("bonus_attack_speed")
end

function modifier_elite_tiny:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_MODEL_SCALE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
			}
end

function modifier_elite_tiny:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_elite_tiny:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_elite_tiny:GetModifierTotalDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_elite_tiny:GetModifierModelScale()
	return self.size
end

function modifier_elite_tiny:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_elite_tiny:IsHidden()
	return true
end

function modifier_elite_tiny:GetEffectName()
	return "particles/units/elite_warning_offense_overhead.vpcf"
end

function modifier_elite_tiny:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end