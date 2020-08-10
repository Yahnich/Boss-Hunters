pudge_flesh_heap_lua = class({})
LinkLuaModifier("modifier_pudge_flesh_heap_lua", "heroes/hero_pudge/pudge_flesh_heap_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pudge_flesh_heap_lua_effect", "heroes/hero_pudge/pudge_flesh_heap_lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_lua:GetIntrinsicModifierName()
	return "modifier_pudge_flesh_heap_lua"
end

function pudge_flesh_heap_lua:AddSkinHeap( amount )
	local caster = self:GetCaster()
	local stacks = amount or 1
	local duration = self:GetTalentSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_pudge_flesh_heap_lua_effect", {Duration = duration}):AddIndependentStack(duration, nil, false, {stacks = stacks})
end

modifier_pudge_flesh_heap_lua = class({})
function modifier_pudge_flesh_heap_lua:OnCreated(table)
	 self.mr = self:GetSpecialValueFor("magic_resist")
end

function modifier_pudge_flesh_heap_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function modifier_pudge_flesh_heap_lua:GetModifierMagicalResistanceBonus()
    return self.mr
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
    return math.min( self:GetStackCount(), 50 )
end

function modifier_pudge_flesh_heap_lua_effect:IsDebuff()
    return false
end