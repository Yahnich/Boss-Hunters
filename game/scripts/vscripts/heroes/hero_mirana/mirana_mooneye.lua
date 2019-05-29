mirana_mooneye = class({})

function mirana_mooneye:GetIntrinsicModifierName()
    return "modifier_mirana_mooneye"
end

function mirana_mooneye:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function mirana_mooneye:GetCooldown(iLvl)
	if self:GetCaster() then
		return self:GetTalentSpecialValueFor("scepter_cd")
	end
end

function mirana_mooneye:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_mirana_mooneye_scepter", {})
end

modifier_mirana_mooneye = class({})
LinkLuaModifier( "modifier_mirana_mooneye", "heroes/hero_mirana/mirana_mooneye.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_mirana_mooneye:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_mirana_mooneye:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() and RollPercentage(self:GetSpecialValueFor("chance")) then
            params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_mirana_mooneye_stack", {Duration = self:GetSpecialValueFor("duration")}):AddIndependentStack(self:GetSpecialValueFor("duration"))
        end
    end
end

function modifier_mirana_mooneye:IsHidden()
    return true
end

modifier_mirana_mooneye_stack = class({})
LinkLuaModifier( "modifier_mirana_mooneye_stack", "heroes/hero_mirana/mirana_mooneye.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_mirana_mooneye_stack:OnCreated(table)
    self.agi = self:GetSpecialValueFor("agi_mult")
end

function modifier_mirana_mooneye_stack:OnRefresh(table)
	self.agi = 0
    self.agi = self:GetSpecialValueFor("agi_mult")
end

function modifier_mirana_mooneye_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS
    }   
    return funcs
end

function modifier_mirana_mooneye_stack:GetModifierAgilityBonusPercentage()
    return self.agi * self:GetStackCount()
end

function modifier_mirana_mooneye_stack:IsDebuff()
    return false
end

modifier_mirana_mooneye_scepter = class({})
LinkLuaModifier( "modifier_mirana_mooneye_scepter", "heroes/hero_mirana/mirana_mooneye.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_mirana_mooneye_scepter:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
    }   
    return funcs
end

function modifier_mirana_mooneye_scepter:GetModifierPreAttack_CriticalStrike()
	self:Destroy()
    return self:GetTalentSpecialValueFor("scepter_crit")
end