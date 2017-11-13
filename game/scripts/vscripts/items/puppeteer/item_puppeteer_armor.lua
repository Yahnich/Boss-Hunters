item_puppeteer_armor_1 = class({})

function item_puppeteer_armor_1:GetIntrinsicModifierName()
	return "modifier_item_puppeteer_armor"
end

item_puppeteer_armor_2 = class(item_puppeteer_armor_1)
item_puppeteer_armor_3 = class(item_puppeteer_armor_1)
item_puppeteer_armor_4 = class(item_puppeteer_armor_1)
item_puppeteer_armor_5 = class(item_puppeteer_armor_1)

modifier_item_puppeteer_armor = class({})
LinkLuaModifier("modifier_item_puppeteer_armor", "items/puppeteer/item_puppeteer_armor.lua", 0)

function modifier_item_puppeteer_armor:OnCreated()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.armor = self:GetSpecialValueFor("armor")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_puppeteer_armor:OnRefresh()
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.armor = self:GetSpecialValueFor("armor")
end

function modifier_item_puppeteer_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_puppeteer_armor:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_item_puppeteer_armor:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_puppeteer_armor:IsHidden()
	return true
end