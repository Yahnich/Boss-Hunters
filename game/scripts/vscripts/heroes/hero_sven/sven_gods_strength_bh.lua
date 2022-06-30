sven_gods_strength_bh = class({})

function sven_gods_strength_bh:GetIntrinsicModifierName()
	return "modifier_sven_gods_strength_talent_handler"
end

function sven_gods_strength_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_sven_gods_strength_bonus_damage", {duration = duration})
	ParticleManager:FireParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	
	local modifier = caster:FindModifierByName("modifier_sven_gods_strength_talent_handler")
	modifier:IncrementStackCount()
	
	caster:EmitSound("Hero_Sven.GodsStrength")
end

modifier_sven_gods_strength_talent_handler = class({})
LinkLuaModifier("modifier_sven_gods_strength_talent_handler", "heroes/hero_sven/sven_gods_strength_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_gods_strength_talent_handler:OnCreated()
	self:OnRefresh()
end

function modifier_sven_gods_strength_talent_handler:OnRefresh()
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_sven_gods_strength_1")
	self.bonusDmg = self:GetCaster():FindTalentValue("special_bonus_unique_sven_gods_strength_1")
end

function modifier_sven_gods_strength_talent_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE }
end

function modifier_sven_gods_strength_talent_handler:GetModifierOverrideAbilitySpecial(params)
	if params.ability == self:GetAbility() and self.talent1 then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "gods_strength_damage" then
			return 1
		end
	end
end

function modifier_sven_gods_strength_talent_handler:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability == self:GetAbility() and self.talent1 then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "gods_strength_damage" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			local value = self.bonusDmg * self:GetStackCount()
			return flBaseValue + value
		end
	end
end

function modifier_sven_gods_strength_talent_handler:IsHidden()
	return true
end

function modifier_sven_gods_strength_talent_handler:RemoveOnDeath()
	return false
end

modifier_sven_gods_strength_bonus_damage = class({})
LinkLuaModifier("modifier_sven_gods_strength_bonus_damage", "heroes/hero_sven/sven_gods_strength_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_gods_strength_bonus_damage:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius_scepter")
	self.damage = self:GetTalentSpecialValueFor("gods_strength_damage")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_sven_gods_strength_2")
	if IsServer() then
		local gFX = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(gFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(gFX)
		ParticleManager:ReleaseParticleIndex(gFX)
	end
end

function modifier_sven_gods_strength_bonus_damage:IsAura()
	return self.talent2
end

function modifier_sven_gods_strength_bonus_damage:GetModifierAura()
	return "modifier_sven_gods_strength_talent"
end

function modifier_sven_gods_strength_bonus_damage:GetAuraRadius()
	return self.radius
end

function modifier_sven_gods_strength_bonus_damage:GetAuraDuration()
	return 0.5
end

function modifier_sven_gods_strength_bonus_damage:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_sven_gods_strength_bonus_damage:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_HERO
end

function modifier_sven_gods_strength_bonus_damage:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_sven_gods_strength_bonus_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_sven_gods_strength_bonus_damage:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end

function modifier_sven_gods_strength_bonus_damage:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_sven_gods_strength_bonus_damage:StatusEffectPriority()
	return 25
end

function modifier_sven_gods_strength_bonus_damage:GetHeroEffectName()
	return "particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf"
end

function modifier_sven_gods_strength_bonus_damage:HeroEffectPriority()
	return 25
end

modifier_sven_gods_strength_talent = class({})
LinkLuaModifier("modifier_sven_gods_strength_talent", "heroes/hero_sven/sven_gods_strength_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_gods_strength_talent:OnCreated()
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_sven_gods_strength_2", "radius")
	self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_sven_gods_strength_2")
end

function modifier_sven_gods_strength_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_sven_gods_strength_talent:GetModifierHealthRegenPercentage()
	return self.regen
end