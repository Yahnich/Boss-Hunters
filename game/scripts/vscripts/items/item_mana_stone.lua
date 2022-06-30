item_mana_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_mana_stone_passive", "items/item_mana_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_mana_stone:GetIntrinsicModifierName()
	return "modifier_item_mana_stone_passive"
end

function item_mana_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierManaBonus"] = (item.itemData[slotIndex].baseFuncs["GetModifierManaBonus"] or 0) + self:GetLevelSpecialValueFor( "mana", level-1 )
end

modifier_item_mana_stone_passive = class(itemBasicBaseClass)

function modifier_item_mana_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_mana_stone_passive:OnRefresh()
	self.mp = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.mp = self.mp + self:GetAbility():GetLevelSpecialValueFor( "mana", i-1 )
	end
end

function modifier_item_mana_stone_passive:DeclareFunctions()
	return {
				MODIFIER_PROPERTY_MANA_BONUS
			}
end

function modifier_item_mana_stone_passive:GetModifierManaBonus()
	return self.mp
end
