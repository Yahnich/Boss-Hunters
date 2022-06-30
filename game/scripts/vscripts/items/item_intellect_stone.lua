item_intellect_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_intellect_stone_passive", "items/item_intellect_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_intellect_stone:GetIntrinsicModifierName()
	return "modifier_item_intellect_stone_passive"
end

function item_intellect_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierBonusStats_Intellect"] = (item.itemData[slotIndex].baseFuncs["GetModifierBonusStats_Intellect"] or 0) + self:GetLevelSpecialValueFor( "bonus_intellect", level-1 )
end

modifier_item_intellect_stone_passive = class(persistentModifier)

function modifier_item_intellect_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_intellect_stone_passive:OnRefresh()
	self.int = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.int = self.int + self:GetAbility():GetLevelSpecialValueFor( "bonus_intellect", i-1 )
	end
end

function modifier_item_intellect_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_intellect_stone_passive:GetModifierBonusStats_Intellect()
	return self.int
end