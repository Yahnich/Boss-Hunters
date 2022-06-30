item_quick_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_quick_stone_passive", "items/item_quick_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_quick_stone:GetIntrinsicModifierName()
	return "modifier_item_quick_stone_passive"
end

function item_quick_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierAttackSpeedBonus_Constant"] = (item.itemData[slotIndex].baseFuncs["GetModifierAttackSpeedBonus_Constant"] or 0) + self:GetLevelSpecialValueFor( "attack_speed", level-1 )
end

modifier_item_quick_stone_passive = class(persistentModifier)

function modifier_item_quick_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_quick_stone_passive:OnRefresh()
	self.as = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.as = self.as + self:GetAbility():GetLevelSpecialValueFor( "attack_speed", i-1 )
	end
end

function modifier_item_quick_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_quick_stone_passive:GetModifierAttackSpeedBonus_Constant()
	return self.as
end