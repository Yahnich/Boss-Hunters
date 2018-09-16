item_pages_buckler = class({})

LinkLuaModifier( "modifier_item_pages_buckler", "items/item_pages_buckler.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_pages_buckler:GetIntrinsicModifierName()
	return "modifier_item_pages_buckler"
end

modifier_item_pages_buckler = class(itemBaseClass)

function modifier_item_pages_buckler:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_pages_buckler:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_item_pages_buckler:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(self.chance) and params.attacker ~= self:GetParent() and self:GetParent():IsRealHero() then
		return self.block
	end
end

function modifier_item_pages_buckler:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_pages_buckler:IsHidden()
	return true
end

function modifier_item_pages_buckler:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end