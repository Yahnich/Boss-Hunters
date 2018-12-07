windrunner_windrun_bh = class({})
LinkLuaModifier("modifier_windrunner_windrun_bh_handle", "heroes/hero_windrunner/windrunner_windrun_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_windrunner_windrun_bh", "heroes/hero_windrunner/windrunner_windrun_bh", LUA_MODIFIER_MOTION_NONE)

function windrunner_windrun_bh:IsStealable()
	return true
end

function windrunner_windrun_bh:IsHiddenWhenStolen()
	return false
end

function windrunner_windrun_bh:OnSpellStart()
	local caster = self:GetCaster()
	
    EmitSoundOn("Ability.Windrun", caster)
	caster:AddNewModifier(caster, self, "modifier_windrunner_windrun_bh_handle", {Duration = self:GetTalentSpecialValueFor("buff_duration")})
end

modifier_windrunner_windrun_bh_handle = class({})
function modifier_windrunner_windrun_bh_handle:OnCreated(table)
    if self:GetCaster():HasTalent("special_bonus_unique_windrunner_windrun_bh_2") then
        self.invis = 10
    end
end

function modifier_windrunner_windrun_bh_handle:CheckState()
    if self:GetCaster():HasTalent("special_bonus_unique_windrunner_windrun_bh_2") then
        local state = { [MODIFIER_STATE_INVISIBLE] = true,
                        [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
        return state
    end

    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
    return state
end

function modifier_windrunner_windrun_bh_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
    return funcs
end

function modifier_windrunner_windrun_bh_handle:GetModifierInvisibilityLevel()
    return self.invis
end

function modifier_windrunner_windrun_bh_handle:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("movespeed_bonus_pct")
end

function modifier_windrunner_windrun_bh_handle:GetMoveSpeedLimitBonus()
    return self:GetTalentSpecialValueFor("movespeed_bonus_limit")
end

function modifier_windrunner_windrun_bh_handle:GetModifierEvasion_Constant()
    return self:GetTalentSpecialValueFor("evasion")
end

function modifier_windrunner_windrun_bh_handle:GetEffectName()
    return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_windrunner_windrun_bh_handle:IsAura()
    return true
end

function modifier_windrunner_windrun_bh_handle:GetAuraDuration()
    return self:GetTalentSpecialValueFor("debuff_duration")
end

function modifier_windrunner_windrun_bh_handle:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_windrunner_windrun_bh_handle:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_windrunner_windrun_bh_handle:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_windrunner_windrun_bh_handle:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_windrunner_windrun_bh_handle:GetModifierAura()
    return "modifier_windrunner_windrun_bh"
end

function modifier_windrunner_windrun_bh_handle:IsDebuff()
    return false
end

modifier_windrunner_windrun_bh = class({})
function modifier_windrunner_windrun_bh:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_windrunner_windrun_bh:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("enemy_movespeed_bonus_pct")
end

function modifier_windrunner_windrun_bh:IsDebuff()
    return true
end

function modifier_windrunner_windrun_bh:GetEffectName()
    return "particles/units/heroes/hero_windrunner/windrunner_windrun_slow.vpcf"
end