item_everbright_shield = class({})
LinkLuaModifier( "modifier_item_everbright_shield_on", "items/item_everbright_shield.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_everbright_shield_off", "items/item_everbright_shield.lua" ,LUA_MODIFIER_MOTION_NONE )

-- function item_everbright_shield:GetAbilityTextureName()
	-- if self:GetCaster():HasModifier("modifier_item_everbright_shield_on") then
		-- return "custom/everbright_shield"
	-- else
		-- return "custom/everbright_shield_off"
	-- end
-- end

function item_everbright_shield:GetIntrinsicModifierName()
	return "modifier_item_everbright_shield_off"
end

function item_everbright_shield:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
	caster:AddNewModifier(caster, self, "modifier_item_everbright_shield_on", {duration = self:GetSpecialValueFor("duration")})
end

modifier_item_everbright_shield_off = class(itemBaseClass)

function modifier_item_everbright_shield_off:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.castrange = self:GetAbility():GetSpecialValueFor("bonus_cast_range")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_magic_resist")
end

function modifier_item_everbright_shield_off:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_CAST_RANGE_BONUS,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
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

function modifier_item_everbright_shield_off:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_item_everbright_shield_off:IsHidden()
	return true
end

function modifier_item_everbright_shield_off:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_everbright_shield_on = class({})
function modifier_item_everbright_shield_on:OnCreated()
	self.magic_resist = self:GetAbility():GetSpecialValueFor("active_magic_resist")
	self.magic_resist = self:GetAbility():GetSpecialValueFor("active_status_resist")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_item_everbright_shield_on:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_item_everbright_shield_on:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function modifier_item_everbright_shield_on:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_item_everbright_shield_on:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_item_everbright_shield_on:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_item_everbright_shield_on:IsHidden()
	return false
end
