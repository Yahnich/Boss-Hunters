item_strength_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_strength_stone_passive", "items/item_strength_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_strength_stone:GetIntrinsicModifierName()
	return "modifier_item_strength_stone_passive"
end

function item_strength_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierBonusStats_Strength"] = (item.itemData[slotIndex].funcs["GetModifierBonusStats_Strength"] or 0) + self:GetLevelSpecialValueFor( "bonus_strength", level-1 )
end

modifier_item_strength_stone_passive = class(persistentModifier)

function modifier_item_strength_stone_passive:OnCreated()
	self.str = self:GetSpecialValueFor("bonus_strength")
end

function modifier_item_strength_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_item_strength_stone_passive:GetModifierBonusStats_Strength()
	return self.str
end