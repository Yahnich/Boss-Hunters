guardian_guardians_spirit = class({})

function guardian_guardians_spirit:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_guardian_guardians_spirit_buff", {duration = self:GetTalentSpecialValueFor("duration")})
	EmitSoundOn("Hero_Sven.GodsStrength", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
end

LinkLuaModifier( "modifier_guardian_guardians_spirit_buff", "heroes/guardian/guardian_guardians_spirit.lua", LUA_MODIFIER_MOTION_NONE )
modifier_guardian_guardians_spirit_buff = class({})

function modifier_guardian_guardians_spirit_buff:OnCreated()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_str")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.damage = self:GetAbility():GetSpecialValueFor("talent_damage")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
		if self:GetCaster():HasTalent("guardian_guardians_spirit_talent_1") then
			ParticleManager:FireParticle("particles/fire_ball_explosion.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
			self:GetParent():DealAOEDamage(self:GetParent():GetAbsOrigin(), self:GetParent():FindTalentValue("guardian_guardians_spirit_talent_1"), {damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
		end
	end
end

function modifier_guardian_guardians_spirit_buff:OnRefresh()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_str")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.damage = self:GetAbility():GetSpecialValueFor("talent_damage")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
		if self:GetCaster():HasTalent("guardian_guardians_spirit_talent_1") then
			ParticleManager:FireParticle("particles/fire_ball_explosion.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
			self:GetParent():DealAOEDamage(self:GetParent():GetAbsOrigin(), self:GetParent():FindTalentValue("guardian_guardians_spirit_talent_1"), {damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
		end
	end
end

function modifier_guardian_guardians_spirit_buff:OnDestroy()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
		if self:GetCaster():HasTalent("guardian_guardians_spirit_talent_1") then
			ParticleManager:FireParticle("particles/fire_ball_explosion.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
			self:GetParent():DealAOEDamage(self:GetParent():GetAbsOrigin(), self:GetParent():FindTalentValue("guardian_guardians_spirit_talent_1"), {damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
		end
	end
end

function modifier_guardian_guardians_spirit_buff:GetEffectName()
	return "particles/units/heroes/hero_sven/sven_spell_gods_strength_ambient.vpcf"
end

function modifier_guardian_guardians_spirit_buff:GetHeroEffectName()
	return "particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf"
end

function modifier_guardian_guardians_spirit_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_guardian_guardians_spirit_buff:StatusEffectPriority()
	return 10
end


function modifier_guardian_guardians_spirit_buff:DeclareFunctions()
	funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

function modifier_guardian_guardians_spirit_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_damage
end

function modifier_guardian_guardians_spirit_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_guardian_guardians_spirit_buff:GetModifierBonusStats_Strength()
	return self.str
end