item_forest_armor_1 = class({})

function item_forest_armor_1:GetIntrinsicModifierName()
	return "modifier_item_forest_armor"
end

item_forest_armor_2 = class(item_forest_armor_1)
item_forest_armor_3 = class(item_forest_armor_1)
item_forest_armor_4 = class(item_forest_armor_1)
item_forest_armor_5 = class(item_forest_armor_1)

modifier_item_forest_armor = class({})
LinkLuaModifier("modifier_item_forest_armor", "items/forest/item_forest_armor.lua", 0)

function modifier_item_forest_armor:OnCreated()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_forest_armor:OnRefresh()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
end

function modifier_item_forest_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_item_forest_armor:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_item_forest_armor:IsHidden()
	return true
end