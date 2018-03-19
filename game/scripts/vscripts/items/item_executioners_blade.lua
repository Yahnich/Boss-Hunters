item_executioners_blade = class({})
function item_executioners_blade:GetIntrinsicModifierName()
	return "modifier_item_executioners_blade_handle"
end

modifier_item_executioners_blade_handle = class({})
LinkLuaModifier( "modifier_item_executioners_blade_handle", "items/item_executioners_blade.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_executioners_blade_handle:OnCreated()
	self.crit_damage = self:GetSpecialValueFor("critical_damage")
	self.crit_chance = self:GetSpecialValueFor("critical_chance")
end

function modifier_item_executioners_blade_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_executioners_blade_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_item_executioners_blade_handle:GetModifierPreAttack_CriticalStrike()
	if RollPercentage( self.crit_chance ) then
		return self.crit_damage
	end
end

function modifier_item_executioners_blade_handle:IsHidden()
	return true
end