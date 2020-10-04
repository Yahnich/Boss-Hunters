item_heal_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_heal_stone_passive", "items/item_heal_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_heal_stone:GetIntrinsicModifierName()
	return "modifier_item_heal_stone_passive"
end

function item_heal_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierHealAmplify_Percentage"] = (item.itemData[slotIndex].funcs["GetModifierHealAmplify_Percentage"] or 0) + self:GetLevelSpecialValueFor( "heal_amp", level-1 )
end

modifier_item_heal_stone_passive = class(persistentModifier)

function modifier_item_heal_stone_passive:OnCreated()
	self.heal_amp = self:GetSpecialValueFor("heal_amp")
end

function modifier_item_heal_stone_passive:GetModifierHealAmplify_Percentage()
	return self.heal_amp
end


