item_focus_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_focus_stone_passive", "items/item_focus_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_focus_stone:GetIntrinsicModifierName()
	return "modifier_item_focus_stone_passive"
end

function item_focus_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierCastRangeBonus"] = (item.itemData[slotIndex].funcs["GetModifierCastRangeBonus"] or 0) + self:GetLevelSpecialValueFor( "bonus_range", level-1 )
end

modifier_item_focus_stone_passive = class(persistentModifier)

function modifier_item_focus_stone_passive:OnCreated()
	self.bonus_range = self:GetSpecialValueFor("bonus_range")
end

function modifier_item_focus_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS}
end

function modifier_item_focus_stone_passive:GetModifierCastRangeBonus()
	return self.bonus_range
end