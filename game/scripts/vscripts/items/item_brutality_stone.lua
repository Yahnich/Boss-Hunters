item_brutality_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_brutality_stone_passive", "items/item_brutality_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_brutality_stone:GetIntrinsicModifierName()
	return "modifier_item_brutality_stone_passive"
end

function item_brutality_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierBaseCriticalDamageBonus"] = (item.itemData[slotIndex].funcs["GetModifierBaseCriticalDamageBonus"] or 0) + self:GetLevelSpecialValueFor( "critical_damage", level-1 )
end

modifier_item_brutality_stone_passive = class(persistentModifier)

function modifier_item_brutality_stone_passive:OnCreated()
	self.criticalChance = self:GetSpecialValueFor("critical_damage")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalDamageBonus", self )
	end
end

function modifier_item_brutality_stone_passive:OnRefresh()
	self.criticalChance = self:GetSpecialValueFor("critical_damage")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierBaseCriticalDamageBonus", self )
	end
end

function modifier_item_brutality_stone_passive:OnDestroy()
	self.criticalChance = self:GetSpecialValueFor("critical_damage")
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierBaseCriticalDamageBonus", self )
	end
end

function modifier_item_brutality_stone_passive:GetModifierBaseCriticalDamageBonus()
	return self.criticalChance
end