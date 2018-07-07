boss_warlock_demon_lust = class({})
LinkLuaModifier( "modifier_boss_warlock_demon_lust", "bosses/boss_warlock/boss_warlock_demon_lust", LUA_MODIFIER_MOTION_NONE )

function boss_warlock_demon_lust:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_boss_warlock_demon_lust", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_boss_warlock_demon_lust = class({})
function modifier_boss_warlock_demon_lust:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_boss_warlock_demon_lust:GetModifierAttackSpeedBonus_Constant()
    return self:GetSpecialValueFor("bonus_as")
end

function modifier_boss_warlock_demon_lust:GetBaseAttackTime_Bonus()
    return self:GetSpecialValueFor("bonus_at")
end

function modifier_boss_warlock_demon_lust:IsDebuff()
    return false
end

function modifier_boss_warlock_demon_lust:GetEffectName()
    return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end