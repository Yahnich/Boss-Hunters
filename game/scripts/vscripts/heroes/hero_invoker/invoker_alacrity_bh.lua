invoker_alacrity_bh = class({})
LinkLuaModifier("modifier_invoker_alacrity_bh", "heroes/hero_invoker/invoker_alacrity_bh", LUA_MODIFIER_MOTION_NONE)

function invoker_alacrity_bh:IsStealable()
    return true
end

function invoker_alacrity_bh:IsHiddenWhenStolen()
    return false
end

function invoker_alacrity_bh:OnAbilityPhaseStart()
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ALACRITY)
    return true
end

function invoker_alacrity_bh:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ALACRITY)
end

function invoker_alacrity_bh:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    local duration = self:GetSpecialValueFor("duration")

    target:AddNewModifier(caster, self, "modifier_invoker_alacrity_bh", {Duration = duration})
end

modifier_invoker_alacrity_bh = class({})
function modifier_invoker_alacrity_bh:OnCreated(table)
    local caster = self:GetCaster()

    self.bonus_as = self:GetSpecialValueFor("bonus_as")
    self.bonus_ad = self:GetSpecialValueFor("bonus_ad")
end

function modifier_invoker_alacrity_bh:OnRefresh(table)
    local caster = self:GetCaster()

    self.bonus_as = self:GetSpecialValueFor("bonus_as")
    self.bonus_ad = self:GetSpecialValueFor("bonus_ad")
end

function modifier_invoker_alacrity_bh:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
    return funcs
end

function modifier_invoker_alacrity_bh:GetModifierPreAttack_BonusDamage()
    return self.bonus_ad
end

function modifier_invoker_alacrity_bh:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_invoker_alacrity_bh:IsDebuff()
    return true
end

function modifier_invoker_alacrity_bh:IsPurgable()
    return true
end