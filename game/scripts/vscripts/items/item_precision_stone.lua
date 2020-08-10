item_precision_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_precision_stone_passive", "items/item_precision_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_precision_stone:GetIntrinsicModifierName()
	return "modifier_item_precision_stone_passive"
end

function item_precision_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierBaseCriticalChanceBonus"] = (item.itemData[slotIndex].funcs["GetModifierBaseCriticalChanceBonus"] or 0) + self:GetLevelSpecialValueFor( "critical_chance", level-1 )
end

modifier_item_precision_stone_passive = class(persistentModifier)

function modifier_item_precision_stone_passive:OnCreated()
	self.criticalChance = self:GetSpecialValueFor("critical_chance")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
	end
end

function modifier_item_precision_stone_passive:OnRefresh()
	self.criticalChance = self:GetSpecialValueFor("critical_chance")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalChanceBonus", self )
	end
end

function modifier_item_precision_stone_passive:OnDestroy()
	self.criticalChance = self:GetSpecialValueFor("critical_chance")
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierBaseCriticalChanceBonus", self )
	end
end

function modifier_item_precision_stone_passive:GetModifierBaseCriticalChanceBonus()
	return self.criticalChance
end