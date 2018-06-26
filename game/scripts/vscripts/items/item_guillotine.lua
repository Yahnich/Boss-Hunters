item_guillotine = class({})
function item_guillotine:GetIntrinsicModifierName()
	return "modifier_item_guillotine_handle"
end

modifier_item_guillotine_handle = class({})
LinkLuaModifier( "modifier_item_guillotine_handle", "items/item_guillotine.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_guillotine_handle:OnCreated()
	self.crit_damage = self:GetSpecialValueFor("critical_damage")
	self.crit_chance = self:GetSpecialValueFor("critical_chance")
	self.damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_guillotine_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_guillotine_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_item_guillotine_handle:GetModifierBaseAttack_BonusDamage()
	return self.damage
end

function modifier_item_guillotine_handle:GetModifierPreAttack_CriticalStrike()
	if RollPercentage( self.crit_chance ) then
		return self.crit_damage
	end
end

function modifier_item_guillotine_handle:IsHidden()
	return true
end

function modifier_item_guillotine_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end