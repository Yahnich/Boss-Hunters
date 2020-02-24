elite_armoured = class({})

function elite_armoured:GetIntrinsicModifierName()
	return "modifier_elite_armoured"
end

modifier_elite_armoured = class({})
LinkLuaModifier("modifier_elite_armoured", "elites/elite_armoured", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_armoured:OnCreated()
	self:OnRefresh()
end

function modifier_elite_armoured:OnRefresh()
	self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_elite_armoured:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS 
			}
end

function modifier_elite_armoured:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_elite_armoured:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_elite_armoured:IsHidden()
	return true
end

function modifier_elite_armoured:GetEffectName()
	return "particles/units/elite_warning_defense_overhead.vpcf"
end

function modifier_elite_armoured:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end