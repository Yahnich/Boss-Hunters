boss_slardar_blessing_of_the_tides = class({})

function boss_slardar_blessing_of_the_tides:GetIntrinsicModifierName()
	return "modifier_boss_slardar_blessing_of_the_tides"
end

modifier_boss_slardar_blessing_of_the_tides = class({})
LinkLuaModifier( "modifier_boss_slardar_blessing_of_the_tides", "bosses/boss_slardar/boss_slardar_blessing_of_the_tides", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_slardar_blessing_of_the_tides:OnCreated()
	self.as = self:GetTalentSpecialValueFor("bonus_as")
	self.regen = self:GetTalentSpecialValueFor("bonus_regen")
end

function modifier_boss_slardar_blessing_of_the_tides:OnRefresh()
	self:OnCreated()
end

function modifier_boss_slardar_blessing_of_the_tides:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
    return funcs
end

function modifier_boss_slardar_blessing_of_the_tides:GetModifierAttackSpeedBonus()
	if self:GetCaster():InWater() then return self.as end
end

function modifier_boss_slardar_blessing_of_the_tides:GetModifierConstantHealthRegen()
	if self:GetCaster():InWater() then return self.regen end
end

function modifier_boss_slardar_blessing_of_the_tides:GetActivityTranslationModifiers()
	if self:GetCaster():InWater() then return "sprint" end
end

function modifier_boss_slardar_blessing_of_the_tides:GetEffectName()
	if self:GetCaster():InWater() then return "particles/units/heroes/hero_slardar/slardar_sprint.vpcf" end
end

function modifier_boss_slardar_blessing_of_the_tides:IsHidden()
	return not self:GetCaster():InWater()
end