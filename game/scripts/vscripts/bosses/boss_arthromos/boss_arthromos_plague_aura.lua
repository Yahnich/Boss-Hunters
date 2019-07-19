boss_arthromos_plague_aura = class({})

function boss_arthromos_plague_aura:GetIntrinsicModifierName()
	return "modifier_boss_arthromos_plague_aura"
end

modifier_boss_arthromos_plague_aura = class({})
LinkLuaModifier( "modifier_boss_arthromos_plague_aura", "bosses/boss_arthromos/boss_arthromos_plague_aura", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_arthromos_plague_aura:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_arthromos_plague_aura:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_arthromos_plague_aura:IsAura()
	return true
end

function modifier_boss_arthromos_plague_aura:GetModifierAura()
	return "modifier_boss_arthromos_plague_aura_debuff"
end

function modifier_boss_arthromos_plague_aura:GetAuraRadius()
	return self.radius
end

function modifier_boss_arthromos_plague_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_arthromos_plague_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP 
end

function modifier_boss_arthromos_plague_aura:GetEffectName()
	return "particles/units/heroes/hero_necrolyte/necrolyte_spirit.vpcf"
end

function modifier_boss_arthromos_plague_aura:IsHidden()
	return true
end

modifier_boss_arthromos_plague_aura_debuff = class({})
LinkLuaModifier( "modifier_boss_arthromos_plague_aura_debuff", "bosses/boss_arthromos/boss_arthromos_plague_aura", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_arthromos_plague_aura_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_HEALING}
end

function modifier_boss_arthromos_plague_aura_debuff:GetDisableHealing()
	return 1
end

function modifier_boss_arthromos_plague_aura_debuff:GetEffectName()
	return "particles/units/heroes/hero_necrolyte/necrolyte_spirit_debuff.vpcf"
end