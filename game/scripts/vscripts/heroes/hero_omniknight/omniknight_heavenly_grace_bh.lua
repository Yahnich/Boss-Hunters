omniknight_heavenly_grace_bh = class({})

function omniknight_heavenly_grace_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier(caster, self, "modifier_omniknight_heavenly_grace_bh", {duration = self:GetTalentSpecialValueFor("duration")})
	
	EmitSoundOn("Hero_Omniknight.Repel", target)
	ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_repel_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_omniknight_heavenly_grace_bh = class({})
LinkLuaModifier("modifier_omniknight_heavenly_grace_bh", "heroes/hero_omniknight/omniknight_heavenly_grace_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_heavenly_grace_bh:OnCreated()
	self.damage_resist = self:GetTalentSpecialValueFor("damage_resist")
	self.regen = self:GetTalentSpecialValueFor("health_regen")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_omniknight_heavenly_grace_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_omniknight_heavenly_grace_2")
	if self.talent1 then
		self.damage_resist_growth = ( (-100 - self.damage_resist/2) / self:GetRemainingTime() ) * 0.25
		self.damage_resist = -100
		self:StartIntervalThink(0.25)
	end
end

function modifier_omniknight_heavenly_grace_bh:OnRefresh()
	self.damage_resist = self:GetTalentSpecialValueFor("damage_resist")
	self.regen = self:GetTalentSpecialValueFor("health_regen")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_omniknight_heavenly_grace_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_omniknight_heavenly_grace_2")
	if self.talent1 then
		self.damage_resist_growth = ( (-100 - self.damage_resist/2) / self:GetRemainingTime() ) * 0.25
		self.damage_resist = -100
	end
end

function modifier_omniknight_heavenly_grace_bh:OnIntervalThink()
	self.damage_resist = self.damage_resist - self.damage_resist_growth
end

function modifier_omniknight_heavenly_grace_bh:OnDestroy()
	if IsServer() then StopSoundOn("Hero_Omniknight.Repel", target) end
end

function modifier_omniknight_heavenly_grace_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
			
end

function modifier_omniknight_heavenly_grace_bh:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_omniknight_heavenly_grace_bh:GetModifierIncomingDamage_Percentage()
	return self.damage_resist
end

function modifier_omniknight_heavenly_grace_bh:GetModifierStatusAmplify_Percentage()
	if self.talent2 then return self.damage_resist * self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_heavenly_grace_2") / 100 end
end

function modifier_omniknight_heavenly_grace_bh:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_buff.vpcf"
end