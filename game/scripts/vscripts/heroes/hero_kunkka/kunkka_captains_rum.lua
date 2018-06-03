kunkka_captains_rum = class({})
LinkLuaModifier("modifier_kunkka_captains_rum", "heroes/hero_kunkka/kunkka_captains_rum.lua", LUA_MODIFIER_MOTION_NONE)

function kunkka_captains_rum:IsStealable()
    return true
end

function kunkka_captains_rum:IsHiddenWhenStolen()
    return false
end

function kunkka_captains_rum:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_unique_kunkka_captains_rum_2") then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    else
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
end

function kunkka_captains_rum:OnSpellStart()
    if self:GetCaster():HasTalent("special_bonus_unique_kunkka_captains_rum_2") then
        local target = self:GetCursorTarget()
        EmitSoundOn("Hero_Kunkka.TauntJig", target)
        target:AddNewModifier(self:GetCaster(), self, "modifier_kunkka_captains_rum", {duration = self:GetTalentSpecialValueFor("duration")})
    else
        EmitSoundOn("Hero_Kunkka.TauntJig", self:GetCaster())
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kunkka_captains_rum", {duration = self:GetTalentSpecialValueFor("duration")})
    end
end

modifier_kunkka_captains_rum = class({})
function modifier_kunkka_captains_rum:OnIntervalThink()
    if IsServer() and self:RollPRNG(25) then
        self:GetParent():SetInitialGoalEntity(nil)
        self:GetParent():Stop()
        self:GetParent():Interrupt()
        self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin()+ActualRandomVector(self:GetParent():GetAttackRange(), -self:GetParent():GetAttackRange()))
    end
end

function modifier_kunkka_captains_rum:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function modifier_kunkka_captains_rum:OnCreated()
    self.damagereduction = self:GetAbility():GetTalentSpecialValueFor("damage_reduction")
    self.movespeedbonus = self:GetAbility():GetTalentSpecialValueFor("movespeed_bonus")
    self.damageamp = self:GetAbility():GetTalentSpecialValueFor("bonus_basedamage_perc")
    self.bonusdamage = self:GetAbility():GetTalentSpecialValueFor("bonus_damage")
    self:StartIntervalThink(0.35)
end

function modifier_kunkka_captains_rum:GetModifierIncomingDamage_Percentage()
    return self.damagereduction
end

function modifier_kunkka_captains_rum:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeedbonus
end

function modifier_kunkka_captains_rum:GetModifierBaseDamageOutgoing_Percentage()
    return self.damageamp
end

function modifier_kunkka_captains_rum:GetModifierPreAttack_BonusDamage()
    return self.bonusdamage
end

function modifier_kunkka_captains_rum:DestroyOnExpire()
    return true
end

function modifier_kunkka_captains_rum:IsPurgable()
    return false
end

function modifier_kunkka_captains_rum:RemoveOnDeath()
    return true
end

function modifier_kunkka_captains_rum:IsDebuff()
    return false
end

function modifier_kunkka_captains_rum:GetStatusEffectName()
    return "particles/status_fx/status_effect_rum.vpcf"
end

function modifier_kunkka_captains_rum:StatusEffectPriority()
    return 10
end

function modifier_kunkka_captains_rum:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_drunken_haze_debuff.vpcf"
end