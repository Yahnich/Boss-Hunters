item_fortress_shield = class({})

LinkLuaModifier( "modifier_item_fortress_shield", "items/item_fortress_shield.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_fortress_shield:GetIntrinsicModifierName()
	return "modifier_item_fortress_shield"
end

modifier_item_fortress_shield = class({})
function modifier_item_fortress_shield:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_fortress_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_item_fortress_shield:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_fortress_shield:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
		return self.block
	end
end

function modifier_item_fortress_shield:IsHidden()
	return true
end

function modifier_item_fortress_shield:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end