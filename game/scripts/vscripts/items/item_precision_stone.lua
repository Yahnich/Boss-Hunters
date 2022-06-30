item_precision_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_precision_stone_passive", "items/item_precision_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_precision_stone:GetIntrinsicModifierName()
	return "modifier_item_precision_stone_passive"
end

function item_precision_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierBaseCriticalChanceBonus"] = (item.itemData[slotIndex].baseFuncs["GetModifierBaseCriticalChanceBonus"] or 0) + self:GetLevelSpecialValueFor( "critical_chance", level-1 )
end

modifier_item_precision_stone_passive = class(persistentModifier)

function modifier_item_precision_stone_passive:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
	end
end

function modifier_item_precision_stone_passive:OnRefresh()
	self.criticalChance = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.criticalChance = self.criticalChance + self:GetAbility():GetLevelSpecialValueFor( "critical_chance", i-1 )
	end
end

function modifier_item_precision_stone_passive:OnDestroy()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierBaseCriticalChanceBonus", self )
	end
end

function modifier_item_precision_stone_passive:GetModifierBaseCriticalChanceBonus()
	return self.criticalChance
end