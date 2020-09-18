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
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
    if self:GetCaster():HasTalent("special_bonus_unique_windrunner_windrun_bh_2") then
		self.fade_delay = 0.75
        if IsServer() then
			self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_invisible", {}):SetDuration(self:GetRemainingTime(), true)
			self:StartIntervalThink(0.1)
		end
    end
end

function modifier_windrunner_windrun_bh_handle:OnIntervalThink()
	if IsServer() then
		if self:GetParent():HasModifier("modifier_invisible") then
			if self:GetParent():GetLastAttackTime() >= GameRules:GetGameTime() - self.fade_delay or self:GetParent():HasActiveAbility() then
				self:GetParent():RemoveModifierByName("modifier_invisible")
				self.think = 0
			end
			return
		else
			self.think = (self.think or 0) + 0.1
			if self.think >= self.fade_delay then
				self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_invisible", {}):SetDuration(self:GetRemainingTime(), true)
			end
		end 
	end
end

function modifier_windrunner_windrun_bh_handle:OnDestroy()
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_windrunner_windrun_bh_handle:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
    return state
end

function modifier_windrunner_windrun_bh_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }
    return funcs
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