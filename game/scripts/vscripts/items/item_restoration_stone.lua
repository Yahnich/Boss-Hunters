item_restoration_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_restoration_stone_passive", "items/item_restoration_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_restoration_stone:GetIntrinsicModifierName()
	return "modifier_item_restoration_stone_passive"
end

function item_restoration_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierConstantHealthRegen"] = (item.itemData[slotIndex].baseFuncs["GetModifierConstantHealthRegen"] or 0) + self:GetLevelSpecialValueFor( "health_regen", level-1 )
end

modifier_item_restoration_stone_passive = class(persistentModifier)

function modifier_item_restoration_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_restoration_stone_passive:OnRefresh()
	self.hp_regen = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.hp_regen = self.hp_regen + self:GetAbility():GetLevelSpecialValueFor( "health_regen", i-1 )
	end
end

function modifier_item_restoration_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_item_restoration_stone_passive:GetModifierConstantHealthRegen()
	return self.hp_regen
end