ds_command = class({})
LinkLuaModifier( "modifier_ds_command", "heroes/hero_dark_seer/ds_command.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ds_command_effect", "heroes/hero_dark_seer/ds_command.lua",LUA_MODIFIER_MOTION_NONE )

function ds_command:GetIntrinsicModifierName()
    return "modifier_ds_command"
end

modifier_ds_command = class({})
function modifier_ds_command:IsAura()
    return true
end

function modifier_ds_command:GetAuraDuration()
    return 0.5
end

function modifier_ds_command:GetAuraRadius()
    return self:GetSpecialValueFor("radius")
end

function modifier_ds_command:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_ds_command:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_ds_command:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_ds_command:GetModifierAura()
    return "modifier_ds_command_effect"
end

function modifier_ds_command:IsAuraActiveOnDeath()
    return false
end

function modifier_ds_command:IsHidden()
    return true
end

modifier_ds_command_effect = class({})
function modifier_ds_command_effect:OnCreated(table)
    self.accuracy = self:GetSpecialValueFor("bonus_accuracy")
    self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_ds_command_effect:OnRefresh(table)
    self.accuracy = self:GetSpecialValueFor("bonus_accuracy")
    self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_ds_command_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function modifier_ds_command_effect:GetAccuracy()
    return self.accuracy
end

function modifier_ds_command_effect:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_ds_command_effect:IsDebuff()
    return false
end