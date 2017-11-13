item_justicar_armor_1 = class({})

function item_justicar_armor_1:GetIntrinsicModifierName()
	return "modifier_item_justicar_armor"
end

item_justicar_armor_2 = class(item_justicar_armor_1)
item_justicar_armor_3 = class(item_justicar_armor_1)
item_justicar_armor_4 = class(item_justicar_armor_1)
item_justicar_armor_5 = class(item_justicar_armor_1)

modifier_item_justicar_armor = class({})
LinkLuaModifier("modifier_item_justicar_armor", "items/justicar/item_justicar_armor.lua", 0)

function modifier_item_justicar_armor:OnCreated()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
	self.bonus_mr = self:GetSpecialValueFor("magic_resist")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_justicar_armor:OnRefresh()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
	self.bonus_mr = self:GetSpecialValueFor("magic_resist")
end

function modifier_item_justicar_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS	}
end

function modifier_item_justicar_armor:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_item_justicar_armor:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_item_justicar_armor:GetModifierMagicalResistanceBonus()
	return self.bonus_mr
end

function modifier_item_justicar_armor:IsHidden()
	return true
end