item_mana_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_mana_stone_passive", "items/item_mana_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_mana_stone:GetIntrinsicModifierName()
	return "modifier_item_mana_stone_passive"
end

function item_mana_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierManaBonus"] = (item.itemData[slotIndex].funcs["GetModifierManaBonus"] or 0) + self:GetLevelSpecialValueFor( "mana", level-1 )
	item.itemData[slotIndex].funcs["GetModifierConstantManaRegen"] = (item.itemData[slotIndex].funcs["GetModifierConstantManaRegen"] or 0) + self:GetLevelSpecialValueFor( "mana_regeneration", level-1 )
end

modifier_item_mana_stone_passive = class(itemBasicBaseClass)

function modifier_item_mana_stone_passive:OnCreated()
	self.mp = self:GetSpecialValueFor("mana")
	self.mp_regen = self:GetSpecialValueFor("mana_regeneration")
end

function modifier_item_mana_stone_passive:DeclareFunctions()
	return {
				MODIFIER_PROPERTY_MANA_BONUS, 
				MODIFIER_PROPERTY_MANA_REGEN_CONSTANT 
			}
end

function modifier_item_mana_stone_passive:GetModifierManaBonus()
	return self.mp
end

function modifier_item_mana_stone_passive:GetModifierConstantManaRegen()
	return self.mp_regen
end