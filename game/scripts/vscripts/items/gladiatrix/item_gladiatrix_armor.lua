item_gladiatrix_armor_1 = class({})

function item_gladiatrix_armor_1:GetIntrinsicModifierName()
	return "modifier_item_gladiatrix_armor"
end

item_gladiatrix_armor_2 = class(item_gladiatrix_armor_1)
item_gladiatrix_armor_3 = class(item_gladiatrix_armor_1)
item_gladiatrix_armor_4 = class(item_gladiatrix_armor_1)
item_gladiatrix_armor_5 = class(item_gladiatrix_armor_1)

modifier_item_gladiatrix_armor = class({})
LinkLuaModifier("modifier_item_gladiatrix_armor", "items/gladiatrix/item_gladiatrix_armor.lua", 0)

function modifier_item_gladiatrix_armor:OnCreated()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.evasion = self:GetSpecialValueFor("evasion")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_gladiatrix_armor:OnRefresh()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.evasion = self:GetSpecialValueFor("evasion")
end

function modifier_item_gladiatrix_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_item_gladiatrix_armor:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_item_gladiatrix_armor:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_gladiatrix_other:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_item_gladiatrix_armor:IsHidden()
	return true
end