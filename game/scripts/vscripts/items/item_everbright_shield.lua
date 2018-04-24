item_everbright_shield = class({})
LinkLuaModifier( "modifier_item_everbright_shield_on", "items/item_everbright_shield.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_everbright_shield_off", "items/item_everbright_shield.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_everbright_shield:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_everbright_shield_on") then
		return "custom/everbright_shield"
	else
		return "custom/everbright_shield_off"
	end
end

function item_everbright_shield:GetIntrinsicModifierName()
	return "modifier_item_everbright_shield_handler"
end

function item_everbright_shield:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_item_everbright_shield_on", {})
		caster:RemoveModifierByName("modifier_item_everbright_shield_off")
	else
		caster:AddNewModifier(caster, self, "modifier_item_everbright_shield_off", {})
		caster:RemoveModifierByName("modifier_item_everbright_shield_on")
	end
end

modifier_item_everbright_shield_handler = class({})
LinkLuaModifier( "modifier_item_everbright_shield_handler", "items/item_everbright_shield.lua" ,LUA_MODIFIER_MOTION_NONE )
if IsServer() then
	function modifier_item_everbright_shield_handler:OnCreated()
		local ability = self:GetAbility()
		local caster = self:GetParent()
		if ability:GetToggleState() then
			caster:AddNewModifier(caster, ability, "modifier_item_everbright_shield_on", {})
			caster:RemoveModifierByName("modifier_item_everbright_shield_off")
		else
			caster:AddNewModifier(caster, ability, "modifier_item_everbright_shield_off", {})
			caster:RemoveModifierByName("modifier_item_everbright_shield_on")
		end
	end
	
	function modifier_item_everbright_shield_handler:OnDestroy()
		local caster = self:GetParent()
		caster:RemoveModifierByName("modifier_item_everbright_shield_on")
		caster:RemoveModifierByName("modifier_item_everbright_shield_off")
	end
end

function modifier_item_everbright_shield_handler:IsHidden()
	return true
end


modifier_item_everbright_shield_off = class({})
function modifier_item_everbright_shield_off:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.castrange = self:GetAbility():GetSpecialValueFor("bonus_cast_range")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_everbright_shield_off:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_CAST_RANGE_BONUS,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
			}
end

function modifier_item_everbright_shield_off:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
		return self.block
	end
end

function modifier_item_everbright_shield_off:GetModifierCastRangeBonus()
	return self.castrange
end

function modifier_item_everbright_shield_off:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_everbright_shield_off:IsHidden()
	return true
end

modifier_item_everbright_shield_on = class({})
function modifier_item_everbright_shield_on:OnCreated()
	self.magic_resist = self:GetAbility():GetSpecialValueFor("bonus_magic_resist")
	self.bonus_physical = self:GetAbility():GetSpecialValueFor("bonus_physical") / 100
	
	self.armor_loss = (self:GetParent():GetPhysicalArmorValue() * self.bonus_physical) * (-1)
	
	self:StartIntervalThink(0.15)
end

function modifier_item_everbright_shield_on:OnIntervalThink()
	self.armor_loss = 0
	self.armor_loss = (self:GetParent():GetPhysicalArmorValue() * self.bonus_physical) * (-1)
end

function modifier_item_everbright_shield_on:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_item_everbright_shield_on:GetModifierPhysicalArmorBonus()
	return self.armor_loss
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
