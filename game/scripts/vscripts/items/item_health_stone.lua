item_health_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_health_stone_passive", "items/item_health_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_health_stone:GetIntrinsicModifierName()
	return "modifier_item_health_stone_passive"
end

function item_health_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierExtraHealthBonus"] = (item.itemData[slotIndex].funcs["GetModifierExtraHealthBonus"] or 0) + self:GetLevelSpecialValueFor( "health", level-1 )
	item.itemData[slotIndex].funcs["GetModifierConstantHealthRegen"] = (item.itemData[slotIndex].funcs["GetModifierConstantHealthRegen"] or 0) + self:GetLevelSpecialValueFor( "health_regeneration", level-1 )
end

modifier_item_health_stone_passive = class(persistentModifier)

function modifier_item_health_stone_passive:OnCreated()
	self.hp = self:GetSpecialValueFor("health")
	self.hp_regen = self:GetSpecialValueFor("health_regeneration")
end

function modifier_item_health_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_item_health_stone_passive:GetModifierExtraHealthBonus()
	return self.hp
end

function modifier_item_health_stone_passive:GetModifierConstantHealthRegen()
	return self.hp_regen
end