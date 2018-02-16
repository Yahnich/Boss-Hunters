mirana_mooneye = class({})
LinkLuaModifier( "modifier_mirana_mooneye", "heroes/hero_mirana/mirana_mooneye.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mirana_mooneye_stack", "heroes/hero_mirana/mirana_mooneye.lua" ,LUA_MODIFIER_MOTION_NONE )

function mirana_mooneye:GetIntrinsicModifierName()
    return "modifier_mirana_mooneye"
end

modifier_mirana_mooneye = class({})
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
function modifier_mirana_mooneye_stack:OnCreated(table)
    self:IncrementStackCount()
    self.agi = self:GetParent():GetAgility() * self:GetSpecialValueFor("agi_mult")/100 * self:GetStackCount()
end

function modifier_mirana_mooneye_stack:OnRefresh(table)
    self.agi = (self:GetParent():GetAgility() - self.agi) * self:GetSpecialValueFor("agi_mult")/100 * self:GetStackCount()
end

function modifier_mirana_mooneye_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS
    }   
    return funcs
end

function modifier_mirana_mooneye_stack:GetModifierBonusStats_Agility()
    return self.agi
end

function modifier_mirana_mooneye_stack:IsDebuff()
    return false
end

function modifier_mirana_mooneye_stack:OnStackCountChanged(iStacks)
    if IsServer() then
        self:GetParent():CalculateStatBonus()
    end
end