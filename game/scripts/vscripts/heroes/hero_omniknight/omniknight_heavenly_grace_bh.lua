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
	self.status_resist = self:GetTalentSpecialValueFor("status_resist")
	self.regen = self:GetTalentSpecialValueFor("health_regen")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_omniknight_heavenly_grace_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_omniknight_heavenly_grace_2")
	if self.talent1 then
		self.magic_resist = self.status_resist
		self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_heavenly_grace_1")
	end
	if self.talent2 then
		self.status_amp = self.status_resist * self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_heavenly_grace_2") / 100
	end
end

function modifier_omniknight_heavenly_grace_bh:OnRefresh()
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_heavenly_grace_1")
	self.status_resist = self:GetTalentSpecialValueFor("status_resist")
	self.regen = self:GetTalentSpecialValueFor("health_regen")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_omniknight_heavenly_grace_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_omniknight_heavenly_grace_2")
	if self.talent1 then
		self.magic_resist = self.status_resist
	end
	if self.talent2 then
		self.status_amp = self.status_resist * self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_heavenly_grace_2") / 100
	end
end

function modifier_omniknight_heavenly_grace_bh:OnDestroy()
	if IsServer() then StopSoundOn("Hero_Omniknight.Repel", target) end
end

function modifier_omniknight_heavenly_grace_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
			
end

function modifier_omniknight_heavenly_grace_bh:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_omniknight_heavenly_grace_bh:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_omniknight_heavenly_grace_bh:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_omniknight_heavenly_grace_bh:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_omniknight_heavenly_grace_bh:GetModifierStatusAmplify_Percentage()
	return self.status_amp
end

function modifier_omniknight_heavenly_grace_bh:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_buff.vpcf"
end