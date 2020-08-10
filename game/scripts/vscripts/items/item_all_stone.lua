item_all_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_all_stone_passive", "items/item_all_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_all_stone:GetIntrinsicModifierName()
	return "modifier_item_all_stone_passive"
end

function item_all_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierBonusStats_Strength"] = (item.itemData[slotIndex].funcs["GetModifierBonusStats_Strength"] or 0) + self:GetLevelSpecialValueFor( "bonus_stats", level-1 )
	item.itemData[slotIndex].funcs["GetModifierBonusStats_Agility"] = (item.itemData[slotIndex].funcs["GetModifierBonusStats_Agility"] or 0) + self:GetLevelSpecialValueFor( "bonus_stats", level-1 )
	item.itemData[slotIndex].funcs["GetModifierBonusStats_Intellect"] = (item.itemData[slotIndex].funcs["GetModifierBonusStats_Intellect"] or 0) + self:GetLevelSpecialValueFor( "bonus_stats", level-1 )
end

modifier_item_all_stone_passive = class(persistentModifier)

function modifier_item_all_stone_passive:OnCreated()
	self.all = self:GetSpecialValueFor("bonus_stats")
end

function modifier_item_all_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_item_all_stone_passive:GetModifierBonusStats_Strength()
	return self.all
end

function modifier_item_all_stone_passive:GetModifierBonusStats_Agility()
	return self.all
end

function modifier_item_all_stone_passive:GetModifierBonusStats_Intellect()
	return self.all
end