kunkka_captains_rum = class({})

function kunkka_captains_rum:IsStealable()
    return true
end

function kunkka_captains_rum:IsHiddenWhenStolen()
    return false
end

function kunkka_captains_rum:GetBehavior()
    if self:GetSpecialValueFor("cast_on_allies") == 1 then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    else
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
end

function kunkka_captains_rum:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or caster
   
	EmitSoundOn("Hero_Kunkka.TauntJig", target)
	target:AddNewModifier( caster, self, "modifier_kunkka_captains_rum", {duration = self:GetSpecialValueFor("duration")} )
end

modifier_kunkka_captains_rum = class({})
LinkLuaModifier("modifier_kunkka_captains_rum", "heroes/hero_kunkka/kunkka_captains_rum.lua", LUA_MODIFIER_MOTION_NONE)
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
    self.damage_reduction = -self:GetSpecialValueFor("damage_reduction")
    self.movespeed_bonus = self:GetSpecialValueFor("movespeed_bonus")
    self.damageamp = self:GetSpecialValueFor("bonus_basedamage_perc")
    self.bonusdamage = self:GetSpecialValueFor("bonus_damage")
    self:StartIntervalThink(0.35)
end

function modifier_kunkka_captains_rum:GetModifierIncomingDamage_Percentage()
    return self.damage_reduction
end

function modifier_kunkka_captains_rum:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed_bonus
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