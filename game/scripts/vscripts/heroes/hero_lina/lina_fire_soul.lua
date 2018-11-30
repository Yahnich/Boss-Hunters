lina_fire_soul = class({})
LinkLuaModifier( "modifier_lina_fire_soul_handle", "heroes/hero_lina/lina_fire_soul.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lina_fire_soul", "heroes/hero_lina/lina_fire_soul.lua" ,LUA_MODIFIER_MOTION_NONE )

function lina_fire_soul:GetIntrinsicModifierName()
    return "modifier_lina_fire_soul_handle"
end

modifier_lina_fire_soul_handle = class({})
function modifier_lina_fire_soul_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }

    return funcs
end

function modifier_lina_fire_soul_handle:OnAbilityExecuted(params)
    if params.unit == self:GetCaster() and params.ability:GetCooldown(-1) > 0 then
        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lina_fire_soul", {Duration = self:GetSpecialValueFor("stack_duration")}):AddIndependentStack(self:GetSpecialValueFor("stack_duration"))
    end
end

function modifier_lina_fire_soul_handle:IsHidden()
    return true
end

modifier_lina_fire_soul = class({})
function modifier_lina_fire_soul:OnCreated(table)
    if self:GetCaster():HasScepter() then
        self.damage = 10
    else
        self.damage = 0
    end
end

function modifier_lina_fire_soul:DeclareFunctions()
    local funcs = {
        
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_lina_fire_soul:GetModifierDamageOutgoing_Percentage()
    return self.damage * self:GetStackCount()
end

function modifier_lina_fire_soul:GetModifierAttackSpeedBonus()
    return self:GetSpecialValueFor("attack_speed_bonus") * self:GetStackCount()
end

function modifier_lina_fire_soul:GetModifierMoveSpeedBonus_Percentage()
    return self:GetSpecialValueFor("move_speed_bonus") * self:GetStackCount()
end