bane_brain_feast = class({})

function bane_brain_feast:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown(self, iLvl)
	if self:GetCaster():HasScepter() then cd = self:GetTalentSpecialValueFor("scepter_cooldown") end
	return cd
end

function bane_brain_feast:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local damage = self:GetTalentSpecialValueFor("heal_damage")
	caster:HealEvent(damage, self, caster)
	
	if not target.IsNightmared then 
		target.IsNightmared = function() return target:HasModifier("modifier_bane_nightmare_prison_sleep") or target:HasModifier("modifier_bane_nightmare_prison_fear") end
	end
	
	if caster:HasTalent("special_bonus_unique_bane_brain_feast_1") and target:IsNightmared() then
		damage = damage * caster:FindTalentValue("special_bonus_unique_bane_brain_feast_1")
	end
	self:DealDamage(caster, target, damage)
	target:AddNewModifier(caster, self, "modifier_bane_brain_feast_debuff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
	
	EmitSoundOn("Hero_Bane.BrainSap.Target", target)
	EmitSoundOn("Hero_Bane.BrainSap", caster)
	
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_POINT_FOLLOW, caster, target)
	if caster:HasTalent("special_bonus_unique_bane_brain_feast_2") then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_bane_brain_feast_2") ) ) do
			if ally ~= caster then
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_POINT_FOLLOW, ally, caster)
				ally:HealEvent(damage, self, caster)
			end
		end
	end
end

modifier_bane_brain_feast_debuff = class({})
LinkLuaModifier("modifier_bane_brain_feast_debuff", "heroes/hero_bane/bane_brain_feast", LUA_MODIFIER_MOTION_NONE)

function modifier_bane_brain_feast_debuff:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage_on_cast")
end

function modifier_bane_brain_feast_debuff:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("damage_on_cast")
end

function modifier_bane_brain_feast_debuff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_bane_brain_feast_debuff:GetModifierIncomingDamage_Percentage()
	return -5
end

function modifier_bane_brain_feast_debuff:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		self:GetAbility():DealDamage( caster, params.unit, self.damage )
	end
end

function modifier_bane_brain_feast_debuff:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_brain_feast_debuff.vpcf"
end

function modifier_bane_brain_feast_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end