item_hawks_feather = class({})

LinkLuaModifier( "modifier_item_hawks_feather", "items/item_hawks_feather.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_hawks_feather:GetIntrinsicModifierName()
	return "modifier_item_hawks_feather"
end

modifier_item_hawks_feather = class({})

function modifier_item_hawks_feather:OnCreated()
	self.chance = self:GetSpecialValueFor("pierce_chance")
end

function modifier_item_hawks_feather:GetAccuracy()
	return self.chance
end

function modifier_item_hawks_feather:IsHidden()
	return true
end

function modifier_item_hawks_feather:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
