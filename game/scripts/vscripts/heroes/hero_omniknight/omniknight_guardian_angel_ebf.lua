omniknight_guardian_angel_ebf = class({})

function omniknight_guardian_angel_ebf:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius") ) ) do
		ally:AddNewModifier(caster, self, "modifier_omniknight_guardian_angel_ebf", {duraton = duration})
	end
end

modifier_omniknight_guardian_angel_ebf = class({})
LinkLuaModifier("modifier_omniknight_guardian_angel_ebf", "heroes/hero_omniknight/omniknight_guardian_angel_ebf", LUA_MODIFIER_MOTION_NONE )

function modifier_omniknight_guardian_angel_ebf:OnCreated()
	self.health_regen = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_guardian_angel_1")
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_guardian_angel_2")
end

function modifier_omniknight_guardian_angel_ebf:OnRefresh()
	self.health_regen = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_guardian_angel_1")
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_guardian_angel_2")
end

function modifier_omniknight_guardian_angel_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_omniknight_guardian_angel_ebf:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_omniknight_guardian_angel_ebf:GetModifierHealthRegenPercentage()
	return self.health_regen
end

function modifier_omniknight_guardian_angel_ebf:GetModifierDamageOutgoing_Percentage()
	return self.damage
end

function modifier_omniknight_guardian_angel_ebf:GetEffectName()
	if self:GetParent() == self:GetCaster() then
		return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf"
	else
		return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
	end
end

function modifier_omniknight_guardian_angel_ebf:GetStatusEffectName()
	return "particles/status_fx/status_effect_guardian_angel.vpcf"
end

function modifier_omniknight_guardian_angel_ebf:StatusEffectPriority()
	return 10
end