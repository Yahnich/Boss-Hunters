item_focus_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_focus_stone_passive", "items/item_focus_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_focus_stone:GetIntrinsicModifierName()
	return "modifier_item_focus_stone_passive"
end

function item_focus_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierCastRangeBonusStacking"] = (item.itemData[slotIndex].baseFuncs["GetModifierCastRangeBonusStacking"] or 0) + self:GetLevelSpecialValueFor( "bonus_range", level-1 )
end

modifier_item_focus_stone_passive = class(persistentModifier)

function modifier_item_focus_stone_passive:OnCreated()
	self.bonus_range = self:GetSpecialValueFor("bonus_range")
end

function modifier_item_focus_stone_passive:OnRefresh()
	self.bonus_range = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.bonus_range = self.bonus_range + self:GetAbility():GetLevelSpecialValueFor( "bonus_range", i-1 )
	end
end

function modifier_item_focus_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING}
end

function modifier_item_focus_stone_passive:GetModifierCastRangeBonusStacking()
	return self.bonus_range
end