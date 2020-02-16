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
			}
end

function modifier_elite_tiny:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_elite_tiny:GetCooldownReduction()
	return self.cdr
end

function modifier_elite_tiny:GetModifierTotalDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_elite_tiny:GetModifierModelScale()
	return self.size
end

function relicBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function relicBaseClass:IsHidden()
	return true
end