item_agility_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_agility_stone_passive", "items/item_agility_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_agility_stone:GetIntrinsicModifierName()
	return "modifier_item_agility_stone_passive"
end

function item_agility_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierBonusStats_Agility"] = (item.itemData[slotIndex].funcs["GetModifierBonusStats_Agility"] or 0) + self:GetLevelSpecialValueFor( "bonus_agility", level-1 )
end

modifier_item_agility_stone_passive = class(persistentModifier)

function modifier_item_agility_stone_passive:OnCreated()
	self.agi = self:GetSpecialValueFor("bonus_agility")
end

function modifier_item_agility_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_item_agility_stone_passive:GetModifierBonusStats_Agility()
	return self.agi
end