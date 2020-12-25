omniknight_guardian_angel_bh = class({})

function omniknight_guardian_angel_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local purification = caster:FindAbilityByName("omniknight_purification_bh")
	local grace = caster:FindAbilityByName("omniknight_heavenly_grace_bh")
	
	local duration = self:GetTalentSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_omniknight_guardian_angel_bh", {duration = duration})
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius") ) ) do
		ally:AddNewModifier(caster, self, "modifier_omniknight_guardian_angel_bh", {duration = duration})
		if caster:HasScepter() then
			caster:SetCursorCastTarget( ally )
			if grace then
				grace:OnSpellStart() 
			end
			if purification then 
				purification:OnSpellStart() 
			end
		end
	end
end

modifier_omniknight_guardian_angel_bh = class({})
LinkLuaModifier("modifier_omniknight_guardian_angel_bh", "heroes/hero_omniknight/omniknight_guardian_angel_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_omniknight_guardian_angel_bh:OnCreated()
	self.health_regen = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_guardian_angel_1")
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_guardian_angel_2")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_omniknight_guardian_angel_bh:OnRefresh()
	self.health_regen = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_guardian_angel_1")
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_guardian_angel_2")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_omniknight_guardian_angel_bh:OnDestroy()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_omniknight_guardian_angel_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_omniknight_guardian_angel_bh:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_omniknight_guardian_angel_bh:GetModifierHealthRegenPercentage()
	return self.health_regen
end

function modifier_omniknight_guardian_angel_bh:GetModifierDamageOutgoing_Percentage()
	return self.damage
end

function modifier_omniknight_guardian_angel_bh:GetEffectName()
	if self:GetParent() == self:GetCaster() then
		return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf"
	else
		return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
	end
end

function modifier_omniknight_guardian_angel_bh:GetStatusEffectName()
	return "particles/status_fx/status_effect_guardian_angel.vpcf"
end

function modifier_omniknight_guardian_angel_bh:StatusEffectPriority()
	return 10
end