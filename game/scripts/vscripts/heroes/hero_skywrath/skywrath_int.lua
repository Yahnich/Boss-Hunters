skywrath_int = class({})
LinkLuaModifier( "modifier_skywrath_int","heroes/hero_skywrath/skywrath_int.lua",LUA_MODIFIER_MOTION_NONE )

function skywrath_int:GetIntrinsicModifierName()
	return "modifier_skywrath_int"
end

modifier_skywrath_int = class({})
function modifier_skywrath_int:OnCreated(table)
	self.int = self:GetCaster():GetIntellect()*self:GetTalentSpecialValueFor("bonus_int")/100
	self:StartIntervalThink(FrameTime())
end

function modifier_skywrath_int:OnIntervalThink()
    self.int = (self:GetCaster():GetIntellect() - self.int)*self:GetTalentSpecialValueFor("bonus_int")/100
end

function modifier_skywrath_int:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
    return funcs
end

function modifier_skywrath_int:GetModifierBonusStats_Intellect()
    return self.int
end

function modifier_skywrath_int:IsHidden()
    return true
end