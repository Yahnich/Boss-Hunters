item_health_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_health_stone_passive", "items/item_health_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_health_stone:GetIntrinsicModifierName()
	return "modifier_item_health_stone_passive"
end

function item_health_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierExtraHealthBonus"] = (item.itemData[slotIndex].baseFuncs["GetModifierExtraHealthBonus"] or 0) + self:GetLevelSpecialValueFor( "health", level-1 )
end

modifier_item_health_stone_passive = class(persistentModifier)

function modifier_item_health_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_health_stone_passive:OnRefresh()
	self.health = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.health = self.health + self:GetAbility():GetLevelSpecialValueFor( "health", i-1 )
	end
end

function modifier_item_health_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_item_health_stone_passive:GetModifierExtraHealthBonus()
	return self.health
end