omniknight_heavenly_grace_bh = class({})

function omniknight_heavenly_grace_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier(caster, self, "modifier_omniknight_heavenly_grace_bh", {duration = self:GetSpecialValueFor("duration")})
	
	EmitSoundOn("Hero_Omniknight.Repel", target)
	ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_repel_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_omniknight_heavenly_grace_bh = class({})
LinkLuaModifier("modifier_omniknight_heavenly_grace_bh", "heroes/hero_omniknight/omniknight_heavenly_grace_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_heavenly_grace_bh:OnCreated()
	self:OnRefresh()
end

function modifier_omniknight_heavenly_grace_bh:OnRefresh()
	self.status_resist = self:GetSpecialValueFor("status_resist")
	self.restore_amp = self:GetSpecialValueFor("restore_amp")
	self.regen = self:GetSpecialValueFor("health_regen")
	self.bonus_str = self:GetSpecialValueFor("bonus_str")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_omniknight_heavenly_grace_2")
	self.talent2Val = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_heavenly_grace_2") / 100
end

function modifier_omniknight_heavenly_grace_bh:OnDestroy()
	if IsServer() then StopSoundOn("Hero_Omniknight.Repel", target) end
end

function modifier_omniknight_heavenly_grace_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
			}

end

function modifier_omniknight_heavenly_grace_bh:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_omniknight_heavenly_grace_bh:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_omniknight_heavenly_grace_bh:GetModifierHPRegenAmplify_Percentage()
	return self.restore_amp
end

function modifier_omniknight_heavenly_grace_bh:GetModifierLifestealRegenAmplify_Percentage()
	return self.restore_amp
end


function modifier_omniknight_heavenly_grace_bh:GetModifierHealAmplify_Percentage()
	return self.restore_amp
end

function modifier_omniknight_heavenly_grace_bh:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_omniknight_heavenly_grace_bh:GetModifierStatusAmplify_Percentage()
	if self.talent2 then return self.restore_amp * self.talent2Val end
end

function modifier_omniknight_heavenly_grace_bh:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_buff.vpcf"
end