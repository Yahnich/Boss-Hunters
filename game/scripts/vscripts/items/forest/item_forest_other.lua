item_forest_other_1 = class({})

function item_forest_other_1:GetIntrinsicModifierName()
	return "modifier_item_forest_other"
end

item_forest_other_2 = class(item_forest_other_1)
item_forest_other_3 = class(item_forest_other_1)
item_forest_other_4 = class(item_forest_other_1)
item_forest_other_5 = class(item_forest_other_1)

modifier_item_forest_other = class({})
LinkLuaModifier("modifier_item_forest_other", "items/forest/item_forest_other.lua", 0)

function modifier_item_forest_other:OnCreated()
	self.cdr = self:GetSpecialValueFor("cdr")
	self.armor = self:GetSpecialValueFor("armor")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_forest_other:OnRefresh()
	self.cdr = self:GetSpecialValueFor("cdr")
	self.armor = self:GetSpecialValueFor("armor")
end

function modifier_item_forest_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_forest_other:GetModifierPercentageCooldownStacking()
	return self.cdr
end

function modifier_item_forest_other:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_forest_other:IsHidden()
	return true
end