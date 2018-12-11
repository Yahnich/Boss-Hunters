pudge_flesh_heap_lua = class({})
LinkLuaModifier("modifier_pudge_flesh_heap_lua", "heroes/hero_pudge/pudge_flesh_heap_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pudge_flesh_heap_lua_effect", "heroes/hero_pudge/pudge_flesh_heap_lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_lua:GetIntrinsicModifierName()
	return "modifier_pudge_flesh_heap_lua"
end

modifier_pudge_flesh_heap_lua = class({})
function modifier_pudge_flesh_heap_lua:OnCreated(table)
    self:StartIntervalThink(FrameTime())
end

function modifier_pudge_flesh_heap_lua:OnIntervalThink()
    self.mr = self:GetSpecialValueFor("magic_resist") * self:GetCaster():GetLevel()
end

function modifier_pudge_flesh_heap_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function modifier_pudge_flesh_heap_lua:GetModifierMagicalResistanceBonus()
    return self.mr
end

function modifier_pudge_flesh_heap_lua:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pudge_flesh_heap_lua_effect", {Duration = self:GetTalentSpecialValueFor("duration")}):AddIndependentStack(self:GetTalentSpecialValueFor("duration"))
        end
    end
end

function modifier_pudge_flesh_heap_lua:IsHidden()
    return true
end

modifier_pudge_flesh_heap_lua_effect = class({})

function modifier_pudge_flesh_heap_lua_effect:OnCreated()
    self.bonus_str = self:GetTalentSpecialValueFor("str_bonus")
    self.bonus_regen = self:GetTalentSpecialValueFor("health_regen")
    if IsServer() then self:GetParent():CalculateStatBonus() end
end

function modifier_pudge_flesh_heap_lua_effect:OnRefresh()
    self.bonus_str = self:GetTalentSpecialValueFor("str_bonus")
    self.bonus_regen = self:GetTalentSpecialValueFor("health_regen")
    if IsServer() then self:GetParent():CalculateStatBonus() end
end

function modifier_pudge_flesh_heap_lua_effect:DeclareFunctions()
    funcs = { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			  MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			  MODIFIER_PROPERTY_MODEL_SCALE }
    return funcs
end

function modifier_pudge_flesh_heap_lua_effect:GetModifierConstantHealthRegen()
    return self.bonus_regen * self:GetStackCount()
end

function modifier_pudge_flesh_heap_lua_effect:GetModifierBonusStats_Strength()
    return self.bonus_str * self:GetStackCount()
end

function modifier_pudge_flesh_heap_lua_effect:GetModifierModelScale()
    return self:GetStackCount()
end

function modifier_pudge_flesh_heap_lua_effect:IsDebuff()
    return false
end