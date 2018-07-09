warlock_golem_immolation = class({})
LinkLuaModifier("modifier_warlock_golem_immolation", "heroes/hero_warlock/warlock_golem_immolation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warlock_golem_immolation_debuff", "heroes/hero_warlock/warlock_golem_immolation", LUA_MODIFIER_MOTION_NONE)

function warlock_golem_immolation:GetIntrinsicModifierName()
	return "modifier_warlock_golem_immolation"
end

modifier_warlock_golem_immolation = class({})
function modifier_warlock_golem_immolation:IsAura()
    return true
end

function modifier_warlock_golem_immolation:GetAuraDuration()
    return 0.5
end

function modifier_warlock_golem_immolation:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_warlock_golem_immolation:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_warlock_golem_immolation:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_warlock_golem_immolation:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_warlock_golem_immolation:GetModifierAura()
    return "modifier_warlock_golem_immolation_debuff"
end

function modifier_warlock_golem_immolation:IsAuraActiveOnDeath()
    return false
end

function modifier_warlock_golem_immolation:IsHidden()
    return true
end

modifier_warlock_golem_immolation_debuff = class({})
function modifier_warlock_golem_immolation_debuff:OnCreated(table)
    if IsServer() then self:StartIntervalThink(1) end
end

function modifier_warlock_golem_immolation_debuff:OnIntervalThink()
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage"), {}, 0)
end

function modifier_warlock_golem_immolation:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_sunray_debuff.vpcf"
end

function modifier_warlock_golem_immolation:IsDebuff()
    return true
end