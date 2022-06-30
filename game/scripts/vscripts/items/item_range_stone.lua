item_range_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_range_stone_passive", "items/item_range_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_range_stone:GetIntrinsicModifierName()
	return "modifier_item_range_stone_passive"
end

function item_range_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierAttackRangeBonus"] = (item.itemData[slotIndex].baseFuncs["GetModifierAttackRangeBonus"] or 0) + self:GetLevelSpecialValueFor( "bonus_range", level-1 )
end

modifier_item_range_stone_passive = class(persistentModifier)

function modifier_item_range_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_range_stone_passive:OnRefresh()
	self.bonus_range = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.bonus_range = self.bonus_range + self:GetAbility():GetLevelSpecialValueFor( "bonus_range", i-1 )
	end
end

function modifier_item_range_stone_passive:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end

function modifier_item_range_stone_passive:GetModifierAttackRangeBonus()
	local range = self.bonus_range
	if not self:GetCaster():IsRangedAttacker() then
		range = range / 2
	end
	return range
end