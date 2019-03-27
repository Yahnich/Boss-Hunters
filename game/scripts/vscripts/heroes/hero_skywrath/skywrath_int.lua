skywrath_int = class({})
LinkLuaModifier( "modifier_skywrath_int","heroes/hero_skywrath/skywrath_int.lua",LUA_MODIFIER_MOTION_NONE )

function skywrath_int:GetIntrinsicModifierName()
	return "modifier_skywrath_int"
end

modifier_skywrath_int = class({})
function modifier_skywrath_int:OnCreated(table)
	self.int = self:GetTalentSpecialValueFor("bonus_int")
end

function modifier_skywrath_int:OnRefresh()
    self.int = self:GetTalentSpecialValueFor("bonus_int")
end

function modifier_skywrath_int:GetModifierIntellectBonusPercentage()
    return self.int
end

function modifier_skywrath_int:IsHidden()
    return true
end