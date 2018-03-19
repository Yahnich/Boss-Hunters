item_pages_buckler = class({})

LinkLuaModifier( "modifier_item_pages_buckler", "items/item_pages_buckler.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_pages_buckler:GetIntrinsicModifierName()
	return "modifier_item_pages_buckler"
end

modifier_item_pages_buckler = class({})
function modifier_item_pages_buckler:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
end

function modifier_item_pages_buckler:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_item_pages_buckler:GetModifierTotal_ConstantBlock()
	if RollPercentage(self.chance) then
		return self.block
	end
end

function modifier_item_pages_buckler:IsHidden()
	return true
end