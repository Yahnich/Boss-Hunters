item_crystal_of_life = class({})
LinkLuaModifier( "modifier_item_crystal_of_life_passive", "items/item_crystal_of_life.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_crystal_of_life:GetIntrinsicModifierName()
	return "modifier_item_crystal_of_life_passive"
end

modifier_item_crystal_of_life_passive = class({})

function modifier_item_crystal_of_life_passive:OnCreated()
	self.bonusHP = self:GetSpecialValueFor("hp_per_str")
end

function modifier_item_crystal_of_life_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_item_crystal_of_life_passive:GetModifierHealthBonus()
	return self:GetParent():GetStrength() * self.bonusHP
end

function modifier_item_crystal_of_life_passive:IsHidden()
	return true
end

function modifier_item_crystal_of_life_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end