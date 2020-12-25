elite_heavy = class({})

function elite_heavy:GetIntrinsicModifierName()
	return "modifier_elite_heavy"
end

modifier_elite_heavy = class({})
LinkLuaModifier("modifier_elite_heavy", "elites/elite_heavy", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_heavy:OnCreated()
	self:OnRefresh()
end

function modifier_elite_heavy:OnRefresh()
	self.slow = self:GetSpecialValueFor("slow")
	self.size = self:GetSpecialValueFor("model_scale")
	self.dmg = self:GetSpecialValueFor("hp_damage") / 100
end

function modifier_elite_heavy:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_MODEL_SCALE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
			}
end

function modifier_elite_heavy:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_elite_heavy:GetModifierModelScale()
	return self.size
end

function modifier_elite_heavy:OnAttackLanded(params)
	if params.attacker == self:GetParent() and params.target.GetHealth then
		self:GetAbility():DealDamage( params.attacker, params.target, params.target:GetMaxHealth() * self.dmg, {damage_type = DAMAGE_TYPE_PHYSICAL} )
	end
end

function modifier_elite_heavy:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_elite_heavy:IsHidden()
	return true
end

function modifier_elite_heavy:GetEffectName()
	return "particles/units/elite_warning_offense_overhead.vpcf"
end
