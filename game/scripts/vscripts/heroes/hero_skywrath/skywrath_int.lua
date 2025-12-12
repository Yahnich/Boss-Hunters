skywrath_int = class({})

function skywrath_int:GetIntrinsicModifierName()
	return "modifier_skywrath_int"
end

modifier_skywrath_int = class({})
LinkLuaModifier( "modifier_skywrath_int","heroes/hero_skywrath/skywrath_int.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_skywrath_int:OnCreated(table)
	self:OnRefresh()
end

function modifier_skywrath_int:OnRefresh()
    self.int = self:GetSpecialValueFor("bonus_int")
	self:GetParent():HookInModifier("GetModifierIntellectBonusPercentage", self)
end

function modifier_skywrath_int:OnDestroy()
    self.int = self:GetSpecialValueFor("bonus_int")
	self:GetParent():HookOutModifier("GetModifierIntellectBonusPercentage", self)
end

function modifier_skywrath_int:GetModifierIntellectBonusPercentage()
    return self.int
end

function modifier_skywrath_int:IsHidden()
    return true
end