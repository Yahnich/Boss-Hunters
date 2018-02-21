lion_mana_aura = class({})
LinkLuaModifier( "modifier_lion_mana_aura", "heroes/hero_lion/lion_mana_aura.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lion_mana_aura_effect", "heroes/hero_lion/lion_mana_aura.lua",LUA_MODIFIER_MOTION_NONE )

function lion_mana_aura:GetIntrinsicModifierName()
    return "modifier_lion_mana_aura"
end

modifier_lion_mana_aura = class({})
function modifier_lion_mana_aura:IsAura()
    return true
end

function modifier_lion_mana_aura:GetAuraDuration()
    return 0.5
end

function modifier_lion_mana_aura:GetAuraRadius()
    return -1
end

function modifier_lion_mana_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_lion_mana_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_lion_mana_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_lion_mana_aura:GetModifierAura()
    return "modifier_lion_mana_aura_effect"
end

function modifier_lion_mana_aura:IsAuraActiveOnDeath()
    return true
end

function modifier_lion_mana_aura:IsHidden()
    return true
end

modifier_lion_mana_aura_effect = class({})
function modifier_lion_mana_aura_effect:OnCreated(table)
    self.manaRegen = self:GetSpecialValueFor("mana_regen")
end

function modifier_lion_mana_aura_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
    }
    return funcs
end

function modifier_lion_mana_aura_effect:GetModifierTotalPercentageManaRegen()
    return self.manaRegen
end