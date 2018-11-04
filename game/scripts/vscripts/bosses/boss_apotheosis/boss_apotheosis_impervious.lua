boss_apotheosis_impervious = class({})

function boss_apotheosis_impervious:GetIntrinsicModifierName()
	return "modifier_boss_apotheosis_impervious"
end

modifier_boss_apotheosis_impervious = class({})
LinkLuaModifier( "modifier_boss_apotheosis_impervious", "bosses/boss_apotheosis/boss_apotheosis_impervious", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_apotheosis_impervious:OnCreated()
	self.limit = self:GetSpecialValueFor("max_hp_dmg") / 100
end

function modifier_boss_apotheosis_impervious:OnRefresh()
	self.limit = self:GetSpecialValueFor("max_hp_dmg") / 100
end

function modifier_boss_apotheosis_impervious:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_boss_apotheosis_impervious:GetModifierTotal_ConstantBlock(params)
	if params.damage > self:GetParent():GetMaxHealth() * self.limit and not self:GetParent():PassivesDisabled() then
		return params.damage - self:GetParent():GetMaxHealth() * self.limit
	end
end

function modifier_boss_apotheosis_impervious:IsHidden()
	return true
end

function modifier_boss_apotheosis_impervious:IsPurgable()
	return false
end