item_executioners_blade = class({})
LinkLuaModifier( "modifier_item_executioners_blade_handle", "items/item_executioners_blade.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_executioners_blade:GetIntrinsicModifierName()
	return "modifier_item_executioners_blade_handle"
end

modifier_item_executioners_blade_handle = class({})
function modifier_item_executioners_blade_handle:OnCreated()
	self.executioners_blade_damage = self:GetSpecialValueFor("critical_damage")
	self.executioners_blade_chance = self:GetSpecialValueFor("critical_chance")
end

function modifier_item_executioners_blade_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_executioners_blade_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_executioners_bladeICALSTRIKE}
end

function modifier_item_executioners_blade_handle:GetModifierPreAttack_executioners_bladeicalStrike()
	if RollPercentage( self.executioners_blade_chance ) then
		return self.executioners_blade_damage
	end
end

function modifier_item_executioners_blade_handle:IsHidden()
	return true
end