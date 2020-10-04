item_longevity_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_longevity_stone_passive", "items/item_longevity_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_longevity_stone:GetIntrinsicModifierName()
	return "modifier_item_longevity_stone_passive"
end

function item_longevity_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierStatusAmplify_Percentage"] = (item.itemData[slotIndex].funcs["GetModifierStatusAmplify_Percentage"] or 0) + self:GetLevelSpecialValueFor( "status_amp", level-1 )
end

modifier_item_longevity_stone_passive = class(persistentModifier)

function modifier_item_longevity_stone_passive:OnCreated()
	self.status_amp = self:GetSpecialValueFor("status_amp")
end

function modifier_item_longevity_stone_passive:GetModifierStatusAmplify_Percentage()
	return self.status_amp
end
