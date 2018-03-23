item_everbright_shield = class({})

LinkLuaModifier( "modifier_item_everbright_shield_on", "items/item_everbright_shield.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_everbright_shield_off", "items/item_everbright_shield.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_everbright_shield:GetIntrinsicModifierName()
	return "modifier_item_everbright_shield_off"
end

function item_everbright_shield:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_item_everbright_shield_on", {})
		caster:RemoveModifierByName("modifier_item_everbright_shield_off")
	else
		caster:AddNewModifier(caster, self, "modifier_item_everbright_shield_on", {})
		caster:RemoveModifierByName("modifier_item_everbright_shield_off")
	end
end

modifier_item_everbright_shield_off = class({})
function modifier_item_everbright_shield_off:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.castrange = self:GetAbility():GetSpecialValueFor("bonus_cast_range")
end

function modifier_item_everbright_shield_off:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_CAST_RANGE_BONUS}
end

function modifier_item_everbright_shield_off:GetModifierTotal_ConstantBlock()
	if RollPercentage(self.chance) then
		return self.block
	end
end

function modifier_item_everbright_shield_off:GetModifierCastRangeBonus()
	return self.castrange
end


function modifier_item_everbright_shield_off:IsHidden()
	return true
end

modifier_item_everbright_shield_on = class({})
function modifier_item_everbright_shield_on:OnCreated()
	self.magic_resist = self:GetAbility():GetSpecialValueFor("bonus_magic_resist")
	self.bonus_physical = self:GetAbility():GetSpecialValueFor("bonus_physical")
end

function modifier_item_everbright_shield_on:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_item_everbright_shield_on:GetModifierIncomingPhysicalDamage_Percentage()
	return self.bonus_physical
end

function modifier_item_everbright_shield_on:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_item_everbright_shield_on:GetEffectName()
	return "particles/items_fx/everbright_shield_active.vpcf"
end

function modifier_item_everbright_shield_on:IsHidden()
	return false
end
