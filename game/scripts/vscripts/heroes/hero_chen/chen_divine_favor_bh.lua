chen_divine_favor_bh = class({})

function chen_divine_favor_bh:IsStealable()
	return true
end

function chen_divine_favor_bh:IsHiddenWhenStolen()
	return false
end

function chen_divine_favor_bh:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_chen_divine_favor_bh_1") then
		return "modifier_chen_divine_favor_bh"
	end
end

function chen_divine_favor_bh:OnTalentLearned(talent)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_chen_divine_favor_bh", {})
end

function chen_divine_favor_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Chen.DivineFavor.Cast", caster)
	EmitSoundOn("Hero_Chen.DivineFavor.Target", target)

	target:Dispel(caster, false)
	target:AddNewModifier(caster, self, "modifier_chen_divine_favor_bh", {Duration = self:GetTalentSpecialValueFor("duration")})
	ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_divine_favor.vpcf", PATTACH_POINT, target, {})
end

modifier_chen_divine_favor_bh = class({})
LinkLuaModifier( "modifier_chen_divine_favor_bh", "heroes/hero_chen/chen_divine_favor_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_chen_divine_favor_bh:OnCreated()
	self.bonus_dmg = self:GetTalentSpecialValueFor("bonus_dmg")
	self.regen = self:GetTalentSpecialValueFor("health_regeneration")
	self.heal_amp = self:GetTalentSpecialValueFor("heal_amp")
	self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_chen_divine_favor_bh_2")
end

function modifier_chen_divine_favor_bh:OnRefresh()
	self.bonus_dmg = self:GetTalentSpecialValueFor("bonus_dmg")
	self.regen = self:GetTalentSpecialValueFor("health_regeneration")
	self.heal_amp = self:GetTalentSpecialValueFor("heal_amp")
	self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_chen_divine_favor_bh_2")
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
	return not (self:GetCaster() == self:GetParent() and self:GetCaster():HasTalent("special_bonus_unique_chen_divine_favor_bh_1") )
end