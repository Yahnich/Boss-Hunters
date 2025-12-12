chen_divine_favor_bh = class({})

function chen_divine_favor_bh:IsStealable()
	return true
end

function chen_divine_favor_bh:IsHiddenWhenStolen()
	return false
end

function chen_divine_favor_bh:GetIntrinsicModifierName()
	return "modifier_chen_divine_favor_bh_aura"
end

-- function chen_divine_favor_bh:OnSpellStart()
	-- local caster = self:GetCaster()
	-- local target = self:GetCursorTarget()

	-- EmitSoundOn("Hero_Chen.DivineFavor.Cast", caster)
	-- EmitSoundOn("Hero_Chen.DivineFavor.Target", target)

	-- target:Dispel(caster, false)
	-- target:AddNewModifier(caster, self, "modifier_chen_divine_favor_bh", {Duration = self:GetSpecialValueFor("duration")})
	-- ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_divine_favor.vpcf", PATTACH_POINT, target, {})
-- end


modifier_chen_divine_favor_bh_aura = class({})
LinkLuaModifier( "modifier_chen_divine_favor_bh_aura", "heroes/hero_chen/chen_divine_favor_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_chen_divine_favor_bh_aura:OnCreated()
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_chen_divine_favor_bh_aura:OnRefresh()
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_chen_divine_favor_bh_aura:IsAura()
	return true
end

function modifier_chen_divine_favor_bh_aura:GetAuraRadius()
	return self.radius
end

function modifier_chen_divine_favor_bh_aura:GetModifierAura()
	return "modifier_chen_divine_favor_bh"
end

function modifier_chen_divine_favor_bh_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_chen_divine_favor_bh_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_chen_divine_favor_bh_aura:GetAuraDuration()
	return 0.5
end

function modifier_chen_divine_favor_bh_aura:IsHidden()
	return true
end

modifier_chen_divine_favor_bh = class({})
LinkLuaModifier( "modifier_chen_divine_favor_bh", "heroes/hero_chen/chen_divine_favor_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_chen_divine_favor_bh:OnCreated()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.regen = self:GetSpecialValueFor("health_regeneration")
	self.heal_amp = self:GetSpecialValueFor("heal_amp")
	self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_chen_divine_favor_2")
	if self:GetCaster() == self:GetParent() and self:GetCaster():HasTalent("special_bonus_unique_chen_divine_favor_1") then
		local mult = self:GetCaster():FindTalentValue("special_bonus_unique_chen_divine_favor_1")
		self.bonus_dmg = self.bonus_dmg * mult
		self.regen = self.regen * mult
		self.heal_amp = self.heal_amp * mult
		self.evasion = self.evasion * mult
	end
end

function modifier_chen_divine_favor_bh:OnRefresh()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.regen = self:GetSpecialValueFor("health_regeneration")
	self.heal_amp = self:GetSpecialValueFor("heal_amp")
	self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_chen_divine_favor_2")
	if self:GetCaster() == self:GetParent() and self:GetCaster():HasTalent("special_bonus_unique_chen_divine_favor_1") then
		local mult = self:GetCaster():FindTalentValue("special_bonus_unique_chen_divine_favor_1")
		self.bonus_dmg = self.bonus_dmg * mult
		self.regen = self.regen * mult
		self.heal_amp = self.heal_amp * mult
		self.evasion = self.evasion * mult
	end
end

function modifier_chen_divine_favor_bh:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return funcs
end

function modifier_chen_divine_favor_bh:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_chen_divine_favor_bh:GetModifierConstantHealthRegen()
    return self.regen
end

function modifier_chen_divine_favor_bh:GetModifierHealAmplify_Percentage()
    return self.heal_amp
end

function modifier_chen_divine_favor_bh:GetModifierEvasion_Constant()
    return self.evasion
end

function modifier_chen_divine_favor_bh:GetEffectName()
    return "particles/units/heroes/hero_chen/chen_divine_favor_buff.vpcf"
end

function modifier_chen_divine_favor_bh:IsPurgable()
	return not (self:GetCaster() == self:GetParent() and self:GetCaster():HasTalent("special_bonus_unique_chen_divine_favor_1") )
end